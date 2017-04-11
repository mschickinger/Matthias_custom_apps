
K = 2;
%intidx = 1;
W = 11;
suspects = cell(size(RMSintSeg,2),1);
suspectSpots = [];
for intidx = 1:size(RMSintSeg,2)
%     suspects{intidx} = union(suspects{intidx},find(RMSintSeg{K,intidx}(1,:)<globThreshs(K,intidx) & ...
%                                 (3/sqrt(W)*abs(xySeg{K,intidx}(1,:))>medSigmas{K}(intidx,1) | ...
%                                 3/sqrt(W)*abs(xySeg{K,intidx}(2,:))>medSigmas{K}(intidx,2))));
    suspects{intidx} = union(suspects{intidx},find(RMSintSeg{K,intidx}(1,:)<globThreshs(K,intidx) & ...
                                3/sqrt(W)*sqrt((xySeg{K,intidx}(1,:)).^2 + (xySeg{K,intidx}(2,:)).^2)>mean(medSigmas{K}(intidx,2))));
    suspectSpots = union(suspectSpots,unique(xySeg{K,intidx}(3,suspects{intidx})));
    
end

suspectFrames = cell(length(indicesHMM),1);
for i = suspectSpots'
    tmp = [];
    for intidx = 1:length(suspects)
        tmp = union(tmp,RMSintSeg{K,intidx}(4,suspects{intidx}(RMSintSeg{K,intidx}(3,suspects{intidx})==i)));
    end
        %tmp = xySeg{K,intidx}(3:4,suspects);
        %tmp = tmp(2,tmp(1,:)==i);
    suspectFrames{i} = sort(tmp);
    %suspectFrames{i} = sort(RMSintSeg{K,intidx}(4,suspects(RMSintSeg{K,intidx}(3,suspects)==i)));
end

%% GUI for inspection of state-assigned trajectories:
%mlmodel = model8_7;
%xyHMM = arxv8_7.xyHMM;
%inDisp = Arxv.indices;
inData = suspectSpots;
inDisp = indicesHMM(suspectSpots,:);
m_start = 1;
i = 48;%find(inDisp(:,1)==m_start,1);
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
                'Callback', 'for p = 1:4 if ~isempty(rmp{p}) rmp{p}.Visible = onoff{mod(bShow.Value,2)+1}; end; end;', 'FontSize', 12);

szRmv = 4;
go_on = 1;
while go_on
    tmpXY = arxv{inData(i)}.XY;
    tmpS = state_trajectories{inData(i)};
    tmpRMS = data{inDisp(i,1)}{inDisp(i,2),1}.vwcm.rms10;
    plot_twostate(tmpXY,tmpS,tmpRMS');
    subplot(4,1,1)
    plot_twostateRMS(tmpRMS,state_trajectories{inData(i)},arxv{inData(i)}.segments)
    hold on
    for k = 1:2
        for intidx = 1:size(arxv{inData(i)}.segments,1)
            plot(arxv{inData(i)}.segments(intidx,:),globThreshs(k,intidx)*[1 1],'k--')
        end
    end
    ylim([0 3])
    title(['Movie ' num2str(inDisp(i,1)) ', spot ' num2str(inDisp(i,2)), ', index ' num2str(i) '/' num2str(length(inData))],'FontSize',16)
   
    for k = 1:2
        subplot(4,1,k+2)
        hold on
        plot(meanfilt1_trunc(tmpXY(k,:),11),'Color',[1 1 1]*.6)
    end
    if ~isempty(suspectFrames{inData(i)})
        subplot(4,1,1)
        rmp{1} = plot(suspectFrames{inData(i)},tmpRMS(suspectFrames{inData(i)}),'mo','MarkerSize',szRmv);
        subplot(4,1,2)
        rmp{2} = plot(suspectFrames{inData(i)},sqrt(tmpXY(1,suspectFrames{inData(i)}).^2+tmpXY(2,suspectFrames{inData(i)}).^2),'mo','MarkerSize',szRmv);
        for p = 1:2
            subplot(4,1,p+2)
            hold on
            rmp{p+2} = plot(suspectFrames{inData(i)},tmpXY(p,suspectFrames{inData(i)}),'mo','MarkerSize',szRmv);
        end
    else
        rmp = cell(4,1);
    end
    bShow.Value = 1;
    uiwait(gcf)
end
display('Done.')
close(ts)

