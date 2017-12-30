%% Startup
clear variables
close all
run('my_prefs.m')

%% Extract relevant data from hop struct
Nsamples = str2double(inputdlg('How many samples?', 'Nsamples', 1, {'1'}));
Nspecies = str2double(inputdlg('How many species?', 'Nspecies', 1, {'1'}));
isnost = strcmp(questdlg('Before or after non-stick correction?','Nost?','Before','After','Before'),'After');
if isnost
    filedef = '*dataPostHMM_nost.mat';
else
    filedef = '*dataPostHMM.mat';
end
filepaths = cell(Nsamples,1);
hops = cell(Nsamples,1);
if Nspecies > 1
    % Names of species
    nameprompt = cell(Nspecies,1);
    defnames = cell(size(nameprompt));
    indexprompt = cell(Nspecies,1);
    for i = 1:Nspecies
        nameprompt{i} = ['Name of species ' num2str(i) ':'];
        defnames{i} = ['species ' num2str(i)];
        indexprompt{i} = ['Movies for species #' num2str(i) ':'];
    end
    Names = inputdlg(nameprompt, 'Names of species', 1, defnames);
else
    Names = {''};
end
% Movie indices in species
movInds = cell(Nsamples,Nspecies);
for i = 1:Nsamples
    [filename, pathname] = uigetfile([data_dir filesep filedef],['Pick sample file number ' num2str(i)]);
    filepaths{i} = [pathname filename];
    if isnost
        load(filepaths{i},'outputPostHMM_nost');
        hops{i} = outputPostHMM_nost.hop;
    else
        load(filepaths{i},'outputPostHMM');
        hops{i} = outputPostHMM.hop;
    end
    if Nspecies>1
        tmp = inputdlg(indexprompt, 'Movie indices',1);
        for j = 1:Nspecies
            movInds{i,j} = str2num(tmp{j});
        end
    else
        movInds{i} = unique(hops{i}.indices(:,1));
    end
end
clear tmp

%%
%{
movInds = cell(Nsamples,Nspecies);
for i = 1:Nsamples
    if Nspecies>1
        foo = regexp(tmpI{i},';');
        movInds(i,1) = textscan(tmpI{i}(1:foo(1)-1),'%d','Delimiter',{',',' '},'MultipleDelimsAsOne',1);
        for j = 2:Nspecies-1
            movInds(i,j) = textscan(tmpI{i}(foo(j-1)+1:foo(j)-1),'%d','Delimiter',{',',' '},'MultipleDelimsAsOne',1);
        end
        movInds(i,end) = textscan(tmpI{i}(foo(end)+1:end),'%d','Delimiter',{',',' ',';'},'MultipleDelimsAsOne',1);
    else
        movInds{i} = unique(hops{i}.indices(:,1));
    end
end
%}

%%
Ntraj = zeros(Nsamples,Nspecies);
for i = 1:Nsamples
    for j = 1:Nspecies
        Ntraj(i,j) = sum(ismember(hops{i}.indices(:,1),movInds{i,j}));
    end
end

%%
resultsALL = cell(Nspecies,1);
tpfALL = cell(Nspecies,1);
lifetimes = cell(Nspecies,1);
for j = 1:Nspecies
    resultsALL{j} = cell(sum(Ntraj(:,j)),1);
    tpfALL{j} = zeros(sum(Ntraj(:,j)),1);
    lifetimes{j}.MEAN = zeros(sum(Ntraj(:,j)),2);
    lifetimes{j}.SUM = zeros(size(lifetimes{j}.MEAN));
    lifetimes{j}.N = lifetimes{j}.SUM;
    lifetimes{j}.ALL = cell(size(lifetimes{j}.MEAN));
    counter = 0;
    for i = 1:Nsamples
        tmp = cell(size(movInds{i,j}));
        for m = 1:length(tmp)
            tmp{m} = hops{i}.tpf(movInds{i,j}(m))*ones(length(hops{i}.results{movInds{i,j}(m)}),1);
        end
        tpfALL{j}(counter + (1:Ntraj(i,j))) = vertcat(tmp{:});
        resultsALL{j}(counter + (1:Ntraj(i,j))) = vertcat(hops{i}.results{movInds{i,j}});        
        counter = sum(Ntraj(1:i,j));
    end
    % fill in lifetimes
    for i = 1:size(lifetimes{j}.ALL,1)
        if ~isempty(resultsALL{j}{i}.lo)
            lifetimes{j}.ALL{i,1} = resultsALL{j}{i}.lo(:,2)*tpfALL{j}(i)*2/1000;
        end
        if ~isempty(resultsALL{j}{i}.hi)
            lifetimes{j}.ALL{i,2} = resultsALL{j}{i}.hi(:,2)*tpfALL{j}(i)*2/1000;
        end
        for k = 1:2
            lifetimes{j}.SUM(i,k) = sum(lifetimes{j}.ALL{i,k});
            lifetimes{j}.N(i,k) = length(lifetimes{j}.ALL{i,k});
        end
        lifetimes{j}.MEAN = lifetimes{j}.SUM./lifetimes{j}.N;
    end
end

%%
close all
surfig = figure('Units','normalized','Position',[0 .5 1 .5]);
dotfig = figure('Units','normalized','Position',[0 0 1 1]);
INdices = cell(Nspecies,1);
taus = zeros(Nspecies,2);
Ns = zeros(Nspecies,2);
stDevs = zeros(Nspecies,2);
SEMs = zeros(Nspecies,2);
for j = 1:Nspecies
    display([Names{j} ': Determining initial INdices...')
    tauRange = cell(2,1);
    for s = 1:2
        %tmp = sort(lifetimes.MEAN(:,s));
        tmp = sort(vertcat(lifetimes{j}.ALL{:,s}));
        tauRange{s} = linspace(tmp(ceil(0.01*length(tmp))),tmp(floor(0.99*length(tmp))),100);
        %tauRange{s} = linspace(tmp(1),tmp(end),100);
        %tauRange{s} = linspace(0.1*tmp(1),tmp(floor(0.95*length(tmp))),100);%tmp(end),100);
    end

    lim = [1e-4 0];
    lim(2) = 1-lim(1);

    iRange = cell(length(tauRange{1}),length(tauRange{1}));
    nRange = zeros(length(tauRange{1}),length(tauRange{1}));
    for i1 = 1:length(tauRange{1})
        for i2 = 1:length(tauRange{2})
            tmpI = zeros(size(lifetimes{j}.SUM,1),1);
            n = 0;
            for k = 1:size(lifetimes{j}.SUM,1)
                tmp = [0 0];
                tmp(1) = erlangcdf(lifetimes{j}.SUM(k,1),1/tauRange{1}(i1),lifetimes{j}.N(k,1));
                tmp(2) = erlangcdf(lifetimes{j}.SUM(k,2),1/tauRange{2}(i2),lifetimes{j}.N(k,2));
                %disp(prod(tmp))
                if min(tmp)>=lim(1) && max(tmp)<=lim(2)
                    n = n+1;
                    tmpI(k) = 1;
                end
            end
            iRange{i1,i2} = find(tmpI==1);
            nRange(i1,i2) = n;
        end
    end
    figure(surfig)
    subplot(1,Nspecies,j)
    surf(tauRange{1},tauRange{2},nRange)
    title(['Species ' num2str(j) ' (' Names{j} ').'],'FontSize',12)
    
    %
    tmpI = find(nRange==max(nRange(:)));
    INdices{j} = [];
    for i = reshape(tmpI,1,[])
        INdices{j} = union(INdices{j},iRange{i});
    end

    %
    figure(dotfig)
    subplot(2,Nspecies,j)
    plot(lifetimes{j}.MEAN(:,2),lifetimes{j}.MEAN(:,1),'.')
    hold on
    plot(lifetimes{j}.MEAN(INdices{j},2),lifetimes{j}.MEAN(INdices{j},1),'ko')
    title(['Bound vs. unbound lifetimes, species ' num2str(j) ' (' Names{j} '). Initial nIN: ' num2str(length(INdices{j}))],'FontSize',12)
    display([num2str(length(INdices{j})) ' spots, ' num2str(length(vertcat(lifetimes{j}.ALL{INdices{j},1}))) ' bound lifetimes, ' num2str(length(vertcat(lifetimes{j}.ALL{INdices{j},2}))) ' unbound lifetimes.'])

    %
    display('Re-evaluation of taus and INdices...')
    go_on = 1;
    while go_on
        INdicesOld = INdices{j};
        for k = 1:2
            taus(j,k) = mean(vertcat(lifetimes{j}.ALL{INdices{j},k}));
        end
        display(['Bound tau: ' num2str(taus(j,1)) ', unbound tau: ' num2str(taus(j,2))])
        tmpI = zeros(size(lifetimes{j}.SUM,1),1);
        for i = reshape(INdices{j},1,[])
            tmp = [0 0];
            tmp(1) = erlangcdf(lifetimes{j}.SUM(i,1),1/taus(j,1),lifetimes{j}.N(i,1));
            tmp(2) = erlangcdf(lifetimes{j}.SUM(i,2),1/taus(j,2),lifetimes{j}.N(i,2));
            if min(tmp)>=lim(1) && max(tmp)<=lim(2)
                tmpI(i) = 1;
            end
        end
        INdices{j} = find(tmpI==1);
        for k = 1:2
            Ns(j,k) = length(vertcat(lifetimes{j}.ALL{INdices{j},k}));
            stDevs(j,k) = std(vertcat(lifetimes{j}.ALL{INdices{j},k}));
            SEMs(j,k) = stDevs(j,k)/sqrt(Ns(j,k));
        end
        display([num2str(length(INdices{j})) ' spots, ' num2str(Ns(j,1)) ' bound lifetimes, ' num2str(Ns(j,2)) ' unbound lifetimes.'])
        go_on = ~isequal(INdices{j},INdicesOld);
    end
    subplot(2,Nspecies,Nspecies+j)
    plot(lifetimes{j}.MEAN(:,2),lifetimes{j}.MEAN(:,1),'.')
    hold on
    plot(lifetimes{j}.MEAN(INdices{j},2),lifetimes{j}.MEAN(INdices{j},1),'ko')
    title(['Bound vs. unbound lifetimes, species ' num2str(j) ' (' Names{j} '). Final nIN: ' num2str(length(INdices{j}))],'FontSize',12)
end

%% Save data
if size(hops,1)==1
    savepath = pathname;
else
    display('Choose folder for results in save dialog')
    [~,savepath] = uiputfile;
end
cd(savepath)
save lts_main_pop.mat lifetimes INdices taus Ns stDevs SEMs
fileID = fopen('taus_main_pop.txt', 'w');
fprintf(fileID, 'tau_b\ttau_u\tN_b\tN_u\tstDev_b\tstDev_u\n');
for j = 1:Nspecies
    fprintf(fileID, [num2str(taus(j,1),'%.2f') '\t' num2str(taus(j,2),'%.2f') '\t']);
    fprintf(fileID, [num2str(Ns(j,1),'%d') '\t' num2str(Ns(j,2),'%d') '\t']);
    fprintf(fileID, [num2str(stDevs(j,1),'%.2f') '\t' num2str(stDevs(j,2),'%.2f') '\n']);
end
fclose(fileID);

%% Plots
close all
colors = {[204 0 0]/255,[0 102 153]/255};
cf = figure('Units', 'normalized', 'Position', [0 0 1 1], 'PaperPositionMode', 'auto');
for j = 1:Nspecies
    for state = 1:2
        lt_state = sort(vertcat(lifetimes{j}.ALL{INdices{j},state}));
        Tmax = max(lt_state)+0.1;
        %
        centers = logspace(-2,log10(Tmax),2e3);
        cumcts = zeros(size(centers));
        for i = 1:length(centers)
            cumcts(i) = sum(lt_state<=centers(i));
        end
        cumcts = cumcts/cumcts(end);
        tmax = centers(find(cumcts>.999,1));

        % histogram
        subplot(2,2,1+2*(state-1))
        hold off
        hg = histogram(lt_state,'Normalization','pdf','BinMethod','scott');
        hg.FaceColor = colors{state};
        hg.EdgeColor = 'white';
        hg.FaceAlpha = 1;
        hold on
        tau = taus(j,state);
        ts = 0:1000;
        plot(ts,1./tau.*exp(-ts./tau), 'k--', 'LineWidth',1)
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
        tau = taus(j,state);
        semilogx(centers,cdf('Exponential',centers,tau),'k--','LineWidth',1)
        xlim([0.1 tmax])
        ax = gca;
        ax.TickDir = 'out';
        ax.YTick = [0 .5 1];
        %ax.YTickLabel = {};
        xlabel('lifetime (s)', 'FontSize', 12)
        ylabel('Cumulative frequency / Probability', 'FontSize', 12)
        box off

        subplot(2,2,1)
        title(['PDF for state 1 (bound), tau = ' num2str(round(taus(j,1),2)) ' +/- ' num2str(round(SEMs(j,1),2)) ' seconds, N = ' num2str(Ns(j,1))], 'FontSize', 16)
        subplot(2,2,2)
        title(['CDF for state 1 (bound), tau = ' num2str(round(taus(j,1),2)) ' +/- ' num2str(round(SEMs(j,1),2)) ' seconds, N = ' num2str(Ns(j,1))], 'FontSize', 16)
        subplot(2,2,3)
        title(['PDF for state 2 (unbound), tau = ' num2str(round(taus(j,2),2)) ' +/- ' num2str(round(SEMs(j,2),2)) ' seconds, N = ' num2str(Ns(j,2))], 'FontSize', 16)
        subplot(2,2,4)
        title(['CDF for state 2 (unbound), tau = ' num2str(round(taus(j,2),2)) ' +/- ' num2str(round(SEMs(j,2),2)) ' seconds, N = ' num2str(Ns(j,2))], 'FontSize', 16)
        
        [~,h] = suplabel(['Species ' num2str(j) ': ' Names{j}],'t');
        set(h,'FontSize',16)
    end
    print('-dpng','-r150',['LifetimeDistributions_' Names{j} '.png'])
end