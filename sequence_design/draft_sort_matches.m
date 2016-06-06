% 
% testsequence = {'AGCTCTCACGGAAAAAGAGACG'; ... % btm (22) --> original, E1
%                 'TTCTTTGATTAGTAATAACAT'; ... % seg 4.6 (21) --> E3
%                 'CAGTTGAAAGGAATTGAGGAA'; ... % seg 6.6 (21) --> E2
%                 'CCTGAGCAAAAGAAGATGATG'; ... % seg 8.6 (21) --> E1, E3
%                 'GTATAAAGCCAACGCTCAACA'; ... % seg 10.6 (21) --> E2
%                 'TTACCAACGCTAACGAGCGTC'; ... % leash4_3'int (21) --> original
%                 };
            
% 
% testsequence = {'AAAAGAAGATGATG'; % 14mer E1 fix
%                 'TCTGGTCAGTTG'; % 12mer E2 fix (6.6)
%                 'GCGTTATACAAA'; % 12mer E2 fix (10.6)
%                 'AATTAACCGTTG'; % 12mer E3 fix (4.6)
%                 'GCGAATTATTCA'; % 12mer E3 fix (8.6)
%                 };

% E2 / E3 fix asymmetric linker:

testsequence = {'TCTGGTCAGTTG'; ... % E2 12mer in seg 6.6
                'TTCTTACCAGTATAAAGCCAACGCTCAACA'; ... % E2 30mer in seg 10.6
                'GCGTTATACAAA'; ... % E2 12mer in seg 10.6
                'GCAAATCAACAGTTGAAAGGAATTGAGGAA'; ... % E2 30mer in seg 6.6
                'AATTAACCGTTG'; ... % E3 12mer in seg 4.6
                'TTTCAATTACCTGAGCAAAAGAAGATGATG'; ... % E3 30mer in seg 8.6
                'GCGAATTATTCA'; ... % E3 12mer in seg 8.6
                'TAGCAATACTTCTTTGATTAGTAATAACAT'; ... % E3 30mer in seg 4.6
                };


testsequence = [testsequence cell(size(testsequence))];

for i = 1:size(testsequence,1)
    testsequence{i,2} = rev_comp(testsequence{i,1});
end


% sequence: need to import column 'sequence' from Excel sheet or load a .mat file
prestock = Prestock;

%% 
sequence_match = cell(size(testsequence));
for s = 1:size(sequence_match,1)
    for r = 1:2
        sequence_match{s,r} = cell(1,length(testsequence{s,r}));
        i = 3;
        go_on = 1;
        while i <= length(testsequence{s,r}) && go_on == 1
            sequence_match{s,r}{i} = sequencefinder(sequence,testsequence{s,r},i,prestock);
            go_on = size(sequence_match{s,r}{i}.discoverymatrix,2)>(1+(s==4)); % add s==2 to increase threshold to 2 for seg 4.6  
            i = i+1;
        end
        sequence_match{s,r} = sequence_match{s,r}(1:i-2);  
    end
end

%% create lists with all matches including start indices in testsequence and ws oligo
discombination = cell(size(testsequence));
for s = 1:size(discombination,1)
    for r = 1:size(discombination,2)
        discombination{s,r} = cell(1,length(sequence));
        for i = 3:length(sequence_match{s,r})
            for j = 1:size(sequence_match{s,r}{i}.discovery,1)
                for k = 1:size(sequence_match{s,r}{i}.discovery,2)
                    discombination{s,r}{k} = vertcat(discombination{s,r}{k}, ...
                        [j*ones(length(sequence_match{s,r}{i}.discovery{j,k}),1) sequence_match{s,r}{i}.discovery{j,k}' ...
                        i*ones(length(sequence_match{s,r}{i}.discovery{j,k}),1)]);
                end
            end
        end
    end
end
%% remove all shorter matches that are contained in a longer match
for s = 1:size(discombination,1)
    for r = 1:size(discombination,2)
        for k = 1:size(discombination{s,r},2)
            if ~isempty(discombination{s,r}{k})
                %step1: same start index
                for j = unique(discombination{s,r}{k}(:,1))'
                    tmp = unique(discombination{s,r}{k}(discombination{s,r}{k}(:,1)==j,2));
                    for n = tmp'
                        tmp_max = max(discombination{s,r}{k}(discombination{s,r}{k}(:,2)==n, 3));
                        discombination{s,r}{k}(discombination{s,r}{k}(:,2)==n & discombination{s,r}{k}(:,3)<tmp_max,:) = [];
                    end
                end
                %step2: same end index
                for j = unique(discombination{s,r}{k}(:,1)+discombination{s,r}{k}(:,3))'
                    tmp = unique(discombination{s,r}{k}(discombination{s,r}{k}(:,1)+discombination{s,r}{k}(:,3)==j,2) + ...
                        discombination{s,r}{k}(discombination{s,r}{k}(:,1)+discombination{s,r}{k}(:,3)==j,3));
                    for n = tmp'
                        tmp_max = max(discombination{s,r}{k}(discombination{s,r}{k}(:,2)+discombination{s,r}{k}(:,3)==n, 3));
                        discombination{s,r}{k}(discombination{s,r}{k}(:,2)+discombination{s,r}{k}(:,3)==n & discombination{s,r}{k}(:,3)<tmp_max,:) = [];
                    end
                end
            end
        end
    end
end

%% sort by index1, then by index2
for s = 1:size(discombination,1)
    for r = 1:size(discombination,2)
        for k = 1:size(discombination{s,r},2)
            discombination{s,r}{k} = sortrows(discombination{s,r}{k},[1 2]);
        end
    end
end
%% get sums over overlapping segments

% 1st row: overlap is not taken into account
% 2nd row: overlap is taken into account
sum_in_oligo = cell(size(discombination));
for s = 1:size(discombination,1)
    for r = 1:size(discombination,2)
        % 1st row: overlap is not taken into account
        % 2nd row: overlap is taken into account
        sum_in_oligo{s,r} = zeros(2,size(discombination{s,r},2));
        for k = 1:size(sum_in_oligo{s,r},2)
            tmp = zeros(2,1);
            tmp_index = 1;
            for j = unique(discombination{s,r}{k}(:,1))'
                tmp_max = max(discombination{s,r}{k}(discombination{s,r}{k}(:,1) == j, 3));
                tmp(1) = tmp(1) + tmp_max;
                tmp(2) = tmp(2) + max(0, tmp_max+min(0,j-tmp_index));
                tmp_index = max(tmp_index,j+tmp_max);
            end
            sum_in_oligo{s,r}(:,k) = tmp;
        end
    end
end
%% display in graph
colors = {'b', 'g', 'r', 'c', 'k', 'm', 'y'};
figure('Units', 'normalized', 'Position', [0 .5 1 .5])
hold off
s = 4;
r = 2;
for i = [70 184]%1:size(discombination{s,r},2)
    hold off
    for j = 1:size(discombination{s,r}{i},1)
        plot(discombination{s,r}{i}(j,1):discombination{s,r}{i}(j,1)+discombination{s,r}{i}(j,3)-1, ...
            discombination{s,r}{i}(j,2):discombination{s,r}{i}(j,2)+discombination{s,r}{i}(j,3)-1, ...
            's-', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 2*discombination{s,r}{i}(j,3))
        hold on
    end
    title(['Working stock oligo number ' num2str(i)])
    xlim([0 length(testsequence{s,r})])
    ylim([0 length(sequence{i})])
    set(gca, 'XTick', 1:length(testsequence{s,r}), 'YTick', 1:length(sequence{i}))
    grid on
    pause
end


%% Display testsequence for copy/paste to DINAmelt server mask
s = 7;
r = 1;
display(['List for testsequence ' num2str(s) ',' num2str(r) ':'])
for i = 1:208
    disp('GTATAAAGCCAACGCTCAACATCCAGAGACG;')
    %disp([testsequence{s,r} ';'])
end

%disp(rev_comp(testsequence{s,r}))

%% Display all prestock sequences
fprintf('%s;\n', sequence{:})