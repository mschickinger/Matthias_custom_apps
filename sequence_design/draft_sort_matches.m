Inds = [4 3; 9 5; 12 4; 15 7];
discovery = {};

%% create lists with all matches including start indices in testsequence and ws oligo
discombination = cell(1,length(workingstock));

for i = 3:length(discovery)
    for j = 1:size(discovery{i},1)
        for k = 1:size(discovery{i},2)
            discombination{k} = vertcat(discombination{k}, ...
                [j*ones(length(discovery{i}{j,k}),1) discovery{i}{j,k}' i*ones(length(discovery{i}{j,k}),1)]);
        end
    end
end

%% remove all shorter matches that are contained in a longer match

for k = 1:size(discombination,2)
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
            discombination{k}(discombination{k}(:,2)+discombination{k}(:,2)==n & discombination{k}(:,3)<tmp_max,:) = [];
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
        tmp_index = j + tmp_max;
    end
end

%% display in graph
colors = {'b', 'g', 'r', 'c', 'k', 'm'};
figure('Units', 'normalized', 'Position', [0 .5 1 .5])
hold off
for i = 1:size(discombination,2)
    for j = 1:size(discombination{i},1)
        plot(discombination{i}(j,1):discombination{i}(j,1)+discombination{i}(j,3), ...
            discombination{i}(j,2):discombination{i}(j,2)+discombination{i}(j,3), ...
            's','Color', colors{discombination{i}(j,3)}, 'MarkerSize', 2*discombination{i}(j,3))
        hold on
    end
    title(['Working stock oligo number ' num2str(i)])
    pause
end
