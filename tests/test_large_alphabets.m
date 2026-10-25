function tests = test_large_alphabets()
% Alphabets too large for dense tables (10 symbols, L_past=3, L_fut=3: 10^9 joint words).
    tests = {@test_measures_are_consistent, @test_pointwise_lists_observed_cells, @test_local_windows, ...
             @test_local_windows_incremental_counts};
end

function test_measures_are_consistent()
    [x, y] = coupled_trials(200, 10, 51);
    [a, b, mi, di, te_xy, te_yx] = multithreadcami(x, y, 3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 'bits');
    check_close([te_xy, te_yx, di], [a - mi, b - mi, a - b], 1e-12, 'identities');
    assert(all(isfinite([a b mi])), 'finite');
end

function test_pointwise_lists_observed_cells()
    [x, y] = coupled_trials(100, 5, 52);
    [a, ~, mi, ~, ~, ~, pw] = multithreadcami(x, y, 3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 'nats');
    assert(isfield(pw, 'cells') && size(pw.cells, 2) == 3, 'pointwise cells for large alphabets');
    check_close(sum(pw.pcami_xy), a, 1e-10, 'pointwise CaMI terms sum to CaMI');
    check_close(sum(pw.pmi), mi, 1e-10, 'pointwise MI terms sum to MI');
end

function test_local_windows()
    [x, y] = coupled_trials(150, 4, 53);
    local = multithreadcami(x, y, 3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 'bits', 'local', 80);
    direct = multithreadcami(x(11:91, :), y(11:91, :), 3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 'bits');
    check_close(local(11), direct, 1e-12, 'window 11');
end

function test_local_windows_incremental_counts()
    % cells x rows too large for the all-windows-at-once path: counts are updated as the window slides
    [x, y] = coupled_trials(3000, 50, 54);
    local = multithreadcami(x, y, 3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 'bits', 'local', 2000, 'step', 500);
    direct = multithreadcami(x(501:2501, :), y(501:2501, :), 3, 3, 0.1:0.1:0.9, 0.1:0.1:0.9, 1, 'bits');
    assert(numel(local) == 2, 'two windows');
    check_close(local(2), direct, 1e-12, 'second window');
end
