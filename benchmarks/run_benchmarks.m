function results = run_benchmarks()
% RUN_BENCHMARKS Timings of multithreadcami (MATLAB and GNU Octave); best of 3 runs.
%   octave-cli --eval "cd benchmarks; run_benchmarks"
    here = fileparts(mfilename('fullpath'));
    addpath(fullfile(here, '..'));
    rand('state', 1);
    x = rand(1000, 200);
    y = [rand(1, 200); x(1:end-1, :)];
    x20 = x(:, 1:20);
    y20 = y(:, 1:20);
    cases = {
        'global 1000x200 L=1/1 ns=2',          @() multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits');
        'global 1000x200 L=3/2 ns=4',          @() multithreadcami(x, y, 3, 2, [0.25 0.5 0.75], [0.25 0.5 0.75], 1, 'bits');
        'global 1000x200 L=3/3 ns=10',         @() multithreadcami(x, y, 3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 'bits');
        'confidence 20, 1000x200',             @() multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'confidence', 20);
        'local w=200, 1000x20 (800 windows)',  @() multithreadcami(x20, y20, 1, 1, 0.5, 0.5, 1, 'bits', 'local', 200);
        'local w=200 L=2/1 ns=3, 1000x20',     @() multithreadcami(x20, y20, 2, 1, [0.3 0.6], [0.3 0.6], 1, 'bits', 'local', 200);
    };
    results = struct('name', cases(:, 1), 'seconds', NaN);
    for c = 1:size(cases, 1)
        try
            best = Inf;
            for r = 1:3
                tic;
                evalc('cases{c, 2}();');
                best = min(best, toc);
            end
            results(c).seconds = best;
            fprintf('%-38s %8.3f s\n', cases{c, 1}, best);
        catch err
            fprintf('%-38s FAILED: %s\n', cases{c, 1}, strtok(err.message, sprintf('\n')));
        end
    end
end
