%{
THINGS YOU NEED TO DO BEFOREHAND:
- check if med_itrace has been corrected. if not -> correct and save data
- set the following parameters for each dataset:
    - jumps: jumpMovs, jumpFrames
    - intervals to be igored: ignore (cell array)
    - Dmax (maximum physically stretched out excursion in XY; ctr len)
    - iEdges:
        - standard for @x-y geometries: [7000 8000 9000]
        - standard for old geometries: [6500 7500]
    - sigManual (optional)
%}

%% Extract dataset from GiTSiK
tmp = 0;
for m = 1:length(GiTSiK)
   tmp = tmp + sum(GiTSiK.behaviour{m} == 2);
end
indicesG = zeros(tmp,2);
counter = 1;
for m = 1:size(data,1)
    for i = find(GiTSiK.behaviour{m} == 2)';
        indicesG(counter,:) = [m i];
        counter = counter+1;
    end
end

%% Account for jumps in the movies
% Correct the XY-trajectories from movies that have 'jumps' in it
% at every site of a sudden 'jump':
% - rewrite the medians101 arrays around that frame number (+/- 50 frames)
% - recalculate the dispmed101 displacements for the same frame range
% (Truncate traces from first occuring zero onwards)
jumpMovs = zeros(1,length(GiTSiK.behaviour)); % RESET FOR EVERY DATASET
jumpFrames = cell(size(jumpMovs));
% set intervals to be ignored
ignore = cell(size(jumpMovs));
%ignore{2} = [19309 19311; 30050 30100; 30234 30236; 30414 30416]; % RESET FOR EVERY DATASET
if exist('jumps.mat','file')
    load jumps.mat
    for m = 1:length(jumpMovs)
        if ~isempty(jumps{m})
            jumpMovs(m) = 1;
            jumpFrames{m} = jumps{m};
            ignore{m} = zeros(numel(jumps{m}),2);
            for j = 1:numel(jumps{m})
                ignore{m}(j,1) = min(jumps{m}(j)-50,floor(jumps{m}(j)/100)*100+1);
                ignore{m}(j,2) = max(jumps{m}(j)+50,ceil(jumps{m}(j)/100)*100);
            end
        end
    end    
end

%% Produce cell array with xy-displacements
xyG = cell(length(indicesG),1);
truncate = []; %[3 82 1 14500]; % RESET FOR EVERY DATASET

for i = 1:length(indicesG)
    if ismember(indicesG(i,1),jumpMovs)
        tmpMF101 = data{indicesG(i,1)}{indicesG(i,2),1}.vwcm.medians101;
        for fNum = jumpFrames{indicesG(i,1)}
            for j = 1:2
                tmpMF101(fNum+(-50:-1),j) = tmpMF101(fNum-51,j);
                tmpMF101(fNum+(0:49),j) = tmpMF101(fNum+50,j);
            end
        end
        tmp_data = data{indicesG(i,1)}{indicesG(i,2),1}.vwcm.pos' - tmpMF101';
    else
        tmp_data = data{indicesG(i,1)}{indicesG(i,2),1}.vwcm.dispmed101';
    end
    tmp_rms10 = data{indicesG(i,1)}{indicesG(i,2),1}.vwcm.rms10;
    tmpL = find(tmp_rms10==0,1);
    if isempty(tmpL)
        xyG{i} = tmp_data;
    else
        xyG{i} = tmp_data(:,1:tmpL-1);
    end
end
for j = 1:size(truncate,1)
    tmpI = find(indicesG(:,1)==truncate(j,1) & indicesG(:,2)==truncate(j,2));
    xyG{tmpI} = xyG{tmpI}(:,truncate(j,3):truncate(j,4));
end

%% Find number of traces containing more than a certain percentage of frames above increasing threshold levels
% (exclude data points with unrealistic values from statistic)
Dmax = 3.5; %INPUT - RESET FOR EVERY DATASET
tol = 0.0001;
threshs = 2.5:0.02:7;
nPmillAbove = zeros(length(threshs),1);
for i = 1:length(xyG)
    tmp_data = xyG{i};
    tmp_data = tmp_data(:,max(tmp_data,[],1)<=Dmax);
    for j = 1:length(threshs)
        tmpN = sum(double(abs(tmp_data(1,:))>threshs(j) | abs(tmp_data(2,:))>threshs(j)));
        nPmillAbove(j) = nPmillAbove(j) + double(tmpN/length(tmp_data)<=tol);
    end
end

%% Determine threshold for 'sensible' displacement values
P = 0.2; %INPUT
THR = threshs(find(nPmillAbove>=P*length(indicesG),1));

% Plot this number against these threshold levels
figure
plot(threshs, nPmillAbove)
hold on
plot([threshs(1) threshs(end)], ceil(length(xyG)*P*[1 1]), 'r--')
plot([THR THR], [0 length(xyG)],'r--')

%% Pick best-suited interval of each trace for HMM evaluation:
intervalsHMM = zeros(size(indicesG));
xyHMM = cell(size(xyG));
for i = 1:length(intervalsHMM)
    tmpM = indicesG(i,1);
    tmpS = indicesG(i,2);
    tmpI = longest_good_interval(xyG{i},Dmax,THR,'ignore',ignore{tmpM});
    if ~isempty(tmpI)
        intervalsHMM(i,:) = tmpI;
        xyHMM{i} = xyG{i}(:,tmpI(1):tmpI(2));
    end
end
indicesHMM = indicesG(intervalsHMM(:,1)~=0,:);
xyHMM = xyHMM(intervalsHMM(:,1)~=0);
intervalsHMM(intervalsHMM(:,1)==0,:) = [];

%% Correct XY-trajectories for instrumental vibration with sample average
xyHMMcorr = correctXYensemble(xyHMM,indicesHMM,intervalsHMM);
for i = 1:length(xyHMMcorr)
    if all(xyHMMcorr{i}(1,:)==0) || all(xyHMMcorr{i}(2,:)==0)
        display(['Something is wrong with xyHMMcorr at index ' num2str(i)])
    end
end

%% cell container for the med_itraces of spots/intervals used for HMM analysis
medI = cell(size(indicesHMM,1),1);
for i = 1:length(medI)
    medI{i} = data{indicesHMM(i,1)}{indicesHMM(i,2),1}.med_itrace(intervalsHMM(i,1):intervalsHMM(i,2));
end

%% Check distribution of data points in intensity intervals
%iEdges = [6750 7500 8500];
iEdges = [7500 9000 10500];
foo2 = N_below(medI,iEdges);
disp(foo2.N/foo2.N_all)

%% Spot-by-spot HMM analysis (dividing each trace into intensity segments)
models = cell(size(xyHMM));
state_trajectories = cell(size(xyHMM));
arxv = cell(size(xyHMM));
%iEdges = [7900 9000];
sigManual = [0.3 0.9];
h = waitbar(0,['Spot-by-spot HMM analysis: ' num2str(0) ' of ' num2str(length(xyHMM)) ' done.']);
tic
for i = 1:length(xyHMM)
    [models{i}, state_trajectories{i}, arxv{i}] = mlhmmINTsegments(xyHMMcorr{i}, medI{i}, iEdges, intervalsHMM(i,1), 'sigmas', sigManual);
    waitbar(i/length(xyHMM),h,['Spot-by-spot HMM analysis: ' num2str(i) ' of ' num2str(length(xyHMM)) ' done.']);
end
toc
close(h)

%% Extract suitable starting values sigManual

SIGMA = [];
for i = 1:length(arxv)
    if isfield(arxv{i},'models')
        for j = 1:length(arxv{i}.models)
            for k = 1:2
                SIGMA = [SIGMA arxv{i}.models{j}.states{k}.sigma];
            end
        end
    end
end

figure
histogram(SIGMA,100)

%% Confirm, discard or truncate state-assigned trajectories:
% ts = figure('Units','normalized','Position',[0 0 1 1]);
% inDisp = indicesHMM;
% m = 1;
% tmp_start = find(inDisp(:,1)==m,1);
% keep2 = [keep zeros(size(keep))]; 
% for i = tmp_start:length(models)
%     if ~isempty(models{i})
%         tmpXY = arxv{i}.XY;
%         tmpS = state_trajectories{i};
%         plot_twostate(tmpXY,tmpS,11);
%         subplot(4,1,1)
%         title(['Movie ' num2str(inDisp(i,1)) ', spot ' num2str(inDisp(i,2)), ', index ' num2str(i)],'FontSize',14)
%         tmp = questdlg('Keep this trajectory?', 'HMM analysis successful?','Yes', 'No', 'Truncate', 'Yes');
%         keep2(i,1) = ~strcmp(tmp,'No');
%         if strcmp(tmp,'Truncate')
%             subplot(2,1,1)
%             h = impoint(gca);
%             pos_cut = wait(h);
%             keep2(i,2) = floor(pos_cut(1));
%             delete(h)
%         end
%     end
% end
% close(ts)

%% GUI for inspection of state-assigned trajectories:
%mlmodel = model8_7;
%xyHMM = arxv8_7.xyHMM;
%inDisp = Arxv.indices;
YLIM = [0 2.5];
inDisp = indicesHMM;
m_start = 1;
i = 1;%find(inDisp(:,1)==m_start,1);
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

go_on = 1;
while go_on
    tmpXY = arxv{i}.XY;
    tmpS = state_trajectories{i};
    tmpRMS = data{inDisp(i,1)}{inDisp(i,2),1}.vwcm.rms10(arxv{i}.segments(1):arxv{i}.segments(end));
    plot_twostate(tmpXY,tmpS,tmpRMS');
    subplot(4,1,1)
    hold on
    %plot(tmpRMS,'ko-', 'MarkerSize', 6)
    ylim(YLIM)
    title(['Movie ' num2str(inDisp(i,1)) ', spot ' num2str(inDisp(i,2)), ', index ' num2str(i) '/' num2str(length(state_trajectories))],'FontSize',16)
    uiwait(gcf)
end
display('Done.')
close(ts)

%% Save data from HMM analysis !!!Navigate to appropriate folder before!!!
save HMMdata.mat state_trajectories arxv iEdges xyHMM xyHMMcorr indicesHMM intervalsHMM

%% Prepare input for postHMM: 
discard = zeros(1,length(state_trajectories));
for i = 1:length(discard)
    discard(i) = isempty(state_trajectories{i});
end

inputPostHMM.indices = indicesHMM;
inputPostHMM.XY = xyHMMcorr;
inputPostHMM.state_trajectories = state_trajectories;
inputPostHMM.medI = medI;
inputPostHMM.ranges = zeros(size(inputPostHMM.indices));
inputPostHMM.ex_int = cell(size(inputPostHMM.indices));
for i = find(discard==0)
    inputPostHMM.ranges(i,:) = [arxv{i}.segments(1,1) arxv{i}.segments(end,2)];
    if ~isempty(ignore{inputPostHMM.indices(i,1)})
        inputPostHMM.ex_int{i} = ignore{inputPostHMM.indices(i,1)};
    else
        inputPostHMM.ex_int{i} = zeros(0,2);
    end
end

%% truncate or discard data from specific particles
% INPUT SPECIFICALLY FOR EVERY NEW DATASET:
index_discard = unique([find(discard==1)]);
copypaste_truncate_from = ...
    [ ...
8	34200
10	36400
51	40850
90	26100
];
copypaste_truncate_to = ...
    [ ...
67	2400
83	10
];
if ~isempty(copypaste_truncate_from)
    index_truncate_from = copypaste_truncate_from(:,1); %[,];
    limit_truncate_from = copypaste_truncate_from(:,2); %[,];
    if length(index_truncate_from)~=length(limit_truncate_from)
        display('ERROR')
    end
    for i = 1:length(index_truncate_from)
        inputPostHMM.XY{index_truncate_from(i)} = inputPostHMM.XY{index_truncate_from(i)}(:,1:limit_truncate_from(i));
        inputPostHMM.state_trajectories{index_truncate_from(i)} = inputPostHMM.state_trajectories{index_truncate_from(i)}(1:limit_truncate_from(i));
        inputPostHMM.medI{index_truncate_from(i)} = inputPostHMM.medI{index_truncate_from(i)}(1:limit_truncate_from(i));
        inputPostHMM.ranges(index_truncate_from(i),2) = inputPostHMM.ranges(index_truncate_from(i),1) + limit_truncate_from(i) - 1;
    end
end

if ~isempty(copypaste_truncate_to)
    index_truncate_to = copypaste_truncate_to(:,1); %[,];
    limit_truncate_to = copypaste_truncate_to(:,2); %[,];
    if length(index_truncate_to)~=length(limit_truncate_to)
        display('ERROR')
    end
    for i = 1:length(index_truncate_to)
        inputPostHMM.XY{index_truncate_to(i)} = inputPostHMM.XY{index_truncate_to(i)}(:,limit_truncate_to(i)+1:end);
        inputPostHMM.state_trajectories{index_truncate_to(i)} = inputPostHMM.state_trajectories{index_truncate_to(i)}(limit_truncate_to(i)+1:end);
        inputPostHMM.medI{index_truncate_to(i)} = inputPostHMM.medI{index_truncate_to(i)}(limit_truncate_to(i)+1:end);
        inputPostHMM.ranges(index_truncate_to(i),1) = inputPostHMM.ranges(index_truncate_from(i),1) + limit_truncate_to(i) + 1;
    end
end

inputPostHMM.indices(index_discard,:) = [];
inputPostHMM.XY(index_discard) = [];
inputPostHMM.state_trajectories(index_discard) = [];
inputPostHMM.medI(index_discard) = [];
inputPostHMM.ranges(index_discard,:) = [];
inputPostHMM.ex_int(index_discard) = [];

%% Post-HMM evaluation
[outputPostHMM] = postHMM(inputPostHMM);
hop = outputPostHMM.hop;

%% Save post-HMM-data !!!Navigate to appropriate folder before!!!

save dataPostHMM.mat outputPostHMM inputPostHMM

%% Export Scatter Stats to Igor
SID = 'S063';
StatsForIgor = outputPostHMM.scatterStats;
tmp_remove = find(StatsForIgor(:,5) == 0 | StatsForIgor(:,6) == 0);
StatsForIgor(tmp_remove,:) = [];
for i = 3:4
    StatsForIgor(:,i) = StatsForIgor(:,i)./sqrt(StatsForIgor(:,i+2));
end
stats_to_igor(StatsForIgor(:,1:4), SID)

%% Plot the series of state-assigned trajectories:
ts = figure('Units','normalized','Position',[0 0 1 1]);
%mlmodel = model8_7;
%xyHMM = arxv8_7.xyHMM;
%inDisp = Arxv.indices;
inDisp = indicesHMM;
m = 1;
tmp_start = find(inDisp(:,1)==m,1);
for i = 1:length(models)
    if ~isempty(models{i})
        tmpXY = arxv{i}.XY;
        tmpS = state_trajectories{i};
        plot_twostate(tmpXY,tmpS,11);
        subplot(4,1,1)
        title(['Movie ' num2str(inDisp(i,1)) ', spot ' num2str(inDisp(i,2)), ', index ' num2str(i) '/' num2str(length(models))],'FontSize',14)
        pause
    end
end
close(ts)
