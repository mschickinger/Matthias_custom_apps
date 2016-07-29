function [steps, ex_int, arxv, GO_ON] = reduce_steptraces(trace, varargin)

    % parse input
    p = inputParser;
    
    addRequired(p, 'trace', @isnumeric)
    addOptional(p, 'L', [], @isnumeric)
    addOptional(p, 'N', 20, @isnumeric)
    addParameter(p, 'steps_init', [], @isnumeric)
    addParameter(p, 'thresh_init', 0.1, @isnumeric)
    addParameter(p, 'movie', [], @isnumeric)
    addParameter(p, 'spot', [], @isnumeric)
    %addParameter(p, 'MW', 'mean', @isstring)
    
    parse(p, trace, varargin{:})
    
    trace = p.Results.trace;
    if ~isempty(p.Results.L)
        L = p.Results.L;
    else
        L = length(trace);
    end
    N = p.Results.N;
    
    % set variables and parameters
    steps = cell(N,1);
    steptrace = cell(N,1);
    arxv.threshs = zeros(N,1);
    ex_int = zeros(0,2);
    GO_ON = 1;
    st_col = 'k';% [0 .5 .6];
      
    % threshold progression:
    thresh_base = 10;
    thresh_exp = -1;
    thresh_incr = thresh_base^thresh_exp;
    arxv.threshs(1) = p.Results.thresh_init;
    next_thresh = arxv.threshs(1) + thresh_incr;
    
    % create figure and user interface (later)
    close all
    f = figure('Visible', 'on', 'Units', 'normalized', 'Position', [0 0 1 1]);
    subplot('Position',[0.05 0.35 .9 .6])
    hold off
    plot(trace, 'Color', .7*[1 1 1])
    ax = gca;
    set(ax, 'Xlim', [0 L])
    YLIM = ylim;
    title(['Movie ' num2str(p.Results.movie) ', spot ' num2str(p.Results.spot)], 'Fontsize', 18)
          
    actionlist = {'Reduce further'; 'One step back'; 'Proceed to next'; 'Finer >'; '< Coarser'; ...
        'Exclude'; 'Re-include'; 'Abort and save'};
    bg = uibuttongroup('Position', [.1 .15 .8 .15], 'Visible', 'off');

    a1 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.02 .55 .08 .3],...
        'String', actionlist{1}, 'Callback', @reduce, 'FontSize', 14);

    a2 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.12 .55 .08 .3],...
        'String', actionlist{2}, 'Callback', @go_back, 'FontSize', 14);

    a3 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.86 .55 .12 .3],...
        'String', actionlist{3}, 'Callback', @done, 'FontSize', 14);
    
    a4 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.22 .55 .08 .3],...
         'String', actionlist{4}, 'Callback', @finer, 'FontSize', 14);
     
    a5 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.42 .55 .08 .3],...
         'String', actionlist{5}, 'Callback', @coarser, 'FontSize', 14);
     
    a6 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.66 .55 .08 .3],...
         'String', actionlist{6}, 'Callback', @exclude, 'FontSize', 14);
    
    a7 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.76 .55 .08 .3], ...
        'String', actionlist{7}, 'Callback', @reinclude, 'FontSize', 14);
    
    a8 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.86 .15 .12 .3],...
        'String', actionlist{8}, 'Callback', @abort, 'FontSize', 14);
    
    at = uicontrol(bg, 'Style', 'Text','Units', 'normalized', 'Position', [.32 .45 .08 .3], 'String', ...
        ['Threshold for first reduction: ' num2str(arxv.threshs(1))], 'FontSize', 14);
    set(bg, 'Visible', 'on')
    
    % set max frame?
    set_max_frame = strcmp(questdlg('Set maximum frame?', 'Max frame?', 'No'), 'Yes');
    if set_max_frame
        h = impoint(ax);
        max_frame = wait(h);
        arxv.max_frame = round(max_frame(1));
        delete(h)
        % re-define L
        L = arxv.max_frame;
        set(ax, 'Xlim', [0 L])
    end
    
    if isempty(p.Results.steps_init)
        steps_init = 3:2:L-1;
    else
        steps_init = p.Results.steps_init(p.Results.steps_init<L);
    end
    
    % first steptrace
    steps{1} = rm_steps_to_hmin(trace,steps_init,arxv.threshs(1));
    [ ~ ... %levels{1}
        ,steptrace{1}] = get_levels(trace,steps{1});
    hold on
    str = plot(steptrace{1}, 'Color', st_col);
    update_thresh(1)
    
    i=1;
    go_on = 1;
    while go_on
        uiwait(gcf)
    end
       
    function reduce(source, callbackdata)
        i = i+1;
        weiter = 1;
        while weiter && length(steps{i-1})>2
            steps{i} = rm_steps_to_hmin(trace,steps{i-1},next_thresh);
            weiter = length(steps{i})==length(steps{i-1});
            if ~weiter
                [ ~ ... %levels{1}
                ,steptrace{i}] = get_levels(trace,steps{i});
                update_plot(i)
                arxv.threshs(i) = next_thresh;
            end
            update_thresh(2)
        end
        uiresume(gcbf)
    end

    function go_back(source, callbackdata)
        if i>1;
            i = i-1;
            next_thresh = arxv.threshs(i);
            update_plot(i)
            update_thresh(2)
        end
    end

    function finer(source, callbackdata)       
        thresh_exp = thresh_exp - 1;
        update_thresh(1)
        uiresume(gcbf)
    end
    function coarser(source, callbackdata)
        thresh_exp = thresh_exp + 1;
        update_thresh(1)
        uiresume(gcbf)
    end

    function exclude(source, callbackdata)
        if ~exist('ex_int','var')
            ex_int = zeros(0,2);
        end
        hex = imrect(gca,[L/2 YLIM(1)+.2*(YLIM(2)-YLIM(1)) L/10 .6*(YLIM(2)-YLIM(1))]);
        setResizable(hex, true);
        hexpos = round(wait(hex));
        if sum(hexpos)>0
            ex_int = [ex_int; hexpos(1) hexpos(1)+hexpos(3)];
            sh = area(hexpos(1)+[0 hexpos(3)], YLIM(2)*[1 1], 'FaceColor', [.95 0.1 0.1], 'EdgeColor', [1 0.15 0.15], 'FaceAlpha', .4);
            uistack(sh, 'bottom')
            ylim(YLIM)
        end
        delete(hex)
    end

    function reinclude(source, callbackdata)
        if exist('ex_int', 'var')
            ex_int(end,:) = [];
            kidz = get(ax, 'children');
            if strcmp(kidz(end).Type,'area')
                delete(kidz(end))
            end
        end
        uiresume(gcbf);
    end

    function update_plot(index)
        delete(str)
        str = plot(steptrace{index}, 'Color', st_col);
    end

    function update_thresh(vz)
        next_thresh = next_thresh - thresh_incr;
        thresh_incr = thresh_base^thresh_exp;
        next_thresh = next_thresh + vz*thresh_incr;
        at.String = ['Threshold for next reduction: ' num2str(next_thresh)];
    end

    function done(source, callbackdata)
        go_on = 0;
        kidz = get(ax, 'children');
        delete(kidz)
        uiresume(gcbf)
        steps = steps(1:i);
        arxv.threshs = arxv.threshs(1:i);
        steptrace = steptrace(1:i);
    end

    function abort(source, callbackdata)
        done;
        GO_ON = 0;
        display('You should see a save dialog box now.')
        close(f)
    end
end