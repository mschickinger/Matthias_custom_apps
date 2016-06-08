function [ Tmatrix ] = import_dG( path, dG_cell_name )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[~, ~, dG_cell] = xlsread( ...
    [path filesep dG_cell_name '.xlsx'],'Sheet1');
dG_cell(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),dG_cell)) = {''};

Tmatrix = zeros(size(dG_cell));
for i = 1:size(Tmatrix,1)
    for j = 1:size(Tmatrix,2)
        Tmatrix(i,j) = str2double(dG_cell{i,j}(6:end-(j==4)*2));
    end
end



end

