% This script gives stats on Main population vs. Outliers. Writes text file
%{
clear lifetimes INdices Names
load lts_main_pop.mat lifetimes INdices Names Tmin Tmax
%}

%% OUTdices

OUTdices = cell(size(INdices));
for j = 1:numel(OUTdices)
    OUTdices{j} = reshape(setdiff(1:size(lifetimes{j}.ALL,1),INdices{j}),[],1);
end

%% Write text file with stats
Nspecies = numel(INdices);
tausall = zeros(Nspecies,2);
tausin = tausall;
tausout = tausall;
fileID = fopen('IOstats.txt', 'w');
fprintf(fileID, 'nIN\tnOUT\tpOUT\ttauBall\ttauUall\ttauBin\ttauUin\ttauBout\ttauUout\tfB\tfU\n');
for j = 1:Nspecies
    fprintf(fileID, [num2str(numel(INdices{j}),'%d') '\t' num2str(numel(OUTdices{j}),'%d') '\t']); %nIN,nOUT
    fprintf(fileID, [num2str(100*numel(OUTdices{j})/(numel(OUTdices{j})+numel(INdices{j})),'%.3f') '\t']); %pOUT
    [khatall, ~ ] = get_corrected_rates({vertcat(lifetimes{j}.ALL{:,1}) vertcat(lifetimes{j}.ALL{:,2})},Tmin,Tmax);
    [khatin, ~ ] = get_corrected_rates({vertcat(lifetimes{j}.ALL{INdices{j},1}) vertcat(lifetimes{j}.ALL{INdices{j},2})},Tmin,Tmax);
    [khatout, ~ ] = get_corrected_rates({vertcat(lifetimes{j}.ALL{OUTdices{j},1}) vertcat(lifetimes{j}.ALL{OUTdices{j},2})},Tmin,Tmax);
    tausall(j,:) = 1./khatall;
    tausin(j,:) = 1./khatin;
    tausout(j,:) = 1./khatout;
    fprintf(fileID, [num2str(tausall(j,1),'%.1f') '\t' num2str(tausall(j,2),'%.1f') '\t']);
    fprintf(fileID, [num2str(tausin(j,1),'%.1f') '\t' num2str(tausin(j,2),'%.1f') '\t']);
    fprintf(fileID, [num2str(tausout(j,1),'%.1f') '\t' num2str(tausout(j,2),'%.1f') '\t']);
    fprintf(fileID, [num2str(tausall(j,1)/tausin(j,1),'%.3f') '\t' num2str(tausall(j,2)/tausin(j,2),'%.3f') '\n']);
end
fclose(fileID);