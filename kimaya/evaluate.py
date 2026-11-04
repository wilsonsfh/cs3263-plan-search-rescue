#!/usr/bin/env python3
"""Auditable LLM -> PDDL evaluation. Standard library only; no live calls by default."""
import argparse
import ast
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'pipelines'))
from checker import check
from fidelity import compare
from api_backend import APIBackend, PauseBatch, load_key

# Read the exact shared prompts/configuration without importing the API SDK.
def shared_constants():
    wanted = {'TASK', 'PDDL_INSTRUCTIONS', 'REPAIR_PDDL', 'MS'}
    out = {}
    for node in ast.parse((ROOT/'pipelines/pipelines.py').read_text()).body:
        if isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id in wanted:
                    out[t.id] = ast.literal_eval(node.value)
    return out


def digest(data):
    return hashlib.sha256(data).hexdigest()


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + '.tmp')
    tmp.write_text(json.dumps(value, indent=2))
    tmp.replace(path)


def planner(problem, domain, fd, timeout, dest):
    dest.mkdir(parents=True, exist_ok=True)
    prob = dest/'problem.pddl'
    prob.write_text(problem)
    searches = [('optimal-lmcut', ['--search', 'astar(lmcut())']),
                ('optimal-ms', ['--search', shared_constants()['MS']]),
                ('lama-anytime', ['--alias', 'seq-sat-lama-2011'])]
    records = []
    for name, args in searches:
        work = dest/name
        work.mkdir(exist_ok=True)
        cmd = [sys.executable, str(fd), '--overall-time-limit', f'{timeout}s']
        cmd += args + [str(domain), str(prob)] if args[0] == '--alias' else [str(domain), str(prob)] + args
        start = time.perf_counter()
        try:
            p = subprocess.run(cmd, cwd=work, capture_output=True, text=True, timeout=timeout+60)
            code, stdout, stderr = p.returncode, p.stdout, p.stderr
        except subprocess.TimeoutExpired as e:
            code = None
            stdout = e.stdout or b''
            stderr = e.stderr or b''
            stdout = stdout.decode(errors='replace') if isinstance(stdout, bytes) else stdout
            stderr = stderr.decode(errors='replace') if isinstance(stderr, bytes) else stderr
        except OSError as e:
            code, stdout, stderr = -1, '', str(e)
        elapsed = time.perf_counter()-start
        (work/'stdout.txt').write_text(stdout)
        (work/'stderr.txt').write_text(stderr)
        plans = sorted(work.glob('sas_plan*'), key=lambda p: int(p.suffix[1:]) if p.suffix[1:].isdigit() else 0)
        rec = {'search': name, 'seconds': elapsed, 'exit_code': code, 'command': cmd,
               'timed_out': code in (None, 2, 3, 21, 23, 24), 'optimal_for_generated_problem': code == 0 and name.startswith('optimal')}
        records.append(rec)
        if plans:
            lines = [l for l in plans[-1].read_text().splitlines() if l.startswith('(')]
            return {'plan': lines, 'searches': records, 'seconds': sum(r['seconds'] for r in records),
                    'status': 'plan_found', 'search': name,
                    'optimal_for_generated_problem': rec['optimal_for_generated_problem']}
        if code not in (None, 21, 23):
            status = ('unsolvable' if code in (10, 11) else 'pddl_error' if code in (31, 34)
                      else 'resource_error' if code in (20, 22, 24) else 'planner_error')
            break
    else:
        status = 'timeout'
    return {'plan': None, 'searches': records, 'seconds': sum(r['seconds'] for r in records),
            'status': status, 'error': (stdout+'\n'+stderr)[-6000:] or status}


def cli_call(system, messages, model, effort, dest):
    # Mirrors Wilson's stateless CLI adapter; retain provider metadata and failures.
    blocked = ('ANTHROPIC_API_KEY', 'ANTHROPIC_AUTH_TOKEN', 'ANTHROPIC_BASE_URL', 'OPENAI_BASE_URL',
               'CLAUDE_CODE_USE_BEDROCK', 'CLAUDE_CODE_USE_VERTEX', 'CLAUDE_CODE_USE_FOUNDRY')
    env = {k:v for k,v in os.environ.items() if k not in blocked}
    prompt = messages[0]['content'] if len(messages)==1 else '\n\n'.join(
        ('=== YOUR PREVIOUS ANSWER ===\n' if m['role']=='assistant' else '=== USER ===\n')+m['content'] for m in messages)
    save(dest/'request.json', {'system': system, 'messages': messages, 'model': model, 'effort': effort})
    cmd = ['claude', '-p', '--model', model, '--effort', effort, '--tools', '', '--setting-sources', '',
           '--no-session-persistence', '--output-format', 'json', '--system-prompt', system]
    start = time.perf_counter()
    result = {'ok': False, 'text': '', 'input_tokens': None, 'output_tokens': None, 'thinking_tokens': None}
    try:
        with tempfile.TemporaryDirectory() as cwd:
            p = subprocess.run(cmd, input=prompt, cwd=cwd, env=env, capture_output=True, text=True, timeout=1800)
        (dest/'cli_stdout.txt').write_text(p.stdout)
        (dest/'cli_stderr.txt').write_text(p.stderr)
        d = json.loads(p.stdout)
        u = d.get('usage') or {}
        result.update(ok=p.returncode==0 and not d.get('is_error'), text=d.get('result',''),
                      stop_reason=d.get('stop_reason'), input_tokens=sum(u.get(k,0) for k in
                      ('input_tokens','cache_creation_input_tokens','cache_read_input_tokens')),
                      output_tokens=u.get('output_tokens'), thinking_tokens=(u.get('output_tokens_details') or {}).get('thinking_tokens'),
                      model_usage=d.get('modelUsage'), reported_cost_usd=d.get('total_cost_usd'))
        if not result['ok']:
            result['error'] = 'CLI error: '+str(d.get('result',''))[:1000]
    except (OSError, subprocess.TimeoutExpired, ValueError) as e:
        result['error'] = str(e)
    result['seconds'] = time.perf_counter()-start
    return result


def run_case(inst, report, reference, domain, cfg, dest, call=cli_call, plan_fn=planner):
    start = time.perf_counter()
    constants = shared_constants()
    system = constants['TASK']+'\n\n'+constants['PDDL_INSTRUCTIONS'].format(domain=domain.read_text())
    messages = [{'role':'user', 'content':'FIELD REPORT\n\n'+report}]
    rec = {'instance':inst['id'], 'size':inst['size'], 'mode':cfg['mode'], 'model':cfg['model'],
           'effort':cfg['effort'], 'attempts':[], 'status':'running'}
    llm_seconds = planner_seconds = validation_seconds = fidelity_seconds = 0.0
    limit = cfg['repairs'] if cfg['mode']=='live' else 0
    for n in range(limit+1):
        attempt_dir = dest/f'attempt-{n}'
        attempt_dir.mkdir(parents=True, exist_ok=True)
        a = {'index':n}
        if cfg['mode']=='live':
            response = call(system, messages, cfg['model'], cfg['effort'], attempt_dir)
            a['llm'] = response
            llm_seconds += response['seconds']
            blocks = re.findall(r'```(?:pddl|lisp)?\s*\n(.*?)```',response['text'],re.S)
            problem = blocks[-1] if blocks else None
            a['pddl_blocks'] = len(blocks)
            messages.append({'role':'assistant','content':response.get('content',response['text'])})
            if not response['ok']:
                a['status']='llm_error'
                rec['attempts'].append(a)
                break
        else:
            problem = reference
        a['pddl_characters'] = len(problem) if problem else 0
        t = time.perf_counter()
        a['fidelity'] = compare(problem or '', reference)
        a['fidelity_seconds']=time.perf_counter()-t
        fidelity_seconds += a['fidelity_seconds']
        if problem is not None:
            (attempt_dir/'generated.pddl').write_text(problem)
        if cfg['mode']=='mock':
            lines=(ROOT/'pddl/instances'/f"{inst['id']}.best-plan").read_text().splitlines()
            info={'plan':lines,'status':'plan_found','seconds':0,'searches':[], 'search':'mock-fixture',
                  'optimal_for_generated_problem':False}
        elif problem is None:
            info={'plan':None,'status':'output_format_error','seconds':0,'searches':[],
                  'error':'no PDDL code block found'}
        else:
            cached_planner=attempt_dir/'planner_result.json'
            if cached_planner.exists():
                info=json.loads(cached_planner.read_text())
            else:
                info=plan_fn(problem,domain,Path(cfg['fd']),cfg['timeout'],attempt_dir/'planner')
                save(cached_planner,info)
        a['planner']=info
        planner_seconds += info['seconds']
        a['status']=info['status']
        if info['plan'] is not None:
            t=time.perf_counter()
            a['result']=check(inst,info['plan'])
            a['validation_seconds']=time.perf_counter()-t
            validation_seconds += a['validation_seconds']
            a['status']='valid' if a['result']['valid'] else 'ground_truth_invalid'
            a['plan_actions']=len(info['plan'])
        rec['attempts'].append(a)
        rec['status']=a['status']
        save(dest/'record.json',rec)  # checkpoint each completed attempt
        # Never reveal ground-truth fidelity/checker feedback to the model.
        if info['plan'] is not None or cfg['mode']!='live' or n==limit:
            break
        if info['status'] in ('planner_error','resource_error','timeout'):
            break  # infrastructure/time budget failures do not justify changing facts
        messages.append({'role':'user','content':constants['REPAIR_PDDL'].format(error=info.get('error',info['status']))})
    rec['status']=rec['attempts'][-1]['status']
    rec['result']=rec['attempts'][-1].get('result',{'valid':False,'cost':None})
    rec['first_valid']=rec['attempts'][0].get('result',{}).get('valid',False)
    rec['first_status']=rec['attempts'][0]['status']
    rec['timing']={'llm_seconds':llm_seconds,'planner_seconds':planner_seconds,
                   'validation_seconds':validation_seconds,'fidelity_seconds':fidelity_seconds,
                   'total_seconds':time.perf_counter()-start}
    rec['timing']['other_seconds']=max(0.0,rec['timing']['total_seconds']-llm_seconds-planner_seconds-validation_seconds-fidelity_seconds)
    rec['usage']={'calls':sum('llm' in a for a in rec['attempts'])}
    for k in ('input_tokens','output_tokens','thinking_tokens'):
        values=[a['llm'].get(k) for a in rec['attempts'] if 'llm' in a]
        rec['usage'][k]=sum(values) if values and all(v is not None for v in values) else None
    rec['usage']['estimated_cost_usd']=sum(a.get('llm',{}).get('estimated_cost_usd',0) for a in rec['attempts'])
    rec['usage']['initial_input_tokens']=rec['attempts'][0].get('llm',{}).get('input_tokens')
    rec['usage']['initial_output_tokens']=rec['attempts'][0].get('llm',{}).get('output_tokens')
    for key in ('input_tokens','output_tokens'):
        vals=[a['llm'].get(key) for a in rec['attempts'][1:] if 'llm' in a]
        rec['usage']['repair_'+key]=sum(vals) if all(v is not None for v in vals) else None
    rec['complete']=True
    save(dest/'record.json',rec)
    return rec


def summarise(out):
    refs={r['id']:r for r in csv.DictReader((ROOT/'pddl/results/best_reference.csv').open())}
    wilson={}
    for tag in ('main','main-sonnet','main-haiku'):
        for p in (ROOT/'pipelines/runs'/tag/'direct').glob('*.json'):
            r=json.loads(p.read_text());wilson[(r['model'],r['instance'],r['level'])]=r['result']
    rows=[]
    translations=[]
    for p in sorted((out/'cases').glob('*/record.json')):
        r=json.loads(p.read_text())
        if not r.get('complete'): continue
        ref=refs[r['instance']];cost=r['result'].get('cost');valid=r['result']['valid']
        final=r['attempts'][-1] if r['attempts'] else {}
        direct=wilson.get((r['model'],r['instance'],r['level']),{})
        for attempt in r['attempts']:
            for category,metric in attempt.get('fidelity',{}).get('categories',{}).items():
                translations.append({'instance':r['instance'],'level':r['level'],'attempt':attempt['index'],
                    'category':category,'exact':metric['exact'],'precision':metric['precision'],'recall':metric['recall'],
                    'missing_count':len(metric['missing']),'extra_count':len(metric['extra'])})
        row={k:r.get(k) for k in ('instance','size','level','mode','backend','model','effort','status','first_status','first_valid')}
        row.update(valid=valid,cost=cost,reference_cost=int(ref['best_cost']),reference_optimal=ref['proven_optimal']=='True',
                   reference_relation=('beats' if cost<int(ref['best_cost']) else 'matches' if cost==int(ref['best_cost']) else 'exceeds') if valid else '',
                   gap_pct=100*(cost/int(ref['best_cost'])-1) if valid else None,
                   repairs=max(0,len(r['attempts'])-1),translation_exact=final.get('fidelity',{}).get('exact',False),
                   pddl_characters=final.get('pddl_characters'),
                   first_translation_exact=(r['attempts'][0].get('fidelity',{}).get('exact',False) if r['attempts'] else False),
                   plan_actions=final.get('plan_actions'),search=final.get('planner',{}).get('search'),
                   optimal_for_generated_problem=final.get('planner',{}).get('optimal_for_generated_problem',False),
                   direct_valid=direct.get('valid'),direct_cost=direct.get('cost'),
                   paired_cost_difference=cost-direct['cost'] if valid and direct.get('valid') else None,
                   **r['timing'],**r['usage'])
        for category in ('rescued','deferred'):
            for band in ('injured','child','elderly','adult'):
                row[f'{category}_{band}']=r['result'].get(category,{}).get(band)
        rows.append(row)
    if not rows:return
    with (out/'results.csv').open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(dict.fromkeys(k for row in rows for k in row)));writer.writeheader();writer.writerows(rows)
    if translations:
        with (out/'translation_metrics.csv').open('w',newline='') as f:
            writer=csv.DictWriter(f,fieldnames=list(translations[0]));writer.writeheader();writer.writerows(translations)
    lines=['# PDDL experiment summary','', 'All completed cases, including failures, are in the denominator. Mock results are not experiments.', '',
           '| Size | Report | N | First valid | Final valid | Exact translation | Mean total seconds |',
           '|---|---|---:|---:|---:|---:|---:|']
    for size,level in sorted({(r['size'],r['level']) for r in rows}):
        rs=[r for r in rows if r['size']==size and r['level']==level]
        lines.append(f"| {size} | {level} | {len(rs)} | {sum(r['first_valid'] for r in rs)} | {sum(r['valid'] for r in rs)} | {sum(r['translation_exact'] for r in rs)} | {statistics.mean(r['total_seconds'] for r in rs):.2f} |")
    lines += ['', '## Reference comparisons (valid plans only)', '', '| Reference status | Eligible runs | Valid | Beats | Matches | Exceeds |', '|---|---:|---:|---:|---:|---:|']
    for optimal in (True,False):
        rs=[r for r in rows if r['reference_optimal']==optimal]
        counts=[sum(r['reference_relation']==rel for r in rs) for rel in ('beats','matches','exceeds')]
        lines.append(f"| {'Proven optimal' if optimal else 'Best known'} | {len(rs)} | {sum(r['valid'] for r in rs)} | {counts[0]} | {counts[1]} | {counts[2]} |")
    lines += ['', '## Latency by outcome', '', '| Outcome | N | Mean total seconds |', '|---|---:|---:|']
    for valid in (True,False):
        rs=[r for r in rows if r['valid']==valid]
        if rs:lines.append(f"| {'Valid' if valid else 'Failed'} | {len(rs)} | {statistics.mean(r['total_seconds'] for r in rs):.2f} |")
    lines += ['', '## Failure stages','']
    for status in sorted({r['status'] for r in rows}):
        lines.append(f"- {status}: {sum(r['status']==status for r in rows)}")
    lines += ['', '## Translation versus outcome', '', '| Exact translation | Valid final plan | Cases |', '|---|---|---:|']
    for exact in (True,False):
        for valid in (True,False):
            lines.append(f"| {exact} | {valid} | {sum(r['translation_exact']==exact and r['valid']==valid for r in rows)} |")
    (out/'summary.md').write_text('\n'.join(lines)+'\n')


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--mode',choices=['mock','baseline','live'],default='mock')
    ap.add_argument('--backend',choices=['cli','api'],default='cli')
    ap.add_argument('--budget-usd',type=float,default=5.0)
    ap.add_argument('--model',default='claude-opus-5-5')
    ap.add_argument('--effort',default='medium',choices=['low','medium','high'])
    ap.add_argument('--repairs',type=int,default=3)
    ap.add_argument('--timeout',type=int,default=60)
    ap.add_argument('--fd',default=os.environ.get('FD','fast-downward.py'))
    ap.add_argument('--tag',required=True)
    ap.add_argument('--ids',nargs='+')
    ap.add_argument('--levels',nargs='+',choices=['explicit','implicit'],default=['explicit','implicit'])
    args=ap.parse_args()
    if not re.fullmatch(r'[A-Za-z0-9_-]+',args.tag):ap.error('tag must contain only letters, digits, underscores or hyphens')
    if args.repairs<0 or args.timeout<=0 or args.budget_usd<=0:ap.error('invalid budget')
    instances=sorted((ROOT/'pddl/instances').glob('*.json'),key=lambda p: ({'small':0,'medium':1,'large':2}[p.stem.split('-')[0]],p.stem))
    if args.ids:
        known={p.stem for p in instances}
        if set(args.ids)-known:ap.error('unknown instance IDs: '+str(set(args.ids)-known))
        instances=[p for p in instances if p.stem in args.ids]
    fd=Path(shutil.which(args.fd) or args.fd).resolve()
    if args.mode!='mock' and not fd.is_file():ap.error('Fast Downward driver missing; pass --fd /absolute/path/fast-downward.py')
    load_key(ROOT)
    if args.mode=='live' and args.backend=='api' and not os.environ.get('ANTHROPIC_API_KEY'):
        ap.error('Configure ANTHROPIC_API_KEY in the environment or ignored .env file')
    if args.mode=='live' and args.backend=='cli':
        if not shutil.which('claude'):ap.error('Claude CLI missing')
        p=subprocess.run(['claude','auth','status'],capture_output=True,text=True)
        try:auth=json.loads(p.stdout)
        except ValueError:auth={}
        if not (auth.get('loggedIn') and auth.get('authMethod')=='claude.ai' and auth.get('apiProvider')=='firstParty'):
            ap.error('Claude CLI must use a claude.ai subscription login')
    cfg={**vars(args),'fd':str(fd),'schema_version':1}
    files=[ROOT/'pddl/domain.pddl',ROOT/'pddl/results/best_reference.csv',ROOT/'pipelines/pipelines.py',
           ROOT/'pipelines/checker.py',Path(__file__),Path(__file__).with_name('fidelity.py'),Path(__file__).with_name('api_backend.py')]
    for p in instances:
        files.extend([p,p.with_suffix('.pddl')])
        files.extend(ROOT/'pipelines/reports'/f'{p.stem}-{l}.txt' for l in args.levels)
        if args.mode=='mock':files.append(p.with_suffix('.best-plan'))
    cfg['file_hashes']={str(p.relative_to(ROOT)):digest(p.read_bytes()) for p in files}
    if args.mode!='mock':
        cfg['fd_driver_sha256']=digest(fd.read_bytes())
        rev=subprocess.run(['git','-C',str(fd.parent),'rev-parse','HEAD'],capture_output=True,text=True)
        cfg['fd_commit']=rev.stdout.strip() or None
        binary=fd.parent/'builds/release/bin/downward'
        cfg['fd_binary_sha256']=digest(binary.read_bytes()) if binary.is_file() else None
    if args.mode=='live' and args.backend=='api':
        import anthropic
        cfg['anthropic_sdk_version']=anthropic.__version__
    if args.mode=='live' and args.backend=='cli':
        cfg['claude_version']=subprocess.check_output(['claude','--version'],text=True).strip()
    fingerprint=digest(json.dumps(cfg,sort_keys=True).encode())
    out=ROOT/'kimaya/runs'/args.tag
    manifest=out/'manifest.json'
    if manifest.exists():
        if json.loads(manifest.read_text())['fingerprint']!=fingerprint:ap.error('configuration/input/code changed; use a new tag')
    else:
        save(manifest,{'fingerprint':fingerprint,'config':cfg,'created_utc':datetime.now(timezone.utc).isoformat(),
                       'git_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                       'python':sys.version,'platform':sys.platform})
    domain=ROOT/'pddl/domain.pddl'
    caller=APIBackend(out,args.budget_usd) if args.mode=='live' and args.backend=='api' else cli_call
    for p in instances:
        inst=json.loads(p.read_text())
        for level in args.levels:
            dest=out/'cases'/f'{p.stem}-{level}'
            record=dest/'record.json'
            if record.exists():
                old=json.loads(record.read_text())
                if old.get('complete'):continue
                if args.backend!='api':ap.error('interrupted CLI case exists; use a new tag')
            if dest.exists() and args.backend!='api' and not record.exists():ap.error('partial case exists; use a new tag')
            t=time.perf_counter()
            try:
                r=run_case(inst,(ROOT/'pipelines/reports'/f'{p.stem}-{level}.txt').read_text(),p.with_suffix('.pddl').read_text(),domain,cfg,dest,call=caller)
            except PauseBatch as exc:
                save(out/'paused.json',{'instance':p.stem,'level':level,'reason':str(exc)})
                summarise(out)
                print('PAUSED:',str(exc),flush=True)
                return
            except Exception as e:
                r={'instance':p.stem,'size':inst['size'],'model':args.model,'effort':args.effort,'mode':args.mode,
                   'attempts':[],'status':'harness_error','error':repr(e),'first_status':'harness_error','first_valid':False,
                   'result':{'valid':False,'cost':None},'complete':True,'timing':{'llm_seconds':None,'planner_seconds':None,
                   'validation_seconds':None,'fidelity_seconds':None,'total_seconds':time.perf_counter()-t},
                   'usage':{'calls':None,'input_tokens':None,'output_tokens':None,'thinking_tokens':None}}
            r['level']=level
            r['backend']=args.backend if args.mode=='live' else None
            save(record,r)
            print(p.stem,level,r['status'],flush=True)
            summarise(out)
    summarise(out)
    print(out)


if __name__=='__main__':main()
