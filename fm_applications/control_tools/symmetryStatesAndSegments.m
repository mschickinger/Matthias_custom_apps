% Symmetrie in HMM-ausgewerteten Datensaetzen

%% Reset und Verzeichnisauswahl
%{
clear variables
close all
run('my_prefs.m')
loadpath = [uigetdir(data_dir) filesep];
%}

% Suche SID
SID = 'TBA';
txt = dir([loadpath '*.txt']);
for i = 1:numel(txt)
    if strcmp(txt(i).name(1:2),'S0')
        SID = txt(i).name(1:4);
    break
    end
end

% Lade Daten
load([loadpath 'HMMdata2.mat'],'medI','arxv','state_trajectories','iEdges','indicesHMM')
load([loadpath 'sticky.mat'],'stickinDices')
load([loadpath 'HMMsortout.mat'],'index_discard')

% Erstelle Output-Ordner
%{
tmp = regexp(loadpath,filesep);
tmp = loadpath(tmp(end-2)+1:tmp(end-1)-1);
path_out = [tmp(1:4) tmp(6:7) tmp(9:end)];
path_out = inputdlg('path_out','path_out',1,{path_out});
path_out = ['/Users/matthiasschickinger/LRZ Sync+Share/FM_Analyse/MitInteraktion/' path_out{1} filesep];
display(path_out)
mkdir(path_out)
cd('/Users/matthiasschickinger/LRZ Sync+Share/FM_Analyse/MitInteraktion/')
%}

% Pre-index symCell
symCell = cell(numel(iEdges)+1,2);
for s = 1:numel(iEdges)+1
    for k = 1:2
        symCell{s,k} = nan(numel(medI),4);
    end
end

% Fill symCell with values N, sigmaX, sigmaY, symmetry ratio
tmpST = cell(2,1);
for i = setdiff(1:numel(medI),index_discard)
    for k = 1:2
        tmpST{k} = setdiff(find(state_trajectories{i}==k),stickinDices{i});
    end
    [tmpS, tmpSind] = iSegments(medI{i},iEdges);
    % Individual segments
    for j = 1:size(tmpS,1)
        tmpI = tmpS(j,1):tmpS(j,2);
        for k = 1:2
            tmpIST = intersect(tmpI,tmpST{k});
            if ~isempty(tmpIST)
                % N
                symCell{tmpSind(j),k}(i,1) = numel(tmpIST);
                % sigmaX, sigmaY
                for d = 1:2
                    symCell{tmpSind(j),k}(i,d+1) = nanstd(arxv{i}.XY(d,tmpIST));
                end
                % symmetry ratio
                tmpE = eig(cov(arxv{i}.XY(1,tmpIST),arxv{i}.XY(2,tmpIST)));
                symCell{tmpSind(j),k}(i,4) = sqrt(max(tmpE)/min(tmpE));
            else
                % N = 0
                symCell{tmpSind(j),k}(i,1) = 0;
            end
        end
    end
    %
    % Combine all segments
    tmpI = tmpS(1):tmpS(end);
    for k = 1:2
        tmpIST = intersect(tmpI,tmpST{k});
        if ~isempty(tmpIST)
            % N
            symCell{numel(iEdges)+1,k}(i,1) = numel(tmpIST);
            % sigmaX, sigmaY
            for d = 1:2
                symCell{numel(iEdges)+1,k}(i,d+1) = nanstd(arxv{i}.XY(d,tmpIST));
            end
            % symmetry ratio
            tmpE = eig(cov(arxv{i}.XY(1,tmpIST),arxv{i}.XY(2,tmpIST)));
            symCell{numel(iEdges)+1,k}(i,4) = sqrt(max(tmpE)/min(tmpE));
        else
            % N = 0
            symCell{numel(iEdges)+1,k}(i,1) = 0;
        end
    end
    %}
    %sprintf('Object %d of %d done.',i,numel(medI)) 
end

% Indices of asymmetrically moving objects
Nmin = 1000;
Asym = cell(2,2);
for k = 1:2
    tmp = [];
    for j = 1:numel(iEdges)
        tmp = union(tmp,find(symCell{j,k}(:,1)>=Nmin & symCell{j,k}(:,4)>1.1));
    end
    Asym{1,k} = tmp;
    Asym{2,k} = find(symCell{numel(iEdges)+1,k}(:,1)>=Nmin & symCell{numel(iEdges)+1,k}(:,4)>1.1);
end

statRow = [numel(medI), numel(medI)-numel(index_discard), ...
                numel(Asym{1,1}), numel(Asym{2,1}), ...
                numel(Asym{1,2}), numel(Asym{2,2}), ...
                numel(intersect(Asym{1,1},Asym{1,2})), ...
                numel(intersect(Asym{2,1},Asym{2,2})), ...
                Nmin];
display(statRow)        
fprintf('Number of non-discarded objects: %d (of total %d)\n', ...
    numel(medI)-numel(index_discard), numel(medI));
fprintf('Ignoring all sets with less than %d data points.\n',Nmin)
for k = 1:2
    fprintf('State %d:\nAsymmetry in at least one segment: %d objects.\n', ...
        k, numel(Asym{1,k}));
    fprintf('Global asymmetry: %d objects.\n', ...
        numel(Asym{2,k}));
end
fprintf('Both states:\nAsymmetry in at least one segment: %d objects.\n', ...
    numel(intersect(Asym{1,1},Asym{1,2})));
fprintf('Global asymmetry: %d objects.\n', ...
    numel(intersect(Asym{2,1},Asym{2,2})));
fprintf('>>><<<>>><<<>>><<<>>><<<>>><<<\n')


% Histogram
Nmin = 1000;
if exist('histFg','var')
    if isvalid(histFg)
        close(histFg)
    end
end
histFg = figure('Units','normalized','Position',[0 0 .5 1],'Color',[1 1 1]);
for j = 1:numel(iEdges)+1
    for k = 1:2
        subplot(numel(iEdges)+1,2,(j-1)*2+k)
        if any(symCell{j,k}(symCell{j,k}(:,1)>Nmin,4))
            histogram(symCell{j,k}(symCell{j,k}(:,1)>Nmin,4),...
                1:0.05:nanmax(symCell{j,k}(symCell{j,k}(:,1)>Nmin,4))+.05)
        end
    end
end


% State 1 vs. State 2
Nmin = 1000;
if exist('vsFg','var')
    if isvalid(vsFg)
        close(vsFg)
    end
end
vsFg = figure('Units','normalized','Position',[0.5 0 .5 1],'Color',[1 1 1]);
for j = 1:numel(iEdges)+1
    subplot(numel(iEdges)+1,1,j)
    hold off
    plot(symCell{j,1}(symCell{j,1}(:,1)>=Nmin & symCell{j,2}(:,1)>=Nmin,4), ...
        symCell{j,2}(symCell{j,1}(:,1)>=Nmin & symCell{j,2}(:,1)>=Nmin,4),'.','MarkerSize',15)
    hold on
    plot(symCell{j,1}(symCell{j,1}(:,1)<Nmin | symCell{j,2}(:,1)<Nmin,4),...
        symCell{j,2}(symCell{j,1}(:,1)<Nmin | symCell{j,2}(:,1)<Nmin,4),'r.','MarkerSize',15)
    ax = gca;
    ax.ColorOrderIndex = 2;
    for n = reshape(Asym{1,2},1,[])
        plot(symCell{j,1}(n,4),symCell{j,2}(n,4),'o','MarkerSize',10)
    end
    hold on
 
    XLIM = ax.XLim;
    XLIM(1) = 1;
    YLIM = ax.YLim;
    YLIM(1) = 1;
    plot([1.1 1.1], YLIM, 'k:', 'LineWidth', 1)
    plot(XLIM, [1.1 1.1], 'k:', 'LineWidth', 1)
    ax.XLim = XLIM;
    ax.YLim = YLIM;
end

%% Save data
display('saving data ...')
save([path_out 'symmStats.mat'],'symCell','Asym','statRow','SID')
display('... done.')
%{
display('saving paths in symmPaths.mat ...')
save([path out 'symmPaths.mat'],'loadpath','path_out')
display('... done.')
%}

%% Plot distributions for a set of problematic particles
sz = [400 800];
if exist('scatFg','var')
    if isvalid(scatFg)
        close(scatFg)
    end
end
scatFg = figure('Units','pixels','Position',[0 0 sz],'Color',[1 1 1]);
LIM = [2 0];
%{
if strcmp(path_out(end-3:end),'prox')
    LIM(1) = 1;
else
    LIM(1) = 2;
end
%}
tmp = regexp(path_out,filesep);
R = str2double(path_out(tmp(end-1)+11));
if R==1 %R10sL2
    LIM(2) = 2;
elseif R==8 %R8sL4
    LIM(2) = 3;
elseif ismember(R,[6 4]) %R6sL4,R4sL8
    LIM(2) = 4;
elseif R==2 %R2L10
    LIM(2) = 5;
elseif R==0 %R0sL12
    LIM(2) = 6;
end
%
IND = reshape(union(union(Asym{1,1},Asym{1,2}),union(Asym{2,1},Asym{2,2})),1,[]);
for i = IND
    clf
    for k = 1:2
        tmpST{k} = setdiff(find(state_trajectories{i}==k),stickinDices{i});
    end
    [tmpS, tmpSind] = iSegments(medI{i},iEdges);
    % Individual segments
    for j = 1:size(tmpS,1)
        tmpI = tmpS(j,1):tmpS(j,2);
        for k = 1:2
            subplot(numel(iEdges)+1,2,(tmpSind(j)-1)*2+k)
            hold off
            tmpIST = intersect(tmpI,tmpST{k});
            if ~isempty(tmpIST)
                if symCell{tmpSind(j),k}(i,4)>1.1
                    plot(arxv{i}.XY(1,tmpIST),arxv{i}.XY(2,tmpIST),'r.','MarkerSize',3);
                else
                    plot(arxv{i}.XY(1,tmpIST),arxv{i}.XY(2,tmpIST),'.','MarkerSize',3);
                end
            else
                plot(NaN,NaN)
            end
            axis equal
            ax = gca;
            xlim(LIM(k)*[-1 1]),ylim(LIM(k)*[-1 1])
            ax.XTick = ceil(-LIM(k)):floor(LIM(k));
            ax.YTick = ax.XTick;
            hold on
            grid on
            title(sprintf('%.4f (N=%d)',symCell{tmpSind(j),k}(i,4),symCell{tmpSind(j),k}(i,1)))
        end
    end
    % Combine all segments
    tmpI = tmpS(1):tmpS(end);
    for k = 1:2
        subplot(numel(iEdges)+1,2,numel(iEdges)*2+k)
        hold off
        tmpIST = intersect(tmpI,tmpST{k});
        if ~isempty(tmpIST)
            if symCell{numel(iEdges)+1,k}(i,4)>1.1
                plot(arxv{i}.XY(1,tmpIST),arxv{i}.XY(2,tmpIST),'r.','MarkerSize',3);
            else
                plot(arxv{i}.XY(1,tmpIST),arxv{i}.XY(2,tmpIST),'.','MarkerSize',3);
            end
        else
            plot(NaN,NaN)
        end
        axis equal
        ax = gca;
        xlim(LIM(k)*[-1 1]),ylim(LIM(k)*[-1 1])
        ax.XTick = ceil(-LIM(k)):floor(LIM(k));
        ax.YTick = ax.XTick;
        hold on
        grid on
        title(sprintf('%.4f (N=%d)',symCell{numel(iEdges)+1,k}(i,4),symCell{numel(iEdges)+1,k}(i,1)))
    end
    suplabel(sprintf('Object %d (m: %d, s: %d)',i,indicesHMM(i,1),indicesHMM(i,2)),'t');
    %pause
    scatFg.PaperUnits = 'points';
    scatFg.PaperPosition = scatFg.Position;
    scatFg.PaperSize = scatFg.Position(3:4);
    print('-djpeg','-r72',[path_out sprintf('m%ds%d.jpg',indicesHMM(i,1),indicesHMM(i,2))])
end
suplabel('This is the last object. Hit another key to close this figure.','x');
%pause
if exist('scatFg','var')
    if isvalid(scatFg)
        close(scatFg)
    end
end




