% What data needs to be loaded?

% inputPostHMM_nost.mat -> contains state trajectories, medI traces,
% excluded intervals and particle indices

% maybe data_spot_pairs.mat for raw intensities? -> RAM-costly; might make
% sense, though, as medI-traces are filtered in the time domain.

%% Get the states, calculate state midpoints

SL{2} = zeros(0,4);
SL{1} = SL{2};

for i = 1:numel(inputPostHMM_nost.state_trajectories)
    tmp_straj = inputPostHMM_nost.state_trajectories{i};
    tmp_ex = inputPostHMM_nost.ex_int{i};
    tmp_states = getStates(tmp_straj, tmp_ex);
    for s = 1:2
        if ~isempty(tmp_states{s})
            tmp_states{s}(:,1) = tmp_states{s}(:,1)+inputPostHMM_nost.ranges(1);
            tmp_states{s} = tmp_states{s}./10;
            SL{s} = [SL{s}; ...
                ones(size(tmp_states{s},1),1)*inputPostHMM_nost.indices(i,:) [tmp_states{s}]];
        end
    end
end

%% Scatter plots duration vs. starting point / mid point
%{
close all
state_names = {'bound','unbound'};

figure('Units','normalized','Position',[0 0 1 1])
for s = 2:-1:1
    YLIM = [0 mean(SL{s}(:,4))+5*std(SL{s}(:,4))]; 
    subplot(2,2,s)
    plot(SL{s}(:,3),SL{s}(:,4),'.')
    title(state_names{s})
    ylim(YLIM)
    subplot(2,2,s+2)
    plot(SL{s}(:,3)+floor(SL{s}(:,4)/2),SL{s}(:,4),'.','Color',[204 0 0]/255)
    ylim(YLIM)
end
%}

%% Split up in 15-minute intervals

Fmax = 0;
for s = 1:2
    Fmax = max(Fmax,max(sum(SL{s}(:,3:4),2)));
end
Fmax = 900*ceil(Fmax/900);
Fmax = min(Fmax,4500);

boxes = cell(Fmax/900,2);
for s = 1:2
    for i = 1:size(boxes,1)
        boxes{i,s} = SL{s}(SL{s}(:,3)>900*(i-1) & (sum(SL{s}(:,3:4),2)-1)<=900*i,:);
    end
end

%% Box plots
%{
figure
plotbox = cell(2,1);
for s = 1:2
    plotbox{s} = zeros(0,2);
    for i = 1:size(boxes,1)
        plotbox{s} = [plotbox{s} ; [boxes{i,s}(:,4) i*ones(size(boxes{i,s},1),1)]];
    end
    subplot(2,1,s)
    boxplot(plotbox{s}(:,1),plotbox{s}(:,2))
end
%}

%% Median-Quartile plots
%{
close all
quartiles = cell(2,1);
sems = cell(2,1);
sz = [800 600];
boxfig = figure('Units','Pixels','Position',[1 1 sz],'Color',[1 1 1],...
    'Visible','on','PaperUnits','points','PaperSize',sz,'PaperPosition',[1 1 sz]);
AREAcolor = .85*[1 1 1];
fsz = 8;
state_names = {'bound','unbound'};
for s = 1:2
    quartiles{s} = zeros(3,size(boxes,1));
    sems{s} = zeros(1,size(boxes,1));
    tmpN = cell(1,size(boxes,1));
    for i = 1:size(boxes,1)
        quartiles{s}(1,i) = prctile(boxes{i,s}(:,4),75);
        quartiles{s}(2,i) = median(boxes{i,s}(:,4));
        quartiles{s}(3,i) = prctile(boxes{i,s}(:,4),25);
        tmpN{i} = ['(' num2str(size(boxes{i,s},1)) ')'];
        sems{s}(i) = std(boxes{i,s}(:,4))/sqrt(size(boxes{i,s},1));
    end
    subplot(2,1,s)
    hold on
    a = [(quartiles{s}(2,:)-3*sems{s})' (6*sems{s})'];
    A = area(a);
    A(1).FaceColor = 'none';
    A(1).EdgeColor = 'none';
    A(2).FaceColor = AREAcolor;
    A(2).EdgeColor = .8*[1 1 1];
    hold on
    D = plot(quartiles{s}(2,:),'d-');
    D.MarkerFaceColor = 'w';
    D.MarkerSize = 8;
    plot(quartiles{s}([1 3],:)','--','Color',.65*[1 1 1])
    text(1:size(boxes,1),1.135*quartiles{s}(2,:),tmpN,'HorizontalAlignment','center')
    ax = gca;
    ax.TickDir = 'out';
    ax.Layer = 'top';
    ax.LineWidth = .5;
    ax.FontName = 'Helvetica';
    ax.FontSize = fsz;
    ax.XLim = [0.8 5.2];
    ax.XTick = 1:5;
    ax.YLim(1) = 0;
    xlabel('Group','FontSize',fsz)
    ylabel([state_names{s} ' dwell times (s)'])
    box off
    axes('Units',ax.Units,'Position',ax.Position,'Color','none','TickDir','out','YAxisLocation','right')
    ax2 = gca;
    ax2.FontSize = ax.FontSize;
    ax2.LineWidth = ax.LineWidth;
    ax2.XAxis.Visible = 'off';
    ax2.XLim = ax.XLim;
    ax2.YLim = ax.YLim;
    ax2.YTick = ax.YTick;
    ax2.YTickLabel = ax.YTickLabel;
    if s==1
        title(current_dir,'FontSize',14)
    end
end
print('-dpng',[prefix_out '_sem.png'])

% Median-Quartile plots (bootstrapping variant)
%close all
quartiles = cell(2,1);
sems = cell(2,1);
sz = [800 600];
bootfig = figure('Units','Pixels','Position',[sz(1)+1 1 sz],'Color',[1 1 1],...
    'Visible','on','PaperUnits','points','PaperSize',sz,'PaperPosition',[1 1 sz]);
AREAcolor = .85*[1 1 1];
fsz = 8;
state_names = {'bound','unbound'};
% left = 0.05;
% right = 0.03;
% bottom = 0.05;
% top = 0.03;
% height = 0.4;
for s = 1:2
    quartiles{s} = zeros(3,size(boxes,1));
    sems{s} = zeros(1,size(boxes,1));
    tmpN = cell(1,size(boxes,1));
    for i = 1:size(boxes,1)
        if ~isempty(boxes{i,s})
            quartiles{s}(1,i) = prctile(boxes{i,s}(:,4),75);
            quartiles{s}(3,i) = prctile(boxes{i,s}(:,4),25);
            bootmp = bootstrp(100,@median,boxes{i,s}(:,4));
            quartiles{s}(2,i) = mean(bootmp);
            sems{s}(i) = std(bootmp);
            tmpN{i} = ['(' num2str(size(boxes{i,s},1)) ')'];
        else
            quartiles{s}(:,i) = NaN;
            sems{s}(i) = NaN;
        end
    end
    %subplot('Position',[left 1-s*(top+height)-(s-1)*bottom 1-left-right height])
    subplot(2,1,s)
    hold on
    a = [(quartiles{s}(2,:)-3*sems{s})' (6*sems{s})'];
    A = area(a);
    A(1).FaceColor = 'none';
    A(1).EdgeColor = 'none';
    A(2).FaceColor = AREAcolor;
    A(2).EdgeColor = .8*[1 1 1];
    hold on
    D = plot(quartiles{s}(2,:),'d-');
    D.MarkerFaceColor = 'w';
    D.MarkerSize = 8;
    plot(quartiles{s}([1 3],:)','--','Color',.65*[1 1 1])
    text(1:size(boxes,1),1.135*quartiles{s}(2,:),tmpN,'HorizontalAlignment','center')
    ax = gca;
    ax.TickDir = 'out';
    ax.Layer = 'top';
    ax.LineWidth = .5;
    ax.FontName = 'Helvetica';
    ax.FontSize = fsz;
    ax.XLim = [0.8 5.2];
    ax.XTick = 1:5;
    ax.YLim(1) = 0;
    xlabel('Group','FontSize',fsz)
    ylabel([state_names{s} ' dwell times (s)'])
    box off
    axes('Units',ax.Units,'Position',ax.Position,'Color','none','TickDir','out','YAxisLocation','right')
    ax2 = gca;
    ax2.FontSize = ax.FontSize;
    ax2.LineWidth = ax.LineWidth;
    ax2.XAxis.Visible = 'off';
    ax2.YLim = ax.YLim;
    ax2.YTick = ax.YTick;
    ax2.YTickLabel = ax.YTickLabel;   
    if s==1
        title(current_dir,'FontSize',14)
    end
end
print('-dpng',[prefix_out '_boot.png'])
%}

%% Compare histograms
close all
sz = [800 600];
histfig = figure('Units','Pixels','Position',[1 1 sz],'Color',[1 1 1],...
    'Visible','on','PaperUnits','points','PaperSize',sz,'PaperPosition',[1 1 sz]);
for s = 1:2
    T99=0;
    subplot(2,1,s)
    legendary = cell(size(boxes,1),1);
    for i = 1:size(boxes,1)
        if ~isempty(boxes{i,s})
            [counts, edges] = histcounts(boxes{i,s}(:,4),0:max(boxes{i,s}(:,4))/1000:max(boxes{i,s}(:,4))-1, ...
            'Normalization','cdf');
            T99 = max(T99,edges(find(counts>=0.99,1)));
            semilogx(edges(1:end-1)+diff(edges(1:2)),counts,'LineWidth',1.5)
            legendary{i} = ['Group ', num2str(i) ' (' num2str(size(boxes{i,s},1)) ')'];
        else
            plot(NaN,NaN)
            legendary{i} = 'NaN';
        end
        hold on
    end
    ax = gca;
    ax.TickDir = 'out';
    ax.Layer = 'top';
    ax.LineWidth = .5;
    ax.FontName = 'Helvetica';
    ax.FontSize = fsz;
    ax.XLim = [0.1 T99];
    ax.YLim = [0 1.0];
    ylabel('CDF','FontSize',fsz)
    xlabel([state_names{s} ' dwell times (s)'])
    box off
    legend(legendary,'Location','southeast','FontSize',12)
    if s==1
        title(current_dir,'FontSize',14)
    end
end
print('-dpng',[prefix_out '_logcdf.png'])
%% Analysis of mus and sigmas from all particle segments



%% Analysis of true homogeneity of intensities from all particle segments