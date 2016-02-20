%% startup
close all, clear all, clc
run('my_prefs.m')
%% load gel data
gelData_raw = load_gel_image('data_dir', '/Users/matthiasschickinger/PhD/Gels/', 'n_images', 1);

%%
[gelData_raw] = check_gel_saturation(gelData_raw);

%% background correct data
gelData = background_correct_gel_image(gelData_raw, 'numberOfAreas', 4);

%% rotate image
gelData = rotate_gel_image(gelData);

%% integrate bands
bands = get_band_intensities(gelData);

%% calculate sums and ratios
bands.sums = bands.intensities(1:2:end) + bands.intensities(2:2:end);
bands.ratios = bands.intensities(2:2:end)./bands.sums;

%% create output dir
prefix_out = [gelData.filenames{1}(1:end-4) '_bands-analysis_' datestr(now, 'yyyy-mm-dd_HH-MM')];
tmp = inputdlg({'Name of analysis (prefix):'}, 'Name of analysis (prefix):' , 1, {prefix_out} );
prefix_out = tmp{1};
path_out = [gelData.pathnames{1} prefix_out filesep];
mkdir(path_out);

%% save data
save([path_out prefix_out '_data.mat'])
display('Data saved.')

%% print plots
figure('Position', [1 1 800 600])

% raw intensities
bar(bands.intensities)
xlabel('band number')
ylabel('integrated intensity')
title('Raw band intensites')
xlim([0 length(bands.intensities)+1])
set(gca, 'XTick', 1:length(bands.intensities))
print('-dpng', '-r96', [path_out 'intensities_raw.png'])

% sum of double band
bar(bands.sums)
xlabel('lane number')
ylabel('Sum of integrated intensity')
title('Sum of double band intensites')
xlim([0 length(bands.sums)+1])
ylim([0 1.1*max(bands.sums)])
set(gca, 'XTick', 1:length(bands.sums))
print('-dpng', '-r96', [path_out 'intensities_sums.png'])

% ratio of leading band over sum of all
bar(bands.ratios)
xlabel('lane number')
ylabel('Intensity ratio')
title('Relative intensity of closed band')
xlim([0 length(bands.ratios)+1])
ylim([0 1])
text(1:length(bands.ratios),bands.ratios',num2str(bands.ratios),'HorizontalAlignment','center','VerticalAlignment','bottom')
set(gca, 'XTick', 1:length(bands.ratios))
print('-dpng', '-r96', [path_out 'intensities_ratios.png'])
