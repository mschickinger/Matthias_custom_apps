function [stremain, sequence] = rm_steps_to_hmin(trace, steps, h_min)

    % Parse input
    p = inputParser;
    addRequired(p, 'trace', @isnumeric)
    addRequired(p, 'steps', @isnumeric)
    addRequired(p, 'h_min', @isnumeric)

    parse(p, trace, steps, h_min)
    trace = p.Results.trace;
    steps = p.Results.steps;
    h_min = p.Results.h_min;

    % Get step heights (from mean values of trace in adjacent intervals)
    levels = get_levels(trace,steps);
    heights = abs(levels(2:end)-levels(1:end-1));

    % Output variable
    stremain = steps;
    sequence = zeros(length(steps),2);

    % Proceed to step-by-step step removal
    k = 1;
    go_on = 1;
    while go_on
        [val, ind] = min(heights);
        go_on = val<h_min;
        if go_on
            sequence(k,1) = stremain(ind);
            sequence(k,2) = val;
            stremain(ind) = [];
            heights(ind) = [];
            if ind <= 2
                heights(1) = get_new_height(1,stremain(1),stremain(2)-1);
                if ind == 2
                    heights(2) = get_new_height(stremain(1),stremain(2),stremain(3)-1);
                end
            elseif ind >= length(stremain)-1
                heights(end) = get_new_height(stremain(end-1),stremain(end),length(trace));
                if ind == length(stremain)-1
                    heights(end-1) = get_new_height(stremain(end-2),stremain(end-1),stremain(end));
                end
            else
                heights(ind-1) = get_new_height(stremain(ind-2),stremain(ind-1),stremain(ind));
                heights(ind) = get_new_height(stremain(ind-1),stremain(ind),stremain(ind+1));
            end
            k = k+1;
            display(['Number of steps remaining: ' num2str(length(stremain))])
        end
    end
    sequence = sequence(1:k,:);
    display('Step-by-step step removal done.')
    
    function nh = get_new_height(a,b,c)
        nh = abs(mean(trace(a:b-1))-mean(trace(b:c)));
    end
end
