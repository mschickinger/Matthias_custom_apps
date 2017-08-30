
W = 11;
suspects = cell(size(RMSintSeg));
suspectSpots = [];
suspectsRMS = cell(size(RMSintSeg));
suspectsOveRel = cell(size(RMSintSeg));
for i = numel(suspectsRMS):-1:1
    suspectsRMS{i} = zeros(3,0);
    suspectsOveRel{i} = zeros(3,0);
end
for K = 1:2
    for intidx = 1:size(RMSintSeg,2)
    %     suspects{intidx} = union(suspects{intidx},find(RMSintSeg{K,intidx}(1,:)<globThreshs(K,intidx) & ...
    %                                 (3/sqrt(W)*abs(xySeg{K,intidx}(1,:))>medSigmas{K}(intidx,1) | ...
    %                                 3/sqrt(W)*abs(xySeg{K,intidx}(2,:))>medSigmas{K}(intidx,2))));
        tmpI = find(RMSintSeg{K,intidx}(1,:)<globThreshs(K,intidx) & ...
                sqrt((xySeg{K,intidx}(1,:)).^2 + (xySeg{K,intidx}(2,:)).^2)>3/sqrt(W)*mean(medSigmas{K}(intidx,:)));
        if ~isempty(tmpI)
            suspects{K,intidx} = union(suspects{K,intidx},tmpI);
            suspectSpots = union(suspectSpots,unique(xySeg{K,intidx}(3,suspects{K,intidx})));
            suspectsRMS{K,intidx} = [suspectsRMS{K,intidx} RMSintSeg{K,intidx}([1 3 4],tmpI)];
            suspectsOveRel{K,intidx} = [suspectsOveRel{K,intidx} [sqrt((xySeg{K,intidx}(1,tmpI)).^2 + (xySeg{K,intidx}(2,tmpI)).^2).*sqrt(W)./mean(medSigmas{K}(intidx,:)); ...
                                                                xySeg{K,intidx}(3:4,tmpI)]];
        end
    end
end

% Lengths of intervals fulfilling criteria
suspectsL = cell(size(suspectsRMS));
for k = 1:2
    foo = cat(2,suspectsRMS{k,:});
    foo(1,:) = 1:size(foo,2);
    foo = sortrows(foo', [2 3])';

    a = 1;
    i = 1;
    l = 1;
    L = zeros(1,size(foo,2));
    while i<=size(foo,2)-1
        if foo(2,i+1)==foo(2,i) && foo(3,i+1)==foo(3,i)+1
            l = l+1;
        else
            L(a:i) = l;
            a = i+1;
            l = 1;
        end
        i = i+1;
    end
    if a==i
        L(i) = 1;
    else
        L(a:i) = l;
    end

    [~,I] = sort(foo(1,:));
    L = L(I);
    
    offset = 0;
    for i = 1:size(suspectsL,2)
        suspectsL{k,i} = L((1:size(suspectsRMS{k,i},2))+offset);
        offset = offset + size(suspectsRMS{k,i},2);
    end
end

suspectInds = cell(size(removInds));
for K = 1:2
    suspectInds{K} = cell(size(removInds{K}));
    for isp = reshape(suspectSpots,1,[]) 
        tmp = zeros(0,1);
        for intidx = 1:size(suspects,2)
            tmpI = sort(RMSintSeg{K,intidx}(4,suspects{K,intidx}(RMSintSeg{K,intidx}(3,suspects{K,intidx})==isp)));
            i = 1;
            while i <= numel(tmpI)
                tmp = union(tmp,(tmpI(i)+(-2*floor(W/2):2*floor(W/2)))');
                i = i+1;
            end
        end
        if ~isempty(tmp)
            suspectInds{K}{isp,2} = sort(unique(tmp));
        end
        tmp = [];
        for i = 1:size(stateFrames{isp,K},1)
            if ~isnan(stateFrames{isp,K}(i,1))
                if ~isempty(intersect(stateFrames{isp,K}(i,1):sum(stateFrames{isp,K}(i,:)),suspectInds{K}{isp,2}))
                    tmp = [tmp; i];
                end
            end
        end
        suspectInds{K}{isp,1} = tmp;
        %suspectFrames{i} = sort(RMSintSeg{K,intidx}(4,suspects(RMSintSeg{K,intidx}(3,suspects)==i)));
    end
end

%% Plot stats of suspicious frames for intervals
colors = {[204 0 0]/255,[0 102 153]/255};
figure('Units','normalized','Position',[0 0 1 1])
N = size(suspectsRMS,2);
for n = 1:N
    subplot(2,N,n)
    plot(suspectsOveRel{2,n}(1,:),suspectsRMS{2,n}(1,:),'.', 'Color', colors{2}, 'MarkerSize', 10)
    hold on
    plot(suspectsOveRel{2,n}(1,suspectsL{2,n}==1),suspectsRMS{2,n}(1,suspectsL{2,n}==1),'ko', 'MarkerSize', 10)
    plot(suspectsOveRel{2,n}(1,suspectsL{2,n}==2),suspectsRMS{2,n}(1,suspectsL{2,n}==2),'go', 'MarkerSize', 10)
    subplot(2,N,n+N)
    plot(suspectsOveRel{1,n}(1,:),suspectsRMS{1,n}(1,:),'.', 'Color', colors{1}, 'MarkerSize', 10)
    hold on
    plot(suspectsOveRel{1,n}(1,suspectsL{1,n}==1),suspectsRMS{1,n}(1,suspectsL{1,n}==1),'ko', 'MarkerSize', 10)
    plot(suspectsOveRel{1,n}(1,suspectsL{1,n}==2),suspectsRMS{1,n}(1,suspectsL{1,n}==2),'go', 'MarkerSize', 10)
end

%% Remove suspects from RMSintSeg, update density statistics:
[RMSintSeg, xySeg, Nremoved] = indRemover(RMSintSeg, xySeg, suspectInds);
display(['Total number of indices removed: ' num2str(Nremoved)])
%%
globThreshs = get_globThreshs(RMSintSeg, 0.01);
%%
h = waitbar(0,'');
for isp = setdiff(1:size(densities,1),discard)
    for K = 1:2
        waitbar(isp/length(state_trajectories),h,['getting density and area statistics ' ...
            num2str(isp) ' of ' num2str(length(state_trajectories)) '.']);
        if ~isempty(segments{isp})
            tmpRMS = data{indicesHMM(isp,1)}{indicesHMM(isp,2),1}.vwcm.rms10(arxv{isp}.segments(1):arxv{isp}.segments(end))';
            [densities{isp,K}, areas{isp,K}] = update_density(densities{isp,K}, areas{isp,K}, tmpRMS, globThreshs(K,:), segments{isp}, segmInds{isp}, stateFrames{isp,K});
        end
    end
end
close(h)
%%
[allD, allDmax, allA, allAmax, allLmax] = get_allADmax(densities, discard, areas, maxlBelow);
    
%% GUI for inspection of state-assigned trajectories:
%mlmodel = model8_7;
%xyHMM = arxv8_7.xyHMM;
%inDisp = Arxv.indices;
inData = suspectSpots;
inDisp = indicesHMM(suspectSpots,:);
m_start = 1;
i = 43;%find(inDisp(:,1)==m_start,1);
while isempty(state_trajectories{i}) && i<=length(state_trajectories)
    i = i+1;
end
ts = figure('Units','normalized','Position',[0 0 1 1]);
for p = 1:4
    subplot(4,1,p)
end
bBack = uicontrol('Style', 'pushbutton', 'String', 'Back', 'Units', 'normalized', 'Position', [0.025 0.8 0.05 0.04], 'Callback', 'if i > 1 i = i-1; end, while isempty(state_trajectories{inData(i)}) && i>1 i = i-1; end, uiresume', 'FontSize', 12);
bNext = uicontrol('Style', 'pushbutton', 'String', 'Next', 'Units', 'normalized','Position', [0.925 0.8 0.05 0.04], 'Callback', 'if inData(i) < length(state_trajectories) i = i+1; end, while isempty(state_trajectories{inData(i)}) && i<length(state_trajectories) i = i+1; end, uiresume', 'FontSize', 12);
loLim = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.025 0.2 0.03 0.03]);
hiLim = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.06 0.2 0.03 0.03]);
bSet = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', 'Set Xlims', 'Position', [0.025 0.15 0.065 0.04], 'Callback', 'for p = 1:4 subplot(4,1,p), xlim([str2double(loLim.String) str2double(hiLim.String)]); end', 'FontSize', 12);
bReset = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', 'Reset', 'Position', [0.025 0.1 0.065 0.04], 'Callback', 'for p = 1:4 subplot(4,1,p), xlim auto; end', 'FontSize', 12);
bDone = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', 'Done', 'Position', [0.925 0.15 0.05 0.04], 'Callback', 'go_on = 0; uiresume', 'FontSize', 12);
onoff = {'off','on'};
bShow = uicontrol('Style', 'togglebutton', 'String', 'Show/Hide', 'Units', 'normalized', 'Position', [0.925 0.25 0.065 0.04], ... 
                'Callback', 'for p = 1:numel(rmp) if ~isempty(rmp{p}) rmp{p}.Visible = onoff{mod(bShow.Value,2)+1}; end; end;', 'FontSize', 12);

W = 11;
szRmv = 4;
color = {'g','m'};
go_on = 1;
rmp = cell(4,2);
while go_on
    tmpXY = arxv{inData(i)}.XY;%data{inDisp(i,1)}{inDisp(i,2),1}.vwcm.dispmed101(arxv{inData(i)}.segments(1):arxv{inData(i)}.segments(end),:)';
    tmpS = state_trajectories{inData(i)};
    tmpRMS = data{inDisp(i,1)}{inDisp(i,2),1}.vwcm.rms10(arxv{inData(i)}.segments(1):arxv{inData(i)}.segments(end));
    plot_twostate(tmpXY,tmpS,tmpRMS');
    subplot(4,1,1)
    hold on
    offset = arxv{inData(i)}.segments(1)-1;
    for k = 1:2
        for intidx = 1:size(arxv{inData(i)}.segments,1)
            plot(arxv{inData(i)}.segments(intidx,:)-offset,globThreshs(k,intidx)*[1 1],'k--')
        end
    end
    ylim([0 3])
    title(['Movie ' num2str(inDisp(i,1)) ', spot ' num2str(inDisp(i,2)), ', index ' num2str(i) '/' num2str(length(inData))],'FontSize',16)
    tmpMedXY = zeros(size(tmpXY));
    for k = 1:2
        tmpMedXY(k,:) = meanfilt1_trunc(tmpXY(k,:),W);
        subplot(4,1,k+2)
        hold on
        plot(tmpMedXY(k,:),'Color',[1 1 1]*.6)
    end
    subplot(4,1,2)
    hold on
    plot(sqrt(tmpMedXY(1,:).^2+tmpMedXY(2,:).^2),'Color',[1 1 1]*.6)
    for K = 1:2
        for intidx = 1:size(arxv{inData(i)}.segments,1)
            plot(arxv{inData(i)}.segments(intidx,:)-offset,3/sqrt(W)*mean(medSigmas{K}(intidx,:))*[1 1],'k--')
        end
    end
    for K = 1:2
        if ~isempty(suspectInds{K}{inData(i),2})           
            subplot(4,1,1)
            rmp{1,K} = plot(suspectInds{K}{inData(i),2},tmpRMS(suspectInds{K}{inData(i),2}),[color{K} 'o'],'MarkerSize',szRmv);
            subplot(4,1,2)
            rmp{2,K} = plot(suspectInds{K}{inData(i),2},sqrt(tmpXY(1,suspectInds{K}{inData(i),2}).^2+tmpXY(2,suspectInds{K}{inData(i),2}).^2),[color{K} 'o'],'MarkerSize',szRmv);
            for p = 1:2
                subplot(4,1,p+2)
                hold on
                rmp{p+2,K} = plot(suspectInds{K}{inData(i),2},tmpXY(p,suspectInds{K}{inData(i),2}),[color{K} 'o'],'MarkerSize',szRmv);
            end
        else
            rmp = cell(4,2);
        end
    end
    bShow.Value = 1;
    uiwait(gcf)
end
display('Done.')
close(ts)

