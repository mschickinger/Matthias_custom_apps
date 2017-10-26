function [ Z ] = ZsumPairHP( dHdSp, T )

% OUTPUT: total partition function of a system of two DNA strands that can form
% hairpins.
% INPUT: 
% dHdSp is a 1x2 cell array containing dH and dS values associated with
% the secondary structures. Ground state (dG = 0) needs to be added.
% T is the temperature in Celsius.

kBT = 1.38064852e-23 * 6.022e23 / 4.1868 / 1000 * (T+273.15);
for i = 2:-1:1
    if ~isempty(dHdSp{i})
        dGp{i} = [0;deltaG(dHdSp{i},T)];
    else
        dGp{i} = 0;
    end
end
dGall = zeros(numel(dGp{1}),numel(dGp{2}));
for i = 1:size(dGall,1)
    for j = 1:size(dGall,2)
        dGall(i,j) = dGp{1}(i) + dGp{2}(j);
    end
end
Z = sum(exp(-dGall(:)./kBT));

end

