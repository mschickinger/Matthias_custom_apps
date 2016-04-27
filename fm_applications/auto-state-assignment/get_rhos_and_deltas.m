function [ rhos, deltas, nearest_pwhd ] = get_rhos_and_deltas( metric, cutoff_distance)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

rhos = zeros(length(metric),1);
deltas = zeros(length(metric),1);
nearest_pwhd = zeros(length(metric),1);
distances = zeros(length(metric),1);
delta_max = 0;

for m = 1:length(rhos)
    distances = sqrt((metric(m,1).*ones(size(distances)) - metric(:,1)).^2 + (metric(m,2).*ones(size(distances)) - metric(:,2)).^2);
    rhos(m) = sum(distances <= cutoff_distance) - 1;
    delta_max = max(delta_max, max(distances));
end
for m = 1:length(deltas)
    pwhd = find(rhos>rhos(m));
    if isempty(pwhd)
        deltas(m) = delta_max;
        nearest_pwhd(m) = m;
    else
        distances_pwhd = sqrt((metric(m,1).*ones(length(pwhd),1) - metric(pwhd,1)).^2 + (metric(m,2).*ones(length(pwhd),1) - metric(pwhd,2)).^2);
        [delta_min, index] = min(distances_pwhd);
        deltas(m) = delta_min(1);
        nearest_pwhd(m) = pwhd(index(1));
    end
end

end

