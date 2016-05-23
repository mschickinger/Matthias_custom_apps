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
    
    % preparation of data
    if isempty(p.Results.interval)
        trace = p.Results.trace;
        tmp_steps = p.Results.steps_in;
    else
        interval = p.Results.interval;
        trace = p.Results.trace(interval(1):interval(2));
        tmp_steps = p.Results.steps_in(p.Results.steps_in>=interval(1) ...
            & p.Results.steps_in<=interval(2)) - interval(1) + 1;
    end
    
    % MAIN PART: DECIDE WHICH STEP TO KILL
    
    % experiment: decide based on changes in total variance upon step
    % removal (did not work so well)
%     delta_chi2 = zeros(size(tmp_steps));
%     A = sum((trace(1:tmp_steps(1)-1) - mean(trace(1:tmp_steps(1)-1))).^2);
%     B = sum((trace(tmp_steps(1):tmp_steps(2)-1) - mean(trace(tmp_steps(1):tmp_steps(2)-1))).^2);
%     C = sum((trace(1:tmp_steps(2)-1) - mean(trace(1:tmp_steps(2)-1))).^2);
%     delta_chi2(1) = (A+B)/C; %difference in variances with/without step (neglecting sub-interval before step)
%     for i = 2:length(delta_chi2)-1
%         A = mean(trace(tmp_steps(i):tmp_steps(i+1)-1));
%         B = mean(trace(tmp_steps(i-1):tmp_steps(i+1)-1));
%         A = sum((trace(tmp_steps(i-1):tmp_steps(i)-1) - mean(trace(tmp_steps(i-1):tmp_steps(i)-1))).^2);
%         B = sum((trace(tmp_steps(i):tmp_steps(i+1)-1) - mean(trace(tmp_steps(i):tmp_steps(i+1)-1))).^2);
%         C = sum((trace(tmp_steps(i-1):tmp_steps(i+1)-1) - mean(trace(tmp_steps(i-1):tmp_steps(i+1)-1))).^2);
%         delta_chi2(1) = (A+B)/C;
%     end
%     A = sum((trace(tmp_steps(end-1):tmp_steps(end)-1) - mean(trace(tmp_steps(end-1):tmp_steps(end)-1))).^2);
%     B = sum((trace(tmp_steps(end):end) - mean(trace(tmp_steps(end):end))).^2);
%     C = sum((trace(tmp_steps(end-1):end) - mean(trace(tmp_steps(end-1):end))).^2);
%     delta_chi2(1) = (A+B)/C;
% 
%     [~, mindex] = min(delta_chi2);
    
    % decide based on total step size (difference of mean levels)
    tmp_levels = get_levels(trace, tmp_steps);
    [~, mindex] = min(abs(tmp_levels(2:end)-tmp_levels(1:end-1)));
   
    % create output
    switch isempty(p.Results.interval)
        case true
            tmp_steps(mindex) = [];
            steps_out = tmp_steps;
        case false
            steps_out = p.Results.steps_in(p.Results.steps_in ~= ...
                tmp_steps(mindex)) + interval(1) - 1;
    end
end

