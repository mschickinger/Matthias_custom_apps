function [ steps_out ] = remove_lps( trace, steps_in, varargin )
%remove_lpt: out of a sequence of steps occuring in a certain interval, 
% remove the least prominent one (i.e. the one whose removal causes the
% least change in square deviation per frame)

    % parse input
    p = inputParser;
    addRequired(p, 'trace', @isnumeric);
    addRequired(p, 'steps_in', @isnumeric);
    addOptional(p, 'interval', [], @isnumeric);

    parse(p,trace, steps_in, varargin{:});
    
    switch isempty(p.Results.interval)
        case true
            trace = p.Results.trace;
            steps_out = p.Results.steps_in;
            delta_chi2 = zeros(size(steps_out));
            A = mean(trace(steps_out(1):steps_out(2)-1));
            B = mean(trace(1:steps_out(2)-1));
            delta_chi2(1) = (A-B)^2; 
            for i = 2:length(delta_chi2)-1
                A = mean(trace(steps_out(i):steps_out(i+1)-1));
                B = mean(trace(steps_out(i-1):steps_out(i+1)-1));
                delta_chi2(i) = (A-B)^2;
            end
            A = mean(trace(steps_out(end):end));
            B = mean(trace(steps_out(end-1):end));
            delta_chi2(end) = (A-B)^2; 
            
            [~, mindex] = min(delta_chi2);
            steps_out(mindex) = []; 
        case false
            interval = p.Results.interval;
            trace = p.Results.trace(interval(1):interval(2));
            tmp_steps = p.Results.steps_in(p.Results.steps_in>=interval(1) ...
                & p.Results.steps_in<=interval(2)) - interval(1) + 1;
            delta_chi2 = zeros(size(tmp_steps));
            A = mean(trace(tmp_steps(1):tmp_steps(2)-1));
            B = mean(trace(1:tmp_steps(2)-1));
            delta_chi2(1) = (A-B)^2; 
            for i = 2:length(delta_chi2)-1
                A = mean(trace(tmp_steps(i):tmp_steps(i+1)-1));
                B = mean(trace(tmp_steps(i-1):tmp_steps(i+1)-1));
                delta_chi2(i) = (A-B)^2;
            end
            A = mean(trace(tmp_steps(end):end));
            B = mean(trace(tmp_steps(end-1):end));
            delta_chi2(end) = (A-B)^2; 
            [~, mindex] = min(delta_chi2);
            steps_out = p.Results.steps_in(p.Results.steps_in ~= ...
                tmp_steps(mindex) + interval(1) - 1);
    end
end

