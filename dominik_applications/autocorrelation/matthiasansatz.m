dataKorr = cell(size(data));
indices = indicesE4;
frames = length(data{1}{1,1}.itrace);
for m = 1:length(indices)
    dataKorr{m} = cell(size(data{m}));
    meanXY = zeros(size(data{m}{1,1}.vwcm.disp100));
    for s = 1:length(indices{m})
        meanXY = meanXY + data{m}{indices{m}(s),2}.vwcm.disp100;
    end
    meanXY = meanXY./length(indices{m});
    for s = 1:length(indices{m})
        dataKorr{m}{indices{m}(s),2}.vwcm.disp100 = data{m}{indices{m}(s),2}.vwcm.disp100 - meanXY;
    end
    dataKorr{m}{1,1}.itrace = data{m}{1,1}.itrace; 
end


