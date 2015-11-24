function [ clabels ] = custom_labels( n_labels, defaults )
% Opens inputdialog for entering custom tick labels (for one axis)

cLabels = cell(n_labels,1);
for i = 1:n_labels
    clabels{i} = ['Label ' num2str(i)];
    defaults{i} = num2str(i);
end

if ~exist('defaults', 'var')
    defaults = cell(n_labels,1);
    for i = 1:n_labels
        defaults{i} = num2str(i);
    end
end

clabels = inputdlg(clabels, 'Enter labels', 1, defaults);

end

