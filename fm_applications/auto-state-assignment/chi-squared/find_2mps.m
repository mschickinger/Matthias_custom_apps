function [step_pos, delta, chi2] = find_2mps(vector, varargin)

    % parse input
    p = inputParser;
    addRequired(p, 'vector', @isnumeric);
    addParameter(p, 'plot', false, @islogical);

    parse(p, vector, varargin{:});
    
    max_frame = length(vector);
    w = 5;
    
    tmp_chi2([1:w max_frame-w+1:max_frame]) = sum((vector-mean(vector)).^2);
    delta = zeros(2,1);
    chi2 = zeros(2,max_frame);
    
    %{
for i = 2:max_frame-1
        for j=i+1:max_frame
            tmp = sum((vector(1:i-1)-mean(vector(1:i-1))).^2) + ...
                    sum((vector(i:j-1)-mean(vector(i:j-1))).^2) + ...
                    sum((vector(j:max_frame)-mean(vector(j:max_frame))).^2);
            if  tmp < tmp_chi2
                tmp_chi2 = tmp;
                step_pos = [i;j];
            end
        end
    end
%}
    
    for i = w+1:max_frame-w
        tmp_chi2(i) = sum((vector(1:i-w-1)-mean(vector(1:i-w-1))).^2) + ...
                    sum((vector(i-w:i+w-1)-mean(vector(i-w:i+w-1))).^2) + ...
                    sum((vector(i+w:max_frame)-mean(vector(i+w:max_frame))).^2);
    end
    
    [chi2_min,tmp] = min(tmp_chi2);
    step_pos = [-w;w] + tmp;
    
    go_on = 1;
    N = 10;
    n = 1;
    while go_on && n <= N
        for i = 1:max_frame
            chi2(1,i) = get_chi2(vector, [i step_pos(2)]);
        end
        [~, step_pos(1)] = min(chi2(1,:));
        for i = 1:max_frame
            chi2(2,i) = get_chi2(vector, [step_pos(1) i]);
        end
        [tmp, step_pos(2)] = min(chi2(2,:));
        go_on = tmp<chi2_min;
        chi2_min = tmp;
        n = n+1;
    end
    
    delta(1) = max(vector(max(step_pos(1)-5,1):min(step_pos(1)+4,length(vector))))-min(vector(max(step_pos(1)-5,1):min(step_pos(1)+4,length(vector))));
    delta(2) = max(vector(max(step_pos(2)-5,1):min(step_pos(2)+4,length(vector))))-min(vector(max(step_pos(2)-5,1):min(step_pos(2)+4,length(vector))));

    chi2_min = min(chi2,[],2);
    
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