%%
Npaths = inputdlg({'How many filepaths?'},'Npaths',1,{'3'});
Npaths = str2double(Npaths{1});
logpaths = cell(Npaths,1);
for j = 1:Npaths
    logpaths{j} = uigetdir(data_dir);
end

%%
frameNum = cell(Npaths,1);
Tchamber = cell(Npaths,1);
for j=1:Npaths
    cd(logpaths{j})
    loglist = dir('*log*');
    frameNum{j} = cell(size(loglist));
    Tchamber{j} = cell(size(frameNum{j}));
    for i = 1:numel(loglist)
        [frameNum{j}{i}, Tchamber{j}{i}] = imporTxt([logpaths{j} filesep loglist(i).name]);
    end
end

%% Save data
save Temperatures.mat frameNum Tchamber logpaths
%% Plot temperature traces
Names = {'504 bp','1512 bp, set 1','1512 bp, set 2','2520 bp'};
Legendary = {'150 mM / 1','150 mM / 2','500 mM / 1','500 mM / 2','1 M / 1','1 M / 2'};
cf = figure('Units','Pixels','Position',[1 1 1920 1080],'Color',[1 1 1]);
ax = cell(Npaths,1);
for j = 1:Npaths
    %figure
    subplot(1,4,j)
    ax{j} = gca;
    if j==4
        ax{j}.ColorOrderIndex = 3;
        hold on
    end
    for i = 1:numel(frameNum{j})
        plot(frameNum{j}{i},Tchamber{j}{i})
        hold on
    end
    ax{j}.FontSize = 12;
    ax{j}.XLim = [0 45000];
    ax{j}.YLim = [22.5 24.5];
    ax{j}.XTick = 0:9000:45000;
    ax{j}.XTickLabel = cell(size(ax{j}.XTick));
    for i = 1:numel(ax{j}.XTick)
        ax{j}.XTickLabel{i} = num2str(ax{j}.XTick(i)/600);
    end
    ax{j}.XLabel.String = 'Time (min)';
    ax{j}.XLabel.FontSize = 16;
    ax{j}.TickDir = 'out';
    box off
    title(Names{j},'FontSize',20)
    legend(Legendary((1+2*(j==4)):end),'FontSize',14);
    %title(['Sample #' num2str(j)],'FontSize',14)
end
ax{1}.YLabel.String = 'Temperature (?C)';
ax{1}.YLabel.FontSize = 16;

%% Save as pdf

cf.PaperUnits = 'points';
cf.PaperSize = cf.Position(3:4);
cf.PaperPosition = cf.Position;
print ('-dpdf','Temperatures.pdf')

%% Average temperatures

Tavg = zeros(8,1);
%504 bp
for i = 0:2:4
    Tavg(i/2+1) = mean(vertcat(Tchamber{1}{i+1:i+2}));
end

%1512 bp
for i = 0:2:4
    Tavg(i/2+4) = mean(vertcat(vertcat(Tchamber{2}{i+1:i+2}), ...
                                vertcat(Tchamber{3}{i+1:i+2})));
end

%2520 bp
for i = [0 2]
    Tavg(i/2+7) = mean(vertcat(Tchamber{4}{i+1:i+2}));
end

%% Correlate with off-rates
colors = {[0 128 255]./255,[255 128 0]./255,[255 0 255]./255};
indices = {1:3,4:6,[7 8]};
figure('Color',[1 1 1])

for i = 1:numel(indices)
    subplot(3,1,1)
    plot(c_NaCl_all(indices{i}), k_off_all(indices{i}),'o', 'Color',colors{i})
    hold on
    subplot(3,1,2)
    plot(c_NaCl_all(indices{i}), Tavg(indices{i}),'x', 'Color',colors{i})
    hold on
    subplot(3,1,3)
    plot(c_NaCl_all(indices{i}), ...
        -1./(273.15*ones(size(Tavg(indices{i})))+Tavg(indices{i})), ...
        'x', 'Color',colors{i})
    hold on
end
YLIM = [0.04 0.08; ...
        23 24.5; ...
        -0.00338 -0.00336];
for i = 1:3
    subplot(3,1,i)
    ax{i} = gca;
    xlim([0.1 1.18])
    ylim(YLIM(i,:))
    ax{i}.Title.FontSize = 12;
    ax{i}.TickDir = 'out';
    box off
end

%
ax{1}.Title.String = 'Off-rates in 1/s vs c_NaCl';
ax{2}.Title.String = 'Average temperature in ?C vs c_NaCl';
ax{3}.Title.String = '-1/(Avg. temperature in K) vs c_NaCl';

%%
figure
colors = {[0 128 255]./255,[255 128 0]./255,[255 0 255]./255};
indices = {1:3,4:6,[7 8]};
figure('Color',[1 1 1])

for i = 1:numel(indices)
    plot(1./(273.15*ones(size(Tavg(indices{i})))+Tavg(indices{i})),k_off_all(indices{i}),'o', 'Color',colors{i})
    hold on
end
title('Off-rates in 1/s vs 1/(Avg. temperature in K)','FontSize',12)













