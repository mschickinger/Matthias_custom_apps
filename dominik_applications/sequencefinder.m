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
        {5} maxima         = sums of comparisons of testsequence and sequence
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


%% Overlap

summe = cell(1,length(sequence));
maxima = zeros(size(summe));
for j = 1:length(sequence)
    L = length(oligo)+length(sequence{j})-1;
    summe{j} = zeros(L,1);
    for i = 1:L
         overlap = max(i,length(oligo)):min(i+length(oligo)-1,L);  
         summe{j}(i) = sum(oligo(overlap-i+1)==sequence{j}(overlap-length(oligo)+1));
    end
    maxima(j) = max(summe{j});
end

%% Output
%positions of highest maxima in summ3
%cut-off level is defined by '*0.6'
suspect3 = find((max(maxima(maxima<length(oligo)))*0.6<=maxima));

%mainsuspects are found in both lists of suspects
mainsuspects = intersect(suspect3,founds);

%column-sum of summe
columnsum = zeros(1,size(summe,2));
for j = 1:size(summe,2)
    columnsum(j) = sum(summe{j});
end

info = cell(1,length(mainsuspects));
for i = 1:length(mainsuspects)
    info{i} = [sequence{mainsuspects(i)},' in ',prestock{mainsuspects(i)}];
end
output.mainsuspects = mainsuspects;
output.info = info;
output.summe = summe;
output.columnsum = columnsum;
output.suspects = suspects;
output.founds = founds;
output.maxima = maxima;
output.discovery = discovery;
output.discoverymatrix = discoverymatrix;

end

