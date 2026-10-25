function [x, y, z] = coupled_trials(n_points, n_trials, seed)
% COUPLED_TRIALS Uniform trials x, a lagged copy y (y(n) = x(n-1), so X drives Y)
% and independent trials z.
    rand('state', seed);
    x = rand(n_points, n_trials);
    y = [rand(1, n_trials); x(1:end-1, :)];
    z = rand(n_points, n_trials);
end
