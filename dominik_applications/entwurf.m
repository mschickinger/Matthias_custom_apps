%oligo = testsequence;       %imports variables from excel list
oligo = 'CAGTTGAAAGGAATTGAGGAA';
testlength = 7;
prestock = Prestock;

%%
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

%searches for all empty cells in discovery and fill them up with zeros
discoverymatrix = zeros(size(discovery));
%it is possible to find more than one suitable codes in a sequence
for i = 1:size(discovery,1)
    for j = 1:size(discovery,2)
        %use only the first match to get a suspicious prestock because we
        %want only one number in each cell to convert it in a matrix
        if ~isempty(discovery{i,j})
            discoverymatrix(i,j) = discovery{i,j}(1);
        end
    end
end

%create new matrix in size of discovery only with zeros
%add two rows for numbering and column sum

discoverymatrix = [1:size(discoverymatrix,2) ; discoverymatrix ; sum(discoverymatrix)];

%delete all columns with sum equals zero
discoverymatrix(:,discoverymatrix(end,:)==0) = [];

%in which oligos of excel list matches were found
founds = discoverymatrix(1,:);
%suspicious prestocks in working stock
%suspicious because of founds of testlength code in sequences
suspects = prestock(founds);

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

%% Overlap

%finding comparisons in changing overlapping sequences of testoligo and sequence
%DEFINE SUMME
summe = cell(1,length(sequence));
%summe = cell(1);
%for j = 1:length(summe)
for j = 1:length(sequence)
    summe{j} = zeros(length(oligo)+length(sequence{j})-1,1);
    %for i = 1:(length(oligo)+length(sequence{j})-1)
    %when sequence and oligo has the same length
    if length(sequence{j})==length(oligo)
        for i = 1:(length(oligo)+length(sequence{j})-1)
            %before passing by
            if i<=length(oligo)
                summe{j}(i) = sum(oligo(end+1-i:end)==sequence{j}(1:i));
            %after passing by
            else
                summe{j}(i) = sum(oligo(1:(end+length(oligo)-i))==sequence{j}(i+1-length(oligo):end));
            end
        end
    %when sequence has more basepares than oligo
    elseif length(sequence{j})>length(oligo)
        for i = 1:(length(oligo)+length(sequence{j})-1)
            %before passing by
            if i<=length(oligo)
                summe{j}(i) = sum(oligo(end+1-i:end)==sequence{j}(1:i));
            %next to
            elseif i>length(oligo) && i<=length(sequence{j})
                summe{j}(i) = sum(oligo==sequence{j}(i+1-length(oligo):i));
            %after passing by
            else
                summe{j}(i) = sum(oligo(1:(end+length(sequence{j})-i))==sequence{j}(i+1-length(oligo):end));
            end
        end
    %when sequence has less basepares than oligo    
    else
        for i = 1:(length(oligo)+length(sequence{j})-1)
            %before passing by
            if i<=length(sequence{j})
                summe{j}(i) = sum(oligo(end+1-i:end)==sequence{j}(1:i));
            %next to
            elseif i>length(sequence{j}) && i<=length(oligo)
                summe{j}(i) = sum(oligo((end-i+1):(end-i+length(sequence{j})))==sequence{j});
            %after passing by
            else
                summe{j}(i) = sum(oligo(1:(end+length(sequence{j})-i))==sequence{j}((i+1-length(oligo)):end));
            end
        end
    end
end


%now we have two informations:
%founds: testoligo is in sequence
%summe: sum of overlapping codes

%%               
%output informations:
%from info one: suspects, dontforget, founds
%from info two: summe, maxsumme
%and mainsuspect which we find in both informations
output{1} = suspects{1};
output{2} = suspects{2};