function [step_pos, delta, chi2] = find_2mps(vector, varargin)

    % parse input
    p = inputParser;
    addRequired(p, 'vector', @isnumeric);
    addParameter(p, 'plot', false, @islogical);

    parse(p, vector, varargin{:});
    
    max_frame = length(vector);

    chi2 = zeros(2,max_frame);
    chi2(1,1) = sum((vector-mean(vector)).^2);
    chi2(1,end) = chi2(1,1);

    for i = 2:max_frame-1
        chi2(1,i) = sum((vector(1:i-1)-mean(vector(1:i-1))).^2) + sum((vector(i:max_frame)-mean(vector(i:max_frame))).^2);
    end
    
    chi2_min = zeros(2,1);
    step_pos = zeros(2,1);
    delta = zeros(2,1);

    [chi2_min(1), step_pos(1)] = min(chi2(1,:));
    delta(1) = max(vector(max(step_pos(1)-5,1):min(step_pos(1)+4,length(vector))))-min(vector(max(step_pos(1)-5,1):min(step_pos(1)+4,length(vector))));
    
    for i = 1:max_frame
        chi2(2,i) = get_chi2(vector, [step_pos(1) i]);
    end
    
    [chi2_min(2), step_pos(2)] = min(chi2(2,:));
    delta(2) = max(vector(max(step_pos(2)-5,1):min(step_pos(2)+4,length(vector))))-min(vector(max(step_pos(2)-5,1):min(step_pos(2)+4,length(vector))));
    
    if p.Results.plot
        if strcmp(questdlg('Close all open figures?', 'Close all?', 'Yes'), 'Yes')
            close all
        end
        figure('Units', 'normalized', 'Position', [0 .5 1 .5])
        subplot(5,1,1)
        plot(vector)
        hold on
        for i = 1:2
            plot(step_pos(i)*[1 1], [0 1.5], '')
        end
        xlim([0 max_frame])
        for i = 1:2
            subplot(5,1,i+1)
            plot(chi2(i,:))
            hold on
            plot(step_pos(i), chi2_min(i), 'o')
            xlim([0 max_frame])
            subplot(5,1,i+3)
            plot(chi2(i,2:end)-chi2(i,1:end-1))
            xlim([0 max_frame])
        end
    end
end