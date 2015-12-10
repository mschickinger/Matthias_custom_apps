function [ boundaries, interval_plots ] = get_intervals( traces, ax, varargin )
%GET_INTERVALS lets the user pick N intervals from a time trace
    % INPUT
    % traces: handle to figure with time trace plots
    % ax: handle to axis of subplot from which intervals are picked
    
    % OUTPUT
    % boundaries: Nx2 matrix with lower and upper interval boundaries  
    % interval_plots: cell array with handles to rectangles depicting
    %                 picked intervals
    
    % parse input
    p = inputParser;
    
    addRequired(p, 'traces', @ishandle)
    addRequired(p, 'ax', @ishandle)
    addOptional(p, 'N', 20, @isnumeric)
    
    parse(p, traces, ax, varargin{:})
    
    % set parameters
    N = p.Results.N;
    boundaries = zeros(N,2);
    interval_plots = cell(N,1);

    figure(traces)
    XLIM = get(ax, 'XLim');
    YLIM = get(ax, 'YLim');

    add_button = uicontrol('Style', 'pushbutton', 'String', 'Add',...
        'Units', 'normalized', 'Position', [.05 .925 .15 .05],... %location, values based on plot_time_traces
        'Callback', @add); 

    %Create undo button
    undo_button = uicontrol('Style', 'pushbutton', 'String', 'Undo',...
        'Units', 'normalized', 'Position', [.6 .925 .15 .05],... %location, values based on plot_time_traces
        'Callback', @undo); 

    %Create "next" button
    next_button = uicontrol('Style', 'pushbutton', 'String', 'Next',...
        'Units', 'normalized', 'Position', [.775 .925 .15 .05],... %location, values based on plot_time_traces
        'Callback', @next); 


    pick = 1;
    n = 1;
    while pick && n<=N
        uiwait(traces)
    end
    boundaries = boundaries(boundaries(:,1)>0,:);

        function add(source, callbackdata)
            uiresume(traces)
            h = imrect(ax);
            pos = wait(h);
            pos = round(pos);
            if pos(1)<2
                pos(3) = pos(3)+pos(1)-2; 
                pos(1) = 2; % Mininum value 2 to avoid indexing error for delta_pos calculation
            end
            pos(3) = min([XLIM(2)-pos(1)-1 pos(3)]); % Maximum value second to last to avoid indexing error for (forward) delta_pos calculation
            switch n<=N
                case true
                    boundaries(n,:) = [pos(1) pos(3)]; 
                case false
                    boundaries = [boundaries; [pos(1) pos(3)]];
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

        function next(source, callbackdata)
            pick = 0;
            uiresume(traces)
        end

end
