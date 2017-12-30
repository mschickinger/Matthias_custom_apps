function [frames, T] = imporTxt(filename)

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
delimiter = '\t';
formatSpec = '%s%*s%*s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
dataArray = horzcat(dataArray{1:2});
for i = 1:numel(dataArray)
	dataArray{i} = str2double(strrep(dataArray{i},',','.'));
end
% Make numeric array from cell array
dataArray = cell2mat(dataArray);
% remove all zero-valued lines
dataArray(dataArray(:,1)==0 | dataArray(:,2)==0, :) = [];


%% Allocate imported array to column variable names
frames = dataArray(:, 1);
T = dataArray(:, 2);

return