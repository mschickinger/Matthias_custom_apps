function [ segments, segments_idx ] = iSegments( trace , thr )

    thr = sort(thr);
    lasts = zeros(length(thr),1);
    segments_idx = zeros(length(thr),1);
    for i = 1:length(thr)
        tmp = find(trace>=thr(i),1,'last');
        if ~isempty(tmp)
            lasts(i) = tmp;
            segments_idx(i) = i;
        end
    end
    lasts = unique(nonzeros(lasts));
    segments_idx = nonzeros(segments_idx);
    if ~isempty(lasts)
        firsts = [1; lasts(1:end-1)+1];
        segments = [firsts lasts];
    else
        segments = [];
    end

end

