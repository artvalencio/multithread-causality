function run_tests()
% RUN_TESTS Runs every test in tests/test_*.m (works in MATLAB and GNU Octave).
%   Each test file is a function returning a cell array of handles to its
%   test functions. Raises an error (non-zero exit status in batch mode)
%   if any test fails.
%
%   octave-cli --eval "cd tests; run_tests"
%   matlab -batch "cd tests; run_tests"
    here = fileparts(mfilename('fullpath'));
    addpath(here);
    addpath(fullfile(here, '..'));
    files = dir(fullfile(here, 'test_*.m'));
    n_run = 0;
    failed = {};
    for i = 1:numel(files)
        suite = files(i).name(1:end-2);
        tests = feval(suite);
        for j = 1:numel(tests)
            name = sprintf('%s/%s', suite, func2str(tests{j}));
            n_run = n_run + 1;
            try
                evalc('tests{j}()');  % hide the functions' progress output
                fprintf('PASS %s\n', name);
            catch err
                fprintf('FAIL %s\n     %s\n', name, err.message);
                failed{end+1} = name; %#ok<AGROW>
            end
        end
    end
    fprintf('\n%d tests, %d failed\n', n_run, numel(failed));
    if ~isempty(failed)
        error('run_tests:failed', '%d of %d tests failed', numel(failed), n_run);
    end
end
