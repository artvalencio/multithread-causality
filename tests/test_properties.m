function tests = test_properties()
% Analytic properties of the estimators (characterization tests).
    tests = {@test_direction_of_coupling, @test_independent_series, @test_te_is_cami_minus_mi, ...
             @test_units, @test_serial_equals_parallel};
end

function test_direction_of_coupling()
    [x, y] = coupled_trials(150, 40, 1);
    [cami_xy, cami_yx, mi, diridx] = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits');
    check_close(cami_xy, 1, 0.02, 'cami_xy');
    check_close(cami_yx, 0, 0.02, 'cami_yx');
    check_close(mi, 0, 0.02, 'mutual_info');
    assert(diridx > 0.95, 'directionality index should be ~1');
end

function test_independent_series()
    [x, ~, z] = coupled_trials(150, 40, 2);
    [cami_xy, cami_yx, mi] = multithreadcami(x, z, 1, 1, 0.5, 0.5, 1, 'bits');
    check_close([cami_xy, cami_yx, mi], [0, 0, 0], 0.02, 'measures');
end

function test_te_is_cami_minus_mi()
    [x, y] = coupled_trials(100, 10, 3);
    [cami_xy, cami_yx, mi, diridx, te_xy, te_yx] = multithreadcami(x, y, 2, 1, [0.3 0.6], [0.3 0.6], 1, 'bits');
    check_close(te_xy, cami_xy - mi, 1e-12, 'te_xy');
    check_close(te_yx, cami_yx - mi, 1e-12, 'te_yx');
    check_close(diridx, cami_xy - cami_yx, 1e-12, 'diridx');
end

function test_units()
    [x, y] = coupled_trials(100, 10, 4);
    [b1, b2, b3] = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits');
    [n1, n2, n3] = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'nats');
    check_close([n1 n2 n3], [b1 b2 b3] * log(2), 1e-12, 'nats');
end

function test_serial_equals_parallel()
    [x, y] = coupled_trials(80, 6, 5);
    [a1, a2, a3, a4, a5, a6] = multithreadcami(x, y, 2, 1, [0.3 0.6], [0.4 0.7], 1, 'bits');
    [b1, b2, b3, b4, b5, b6] = serialmultithreadcami(x, y, 2, 1, [0.3 0.6], [0.4 0.7], 1, 'bits');
    check_close([a1 a2 a3 a4 a5 a6], [b1 b2 b3 b4 b5 b6], 1e-12, 'serial vs parallel');
end
