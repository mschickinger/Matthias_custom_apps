% need a function or script that executes 'calculate_states' for all result
% structures in a hop structure and finishes with combining all lifetimes
% from... each movie? the whole dataset? ... need to think about this.
% probably both.

% the start should go like this:

for m = 1:length(hop.results)
    for s = 1:length(hop.results{m})
        tmp = hop.results{m}{s};
        [tmp.hi, tmp.lo, tmp.Tu, tmp.Tb, tmp.state_trace] = ...
            calculate_states(tmp.steps, tmp.steptrace, tmp.ex_int, hop.tpf{m});
        hop.results{m}{s} = tmp;
    end
end

% Idea:

lifetimes.movie = cell(size(hop.results));
for m = 1:length(lifetimes.movie)
    lifetimes.movie{m}.Tu = [];
    lifetimes.movie{m}.Tb = [];
end
lifetimes.all = []; %combine all lifetimes here