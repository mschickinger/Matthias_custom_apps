function NnonNaN = get_NnonNaN(stateFrames, discard)
    NnonNaN = zeros(2,1);
    for k = 1:2
        for isp = setdiff(1:size(stateFrames,1),discard)
            if ~isempty(stateFrames{isp,k})
                NnonNaN(k) = NnonNaN(k) + sum(~isnan(stateFrames{isp,k}(:,1)));
            end
        end
    end
end

