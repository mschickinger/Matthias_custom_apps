
hop.tpf = [50;50;50;50;50;100;50;100;50;100;50;50];

for m = 1:length(hop.results)
    for s = 1:length(hop.results{m})
        if hop.results{m}{s}.todo == 0
            tmp = hop.results{m}{s};
            if ~isempty(hop.results{m}{s}.steps)
                [tmp.hi, tmp.lo, tmp.Tu, tmp.Tb, tmp.state_trace] = ...
                    calculate_states(tmp.steps{end}, tmp.steptraces{end}, tmp.ex_int, hop.tpf(m));
            else
                tmp.hi = []; tmp.lo = []; tmp.Tu = []; tmp.Tb = []; tmp.state_trace = [];
            end
            hop.results{m}{s} = tmp;
        end
    end
end

%% Idea:

lifetimes.movie = cell(size(hop.results));
lifetimes.all.Tu = [];
lifetimes.all.Tb = [];
for m = 1:length(lifetimes.movie)
    lifetimes.movie{m}.Tu = [];
    lifetimes.movie{m}.Tb = [];
    for s = 1:size(hop.results{m},1)
        if isfield(hop.results{m}{s},'Tu')
            lifetimes.movie{m}.Tu = [lifetimes.movie{m}.Tu; hop.results{m}{s}.Tu];
        end
        if isfield(hop.results{m}{s},'Tb')
            lifetimes.movie{m}.Tb = [lifetimes.movie{m}.Tb; hop.results{m}{s}.Tb];
        end
    end
    lifetimes.all.Tu = [lifetimes.all.Tu ; lifetimes.movie{m}.Tu];
    lifetimes.all.Tb = [lifetimes.all.Tb ; lifetimes.movie{m}.Tb];
end
%combine all lifetimes here