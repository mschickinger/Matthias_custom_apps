function [ metric, norm_factors ] = plot_metric_by_intensity_bins( correlations, pos_RMSD, frames_in_bin, N_frames_in_bin, intensity_edges, behaviour, data_dir )
%CLUSTER_BY_INTERVAL Assign data points to clusters by intensity intervals
%   Detailed explanation goes here

N_intervals = size(frames_in_bin{1},2);

norm_exclude = [1 5];

metric = cell(1,N_intervals);
for i = 1:N_intervals
    metric{i} = zeros(sum(N_frames_in_bin{1}(:,i)),2);
end
norm_factors = zeros(2, N_intervals);

data_path = uigetdir(data_dir);
plot_dir = [data_path filesep 'cluster_plots'];
mkdir(plot_dir)

XLIM = [0 1];
YLIM = [0 1];

for i = 1:N_intervals
    n = 0;
    for s = find(behaviour==2)'
        if N_frames_in_bin{1}(s,i) > 0
            metric{i}(n+1:n+N_frames_in_bin{1}(s,i),1) = correlations{s}(frames_in_bin{1}{s,i},5);
            metric{i}(n+1:n+N_frames_in_bin{1}(s,i),2) = pos_RMSD{s}(frames_in_bin{1}{s,i},5);

            n = n + N_frames_in_bin{1}(s,i);
        end
    end

    % remove NaN and overshoot values
    metric{i} = metric{i}(~isnan(metric{i}(:,1)) & metric{i}(:,2) < norm_exclude(2), : );
    if ~isempty(metric{i})
        for j = 1:2
            norm_factors(j,i) = 1/(nanmax(metric{i}(metric{i}(:,j)<=norm_exclude(j),j)));
            metric{i}(:,j) = metric{i}(:,j).*norm_factors(j,i);
        end
        close all
        figure('Units', 'normalized', 'OuterPosition', [0 0 1 1], 'PaperPositionMode', 'auto')

        % make plot
        subplot('Position', [.05 .075 .7 .7])
        plot(metric{i}(:,1),metric{i}(:,2),'.', 'MarkerSize', 5)
        xlabel('correlation')
        ylabel('RMS')
        xlim(XLIM)
        ylim(YLIM)
        grid on

        subplot('Position', [.05 .8 .7 .19])
        hist(metric{i}(:,1),100)
        set(gca, 'XGrid', 'on')
        h1 = findobj(gca, 'Type', 'patch');
        set(h1, 'FaceColor', [0 0.4470 0.7410])
        xlim(XLIM)

        subplot('Position', [.775 .075 .2 .7])
        hist(metric{i}(:,2),100)
        set(gca, 'view', [90 -90], 'XGrid', 'on')
        h2 = findobj(gca, 'Type', 'patch');
        set(h2, 'FaceColor', [0 0.4470 0.7410])
        xlim(XLIM)

        subplot('Position', [.8 .8 .19 .05])
        axis off
        title(sprintf('Interval %d \n intensities %d to %d \n Number of datapoints: %d', i, intensity_edges{1}(i), intensity_edges{1}(i+1), length(metric{i})));

        print('-dpng', '-r150', [plot_dir filesep 'interval' num2str(i) '.png'])
    end
end

end
        