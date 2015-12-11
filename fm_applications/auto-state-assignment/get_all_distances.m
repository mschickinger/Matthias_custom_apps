function [ distances, cutoff_distance ] = get_all_distances( metric, fraction )
%GET_ALL_DISTANCES 
%   For a matrix of Nxm metric values, all distances between data points are
%   calculated and stored in an NxN matrix.
%   A characteristc cutoff distance is determined as the radius around the 
%   point of highest density that encompasses the percentage of data points 
%   given by variable "fraction", (e.g. 10% -> 0.1)

fraction_index = round(size(metric,1)*fraction);

distances = zeros(size(metric,1));
cutoff_distance = norm(max(metric)-min(metric));

% Cross-reference all distances
for i = 1:size(distances,1)
    distances(i+1:end,i) = sqrt((metric(i,1).*ones(size(metric,1)-i,1) - metric(i+1:end,1)).^2 + (metric(i,2).*ones(size(metric,1)-i,1) - metric(i+1:end,2)).^2);
    distances(i,i+1:end) = distances(i+1:end,i)';
end

for i = 1:size(distances,1)
    tmp_dist = sort(distances(i,:));
    cutoff_distance = min(cutoff_distance, tmp_dist(fraction_index));
end

end

