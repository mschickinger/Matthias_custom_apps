function [ deltaG ] = get_deltaG( seq )
T = 23;
NaCl = 0.5;
deltaG = zeros(size(seq,1),1);
for i = 1:length(deltaG)
    tmp = oligoprop(seq{i},'Temp',T,'Salt',NaCl);
    deltaG(i) = tmp.Thermo(3,3);
end
end

