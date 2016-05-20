function [output] = sequencefinder(sequence,testsequence,testlength,prestock)

oligo = testsequence;       %imports variables from excel list
%testlength = 7;             %free parameter for length of basepares to compare

for i = 1:(length(oligo{1})-testlength+1)
    oligotest{i} = oligo{1}(i:i+testlength-1);      %cuts the testsequence in all possible parts of testlength length
    for j = 1:length(sequence)
        discovery{i,j} = regexp(sequence{j},oligotest{i});  %search for all possible testsequenceparts in the list of sequences
    end                                                     %and gives out a cell of match informations
end

oligorev{1} = rev_comp(oligo{1});   %gives the complementar sequence of testsequence and do the same again

for i = 1:(length(oligorev{1})-testlength+1)
    oligotestrev{i} = oligorev{1}(i:i+testlength-1);
    for j = 1:length(sequence)
        discoveryrev{i,j} = regexp(sequence{j},oligotestrev{i});
    end
end

indices = cellfun(@isempty,discovery);      %searches for all empty cells
discovery(indices) = {0};                   %fills up the empty cells with zeros
discoverymatrix = cell2mat(discovery);      %convert the cell into a matrix
discoverymatrix(2:(end+1),:) = discoverymatrix;
for i = 1:size(discoverymatrix,2)
    discoverymatrix(1,i) = i;               %labeling the first row with the oligo number in excel list
end

indicesrev = cellfun(@isempty,discoveryrev);%do the same for the rev-cell
discoveryrev(indicesrev) = {0};
discoveryrevmatrix = cell2mat(discoveryrev);
discoveryrevmatrix(2:(end+1),:) = discoveryrevmatrix;
for i = 1:size(discoveryrevmatrix,2)
    discoveryrevmatrix(1,i) = i;            %labeling the first row with the oligo number in excel list
end

a{1} = sum(discoverymatrix(2:end,:),1);     %sum up coloms with zeros under the row number
discoverymatrix(:,find(a{1}==0)) = [];      %delet the total colume where the sum is zero

a{2} = sum(discoveryrevmatrix(2:end,:),1);  %the same for the rev matrix
discoveryrevmatrix(:,find(a{2}==0)) = [];

founds{1} = discoverymatrix(1,1:end);       %in which oligos of excel list matches were found

founds{2} = discoveryrevmatrix(1,1:end);    %in which reverse complementar oligos of list matches were found

for k = 1:2
    for i = 1:length(founds{k})                                                    %count of compared basepares with oligo
       if length(oligo{1})==length(sequence{founds{k}(i)})                         %check if oligo and sequence have the same length
            match{k}(i) = sum(sequence{founds{k}(i)}==oligo{1});                   %count matches
       elseif length(oligo{1})<length(sequence{founds{k}(i)})                      %sequence is longer than oligo
            for j = 1:(length(sequence{founds{k}(i)})-length(oligo{1})+1)          %take all parts of sequence in length of oligo
                sequencetest{j} = sequence{founds{k}(i)}(j:j+length(oligo{1})-1);  %and compare them with the oligo
                prematch{k}(j) = sum(oligo{1}==sequencetest{j});
            end
            match{k}(i) = max(prematch{k}(:));                                     %take only the part of most compare
       else                                                                        %oligo is longer than sequence
            for m = 1:(length(oligo{1})-length(sequence{founds{k}(i)})+1)          %take all parts of oligo in length of sequence
            sequencetestelse{m} = oligo{1}(m:m+length(sequence{founds{k}(i)})-1);  %and compare them with the sequence
            prematchelse{k}(m) = sum(sequencetestelse{m}==sequence{founds{k}(i)});
            end
            match{k}(i) = max(prematchelse{k}(:));     %take only the part of most compare
       end
    end

suspicious{k} = prestock(founds{k});        %suspicious prestocks in working stock
end

end

