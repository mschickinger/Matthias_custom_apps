function [ density, area ] = update_density( density, area, RMS, threshs, segments, segmInds, stateFrames, Lmin )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    tmpSeg = 1;
    for i = 1:size(density,1)
        if ~isnan(stateFrames(i,1))
            while stateFrames(i,1) > segments(tmpSeg,2)
                tmpSeg = tmpSeg + 1;
            end
            tmpA = zeros(1,stateFrames(i,2));
            tmpB = zeros(1,stateFrames(i,2));
            tmpI = stateFrames(i,1):sum(stateFrames(i,:))-1;
            tmpF = 0;
            while sum(stateFrames(i,:)) > segments(tmpSeg,2)
                tmpA((tmpF+1):(segments(tmpSeg,2)-stateFrames(i,1))) = ...
                    RMS(tmpI((tmpF+1):(segments(tmpSeg,2)-stateFrames(i,1))))-threshs(segmInds(tmpSeg));
                tmpB((tmpF+1):(segments(tmpSeg,2)-stateFrames(i,1))) = ...
                    RMS(tmpI((tmpF+1):(segments(tmpSeg,2)-stateFrames(i,1))))<=threshs(segmInds(tmpSeg));
                tmpF = segments(tmpSeg,2)-stateFrames(i,1);
                tmpSeg = tmpSeg + 1;
            end
            if tmpF < stateFrames(i,2)
                tmpA(tmpF+1:end) = RMS(tmpI(tmpF+1:end))-threshs(segmInds(tmpSeg));
                tmpB(tmpF+1:end) = RMS(tmpI(tmpF+1:end))<=threshs(segmInds(tmpSeg));
            end
            density(i,1) = sum(tmpB)/length(tmpB);
            area(i,1) = abs(sum(tmpB.*tmpA));
            Nmax = 100;
            if stateFrames(i,2)>Lmin
                if Lmin>Nmax
                    W = Lmin-Nmax;
                    tmpB = tmpB(floor(W/2)+1:end-floor(W/2));
                end
                tmpA2 = zeros(1,length(tmpB)-Nmax+1);
                tmpB2 = zeros(1,length(tmpB)-Nmax+1);
                for j = 1:length(tmpB2)
                    tmpA2(j) = abs(sum(tmpA(j:j+Nmax-1).*tmpB(j:j+Nmax-1)));
                    tmpB2(j) = sum(tmpB(j:j+Nmax-1));
                end
                density(i,2) = max(tmpB2)/Nmax;
                area(i,2) = max(tmpA2);
            elseif ~isnan(density(i,2));
                density(i,2) = density(i,1);
                area(i,2) = area(i,1);
            end
        else
            density(i,:) = NaN; % REDUNDANCY
            area(i,:) = NaN; % REDUNDANCY
        end
    end
end

