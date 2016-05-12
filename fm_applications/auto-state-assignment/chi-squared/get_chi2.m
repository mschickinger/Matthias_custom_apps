function [ chi2, SqDevs ] = get_chi2( trace, varargin )
%calculate residual chi2 of trace with step positions step_pos
    
    p = inputParser;
    addRequired(p, 'trace', @isnumeric);
    addOptional(p, 'step_pos', [], @isnumeric);
    
    parse(p, trace, varargin{:})
    
    trace = p.Results.trace;
    step_pos = sort(p.Results.step_pos);
    
    if isempty(step_pos)
        SqDevs = (trace-mean(trace)).^2;
    else
        SqDevs = zeros(size(trace));
        SqDevs(1:step_pos(1)-1) = (trace(1:step_pos(1)-1)-mean(trace(1:step_pos(1)-1))).^2;
        for i = 1:length(step_pos)-1
            SqDevs(step_pos(i):step_pos(i+1)-1) = (trace(step_pos(i):step_pos(i+1)-1)-mean(trace(step_pos(i):step_pos(i+1)-1))).^2;
        end
        SqDevs(step_pos(end):end) = (trace(step_pos(end):end)-mean(trace(step_pos(end):end))).^2;
    end
    chi2 = sum(SqDevs);
end

