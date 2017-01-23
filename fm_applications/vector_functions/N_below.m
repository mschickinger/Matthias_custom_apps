function [ output ] = N_below (traces,threshs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

N = zeros(1,numel(threshs));
N_all = 0;
threshs = sort(threshs);

for i = 1:length(traces)
    N_all = N_all + nnz(traces{i});
    tmp_trace = fliplr(nonzeros(traces{i}));
    for j = 1:numel(threshs)
        tmpF = find(tmp_trace > threshs(j),1);
        if ~isempty(tmpF)
            N(j) = N(j) + tmpF-1;
        else
            N(j) = N(j) + numel(tmp_trace);
        end
    end
end

output.N = N;
output.N_all = N_all;
output.threshs = threshs;
end

