function tests = test_inputs()
% Option parsing and input validation.
    tests = {@test_positive_delay_shifts_the_effect, @test_negative_delay_keeps_matrix_shape, ...
             @test_delay_reveals_a_lagged_response, @test_every_option_is_parsed, @test_unknown_option, ...
             @test_size_mismatch_in_rows, @test_size_mismatch_in_columns, @test_unit_aliases, @test_invalid_units};
end

function out = measures(varargin)
    [a, b, c, d, e, f] = multithreadcami(varargin{:});
    out = [a, b, c, d, e, f];
end

function test_positive_delay_shifts_the_effect()
    [x, y] = coupled_trials(120, 8, 11);
    check_close(measures(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'delay', 2), ...
                measures(x(1:end-2, :), y(3:end, :), 1, 1, 0.5, 0.5, 1, 'bits'), 1e-12, 'delay 2');
end

function test_negative_delay_keeps_matrix_shape()
    [x, y] = coupled_trials(120, 8, 12);
    check_close(measures(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'delay', -2), ...
                measures(x(3:end, :), y(1:end-2, :), 1, 1, 0.5, 0.5, 1, 'bits'), 1e-12, 'delay -2');
end

function test_delay_reveals_a_lagged_response()
    % y(n) = x(n-3): the one-step CaMI only sees the link with a delay of 2
    [x, ~, z] = coupled_trials(200, 30, 13);
    y = [z(1:3, :); x(1:end-3, :)];
    no_delay = measures(x, y, 1, 1, 0.5, 0.5, 1, 'bits');
    delayed = measures(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'delay', 2);
    check_close(no_delay(1), 0, 0.02, 'cami_xy without delay');
    check_close(delayed(1), 1, 0.02, 'cami_xy with delay 2');
end

function test_every_option_is_parsed()
    % the delay comes after another option and must still be applied
    [x, y] = coupled_trials(150, 5, 14);
    [cami_xy, ~, mi] = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'local', 99, 'delay', 1);
    expected = measures(x(1:100, :), y(2:101, :), 1, 1, 0.5, 0.5, 1, 'bits');
    check_close([cami_xy(1), mi(1)], expected([1 3]), 1e-12, 'first window');
end

function test_unknown_option()
    [x, y] = coupled_trials(50, 2, 15);
    check_error(@() multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'dealy', 1), 'unknown option');
end

function test_size_mismatch_in_rows()
    [x, y] = coupled_trials(50, 4, 16);
    check_error(@() multithreadcami(x, y(1:end-1, :), 1, 1, 0.5, 0.5, 1, 'bits'), 'same size');
end

function test_size_mismatch_in_columns()
    [x, y] = coupled_trials(50, 4, 17);
    check_error(@() multithreadcami(x, y(:, 1:3), 1, 1, 0.5, 0.5, 1, 'bits'), 'same size');
end

function test_unit_aliases()
    [x, y] = coupled_trials(80, 4, 18);
    check_close(measures(x, y, 1, 1, 0.5, 0.5, 1, 'bit'), measures(x, y, 1, 1, 0.5, 0.5, 1, 'bits'), 0, 'bit');
    check_close(measures(x, y, 1, 1, 0.5, 0.5, 1, 'nat'), measures(x, y, 1, 1, 0.5, 0.5, 1, 'nats'), 0, 'nat');
end

function test_invalid_units()
    [x, y] = coupled_trials(50, 2, 19);
    check_error(@() multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'banana'), 'units');
end
