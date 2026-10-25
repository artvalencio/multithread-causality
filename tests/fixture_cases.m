function cases = fixture_cases()
% FIXTURE_CASES Parameters of tests/fixtures/expected.csv (same order as make_fixtures.py).
%   Each row: {L_past, L_fut, cause_part, effect_part, tau, delay}
    cases = {
        1, 1, 0.5,        0.5,         1, 0;
        2, 1, [0.3 0.6],  [0.3 0.6],   1, 0;
        1, 2, 0.5,        0.4,         1, 0;
        2, 2, 0.5,        0.5,         2, 0;
        1, 1, [0.3 0.6],  [0.35 0.65], 3, 0;
        2, 1, 0.5,        0.5,         1, 1;
        3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 0;
    };
end
