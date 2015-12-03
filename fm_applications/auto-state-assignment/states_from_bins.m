function [ states ] = states_from_bins( assignment, pos_RMSD, behaviour )
%STATES_FROM_BINS Transfer state assignment from intensity binned data to
%spotwise time traces
%   Detailed explanation goes here

states = cell(size(pos_RMSD,1),1);
for s = find(behaviour == 2)'
    states{s} = zeros(size(pos_RMSD{s},1),1);
end

for i = 14:72
    for s = unique(assignment{i}(:,1))'
        %indices = assignment{i}(assignment{i}(:,1)==s,2);
        states{s}(assignment{i}(assignment{i}(:,1)==s,2)) = assignment{i}(assignment{i}(:,1)==s,3);
    end
end

end

