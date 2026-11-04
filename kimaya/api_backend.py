"""Anthropic API backend with successful-response caching and a conservative spend guard."""
import json
import os
from pathlib import Path
import time

class PauseBatch(Exception):
    """Infrastructure or budget interruption: preserve work, do not score as model failure."""


def load_key(root):
    if os.environ.get('ANTHROPIC_API_KEY'):
        return
    path = Path(root)/'.env'
    if path.exists():
        for line in path.read_text().splitlines():
            key, sep, value = line.partition('=')
            if sep and key.strip() == 'ANTHROPIC_API_KEY':
                os.environ['ANTHROPIC_API_KEY'] = value.strip().strip('\"\'')
                return


class APIBackend:
    def __init__(self, out, budget=5.0):
        import anthropic
        self.client = anthropic.Anthropic(api_key=os.environ['ANTHROPIC_API_KEY'],
            base_url='https://api.anthropic.com', max_retries=0, timeout=1800)
        self.out, self.budget = Path(out), budget

    def __call__(self, system, messages, model, effort, dest):
        from evaluate import save
        if model != 'claude-opus-5-5':
            raise ValueError('Spend guard rates currently verified only for claude-opus-5-5')
        payload={'model':model,'system':system,'messages':messages,
                 'max_tokens':32000,'output_config':{'effort':effort}}
        cached=dest/'api_response.json'
        request=dest/'request.json'
        if cached.exists():
            if json.loads(request.read_text()) != payload:
                raise ValueError('Cached request differs from current request')
            return json.loads(cached.read_text())
        save(request,payload)
        spent=sum(json.loads(p.read_text()).get('estimated_cost_usd',0) for p in self.out.glob('cases/*/attempt-*/api_response.json'))
        # Count tokens without generating; reserve the maximum output cost before every paid request.
        try:
            count=self.client.messages.count_tokens(model=model,system=system,messages=messages).input_tokens
        except Exception as exc:
            save(dest/'api_interruption.json',{'kind':type(exc).__name__,'stage':'count_tokens'})
            raise PauseBatch('API preflight failed; see api_interruption.json. No model request issued.') from exc
        reserve=(count*4+32000*20)/1_000_000
        if spent+reserve > self.budget:
            save(dest/'api_interruption.json',{'kind':'budget_guard','spent_usd':spent,'reserved_usd':reserve,'budget_usd':self.budget})
            raise PauseBatch('Budget guard paused before next paid request')
        start=time.perf_counter()
        try:
            with self.client.messages.stream(**payload) as stream:
                msg=stream.get_final_message()
        except Exception as exc:
            # Do not store exception strings that might echo credentials. Unknown-charge calls need review.
            save(dest/'api_interruption.json',{'kind':type(exc).__name__,'stage':'generation',
                'http_status':getattr(exc,'status_code',None),'seconds':time.perf_counter()-start,
                'possible_charge':True})
            raise PauseBatch('API call interrupted; review billing/error before resuming') from exc
        raw=msg.model_dump(mode='json')
        usage=raw['usage']
        result={'ok':True,'text':''.join(b.get('text','') for b in raw['content'] if b['type']=='text'),
                'content':raw['content'],'seconds':time.perf_counter()-start,'stop_reason':raw['stop_reason'],
                'model_returned':raw['model'],'message_id':raw['id'], 'provider_usage':usage,
                'input_tokens':sum(usage.get(k,0) or 0 for k in ('input_tokens','cache_creation_input_tokens','cache_read_input_tokens')),
                'output_tokens':usage['output_tokens'],
                'thinking_tokens':(usage.get('output_tokens_details') or {}).get('thinking_tokens')}
        result['estimated_cost_usd']=(usage['input_tokens']*4+usage['output_tokens']*20+
            (usage.get('cache_creation_input_tokens') or 0)*5+(usage.get('cache_read_input_tokens') or 0)*.2)/1_000_000
        save(cached,result)
        save(dest/'provider_message.json',raw)
        return result
