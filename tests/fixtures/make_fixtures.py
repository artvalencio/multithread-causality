"""Reference values for test_fixtures.m, computed with cami-python >= 1.5.0.

    python make_fixtures.py [path/to/cami-python]

The CASES below must match tests/fixture_cases.m (same order).
"""
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import cami  # noqa: E402

# L_past, L_fut, cause_part, effect_part, tau, delay
CASES = [
    (1, 1, [0.5], [0.5], 1, 0),
    (2, 1, [0.3, 0.6], [0.3, 0.6], 1, 0),
    (1, 2, [0.5], [0.4], 1, 0),
    (2, 2, [0.5], [0.5], 2, 0),
    (1, 1, [0.3, 0.6], [0.35, 0.65], 3, 0),
    (2, 1, [0.5], [0.5], 1, 1),
    (3, 3, [0.1 * k for k in range(1, 10)], [0.1 * k for k in range(1, 10)], 1, 0),
]

rng = np.random.default_rng(2018)
x = rng.random((120, 12))
y = np.vstack([rng.random((1, 12)), 0.6 * x[:-1] + 0.4 * rng.random((119, 12))])
np.savetxt(os.path.join(HERE, 'x.csv'), x, delimiter=',', fmt='%.17g')
np.savetxt(os.path.join(HERE, 'y.csv'), y, delimiter=',', fmt='%.17g')

rows = []
for l_past, l_fut, cause_part, effect_part, tau, delay in CASES:
    r = cami.multithread_causality(x, y, x_divs=cause_part, y_divs=effect_part,
                                   symbolic_length=(l_past, l_past, l_fut), tau=tau, delay=delay)
    rows.append([r['cami_xy'], r['cami_yx'], r['mutual_info'], r['directionality'], r['te_xy'], r['te_yx']])
np.savetxt(os.path.join(HERE, 'expected.csv'), rows, delimiter=',', fmt='%.17g',
           header='cami_xy,cami_yx,mutual_info,diridx,te_xy,te_yx (bits)')
print('wrote fixtures with cami from', cami.__file__)
