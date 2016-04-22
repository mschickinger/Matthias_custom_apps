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
    steps_cell{2} = p.Results.steps(dv==-1); % downward steps
    steps_cell{1} = p.Results.steps(dv==1); % upward steps
    
    % remove consecutive same direction steps
    for s = 1:2
        % first entry (i=1)
        tmp_ceil = min(steps_cell{1+(s==1)}(steps_cell{1+(s==1)}>steps_cell{s}(1)));
        while sum(steps_cell{s}>=steps_cell{s}(1) & steps_cell{s}<tmp_ceil)>1
            steps_cell{s} = remove_lps(trace, steps_cell{s}, [1 tmp_ceil-1]);
        end

        i = 2;
        while i < length(steps_cell{s})
            tmp_floor = max(steps_cell{1+(s==1)}(steps_cell{1+(s==1)}<steps_cell{s}(i)));
            tmp_ceil = min(steps_cell{1+(s==1)}(steps_cell{1+(s==1)}>steps_cell{s}(i)));
            while sum(steps_cell{s}>tmp_floor & steps_cell{s}<tmp_ceil)>1
                steps_cell{s} = remove_lps(trace, steps_cell{s}, [tmp_floor tmp_ceil-1]);
            end
            i = i+1;
        end
    end
    
    % create output
    steps_no_stairs = sort(vertcat(steps_cell));
end