import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import evaluate as e
from fidelity import compare

class EvaluationTests(unittest.TestCase):
    def setUp(self):
        self.problem=(e.ROOT/'pddl/instances/small-01.pddl').read_text()
        self.inst=json.loads((e.ROOT/'pddl/instances/small-01.json').read_text())
        self.domain=e.ROOT/'pddl/domain.pddl'
        self.cfg={'mode':'live','model':'fixture','effort':'medium','repairs':2,'timeout':1,'fd':'unused'}

    def test_formatting_and_fact_order(self):
        from fidelity import parse,atom
        tree=parse(self.problem)
        for s in tree:
            if isinstance(s,list) and s and s[0]==':init':s[1:]=reversed(s[1:])
        self.assertTrue(compare('; comment\n'+atom(tree),self.problem)['exact'])

    def test_missing_goal_and_wrong_penalty(self):
        from fidelity import parse,atom
        tree=parse(self.problem)
        for s in tree:
            if isinstance(s,list) and s and s[0]==':goal':s[1].pop()
        result=compare(atom(tree),self.problem)
        self.assertFalse(result['categories']['goals']['exact'])
        import re
        bad=re.sub(r'(\(= \(defer-cost injured n1\) )80',r'\g<1>1',self.problem)
        self.assertFalse(compare(bad,self.problem)['categories']['defer-cost']['exact'])

    def test_damage_and_malformed(self):
        damaged=self.problem.replace('(road ', '(damaged ',1)
        self.assertFalse(compare(damaged,self.problem)['scenario_exact'])
        self.assertFalse(compare(self.problem[:-4],self.problem)['parse_ok'])

    def test_repair_metrics_and_no_oracle_feedback(self):
        calls=[]
        replies=iter(['not pddl','```pddl\n'+self.problem+'```'])
        def call(system,messages,*args):
            calls.append(json.loads(json.dumps(messages)))
            return {'ok':True,'text':next(replies),'seconds':2,'input_tokens':10,'output_tokens':20,'thinking_tokens':None}
        def planner(*args):
            return {'plan':(e.ROOT/'pddl/instances/small-01.best-plan').read_text().splitlines(),
                    'seconds':3,'status':'plan_found','searches':[]}
        with tempfile.TemporaryDirectory() as d:
            r=e.run_case(self.inst,'report',self.problem,self.domain,self.cfg,Path(d),call,planner)
        self.assertFalse(r['first_valid']);self.assertTrue(r['result']['valid'])
        self.assertEqual(r['usage']['calls'],2);self.assertEqual(r['usage']['output_tokens'],40)
        self.assertEqual(r['timing']['llm_seconds'],4);self.assertEqual(r['timing']['planner_seconds'],3)
        self.assertIn('no PDDL code block',calls[1][-1]['content'])
        self.assertNotIn('missing_waiting',calls[1][-1]['content'])

    def test_timeout_does_not_trigger_translation_repair(self):
        def call(*args):return {'ok':True,'text':'```pddl\n'+self.problem+'```','seconds':1}
        def planner(*args):return {'plan':None,'seconds':3,'status':'timeout','error':'timeout','searches':[]}
        with tempfile.TemporaryDirectory() as d:
            r=e.run_case(self.inst,'report',self.problem,self.domain,self.cfg,Path(d),call,planner)
        self.assertEqual(r['status'],'timeout');self.assertEqual(len(r['attempts']),1)

    def test_failed_call_persisted(self):
        def call(*args):return {'ok':False,'text':'','seconds':1,'error':'quota'}
        with tempfile.TemporaryDirectory() as d:
            r=e.run_case(self.inst,'report',self.problem,self.domain,self.cfg,Path(d),call)
            saved=json.loads((Path(d)/'record.json').read_text())
        self.assertTrue(saved['complete']);self.assertEqual(r['status'],'llm_error')

    def test_all_search_times_and_logs(self):
        class R:
            returncode=23;stdout='timeout';stderr=''
        def fake(cmd,**kwargs):
            if 'seq-sat-lama-2011' in cmd:
                (Path(kwargs['cwd'])/'sas_plan.1').write_text('(drive c a b)\n')
            return R()
        with tempfile.TemporaryDirectory() as d,patch.object(e.subprocess,'run',side_effect=fake):
            r=e.planner(self.problem,self.domain,Path('/fake/fd.py'),1,Path(d))
            self.assertTrue((Path(d)/'optimal-lmcut/stdout.txt').exists())
        self.assertEqual(len(r['searches']),3)
        self.assertEqual(r['seconds'],sum(s['seconds'] for s in r['searches']))
        self.assertFalse(r['optimal_for_generated_problem'])

if __name__=='__main__':unittest.main()
