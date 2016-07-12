function [sequence, S, stremain]= rm_steps_analysiS(trace, steps)

    % Parse input
    p = inputParser;
    addRequired(p, 'trace', @isnumeric)
    addRequired(p, 'steps', @isnumeric)

    parse(p, trace, steps)
    trace = p.Results.trace;
    steps = p.Results.steps;

    % perform first counter fits
    N = length(steps);
    countersteps = zeros(1,N+1);
    tmp = find_mps(trace(steps(end)+1:end));
    if isempty(tmp)
        countersteps(end) = length(trace);
    else
        countersteps(end) = steps(end) + tmp;
    end
    tmp = find_mps(trace(1:steps(1)-1));
    if isempty(tmp)
        countersteps(1) = 1;
    else
        countersteps(1) = tmp;
    end
    for i = 1:length(steps)-1
        tmp = find_mps(trace(steps(i)+1:steps(i+1)-1));
        if isempty(tmp)
            countersteps(i+1) = floor(mean(steps(i:i+1)));
        else
            countersteps(i+1) = steps(i) + tmp;
        end
    end

    % Get step heights (from max/min values of trace in adjacent intervals)
    heights = zeros(size(steps));
    %first step
    minmax = [max(trace(1:steps(1))) min(trace(steps(1):steps(2))) ; ...
                min(trace(1:steps(1))) max(trace(steps(1):steps(2)))];
    heights(1) = max(abs(minmax(:,1)-minmax(:,2)));

    for i = 2:length(heights)-1
        minmax = [max(trace(steps(i-1):steps(i))) min(trace(steps(i):steps(i+1))) ; ...
                    min(trace(steps(i-1):steps(i))) max(trace(steps(i):steps(i+1)))];
        heights(i) = max(abs(minmax(:,1)-minmax(:,2)));
    end

    minmax = [max(trace(steps(end):steps(end))) min(trace(steps(end):end)) ; ...
                min(trace(steps(end):steps(end))) max(trace(steps(end):end))];
    heights(end) = max(abs(minmax(:,1)-minmax(:,2)));
    
    % Output variables
    stremain = steps;
    sequence = zeros(length(steps)-2,3);
    S = zeros(size(steps));

    % Proceed to step-by-step step removal
    k = 1;
    while length(stremain)>2
        [sequence(k,2), ind] = min(heights);
        sequence(k,1) = stremain(ind);
        heights(ind) = [];
        borders = zeros(1,2);
        if ind == 1
            borders(1) = 1; borders(2) = stremain(2)-1;
            minmax = [max(trace(1:stremain(2))) min(trace(stremain(2):stremain(3))) ; ...
                min(trace(1:stremain(2))) max(trace(stremain(2):stremain(3)))];
            heights(1) = max(abs(minmax(:,1)-minmax(:,2)));
        elseif ind == length(stremain)
            borders(1) = stremain(end-1)+1; borders(2) = length(trace);
            minmax = [max(trace(stremain(end-2):stremain(end-1))) min(trace(stremain(end-1):end)) ; ...
                min(trace(stremain(end-2):stremain(end-1))) max(trace(stremain(end-1):end))];
            heights(end) = max(abs(minmax(:,1)-minmax(:,2)));
        else
            borders(1) = stremain(ind-1)+1; borders(2) = stremain(ind+1)-1;
            if ind>2
                minmax = [max(trace(stremain(ind-2):stremain(ind-1))) min(trace(stremain(ind-1):stremain(ind+1))); ...
                min(trace(stremain(ind-2):stremain(ind-1))) max(trace(stremain(ind-1):stremain(ind+1)))];
            else
                minmax = [max(trace(1:stremain(ind-1))) min(trace(stremain(ind-1):stremain(ind+1))); ...
                min(trace(1:stremain(ind-1))) max(trace(stremain(ind-1):stremain(ind+1)))];
            end
            heights(ind-1) = max(abs(minmax(:,1)-minmax(:,2)));
            if length(stremain)-ind>=2
                minmax = [max(trace(stremain(ind-1):stremain(ind+1))) min(trace(stremain(ind+1):stremain(ind+2))); ...
                    min(trace(stremain(ind-1):stremain(ind+1))) max(trace(stremain(ind+1):stremain(ind+2)))];
            else
                minmax = [max(trace(stremain(ind-1):stremain(ind+1))) min(trace(stremain(ind+1):end)); ...
                    min(trace(stremain(ind-1):stremain(ind+1))) max(trace(stremain(ind+1):end))];
            end
            heights(ind) = max(abs(minmax(:,1)-minmax(:,2)));
        end
        sequence(k,3) = get_chi2(trace(borders(1):borders(2)))/ ...
                        get_chi2(trace(borders(1):borders(2)),stremain(ind)-borders(1)+1);
        stremain(ind) = [];
        countersteps(ind) = [];
        countersteps(ind) = find_mps(trace(borders(1):borders(2))) + borders(1) - 1;
        S(k) = get_chi2(trace,countersteps)/get_chi2(trace,stremain);
        k = k+1;
        display(['Number of steps remaining: ' num2str(length(stremain))])
    end
    display('Step-by-step step removal done.')
end
