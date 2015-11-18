%% startup
close all, clear all, clc
run('my_prefs.m')

n_data = str2double(inputdlg('How many time data would you like to compare?', 'Enter n_data', 1, {'4'}));
bands_over_time = cell(n_data,1);
for i = 1:n_data
    [tmp_filename, tmp_pathname] = uigetfile('/Users/matthiasschickinger/Public/Gels_SG/*.mat', 'Choose .mat file containing bandsets');
    tmp = load([tmp_pathname tmp_filename], 'bandsets');
    bands_over_time{i} = tmp.bandsets;
end

%% Get gel run times
times = cell(n_data,1);
for i = 1:n_data
    times{i} = ['Time ' num2str(i) ' (h:mm)'];
end

default_times = {'1:30','3:00','4:30','6:00'};  
default_times = default_times(1:n_data);
times = inputdlg(times, 'Enter gel run times', 1, default_times);

for i = 1:n_data
    times{i} = [times{i} ' h'];
end

%% reshape data for plots
n_lanes = size(bands_over_time{1}.sums,1);
means.intensities = zeros(2*n_lanes,n_data);
means.sums = zeros(n_lanes,n_data);
means.ratios = zeros(n_lanes,n_data);

stdevs.intensities = zeros(2*n_lanes,n_data);
stdevs.sums = zeros(n_lanes,n_data);
stdevs.ratios = zeros(n_lanes,n_data);

for i = 1:n_data
    means.intensities(:,i) = mean(bands_over_time{i}.intensities,2);
    means.sums(:,i) = mean(bands_over_time{i}.sums,2);
    means.ratios(:,i) = mean(bands_over_time{i}.ratios,2);
    
    stdevs.intensities(:,i) = std(bands_over_time{i}.intensities.')';
    stdevs.sums(:,i) = std(bands_over_time{i}.sums.')';
    stdevs.ratios(:,i) = std(bands_over_time{i}.ratios.')';
end

%% create output dir
filesep_index = find(tmp_pathname=='/',2,'last');
filesep_index = filesep_index(1);
prefix_out = [tmp_pathname(filesep_index+1:strfind(tmp_pathname, 'bands')-2) '_bands-over-time_' datestr(now, 'yyyy-mm-dd_HH-MM')];
tmp = inputdlg({'Name of analysis (prefix):'}, 'Name of analysis (prefix):' , 1, {prefix_out} );
prefix_out = tmp{1};    
path_out = [tmp_pathname(1:filesep_index) prefix_out filesep];
mkdir(path_out);

%% save data
save([path_out 'bands_data.mat'], 'means', 'stdevs')

%% plot band values over gel run time
ctl = strcmp(questdlg('Enter custom lane labels for bands-over-time plots?','','Yes'),'Yes');
if ctl
   use_default = questdlg('Use default values?','','Excess', 'Length', 'None', 'None');
   switch use_default
       case 'Excess'
           lane_labels = {'linked', '0,25x', '0,5x', 'linked', '0,75x', '1,0x', '1,25x', '1,5x', 'linked', '2,0x', '2,5x', '5,0x', '10x', 'linked', '20x', 'linked'};
       case 'Length'
           lane_labels = {'linked', 'linked', 'linked', 'i9', 'linked', 'linked', 'i10', 'linked'};
       case 'None'
           lane_labels = custom_labels(n_lanes);
   end
else
   lane_labels = cell(n_lanes,1);
   for i = 1:n_lanes
       lane_labels{i} = ['Lane ' num2str(i)];
   end
end

close all
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto', 'Visible', 'on')
for i = 1:n_lanes
    subplot(2,1,1)
    hold off
    errorbar(means.intensities(2*i-1,:),3*stdevs.intensities(2*i-1,:))
    hold on
    errorbar(means.intensities(2*i,:),3*stdevs.intensities(2*i,:))
    errorbar(means.sums(i,:),3*stdevs.sums(i,:))
    xlabel('Gel run time')
    ylabel('Intensity (a.u.)')
    set(gca, 'XTick', 1:length(times), 'XTickLabel', times, 'YGrid', 'on');
    legend({'Trailing band', 'Leading band', 'Sum'})
    title([prefix_out ' , lane #' num2str(i) ' , ' lane_labels{i}])
    
    subplot(2,1,2)
    hold off
    errorbar(means.ratios(i,:),3*stdevs.ratios(i,:),'k')
    legend({'Ratio leading:sum'})
    xlabel('Gel run time')
    ylabel('Ratio')
    ylim([0.9*min(means.ratios(i,:)-3*stdevs.ratios(i,:)) 1.1*max(means.ratios(i,:)+3*stdevs.ratios(i,:))])
    set(gca, 'XTick', 1:length(times), 'XTickLabel', times, 'YTick', 0:.05:1, 'YGrid', 'on');
    print('-dpng', '-r96', [path_out 'intensities_over_time_lane' num2str(i) '.png'])
end
    
