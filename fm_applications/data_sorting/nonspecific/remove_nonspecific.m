%% RESET to initial state
xySeg = xySegZ;
RMSintSeg = RMSintSegZ;
removInds = cell(2,1);
for k = 1:2
    removInds{k} = cell(length(medI),2);
end
stateFrames = stateFramesZ;
densities = densitiesZ;
areas = areasZ;
maxlBelow = maxlBelowZ;
[allD, allDmax, allA, allAmax, allLmax] = get_allADmax(densities, discard, areas, maxlBelow);
display('RESET COMPLETE')
%% identify suspects for unspecific sticking -> to be removed
cutoffD = [0.25 0.5];
for K = 1:2 % SELECT STATE
    go_on = 1;
    while go_on
        distlBelow = cell(2,1);
        distXYBelow = cell(2,1);
        indsBelow = cell(2,1);
        for i = 1:2
            distXYBelow{i} = zeros(2,0);
            indsBelow{i} = zeros(0,3);
        end
        %cutoffL = [20 20];
        %removInds = cell(length(medI),2);
        display(['Total number of non-discarded states is: ' num2str(length(allDmax{K}))])
        if any(allDmax{K}>cutoffD(K))
            display(['number of states with density above ' num2str(cutoffD(K)) ...
                            ' is ' num2str(sum(allDmax{K}>cutoffD(K)))])
                for isp = setdiff(1:size(densities,1),discard)
                    if ~isempty(densities{isp,K})
                        tmpI = find(densities{isp,K}(:,2)>cutoffD(K));         
                        if ~isempty(tmpI)
                            %disp(length(tmpI));
                            densities{isp,K}(tmpI,:) = NaN;
                            %maxlBelow{isp,K}(tmpI) = NaN;
                            removInds{K}{isp,1} = [removInds{K}{isp,1} ; tmpI];
                            for i = 1:length(tmpI)
                                removInds{K}{isp,2} = [removInds{K}{isp,2} ; (stateFrames{isp,K}(tmpI(i),1):sum(stateFrames{isp,K}(tmpI(i),:))-1)'];
                            end
                        end
                        for i = 1:2
                            removInds{K}{isp,i} = unique(removInds{K}{isp,i});
                        end
                        stateFrames{isp,K}(removInds{K}{isp,1},:) = NaN;
                    end
                end


            %% Remove from global cell array for segments and states
            [RMSintSeg, xySeg] = indRemover(RMSintSeg, xySeg, removInds);
%             for j = 1:size(RMSintSeg,2)
%                 for isp = 1:size(removInds{K},1)
%                     RMSintSeg{K,j}(:,RMSintSeg{K,j}(3,:)==isp & ismember(RMSintSeg{K,j}(4,:),removInds{K}{isp,2})) = [];
%                     xySeg{K,j}(:,xySeg{K,j}(3,:)==isp & ismember(xySeg{K,j}(4,:),removInds{K}{isp,2})) = [];
%                 end 
%             end

            %% Get density below 0.01% threshold for all bound intervals
            globThreshs = get_globThreshs(RMSintSeg, 0.01);
%             P = 0.01;
%             for i = 1:size(globThreshs,2)
%                 for k = 1:2
%                     tmpV = sort(RMSintSeg{k,i}(1,:));
%                     tmpP = max(1,floor(P*length(tmpV)));
%                     globThreshs(k,i) = tmpV(tmpP);
%                 end
%             end
            h = waitbar(0,'');
            for isp = setdiff(1:size(densities,1),discard)
                waitbar(isp/length(state_trajectories),h,['getting density and area statistics ' ...
                    num2str(isp) ' of ' num2str(length(state_trajectories)) '.']);
                if ~isempty(segments{isp}) 
                    tmpRMS = data{indicesHMM(isp,1)}{indicesHMM(isp,2),1}.vwcm.rms10(arxv{isp}.segments(1):arxv{isp}.segments(end))';
                    tmpXY = arxv{isp}.XY;
                    tmpSeg = 1;
                    for i = 1:size(densities{isp,K},1)
                        if ~isnan(stateFrames{isp,K}(i,1))
                            while stateFrames{isp,K}(i,1) > segments{isp}(tmpSeg,2)
                                tmpSeg = tmpSeg + 1;
                            end
                            tmpA = zeros(1,stateFrames{isp,K}(i,2));
                            tmpB = zeros(1,stateFrames{isp,K}(i,2));
                            tmpI = stateFrames{isp,K}(i,1):sum(stateFrames{isp,K}(i,:))-1;
                            tmpF = 0;
                            while sum(stateFrames{isp,K}(i,:)) > segments{isp}(tmpSeg,2)
                                tmpA(tmpF+(1:segments{isp}(tmpSeg,2)-stateFrames{isp,K}(i,1))) = ...
                                    tmpRMS(tmpI(tmpF+(1:segments{isp}(tmpSeg,2)-stateFrames{isp,K}(i,1))))-globThreshs(K,segmInds{isp}(tmpSeg));
                                tmpB(tmpF+(1:segments{isp}(tmpSeg,2)-stateFrames{isp,K}(i,1))) = ...
                                    tmpRMS(tmpI(tmpF+(1:segments{isp}(tmpSeg,2)-stateFrames{isp,K}(i,1))))<=globThreshs(K,segmInds{isp}(tmpSeg));
                                tmpF = segments{isp}(tmpSeg,2)-stateFrames{isp,K}(i,1);
                                tmpSeg = tmpSeg + 1;
                            end
                            if tmpF < stateFrames{isp,K}(i,2)
                                tmpA(tmpF+1:end) = tmpRMS(tmpI(tmpF+1:end))-globThreshs(K,segmInds{isp}(tmpSeg));
                                tmpB(tmpF+1:end) = tmpRMS(tmpI(tmpF+1:end))<=globThreshs(K,segmInds{isp}(tmpSeg));
                            end
                            densities{isp,K}(i,1) = sum(tmpB)/length(tmpB);
                            areas{isp,K}(i,1) = abs(sum(tmpB.*tmpA));
                            Nmax = 100;
                            if stateFrames{isp,K}(i,2)>Nmax
                                tmpA2 = zeros(1,length(tmpB)-Nmax+1);
                                tmpB2 = zeros(1,length(tmpB)-Nmax+1);
                                for j = 1:length(tmpB2)
                                    tmpA2(j) = abs(sum(tmpA(j:j+Nmax-1).*tmpB(j:j+Nmax-1)));
                                    tmpB2(j) = sum(tmpB(j:j+Nmax-1));
                                end
                                densities{isp,K}(i,2) = max(tmpB2)/Nmax;
                                areas{isp,K}(i,2) = max(tmpA2);
                            else
                                densities{isp,K}(i,2) = densities{isp,K}(i,1);
                                areas{isp,K}(i,2) = areas{isp,K}(i,1);
                            end
                            if any(tmpB==1)
                                steps = find(diff([0 tmpB 0])~=0);
                                S = steps(1:end-1);
                                S = S(tmpB(steps(1:end-1))==1);
                                L = steps(2:end)-steps(1:end-1);
                                L = L(tmpB(steps(1:end-1))==1);
                                distlBelow{K} = [distlBelow{K} L];
                                indsBelow{K} = [indsBelow{K}; isp*ones(length(S),1) tmpI(S)' L'];
                                maxlBelow{isp,K}(i) = max(L);
                                tmpXYbelow = zeros(2,length(S));
                                for s = 1:size(tmpXYbelow,2)
                                    tmpXYbelow(:,s) = mean(tmpXY(:,tmpI(S(s)):(tmpI(S(s))+L(s)-1)),2);
                                end
                                distXYBelow{K} = [distXYBelow{K} tmpXYbelow]; 
                            end
                        else
                            densities{isp,K}(i,:) = NaN; % REDUNDANCY
                            areas{isp,K}(i,:) = NaN; % REDUNDANCY
                        end
                    end

                end
            end
            close(h)

            %%
            [allD, allDmax, allA, allAmax, allLmax] = get_allADmax(densities, discard, areas, maxlBelow);
    %         allD = cell(2,1);
    %         allDmax = cell(2,1);
    %         allA = cell(2,1);
    %         allAmax = cell(2,1);
    %         allLmax = cell(2,1);
    %         for k = 1:2
    %             for isp = setdiff(1:size(densities,1),discard)
    %                 if ~isempty(densities{isp,k})
    %                     allD{k} = [allD{k};densities{isp,k}(~isnan(densities{isp,k}(:,1)),1)];
    %                     allDmax{k} = [allDmax{k};densities{isp,k}(~isnan(densities{isp,k}(:,2)),2)];
    %                     allA{k} = [allA{k};areas{isp,k}(~isnan(areas{isp,k}(:,1)),1)];
    %                     allAmax{k} = [allAmax{k};areas{isp,k}(~isnan(areas{isp,k}(:,2)),2)];
    %                     allLmax{k} = [allLmax{k};maxlBelow{isp,k}(~isnan(maxlBelow{isp,k}))];
    %                 end
    %             end
    %         end
        else
            display(['No states with density above ' num2str(cutoffD(K))])
            go_on = 0;
        end
        display(['Total number of non-discarded states is: ' num2str(length(allDmax{K}))])
    end
end


%% GUI for inspection of state-assigned trajectories:
%mlmodel = model8_7;
%xyHMM = arxv8_7.xyHMM;
%inDisp = Arxv.indices;
inDisp = indicesHMM;
m_start = 1;
i = 84;%find(inDisp(:,1)==m_start,1);
while isempty(state_trajectories{i}) && i<=length(state_trajectories)
    i = i+1;
end
ts = figure('Units','normalized','Position',[0 0 1 1]);
for p = 1:4
    subplot(4,1,p)
end
bBack = uicontrol('Style', 'pushbutton', 'String', 'Back', 'Units', 'normalized', 'Position', [0.025 0.8 0.05 0.04], 'Callback', 'if i > 1 i = i-1; end, while isempty(state_trajectories{i}) && i>1 i = i-1; end, uiresume', 'FontSize', 12);
bNext = uicontrol('Style', 'pushbutton', 'String', 'Next', 'Units', 'normalized','Position', [0.925 0.8 0.05 0.04], 'Callback', 'if i < length(state_trajectories) i = i+1; end, while isempty(state_trajectories{i}) && i<length(state_trajectories) i = i+1; end, uiresume', 'FontSize', 12);
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
    tmpXY = arxv{i}.XY;
    tmpS = state_trajectories{i};
    tmpRMS = data{indicesHMM(i,1)}{indicesHMM(i,2),1}.vwcm.rms10;
    plot_twostate(tmpXY,tmpS,tmpRMS');
    subplot(4,1,1)
    plot_twostateRMS(tmpRMS,state_trajectories{i},arxv{i}.segments)
    hold on
    for k = 1:2
        for intidx = 1:size(arxv{i}.segments,1)
            plot(arxv{i}.segments(intidx,:),globThreshs(k,intidx)*[1 1],'k--')
        end
    end
    ylim([0 3])
    title(['Movie ' num2str(inDisp(i,1)) ', spot ' num2str(inDisp(i,2)), ', index ' num2str(i) '/' num2str(length(state_trajectories))],'FontSize',16)
   
%     for k = 1:2
%         subplot(4,1,k+2)
%         hold on
%         plot(medfilt1_trunc(tmpXY(k,:),11),'Color',[1 1 1]*.6)
%     end
    if ~isempty(removInds{K}{i,2})
        rmp{1} = plot(removInds{K}{i,2},tmpRMS(removInds{K}{i,2}),'ko','MarkerSize',szRmv);
        subplot(4,1,2)
        rmp{2} = plot(removInds{K}{i,2},sqrt(tmpXY(1,removInds{K}{i,2}).^2+tmpXY(2,removInds{K}{i,2}).^2),'ko','MarkerSize',szRmv);
        for p = 1:2
            subplot(4,1,p+2)
            hold on
            rmp{p+2} = plot(removInds{K}{i,2},tmpXY(p,removInds{K}{i,2}),'ko','MarkerSize',szRmv);
        end
    else
        rmp = cell(4,1);
    end
    bShow.Value = 1;
    uiwait(gcf)
end
display('Done.')
close(ts)


%% Mean filtered values from state1 / state2

wSize = 10;
b = (1/wSize)*ones(1,wSize);
a = 1;
allAVG = cell(2,1);
allRMS = cell(2,1);
for k = 1:2
    allAVG{k} = zeros(2,0);
end
for isp = setdiff(1:length(indicesHMM),discard)
    tmpXY = data{indicesHMM(isp,1)}{indicesHMM(isp,2),1}.vwcm.dispmed101(intervalsHMM(isp,1):intervalsHMM(isp,2),:)';
    avgXY = vertcat(filter(b,a,tmpXY(1,:)),filter(b,a,tmpXY(2,:)));
    avgXY = avgXY(:,wSize:end);
    straj = state_trajectories{isp}(wSize:end);
    tmpRMS = data{indicesHMM(isp,1)}{indicesHMM(isp,2),1}.vwcm.rms10(wSize:end);
    steps = find(diff(straj)~=0) + 1;
    tmpF = [];
    for i = 1:length(steps)
        tmpF = [tmpF steps(i):steps(i)+wSize-1];
    end
    tmpF(tmpF>length(straj)) = [];
    avgXY(:,tmpF) = [];
    straj(tmpF) = [];
    tmpRMS(tmpF) = [];
    for k = 1:2
        allAVG{k} = [allAVG{k} avgXY(:,straj==k)];
        allRMS{k} = [allRMS{k} tmpRMS(straj==k)'];
    end
end

%% Fill global cell array for segments and states with mean-filtered XY
xySeg = cell(2,numel(iEdges));
for i = 1:length(arxv)
    if ~isempty(arxv{i}.segments)
        tmpXY = arxv{i}.XY;
        W = 11;
        tmpXY(1,:) = meanfilt1_trunc(tmpXY(1,:),W);
        tmpXY(2,:) = meanfilt1_trunc(tmpXY(2,:),W);
        if length(tmpXY)~=length(state_trajectories{i})
            display([num2str(i) ' of ' num2str(length(medI)) ': ERROR'])
        else
            display([num2str(i) ' of ' num2str(length(medI)) ': OK'])
        end
        if ~isempty(segments{i})
            tmpS = state_trajectories{i}(1:find(state_trajectories{i}~=state_trajectories{i}(end),1,'last'));
            for k = 1:2
                statesInds{k} = find(state_trajectories{i}==k);
                %statesInds{k} = setdiff(find(state_trajectories{i}==k),removInds{i,2});
            end
            for j = 1:length(segmInds{i})
                for k = 1:2
                    tmpIND = intersect(statesInds{k},segments{i}(j,1):segments{i}(j,2));
                    xySeg{k,segmInds{i}(j)} = [xySeg{k,segmInds{i}(j)} [tmpXY(:,tmpIND); ...
                                                                        i*ones(1,length(tmpIND)); ...
                                                                        tmpIND]];                                                                           
                end
            end 
        end
    end
end

%%
figure
W = 21;
L = length(RMSintSeg{2,1});
subplot(2,1,1)
hold off
plot(RMSintSeg{2,1}(5,:),'.')
hold on
plot([0 L], medSigmas{2}(1,1)*3.29/sqrt(W)*[1 1], 'k--')
plot([0 L], -medSigmas{2}(1,1)*3.29/sqrt(W)*[1 1], 'k--')
subplot(2,1,2)
hold off
plot(RMSintSeg{2,1}(6,:),'.')
hold on
plot([0 L], medSigmas{2}(1,2)*3.29/sqrt(W)*[1 1], 'k--')
plot([0 L], -medSigmas{2}(1,2)*3.29/sqrt(W)*[1 1], 'k--')










