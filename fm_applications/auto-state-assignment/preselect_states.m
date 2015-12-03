function [ states ] = preselect_states(movie_data, behaviour)
    %PRESELECT_STATES
    % Detailed explanation goes here

    %% set parameters
    spots = find(behaviour==2)';
    states.spotnums = spots';
    states.unbound = cell(size(spots'));
    states.bound = cell(size(spots'));
    state_colors = {'c','b'};
    
    %% collect intervals, assign states with Otsu and write to output
    i = 1;
    go_on = 1;
    refresh = 1;
    while go_on
        if refresh
            [traces, primary_ax] = plot_time_traces(movie_data(spots(i),:));
            refresh = 0;
        end
        [boundaries, tmp_box] = get_intervals(traces, primary_ax, 1);
        if sum(boundaries) == 0
            go_on = strcmp(questdlg('Keep preselecting?','Go on?','Yes', 'No', 'Stats', 'Yes'),'Yes');
            i = i+1;
            refresh = 1;
        else
            % otsu thresholding
            tmp_frames = boundaries(1):sum(boundaries);
            tmp_rms10 = movie_data{spots(i),1}.vwcm.rms10(tmp_frames);
            threshold = graythresh(tmp_rms10);
            tmp_states = double(tmp_rms10<threshold) + 2.*double((tmp_rms10>threshold));
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
end

