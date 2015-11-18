%% startup
close all, clear all, clc
run('my_prefs.m')

[tmp_filename, path_out] = uigetfile('/Users/matthiasschickinger/PhD/Gels/*.mat', 'Choose .mat file containing lane data');
tmp = load([path_out tmp_filename]);
lanes = tmp.lanes;
single_gelData = tmp.single_gelData;

n_data = length(lanes);
n_lanes = length(lanes{1}.profiles);

tmp = inputdlg({'Name of gel (prefix):'}, 'Name of gel (prefix):' , 1, {''} );
prefix_out = [tmp{1} ' maxima analysis']; 
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

%% get band maxima for lanes with double bands
def_n_dbl = num2str(0);
n_doublanes = str2double(inputdlg('How many lanes with double bands?', 'n_doublanes', 1, {def_n_dbl}));

ctl = strcmp(questdlg('Enter custom lane labels for maxima-over-time plots?','','Yes'),'Yes');
if ctl
   use_default = questdlg('Use default values?','','Excess', 'Length', 'None', 'None');
   switch use_default
       case 'Excess'
           lane_labels = {'linked', '0,25x', '0,5x', 'linked', '0,75x', '1,0x', '1,25x', '1,5x', 'linked', '2,0x', '2,5x', '5,0x', '10x', 'linked', '20x', 'linked'};
       case 'Length'
           lane_labels = {'linked', 'linked', 'linked', 'i9', 'linked', 'linked', 'i10', 'linked'};
       case 'None'
           lane_labels = custom_labels(n_doublanes);
   end
else
   lane_labels = cell(n_lanes,1);
   for i = 1:n_lanes
       lane_labels{i} = ['Lane ' num2str(i)];
   end
end
maxima.intensities = ones(2*n_doublanes,n_data);
maxima.positions = zeros(2*n_doublanes,n_data);
maxima.sums = zeros(n_doublanes,n_data);
maxima.ratios = zeros(n_doublanes,n_data);
i = 1;
maxima_counter = 1;
%%
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto', 'Visible', 'on')
tmp = inputdlg({'Resume at total lane #:', 'Resume at analysis lane #:'}, 'Lane numbers', 1, {num2str(i), num2str(maxima_counter)});
i = str2double(tmp{1});
maxima_counter = str2double(tmp{2});
while i <= n_lanes
    hold off
    for j = 1:n_data
        subplot(n_data,1,j)
        hold off
        plot(lanes{j}.profiles{i})
        hold on
        ylabel('Intensity (a.u.)')
        title(['Profile after ' times{j}])
    end
    xlabel('Pixels (25 \mum / px)', 'Interpreter', 'tex')
    
    dbl = strcmp(questdlg('Double band?', 'Doublane?', 'Yes', 'No', 'Yes'), 'Yes');
    if dbl
        for j = 1:n_data
            get_maxima = 1;
            while get_maxima
                subplot(n_data,1,j)
                hold off
                if exist('h1', 'var')
                    delete(h1)
                end
                plot(lanes{j}.profiles{i})
                hold on
                ylabel('Intensity (a.u.)')
                title([lane_labels{maxima_counter} ', profile after ' times{j}])
                for k = 1:2
                    h1 = imrect(gca);
                    setResizable(h1,1);
                    pos1 = wait(h1);
                    tmp_profile = lanes{j}.profiles{i}(pos1(1):pos1(1)+pos1(3));
                    [val,ind] = max(tmp_profile);
                    if length(val)>1
                        val = val(1);
                        ind = ind(1);
                    end
                    ind = pos1(1)+ind-1;                    
                    maxima.intensities(2*(maxima_counter-1)+k,j) = val;
                    maxima.positions(2*(maxima_counter-1)+k,j) = ind;
                    delete(h1)
                    hold on
                    plot(ind, val, 'r.')
                end
                get_maxima = strcmp(questdlg('Maxima OK?', 'Check maxima', 'Yes', 'No', 'Yes'),'No');
            end
        end
        maxima_counter = maxima_counter + 1;
    end
    i = i+1;
end
maxima.sums = maxima.intensities(1:2:end,:) + maxima.intensities(2:2:end,:);
maxima.ratios = maxima.intensities(2:2:end,:)./maxima.sums;
%% save data
close all
cd(path_out)
save([path_out 'bands_maxima.mat'], 'maxima')

%% plot band values over gel run time
close all
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto', 'Visible', 'on')
for i = 1:n_doublanes
    subplot(2,1,1)
    hold off
    plot(maxima.intensities(2*i-1,:))
    hold on
    plot(maxima.intensities(2*i,:))
    plot(maxima.sums(i,:))
    xlabel('Gel run time')
    ylabel('Intensity (a.u.)')
    xlim([.5 n_data+.5])
    set(gca, 'XTick', 1:length(times), 'XTickLabel', times, 'YGrid', 'on');
    legend({'Trailing band', 'Leading band', 'Sum'})
    title([prefix_out ' , lane #' num2str(i) ' , ' lane_labels{i}])
    
    subplot(2,1,2)
    hold off
    plot(maxima.ratios(i,:))
    legend({'Ratio leading:sum'})
    xlabel('Gel run time')
    ylabel('Ratio')
    xlim([.5 4.5])
    ylim([0.9*min(maxima.ratios(i,:)) 1.1*max(maxima.ratios(i,:))])
    set(gca, 'XTick', 1:length(times), 'XTickLabel', times, 'YTick', 0:.05:1, 'YGrid', 'on');
    print('-dpng', '-r96', [path_out 'maxima_over_time_lane' num2str(i) '.png'])
end

%% Bar plots of ratios for gel run times
close all
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
for i = 1:n_data
    bar(maxima.ratios(:,i))
    xlabel('lane number')
    ylabel('ratios of maxima')
    title(['Ratios comparison for ' prefix_out ', ' times{i} ':'])
    xlim([0 length(maxima.ratios(:,i))+1])
    ylim([0 1])
    set(gca, 'XTick', 1:length(maxima.ratios(:,i)))
    if ctl
        set(gca,'XTickLabel', lane_labels)
    end
    text((1:length(maxima.ratios(:,i))),maxima.ratios(:,i)' + .05, ...
        num2str(maxima.ratios(:,i)), ... 
        'HorizontalAlignment','center','VerticalAlignment','bottom')
    print('-dpng', '-r300', [path_out 'maxima_ratios_comparison_' times{i} '.png']) 
end
close all
