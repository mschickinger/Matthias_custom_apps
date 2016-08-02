function [stremain, sequence] = rm_steps_to_hmin(trace, steps, h_min, varargin)

    % Parse input
    p = inputParser;
    addRequired(p, 'trace', @isnumeric)
    addRequired(p, 'steps', @isnumeric)
    addRequired(p, 'h_min', @isnumeric)
    addParameter(p, 'ex_int', zeros(0,2), @isnumeric)

    parse(p, trace, steps, h_min, varargin{:})
    trace = p.Results.trace;
    steps = p.Results.steps;
    h_min = p.Results.h_min;
    ex_int = p.Results.ex_int;
    
    for i=1:size(ex_int,1)
        trace(ex_int(i,1):ex_int(i,2)) = NaN;
        steps(steps>=ex_int(1) & steps<=ex_int(2)) = [];
    end

    % Get step heights (from mean values of trace in adjacent intervals)
    levels = get_levels(trace,steps);
    heights = abs(levels(2:end)-levels(1:end-1));

    % Output variable
    stremain = steps;
    sequence = zeros(length(steps),2);

    % Proceed to step-by-step step removal
    k = 1;
    go_on = 1;
    L = length(stremain);
    while go_on && L > 2
        [val, ind] = min(heights);
        val = val(1);
        ind = ind(1);
        go_on = val<h_min;
        if go_on
            sequence(k,1) = stremain(ind);
            sequence(k,2) = val;
            stremain(ind) = [];
            heights(ind) = [];
            if L==3
                heights(1) = get_new_height(1,stremain(1),stremain(2)-1);
                heights(2) = get_new_height(stremain(1),stremain(2),length(trace));
            else
                if ind <= 2
                    heights(1) = get_new_height(1,stremain(1),stremain(2)-1);
                    if ind == 2
                        heights(2) = get_new_height(stremain(1),stremain(2),stremain(3)-1);
                    end
                elseif ind >= L-1
                    heights(end) = get_new_height(stremain(end-1),stremain(end),length(trace));
                    if ind == L-1
                        heights(end-1) = get_new_height(stremain(end-2),stremain(end-1),stremain(end)-1);
                    end
                else
                    heights(ind-1) = get_new_height(stremain(ind-2),stremain(ind-1),stremain(ind)-1);
                    heights(ind) = get_new_height(stremain(ind-1),stremain(ind),stremain(ind+1)-1);
                end
            end
            k = k+1;
            L = length(stremain);
            display(['Number of steps remaining: ' num2str(L)])
        end
    end
    sequence = sequence(1:k,:);
    display('Step-by-step step removal done.')
    
    function nh = get_new_height(a,b,c)
        %nh = abs(median(trace(max(a,b-100):b-1))-median(trace(b:min(b+100,c))));
        nh = abs(nanmedian(trace(a:b-1))-nanmedian(trace(b:c)));
    end
end
