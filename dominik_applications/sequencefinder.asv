function [output] = sequencefinder(sequence,testsequence,testlength,prestock)
%{
Input:  sequence = list of all oligo-sequences from workingstock
        testsequence
        testlength = number of basepares to search for comparison
        prestock = names of stocks in which you can find each sequence

Output: ...

%}

%imports variables from excel list
oligo = testsequence;

%oligo = VarName9{1};
%testlength = 7;
%prestock = Prestock;

oligotest = cell(1,(length(oligo)-testlength+1));
discovery = cell((length(oligo)-testlength+1),length(sequence));
for i = 1:(length(oligo)-testlength+1)
    %cuts the testsequence in all possible parts of testlength length
    oligotest{i} = oligo(i:i+testlength-1);
    for j = 1:length(sequence)
        %search for all possible testsequenceparts in the list of sequences
        %and gives out a cell of match informations
        discovery{i,j} = regexp(sequence{j},oligotest{i});
    end
end

%IS THIS REALLY NECESSARY??????
%gives the complementar sequence of testsequence and creates the same
%discovery cell as before
oligorev = rev_comp(oligo);
oligotestrev = cell(1,(length(oligorev)-testlength+1));
discoveryrev = cell((length(oligorev)-testlength+1),length(sequence));
for i = 1:(length(oligorev)-testlength+1)
    oligotestrev{i} = oligorev(i:i+testlength-1);
    for j = 1:length(sequence)
        discoveryrev{i,j} = regexp(sequence{j},oligotestrev{i});
    end
end

%searches for all empty cells in discovery and fill them up with zeros
discovery(cellfun(@isempty,discovery)) = {0};
dontforget{1} = zeros(size(discovery,1),size(discovery,2));
%it is possible to find more than one suitable code in a sequence
for i = 1:size(discovery,1)
    for j = 1:size(discovery,2)
        %use only the first match to get a suspicious prestock because we
        %want only one number in each cell to convert it in a matrix
        if size(discovery{i,j},2)>1
            %but keep the other matches in mind
            dontforget{1}(i,j) = discovery{i,j}(2:end);
            discovery{i,j} = discovery{i,j}(1);
        end
    end
end

%create new matrix in size we need and two layers only with zeros
discoverymatrix = zeros(size(discovery,1)+2,size(discovery,2),2);
%converte the discovery cell into the first layer of the new matrix
discoverymatrix(2:(end-1),:,1) = cell2mat(discovery);
%labeling the first row with the oligo number in excel list in both layers
for m = 1:2
    for i = 1:size(discoverymatrix,2)
        discoverymatrix(1,i,m) = i;
    end
end

%do the same for the reverce cell in layer two
discoveryrev(cellfun(@isempty,discoveryrev)) = {0};
dontforget{2} = zeros(size(discoveryrev,1),size(discoveryrev,2));
for i = 1:size(discoveryrev,1)
    for j = 1:size(discoveryrev,2)
        if size(discoveryrev{i,j},2)>1
            dontforget{2}(i,j) = discoveryrev{i,j}(2:end);
            discoveryrev{i,j} = discoveryrev{i,j}(1);
        end
    end
end

discoverymatrix(2:(end-1),:,2) = cell2mat(discoveryrev);

%sum up all columns from second index to second to last index
column = zeros(1,size(discovery,2),2);
discoverycell = cell(1,2);
discoverycell{1} = zeros(size(discoverymatrix,1),size(discoverymatrix,2));
discoverycell{2} = zeros(size(discoverymatrix,1),size(discoverymatrix,2));
for k = 1:2
    column(1,:,k) = sum(discoverymatrix(2:(end-1),:,k),1);
    discoverymatrix(end,:,k) = column(1,:,k);
    %we need a cell again because after deleting empty columns the layers
    %have different sizes
    discoverycell{k} = discoverymatrix(:,:,k);
    %delete all columns with sum equals zero in both cells
    discoverycell{k}(:,column(1,:,k)==0) = [];
end

%in which oligos of excel list matches were found
founds{1} = discoverycell{1}(1,:);
founds{2} = discoverycell{2}(1,:);
%suspicious prestocks in working stock
%suspicious because of founds of testlength code in sequences
suspects{1} = prestock(founds{1});
suspects{2} = prestock(founds{2});

%match{1} = zeros(1,length(founds{1}));
%match{2} = zeros(1,length(founds{2}));
%sequencetest{1} = 
%sequencetest{2} = 
%prematch{1} =
%prematch{2} =
%sequencetestelse{1} =
%sequencetestelse{2} =
%prematchelse{1}(m) =
%prematchelse{2}(m) =

%{
for k = 1:2
    for i = 1:length(founds{k}) %count of compared basepares with oligo
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
end
%}


%finding comparisons in changing overlapping sequences of testoligo and sequence
%DEFINE SUMME
%summe = ...
for j = 1:length(sequence)
    summe{j} = 0;
    for i = 1:(length(oligo)+length(sequence{j})-1)
        if length(sequence{j})==length(oligo)
            summe{j} = sum(oligo(max(end+1-i,1):end)==sequence{j}(1:min(i,length(sequence{j})))) + summe{j};
        elseif length(sequence{j})>length(oligo)
            if i<=length(oligo)
                summe{j} = sum(oligo(end+1-i:end)==sequence{j}(1:i)) + summe{j};
            else
                summe{j} = sum(oligo==sequence{j}(i+1-length(oligo):min(i,length(sequence{j})))) + summe{j};
            end
        else
            if i<=length(sequence{j})
                summe{j} = sum(oligo(end+1-i:end)==sequence{j}(1:i)) + summe{j};
            else
                summe{j} = sum(oligo(end-i:end-i+length(sequence{j}))==sequence{j}) + summe{j};
            end
        end
    end
end

%now we have two informations:
%founds: testoligo is in sequence
%summe: sum of overlapping codes

               
%output informations:
%from info one: suspects, dontforget, founds
%from info two: summe, maxsumme
%and mainsuspect which we find in both informations
output{1} = suspects{1};
output{2} = suspects{2};

end

