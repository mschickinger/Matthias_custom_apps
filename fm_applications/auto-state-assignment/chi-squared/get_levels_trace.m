function [ levels, step_trace ] = get_levels_trace( trace, steps )
% self-explanatory. sub-function for step finding stuff
    
    steps = sort(steps);
    levels(length(steps)+1) = mean(trace(steps(end):end));
    step_trace = levels(end)*ones(length(trace),1);
    levels(1) = mean(trace(1:steps(1)-1));
    step_trace(1:steps(1)-1) = levels(1);
    for i = 1:length(steps)-1
        levels(i+1) = mean(trace(steps(i):steps(i+1)-1));
        step_trace(steps(i):steps(i+1)-1) = levels(i+1);
    end

end

