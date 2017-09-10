clear variables
run('my_prefs.m')
loadpath = uigetdir('/Users/matthiasschickinger/PhD/TIRFM_Data/00_TIRFM_Analysis/NaCl_screens');
cd(loadpath)
load('lts_main_pop.mat')
close all
exppdf_mod = @(t,tau,Tmin,Tmax)1./tau.*exp(-t./tau)./(exp(-Tmin./tau)-exp(-Tmax./tau));
expcdf_mod = @(t,tau,Tmin,Tmax)(exp(-t./tau)-exp(-Tmin./tau))/(exp(-Tmax./tau)-exp(-Tmin./tau));
%colors = {[237 177 32]/255,[0 102 153]/255, [204 0 0]/255};
%cf = figure('Color', [1 1 1], 'Units', 'Pixels', 'Position', [500 500 128 115], 'PaperPositionMode', 'auto', ...
 %               'Visible','off');
[filename,savepath] = uiputfile('','',[paper_dir '/2017_Figures/NaClScreen/']);%inputdlg({'Enter filename (without extension):'},'Filename',1,{''});
cd(savepath)

%% Set limits, color, markers
BLIM = [8 45];
ULIM = [9 400];
colors = {[.929 .694 .125],[.494 .184 .556],[.466 .674 .188]};
cind = 2;
markers = {'x','o','+'};
msize = [4.2,5,3.5];
%% Scatter plot
close all
sz = [100 100 320 170];
figure('Units','Points','Position',sz,'PaperUnits','Points','PaperSize',sz(3:4),'PaperPositionMode','auto')
hold off
XYmin = [Inf Inf];
%cind = 0;
for j = numel(lifetimes):-1:1
    %cind = cind+1;
    loglog(lifetimes{j}.MEAN(INdices{j},2),lifetimes{j}.MEAN(INdices{j},1),markers{j},'Color',colors{cind},'MarkerSize',msize(j),'LineWidth',.1,'MarkerFaceColor',[1 1 1]*1)
    hold on
    for k = 1:2
        XYmin(k) = min(XYmin(k),min(lifetimes{j}.MEAN(INdices{j},k)));
    end
end
XYmin = XYmin - [0.1 0.1];
ax = gca;
ax.XLim = ULIM;
%xlim auto
ax.YLim = BLIM;
ax.TickDir = 'out';
ax.FontName = 'Helvetica';
ax.FontSize = 12;
%ax.YTick = [0 .5 1];
ax.XTick = [10,100];
for i = 1:numel(ax.XTick)
    ax.XTickLabel{i} = num2str(ax.XTick(i));
end
ax.YTick = [10, 20, 30, 40];
for i = 1:numel(ax.YTick)
    ax.YTickLabel{i} = num2str(ax.YTick(i));
end
ax.YMinorGrid = 'off';
%ax.YTickLabel = {};
%xlabel('lifetime (s)', 'FontSize', 14)
%ylabel('Cumulative frequency / Probability', 'FontSize', 14)
%l = legend({'data','MLE'},'Location','southeast', 'FontSize', 12);
box off
ax.Layer = 'top';
grid on

%minimize whitespace (from Matlab help)
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%export_fig(filename(1:strfind(filename,'.')-1),'-eps','-r600', '-transparent')
print('-depsc','-r600','-tiff','-loose',[filename(1:strfind(filename,'.')-1) '_scatter.eps'])

%% CDF plot unbound (state 2)
close all
sz = [100 100 320 200];
figure('Units','Points','Position',sz,'PaperUnits','Points','PaperSize',sz(3:4),'PaperPositionMode','auto')
hold off
cind = 0;
Tmax = 800;
tmax = 0;
for j = numel(lifetimes):-1:1
    cind = cind+1;
    lt = sort(vertcat(lifetimes{j}.ALL{INdices{j},2}));
    tmin = min(lt);
    %
    tmp = lt(floor(0.999*length(lt)));
    centers = logspace(-2,log10(Tmax),3e3);
    %centers = linspace(0,Tmax,3e3);
    cumcts = zeros(size(centers));
    for i = 1:length(centers)
        cumcts(i) = sum(lt<=centers(i));
    end
    cumcts = cumcts/cumcts(end);
    tmax = max(tmax,centers(find(cumcts>.999,1)));
    semilogx(centers,cumcts,'Color',colors{cind},'LineWidth',2)
    hold on
end
ax = gca;
ax.XLim = [tmin-0.1 tmax];
%xlim auto
ax.YLim = [0 1];
ax.YTick = [0 0.5 1];
ax.TickDir = 'out';
ax.FontName = 'Helvetica';
ax.FontSize = 12;
%ax.YTick = [0 .5 1];
ax.XTick = [.1, 1, 10, 100, 1000];
for i = 1:numel(ax.XTick)
    ax.XTickLabel{i} = num2str(ax.XTick(i));
end
%ax.YTickLabel = {};
%xlabel('lifetime (s)', 'FontSize', 14)
%ylabel('Cumulative frequency / Probability', 'FontSize', 14)
%l = legend({'data','MLE'},'Location','southeast', 'FontSize', 12);
box off
ax.Layer = 'top';
grid off

%minimize whitespace (from Matlab help)
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%export_fig(filename(1:strfind(filename,'.')-1),'-eps','-r600', '-transparent')
print('-depsc','-r600','-tiff','-loose',[filename(1:strfind(filename,'.')-1) '_unbound.eps'])

%% CDF plot bound (state1)
close all
sz = [100 100 320 200];
figure('Units','Points','Position',sz,'PaperUnits','Points','PaperSize',sz(3:4),'PaperPositionMode','auto')
hold off
cind = 0;
Tmax = tmax;
for j = numel(lifetimes):-1:1
    cind = cind+1;
    lt = sort(vertcat(lifetimes{j}.ALL{INdices{j},1}));
    %Tmax = max(lt)+0.1;
    %
    tmp = lt(floor(0.999*length(lt)));
    centers = logspace(-2,log10(Tmax),3e3);
    %centers = linspace(0,Tmax,3e3);
    cumcts = zeros(size(centers));
    for i = 1:length(centers)
        cumcts(i) = sum(lt<=centers(i));
    end
    cumcts = cumcts/cumcts(end);
    %tmax = max(tmax,centers(find(cumcts>.999,1)));
    semilogx(centers,cumcts,'Color',colors{cind},'LineWidth',2)
    hold on
end
ax = gca;
ax.XLim = [tmin-0.1 tmax];
%xlim auto
ax.YLim = [0 1];
ax.YTick = [0 0.5 1];
ax.TickDir = 'out';
ax.FontName = 'Helvetica';
ax.FontSize = 12;
%ax.YTick = [0 .5 1];
ax.XTick = [.1, 1, 10, 100, 1000];
for i = 1:numel(ax.XTick)
    ax.XTickLabel{i} = num2str(ax.XTick(i));
end
%ax.YTickLabel = {};
%xlabel('lifetime (s)', 'FontSize', 14)
%ylabel('Cumulative frequency / Probability', 'FontSize', 14)
%l = legend({'data','MLE'},'Location','southeast', 'FontSize', 12);
box off
ax.Layer = 'top';
grid off

%minimize whitespace (from Matlab help)
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%export_fig(filename(1:strfind(filename,'.')-1),'-eps','-r600', '-transparent')
print('-depsc','-r600','-tiff','-loose',[filename(1:strfind(filename,'.')-1) '_bound.eps'])
