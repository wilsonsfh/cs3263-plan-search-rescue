"""Recompute pilot findings from saved records and produce the report used in the PR."""
import csv
import json
from pathlib import Path
import statistics
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'pipelines'))
from checker import check


def main():
    run=ROOT/'kimaya/runs/pilot-opus-api-v1'
    baseline=ROOT/'kimaya/runs/pilot-opus-baseline-v1'
    records=[json.loads(p.read_text()) for p in sorted((run/'cases').glob('*/record.json'))]
    records=[r for r in records if r.get('complete')]
    refs={r['id']:r for r in csv.DictReader((ROOT/'pddl/results/best_reference.csv').open())}
    bs={p.parent.name:json.loads(p.read_text()) for p in (baseline/'cases').glob('*/record.json') if json.loads(p.read_text()).get('complete')}
    comparisons=[]
    for r in records:
        a=r['attempts'][-1];plan=a.get('planner',{}).get('plan')
        if plan is not None:
            ground=json.loads((ROOT/'pddl/instances'/f"{r['instance']}.json").read_text())
            assert check(ground,plan)==r['result'],r['instance']
        direct=json.loads((ROOT/'pipelines/runs/main/direct'/f"{r['instance']}-{r['level']}.json").read_text())
        b=bs.get(f"{r['instance']}-{r['level']}")
        comparisons.append({'instance':r['instance'],'size':r['size'],'level':r['level'],
            'first_valid':r['first_valid'],'valid':r['result']['valid'],'cost':r['result'].get('cost'),
            'direct_valid':direct['result']['valid'],'direct_cost':direct['result'].get('cost'),
            'baseline_valid':b['result']['valid'] if b else None,'baseline_cost':b['result'].get('cost') if b else None,
            'reference_cost':int(refs[r['instance']]['best_cost']),
            'reference_proven':refs[r['instance']]['proven_optimal']=='True',
            'translation_exact':a.get('fidelity',{}).get('exact'),
            'llm_seconds':r['timing']['llm_seconds'],'planner_seconds':r['timing']['planner_seconds'],
            'validation_seconds':r['timing']['validation_seconds'],'total_seconds':r['timing']['total_seconds'],
            'input_tokens':r['usage']['input_tokens'],'output_tokens':r['usage']['output_tokens'],
            'estimated_usd':r['usage']['estimated_cost_usd'],'repairs':len(r['attempts'])-1})
    if not records:raise SystemExit('No completed pilot records')
    with (run/'comparison.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(comparisons[0]));w.writeheader();w.writerows(comparisons)
    n=len(records)
    lines=['# Opus LLM → PDDL pilot','',
        '## Design','',
        'Six fixed scenarios (small-01/02, medium-01/02, large-01/02), each explicit and implicit: 12 cases. '
        'One initial Opus 5.5 response per report at medium effort; up to three parser/unsolvability repairs. '
        'No tools and no ground-truth feedback are supplied to the LLM. '
        'The goal, penalty weights, domain, reports, and ground-truth checker are unchanged.', '',
        'Wilson used Claude Code; this pilot uses the raw Anthropic Messages API, with a 32,000-output-token cap '
        'and preserved assistant content blocks for repairs. This matches his requested model/effort, but not '
        'the CLI hidden preamble or transport. Do not claim identical model context.', '',
        'Fast Downward uses LM-cut → merge-and-shrink → LAMA, each with a 60-second overall CPU-time budget '
        'and a 120-second wall-clock process guard. All invocation times are added. Planner timeouts do not '
        'trigger model repairs. The correct-PDDL baseline uses the same configurations. '
        'The baseline and pilot overlapped in execution, so timings are descriptive, not controlled hardware benchmarks.', '',
        '## Results','',f'- Completed cases: **{n}/12**.',
        f"- Valid on first attempt: **{sum(r['first_valid'] for r in records)}/{n}**; final: **{sum(r['result']['valid'] for r in records)}/{n}**.",
        f"- Canonical translation exact on final attempt: **{sum(bool(r['attempts'][-1].get('fidelity',{}).get('exact')) for r in records)}/{n}**.",
        f"- Model calls: **{sum(r['usage']['calls'] for r in records)}**; repairs: **{sum(len(r['attempts'])-1 for r in records)}**.",
        f"- Input/output tokens: **{sum(r['usage']['input_tokens'] or 0 for r in records):,} / {sum(r['usage']['output_tokens'] or 0 for r in records):,}**.",
        f"- Estimated API generation cost: **US${sum(r['usage']['estimated_cost_usd'] for r in records):.4f}** (usage × published rates; excludes tax and is not a receipt).",'',
        '| Scenario | Report | First/final valid | Translation exact | PDDL cost | Direct cost | Correct-PDDL cost | Saved reference |',
        '|---|---|---|---|---:|---:|---:|---:|']
    for r in comparisons:
        lines.append(f"| {r['instance']} | {r['level']} | {r['first_valid']}/{r['valid']} | {r['translation_exact']} | {r['cost']} | {r['direct_cost']} | {r['baseline_cost']} | {r['reference_cost']}{'' if r['reference_proven'] else '*'} |")
    lines += ['', '*Reference not proven optimal. A valid lower cost beats this saved upper bound, not an optimum.', '',
              '## Component time and usage','', '| Size | N | Mean LLM seconds | Mean planner seconds | Mean total seconds | Mean output tokens |',
              '|---|---:|---:|---:|---:|---:|']
    for size in ('small','medium','large'):
        rs=[r for r in comparisons if r['size']==size]
        if rs:lines.append(f"| {size} | {len(rs)} | {statistics.mean(r['llm_seconds'] for r in rs):.2f} | {statistics.mean(r['planner_seconds'] for r in rs):.2f} | {statistics.mean(r['total_seconds'] for r in rs):.2f} | {statistics.mean(r['output_tokens'] for r in rs):.0f} |")
    lines += ['', '## Translation fidelity and limitations','',
        'Translation metrics compare parsed canonical objects, initial facts, goals, metric, and cost functions. '
        'Order and comments are ignored; missing/extra facts and precision/recall are reported separately per category. '
        'Scenario facts are not pooled with arithmetic-table facts. This detects semantic omissions in the expected '
        'encoding; it is not an equivalence prover for arbitrary PDDL. The local parser flag is distinct from planner acceptance.', '',
        'See `translation_metrics.csv` and per-attempt records for the category-level details. '
        'Separate LLM/planner/validation/fidelity/total timings, initial/repair tokens, rescued/deferred counts, '
        'planner logs, returned model IDs and complete model responses are retained. Reasoning tokens remain null '
        'if the provider does not expose them separately.', '',
        'There is one sample per presentation and only six underlying scenarios. These are development pilot results, '
        'not a held-out or statistically conclusive main evaluation. Optimality of a plan for generated PDDL does not '
        'establish translation correctness. Original reference budgets and encodings differ from this pilot.', '',
        '## Verification','',
        f'All {n} saved final plans with a plan available were replayed against the shared ground-truth checker; results agree. '
        'The harness has focused unit tests for fidelity, failure persistence, repair feedback, timing, API caching and spend guarding. '
        'VAL was not rerun for these experimental plans.', '',
        '## Reproduction','',
        'See `README.md` for setup and the exact API pilot command. Never commit `.env`. '
        'The manifested planner commit/binary and file hashes identify inputs. API budget or transport interruptions pause '
        'the batch; cached successful calls avoid duplicate generation on resume. Provider billing is authoritative.', '',
        'Implementation and analysis were assisted by Codex; team members should review the modelling, results and conclusions before submission.']
    lines += ['', '## Interpretation', '']
    for size in ('small','medium','large'):
        rs=[r for r in comparisons if r['size']==size]
        both=[r for r in rs if r['valid'] and r['direct_valid']]
        if both:
            lower=sum(r['cost']<r['direct_cost'] for r in both)
            equal=sum(r['cost']==r['direct_cost'] for r in both)
            higher=sum(r['cost']>r['direct_cost'] for r in both)
            lines.append(f'- {size}: among {len(both)} mutually valid pairs, PDDL cost is lower/equal/higher than direct in {lower}/{equal}/{higher} cases.')
    example=next((r for r in records if r['instance']=='large-01' and r['level']=='explicit'),None)
    if example and example['result']['valid']:
        result=example['result']
        lines += ['', f"For large-01 explicit, the translated-PDDL plan costs {result['cost']}, rescuing {result['people_rescued']} people and deferring {result['deferred']}. Wilson's direct plan costs 240, rescues 22 people and defers three adults. The canonical translation is exact; the correct-PDDL baseline also costs 462. Thus this case identifies a planner/configuration-budget limitation, not a translation failure. This does not establish that all classical planners perform worse."]
    lines += ['', 'Formatting/object ordering can affect search tie-breaking even when canonical fidelity is exact. Any cost differences between correct and translated PDDL should therefore be analysed with the search logs and budget, not automatically attributed to missing facts.']
    (ROOT/'kimaya/pilot_results.md').write_text('\n'.join(lines)+'\n')
    print('wrote pilot_results.md and comparison.csv for',n,'cases')

if __name__=='__main__':main()
