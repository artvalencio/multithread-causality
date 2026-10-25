function tests = test_confidence()
% Confidence margins from shuffled surrogates ('confidence', N).
    tests = {@test_margins_are_returned, @test_coupling_exceeds_margins, @test_margins_are_saved, ...
             @test_confidence_needs_global_mode, @test_serial_version_returns_margins};
end

function test_margins_are_returned()
    [x, ~, z] = coupled_trials(100, 10, 41);
    [~, ~, ~, ~, ~, ~, ~, conf] = multithreadcami(x, z, 1, 1, 0.5, 0.5, 1, 'bits', 'confidence', 15);
    assert(conf.runs == 15, 'number of runs');
    assert(all([conf.cami_xy, conf.mutual_info] >= 0), 'margins must be non-negative');
    assert(all([conf.cami_xy, conf.mutual_info, conf.te_xy] < 0.02), 'margins of independent data should be small');
end

function test_coupling_exceeds_margins()
    [x, y] = coupled_trials(100, 10, 42);
    [cami_xy, ~, ~, ~, te_xy, ~, ~, conf] = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'confidence', 15);
    assert(cami_xy > 10 * conf.cami_xy, 'CaMI should exceed its confidence margin');
    assert(te_xy > 10 * conf.te_xy, 'TE should exceed its confidence margin');
end

function test_margins_are_saved()
    [x, y] = coupled_trials(60, 3, 43);
    folder = tempname();
    mkdir(folder);
    previous = cd(folder);
    cleanup = onCleanup(@() cd(previous));
    multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'save', 'confidence', 5);
    summary = fileread(fullfile(folder, 'output.txt'));
    assert(~isempty(strfind(summary, 'Confidence margins')), 'summary lacks the confidence margins');
end

function test_confidence_needs_global_mode()
    [x, y] = coupled_trials(60, 3, 44);
    check_error(@() multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'local', 30, 'confidence', 5), 'local');
end

function test_serial_version_returns_margins()
    [x, y] = coupled_trials(60, 3, 45);
    [~, ~, ~, ~, ~, ~, ~, conf] = serialmultithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'confidence', 3);
    assert(conf.runs == 3, 'number of runs');
end
