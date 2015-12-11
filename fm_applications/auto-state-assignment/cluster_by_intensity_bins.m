function [ assignment, metric, sample_idx, centers, rhos, deltas, nearest_pwhd, ind, rho_mins, delta_mins, norm_factors, cutoff_distances ] = cluster_by_intensity_bins( correlations, pos_RMSD, frames_in_bin, N_frames_in_bin, behaviour )
%CLUSTER_BY_INTERVAL Assign data points to clusters by intensity intervals
%   Detailed explanation goes here

N_intervals = size(frames_in_bin{1},2);

N_min = 1000;
N_max = 10000;
norm_exclude = [1 5];

assignment = cell(1,N_intervals);
metric = cell(1,N_intervals);
sample_idx = cell(1, N_intervals);
rhos = cell(1, N_intervals);
deltas = cell(1, N_intervals);
nearest_pwhd = cell(1, N_intervals);
for i = 1:N_intervals
    assignment{i} = zeros(sum(N_frames_in_bin{1}(:,i)),3);
    metric{i} = zeros(sum(N_frames_in_bin{1}(:,i)),2);
    sample_idx{i} = zeros(min(sum(N_frames_in_bin{1}(:,i)), 10000),1);
end
norm_factors = zeros(2, N_intervals);
cutoff_distances = zeros(1, N_intervals);
ind = zeros(2,N_intervals);
rho_mins = zeros(1, N_intervals);
delta_mins = zeros(1, N_intervals);

centers = zeros(4, N_intervals,2);

%data_path = uigetdir(data_dir);

for i = 12:N_intervals
    if sum(N_frames_in_bin{1}(:,i)) >= N_min
        display(['Clustering data in interval number ' num2str(i) '...'])
        tic
        n = 0;
        for s = find(behaviour==2)'
            if N_frames_in_bin{1}(s,i) > 0
                assignment{i}(n+1:n+N_frames_in_bin{1}(s,i),1) = s.*ones(N_frames_in_bin{1}(s,i),1);
                assignment{i}(n+1:n+N_frames_in_bin{1}(s,i),2) = frames_in_bin{1}{s,i};
                metric{i}(n+1:n+N_frames_in_bin{1}(s,i),1) = correlations{s}(frames_in_bin{1}{s,i},5);
                metric{i}(n+1:n+N_frames_in_bin{1}(s,i),2) = pos_RMSD{s}(frames_in_bin{1}{s,i},5);
                
                n = n + N_frames_in_bin{1}(s,i);
            end
        end
        
        % remove NaN and overshoot values
        assignment{i} = assignment{i}(~isnan(metric{i}(:,1)) & metric{i}(:,2) < norm_exclude(2),:);
        metric{i} = metric{i}(~isnan(metric{i}(:,1)) & metric{i}(:,2) < norm_exclude(2), : );
        if length(metric{i}) >= N_min
            for j = 1:2
                norm_factors(j,i) = 1/(nanmax(metric{i}(metric{i}(:,j)<=norm_exclude(j),j)));
                metric{i}(:,j) = metric{i}(:,j).*norm_factors(j,i);
            end
            
            % get appropriate cutoff distance from a maximum sample of N_max data points
            if length(metric{i}) >= N_max
                [sample, idx] = datasample(metric{i}, N_max);
                sample_idx{i} = idx';
            else
                sample = metric{i};
                sample_idx{i} = 'all';
            end
            [ ~ , cutoff_distances(i)] = get_all_distances(sample, .2);
            display('get_all_distances done')
            toc
            % get densities and deltas
            [ rhos{i}, deltas{i}, nearest_pwhd{i} ] = get_rhos_and_deltas(metric{i}, cutoff_distances(i));
            display('rhos and deltas done')
            toc
            % identify cluster centers
            [ind(:,i), rho_mins(i), delta_mins(i)] = get_2_centers(metric{i}, rhos{i}, deltas{i}, 1000);
            if metric{i}(ind(1,i),2) > metric{i}(ind(2,i),2)
                ind(:,i) = [ind(2,i); ind(1,i)];
            end
            for c = 1:2
                centers(1:2,i,c) = assignment{i}(ind(c,i),1:2)';
                centers(3:4,i,c) = metric{i}(ind(c,i),:)';
            end
            assignment{i}(:,3) = assign_2_clusters(ind(:,i), nearest_pwhd{i}, rhos{i}, deltas{i}, rho_mins(i), delta_mins(i), metric{i});
        else
            display(['Interval number ' num2str(i) ': Number of non-NaN RMS data points < N_min. No clustering attempted.'])
            assignment{i} = 'Number of non-NaN RMS data points < N_min. No clustering attempted.';
        end
    else
        display(['Interval number ' num2str(i) ' N_frames < N_min. No clustering attempted.'])
        assignment{i} = 'N_frames < N_min. No clustering attempted.';    
    end
end
    

end

