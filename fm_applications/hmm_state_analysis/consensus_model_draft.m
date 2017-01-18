% 'Consensus' Hidden Markov Model
%% Containers for model data
xyModels = cell(size(models));
rmsModels = cell(size(models));
XYstates = cell(length(models),2);
RMSstates = cell(length(models),2);
for i = 1:length(models)
    xyModels{i}.nstates = 2;
    rmsModels{i}.nstates = 2;
    xyModels{i}.states = cell(2,1);
    rmsModels{i}.states = cell(2,1);
    for j = 1:2
        xyModels{i}.states{j}.mu = [0 0];
        xyModels{i}.states{j}.sigma = [1 1];
        xyModels{i}.states{j}.log_emission_probability = @(o) -log(2*pi) - log(prod(state.sigma)) - ...
                                                        (1/2)*(((o(:,1)-state.mu(1))./state.sigma(1)).^2+((o(:,2)-state.mu(2))./state.sigma(2)).^2);
        rmsModels{i}.states{j}.mu = [0 0];
        rmsModels{i}.states{j}.sigma = [1 1];
        rmsModels{i}.states{j}.log_emission_probability = @(o) -log(2*pi) - log(prod(state.sigma)) - ...
                                                        (1/2)*(((o(:,1)-state.mu(1))./state.sigma(1)).^2+((o(:,2)-state.mu(2))./state.sigma(2)).^2);
                                                
        XYstates{i,j} = zeros(2,0);
    end
end

%%
SelOK = 1:10; % or some selection of successfully analyzed particles.

%% Emission probabilities:
tmpST = cell(1,2);
for n = SelectionOK
    tmpXY = XY{n};
    tmpRMS = RMSfilt2d(tmpXY',101);
    tmpMedI = medI{n};
    for j = 1:2
        tmpST{j} = find(state_trajectories{n}==j);
    end
    [tmpSegments, tmpIdx] = iSegments(tmpMedI, iEdges);
    for i = 1:length(tmpIdx)
        for j = 1:2
            tmpFrames = tmpST{j}(tmpST{j}>=tmpSegments(i,1) & tmpST{j}<=tmpSegments(i,2));
            XYstates{tmpIdx(i),j} = [XYstates{j} tmpXY(:,tmpFrames)];
            RMSstates{tmpIdx(i),j} = [RMSstates{j} tmpRMS(tmpFrames)];
        end
    end
end

%% Update mus and sigmas in the consensus arrays
for i = 1:length(xyModels)
    for j = 1:2
        xyModels{i}.states{j}.mu = mean(XYstates{i,j},2)';
        xyModels{i}.states{j}.sigma = std(XYstates{i,j},0,2)';
        rmsModels{i}.states{j}.mu = mean(RMSstates{i,j});
        rmsModels{i}.states{j}.sigma = std(RMSstates{i,j});
    end
end
