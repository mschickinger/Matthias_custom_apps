function [steps, steps_in_order, chi2, counter_chi2, levels, step_trace] = find_steps_by_chi2(trace, N, max_frame)
% find up to N transitions with chi-squared method
    % parse input and set parameters
    p = inputParser;
    addRequired(p, 'trace', @isnumeric);
    addRequired(p, 'N', @isnumeric);
    addOptional(p, 'max_frame', -1, @isnumeric);

    parse(p, trace, N, max_frame);

    trace = p.Results.trace;
    N = p.Results.N;
    if p.Results.max_frame > 0
        trace = trace(1:p.Results.max_frame);
    end
    if any(isnan(trace))
        trace = trace(1:find(isnan(trace),1)-1);
    end

    % chi2 containers
    chi2(N) = 0;
    counter_chi2 = chi2;

    % find first transition and perform first counterfit
    steps = [];
    steps_in_order = zeros(N,1);
    [steps(1), ~ ] = find_mps(trace);
    steps_in_order(1) = steps(1);
    countersteps = zeros(1,N+1);
    [countersteps(1), ~] = find_mps(trace(1:steps(1)-1));
    [tmp, ~] = find_mps(trace(steps(1)+1:end));
    countersteps(2) = steps(1) + tmp;
    chi2(1) = get_chi2(trace,steps);
    counter_chi2(1) = get_chi2(trace, countersteps(countersteps>0));
    display(['iteration number ' num2str(length(steps)) ' done.'])

    % find all other transitions until S has peaked and fallen below 2 again
    go_on = 1; N_min = 25;
    S = 1;
    while (go_on || (S>2)) && length(steps)<N
        % find best fits for all plateaus
        candidates = zeros(1,length(steps)+1);
        windows = candidates;
        deltas = candidates;
        [candidates(1), deltas(1)] = find_mps(trace(1:steps(1)-1));
        windows(1) = steps(1) - candidates(1);
        for i = 1:length(steps)-1
            [tmp, deltas(i+1)] = find_mps(trace(steps(i)+1:steps(i+1)-1));
            candidates(i+1) = steps(i)+tmp;
            windows(i+1) = min(tmp, (steps(i+1)-steps(i)-tmp));
        end
        [windows(end), deltas(end)] = find_mps(trace(steps(end)+1:end));
        candidates(end) = steps(end) + windows(end);

        % choose step to be added in this iteration
        [~,max_index] = max(deltas.*sqrt(windows));
        steps = sort([steps; candidates(max_index)]);
        steps_in_order(length(steps)) = candidates(max_index);

        % perform counter fit
        countersteps = zeros(1,N+1);
        [tmp, ~] = find_mps(trace(steps(end)+1:end));
        countersteps(length(steps)+1) = steps(end) + tmp;
        countersteps(1) = find_mps(trace(1:steps(1)-1));
        for i = 1:length(steps)-1
            [tmp, ~] = find_mps(trace(steps(i)+1:steps(i+1)-1));
            countersteps(i) = steps(i) + tmp;
        end

        % calculate chi2 for fit and counter fit
        chi2(length(steps)) = get_chi2(trace, steps);
        counter_chi2(length(steps)) = get_chi2(trace, countersteps(countersteps>0));
        S = counter_chi2(length(steps))/chi2(length(steps));
        if go_on && length(steps)>N_min
            go_on = go_on*(S<2.5);
        end
        display(['iteration number ' num2str(length(steps)) ' done. S = ' num2str(S)])
    end
    steps_in_order = steps_in_order(steps_in_order>0);
    chi2 = chi2(chi2>0);
    counter_chi2 = counter_chi2(counter_chi2>0);
    [levels, step_trace] = get_levels(trace,steps);
    display(['finished. total number of steps is ' num2str(length(steps)) '.'])
end