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
        tmp = inputdlg(indquest, 'Movie indices',1);
        for j = 1:Nspecies
            movInds{i,j} = str2num(tmp{j});
        end
    else
        movInds{i} = unique(hops{i}.indices(:,1));
    end
end
clear tmp

%%
Ntraj = zeros(Nsamples,Nspecies);
for i = 1:Nsamples
    for j = 1:Nspecies
        Ntraj(i,j) = sum(ismember(hops{i}.indices(:,1),movInds{i,j}));
    end
end

%% set parameters for missed-event correction
Fmin = [13 7];
Tmin = round(0.1*Fmin,1);
Tmax = 0;

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
    lifetimes{j}.ScatDat = zeros(sum(Ntraj(:,j)),6);
    counter = 0;
    for i = 1:Nsamples
        tmp = cell(size(movInds{i,j}));
        for m = 1:length(tmp)
            tmp{m} = hops{i}.tpf(movInds{i,j}(m))*ones(length(hops{i}.results{movInds{i,j}(m)}),1);
        end
        tpfALL{j}(counter + (1:Ntraj(i,j))) = vertcat(tmp{:});
        lifetimes{j}.ScatDat(counter + (1:Ntraj(i,j)),5) = ones(Ntraj(i,j),1)*i;
        lifetimes{j}.ScatDat(counter + (1:Ntraj(i,j)),6) = hops{i}.indices(ismember(hops{i}.indices(:,1),movInds{i,j}),1);
        resultsALL{j}(counter + (1:Ntraj(i,j))) = vertcat(hops{i}.results{movInds{i,j}});        
        counter = sum(Ntraj(1:i,j));
    end
    % fill in lifetimes
    for i = 1:size(lifetimes{j}.ALL,1)
        if ~isempty(resultsALL{j}{i}.state_trajectory)
            lifetimes{j}.ALL(i,:) = lts_strict_cutoff({resultsALL{j}{i}.state_trajectory},Fmin,{resultsALL{j}{i}.ex_int});
        end
        for k = 1:2
            lifetimes{j}.ALL{i,k} = lifetimes{j}.ALL{i,k}.*2*tpfALL{j}(i)/1000;
            lifetimes{j}.SUM(i,k) = sum(lifetimes{j}.ALL{i,k});
            lifetimes{j}.N(i,k) = length(lifetimes{j}.ALL{i,k});
            if ~isempty(lifetimes{j}.ALL{i,k})
                Tmax = max(Tmax,max(lifetimes{j}.ALL{i,k}));
            end
        end
        if ~isempty(resultsALL{j}{i}.hi) && ~isempty(resultsALL{j}{i}.lo)
            lifetimes{j}.ScatDat(i,1:2) = [mean(resultsALL{j}{i}.lo(:,2)) mean(resultsALL{j}{i}.hi(:,2))]*2*tpfALL{j}(i)/1000;
            lifetimes{j}.ScatDat(i,3:4) = [std(resultsALL{j}{i}.lo(:,2))/sqrt(size(resultsALL{j}{i}.lo,1)) ...
                                    std(resultsALL{j}{i}.hi(:,2))/sqrt(size(resultsALL{j}{i}.hi,1))]*2*tpfALL{j}(i)/1000;
        end
    end
    lifetimes{j}.MEAN = lifetimes{j}.SUM./lifetimes{j}.N;
end
clear resultsALL tpfALL
%%
close all
surfig = figure('Units','normalized','Position',[0 .5 1 .5]);
dotfig = figure('Units','normalized','Position',[0 0 1 1]);
INdices = cell(Nspecies,1);
taus = zeros(Nspecies,2);
tauhats = zeros(Nspecies,2);
Ns = zeros(Nspecies,2);
stDevs = zeros(Nspecies,2);
SEMs = zeros(Nspecies,2);
for j = 1:Nspecies
    display('Determining initial INdices...')
    tauRange = cell(2,1);
    for s = 1:2
        tmp = sort(vertcat(lifetimes{j}.ALL{:,s}));
        tauRange{s} = linspace(tmp(ceil(0.01*length(tmp))),tmp(floor(0.99*length(tmp))),100);
    end

    lim = [1e-4 0];
    lim(2) = 1-lim(1);

    iRange = cell(length(tauRange{1}),length(tauRange{1}));
    nRange = zeros(length(tauRange{1}),length(tauRange{1}));
    for i1 = 1:length(tauRange{1})
        for i2 = 1:length(tauRange{2})
            tmpI = zeros(size(lifetimes{j}.SUM,1),1);
            tmpTaus = [tauRange{1}(i1) tauRange{2}(i2)];
            Nmult = exp(Tmin./tmpTaus);
            n = 0;
            for k = 1:size(lifetimes{j}.SUM,1)
                tmp = [0 0];
%                 tmp(1) = erlangcdf(lifetimes{j}.SUM(k,1),1/tmpTaus(1),Nmult(1)*lifetimes{j}.N(k,1));
%                 tmp(2) = erlangcdf(lifetimes{j}.SUM(k,2),1/tmpTaus(2),Nmult(2)*lifetimes{j}.N(k,2));
                tmp(1) = erlangcdf(lifetimes{j}.SUM(k,1),1/tmpTaus(1),Nmult(1)*lifetimes{j}.N(k,1)+(1-1/Nmult(2))*lifetimes{j}.N(k,2));
                tmp(2) = erlangcdf(lifetimes{j}.SUM(k,2),1/tmpTaus(2),Nmult(2)*lifetimes{j}.N(k,2)+(1-1/Nmult(1))*lifetimes{j}.N(k,1));
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
    lim = [1e-4 0];
    lim(2) = 1-lim(1);
    display('Re-evaluation of taus and INdices...')
    go_on = 1;
    while go_on
        INdicesOld = INdices{j};
        Tmax = 0;
        for i = INdices{j}'
            for k = 1:2
                if ~isempty(lifetimes{j}.ALL{i,k})
                    Tmax = max(Tmax,max(lifetimes{j}.ALL{i,k}));
                end
            end
        end
        [khat, tauhats(j,:)] = get_corrected_rates({vertcat(lifetimes{j}.ALL{INdices{j},1}) vertcat(lifetimes{j}.ALL{INdices{j},2})},Tmin,Tmax);
        taus(j,:) = 1./khat;
        display(['Bound tau: ' num2str(taus(j,1)) ', unbound tau: ' num2str(taus(j,2))])
        Nmult = [0 0];
        for k = 1:2
            Nmult(k) = exp(Tmin(k)*khat(k));
        end
        tmpI = zeros(size(lifetimes{j}.SUM,1),1);
        for k = 1:size(lifetimes{j}.SUM,1)
            tmp = [0 0];
        %     tmp(1) = erlangcdf(lifetimes{j}.SUM(k,1),khat(1),Nmult(1)*lifetimes{j}.N(k,1));
        %     tmp(2) = erlangcdf(lifetimes{j}.SUM(k,2),khat(2),Nmult(2)*lifetimes{j}.N(k,2));
            tmp(1) = erlangcdf(lifetimes{j}.SUM(k,1),khat(1),Nmult(1)*lifetimes{j}.N(k,1)+(1-1/Nmult(2))*lifetimes{j}.N(k,2));
            tmp(2) = erlangcdf(lifetimes{j}.SUM(k,2),khat(2),Nmult(2)*lifetimes{j}.N(k,2)+(1-1/Nmult(1))*lifetimes{j}.N(k,1));
            if min(tmp)>=lim(1) && max(tmp)<=lim(2)
                tmpI(k) = 1;
            else
                display(['Removing index ' num2str(k) ' from analysis.'])
                display(['P_state1 = ' num2str(tmp(1),12) ', P_state2 = ' num2str(tmp(2),12)])
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
save lts_main_pop.mat filepaths hops Names Fmin Tmin Tmax lifetimes INdices taus tauhats Ns stDevs SEMs
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
exppdf_mod = @(t,tau,Tmin,Tmax)1./tau.*exp(-t./tau)./(exp(-Tmin./tau)-exp(-Tmax./tau));
expcdf_mod = @(t,tau,Tmin,Tmax)(exp(-t./tau)-exp(-Tmin./tau))/(exp(-Tmax./tau)-exp(-Tmin./tau));
colors = {[204 0 0]/255,[0 102 153]/255};
for j = 1:Nspecies
    figure('Units', 'normalized', 'Position', [0 0 1 1], 'PaperPositionMode', 'auto');
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
        edges = hg.BinEdges + Tmin(state)-hg.BinEdges(1);
        hg = histogram(lt_state,edges,'Normalization','pdf');
        hg.FaceColor = colors{state};
        hg.EdgeColor = 'white';
        hg.FaceAlpha = 1;
        hold on
        ts = linspace(Tmin(state),centers(end),1001);
        plot(ts,exppdf_mod(ts,tauhats(j,state),Tmin(state),Tmax), 'k--', 'LineWidth',1)
        plot(centers,exppdf(centers,taus(j,state)), 'k:', 'LineWidth',1)
        xlim([0 tmax])
        ax = gca;
        ax.TickDir = 'out';
        xlabel('lifetime (s)', 'FontSize', 14)
        ylabel('Relative frequency / Probability density', 'FontSize', 14)
        box off

        % cdf
        subplot(2,2,2+2*(state-1))
        hold off
        semilogx(centers,cumcts,'Color',colors{state},'LineWidth',1)
        hold on
        ts = logspace(log10(Tmin(state)-.1),log10(centers(end)),2e3);
        semilogx(ts,expcdf_mod(ts,tauhats(j,state),Tmin(state),Tmax),'k--','LineWidth',1)
        semilogx(ts,expcdf(ts,taus(j,state)),'k:','LineWidth',1)
        xlim([Tmin(state)-.1 tmax])
        ylim([0 1])
        ax = gca;
        ax.TickDir = 'out';
        ax.YTick = [0 .5 1];
        %ax.YTickLabel = {};
        xlabel('lifetime (s)', 'FontSize', 14)
        ylabel('Cumulative frequency / Probability', 'FontSize', 14)
        box off

        subplot(2,2,1)
        title(['PDF for state 1 (bound), \tau_{final} = ' num2str(round(taus(j,1),2)) ' s, \tau_{MLE} = ' num2str(round(tauhats(j,1),2)) ' s, N = ' num2str(Ns(j,1))], 'FontSize', 18, 'Interpreter', 'tex')
        subplot(2,2,2)
        title(['CDF for state 1 (bound), \tau_{final} = ' num2str(round(taus(j,1),2)) ' s, \tau_{MLE} = ' num2str(round(tauhats(j,1),2)) ' s, N = ' num2str(Ns(j,1))], 'FontSize', 18, 'Interpreter', 'tex')
        subplot(2,2,3)
        title(['PDF for state 2 (unbound), \tau_{final} = ' num2str(round(taus(j,2),2)) ' s, \tau_{MLE} = ' num2str(round(tauhats(j,2),2)) ' s, N = ' num2str(Ns(j,2))], 'FontSize', 18, 'Interpreter', 'tex')
        subplot(2,2,4)
        title(['CDF for state 2 (unbound), \tau_{final} = ' num2str(round(taus(j,2),2)) ' s, \tau_{MLE} = ' num2str(round(tauhats(j,2),2)) ' s, N = ' num2str(Ns(j,2))], 'FontSize', 18, 'Interpreter', 'tex')
        
        [~,h] = suplabel(['Species ' num2str(j) ': ' Names{j}],'t');
        set(h,'FontSize',20)
    end
    print('-dpng','-r150',['LifetimeDistributions_' Names{j} '.png'])
end

%% Produce text files for main population scatter plotting
tmp = inputdlg({'Enter sample ID:'},'SID',1,{'M000'});
SID = tmp{1};
OUTdices = cell(size(INdices));
for j = 1:numel(INdices)
    OUTdices{j} = setdiff(1:size(lifetimes{j}.ALL,1),INdices{j});
    OUTdices{j} = reshape(OUTdices{j},[],1);
end

for j = 1:Nspecies    
    % write .txt file IN
    ID = [SID '_IN_' Names{j}];
    wave_names = {[ID '_mTb'],[ID '_mTu'],[ID '_SEMb'],[ID '_SEMu'], [ID '_sample'], [ID '_movie']};
    fileID=fopen(ID, 'w'); %open file to write
    for i=1:6            %write wavenames at each column header
        fprintf(fileID, [wave_names{i} '\t']);
    end
    fprintf(fileID,'\n');
    fclose(fileID);
    % append data
    dlmwrite(ID, lifetimes{j}.ScatDat(INdices{j},:), 'delimiter', '\t','-append')
    
    % write .txt file OUT
    ID = [SID '_OUT_' Names{j}];
    wave_names = {[ID '_mTb'],[ID '_mTu'],[ID '_SEMb'],[ID '_SEMu'], [ID '_sample'], [ID '_movie']};
    fileID=fopen(ID, 'w'); %open file to write
    for i=1:6            %write wavenames at each column header
        fprintf(fileID, [wave_names{i} '\t']);
    end
    fprintf(fileID,'\n');
    fclose(fileID);
    % append data
    dlmwrite(ID, lifetimes{j}.ScatDat(OUTdices{j},:), 'delimiter', '\t','-append')    
end
display('Done writing text file for scatter plot of main population')
%% Error estimate by bootstrapping:
%{
LT = {vertcat(lifetimes{1}.ALL{:,1}) vertcat(lifetimes{1}.ALL{:,2})}; % only works for Nspecies = 1;
bootstat = cell(size(LT));
bootsam = cell(size(LT));
for s = 2:-1:1
    [bootstat{s},bootsam{s}] = bootstrp(1000,@mean,LT{s});
end
bootkhat = zeros(1000,2);
for i = 1:1000
    bootkhat(i,:) = get_corrected_rates({LT{1}(bootsam{1}(:,i)) LT{2}(bootsam{2}(:,i))},Tmin,Tmax);
end
figure
for k = 1:2
    subplot(2,2,k)
    histogram(1./bootkhat(:,k))
    subplot(2,2,k+2)
    histogram(bootstat{k})
end
%}