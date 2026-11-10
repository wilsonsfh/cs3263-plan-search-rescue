import json
from pathlib import Path
import sys
import tempfile
import unittest
from types import SimpleNamespace
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from api_backend import APIBackend, PauseBatch

class APITests(unittest.TestCase):
    def backend(self, out, budget):
        b=object.__new__(APIBackend);b.out=out;b.budget=budget
        b.client=SimpleNamespace(messages=SimpleNamespace(count_tokens=lambda **kw:SimpleNamespace(input_tokens=100)))
        return b

    def test_budget_blocks_generation(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d);b=self.backend(p,.1)
            with self.assertRaises(PauseBatch):b('s',[{'role':'user','content':'x'}],'claude-opus-5-5','medium',p)
            self.assertEqual(json.loads((p/'api_interruption.json').read_text())['kind'],'budget_guard')

    def test_cached_response_does_not_call_provider(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d);b=self.backend(p,0)
            payload={'model':'claude-opus-5-5','system':'s','messages':[{'role':'user','content':'x'}],
                     'max_tokens':32000,'output_config':{'effort':'medium'}}
            (p/'request.json').write_text(json.dumps(payload))
            (p/'api_response.json').write_text(json.dumps({'ok':True,'text':'cached'}))
            self.assertEqual(b('s',payload['messages'],payload['model'],'medium',p)['text'],'cached')
            with self.assertRaises(ValueError):b('different',payload['messages'],payload['model'],'medium',p)

    def test_api_error_pauses_without_credential_echo(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d);b=self.backend(p,5)
            def fail(**kw):raise RuntimeError('secret must not be logged')
            b.client.messages.stream=fail
            with self.assertRaises(PauseBatch):b('s',[{'role':'user','content':'x'}],'claude-opus-5-5','medium',p)
            text=(p/'api_interruption.json').read_text()
            self.assertNotIn('secret',text);self.assertIn('possible_charge',text)
