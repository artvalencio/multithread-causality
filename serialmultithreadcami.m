function [cami_xy,cami_yx,mutual_info,diridx,te_xy,te_yx,pointwise]...
    = serialmultithreadcami(cause,effect,L_past,L_fut,cause_part,effect_part,tau,units,varargin)
% SERIALMULTITHREADCAMI Same as MULTITHREADCAMI, computed on a single CPU core.
%   Kept for backward compatibility: it is equivalent to
%   multithreadcami(..., 'parallel', false). See help multithreadcami for
%   the inputs, outputs and options.
%
%   Example:
%       [cami_xy,cami_yx,mi,diridx,te_xy,te_yx] = ...
%                serialmultithreadcami(x,y,2,3,0.5,0.5,1,'nats');
    [cami_xy,cami_yx,mutual_info,diridx,te_xy,te_yx,pointwise] = multithreadcami(cause,effect,L_past,L_fut,...
        cause_part,effect_part,tau,units,'parallel',false,varargin{:});
end
