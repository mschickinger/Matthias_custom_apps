maxI = [];
minI = [];
for i = 1:length(arxv)
    if ~isempty(arxv{i}.segments)
        offset = arxv{i}.segments(1) - 1;
        for j = 1:size(arxv{i}.segments,1)
            maxI = [maxI max(medI{i}((arxv{i}.segments(j,1):arxv{i}.segments(j,2)) - offset))];
            minI = [minI min(medI{i}((arxv{i}.segments(j,1):arxv{i}.segments(j,2)) - offset))];
        end
        maxI = [maxI max(medI{i}((arxv{i}.segments(end)+1-offset):end))];
        minI = [minI min(medI{i}((arxv{i}.segments(end)+1-offset):end))];
    end        
end

%%
figure('Units', 'normalized', 'Position', [0 0 1 1])
subplot(1,2,1)
histogram(maxI,6000:50:12000)
subplot(1,2,2)
histogram(minI,5500:50:7500)
