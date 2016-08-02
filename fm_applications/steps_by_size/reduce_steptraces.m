function [steps, steptraces, ex_int, arxv, GO_ON, ex_global] = reduce_steptraces(primary_trace, secondary_trace, ex_int, varargin)

    % parse input
    p = inputParser;
    
    addRequired(p, 'primary_trace', @isnumeric)
    addRequired(p, 'secondary_trace', @isnumeric)
    addRequired(p, 'ex_int')
    addOptional(p, 'L', [], @isnumeric)
    addOptional(p, 'N', 20, @isnumeric)
    addParameter(p, 'steps_init', [], @isnumeric)
    addParameter(p, 'thresh_init', 0.1, @isnumeric)
    addParameter(p, 'movie', [], @isnumeric)
    addParameter(p, 'spot', [], @isnumeric)
    
    parse(p, primary_trace, secondary_trace, ex_int, varargin{:})
    N = p.Results.N;
    
    % set all variables
    GO_ON = 1;
    st_col = 'k';% [0 .5 .6];
    ax = cell(1,2);
    L = 0;
    next_thresh = 0;
    YLIM = [0 3.5];
    thresh_incr = 0;
    thresh_base = 0;
    thresh_exp = 0;
    LEX = zeros(0,2);
    str = {};
    
    close all
    f = figure('Visible', 'on', 'Units', 'normalized', 'Position', [0 0 1 1]);
    
    f_startup
    reset_figure
    
    % create interface (later)
          
    actionlist = {'Reduce further'; 'One step back'; 'Proceed to next'; 'Finer >'; '< Coarser'; ...
        'Exclude'; 'Re-include'; 'Exclude in movie'; 'Discard'; 'Postpone'};
    bg = uibuttongroup('Position', [.1 .15 .8 .15], 'Visible', 'off');

    a1 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.02 .55 .08 .3],...
        'String', actionlist{1}, 'Callback', @reduce, 'FontSize', 10);

    a2 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.12 .55 .08 .3],...
        'String', actionlist{2}, 'Callback', @go_back, 'FontSize', 10);

    a3 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.86 .55 .12 .3],...
        'String', actionlist{3}, 'Callback', @done, 'FontSize', 10);
    
    a4 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.22 .55 .08 .3],...
         'String', actionlist{4}, 'Callback', @finer, 'FontSize', 10);
     
    a5 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.42 .55 .08 .3],...
         'String', actionlist{5}, 'Callback', @coarser, 'FontSize', 10);
     
<<<<<<< HEAD
    a6 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.66 .55 .08 .3],...
         'String', actionlist{6}, 'Callback', @exclude, 'FontSize', 10);
    
    a7 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.76 .55 .08 .3], ...
        'String', actionlist{7}, 'Callback', @reinclude, 'FontSize', 10);
    
    a8 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.86 .15 .12 .3],...
        'String', actionlist{8}, 'Callback', @abort, 'FontSize', 10);
    
    at = uicontrol(bg, 'Style', 'Text','Units', 'normalized', 'Position', [.32 .2 .08 .6], 'String', ...
        ['Threshold for first reduction: ' num2str(arxv.threshs(1))], 'FontSize', 10);
=======
    a6 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.52 .55 .08 .3],...
         'String', actionlist{6}, 'Callback', @exclude, 'FontSize', 10);
    
    a7 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.62 .55 .08 .3], ...
        'String', actionlist{7}, 'Callback', @reinclude, 'FontSize', 10);
    
    a8 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.52 .15 .08 .3],...
         'String', actionlist{8}, 'Callback', @exclude_global, 'FontSize', 10);
     
    a9 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.76 .55 .08 .3],...
         'String', actionlist{9}, 'Callback', @discard, 'FontSize', 10);
    
    a10 = uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.76 .15 .08 .3],...
         'String', actionlist{10}, 'Callback', @postpone, 'FontSize', 10);
    
    % abort button
    uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.86 .15 .12 .3],...
        'String', 'Abort and save', 'Callback', @abort, 'FontSize', 10);
    
    % reset button
    uicontrol(bg, 'Style', 'Pushbutton','Units', 'normalized', 'Position', [.02 .15 .08 .3],...
        'String', 'Reset', 'Callback', @reset, 'FontSize', 10);
    
    at = uicontrol(bg, 'Style', 'Text','Units', 'normalized', 'Position', [.32 .45 .08 .3], 'String', ...
        ['Threshold for first reduction: ' num2str(arxv.threshs(1))], 'FontSize', 10);
    
>>>>>>> origin/Dominik
    set(bg, 'Visible', 'on')
    
    % set max frame?
    set_max
    % plot the first steptrace:
    first_steptrace
 
    i=1;
    go_on = 1;
    while go_on
        uiwait(gcf)
    end
    
    function f_startup
        primary_trace = p.Results.primary_trace;
        % threshold progression:
        arxv.threshs = zeros(N,1);
        thresh_base = 10;
        thresh_exp = -1;
        thresh_incr = thresh_base^thresh_exp;
        arxv.threshs(1) = p.Results.thresh_init;
        next_thresh = arxv.threshs(1) + thresh_incr;
        % Inputs:
        if isempty(p.Results.ex_int)
            ex_int = zeros(0,2);
        else
            ex_int = p.Results.ex_int;
        end
        LEX = size(ex_int,1);
        ex_global = zeros(0,2);
        if ~isempty(p.Results.L)
            L = p.Results.L;
        else
            L = length(primary_trace);
        end
        steps = cell(N,1);
        steptraces = cell(N,1);
        arxv.max_frame = L;
    end

    function reset_figure
        figure(f)
        subplot('Position',[0.05 0.55 .9 .4])
        hold off
        plot(primary_trace, 'Color', .7*[1 1 1])
        hold on
        ax{1} = gca;
        for k = 1:size(ex_int,1)
            sh = area(ex_int(k,:), YLIM(2)*[1 1], 'FaceColor', [.95 0.1 0.1], 'EdgeColor', [1 0.15 0.15], 'FaceAlpha', .4);
            uistack(sh, 'bottom')
        end
        set(ax{1}, 'Xlim', [0 L], 'Ylim', YLIM)
        title(['Movie ' num2str(p.Results.movie) ', spot ' num2str(p.Results.spot)], 'Fontsize', 14)
    
        subplot('Position',[0.05 0.35 .9 .15])
        plot(p.Results.secondary_trace, 'Color', [.2 .3 .2])
        ax{2} = gca;
        set(ax{2}, 'Xlim', [0 L], 'Ylim', [0 2])
        title('RMSD trace of green spot', 'Fontsize', 14)
        
        subplot(ax{1})
    end

    function set_max
        if strcmp(questdlg('Set maximum frame?', 'Max frame?', 'No'), 'Yes');
            h = impoint(ax{1});
            max_frame = wait(h);
            arxv.max_frame = round(max_frame(1));
            delete(h)
            % re-define L and trace
            L = arxv.max_frame;
            set(ax{1}, 'Xlim', [0 L], 'Ylim', YLIM)
            set(ax{2}, 'Xlim', [0 L])
            primary_trace = primary_trace(1:L);
        end
    end

    function first_steptrace
        if isempty(p.Results.steps_init)
            steps_init = 3:2:L-1;
        else
            steps_init = p.Results.steps_init(p.Results.steps_init<L);
        end
        disp(length(steps_init))
        disp(arxv.threshs(1))
        steps{1} = rm_steps_to_hmin(primary_trace,steps_init,arxv.threshs(1));
        steps{1} = eliminate_stairs(primary_trace,steps{1});
        display(sprintf(['Eliminated stairs.\nNumber of steps remaining: ' num2str(length(steps{1}))]))
        [ ~,steptraces{1}] = get_levels(primary_trace,steps{1});
        hold on
        str = plot(steptraces{1}, 'Color', st_col);
        update_thresh(1)
    end

    function reduce(source, callbackdata)
        i = i+1;
        weiter = 1;
        while weiter && length(steps{i-1})>2
            steps{i} = rm_steps_to_hmin(primary_trace,steps{i-1},next_thresh);
            steps{i} = eliminate_stairs(primary_trace,steps{i});
            display(sprintf(['Eliminated stairs.\nNumber of steps remaining: ' num2str(length(steps{i}))]))
            weiter = length(steps{i})==length(steps{i-1});
            if ~weiter
                [ ~ ... %levels{1}
                ,steptraces{i}] = get_levels(primary_trace,steps{i});
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
        hex = imrect(gca,[L/2 YLIM(1)+.25*(YLIM(2)-YLIM(1)) L/10 .5*(YLIM(2)-YLIM(1))]);
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
        if size(ex_int,1)>LEX
            if size(ex_global,1)>0
                if ex_int(end,:)==ex_global(end,:)
                    ex_global(end,:) = [];
                end
            end
            ex_int(end,:) = [];
            kidz = get(ax{1}, 'children');
            if strcmp(kidz(end).Type,'area')
                delete(kidz(end))
            end
        end
        uiresume(gcbf);
    end

    function exclude_global(source, callbackdata)
        gex = imrect(gca,[L/2 YLIM(1)+.25*(YLIM(2)-YLIM(1)) L/10 .5*(YLIM(2)-YLIM(1))]);
        setResizable(gex, true);
        gexpos = round(wait(gex));
        if sum(gexpos)>0
            ex_int = [ex_int; gexpos(1) gexpos(1)+gexpos(3)];
            ex_global = [ex_global; ex_int(end,:)];
            sh = area(gexpos(1)+[0 gexpos(3)], YLIM(2)*[1 1], 'FaceColor', [.95 0.1 0.1], 'EdgeColor', [1 0.15 0.15], 'FaceAlpha', .4);
            uistack(sh, 'bottom')
            ylim(YLIM)
        end
        delete(gex)
        uiresume(gcbf);
    end

    function discard(source,callbackdata)
        if strcmp(questdlg('Are you sure you want to discard this spot?', 'Really discard?'),'Yes')
            arxv.why_discarded = inputdlg('Enter reason for discarding this spot:', 'Why discarded?', 1, {'SNR'});
            if isempty(arxv.why_discarded)
                arxv = rmfield(arxv, 'why_discarded');
                uiresume(gcbf)
            else
                i = 0;
                ex_int = [];
                ex_global = [];
                done
            end
        else
            uiresume(gcbf)
        end
    end

    function postpone(source,callbackdata)
        arxv.why_postponed = inputdlg('Enter reason for postponing this spot:', 'Why postponed?', 1, {'SNR'});
        if isempty(arxv.why_postponed)
            arxv = rmfield(arxv, 'why_postponed');
            uiresume(gcbf)
        else
            GO_ON = 2;
            done
        end
        uiresume(gcbf)
    end

    function update_plot(index)
        delete(str)
        str = plot(steptraces{index}, 'Color', st_col);
    end

    function update_thresh(vz)
        next_thresh = next_thresh - thresh_incr;
        thresh_incr = thresh_base^thresh_exp;
        next_thresh = next_thresh + vz*thresh_incr;
        at.String = ['Threshold for next reduction: ' num2str(next_thresh)];
    end
        
    function reset(source,callbackdata)
        kidz = get(ax{1}, 'children');
        delete(kidz)
        f_startup
        update_thresh(1)
        reset_figure
        set_max
        first_steptrace
        i = 1;
        uiresume(gcbf)
    end

    function done(source, callbackdata)
        go_on = 0;
        kidz = get(ax{1}, 'children');
        delete(kidz)
        uiresume(gcbf)
        steps = steps(1:i);
        arxv.threshs = arxv.threshs(1:i);
        steptraces = steptraces(1:i);
    end

    function abort(source, callbackdata)
        done;
        GO_ON = 0;
        display('You should see a save dialog box now.')
        close(f)
    end
end