function [output] = sequencefinder(sequence,testsequence,testlength,prestock)
%{
Input:  sequence        = list of all oligo-sequences from workingstock
        testsequence    = code to search in sequence
        testlength      = number of basepares to search for comparison
        prestock        = names of stocks in which you can find each sequence

Output: {1} mainsuspects    = positions of sequences found in both tests
        {2}
        {3} suspects        = prestocks in which the testsequence were found
        {4} founds          = positions of sequences the testsequence is part of
        {5} maxima3         = sums of comparisons of testsequence and sequence
        {6} discovery       = cell of all comparison of testsequenceparts and all sequences
        {7} discoverymatrix = discovery cell converted in matrix with numbering in first row and sum of items in last row

%}

%% Discovery
oligo = testsequence;
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
discoverymatrix = [1:size(discoverymatrix,2) ; discoverymatrix ; sum(discoverymatrix>0)];

%delete all columns with sum equals zero
discoverymatrix(:,discoverymatrix(end,:)==0) = [];

%in which oligos of excel list matches were found
founds = discoverymatrix(1,:);
%suspicious prestocks in working stock
%suspicious because of founds of testlength code in sequences
suspects = prestock(founds);

%{
%% Overlap

%finding comparisons in changing overlapping sequences of testoligo and sequence
%DEFINE SUMME
summe = cell(1,length(sequence));
maxima = zeros(size(summe));
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
    maxima(j) = max(summe{j});
end
%}

%{
%% Alternative:
summe2 = cell(1,length(sequence));
maxima2 = zeros(size(summe2));
for j = 1:length(sequence)
    %length of the universe for these two sequences:
    L = length(oligo)+length(sequence{j})-1;
    %units of the universe filled with "sequence":
    fill2 = zeros(1,L);
    fill2(length(oligo):end) = 1;
    summe2{j} = zeros(L,1);
    for i = 1:L
         %units of the universe filled with "oligo" during iteration i:
         fill1 = zeros(1,L);
         fill1(i:min(i+length(oligo)-1,L)) = 1;
         %units of universe filled with both sequences during iteration i:
         overlap = find(fill1 & fill2);  
         %point of reference for oligo is moving with i, 
         %p.o.r. for sequence stays fixed at value length(oligo):
         summe2{j}(i) = sum(oligo(overlap-i+1)==sequence{j}(overlap-length(oligo)+1));
    end
    maxima2(j) = max(summe2{j});
end
%}

%% Alternative 2:
summe3 = cell(1,length(sequence));
maxima3 = zeros(size(summe3));
for j = 1:length(sequence)
    L = length(oligo)+length(sequence{j})-1;
    summe3{j} = zeros(L,1);
    for i = 1:L
         overlap = max(i,length(oligo)):min(i+length(oligo)-1,L);  
         summe3{j}(i) = sum(oligo(overlap-i+1)==sequence{j}(overlap-length(oligo)+1));
    end
    maxima3(j) = max(summe3{j});
end

%% Output
%positions of highest maxima in summ3
suspect3 = find((max(maxima3)*0.6<=maxima3));
%mainsuspects are found in both lists of suspects
mainsuspects = intersect(suspect3,founds);

for i = 1:length(mainsuspects)
    output{2}{i} = [sequence{mainsuspects(i)},' in ',prestock{mainsuspects(i)}];
end

output{1} = mainsuspects;
%output{2} = 
output{3} = suspects;
output{4} = founds;
output{5} = maxima3;
output{6} = discovery;
output{7} = discoverymatrix;

end

