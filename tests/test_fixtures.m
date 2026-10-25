function tests = test_fixtures()
% Agreement with reference values computed by cami-python (tests/fixtures).
    tests = {@test_matches_cami_python};
end

function test_matches_cami_python()
    here = fileparts(mfilename('fullpath'));
    x = csvread(fullfile(here, 'fixtures', 'x.csv'));
    y = csvread(fullfile(here, 'fixtures', 'y.csv'));
    expected = dlmread(fullfile(here, 'fixtures', 'expected.csv'), ',', 1, 0);
    cases = fixture_cases();
    problems = {};
    for c = 1:size(cases, 1)
        [L_past, L_fut, cause_part, effect_part, tau, delay] = cases{c, :};
        [a, b, mi, di, te_xy, te_yx] = multithreadcami(x, y, L_past, L_fut, cause_part, effect_part, tau, 'bits', 'delay', delay);
        got = [a, b, mi, di, te_xy, te_yx];
        if max(abs(got - expected(c, :))) > 1e-10
            problems{end+1} = sprintf('case %d (L_past=%d, L_fut=%d, tau=%d): got %s, expected %s', ...
                                      c, L_past, L_fut, tau, mat2str(got, 5), mat2str(expected(c, :), 5)); %#ok<AGROW>
        end
    end
    if ~isempty(problems)
        error('%s', strjoin(problems, '; '));
    end
end
