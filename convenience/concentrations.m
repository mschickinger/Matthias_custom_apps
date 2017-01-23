%% Coefficients and sequence strings
coeff_bases = [15400;%A
        7400;%C
        11500;%G
        8700];%T
coeff_MWG = [15400;%A
        7500;%C
        11700;%G
        9200];%T
strings_bases = {'A';'C';'G';'T'};
coeff_pairs = [27400;%AA
        21200;%AC
        25000;%AG
        22800;%AT
        21200;%CA
        14600;%CC
        18000;%CG
        15200;%CT
        25200;%GA
        17600;%GC
        21600;%GG
        20000;%GT
        23400;%TA
        16200;%TC
        19000;%TG
        16800];%TT
strings_pairs = {'AA'; 'AC'; 'AG'; 'AT';...
                'CA'; 'CC'; 'CG'; 'CT';...
                'GA'; 'GC'; 'GG'; 'GT';...
                'TA'; 'TC'; 'TG'; 'TT'};
    
%% Enter oligo IDs and sequences
N_oligos = inputdlg('How many oligos?', 'N_oligos', 1,{'2'});
N_oligos = str2double(N_oligos{1});
prompt = cell(1,N_oligos);
for i = 1:N_oligos
    prompt{i} = ['Enter oligo ID ' num2str(i)];
end
oligoID = inputdlg(prompt, 'OligoIDs');
for i = 1:N_oligos
    prompt{i} = ['Enter sequence for ' oligoID{i}];
end
seq = inputdlg(prompt, 'sequences');
%% Determine extinction coefficients
epsilon_NN = zeros(size(seq));
epsilon_MWG = epsilon_NN;
for i = 1:length(seq)
    tmp_pairs = cell(1,length(seq{i})-1);
    for j = 1:length(tmp_pairs)
        tmp_pairs{j} = seq{i}(j:j+1);
    end
    for k = 1:length(coeff_pairs)
        epsilon_NN(i) = epsilon_NN(i) + ...
            sum(cellfun(@(x) strcmp(x,strings_pairs{k}), tmp_pairs))*coeff_pairs(k);
    end
    for k = 1:length(coeff_bases)
        epsilon_NN(i) = epsilon_NN(i) - sum(seq{i}(2:end-1)==strings_bases{k})*coeff_bases(k);
        epsilon_MWG(i) = epsilon_MWG(i) + sum(seq{i}==strings_bases{k})*coeff_MWG(k);
    end
end

%%
% read in absorption values, reshape and average
fileID = fopen('concentrations.txt', 'w+');
%fSpecStr = '%10s\t';
%fSpecDec = '%10d\t';
%fSpecStr = '%\t';
fprintf(fileID,'%12s\t%12s\t%12s\t%12s\t%12s\t%12s\n','oligoID','mean(Abs260)','epsilon(NN)','epsilon(MWG)','conc.(NN)','conc.(MWG)');
for i = 1:length(seq)
    fprintf(fileID,'%12s\t',oligoID{i});
    fprintf(fileID,'%9.2f\t',mA260(i));
    fprintf(fileID,'%12d\t',epsilon_NN(i));
    fprintf(fileID,'%12d\t',epsilon_MWG(i));
    fprintf(fileID,'%9.2f uM\t',mA260(i)/epsilon_NN(i)./1e-6);
    fprintf(fileID,'%9.2f uM\n',mA260(i)/epsilon_MWG(i)./1e-6);
end
%fprintf(fileID,'oligoID:\t %9s\t %9s\t %9s\t %9s\n', oligoID{:});
%fprintf(fileID,'epsilon(NN):\t %9d\t %9d\t %9d\t %9d\n', epsilon_NN);
%fprintf(fileID,'epsilon(MWG):\t %9d\t %9d\t %9d\t %9d\n', epsilon_MWG);
%fprintf(fileID,'conc.(NN):\t %3.2f uM\t %3.2f uM\t %3.2f uM\t %3.2f uM\n', mA260./epsilon_NN'./1e-6);
%fprintf(fileID,'conc.(MWG):\t %3.2f uM\t %3.2f uM\t %3.2f uM\t %3.2f uM\n', mA260./epsilon_MWG'./1e-6);
fclose(fileID);
