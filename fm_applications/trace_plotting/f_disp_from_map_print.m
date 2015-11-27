function f_disp_from_map_print (path_out, varargin)

% Plots the displacements of mobile spot position (single frame and mean)
% from mapped fixed spot position and produces .png images of these graphs

%% parse input

p = inputParser;

addRequired(p, 'path_out', @isdir);
%addParameter(p, 'filter', 'RMS', @ischar);
%addParameter(p, 'method', 'vwcm', @ischar);
addParameter(p, 'YLIM', [0 2], @isvector);
%addParameter(p, 'horzAx', 'frames', @ischar);

parse(p, path_out, varargin{:});
YLIM = p.Results.YLIM;

%% Load data
clear channel chb cut fit_cutoff data

cd(path_out)
folder_out = [path_out filesep 'disp_from_map_traces_new'];
mkdir(folder_out)

load('data_proc.mat');
load('data_plot.mat');
load('data_spot_pairs.mat', 'data');
disp('All data loaded.')

%% Set parameters
if chb == 1
    chm = 2;
else
    chm = 1;
end

% subplot parameters
lower = 0.125;
upper = 0.575; 

%% Get and plot displacement traces
for m=1:size(data,1)
    if ceil(size(data{m}{1,1}.pos0,1)/1000) == 1
        XTickDiv = 20;
    elseif ceil(size(data{m}{1,1}.pos0,1)/1000) <= 10
        XTickDiv = 100;
    else
        XTickDiv = 1000;
    end
    XTC = cell(1,floor(size(data{m}{1,1}.pos0,1)/XTickDiv)); %DO PROPERLY IN THE LONG RUN!!!!
    for i = 1:floor(size(data{m}{1,1}.pos0,1)/(5*XTickDiv)) %DO PROPERLY IN THE LONG RUN!!!!
        XTC{5*i+1} = i*5*XTickDiv;
    end
    for s=1:size(data{m},1)
        L = min([length(data{m}{s,chm}.vwcm.pos) length(data{m}{s,chb}.vwcm.pos_map)]);
        % determine displacements
        disp_from_map = data{m}{s,chm}.vwcm.pos(1:L,:)-data{m}{s,chb}.vwcm.pos_map(1:L,:);
        disp_mean_from_map = data{m}{s,chm}.vwcm.means100-data{m}{s,chb}.vwcm.pos_map;

        abs_disp_from_map = sqrt(disp_from_map(:,1).^2+disp_from_map(:,2).^2);
        abs_disp_mean_from_map = sqrt(disp_mean_from_map(:,1).^2+disp_mean_from_map(:,2).^2);
        
        med_abs_disp_from_map = medfilt1(abs_disp_from_map,20);
        med_abs_disp_mean_from_map = medfilt1(abs_disp_mean_from_map,20);

        % make plots
        figure('Visible','off', 'PaperPositionMode', 'manual','PaperUnits',...
        'centimeters', 'PaperPosition', [0 0 29.7 9.9]);
        
        % displacement subplot
        subplot('Position', [0.035 upper 0.65 0.35])
        hold off
        plot(abs_disp_from_map(:), '.', 'MarkerSize', 5)
        hold on
        plot(med_abs_disp_from_map(:), 'Color', 'c', 'LineWidth', .2)
        set(gca, 'Ylim', YLIM, 'YTick', YLIM(1):YLIM(2), 'Xlim',[0 size(data{m}{s,1}.pos0,1)], ...
                'XTick', 0:XTickDiv:size(data{m}{s,1}.pos0,1), 'XTickLabel', {},...
                'TickDir', 'in', 'Layer', 'top');    
        ylabel('Delta')
        grid on
        title(['Absolute displacements of mobile spot from mapped fixed spot position. ' ...
            'Spot pair # ' num2str(s) ' of ' num2str(size(data{m},1)) ' / movie: ' num2str(m)])
        
        % mean100 displacement subplot
        subplot('Position', [0.035 lower 0.65 0.35])
        hold off
        plot(abs_disp_mean_from_map(:), '.', 'MarkerSize', 5)
        hold on
        plot(med_abs_disp_mean_from_map(:), 'Color', 'c', 'LineWidth', .2)
        set(gca, 'Ylim', YLIM, 'YTick', YLIM(1):YLIM(2), 'Xlim',[0 size(data{m}{s,1}.pos0,1)], ...
                'XTick', 0:XTickDiv:size(data{m}{s,1}.pos0,1), 'XTickLabel', XTC,...
                'TickDir', 'in', 'Layer', 'top');
        ylabel('Delta'), xlabel('Frame #')
        grid on
        title('Mean100 displacements of mobile spot from mapped fixed spot position')
        
        % displacement scatter plot
        subplot('Position', [0.825 upper 0.175 0.35])
        plot(disp_from_map(:,1), disp_from_map(:,2),'.', 'MarkerSize', 3)
        xlim([-5 5])
        ylim([-5 5])
        TC = cell(1,11); TC{1} = -5; TC{6} = 0; TC{11} = 5;
        set(gca, 'XTick', -5:5, 'YTick', -5:5, 'XTickLabel', TC, 'YTickLabel', TC)
        grid on, axis square
        title('X/Y-displacements')
        
        % x-displacement distribution
        subplot('Position',[0.71, lower, 0.12, 0.35])
        hx = histogram(disp_from_map(:,1),-5:.5:5,'Normalization', 'probability');
        hx.FaceColor = [0 0.4470 0.7410];
        hx.EdgeColor = [0 0.4470 0.7410];
        set(gca, 'XTick', -5:5, 'XTickLabel', {-5, [], -3, [], -1, [], 1, [], 3, [], 5},...
            'YTickLabel', {}, 'TickDir', 'in', 'Xlim', [-5 5], 'XGrid', 'on', 'YTick', [])
        ylabel('Frequency')
        xlabel('X-displacements')
        
        % y-displacement distribution
        subplot('Position',[0.8515, lower, 0.12, 0.35])
        hy = histogram(disp_from_map(:,2),-5:.5:5,'Normalization', 'probability');
        hy.FaceColor = [0 0.4470 0.7410];
        hy.EdgeColor = [0 0.4470 0.7410];
        set(gca, 'XTick', -5:5, 'XTickLabel', {-5, [], -3, [], -1, [], 1, [], 3, [], 5},...
            'YTick', 0:1, 'YTickLabel', {0, 1}, 'TickDir', 'in', 'Xlim', [-5 5], 'XGrid', 'on')
        xlabel('Y-displacements')
        
        % save .png picture
        print('-dpng', '-r96', [folder_out filesep 'disp_from_map_m' num2str(m) '_s' num2str(s) '.png'])
        close(gcf)
    end
end
display('Done plotting traces.')
end