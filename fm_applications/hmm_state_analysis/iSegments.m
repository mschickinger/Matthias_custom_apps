function [ segments, segments_idx ] = iSegments( trace , thr )

    thr = sort(thr,'descend');
    lasts = zeros(length(thr),1);
    segments_idx = zeros(length(thr),1);
    for i = 1:length(thr)
        tmp = find(trace>=thr(i),1,'last');
        if ~isempty(tmp)
            lasts(i) = tmp;
            segments_idx(i) = i;
        end
    end
    [lasts, tmpI] = unique(nonzeros(lasts));
    segments_idx = nonzeros(segments_idx);
    segments_idx = segments_idx(tmpI);
    if ~isempty(lasts)
        firsts = [1; lasts(1:end-1)+1];
        segments = [firsts lasts];
    else
        segments = [];
    end
    
    minLEN = 1000;
    if ~isempty(segments)
        LEN = segments(:,2) - segments(:,1) + 1;
        while any(LEN<100)
            while LEN(1)<minLEN
                segments(1,:) = [];
                segments_idx(1) = [];
                segments(1,1) = 1;
                LEN = segments(:,2) - segments(:,1) + 1;              
            end
            i = 1;
            while i <length(LEN)
                i = i+1;
                if LEN(i)<minLEN
                    segments(i-1,2) = segments(i,2);
                    segments(i,:) = [];
                    segments_idx(i) = [];
                    LEN = segments(:,2) - segments(:,1) + 1;
                    i = i-1;
                end
            end
        end
    end

end

