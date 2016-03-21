function [ind, rho_min, delta_min] = get_2_centers( metric, rhos, deltas, N_space )
%GET_2_CENTERS Finds the two cluster centers with the highest delta above a
%   dynamic rho threshold.

ind = [0;0];
[~, ind(1)] = max(deltas);

same_rho_pts = find(rhos == rhos(ind(1)));
same_rho_pts = same_rho_pts(same_rho_pts~=ind(1));
rhos(same_rho_pts) = rhos(ind(1)) - 0.5;
for m = same_rho_pts'
    pwhd = find(rhos>rhos(m));
    distances_pwhd = sqrt((metric(m,1).*ones(length(pwhd),1) - metric(pwhd,1)).^2 + (metric(m,2).*ones(length(pwhd),1) - metric(pwhd,2)).^2);
    deltas(m) = min(distances_pwhd);
end

rhospace = linspace(min(rhos),max(rhos),N_space);
deltaspace = linspace(min(deltas),max(deltas),N_space);
counts = zeros(N_space,1);

tic
for j = 1:N_space
    counts(j) = sum((deltas>deltaspace(j))&(rhos>rhospace(j)));
end

toc
tmp = find(counts>1, 1, 'last');
cherries = find((deltas>deltaspace(tmp)) & (rhos>rhospace(tmp)));
cherries = cherries(cherries~=ind(1));
[~ , indices] = max(deltas(cherries));
cherries = cherries(indices);
[~ , indices] = max(rhos(cherries));
cherries = cherries(indices);
ind(2) = cherries(1);

% "up"
for j = 1:N_space
    counts(j) = sum((deltas>deltaspace(j))&(rhos>rhospace(tmp)));
end
tmp = find(counts>1, 1, 'last');
% "left"
for j = 1:N_space
    counts(j) = sum((deltas>deltaspace(tmp))&(rhos>rhospace(j)));
end
tmp = find(counts>1, 1, 'last');
rho_min = rhospace(tmp);
% "down"
for j = 1:N_space
    counts(j) = sum((deltas>deltaspace(j))&(rhos>rho_min));
end
delta_min = deltaspace(find(counts>1, 1, 'last'));
end

