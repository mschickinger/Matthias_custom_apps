function [ steps_no_stairs ] = eliminate_stairs ( trace, steps, varargin )

    % parse input
    p = inputParser;
    addRequired(p, 'trace', @isnumeric);
    addRequired(p, 'steps', @isnumeric);
    addOptional(p, 'levels', [], @isnumeric);

    parse(p,trace, steps, varargin{:});
    
    % preparation of data
    trace = p.Results.trace;
    if isempty(p.Results.levels)
        levels = get_levels(trace,p.Results.steps);
    else
        levels = p.Results.levels;
    end
    
    % up and down steps
    dv = sign(levels(2:end)-levels(1:end-1));
    steps_cell{2} = reshape(p.Results.steps(dv==-1),sum(dv==-1),1); % downward steps
    steps_cell{1} = reshape(p.Results.steps(dv==1),sum(dv==1),1); % upward steps
    L = length(steps_cell{1}) + length(steps_cell{2});
    
    % remove consecutive same direction steps
    go_on = 1;
    while go_on
        for s = 1:2
            % first entry (i=1)
            tmp_ceil = min(steps_cell{1+(s==1)}(steps_cell{1+(s==1)}>steps_cell{s}(1)));
            if isempty(tmp_ceil)
                tmp_ceil = length(trace)+1;
            end
            while sum(steps_cell{s}>=steps_cell{s}(1) & steps_cell{s}<tmp_ceil)>1
                steps_cell{s} = remove_lps(trace, steps_cell{s}, [1 tmp_ceil-1]);
            end

            i = 2;
            while i < length(steps_cell{s})
                tmp_floor = max(steps_cell{1+(s==1)}(steps_cell{1+(s==1)}<steps_cell{s}(i)));
                tmp_ceil = min(steps_cell{1+(s==1)}(steps_cell{1+(s==1)}>steps_cell{s}(i)));
                if isempty(tmp_ceil)
                    tmp_ceil = length(trace)+1;
                end
                while sum(steps_cell{s}>tmp_floor & steps_cell{s}<tmp_ceil)>1
                    steps_cell{s} = remove_lps(trace, steps_cell{s}, [tmp_floor tmp_ceil-1]);
                end
                i = i+1;
            end
        end
        steps_no_stairs = sort(vertcat(steps_cell{:}));
        go_on = L > length(steps_no_stairs);
        if go_on
            levels = get_levels(trace, steps_no_stairs);
            dv = sign(levels(2:end)-levels(1:end-1));
            steps_cell{2} = steps_no_stairs(dv==-1); % downward steps
            steps_cell{1} = steps_no_stairs(dv==1); % upward steps
            L = length(steps_no_stairs);
        end
    end
end