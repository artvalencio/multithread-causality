# multithread-causality

Causality toolbox for systems observed through many parallel experiments
(MATLAB / GNU Octave).

`multithreadcami` computes the Causal Mutual Information (CaMI) in both
directions, the Mutual Information, the Transfer Entropy in both directions,
the Directionality Index and pointwise information measures, pooling many
short, independent observations of the same phenomenon. A Python version is
`multithread_causality` in [CaMI-Python](https://github.com/artvalencio/cami-python);
both give the same results.

## Requirements

- MATLAB R2016b or later, or GNU Octave 6 or later (tested with Octave 9.1)
- Optional: MATLAB Parallel Computing Toolbox, used by `parfor` for the
  `'confidence'` runs and per-window pointwise tables (without it, or in
  Octave, these loops run serially with the same results)

No installation is needed: add the folder to the path (`addpath('path/to/multithread-causality')`).
Details of each function: `help multithreadcami`.

## Usage

```matlab
[cami_xy,cami_yx,mi,diridx,te_xy,te_yx,pointwise,confidence] = ...
    multithreadcami(cause,effect,L_past,L_fut,cause_part,effect_part,tau,units,options...)
```

| Input | Meaning |
|---|---|
| `cause`, `effect` | matrices of the same size: rows are time, columns are experiments |
| `L_past`, `L_fut` | symbols in the past words of x and y, and in the future word of y |
| `cause_part`, `effect_part` | increasing partition divisions (e.g. `[0.5 1]`: symbols 0 for x < 0.5, 1 for 0.5 ≤ x < 1, 2 for x ≥ 1); same number for both |
| `tau` | spacing between the points of a word (1 for maps) |
| `units` | `'bits'` (or `'bit'`) or `'nats'` (or `'nat'`) |

Options (name-value pairs, in any order):

| Option | Effect |
|---|---|
| `'delay', d` | pairs `cause(n)` with `effect(n+d)`; `d` may be negative |
| `'local', w` | measures over sliding windows of `w+1` points; outputs become one value per window |
| `'step', s` | with `'local'`, moves the window `s` points at a time (default 1) |
| `'confidence', N` | confidence margins from `N` runs with the cause shuffled in time within each experiment (8th output: largest CaMI, MI and TE X→Y obtained) |
| `'parallel', true/false` | use `parfor` (default `true`); `serialmultithreadcami(...)` equals `'parallel', false` |
| `'save'` | writes `output.txt` (summary) and `calculations.mat` (series, symbols, words, probabilities, results) |

Examples:

```matlab
% 3 symbols, 2 points of past -> 2 points of future, tau = 8
[cami_xy,cami_yx,mi,diridx,te_xy,te_yx] = multithreadcami(x,y,2,2,[0.2 0.6],[0.2 0.8],8,'bits');

% sliding windows of 501 points every 100 points, with a delay of 2
cami_xy = multithreadcami(x,y,1,1,0.5,0.5,1,'bits','local',500,'step',100,'delay',2);

% is CaMI above chance level?
[cami_xy,~,~,~,~,~,~,conf] = multithreadcami(x,y,1,1,0.5,0.5,1,'bits','confidence',100);
significant = cami_xy > conf.cami_xy;
```

## How it works

Each series is encoded into symbols with the given partitions. Symbolic words
are formed with spacing `tau` inside each experiment, never across
experiments: at time n, the past of x and the past of y are the `L_past`
symbols before n, and the future of y the `L_fut` symbols from n on. The word
frequencies of all experiments together give the probabilities, and with H
the plug-in entropy:

- MI = H(Xp) + H(Yp) − H(Xp, Yp)
- CaMI(X→Y) = H(Xp) + H(Yp, Yf) − H(Xp, Yp, Yf)
- TE(X→Y) = CaMI(X→Y) − MI, and TE(Y→X) = CaMI(Y→X) − MI
- Directionality Index = CaMI(X→Y) − CaMI(Y→X), positive when information flows from X to Y

Measures are computed from counts of the observed words: dense tables for
small alphabets, lists of observed words for large ones. Pointwise tables are
built only when that output is requested; for very large alphabets they list
the observed cells (`help multithreadcami`).

## FAQ

**When to use Multithread Causality?** When you investigate the dynamics of a
phenomenon you may have (i) one very long time-series, or (ii) many short
observations taken independently. The original Causality Toolbox addresses
the first case; Multithread Causality the second. It is backward compatible:
a single long observation is a single column.

**What does "serial" mean?** `serialmultithreadcami` computes the same values
without `parfor`, for MATLAB users without the Parallel Computing Toolbox or
when a serial run is faster. It is the same as `multithreadcami(..., 'parallel', false)`.

**How to interpret the results?** The outputs are global information-theoretical
values (CaMI, MI, TE and Directionality Index, a net transfer entropy) for the
whole set of observations. See the references below for the mathematical details.

**What about confidence margins?** A confidence margin is what you would get by
chance rather than from an actual physical relationship, like an error bar.
`'confidence', N` shuffles the time order of the cause within each experiment
N times, which destroys any relationship, and returns the largest values
obtained. In principle these are close to zero, but not exactly, because of
the limited size of the data. A hypothesis is supported only if the values for
the original data are clearly above the confidence margins.

## Tests and benchmarks

```
octave-cli --eval "cd tests; run_tests"     (or: sh run_tests.sh)
matlab -batch "cd tests; run_tests"
```

Reference values in `tests/fixtures` are computed with CaMI-Python
(`tests/fixtures/make_fixtures.py`). Benchmarks: `benchmarks/run_benchmarks.m`.

Timings in GNU Octave (before → after the 2026 update):

| Case | Before | After |
|---|---|---|
| `'local'`, 800 windows of 200 points, 20 experiments | 1.45 s | 0.015 s |
| `'confidence'`, 20 runs, 1000 × 200 | 1.21 s | 0.35 s |
| whole series, 1000 × 200 | 0.09–0.19 s | 0.03–0.06 s |
| 10 symbols, L_past = 3, L_fut = 3 | out of memory | 0.38 s |

## Changes (2026)

- options after the first one were ignored; unknown options are now reported
- `'delay'` did not shift the series (and negative delays broke matrices)
- symbolic words with tau > 1 used consecutive points instead of tau-spaced
  ones, and the last tau points were never used as future words
- the size check missed row mismatches; units are validated
- `'save'` failed (undefined variable; `table` not available in Octave)
- confidence margins are now computed (`'confidence', N`)
- one implementation for the parallel and serial versions, vectorized;
  large alphabets supported; sliding windows computed together

## Credits

(C) Dr Arthur Valencio[1,2]', Dr Norma Valencio[3]'' and Dr Murilo S. Baptista[1]

[1] Institute for Complex Systems and Mathematical Biology (ICSMB), University of Aberdeen
[2] Research, Innovation and Dissemination Center for Neuromathematics (RIDC NeuroMat)
[3] Department of Environmental Sciences, Federal University of Sao Carlos (UFSCar)

'Support: CNPq [206246/2014-5] and FAPESP [2018/09900-8], Brazil
''Support: FAPESP [17/17224-0] and CNPq [310976/2017-0], Brazil

This package is available as is, without any warranty. Use it at your own risk.

Original: 19 June 2018. Updates: 07 July 2019; October 2026.

## Citation

If useful, please cite:

1. Arthur Valencio. An information-theoretical approach to identify seismic precursors and earthquake-causing variables. PhD thesis, University of Aberdeen, 2018. Available at: http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer
2. Arthur Valencio, Norma Valencio and Murilo S. Baptista. Multithread causality: causality toolbox for systems observed through many short parallel experiments. Open source codes for Matlab. 2018. Available at: https://github.com/artvalencio/multithread-causality/

```bibtex
@phdthesis{Valencio2018, author={Arthur Valencio}, title={An information-theoretical approach to identify seismic precursors and earthquake-causing variables}, school={University of Aberdeen}, year={2018},address={Aberdeen (UK)},note= {Available at: \url{http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer}.}}

@misc{cami, author={Valencio, Arthur and Valencio, Norma and Baptista, Murilo da Silva}, title={Pointwise Information: displaying the topology of causality from the time-series}, note={Open source codes for Matlab. Available at \url{https://github.com/artvalencio/multithread-causality/}.}, year={2018} }
```
