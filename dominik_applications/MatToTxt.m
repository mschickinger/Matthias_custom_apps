function [] = MatToTxt(vector,DateAndSample,data)

if iscell(DateAndSample.date)
    date = DateAndSample.date{1};
    sample = DateAndSample.sample{1};
else
    date = DateAndSample.date;
    sample = DateAndSample.sample;
end

stem = inputdlg('Enter filename stem:', 'Stem', 1, {[date '_' sample]});
stem = stem{1};

for i = 1:size(vector,1)
    name = ['m',num2str(vector(i,1)),'s',num2str(vector(i,2)),'_',stem,'.txt'];
    inhalt = data{vector(i,1)}{vector(i,2),1}.vwcm.rms10;
    fileID = fopen(name,'w');
    fprintf(fileID,'%6.4f\r\n',inhalt);
    fclose(fileID);
end
end


