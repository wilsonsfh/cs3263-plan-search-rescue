"""Canonical PDDL fidelity, not a proof of arbitrary semantic equivalence."""
import re
from collections import Counter


def parse(text):
    tokens = re.findall(r'\(|\)|[^\s()]+', re.sub(r';[^\n]*', '', text).lower())
    stack, root = [], []
    for token in tokens:
        if token == '(':
            child = []
            (stack[-1] if stack else root).append(child)
            stack.append(child)
        elif token == ')':
            if not stack:
                raise ValueError('unmatched closing parenthesis')
            stack.pop()
        elif stack:
            stack[-1].append(token)
        else:
            raise ValueError('token outside expression')
    if stack or len(root) != 1 or not root[0] or root[0][0] != 'define':
        raise ValueError('expected one complete (define ...) expression')
    return root[0]


def atom(x):
    return '(' + ' '.join(atom(y) if isinstance(y, list) else y for y in x) + ')'


def groups(text):
    tree = parse(text)
    sections = {}
    for s in tree[1:]:
        if not isinstance(s, list) or not s:
            raise ValueError('invalid problem section')
        if s[0] in sections:
            raise ValueError('duplicate section ' + s[0])
        sections[s[0]] = s[1:]
    if not all(k in sections for k in ('problem', ':domain', ':objects', ':init', ':goal', ':metric')):
        raise ValueError('missing required problem section')
    out = {'domain': [atom(sections[':domain'])], 'objects': [], 'goals': [],
           'metric': [atom(sections[':metric'])], 'encoding': [], 'initial_cost': [], 'other': []}
    pending = []
    it = iter(sections[':objects'])
    for x in it:
        if x == '-':
            typ = next(it, None)
            if not pending or typ is None:
                raise ValueError('invalid typed objects')
            out['objects'].extend(n + ':' + typ for n in pending)
            pending = []
        else:
            pending.append(x)
    out['objects'].extend(n + ':object' for n in pending)
    for f in sections[':init']:
        if not isinstance(f, list) or not f:
            raise ValueError('invalid init expression')
        kind = f[0]
        if kind == '=' and len(f) == 3 and isinstance(f[1], list) and f[1]:
            kind = f[1][0]
        key = ('encoding' if kind in ('sum', 'positive') else
               'initial_cost' if kind == 'total-cost' else kind)
        out.setdefault(key, []).append(atom(f))
    if len(sections[':goal']) != 1:
        raise ValueError('expected one goal')
    goal = sections[':goal'][0]
    out['goals'] = [atom(x) for x in goal[1:]] if goal and goal[0] == 'and' else [atom(goal)]
    for k, v in sections.items():
        if k not in ('problem', ':domain', ':objects', ':init', ':goal', ':metric'):
            out['other'].append(atom([k] + v))
    return out


def compare(generated, reference):
    expected = groups(reference)
    try:
        actual = groups(generated)
    except (ValueError, TypeError, IndexError) as e:
        return {'parse_ok': False, 'exact': False, 'error': str(e), 'categories': {}}
    categories = {}
    for k in sorted(expected.keys() | actual.keys()):
        g, a = Counter(expected.get(k, [])), Counter(actual.get(k, []))
        common = sum((g & a).values())
        categories[k] = {'exact': g == a, 'precision': common / sum(a.values()) if a else None,
                         'recall': common / sum(g.values()) if g else None,
                         'missing': list((g-a).elements()), 'extra': list((a-g).elements())}
    scenario = ('road', 'damaged', 'travel-time', 'evac-point', 'waiting', 'car-at', 'free-seats', 'carrying')
    return {'parse_ok': True, 'exact': all(v['exact'] for v in categories.values()),
            'scenario_exact': all(categories.get(k, {'exact': True})['exact'] for k in scenario),
            'categories': categories}
