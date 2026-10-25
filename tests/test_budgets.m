function tests = test_budgets()
% Generous time budgets (performance plan items D1, D2).
    tests = {@test_local_windows_time, @test_confidence_time};
end

function test_local_windows_time()
    [x, y] = coupled_trials(1000, 20, 61);
    multithreadcami(x(1:300, :), y(1:300, :), 1, 1, 0.5, 0.5, 1, 'bits', 'local', 200);  % warm-up
    tic;
    multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'local', 200);
    elapsed = toc;
    assert(elapsed < 0.4, sprintf('800 windows took %.2f s', elapsed));  % 1.45 s before, ~0.02 s now
end

function test_confidence_time()
    [x, y] = coupled_trials(1000, 200, 62);
    tic;
    multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'confidence', 20);
    elapsed = toc;
    assert(elapsed < 1.5, sprintf('20 confidence runs took %.2f s', elapsed));  % 1.2 s before, ~0.35 s now
end
