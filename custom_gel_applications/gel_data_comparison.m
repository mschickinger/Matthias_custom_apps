%% startup
close all, clear all, clc
run('my_prefs.m')
%% load gel data
datasets.num = str2double(inputdlg('How many datasets would you like to compare?', 'Number of datasets', 1, {'5'}));
datasets.filenames = cell(1,datasets.num);
datasets.pathnames = cell(1,datasets.num);
for i = 1:datasets.num
   [datasets.filenames{i}, datasets.pathnames{i}] = uigetfile('/Users/matthiasschickinger/PhD/Gels/*.mat', ['Select MATLAB data file #' num2str(i)]); 
end

% Check for doubly occuring data
duplicity = 0;
for i = 1:datasets.num
    for j = i+1:datasets.num
        if strcmp(datasets.filenames{i}, datasets.filenames{j}) && strcmp(datasets.pathnames{i}, datasets.pathnames{j})
            display(['WARNING: Detected duplicity in datasets #' num2str(i) ' and #' num2str(j) '.'])
            duplicity = 1;
        end
    end
end
if duplicity
    display('No duplicity in datasets. Proceed.')
end

% Get data from bands structs
tmp = load([datasets.pathnames{1} datasets.filenames{1}], 'bands');
bandsets.intensities = [tmp.bands.intensities zeros(length(tmp.bands.intensities),datasets.num-1)];
for i = 2:datasets.num 
    tmp = load([datasets.pathnames{i} datasets.filenames{i}], 'bands');
    bandsets.intensities(:,i) = tmp.bands.intensities;
end

%% calculate sums and ratios
bandsets.sums = zeros(size(bandsets.intensities,1)./2,datasets.num);
bandsets.ratios = zeros(size(bandsets.intensities,1)./2,datasets.num);

for i = 1:datasets.num
    bandsets.sums(:,i) = bandsets.intensities(1:2:end,i) + bandsets.intensities(2:2:end,i);
    bandsets.ratios(:,i) = bandsets.intensities(2:2:end,i)./bandsets.sums(:,i);
end

%% Evaluate medians and errors
bandsets.medians.intensities = zeros(size(bandsets.intensities,1),1);
bandsets.medians.sums = zeros(size(bandsets.sums,1),1);
bandsets.medians.ratios = zeros(size(bandsets.ratios,1),1);

bandsets.errors.intensities = zeros(size(bandsets.intensities,1),1);
bandsets.errors.sums = zeros(size(bandsets.sums,1),1);
bandsets.errors.ratios = zeros(size(bandsets.ratios,1),1);

bandsets.stDevs.intensities = zeros(size(bandsets.intensities,1),1);
bandsets.stDevs.sums = zeros(size(bandsets.sums,1),1);
bandsets.stDevs.ratios = zeros(size(bandsets.ratios,1),1);

% Intensities
for i = 1:size(bandsets.medians.intensities,1)
    bandsets.medians.intensities(i) = median(bandsets.intensities(i,:));
    bandsets.errors.intensities(i) = max(abs(bandsets.intensities(i,:) - bandsets.medians.intensities(i)));
    bandsets.stDevs.intensities(i) = std(bandsets.intensities(i,:));
end
% Sums
for i = 1:size(bandsets.medians.sums,1)
    bandsets.medians.sums(i) = median(bandsets.sums(i,:));
    bandsets.errors.sums(i) = max(abs(bandsets.sums(i,:) - bandsets.medians.sums(i)));
    bandsets.stDevs.sums(i) = std(bandsets.sums(i,:));
end
% Ratios
for i = 1:size(bandsets.medians.ratios,1)
    bandsets.medians.ratios(i) = median(bandsets.ratios(i,:));
    bandsets.errors.ratios(i) = max(abs(bandsets.ratios(i,:) - bandsets.medians.ratios(i)));
    bandsets.stDevs.ratios(i) = std(bandsets.ratios(i,:));
end
%% create output dir
path_out = [datasets.pathnames{1}(1:end-19) '-comparison_' datestr(now, 'yyyy-mm-dd_HH-MM') filesep];
%tmp = inputdlg({'Name of analysis (prefix):'}, 'Name of analysis (prefix):' , 1, {prefix_out} );
%prefix_out = tmp{1};
tmp = find(datasets.pathnames{1} == filesep, 2, 'last');
tmp = tmp(1);
%path_out = [datasets.pathnames{1}(1:tmp-1) filesep prefix_out filesep];
mkdir(path_out);
prefix_out = path_out(tmp+1:end-1);

%% save data
save([path_out 'data-comparison_results.mat'], 'datasets', 'bandsets')
display('Data comparison results saved.')

%% print plots
% one cell for intensity, one for sums and one for ratios
% possible to enter custom tick labels
%% Intensities comparison
ctl = strcmp(questdlg('Enter custom XTick Labels for intensity plots?','','No'),'Yes');
if ctl  
   use_default = questdlg('Use default values?','','Excess', 'Length', 'None', 'None');
   switch use_default
       case 'Excess'
           xtlabels = {'linked', '0,25x', '0,5x', 'linked', '0,75x', '1,0x', '1,25x', '1,5x', 'linked', '2,0x', '2,5x', '5,0x', '10x', 'linked', '20x', 'linked'};
       case 'Length'
           xtlabels = {'linked', 'linked', 'linked', 'i9', 'linked', 'linked', 'i10', 'linked'};
       case 'None'  
          xtlabels = custom_labels(length(bandsets.medians.intensities));
   end
end
% Means and errors of intensities
close all
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
bar(bandsets.medians.intensities)
xlabel('band number')
ylabel('median of integrated intensities')
title(['Intensites comparison for ' prefix_out ': median, stDev, rel_stDev, abs_error, rel_error'])
xlim([0 length(bandsets.medians.intensities)+1])
ylim([0 1.25*max(bandsets.medians.intensities)])
set(gca, 'XTick', 1:length(bandsets.intensities))
if ctl
    set(gca,'XTickLabel', xtlabels)
end
text((1:length(bandsets.medians.intensities)),bandsets.medians.intensities' + 800, ...
    num2str(bandsets.medians.intensities), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.stDevs.intensities),bandsets.medians.intensities' + 600, ...
    num2str(bandsets.stDevs.intensities), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.stDevs.intensities),bandsets.medians.intensities' + 400, ...
    num2str(bandsets.stDevs.intensities./bandsets.medians.intensities), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.errors.intensities),bandsets.medians.intensities' + 200, ...
    num2str(bandsets.errors.intensities), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.errors.intensities),bandsets.medians.intensities', ...
    num2str(bandsets.errors.intensities./bandsets.medians.intensities), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
print('-dpng', '-r150', [path_out 'intensities_comparison.png'])
% intensity variation by band
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
plot(bandsets.intensities)
xlim([0 size(bandsets.intensities,1)+1])
ylim([0 1.1*max(bandsets.medians.intensities)])
xlabel('band number')
ylabel('integrated intensity')
set(gca, 'XTick', 1:length(bandsets.intensities))
if ctl
    set(gca,'XTickLabel', xtlabels)
end
title(['Variation in analyzed intensities (by band number),' prefix_out])
legend_cell = cell(size(bandsets.intensities,2),1);
for i = 1:length(legend_cell)
    legend_cell{i} = ['analysis ' num2str(i)];
end
legend(legend_cell)
print('-dpng', '-r150', [path_out 'intensities_variation1.png'])
% intensity variation by analysis
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
plot(bandsets.intensities.')
xlim([0 size(bandsets.intensities,2)+1])
ylim([0 1.1*max(bandsets.medians.intensities)])
set(gca, 'XTick', 1:size(bandsets.intensities,2))
xlabel('analysis number')
ylabel('integrated intensity')
title(['Variation in analyzed intensities (by analysis number),' prefix_out]);
if ctl
    legend(xtlabels)
else
    legend_cell = cell(size(bandsets.intensities,1),1);
    for i = 1:length(legend_cell)
        legend_cell{i} = ['band ' num2str(i)];
    end
    legend(legend_cell)
end
print('-dpng', '-r150', [path_out 'intensities_variation2.png'])

%% Sums comparison
ctl = strcmp(questdlg('Enter custom XTick Labels for sums and ratios plots?','','Yes'),'Yes');
if ctl
   use_default = questdlg('Use default values?','','Excess', 'Length', 'None', 'None');
   switch use_default
       case 'Excess'
           xtlabels = {'linked', '0,25x', '0,5x', 'linked', '0,75x', '1,0x', '1,25x', '1,5x', 'linked', '2,0x', '2,5x', '5,0x', '10x', 'linked', '20x', 'linked'};
       case 'Length'
           xtlabels = {'linked', 'linked', 'linked', 'i9', 'linked', 'linked', 'i10', 'linked'};
       case 'None'  
          xtlabels = custom_labels(length(bandsets.medians.sums));
   end
end
% Means and errors of sums
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
bar(bandsets.medians.sums)
xlabel('lane number')
ylabel('median of sums')
title(['Sums comparison for ' prefix_out ': median, stDev, rel_stDev, abs_error, rel_error'])
xlim([0 length(bandsets.medians.sums)+1])
ylim([0 1.25*max(bandsets.medians.sums)])
set(gca, 'XTick', 1:length(bandsets.medians.sums))
if ctl
    set(gca,'XTickLabel', xtlabels)
end
text((1:length(bandsets.medians.sums)),bandsets.medians.sums' + 800, ...
    num2str(bandsets.medians.sums), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.stDevs.sums),bandsets.medians.sums' + 600, ...
    num2str(bandsets.stDevs.sums), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.stDevs.sums),bandsets.medians.sums' + 400, ...
    num2str(bandsets.stDevs.sums./bandsets.medians.sums), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.errors.sums),bandsets.medians.sums' + 200, ...
    num2str(bandsets.errors.sums), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.errors.sums),bandsets.medians.sums', ...
    num2str(bandsets.errors.sums./bandsets.medians.sums), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
print('-dpng', '-r150', [path_out 'sums_comparison.png'])
% sum variation by band
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
plot(bandsets.sums)
xlim([0 size(bandsets.sums,1)+1])
ylim([0 1.1*max(bandsets.medians.sums)])
xlabel('lane number')
ylabel('sum of integrated intensities')
set(gca, 'XTick', 1:length(bandsets.medians.sums))
if ctl
    set(gca,'XTickLabel', xtlabels)
end
title(['Variation in lane sums (by band number),' prefix_out])
legend_cell = cell(size(bandsets.sums,2),1);
for i = 1:length(legend_cell)
    legend_cell{i} = ['analysis ' num2str(i)];
end
legend(legend_cell)
print('-dpng', '-r150', [path_out 'sums_variation1.png'])
% sum variation by analysis
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
plot(bandsets.sums.')
xlim([0 size(bandsets.sums,2)+1])
ylim([0 1.1*max(bandsets.medians.sums)])
xlabel('analysis number')
ylabel('sum integrated intensities')
set(gca, 'XTick', 1:size(bandsets.sums,2))
title(['Variation in lane sums (by analysis number),' prefix_out])
if ctl
    legend(xtlabels)
else
    legend_cell = cell(size(bandsets.sums,1),1);
    for i = 1:length(legend_cell)
        legend_cell{i} = ['sum ' num2str(i)];
    end
    legend(legend_cell)
end
print('-dpng', '-r150', [path_out 'sums_variation2.png'])


%% Ratios comparison
% Means and errors of ratios
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
bar(bandsets.medians.ratios)
xlabel('lane number')
ylabel('median of ratios')
title(['Ratios comparison for ' prefix_out ': median, stDev, rel_stDev, abs_error, rel_error'])
xlim([0 length(bandsets.medians.ratios)+1])
ylim([0 1])
set(gca, 'XTick', 1:length(bandsets.medians.ratios))
if ctl
    set(gca,'XTickLabel', xtlabels)
end
text((1:length(bandsets.medians.ratios)),bandsets.medians.ratios' + .133, ...
    num2str(bandsets.medians.ratios), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.stDevs.ratios),bandsets.medians.ratios' + .1, ...
    num2str(bandsets.stDevs.ratios), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.stDevs.ratios),bandsets.medians.ratios' + .066, ...
    num2str(bandsets.stDevs.ratios./bandsets.medians.ratios), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.errors.ratios),bandsets.medians.ratios' + .033, ...
    num2str(bandsets.errors.ratios), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
text(1:length(bandsets.errors.ratios),bandsets.medians.ratios', ...
    num2str(bandsets.errors.ratios./bandsets.medians.ratios), ... 
    'HorizontalAlignment','center','VerticalAlignment','bottom')
print('-dpng', '-r300', [path_out 'ratios_comparison.png'])
% ratio variation by band
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
plot(bandsets.ratios)
ylim([0 1])
xlim([0 size(bandsets.ratios,1)+1])
xlabel('lane number')
ylabel('ratio of integrated intensities')
set(gca, 'XTick', 1:length(bandsets.medians.ratios))
if ctl
    set(gca,'XTickLabel', xtlabels)
end
title(['Variation in ratios (by band number),' prefix_out])
legend_cell = cell(size(bandsets.ratios,2),1);
for i = 1:length(legend_cell)
    legend_cell{i} = ['analysis ' num2str(i)];
end
legend(legend_cell)
print('-dpng', '-r150', [path_out 'ratios_variation1.png'])
% ratio variation by analysis
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
plot(bandsets.ratios.')
ylim([0 1])
xlim([0 size(bandsets.ratios,2)+1])
xlabel('analysis number')
ylabel('ratio of integrated intensities')
set(gca, 'XTick', 1:size(bandsets.ratios,2))
title(['Variation in ratios (by analysis number),' prefix_out])
if ctl
    legend(xtlabels)
else
    legend_cell = cell(size(bandsets.ratios,1),1);
    for i = 1:length(legend_cell)
        legend_cell{i} = ['ratio ' num2str(i)];
    end
    legend(legend_cell)
end
print('-dpng', '-r150', [path_out 'ratios_variation2.png'])