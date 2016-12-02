%{
'0' = 'A'
'1' = 'T'
'2' = 'C'
'3' = 'G'
%}

%% Generate all numbers from 0 to 4^L-1
L = 8;
b = 4; %base(s) ;)
N = b^L;
seqs = char(zeros(N,L));
for n = 0:N-1
    seqs(n+1,:) = dec2base(n,b,L);
end

%% Weed out all sequences with 
% undesired GC-contents
% 3 or more identical consecutive bases
des = [4 5 6];
c = length(seqs);
while c>0
    wrongNumber = ~ismember(sum(ismember(seqs(c,:),'23')),des);
    tooMany = 0;
    for i = 0:3
        tmp = (seqs(c,:)==num2str(i));
        tmp = tmp(1:end-2)+tmp(2:end-1)+tmp(3:end);
        tooMany = tooMany + any(tmp==3);
    end
    if wrongNumber || tooMany
        seqs(c,:) = [];
    end
    c = c-1;
end

%% Transform to ATCG
for i = 1:numel(seqs)
    if seqs(i) == '0'
        seqs(i) = 'A';
    elseif seqs(i) == '1'
        seqs(i) = 'T';
    elseif seqs(i) == '2';
        seqs(i) = 'C';
    elseif seqs(i) == '3';
        seqs(i) = 'G';
    end
end

%% Get deltaGs
T = 23;
NaCl = 0.5;
deltaG = zeros(size(seqs,1),1);
for i = 1:length(deltaG)
    tmp = oligoprop(seqs(i,:),'Temp',T,'Salt',NaCl);
    deltaG(i) = tmp.Thermo(3,3);
end

%% Subselection in energy interval
% 8mer dG = -10.8683
%{
bla = oligoprop('CAGGAACG','Temp',23,'Salt',500);
bla.Thermo(3,3)
%}
lower = -10.95;
upper = -10.8;
subset = find(deltaG>lower & deltaG<upper);
select = seqs(subset,:);

selectAT = select(ismember(select(:,1),'AT') & ismember(select(:,end),'AT'),:);
selectGC = select(ismember(select(:,1),'GC') & ismember(select(:,end),'GC'),:);

% clear out reverse complements
at = 1;
while at < size(selectAT,1)
    getrID = 0;
    for i = at+1:size(selectAT,1)
        if strcmp(selectAT(at,:),rev_comp(selectAT(i,:)))
            getrID = i;
        end
    end
    if getrID
        selectAT(getrID,:) = [];
    end
    at = at+1;
end
gc = 1;
while gc < size(selectGC,1)
    getrID = 0;
    for i = gc+1:size(selectGC,1)
        if strcmp(selectGC(gc,:),rev_comp(selectGC(i,:)))
            getrID = i;
        end
    end
    if getrID
        selectGC(getrID,:) = [];
    end
    gc = gc+1;
end

whos selectAT
whos selectGC

%% Get rid of dyads / triads
tupel = 3;
at = 1;
while at < size(selectAT,1)
    getrID = [];
    for i = at+1:size(selectAT,1)
        for j = 0:size(selectAT,2)-tupel
            if strcmp(selectAT(at,j+(1:tupel)),rev_comp(selectAT(i,j+(1:tupel))))
                getrID = [getrID;i];
            end
        end
    end
    if getrID
        selectAT(getrID,:) = [];
    end
    at = at+1;
end
gc = 1;
while gc < size(selectGC,1)
    getrID = [];
    for i = gc+1:size(selectGC,1)
        for j = 0:size(selectGC,2)-tupel
            if strcmp(selectGC(gc,j+(1:tupel)),rev_comp(selectGC(i,j+(1:tupel))))
                getrID = [getrID;i];
            end
        end
    end
    if getrID
        selectGC(getrID,:) = [];
    end
    gc = gc+1;
end
whos selectAT
whos selectGC
% %% Separate sequences that don't contain 'T'
% idx = zeros(size(seqs,1),1);
% for i = 1:size(seqs,1)
%     idx(i) = any(seqs(i,:)=='T');
% end
% seqs_noT = seqs(idx==0,:);

%% make txt file:
sel = selectGC;
filename = '161129_iso8_GC_plus12T.txt';

fileID = fopen(filename, 'w+');
fprintf(fileID, 'sequences:\n');
for i = 1:size(sel,1)
fprintf(fileID, '%8s\n', ['TTTTTTTTTTTT' sel(i,:) ';']);
end
fprintf(fileID, 'reverse complements:\n');
for i = 1:size(sel,1)
fprintf(fileID, '%8s\n', ['TTTTTTTTTTTT' rev_comp(sel(i,:)) ';']);
end
fclose(fileID);

%% specific positions of AT/GC: 2-4-2
AT2 = {'AA' 'AT' 'TA' 'TT'}';
CG4 = cell(16,1);
for n = 1:16
    tmp = dec2base(n-1,2,4);
    for i = 1:4
        if tmp(i) == '0'
            CG4{n}(i) = 'C';
        elseif tmp(i) == '1'
            CG4{n}(i) = 'G';
        end
    end
end
allcombA2C4A2 = cell(0,1);
for i = 1:4
    for j = 1:16
        for k = 1:4
            %tmp = (i-1)*4+(j-1)*16+k;
            allcombA2C4A2 = [allcombA2C4A2;[AT2{i} CG4{j} AT2{k}]];
        end
    end
end

%% specific positions of AT/GC: 1-1-4-1-1
AC2 = {'AC' 'AG' 'TC' 'TG'}';
X4 = cell(4^4,1);
for n = 1:4^4
    tmp = dec2base(n-1,4,4);
    for i = 1:4
        if tmp(i) == '0'
            X4{n}(i) = 'A';
        elseif tmp(i) == '1'
            X4{n}(i) = 'T';
        elseif tmp(i) == '2'
            X4{n}(i) = 'C';
        elseif tmp(i) == '3'
            X4{n}(i) = 'G';
        end
    end
end
allcombAC2X4CA2 = cell(0,1);
for i = 1:4
    for j = 1:4^4
        for k = 1:4
            %tmp = (i-1)*4+(j-1)*16+k;
            allcombAC2X4CA2 = [allcombAC2X4CA2;[AC2{i} X4{j} fliplr(AC2{k})]];
        end
    end
end
%% get rid of all reverse complements