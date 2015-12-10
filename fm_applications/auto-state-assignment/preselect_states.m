function [ states ] = preselect_states(movie_data, behaviour, varargin)
    %PRESELECT_STATES
    % Detailed explanation goes here

    %% parse input
    p = inputParser;
    
    addRequired(p, 'movie_data', @iscell);
    addRequired(p, 'behaviour', @isvector);
    addOptional(p, 'previous_states', [], @isstruct);
    
    parse(p, movie_data, behaviour, varargin{:});
    
    %% set parameters
    spots = find(behaviour==2);
    
    if ~isempty(p.Results.previous_states)
        states = p.Results.previous_states;
        i = find(states.spotnums==0, 1);
        while isempty(states.unbound{i}) && isempty(states.bound{i}) && i>1
            i = i-1;
        end
    else
        states.spotnums = zeros(size(spots));
        states.unbound = cell(size(spots));
        states.bound = cell(size(spots));
        i = 1;
    end
    
    state_colors = {'c','b'};
    
    %% collect intervals, assign states and write to output
    go_on = 1;
    refresh = 1;
    while go_on
        if refresh
            [traces, primary_ax] = plot_time_traces(movie_data(spots(i),:));
            figure(traces)
            subplot(primary_ax)
            plot(states.bound{i}, movie_data{spots(i),1}.vwcm.rms10(states.bound{i}), 'c.', 'MarkerSize', 5);
            plot(states.unbound{i}, movie_data{spots(i),1}.vwcm.rms10(states.unbound{i}), 'b.', 'MarkerSize', 5);
            refresh = 0;
        end
        [boundaries, int_type, tmp_box] = get_intervals(traces, primary_ax, 1);
        if sum(boundaries) == 0
            go_on = strcmp(questdlg('Keep preselecting?','Go on?','Yes', 'No', 'Stats', 'Yes'),'Yes');
            states.spotnums(i) = spots(i);
            i = i+1;
            refresh = 1;
        else
            tmp_frames = boundaries(1):sum(boundaries);
            tmp_rms10 = movie_data{spots(i),1}.vwcm.rms10(tmp_frames);
            switch int_type{1}
                case 'b' % bound state
                    tmp_states = ones(size(tmp_frames));
                case 'u' % unbound state
                    tmp_states = 2.*ones(size(tmp_frames));
                case 'o' % otsu thresholding                 
                    threshold = graythresh(tmp_rms10);
                    tmp_states = double(tmp_rms10<threshold) + 2.*double((tmp_rms10>threshold));
            end
            tmp_plot = cell(2,1);
            for st = 1:2
                tmp_plot{st} = plot(tmp_frames(tmp_states==st), tmp_rms10(tmp_states==st), [state_colors{st} '.'], 'MarkerSize', 5);
            end
            switch questdlg('Preselection OK?')
                case 'Yes'
                    states.bound{i} = vertcat(states.bound{i}, tmp_frames(tmp_states==1)');
                    states.unbound{i} = vertcat(states.unbound{i}, tmp_frames(tmp_states==2)');
                case 'No'
                    tmp_box{1}.delete;
                    for st = 1:2
                       tmp_plot{st}.delete;
                    end
            end
        end
    end
    close all
end

