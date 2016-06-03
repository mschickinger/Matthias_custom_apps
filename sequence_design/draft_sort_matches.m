testsequence = 'CAGTTGAAAGGAATTGAGGAA';
prestock = Prestock;
S6 = cell(1,length(testsequence));
i = 3;
go_on = 1;
while i <= length(testsequence) && go_on == 1
    S6{i} = sequencefinder(sequence,testsequence,i,prestock);
    go_on = size(S6{i}.discoverymatrix,2)>1;  
    i = i+1;
end
 
S6 = S6(1:i-2);

%% create lists with all matches including start indices in testsequence and ws oligo
input = S6;
discombination = cell(1,length(sequence));

for i = 3:length(input)
    for j = 1:size(input{i}.discovery,1)
        for k = 1:size(input{i}.discovery,2)
            discombination{k} = vertcat(discombination{k}, ...
                [j*ones(length(input{i}.discovery{j,k}),1) input{i}.discovery{j,k}' ...
                i*ones(length(input{i}.discovery{j,k}),1)]);
        end
    end
end

%% remove all shorter matches that are contained in a longer match

for k = 1:size(discombination,2)
    if ~isempty(discombination{k})
        %step1: same start index
        for j = unique(discombination{k}(:,1))'
            tmp = unique(discombination{k}(discombination{k}(:,1)==j,2));
            for n = tmp'
                tmp_max = max(discombination{k}(discombination{k}(:,2)==n, 3));
                discombination{k}(discombination{k}(:,2)==n & discombination{k}(:,3)<tmp_max,:) = [];
            end
        end
        %step2: same end index
        for j = unique(discombination{k}(:,1)+discombination{k}(:,3))'
            tmp = unique(discombination{k}(discombination{k}(:,1)+discombination{k}(:,3)==j,2) + ...
                discombination{k}(discombination{k}(:,1)+discombination{k}(:,3)==j,3));
            for n = tmp'
                tmp_max = max(discombination{k}(discombination{k}(:,2)+discombination{k}(:,3)==n, 3));
                discombination{k}(discombination{k}(:,2)+discombination{k}(:,3)==n & discombination{k}(:,3)<tmp_max,:) = [];
            end
        end
    end
end

%% sort by index1, then by index2

for k = 1:size(discombination,2)
    discombination{k} = sortrows(discombination{k},[1 2]);
end

%% get sums over overlapping segments

% 1st row: overlap is not taken into account
% 2nd row: overlap is taken into account

sum_in_oligo = zeros(2,size(discombination,2));
tmp = zeros(2,1);
for k = 1:size(sum_in_oligo,2)
    tmp(:) = 0;
    tmp_index = 1;
    for j = unique(discombination{k}(:,1))'
        tmp_max = max(discombination{k}(discombination{k}(:,1) == j, 3));
        tmp(1) = tmp(1) + tmp_max;
        tmp(2) = tmp(2) + max(0, tmp_max+min(0,j-tmp_index));
        tmp_index = max(tmp_index,j+tmp_max);
    end
    sum_in_oligo(:,k) = tmp;
end

%% display in graph
colors = {'b', 'g', 'r', 'c', 'k', 'm', 'y'};
figure('Units', 'normalized', 'Position', [0 .5 1 .5])
hold off
for i = 1:size(discombination,2)
    hold off
    for j = 1:size(discombination{i},1)
        plot(discombination{i}(j,1):discombination{i}(j,1)+discombination{i}(j,3), ...
            discombination{i}(j,2):discombination{i}(j,2)+discombination{i}(j,3), ...
            's-', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 2*discombination{i}(j,3))
        hold on
    end
    title(['Working stock oligo number ' num2str(i)])
    xlim([0 length(testsequence)])
    ylim([0 length(sequence{i})])
    set(gca, 'XTick', 1:length(testsequence), 'YTick', 1:length(sequence{i}))
    grid on
    pause
end
