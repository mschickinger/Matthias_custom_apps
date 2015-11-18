%% startup
close all, clear all, clc
run('my_prefs.m')

n_images = str2double(inputdlg('How many scans would you like to compare?', 'Enter n_images', 1, {'4'}));

%{
%% Check for imageData and load, if necessary
if ~exist('gelData', 'var')
    [tmp_filename, tmp_pathname] = uigetfile('/Users/matthiasschickinger/PhD/Gels/*.mat', 'Choose .mat file containing gelData');
    tmp = load([tmp_pathname tmp_filename], 'gelData');
    gelData = tmp.gelData;
end
%}
%% load gel data
gelData_raw = load_gel_image('data_dir', '/Users/matthiasschickinger/PhD/Gels/', 'n_images', n_images);

%%
[gelData_raw, cf] = check_gel_saturation(gelData_raw);
close all

%% background correct data
gelData = background_correct_gel_image(gelData_raw, 'numberOfAreas', 4);

%{
%% adjust of unequal image size
for i = 1:length(gelData.images)
    if any(size(gelData.images{i})-size(gelData.images{end}))
        tmp = ones(size(gelData.images{end}));
        tmp(1:size(gelData.images{i},1),1:size(gelData.images{i},2)) = gelData.images{i};
        gelData.images{i} = tmp;
    end
end
%}

%% Get gel run times
times = cell(n_images,1);
for i = 1:n_images
    times{i} = ['Time ' num2str(i)];
end

default_times = {'1:30','3:00','4:30','6:00'};
default_times = default_times(1:n_images);
times = inputdlg(times, 'Enter gel run times', 1, default_times);

for i = 1:n_images
    times{i} = [times{i} ' h'];
end

%% divide gelData up in individual cell entries
single_gelData = cell(size(gelData.images));
for i = 1:length(gelData.images)
single_gelData{i}.images = {gelData.images{i}};
single_gelData{i}.pathnames = {gelData.pathnames{i}};
single_gelData{i}.filenames = {gelData.filenames{i}};
single_gelData{i}.nrImages = 1;
single_gelData{i}.saturation = gelData.saturation(i);
single_gelData{i}.background = {gelData.background{i}};
end

%% get lanes
lanes = cell(size(single_gelData));
for i = 1:length(lanes)
    lanes{i} = get_gel_lanes(single_gelData{i});
end
n_lanes = length(lanes{1}.profiles);

%% create output dir
prefix_out = [gelData.filenames{1}(1:end-4) '_lanes-analysis_' datestr(now, 'yyyy-mm-dd_HH-MM')];
tmp = inputdlg({'Name of analysis (prefix):'}, 'Name of analysis (prefix):' , 1, {prefix_out} );
prefix_out = tmp{1};    
path_out = [gelData.pathnames{1} prefix_out filesep];
mkdir(path_out);

%% save data
save([path_out 'lanes_data.mat'], 'single_gelData', 'lanes')

%% plot profile comparisons
ctl = strcmp(questdlg('Enter custom lane labels for profile plots?','','Yes'),'Yes');
if ctl
   lane_labels = custom_labels(n_lanes);
else
   lane_labels = cell(n_lanes,1);
   for i = 1:n_lanes
       lane_labels{i} = ['Lane ' num2str(i)];
   end
end
%%
xmax = zeros(n_images,1);
for i = 1:length(xmax)
    xmax(i) = length(lanes{i}.profiles{1});
end
xmax = max(xmax);

close all
figure('Position', scrsz, 'PaperPositionMode', 'auto', 'Visible', 'off')
for i = 1:n_lanes
    for j = 1:n_images
        subplot(n_images,1,j)
        hold off
        plot(lanes{j}.profiles{i})
        hold on
        xlim([0 xmax])
        ylabel('Intensity (a.u.)')
        title([lane_labels{i} ', profile after ' times{j}])
    end
    xlabel('Pixels (25 \mum / px)', 'Interpreter', 'tex')
    suplabel(prefix_out, 't')
    print('-dpng', '-r96', [path_out 'profile_over_time_lane' num2str(i) '.png'])
end
    
