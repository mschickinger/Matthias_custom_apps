% set parameters
taus = [2.5 3]; % expected values of dwell times in states 1 and 2
Ndwells = 10000;
Tdraw = zeros(Ndwells,2);
stateRecorded = zeros(2*Ndwells*sum(taus),1);

% run loop
stateRecorded(1) = 1; % system starts in state 1
currentRecorded = [1 1];
sumT = 1;
rng default % for reproducibility
for i = 1:Ndwells
    for j = 1:2
        Tdraw(i,j) = exprnd(taus(j));
        sumT = sumT + Tdraw(i,j);
        if floor(sumT)>currentRecorded(2)
            currentRecorded(1) = currentRecorded(2)+1;
            currentRecorded(2) = floor(sumT);
            stateRecorded(currentRecorded(1):currentRecorded(2)) = j;
        end
    end
end

% truncate state trajectory
stateRecorded = nonzeros(stateRecorded);

%%
%plot(stateRecord)

%% Get dwell times from stateRecorded
dwells = cell(2,1);
transitions = find(diff(stateRecorded)~=0) + 1;
if ~isempty(transitions)
    % Start frames and durations of recorded dwells
    S = reshape(transitions(1:end-1),length(transitions)-1,1);
    D = reshape(transitions(2:end)-transitions(1:end-1),length(transitions)-1,1);
    % Assign type of states
    tmp = zeros(size(S));
    for j = 1:length(tmp)
        tmp(j) = sign(stateRecorded(transitions(j))-stateRecorded(transitions(j)-1));
    end
    dwells{1} = [S(tmp==-1) D(tmp==-1)];
    dwells{2} = [S(tmp==1) D(tmp==1)];
end
% Display the numbers of actually detected dwells in the two states:
disp([size(dwells{1}(:,2),1) size(dwells{2}(:,2),1)]);

%% View probability distributions of dwells in the states

% set up figure
if exist('fDist','var')
    if isvalid(fDist)
        close(fDist)
    end
end
fDist = figure('Units','normalized','Position',[0 .3 .6 .6],'Color','w');
ax = cell(2,1);

binEdges = cell(2,1);
binCenters = cell(2,1);
Hdraw = cell(2,1);
Hrecorded = cell(2,1);
for state = 1:2
    subplot(1,2,state)
    ax{state} = gca;
    % Theoretical probability distribution
    Tmax = max([max(Tdraw(:,state)) max(dwells{state}(:,2))]);
    Tspace = linspace(0,Tmax);
    plot(Tspace,exppdf(Tspace,taus(state)),'k:','LineWidth',1)
    hold on
    % Estimate from drawn dwell times
    [Hdraw{state},tmpEdges] = histcounts(Tdraw(:,state),20,'Normalization','pdf');
    tmpCenters = tmpEdges(1:end-1)+diff(tmpEdges(1:2))/2;
    plot(tmpCenters(Hdraw{state}>0),...
            Hdraw{state}(Hdraw{state}>0),'o','MarkerSize',8)
    % Estimate from recorded dwell times
    binEdges{state} = 0.5:ceil(Tmax);
    binCenters{state} = 1:binEdges{state}(end)-0.5;
    Hrecorded{state} = histcounts(dwells{state}(:,2),binEdges{state},'Normalization','pdf');
    plot(binCenters{state}(Hrecorded{state}>0),...
            Hrecorded{state}(Hrecorded{state}>0),'o','MarkerSize',8)

    % Legend
    legend({'Theoretical pdf',...
            'Estimate from drawn random numbers',...
            'Estimate from recording'},'FontSize',14,'Box','off')
    % Axis Adjustments
    ax{state} = gca;
    ax{state}.TickDir = 'out';
    ax{state}.Box = 'off';
    ax{state}.LineWidth = .5;
    ax{state}.FontSize = 12;
    ax{state}.XAxis.Label.String = 'Dwell time (in sampling intervals, i.e. frames)';
    ax{state}.YAxis.Label.String = 'Probability density (pdf)';
    ax{state}.Title.Interpreter = 'tex';
    ax{state}.Title.String = ['State ' num2str(state) ... 
                                ': tau = ' num2str(taus(state)) ...
                                ' , mean(recorded dwells) = ' num2str(round(mean(dwells{state}(:,2)),2))];
    ax{state}.Title.FontSize = 16;
end


%% Data for Curve Fitting App
state = 1;
fooX = binCenters{state}(Hrecorded{state}>0);
fooY = Hrecorded{state}(Hrecorded{state}>0);
















































