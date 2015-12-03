function [ intensity_edges, dist_vals_chm, dist_vals_map, coverage] = get_distribution( bound_states_data )
%GET_DISTRIBUTION of values contained in bound_states_data
%   For intensity bins of width W, return mean, median, standard
%   deviation, min, max and number of data points contained in each bin.
%   2-D intensity binning for distance from mapped attachment point.

W = 100;

intensity_edges = cell(1,2);

for ch=1:2
    intensity_edges{ch} = (floor(min(bound_states_data(:,ch))/W):ceil(max(bound_states_data(:,ch))/W)).*W;
end

coverage = cell(1,2);
coverage{1} = zeros(size(intensity_edges{1})-1);
coverage{2} = zeros(length(intensity_edges{1})-1,length(intensity_edges{2})-1);
dist_vals_chm = zeros(length(intensity_edges{1})-1,5,6);
dist_vals_map = zeros(length(intensity_edges{1})-1,5,length(intensity_edges{2})-1);

% fill dist_vals_chm
for i = 1:size(dist_vals_chm,1)
    tmp_states_data = bound_states_data(bound_states_data(:,1)>intensity_edges{1}(i) & bound_states_data(:,1)<=intensity_edges{1}(i+1),:);
    coverage{1}(i) = size(tmp_states_data,1); % number of rows in tmp_states_data = number of data points in interval.
    if ~isempty(tmp_states_data)
        for dv = 1:6
            dist_vals_chm(i,1,dv) = mean(tmp_states_data(:,dv+2));
            dist_vals_chm(i,2,dv) = median(tmp_states_data(:,dv+2));
            dist_vals_chm(i,3,dv) = std(tmp_states_data(:,dv+2));
            dist_vals_chm(i,4,dv) = min(tmp_states_data(:,dv+2));
            dist_vals_chm(i,5,dv) = max(tmp_states_data(:,dv+2));
        end
    end
end

% fill dist_vals_map
for i = 1:size(dist_vals_map,1)
    for j = 1:size(dist_vals_map,3)
        tmp_states_data = bound_states_data(bound_states_data(:,1)>intensity_edges{1}(i) & bound_states_data(:,1)<=intensity_edges{1}(i+1) ...
                        & bound_states_data(:,2)>intensity_edges{2}(j) & bound_states_data(:,2)<=intensity_edges{2}(j+1),:);
        coverage{2}(i,j) = size(tmp_states_data,1); % number of rows in tmp_states_data = number of data points in interval.
        if ~isempty(tmp_states_data)
            dist_vals_map(i,1,j) = mean(tmp_states_data(:,dv+2));
            dist_vals_map(i,2,j) = median(tmp_states_data(:,dv+2));
            dist_vals_map(i,3,j) = std(tmp_states_data(:,dv+2));
            dist_vals_map(i,4,j) = min(tmp_states_data(:,dv+2));
            dist_vals_map(i,5,j) = max(tmp_states_data(:,dv+2));
        end
    end
end

end

