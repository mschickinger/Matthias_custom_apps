% cluster in intervals

%index = 20;
ch = 1;
close all
figure('Units', 'normalized', 'Position', [0 0 1 1])
plot_index = 1;
for index = 26:-1:15
    correlation = zeros(sum(N_frames_in_bin{ch}(:,index)),1);
    RMSD = zeros(sum(N_frames_in_bin{ch}(:,index)),1);
    r = zeros(sum(N_frames_in_bin{ch}(:,index)),1);
    n = 0;
    for s = find(behaviour==2)'
        if N_frames_in_bin{ch}(s,index) > 0
            correlation(n+1:n+N_frames_in_bin{ch}(s,index)) = corr_pos0_rev_med{m}{s}(frames_in_bin{ch}{s,index},5);
            RMSD(n+1:n+N_frames_in_bin{ch}(s,index)) = pos_RMSD{m}{s}(frames_in_bin{ch}{s,index},5);
            r(n+1:n+N_frames_in_bin{ch}(s,index)) = data{m}{s,ch}.vwcm.r(frames_in_bin{ch}{s,index});
            n = n + N_frames_in_bin{ch}(s,index);
        end
    end
    subplot(3,4,plot_index)
    scatter3(RMSD, correlation, r, '.')%, 'MarkerSize', 4)
    xlabel('RMSD')
    ylabel('correlations, medfilt')
    zlabel('r')
    title(['Index: ' num2str(index) ' , ' num2str(intensity_edges{ch}(index)) ' to ' num2str(intensity_edges{ch}(index+1)) ' , ' num2str(sum(N_frames_in_bin{ch}(:,index))) ' frames.'])
    xlim([0 5])
    ylim([0 1])
    zlim([0 5])
    plot_index = plot_index + 1;
end
