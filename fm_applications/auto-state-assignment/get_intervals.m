function [ boundaries, interval_plots ] = get_intervals( traces, ax, varargin )
%GET_INTERVALS lets the user pick N intervals from a time trace
    % INPUT
    % traces: handle to figure with time trace plots
    % ax: handle to axis of subplot from which intervals are picked
    
    % OUTPUT
    % boundaries: Nx2 matrix with lower and upper interval boundaries  
    % interval_plots: cell array with handles to rectangles depicting
    %                 picked intervals
    
    % set parameters
    N = 20;
    boundaries = zeros(N,2);
    interval_plots = cell(N,1);

    figure(traces)
    YLIM = get(ax, 'YLim');

    %Create done button
    add_button = uicontrol('Style', 'pushbutton', 'String', 'Add',...
        'Units', 'normalized', 'Position', [.05 .925 .15 .05],... %location, values based on plot_time_traces
        'Callback', @add); 

    %Create undo button
    undo_button = uicontrol('Style', 'pushbutton', 'String', 'Undo',...
        'Units', 'normalized', 'Position', [.425 .925 .15 .05],... %location, values based on plot_time_traces
        'Callback', @undo); 

    %Create done button
    done_button = uicontrol('Style', 'pushbutton', 'String', 'Done',...
        'Units', 'normalized', 'Position', [.8 .925 .15 .05],... %location, values based on plot_time_traces
        'Callback', @done); 


    pick = 1;
    n = 1;
    while pick
        uiwait(traces)
    end
    close(traces)
    boundaries = boundaries(boundaries(:,1)>0,:);

        function add(source, callbackdata)
            uiresume(traces)
            h = imrect(ax);
            pos = wait(h);
            pos = round(pos);
            switch n<=N
                case true
                    boundaries(n,:) = [max([2 pos(1)]) pos(3)]; % Mininum value 2 to avoid indexing error for delta_pos calculation
                case false
                    boundaries = [boundaries; [max([2 pos(1)]) pos(3)]];
            end
            delete(h)
            interval_plots{n} = rectangle('Position', [pos(1) YLIM(1)+.1 pos(3) YLIM(2)-.2], 'EdgeColor', 'b', 'LineWidth', 2);
            n = n+1;
        end

        function undo(source, callbackdata)
            if n>1
                n = n-1;
                boundaries(n,:) = zeros(1,2);
                interval_plots{n}.delete;
            end
            uiresume(traces)
        end

        function done(source, callbackdata)
            pick = 0;
            uiresume(traces)
        end

end
