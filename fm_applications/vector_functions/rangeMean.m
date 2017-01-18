function rangeMean = rangeMean(arrayIn,ranges)

%TimeDim = 1;
%MeanDim = 2;
rangeMean = zeros(size(arrayIn,1),1);
divider = zeros(size(arrayIn,1),1);

for i = 1:size(ranges,1)
    rangeMean(ranges(i,1):ranges(i,2)) = rangeMean(ranges(i,1):ranges(i,2)) + arrayIn(ranges(i,1):ranges(i,2),i);
    divider(ranges(i,1):ranges(i,2)) = divider(ranges(i,1):ranges(i,2)) + 1;
end
rangeMean = rangeMean./divider;



return