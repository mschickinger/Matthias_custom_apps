function [ segments ] = iSegments( trace , thr )

    thr = sort(thr);
    lasts = zeros(length(thr),1);
    for i = 1:length(thr)
        tmp = find(trace>=thr(i),1,'last');
        if ~isempty(tmp)
            lasts(i) = tmp;
        end
    end
    lasts = unique(nonzeros(lasts));
    if ~isempty(lasts)
        firsts = [1; lasts(1:end-1)+1];
        segments = [firsts lasts];
    else
        segments = [];
    end

end

