function [step_pos, delta, chi2] = find_mps(vector, varargin)

    % parse input
    p = inputParser;
    addRequired(p, 'vector', @isnumeric);
    addParameter(p, 'plot', false, @islogical);

    parse(p, vector, varargin{:});
    
    max_frame = length(vector);

    chi2 = zeros(1,max_frame);
    chi2(1) = sum((vector-mean(vector)).^2);
    chi2(end) = chi2(1);

    for i = 2:max_frame-1
        chi2(i) = sum((vector(1:i-1)-mean(vector(1:i-1))).^2) + sum((vector(i:max_frame)-mean(vector(i:max_frame))).^2);
    end

    [chi2_min, step_pos] = min(chi2);
    delta = max(vector(max(step_pos-5,1):min(step_pos+4,length(vector))))-min(vector(max(step_pos-5,1):min(step_pos+4,length(vector))));
    
    if p.Results.plot
        if strcmp(questdlg('Close all open figures?', 'Close all?', 'Yes'), 'Yes')
            close all
        end
        figure('Units', 'normalized', 'Position', [0 .5 1 .5])
        subplot(2,1,1)
        plot(vector)
        hold on
        plot(step_pos*[1 1], [0 1.5], '')
        subplot(2,1,2)
        plot(chi2)
        hold on
        plot(step_pos, chi2_min, 'o')
    end
end