function [ assigned_cluster ] = assign_2_clusters( ind, nearest_pwhd, rhos, deltas, rho_min, delta_min, metric)
%ASSIGN_TO_CLUSTER
%   This function sorts all data points above a certain rho and delta
%   threshold into two clusters with predefined centers. The first step is
%   to find data points whose nearest neighbour with higher density are
%   the cluster centers. In every iteration that follows, data points are
%   found whose nearest neighbour with higher density is among those data
%   points added in the previous step.

[V,I] = sort(rhos(ind));
nearest_pwhd(rhos == V(2)) = ind(I(2));
same_rho_pts = find(rhos == V(1));
same_rho_pts = same_rho_pts(same_rho_pts~=ind(I(1)));
rhos(same_rho_pts) = V(1) - 0.5;
for m = same_rho_pts'
    pwhd = find(rhos>rhos(m));
    distances_pwhd = sqrt((metric(m,1).*ones(length(pwhd),1) - metric(pwhd,1)).^2 + (metric(m,2).*ones(length(pwhd),1) - metric(pwhd,2)).^2);
    [~, index] = min(distances_pwhd);
    nearest_pwhd(m) = pwhd(index(1));
end
nearest_pwhd(ind) = 0;

assigned_cluster = zeros(length(nearest_pwhd),1);

% 1st step
assigned_cluster(ind(1)) = 1;
assigned_cluster(ind(2)) = 2;

new1 = find(nearest_pwhd == ind(1));

new2 = find(nearest_pwhd == ind(2));

N_new = length(new1) + length(new2);

assigned_cluster(new1) = 1;
assigned_cluster(new2) = 2;

while N_new > 0
    tmp = find(ismember(nearest_pwhd, new1));
    tmp(rhos(tmp)<rho_min & deltas(tmp)>delta_min) = [];
    new1 = tmp;

    tmp = find(ismember(nearest_pwhd, new2));
    tmp(rhos(tmp)<rho_min & deltas(tmp)>delta_min) = [];
    new2 = tmp;

    N_new = length(new1) + length(new2);
    disp(N_new)
    assigned_cluster(new1) = 1;
    assigned_cluster(new2) = 2;
    display(['Cluster 1: ' num2str(sum(assigned_cluster==1)) ', Cluster 2: ' num2str(sum(assigned_cluster == 2))])
end

end

