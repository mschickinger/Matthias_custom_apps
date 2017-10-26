function [ dG ] = deltaG( dHdS , T )
%INPUT
%dHdS: column 1 are dH values in kcal/mol, column 2 are dS values in cal/(mol*K)
% T: temperature in Celsius

%OUTPUT
% dG: deltaG0 in kcal/mol

    dG = dHdS(:,1) - (273.15+T).*dHdS(:,2)./1000;

end

