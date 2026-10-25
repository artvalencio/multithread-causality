function check_close(actual, expected, tol, label)
% CHECK_CLOSE Errors unless all |actual - expected| <= tol.
    if nargin < 4
        label = 'value';
    end
    if ~isequal(size(actual), size(expected)) && numel(expected) ~= 1
        error('%s: size [%s] differs from expected [%s]', label, num2str(size(actual)), num2str(size(expected)));
    end
    worst = max(abs(actual(:) - expected(:)));
    if ~(worst <= tol)
        error('%s: off by %g (tolerance %g); got %s, expected %s', label, worst, tol, ...
              mat2str(actual, 6), mat2str(expected, 6));
    end
end
