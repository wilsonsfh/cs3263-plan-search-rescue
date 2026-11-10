"""Verify saved full-run records and reproduce comparisons without model/planner calls."""
import csv
import hashlib
import json
from pathlib import Path
import statistics
import sys
from collections import Counter

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'pipelines'))
from checker import check
from fidelity import compare


def read(path):return json.loads(path.read_text())


def write_csv(path,rows):
    with path.open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)


def main():
    out=ROOT/'kimaya/runs/full-cli-v1'
    refs={r['id']:r for r in csv.DictReader((ROOT/'pddl/results/best_reference.csv').open())}
    instances={p.stem:read(p) for p in (ROOT/'pddl/instances').glob('*.json')}
    for iid,ref in refs.items():
        for suffix in ('best-plan','exact-plan'):
            r=check(instances[iid],(ROOT/f'pddl/instances/{iid}.{suffix}').read_text().splitlines())
            assert r['valid'] and r['cost']==int(ref['best_cost']),iid
    runs={};verified_hashes=0
    for model in ('baseline','opus','sonnet','haiku'):
        d=ROOT/f'kimaya/runs/full-cli-v1-{model}'
        manifest=read(d/'manifest.json')
        for filename,expected in manifest['config']['file_hashes'].items():
            assert hashlib.sha256((ROOT/filename).read_bytes()).hexdigest()==expected,filename
            verified_hashes+=1
        runs[model]=[read(p) for p in sorted((d/'cases').glob('*/record.json'))]
        assert len(runs[model])==(45 if model=='baseline' else 90)
        assert len({(r['instance'],r['level']) for r in runs[model]})==len(runs[model])
        for r in runs[model]:
            assert r['complete'] and len(r['attempts'])==1
            a=r['attempts'][0]
            generated=(d/'cases'/f"{r['instance']}-{r['level']}"/'attempt-0/generated.pddl').read_text()
            assert compare(generated,(ROOT/f"pddl/instances/{r['instance']}.pddl").read_text())==a['fidelity']
            assert check(instances[r['instance']],a['planner']['plan'])==r['result'],(model,r['instance'],r['level'])
            assert [s['search'] for s in a['planner']['searches']] in (['optimal-lmcut'],['optimal-lmcut','lama-anytime'])
            if model!='baseline':
                assert r['model']==f'claude-{model}-5-5' and r['effort']=='medium'
                assert r['usage']['calls']==1 and set(a['llm']['model_usage'])=={r['model']}
    baseline={r['instance']:r for r in runs['baseline']}
    rows=[];direct_rows=[];differences=[]
    for model,tag in (('opus','main'),('sonnet','main-sonnet'),('haiku','main-haiku')):
        for r in runs[model]:
            iid,level=r['instance'],r['level'];a=r['attempts'][0];result=r['result'];valid=result['valid']
            dr=read(ROOT/f'pipelines/runs/{tag}/direct/{iid}-{level}.json')
            # The original result is independently replayed, not merely trusted.
            dp=dr['attempts'][-1]['plan']
            assert check(instances[iid],dp)==dr['result'],('direct',model,iid,level)
            direct=dr['result'];ref=int(refs[iid]['best_cost']);cost=result['cost']
            assert not valid or cost>=ref,('reference anomaly',model,iid,level)
            assert not direct['valid'] or direct['cost']>=ref,('direct reference anomaly',model,iid,level)
            diff={k:v for k,v in a['fidelity']['categories'].items() if not v['exact']}
            req_only=(set(diff)=={'other'} and not diff['other']['missing'] and
                      all(s.startswith('(:requirements ') for s in diff['other']['extra']))
            if diff:differences.append({'model':model,'instance':iid,'level':level,'requirements_only':req_only,'differences':diff})
            row={'model':model,'instance':iid,'size':r['size'],'level':level,'valid':valid,'cost':cost,
                 'reference_cost':ref,'optimal':valid and cost==ref,'gap_pct':100*(cost/ref-1) if valid and ref else None,
                 'direct_valid':direct['valid'],'direct_cost':direct['cost'],
                 'paired_difference':cost-direct['cost'] if valid and direct['valid'] else None,
                 'baseline_cost':baseline[iid]['result']['cost'],
                 'strict_exact':a['fidelity']['exact'],'requirements_only_difference':req_only,
                 'exact_except_requirements':a['fidelity']['exact'] or req_only,
                 'failure':result.get('error'),**r['timing'],
                 'input_tokens':r['usage']['input_tokens'],'output_tokens':r['usage']['output_tokens'],
                 'thinking_tokens_provider':a['llm']['model_usage'][r['model']].get('thinkingTokens'),
                 'search':a['planner']['search'],'rescued':result['people_rescued'] if valid else None,
                 'deferred':sum(result['deferred'].values()) if valid else None}
            rows.append(row)
            direct_rows.append({'model':model,'instance':iid,'size':r['size'],'level':level,
                                'valid':direct['valid'],'cost':direct['cost'],'reference_cost':ref,
                                'optimal':direct['valid'] and direct['cost']==ref})
    write_csv(out/'comparison.csv',rows);write_csv(out/'direct_rescored.csv',direct_rows)
    (out/'translation_differences.json').write_text(json.dumps(differences,indent=2)+'\n')
    aggregates=[]
    for model in ('opus','sonnet','haiku'):
        for size in ('all','small','medium','large'):
            for level in ('all','explicit','implicit'):
                rs=[r for r in rows if r['model']==model and (size=='all' or r['size']==size) and (level=='all' or r['level']==level)]
                ds=[r for r in direct_rows if r['model']==model and (size=='all' or r['size']==size) and (level=='all' or r['level']==level)]
                pairs=[r['paired_difference'] for r in rs if r['paired_difference'] is not None]
                aggregates.append({'model':model,'size':size,'level':level,'n':len(rs),
                    'valid':sum(r['valid'] for r in rs),'optimal':sum(r['optimal'] for r in rs),
                    'strict_exact':sum(r['strict_exact'] for r in rs),
                    'exact_except_requirements':sum(r['exact_except_requirements'] for r in rs),
                    'direct_valid':sum(r['valid'] for r in ds),'direct_optimal':sum(r['optimal'] for r in ds),
                    'paired_n':len(pairs),'cheaper':sum(d<0 for d in pairs),'equal':sum(d==0 for d in pairs),'higher':sum(d>0 for d in pairs),
                    'mean_valid_gap_pct':statistics.mean(r['gap_pct'] for r in rs if r['valid']),
                    'mean_llm_seconds':statistics.mean(r['llm_seconds'] for r in rs),
                    'mean_planner_seconds':statistics.mean(r['planner_seconds'] for r in rs),
                    'mean_total_seconds':statistics.mean(r['total_seconds'] for r in rs),
                    'median_total_seconds':statistics.median(r['total_seconds'] for r in rs),
                    'input_tokens':sum(r['input_tokens'] for r in rs),'output_tokens':sum(r['output_tokens'] for r in rs)})
    write_csv(out/'aggregate.csv',aggregates)
    top=[a for a in aggregates if a['size']==a['level']=='all']
    lines=['# Full LLM → PDDL subscription results','',
           'Completed 7 November 2026: 270 model cases and 45 correct-PDDL baselines. One initial response per case, zero repairs. '
           'This report supersedes pilot conclusions for the full-run configuration; historical pilot artifacts remain unchanged.','',
           '## Design','',
           '45 scenarios (15 per size) × two report styles × three Claude 5.5 models, medium effort. '
           'CLI subscription transport and request flags match Wilson; exact model IDs, inputs, objective and checker are unchanged. '
           'Claude Code was updated to 2.1.319 after a zero-token version rejection. Same CLI flags do not establish identical hidden context across CLI versions. '
           'The new planner sequence is A* LM-cut for 60 CPU seconds, then LAMA for 60 CPU seconds on timeout. '
           'The pilot additionally used merge-and-shrink; do not pool its outcomes with these runs. '
           'All planner jobs were sequential. See [protocol](full_run_protocol.md).','',
           '## Headline results','',
           'Optimal means valid and equal in cost to the updated exact reference. Denominators include all attempted cases.','',
           '| Model | Valid / 90 | Optimal / 90 | Strict canonical exact / 90 | Exact except added requirements / 90 | Direct valid / 90 | Direct optimal / 90 |',
           '|---|---:|---:|---:|---:|---:|---:|']
    for a in top:lines.append(f"| {a['model']} | {a['valid']} | {a['optimal']} | {a['strict_exact']} | {a['exact_except_requirements']} | {a['direct_valid']} | {a['direct_optimal']} |")
    lines+=['','| Model | Mutually valid pairs | PDDL cheaper | Equal | PDDL more expensive | Mean valid cost gap (%) |','|---|---:|---:|---:|---:|---:|']
    for a in top:lines.append(f"| {a['model']} | {a['paired_n']} | {a['cheaper']} | {a['equal']} | {a['higher']} | {a['mean_valid_gap_pct']:.2f} |")
    lines+=['','## Size and report breakdown','', '| Model | Size | Report | Valid | Optimal | N |','|---|---|---|---:|---:|---:|']
    for a in aggregates:
        if a['size']!='all' and a['level']!='all':lines.append(f"| {a['model']} | {a['size']} | {a['level']} | {a['valid']} | {a['optimal']} | {a['n']} |")
    lines+=['','## Time and tokens','', '| Model | Mean LLM seconds | Mean planner seconds | Mean total seconds | Input tokens | Output tokens |','|---|---:|---:|---:|---:|---:|']
    for a in top:lines.append(f"| {a['model']} | {a['mean_llm_seconds']:.2f} | {a['mean_planner_seconds']:.2f} | {a['mean_total_seconds']:.2f} | {a['input_tokens']:,} | {a['output_tokens']:,} |")
    lines+=['', 'Tokens include provider-reported cache input usage. Thinking counts exposed under CLI `modelUsage.thinkingTokens` '
            'are extracted separately in comparison.csv; do not add them to output tokens without a provider accounting definition. '
            'The original top-level thinking field can be null because the CLI exposed this information elsewhere. '
            'CLI list-price dollar estimates are not actual subscription charges. No API credit spending is inferred.','',
            '## Translation findings','',
            'Opus and Sonnet each match all 90 benchmark encodings. Haiku matches 36 strictly. '
            f"Another {sum(d['requirements_only'] for d in differences)} Haiku cases differ only by added `:requirements` declarations; "
            'the separately labelled comparison excludes only those declarations, not arbitrary extra content. '
            'Three Haiku cases have substantive fact differences:', '',
            '- `medium-03 implicit`: elderly n1 becomes injured n1 at kakani-temple in the initial state and goal. '
            'The returned plan fails ground-truth replay at step 2, when it tries to defer an injured person who is not there.',
            '- `large-05 implicit`: omits both directions of a damaged-road fact between thakre-shelter and trishuli-care-home.',
            '- `large-06 implicit`: omits both directions of a damaged-road fact between kakani-temple and dhunche-temple.',
            '', 'Both damaged-road cases still return valid plans. Validity of one returned plan therefore does not prove translation fidelity. '
            'Canonical agreement, even with requirements ignored, is an encoding comparison rather than a general semantic-equivalence proof.','',
            '## Correct-PDDL baseline and interpretation','']
    bs=runs['baseline'];opt=sum(r['result']['cost']==int(refs[r['instance']]['best_cost']) for r in bs)
    lines += [f"The baseline returns **45/45 valid plans**, of which **{opt}/45 match the optimal reference**. "
              f"It uses LM-cut for {sum(r['attempts'][0]['planner']['search']=='optimal-lmcut' for r in bs)} final plans and LAMA for the remainder. "
              'The baseline consumes no LLM calls; the explicit label is only the harness slot name.', '',
              'The PDDL pipeline improves validity relative to the saved direct runs, but fewer plans match the optimum for every model. '
              'All 30 small presentations per model are optimal. On large presentations, Opus/Sonnet match the optimum in 4/30 cases and Haiku in 3/30. '
              'Thus better validity and translation fidelity do not imply better cost optimization under this budget.', '',
              'Exact translation does not guarantee an optimal resulting plan under finite search time. '
              'Compare each generated problem with the correct-PDDL control in comparison.csv. '
              'Canonical-equivalent fact/object order can change search tie-breaking; cost differences are not automatically translation failures. '
              'These results concern this domain, configuration and budget, not all classical planners.', '',
              '## Verification and reproducibility','',
              f'Independently replayed all 315 saved full-run/baseline plans and all 270 saved direct plans; results match their records. '
              f'Checked {verified_hashes} manifested file-hash entries and all 45 exact/best reference pairs. '
              'All live cases used the requested model and medium effort with one attempt. No valid plan beats the claimed optimum. '
              'No new inference or planning is needed for this analysis:', '',
              '```sh','.venv/bin/python kimaya/analyse_full.py','```','',
              'Detailed outputs are in `runs/full-cli-v1/{comparison,direct_rescored,aggregate}.csv` and `translation_differences.json`. '
              'Original per-case records, CLI responses, prompts, generated PDDL, planner logs/plans and manifests remain in the four run directories.', '',
              '## Limitations','',
              '- One model sample per scenario/report. Explicit and implicit presentations share a scenario, so 90 cases are not 90 independent scenarios.',
              '- The six pilot scenarios overlap the full set. This is not a completely untouched held-out benchmark.',
              '- The exact-reference solver inherits its reduction assumptions; replay checks establish validity/cost, not an independent proof of optimality.',
              '- Cross-machine or cross-version latency comparisons with Wilson are descriptive. CLI context and service-side behaviour may vary over time.',
              '- Ground-truth Python replay is the primary validity check; VAL was not rerun for these experiments.',
              '- Penalties are modelling choices, and the simplified rescue objective is not validated for real disaster decisions.',
              '- Implementation and analysis were assisted by Codex; the team should review and own the conclusions.']
    (ROOT/'kimaya/full_results.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(top,indent=2))


if __name__=='__main__':main()
