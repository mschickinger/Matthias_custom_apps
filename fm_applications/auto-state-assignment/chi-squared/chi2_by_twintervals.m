function [steps_raw, steps, ratioS] = chi2_by_twintervals(trace, varargin)
% Step-by-step step determination with chi-squared method
% New approach (May 1st 2016): Optimize individual intervals, not entire
% time trace
    
    % parse input
    p = inputParser;
    addRequired(p, 'trace', @isnumeric);
    addOptional(p, 'N_max', 1000, @isnumeric);
    addOptional(p, 'ratio_min', 0.99, @isnumeric);

    parse(p,trace, varargin{:});
    trace = p.Results.trace;
    N_max = p.Results.N_max;
    ratio_min = p.Results.ratio_min;

    steps_raw = zeros(N_max,1); % positions of steps
    steps = steps_raw;
    
    % quality control arrays: ratioS
    ratioS = zeros(N_max,3);
    
    display('looking for starting step pair...')
    % find starting pair (most prominent in entire trace)
    steps_raw(1:2) = find_2mps(trace);
    steps(1:2) = sort(steps_raw(1:2));
    N = 2;

    display('found starting step pair.')
 
    % set all plateau intervals as open

    offen = zeros(N_max,1);
    offen(1:2) = 1;
    offEND = 1;
 
    % keep adding steps until all intervals are closed  
    while any(offen) && N<=N_max
        counter = N;
        N_plateaus = N+1;
        offen_plateaus = find(offen)';
        if offen(1)
            add_twinsteps(1,steps(1)-1);
            if N>counter
                offen(counter+1:N) = 1;
                counter = N;
            else
                offen(1) = 0;
            end
            offen_plateaus(1) = [];
        end
        for i=offen_plateaus
            add_twinsteps(steps(i-1)+1,steps(i)-1);
            if N>counter
                offen(counter+1:N) = 1;
            else
                offen(i) = 0;
            end
            counter = N;
        end
        if offEND
            add_twinsteps(steps(N_plateaus-1),length(trace));
            if N>counter
                offen(counter+1:N) = 1;
            else
                offEND = 0;
            end
        end
        [steps(1:N), indices] = sort(steps(1:N));
        offen(1:N) = offen(indices);
        ratioS(1:N,:) = ratioS(indices,:);
        display(['Current number of steps is: ' num2str(N) ...
            ', number of open intervals is: ' num2str(sum(offen)+offEND)])
    end
    steps_raw = steps_raw(1:N);
    steps = steps(1:N);
    ratioS = ratioS(1:N,:);

%     % eliminate all stairs
%     steps_raw = steps_raw(1:N);
%     if length(steps_raw)>2
%         steps = eliminate_stairs(trace,steps_raw);
%         tmp = length(steps);
%         go_on = 1;
%         while go_on
%             steps = eliminate_stairs(trace, steps);
%             go_on = length(steps)<tmp;
%             tmp = length(steps);
%         end
%     else
%         steps = steps_raw;
%     end
    display(['Final number of steps is: ' num2str(length(steps))])
    display(['Maximum step frame number: ' num2str(max(steps))])
   
    function add_twinsteps(startFrame,endFrame)
        tmp_trace = trace(startFrame:endFrame);
        step2 = find_2mps(tmp_trace);
        cs2 = get_chi2(tmp_trace, step2);
        tmp_cs = get_chi2(tmp_trace);
        if cs2/tmp_cs < ratio_min
            steps(N+1:N+2) = step2 + startFrame - 1;
            steps_raw(N+1:N+2) = steps(N+1:N+2);
            ratioS(N+1:N+2,1) = cs2/tmp_cs;
            N = N + 2;
        end
    end

end
