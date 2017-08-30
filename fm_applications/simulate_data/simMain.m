%% Extract relevant data from hop struct
% tpfALL = zeros(0,1);
% for i = 1:size(hops,1)
%     tmp = cell(size(hops{i}.results));
%     for m = 1:length(tmp)
%         tmp{m} = hops{i}.tpf(m)*ones(length(hops{i}.results{m}),1);
%     end
%     tpfALL = [tpfALL;vertcat(tmp{:})];
% end
load('dataPostHMM_nost.mat')
load('HMMdata1.mat')

%%
tpf = 50;

%Fmin = [t1(findex) t2(findex)];
Fmin = [17 9]; 
Tmin = Fmin*2*tpf/1000;
Tmax = 0;

lifetimes.ALL = cell(numel(state_trajectories),2);
excludedIntervals = inputPostHMM_nost.ex_int;
for j = 1:size(lifetimes.ALL,1)
    lifetimes.ALL(j,:) = lts_strict_cutoff(state_trajectories(j),Fmin,excludedIntervals);
end


%%
lifetimes.MEAN = zeros(size(lifetimes.ALL));
lifetimes.SUM = zeros(size(lifetimes.MEAN));
lifetimes.N = lifetimes.SUM;

for i = 1:numel(lifetimes.ALL)
    lifetimes.ALL{i} = lifetimes.ALL{i}*2*tpf/1000;
    if ~isempty(lifetimes.ALL{i})
        Tmax = max(Tmax,max(lifetimes.ALL{i}));
    end
    lifetimes.SUM(i) = sum(lifetimes.ALL{i});
    lifetimes.N(i) = numel(lifetimes.ALL{i});
    lifetimes.MEAN(i) = mean(lifetimes.ALL{i});
end

%%
INdices = 1:size(lifetimes.ALL,1);

display('Evaluation of taus...')
[khat, tauhat] = get_corrected_rates({vertcat(lifetimes.ALL{INdices,1}) vertcat(lifetimes.ALL{INdices,2})},Tmin,Tmax);
[~, tauhatNC] = get_corrected_rates({vertcat(lifetimes.ALL{INdices,1}) vertcat(lifetimes.ALL{INdices,2})},[0 0],Inf);
taus = 1./khat;
Ns = [0 0];
stDevs = [0 0];
SEMs = [0 0];

display(['Bound tau: ' num2str(taus(1)) ', unbound tau: ' num2str(taus(2))])

Nmult = [0 0];
for k = 1:2
    Nmult(k) = exp(Tmin(k)*khat(k));
end

pIN = zeros(size(lifetimes.ALL,1),2);

for i = 1:size(lifetimes.ALL,1)
%     for k = 1:2
%         pIN(i,k) = erlangcdf(lifetimes.SUM(i,k),khat(k),Nmult(k)*lifetimes.N(i,k));
%     end
    pIN(i,1) = erlangcdf(lifetimes.SUM(i,1),khat(1),Nmult(1)*lifetimes.N(i,1)+(1-1/Nmult(2))*lifetimes.N(i,2));
    pIN(i,2) = erlangcdf(lifetimes.SUM(i,2),khat(2),Nmult(2)*lifetimes.N(i,2)+(1-1/Nmult(1))*lifetimes.N(i,1));
end

for i = 1:2
    Ns(i) = length(vertcat(lifetimes.ALL{INdices,i}));
    stDevs(i) = std(vertcat(lifetimes.ALL{INdices,i}));
    SEMs(i) = stDevs(i)/sqrt(Ns(i));
end

display([num2str(length(INdices)) ' spots, ' num2str(Ns(1)) ' bound lifetimes, ' num2str(Ns(2)) ' unbound lifetimes.'])

%% Probability plots
NONZEROS = nnz(min(lifetimes.N,[],2));
counts = zeros(50,1);
i = 0;
go_on = 1;
while go_on
    i = i+1;
    counts(i) = sum(min(pIN,[],2)>10^-i & max(pIN,[],2)<(1-10^-i));
    go_on = counts(i)<NONZEROS;
end
counts = counts(1:i);

figure
for k = 1:2
    subplot(1,2,k)
    histogram(pIN(:,k))
end

figure
bar(-1:-1:-length(counts),counts)
for i = 1:length(counts)
    text(-i,max(counts),num2str(counts(i)),'HorizontalAlignment','center','VerticalAlignment','bottom')
end
xlabel('probability limit (log10)')
ylabel('counts, N_{in}', 'Interpreter', 'tex')
title(['Number of spots with nonzero lifetimes in both states: ' num2str(NONZEROS) sprintf('\n')], 'FontSize', 12)
print('-dpng','-r96','nINoverLim.png')
%% Save data

save lts_main_pop.mat lifetimes INdices taus Ns stDevs SEMs
fileID = fopen('taus_main_pop.txt', 'w');
fprintf(fileID, 'tau_b\ttau_u\tN_b\tN_u\tstDev_b\tstDev_u\n');
fprintf(fileID, [num2str(taus(1)) '\t' num2str(taus(2)) '\t']);
fprintf(fileID, [num2str(Ns(1)) '\t' num2str(Ns(2)) '\t']);
fprintf(fileID, [num2str(stDevs(1)) '\t' num2str(stDevs(2))]);
fclose(fileID);
%% Plots
LT = {vertcat(lifetimes.ALL{INdices,1}) vertcat(lifetimes.ALL{INdices,2})};
exppdf_mod = @(t,tau,Tmin,Tmax)1./tau.*exp(-t./tau)./(exp(-Tmin./tau)-exp(-Tmax./tau));
expcdf_mod = @(t,tau,Tmin,Tmax)(exp(-t./tau)-exp(-Tmin./tau))/(exp(-Tmax./tau)-exp(-Tmin./tau));
colors = {[204 0 0]/255,[0 102 153]/255};
cf = figure('Units', 'normalized', 'Position', [0 0 1 1], 'PaperPositionMode', 'auto');
for state = 1:2
    %
    Tmax = max(LT{state}) + 0.1;
    centers = logspace(-2,log10(Tmax),2000);
    cumcts = zeros(size(centers));
    for i = 1:length(centers)
        cumcts(i) = sum(LT{state}<=centers(i));
    end
    cumcts = cumcts/cumcts(end);
    tmax = centers(find(cumcts>.999,1));

    % histogram
    subplot(2,2,1+2*(state-1))
    hold off
    hg = histogram(LT{state},'Normalization','pdf','BinMethod','scott');
    hg.FaceColor = colors{state};
    hg.EdgeColor = 'white';
    hg.FaceAlpha = 1;
    hold on
    ts = linspace(Tmin(state),centers(end),1001);
    plot(ts,exppdf_mod(ts,tauhat(state),Tmin(state),Tmax), 'k--', 'LineWidth',1)
    plot(ts,exppdf(ts,taus(state)), 'k:', 'LineWidth',1)
    xlim([0 tmax])
    ax = gca;
    ax.TickDir = 'out';
    xlabel('lifetime (s)', 'FontSize', 12)
    ylabel('Relative frequency / Probability density', 'FontSize', 12)
    box off

    % cdf
    subplot(2,2,2+2*(state-1))
    hold off
    semilogx(centers,cumcts,'Color',colors{state},'LineWidth',1)
    hold on
    ts = logspace(log10(Tmin(state)-0.1),log10(centers(end)),2e3);
    semilogx(ts,expcdf_mod(ts,tauhat(state),Tmin(state),Tmax),'k--','LineWidth',1)
    semilogx(ts,expcdf(ts,taus(state)),'k:','LineWidth',1)
    xlim([Tmin(state)-0.1 tmax])
    ylim([0 1])
    ax = gca;
    ax.TickDir = 'out';
    ax.YTick = [0 .5 1];
    %ax.YTickLabel = {};
    xlabel('lifetime (s)', 'FontSize', 12)
    ylabel('Cumulative frequency / Probability', 'FontSize', 12)
    box off
    
    subplot(2,2,1)
    title(['PDF for state 1 (bound), tau = ' num2str(round(taus(1),2)) ' s, tauhat = ' num2str(round(tauhat(1),2)) ' s, N = ' num2str(Ns(1))], 'FontSize', 16)
    subplot(2,2,2)
    title(['CDF for state 1 (bound), tau = ' num2str(round(taus(1),2)) ' s, tauhat = ' num2str(round(tauhat(1),2)) ' s, N = ' num2str(Ns(1))], 'FontSize', 16)
    subplot(2,2,3)
    title(['PDF for state 2 (unbound), tau = ' num2str(round(taus(2),2)) ' s, tauhat = ' num2str(round(tauhat(2),2)) ' s, N = ' num2str(Ns(2))], 'FontSize', 16)
    subplot(2,2,4)
    title(['CDF for state 2 (unbound), tau = ' num2str(round(taus(2),2)) ' s, tauhat = ' num2str(round(tauhat(2),2)) ' s, N = ' num2str(Ns(2))], 'FontSize', 16)
end
print('-dpng','-r150','LifetimeDistributions.png')

%% Error estimate by bootstrapping:
% bootstat = cell(size(LT));
% bootsam = cell(size(LT));
% for s = 2:-1:1
%     [bootstat{s},bootsam{s}] = bootstrp(1000,@mean,LT{s});
% end
% bootkhat = zeros(1000,2);
% for i = 1:1000
%     bootkhat(i,:) = get_corrected_rates({LT{1}(bootsam{1}(:,i)) LT{2}(bootsam{2}(:,i))},Tmin,1000);
% end
% figure
% for k = 1:2
%     subplot(2,2,k)
%     histogram(1./bootkhat(:,k))
%     subplot(2,2,k+2)
%     histogram(bootstat{k})
% end