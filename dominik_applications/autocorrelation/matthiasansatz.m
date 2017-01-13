dataKorr = data;
indices = indicesE4;
frames = length(data{1}{1,1}.itrace);
for m = 1:length(indices)
    mean_x = zeros(frames,length(indices{m}) );
    mean_y = zeros(frames,length(indices{m}));
    for s = 1:length(indices{m})
        mean_x(:,s) = data{m}{indices{m}(s),2}.vwcm.disp100(:,1);
        mean_y(:,s) = data{m}{indices{m}(s),2}.vwcm.disp100(:,2);
    end
    mean_x = mean(mean_x,2);
    mean_y = mean(mean_y,2);
    for s = 1:length(indices{m})
        dataKorr{m}{indices{m}(s),2}.vwcm.disp100(:,1) = data{m}{indices{m}(s),2}.vwcm.disp100(:,1) - mean_x;
        dataKorr{m}{indices{m}(s),2}.vwcm.disp100(:,2) = data{m}{indices{m}(s),2}.vwcm.disp100(:,2) - mean_y;
    end
    
end


