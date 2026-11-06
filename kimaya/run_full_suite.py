#!/usr/bin/env python3
"""Run the approved subscription suite sequentially; stop model calls on interruption.

Resume by rerunning this command. Successful responses and completed cases are cached.
The baseline runs even if subscription generation pauses, without competing planners.
"""
import fcntl
import json
from pathlib import Path
import subprocess
import sys
from datetime import datetime, timezone

ROOT=Path(__file__).resolve().parents[1]
PREFIX='full-cli-v1'


def main():
    logs=ROOT/'kimaya/runs'/PREFIX
    logs.mkdir(parents=True,exist_ok=True)
    lock=(logs/'suite.lock').open('w')
    try:
        fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    except BlockingIOError:
        sys.exit('Another full-suite process is already running')
    common=[sys.executable,'-u',str(ROOT/'kimaya/evaluate.py'),'--fd',
            str(ROOT/'.tools/downward/fast-downward.py'),'--repairs','0','--timeout','60']
    status={'started_utc':datetime.now(timezone.utc).isoformat(),'runs':[]}
    def run(name,args):
        print('START',name,flush=True)
        with (logs/f'{name}.log').open('a') as log:
            code=subprocess.call(common+args,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
        status['runs'].append({'name':name,'exit_code':code})
        (logs/'status.json').write_text(json.dumps(status,indent=2)+'\n')
        print('END',name,'exit',code,flush=True)
        return code
    paused=False
    for model in ('opus','sonnet','haiku'):
        name=f'{PREFIX}-{model}'
        code=run(name,['--mode','live','--backend','cli','--model',f'claude-{model}-5-5',
                       '--effort','medium','--tag',name])
        if code:
            paused=True
            break
    baseline=f'{PREFIX}-baseline'
    baseline_code=run(baseline,['--mode','baseline','--tag',baseline,'--levels','explicit'])
    status['finished_utc']=datetime.now(timezone.utc).isoformat()
    status['state']='paused' if paused or baseline_code else 'complete'
    (logs/'status.json').write_text(json.dumps(status,indent=2)+'\n')
    return 75 if status['state']=='paused' else 0


if __name__=='__main__':sys.exit(main())
