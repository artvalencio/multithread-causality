function tests = test_windows()
% Sliding-window ('local') measures, the 'parallel' option and partitions.
    tests = {@test_local_window_equals_direct_call, @test_local_step, @test_parallel_option, ...
             @test_unsorted_partition_is_rejected};
end

function out = measures(varargin)
    [a, b, c, d, e, f] = multithreadcami(varargin{:});
    out = [a, b, c, d, e, f];
end

function test_local_window_equals_direct_call()
    [x, y] = coupled_trials(120, 4, 21);
    [a, b, c, d, e, f] = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'local', 59);
    assert(numel(a) == 61, sprintf('expected 61 windows, got %d', numel(a)));
    for t = [1, 30, 61]
        check_close([a(t) b(t) c(t) d(t) e(t) f(t)], measures(x(t:t+59, :), y(t:t+59, :), 1, 1, 0.5, 0.5, 1, 'bits'), ...
                    1e-12, sprintf('window %d', t));
    end
end

function test_local_step()
    [x, y] = coupled_trials(120, 4, 22);
    all_windows = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'local', 59);
    stepped = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'local', 59, 'step', 10);
    check_close(stepped, all_windows(1:10:61), 1e-12, 'every 10th window');
end

function test_parallel_option()
    [x, y] = coupled_trials(100, 4, 23);
    check_close(measures(x, y, 2, 1, 0.5, 0.5, 1, 'bits', 'local', 80, 'parallel', false), ...
                measures(x, y, 2, 1, 0.5, 0.5, 1, 'bits', 'local', 80, 'parallel', true), 1e-12, 'parallel');
end

function test_unsorted_partition_is_rejected()
    [x, y] = coupled_trials(50, 2, 24);
    check_error(@() multithreadcami(x, y, 1, 1, [0.6 0.3], [0.3 0.6], 1, 'bits'), 'increasing');
end
