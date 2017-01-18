function density = density_above( trace, threshold, B )
% Function that determines the density of entries with values above a
% certain threshold within a block of length B

L = length(trace);
above = trace>threshold;
density = zeros(L-B+1,1);
density(1) = sum(above(1:B));
for i = 1:L-B
    density(i+1) = density(i) - above(i) + above(i+B);
end
density = density/B;

end

