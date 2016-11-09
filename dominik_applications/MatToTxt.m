function [] = MatToTxt(vector,hop,data)

m = vector(:,1);
s = vector(:,2);
name = [];

for i = 1:size(vector,1)
    name = [hop.date,'_',hop.sample,'_','m',num2str(m(i)),'s',num2str(s(i)),'.txt'];
    inhalt = data{m(i)}{s(i),1}.vwcm.rms10;
    fileID = fopen(name,'w');
    fprintf(fileID,'%6.4f\r\n',inhalt);
    fclose(fileID);

end
end


