function [steps_raw, steps] = chi2_by_intervals(trace, varargin)
% Step-by-step step determination with chi-squared method
% New approach (May 1st 2016): Optimize individual intervals, not entire
% time trace
    
    % parse input
    p = inputParser;
    addRequired(p, 'trace', @isnumeric);
    addOptional(p, 'N_max', 1000, @isnumeric);

    parse(p,trace, varargin{:});
    trace = p.Results.trace;
    N_max = p.Results.N_max;

    steps_raw = zeros(N_max,1); % positions of steps
    
    ratio_min = 1.1;
    display('looking for starting step pair...')
    % find starting pair (most prominent in entire trace)
    tmp = find_2mps(trace);
    steps_raw(1:2) = sort(tmp);
    N = 2;

    display('found starting step pair.')
    
    % fill up to start and end of trace
    go_on = 1;
    counter = N;
    while go_on
        [steps_raw, N] = add_steps(1,steps_raw(1)-1,steps_raw,N);
        steps_raw(1:N) = sort(steps_raw(1:N));
        go_on = (N>counter);
        counter = N;
    end
    display(['done filling up to start. N = ' num2str(N)])
    go_on = 1;
    counter = N;
    while go_on
        start_frame = steps_raw(N)+1;
        if start_frame < length(trace)
            [steps_raw, N] = add_steps(start_frame,length(trace),steps_raw,N);
            steps_raw(1:N) = sort(steps_raw(1:N));
            go_on = (N>counter);
            counter = N;
        else
            go_on = 0;
        end
    end
    display(['done filling up to end. N = ' num2str(N)])

    % set all intervals in between two steps as open

    offen = zeros(N_max-1,1);
    offen(1:N-1) = 1;

    % keep adding steps until all intervals are closed
    counter = N;
    while any(offen) && N<=N_max
        for i=find(offen)'
            [steps_raw, N] = add_steps(steps_raw(i)+1,steps_raw(i+1)-1,steps_raw,N);
            if N>counter
                offen(counter+1:N) = 1;
            else
                offen(i) = 0;
            end
            counter = N;
        end
        [steps_raw(1:N), indices] = sort(steps_raw(1:N));
        offen = offen(indices);
        display(['Current number of steps is: ' num2str(N)])
    end

    % eliminate all stairs
    steps_raw = steps_raw(steps_raw>0);
    steps = eliminate_stairs(trace,steps_raw);
    tmp = length(steps);
    go_on = 1;
    while go_on
        steps = eliminate_stairs(trace, steps);
        go_on = length(steps)<tmp;
        tmp = length(steps);
    end
    display(['Final number of steps is: ' num2str(length(steps))])
    
    function [steps_out,N_out] = add_steps(startFrame,endFrame,steps_in,N_in)
        steps_out = steps_in;      
        [step1, ~, tmp] = find_mps(trace(startFrame:endFrame));
        cs1 = min(tmp);
        step2 = find_2mps(trace(startFrame:endFrame));
        cs2 = get_chi2(trace(startFrame:endFrame), step2);
        tmp = get_chi2(trace(startFrame:endFrame));
        if tmp/min(cs1,cs2)>ratio_min
            if cs2<cs1
                steps_out(N_in+1:N_in+2) = step2 + startFrame - 1;
                N_out = N_in + 2;
            else
                steps_out(N_in+1) = step1 + startFrame - 1;
                N_out = N_in + 1;
            end
        else
            N_out = N_in;
        end
    end
end
