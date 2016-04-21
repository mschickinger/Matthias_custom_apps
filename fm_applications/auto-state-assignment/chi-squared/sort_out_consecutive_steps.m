%% up and down steps
dv = sign(levels(2:end)-levels(1:end-1));
steps_cell{2} = steps(dv==-1); % downward steps
steps_cell{1} = steps(dv==1); % upward steps
steps_cell_raw = steps_cell;
%% remove consecutive same direction steps

for s = 1:2
    % first entry (i=1)
    tmp_steps = steps_cell{s};
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