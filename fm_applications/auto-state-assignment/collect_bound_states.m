function [bound_states_data] = collect_bound_states(movie_data, correlations, behaviour)

    % collect_bound_states: 
    % Definitely bound states are defined by user interaction from spot pair
    % data time traces. For these states, observable values are concatenated 
    % for final output.
    
    %% set parameters
    N_max = 50;
    bs_params = cell(N_max,2);

    spots = find(behaviour==2)';

    %% collect bound state intervals
    i = 1;
    go_on = 1;
    while i <= min([N_max length(spots)]) && go_on
        [traces, primary_ax] = plot_time_traces(movie_data(spots(i),:));
        bs_params{i,1} = spots(i);
        bs_params{i,2} = get_intervals(traces, primary_ax);
        go_on = strcmp(questdlg('Keep collecting states?','Go on?','Yes', 'No', 'Stats', 'Yes'),'Yes');
        i = i+1;
    end

    %% make output
    tmp = sum(cat(1,bs_params{:,2}),1);
    bound_states_data = zeros(tmp(2),9); % intensity ch1 | intensity ch2 | disp100(x|y) | r | delta_pos | correlation | stDev | delta_map
    j = 1;
    for n = 1:N_max
        if ~isempty(bs_params{n,1})
            spotnum = bs_params{n,1};
            for i = 1:size(bs_params{n,2},1)
                frames = bs_params{n,2}(i,1):sum(bs_params{n,2}(i,:));
                % intensity ch1
                bound_states_data(j:j+bs_params{n,2}(i,2),1) = movie_data{spotnum,1}.itrace(frames);
                % intensity ch2
                bound_states_data(j:j+bs_params{n,2}(i,2),2) = movie_data{spotnum,2}.itrace(frames);
                % disp100(x)
                bound_states_data(j:j+bs_params{n,2}(i,2),3) = movie_data{spotnum,1}.vwcm.disp100(frames,1);
                % disp100(y)
                bound_states_data(j:j+bs_params{n,2}(i,2),4) = movie_data{spotnum,1}.vwcm.disp100(frames,2);
                % r
                bound_states_data(j:j+bs_params{n,2}(i,2),5) = movie_data{spotnum,1}.vwcm.r(frames);
                % delta_pos
                bound_states_data(j:j+bs_params{n,2}(i,2),6) = sqrt(sum((movie_data{spotnum,1}.vwcm.pos(frames,:) ...
                                                    - movie_data{spotnum,1}.vwcm.pos(frames-1,:)).^2,2));
                % correlation
                bound_states_data(j:j+bs_params{n,2}(i,2),7) = correlations{spotnum,1}.reverse(frames);
                % stDev
                bound_states_data(j:j+bs_params{n,2}(i,2),8) = movie_data{spotnum,1}.vwcm.stDev(frames);
                % delta_map
                bound_states_data(j:j+bs_params{n,2}(i,2),9) = sqrt(sum((movie_data{spotnum,1}.vwcm.pos(frames,:) ...
                                                    - movie_data{spotnum,2}.vwcm.pos_map(frames,:)).^2,2));

                % increase j accordingly
                j = j+ bs_params{n,2}(i,2) + 1;
            end
        end
    end

end