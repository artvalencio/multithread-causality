function check_error(f, pattern)
% CHECK_ERROR Errors unless calling f() raises an error whose message matches pattern.
    try
        f();
    catch err
        if isempty(regexpi(err.message, pattern, 'once'))
            error('expected an error matching "%s", got "%s"', pattern, err.message);
        end
        return
    end
    error('expected an error matching "%s", but none was raised', pattern);
end
