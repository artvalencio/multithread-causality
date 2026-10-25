function tests = test_save()
% The 'save' option writes a text summary and a .mat file.
    tests = {@test_save_writes_summary_and_mat_file};
end

function test_save_writes_summary_and_mat_file()
    [x, y] = coupled_trials(80, 3, 31);
    folder = tempname();
    mkdir(folder);
    previous = cd(folder);
    cleanup = onCleanup(@() cd(previous));
    [cami_xy, ~, mi] = multithreadcami(x, y, 1, 1, 0.5, 0.5, 1, 'bits', 'save');
    summary = fileread(fullfile(folder, 'output.txt'));
    assert(~isempty(strfind(summary, sprintf('CaMI X->Y: %.6g', cami_xy))), 'summary lacks CaMI X->Y');
    saved = load(fullfile(folder, 'calculations.mat'));
    check_close(saved.cami_xy, cami_xy, 1e-12, 'saved cami_xy');
    check_close(saved.mutual_info, mi, 1e-12, 'saved mutual_info');
    assert(isequal(size(saved.timeseries.Sx), size(x)), 'saved symbols have the wrong size');
    assert(abs(sum(saved.p_xypf(:)) - 1) < 1e-12, 'saved joint probabilities do not sum to 1');
end
