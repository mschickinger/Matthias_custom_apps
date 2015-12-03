% metric for bound state threshold

metric = zeros(size(bound_states_data,1),1);
Nbins_chm = length(intensity_edges_dist{1})-1;
dist_vals_metric = zeros(Nbins_chm,3);
threshold_multiplier = 3;

for i = 1:Nbins_chm
    int_lb = intensity_edges_dist{1}(i);
    int_ub = intensity_edges_dist{1}(i+1);
    tmpI = find(bound_states_data(:,1)>=int_lb & bound_states_data(:,1)<int_ub);
    if ~isempty(tmpI)
        level = ones(length(tmpI),1);
        metric(tmpI) = sqrt(((bound_states_data(tmpI,5)-level.*dist_vals_chm(i,1,3))./dist_vals_chm(i,3,3)).^2 + ...
                                ((bound_states_data(tmpI,6)-level.*dist_vals_chm(i,1,4))./dist_vals_chm(i,3,4)).^2 + ...
                                ((bound_states_data(tmpI,7)-level.*dist_vals_chm(i,1,5))./dist_vals_chm(i,3,5)).^2); %+ ...
                                    %((movie_data{s,1}.vwcm.stDev(tmpI)-level.*dist_vals_chm(i,1,6))./dist_vals_chm(i,3,6)).^2);
        dist_vals_metric(i,1) = mean(metric(tmpI));
        dist_vals_metric(i,2) = std(metric(tmpI));
    end
end

dist_vals_metric(:,3) = dist_vals_metric(:,1)+threshold_multiplier*dist_vals_metric(:,2);