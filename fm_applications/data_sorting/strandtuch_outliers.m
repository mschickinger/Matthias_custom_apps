outliers = cell(size(testRed2.intervals));
int_outliers = outliers;
for i = 1:length(testRed2.intervals)
    if ~isempty(testRed2.intervals{i})
        [~,~,outliers{i}] = deleteoutliers(testRed2.intervals{i}(:,2));
        int_outliers{i} = zeros(size(outliers{i}));
        for j = 1:length(outliers{i})
            int_outliers{i}(j) = testRed2.intervals{i}(testRed2.intervals{i}(:,2)==outliers{i}(j),1);
        end
    end
end