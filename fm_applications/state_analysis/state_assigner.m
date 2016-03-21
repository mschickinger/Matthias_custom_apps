% Need to be loaded: 
% data_spot_pairs, GiTSiK, hop (if it already exists)

close all
clear spot_result
%% Assign parameters

% trace parameters:
w_med = 10;
threshold = [];

% display parameters:
w_plot = 5000; %Plot window size
YLIM = [0 2];

binsize = 0.02;
spacing = 0.002;
centers = binsize/2:spacing:2;
counts = zeros(size(centers));
%% Create hop structure
if ~exist('hop','var')
    sample_ident = inputdlg({'Date:', 'Sample:'}, 'Identify');
    hop.sample = sample_ident{2};
    hop.date = sample_ident{1};
    hop.results = {};
end
%% Create counter/check storage
if ~exist('hop_list','var')
    hop_list = [];
    for i = 1:length(GiTSiK.categorized)
        tmp = find(GiTSiK.behaviour{i}==2);
        hop_list = [hop_list; i*ones(size(tmp)) tmp];
    end
end
%% spot_result structure:
% change movie number
% movie = 
hop_counter = length(hop.results) + 1;
prompt = {'Movie:', 'Spot:'};
defaultanswers = {num2str(hop_list(hop_counter,1)), num2str(hop_list(hop_counter,2))};
spot_ident = inputdlg(prompt,'Identify',1,defaultanswers);
m = str2double(spot_ident{1});
s = str2double(spot_ident{2});
plot_data = data{m}{s,1}.vwcm;
spot_result.index = ['m' spot_ident{1} 's' spot_ident{2}];
spot_result.t_bind = [];
spot_result.t_unbind = [];
spot_result.states = zeros(size(data{m}{s,1}.pos0,1),1);

%% Set maximum frame and kind of state traces
% define traces
plot_data = data{m}{s,1}.vwcm;
state_trace_coarse = ones(size(correlations_pos0{m}{s,1}.forward))-medfilt1(correlations_pos0{m}{s,1}.forward,2*w_med+1);
state_trace_coarse(1) = state_trace_coarse(2);
state_trace_coarse(end) = state_trace_coarse(end-1);
state_trace_fine = ones(size(correlations_pos0{m}{s,1}.forward))-correlations_pos0{m}{s,1}.forward;
% create figure window
fg_traces = figure('OuterPosition', [scrsz(1) scrsz(2) scrsz(3) scrsz(4)*.6]);
hold off
plot(plot_data.r, 'r.', 'MarkerSize', 8)
hold on
plot(plot_data.rms10, 'k-', 'LineWidth', 1.5)
%plot(state_trace_fine, '-', 'LineWidth', .5)
set(gca, 'ColorOrderIndex', 3);
%plot(state_trace_coarse, 'LineWidth', 1.5)
%plot(threshold, 'b-', 'Linewidth', 1.5)
xlim([1 length(state_trace_coarse)])
ylim(YLIM)
%%% new
check_spot = questdlg('Spot alright?', 'Continue?', 'Continue', 'Only one transition', 'Something else', 'Continue');
switch check_spot
    case 'Only one transition'
        spot_result.comment = 'discarded: only one transition';
        hop.results{hop_counter}.index = spot_result.index;
        hop.results{hop_counter}.comment = spot_result.comment;
        display(['Discarded spot #' num2str(s) ' from movie #' num2str(m)])
        close all;
        return;
    case 'Something else'
        prompt = {'Specify'};
        defaultanswers = {'Promiscuous'};
        check_spot_specify = inputdlg(prompt,'Specify',1,defaultanswers);
        spot_result.comment = check_spot_specify{1}; 
        hop.results{hop_counter}.index = spot_result.index;
        hop.results{hop_counter}.comment = spot_result.comment;
        display(['Postponed spot #' num2str(s) ' from movie #' num2str(m)])
        close all;
        return;
    case 'Continue'
        if isfield(spot_result,'comment')
            spot_result = rmfield(spot_result,'comment');
        end
end
%%%
set_max_frame = questdlg('Set maximum frame?', 'Max frame?', 'No');
switch set_max_frame
    case 'Yes'
        h0 = impoint(gca);
        max_frame = getPosition(h0);
        max_frame = round(max_frame(1));
        clear h0
        % re-define traces
        state_trace_coarse = state_trace_coarse(1:max_frame);
        %state_trace_fine = state_trace_fine(1:max_frame);
    case 'No'
        max_frame = length(plot_data.r);
end

%% Assign states with transition detective

tmp_output = transition_detective(plot_data.rms10(1:max_frame), plot_data.r(1:max_frame));
spot_result.t_bind = tmp_output.t_bind_coarse;
spot_result.t_unbind = tmp_output.t_unbind_coarse;

%% Define initital state
if isempty(spot_result.t_bind) && isempty(spot_result.t_unbind)
    xlim([1 w_plot]), figure(fg_traces)
    start_state = questdlg('Which is the initial state?', 'Initial state', 'Bound', 'Unbound', 'Bound');
end

%% Threshold determination        
% go_on = 1;
% pointwise = strcmp(questdlg('Threshold by point-and-click?', 'Pointwise', 'Yes'),'Yes');
% while go_on
%     close all
%     assign = 1;
%     assign_counter = 1;
%     threshold_vals = []; % container for threshold sample values
%     threshold_pos = []; % container for threshold sample positions
%     st_hist = figure('OuterPosition', [scrsz(1) scrsz(2) scrsz(3)./3 scrsz(4)/2], 'Visible', 'off');
%     fg_traces = figure('OuterPosition', [scrsz(1) scrsz(4)*.4 scrsz(3) scrsz(4)*.6]);
%     while assign
%         figure(fg_traces)
%         hold off
%         plot(plot_data.r, 'r.', 'MarkerSize', 8)
%         hold on
%         plot(plot_data.rms10, 'k-', 'LineWidth', 1.5)
%         plot(state_trace_fine, '-', 'LineWidth', .5)
%         set(gca, 'ColorOrderIndex', 3);
%         plot(state_trace_coarse, 'LineWidth', 1.5)
%         plot(threshold, 'b-', 'Linewidth', 1.5)
%         ylim(YLIM)
%         xlim([1 max_frame])
%         if pointwise
%             h1 = impoint(gca);
%             h1pos = getPosition(h1);
%             threshold_pos = [threshold_pos round(h1pos(1))];
%             threshold_vals = [threshold_vals h1pos(2)];
%         else
%             h1 = imrect(gca);
%             h1pos = round(getPosition(h1));
%             h1pos(3) = min([h1pos(3) length(state_trace_coarse)-h1pos(1)]);
%             for i = 1:length(counts)
%                 counts(i) = sum(state_trace_coarse(h1pos(1):h1pos(1)+h1pos(3))>=centers(i)-binsize/2 ...
%                     & state_trace_coarse(h1pos(1):h1pos(1)+h1pos(3))<centers(i)+binsize/2);
%             end
%             figure(st_hist)
%             hold off
%             plot(centers,counts)
%             set(gcf, 'Visible', 'on')
%             threshold_method = questdlg('Which method for thresholding?', 'threshold_method', 'Line', 'Minimum', 'Mean-Maxima', 'Line');
%             h2 = imrect(gca);
%             h2pos = getPosition(h2);
%             delete(h2)
%             clear h2
%             centers_box = centers((centers>=h2pos(1)).*(centers<=(h2pos(1)+h2pos(3)))==1);
%             counts_box = counts((centers>=h2pos(1)).*(centers<=(h2pos(1)+h2pos(3)))==1);
%             if strcmp(threshold_method, 'Line')
%                 threshold_tmp = h2pos(1)+h2pos(3)/2;
%             elseif strcmp(threshold_method, 'Minimum')      
%                 min_count = min(counts((centers>=h2pos(1)).*(centers<=(h2pos(1)+h2pos(3)))==1));
%                 tmp = find(counts_box==min_count);
%                 threshold_tmp = centers_box(tmp);
%             elseif strcmp(threshold_method, 'Mean-Maxima')
%                 tmp = counts_box>h2pos(2);
%                 tmp = [0 tmp(2:end)-tmp(1:end-1)];
%                 lower = find(tmp==1);
%                 if length(lower)<2
%                     lower = [1 lower];
%                 end
%                 upper = find(tmp==-1);
%                 if length(upper)<2;
%                     upper = [upper length(centers_box)];
%                 end
%                 centers_max = [0 0];
%                 for i = 1:2
%                     tmp = find(counts_box==max(counts_box(lower(i):upper(i))));
%                     tmp = round(mean(tmp));
%                     centers_max(i) = centers_box(tmp);
%                 end
%                 threshold_tmp = mean(centers_max);
%             end
%             if length(threshold_tmp)>1
%                 threshold_tmp = [threshold_tmp mean(threshold_tmp)];
%                 threshold_options = cell(length(threshold_tmp),1);
%                 figure(fg_traces)
%                 hold on
%                 xlim([h1pos(1)-1 h1pos(1)+h1pos(3)+1])
%                 for i = 1:length(threshold_options)
%                     threshold_options{i} = num2str(threshold_tmp(i));
%                     plot([h1pos(1)-1 h1pos(1)+h1pos(3)+1], [1 1].*threshold_tmp(i), '-', 'LineWidth', .5)
%                 end
%                 [threshold_select, ok] = listdlg('ListString', threshold_options,...
%                     'PromptString', 'Pick threshold', 'SelectionMode', 'single');
%                 threshold_tmp = threshold_tmp(threshold_select(1));
%             end
%         threshold_vals = [threshold_vals threshold_tmp];
%         threshold_pos = [threshold_pos h1pos(1)+round(h1pos(3)/2)];
%         set(st_hist, 'Visible', 'off')
%         end
%         if assign_counter > 1
%             assign = questdlg('Keep assigning?', 'Keep assigning', 'Yes');
%             assign = strcmp(assign, 'Yes');
%         end
%         assign_counter = assign_counter+1;
%     end
%     threshold_vals = [threshold_vals(1) threshold_vals threshold_vals(end)];
%     threshold_pos = [1 threshold_pos max_frame];
%     threshold = interp1(threshold_pos, threshold_vals, 1:max_frame,...
%         'linear', 'extrap');
% 
%     % Check threshold
%     figure(fg_traces)
%     plot(threshold, 'b-', 'LineWidth', 1.5)
%     xlim([1 max_frame])
%     check_threshold = questdlg('Threshold OK?', 'Threshold check', 'Yes');
%     if strcmp(check_threshold, 'Yes')
%         figure(fg_traces)
%         plot(threshold, 'b-', 'LineWidth', 1.5)
%         glob = questdlg('Assign coarse transitions?', 'Coarse assignment?', 'Yes');
%         if strcmp(glob,'Yes')
%             states = state_trace_coarse>threshold'; %change >/< according to type of state_trace
%             t_trans = [states(1) (states(2:end)-states(1:end-1))'];
%             spot_result.t_bind = (find(t_trans==-1))'; %change -1/1 according to type of state_trace
%             spot_result.t_unbind = (find(t_trans==1))'; %change 1/-1 according to type of state_trace
%             go_on = 0;
%             close all
%         elseif strcmp(glob, 'No')
%             uiwait(msgbox('Restart threshold assignment', 'Restart', 'modal'))
%             threshold = zeros(1,max_frame);
%         end
%     elseif strcmp(check_threshold, 'No')
%         uiwait(msgbox('Restart threshold assignment', 'Restart', 'modal'))
%         threshold = zeros(1,max_frame);
%     end
% end

%% Check all transitions again
check_transitions = 1;
while check_transitions
    close all
    figure('OuterPosition', [scrsz(1) scrsz(2) scrsz(3) scrsz(4)*.6])
    for k = 1:2    
        subplot(2,1,k)
        hold off
        plot(plot_data.r,'r.', 'MarkerSize', 8);
        hold on
        plot(plot_data.rms10,'k-', 'LineWidth', 1.5);
        %plot(state_trace_fine, '-', 'LineWidth', .5)
        set(gca, 'ColorOrderIndex', 3);
        plot(state_trace_coarse, 'LineWidth', 1.5)
        for j = spot_result.t_bind'
            plot([j,j],YLIM,'b-', 'LineWidth', .5);
            plot(j,.1*YLIM(2),'bv', 'MarkerFaceColor', 'b')
        end
        for j = spot_result.t_unbind'
            plot([j,j],YLIM,'b-', 'LineWidth', .5);
            plot(j,.9*YLIM(2),'b^', 'MarkerFaceColor', 'b')
        end
    end
    subplot(2,1,2)
    xlim([1 length(plot_data.r)])
    start_check_index = 1;
    for i = sort([spot_result.t_bind(start_check_index:end)' spot_result.t_unbind(start_check_index:end)'])
        for k = 1:2
            subplot(2,1,k)
            plot([i,i],YLIM,'g-');
            ylim(YLIM)
        end
        subplot(2,1,1)
        xlim([i-100 i+100])
        if size(find(spot_result.t_bind == i),1) == 1
            title(['Binding event at frame #' num2str(i)])
        else
            title(['Unbinding event at frame #' num2str(i)])
        end
        figure(gcf)
        keep = questdlg('Keep transition?', 'Keep');
        switch keep
            case 'Yes'
                for k = 1:2
                    subplot(2,1,k)
                    plot([i,i],YLIM,'b-');
                    ylim(YLIM)
                end
            case 'No'
                for k = 1:2
                    subplot(2,1,k)
                    plot([i,i],YLIM,'w-');
                    ylim(YLIM)
                end
                spot_result.t_bind = spot_result.t_bind(spot_result.t_bind~=i);
                spot_result.t_unbind = spot_result.t_unbind(spot_result.t_unbind~=i);
            case 'Cancel'
                break
        end
    end
    check_transitions = strcmp(questdlg('Check again?', 'Keep checking', 'No'),'Yes');
end
close all
%% Add lost transitions
add = questdlg('Add further transitions?', 'Add more?','No');
if strcmp(add, 'Yes')
    state_adder
end
%% Assign initial state
% if strcmp(start_state,'Bound') && isempty(find(spot_result.t_bind==1,1))
%     spot_result.t_bind = [1; spot_result.t_bind];
% elseif strcmp(start_state,'Unbound') && isempty(find(spot_result.t_unbind==1,1))
%     spot_result.t_unbind = [1; spot_result.t_unbind];
% end
%% Exclude intervals from evaluation
ex = questdlg('Exclude intervals from evaluation?', 'Exclude?','No');
ex = strcmp(ex, 'Yes');
ex_int = {}; % container for excluded interval boundaries
spot_result.t_excluded = [];
spot_result.excluded = zeros(size(state_trace_coarse));
if ex
    fg_traces = figure('OuterPosition', [scrsz(1) scrsz(4)*.4 scrsz(3) scrsz(4)*.6]);
    hold off
    plot(plot_data.r, 'r.', 'MarkerSize', 8)
    hold on
    plot(plot_data.rms10, 'k-', 'LineWidth', 1.5)
    %plot(state_trace_fine, '-', 'LineWidth', .5)
    set(gca, 'ColorOrderIndex', 3);
    plot(state_trace_coarse, 'LineWidth', 1.5)
    plot(threshold, 'b-', 'Linewidth', 1.5)
    for j = sort([spot_result.t_bind spot_result.t_unbind])
        plot([j j], YLIM, 'b-', 'LineWidth', 1.5)
    end
    ylim(YLIM)
    xlim([1 max_frame])
    if ~isempty(ex_int)
        for i = 1:size(ex_int,2)
            spot_result.excluded(ex_int{i}(1):ex_int{i}(2)) = 1;
        end
        plot(spot_result.excluded+.5, '-g')
        ex = strcmp(questdlg('Exclude more intervals from evaluation?', 'Exclude more?'),'Yes');
    end
    while ex
        h4 = imrect(gca);
        setResizable(h4, true);
        h4pos = round(wait(h4));
        ex_int = [ex_int [h4pos(1) h4pos(1)+h4pos(3)]];
        ex = strcmp(questdlg('Exclude more intervals from evaluation?', 'Exclude more?'),'Yes');
    end
    for i = 1:size(ex_int,2)
        spot_result.t_excluded = [spot_result.t_excluded; ...
            spot_result.t_bind(spot_result.t_bind >= ex_int{i}(1) & spot_result.t_bind <= ex_int{i}(2))'; ...
            spot_result.t_unbind(spot_result.t_unbind >= ex_int{i}(1) & spot_result.t_unbind <= ex_int{i}(2))'];
        spot_result.excluded(ex_int{i}(1):ex_int{i}(2)) = 1;
    end
    plot(spot_result.excluded+.5, '-g')
    zoom out
    uiwait(msgbox('Confirm excluded intervals', 'Confirm excluded', 'modal'))
    close(gcf)
end
%% Corrected transition times
% spot_result.t_bind_corr = spot_result.t_bind;
% spot_result.t_unbind_corr = spot_result.t_unbind;
% 
% means_r = zeros(size(spot_result.t_bind));
% stds_r = zeros(size(means_r));
% means_state_fine = zeros(size(means_r));
% stds_state_fine = zeros(size(means_r));
% 
% trans_counter = 1;
% for j = spot_result.t_bind'
%     i1 = max([1 j-w_med]); i2 = j+w_med;     
%     tmp_interval = i1:i2;
%     if j < spot_result.t_unbind(end)
%         next_unbind = spot_result.t_unbind(find(spot_result.t_unbind>j,1));
%         corr_unbind = 1;
%     else
%         next_unbind = min([j+100 length(state_trace_fine)]);
%         corr_unbind = 0;
%     end
%     indices = j:next_unbind;
%     loop_breaker = 1;
%     while length(indices)<500 && loop_breaker<=10
%         loop_breaker = loop_breaker + 1;
%         indices = [spot_result.t_bind(find(spot_result.t_bind<indices(1),1,'last')):spot_result.t_unbind(find(spot_result.t_unbind<indices(1),1,'last')) ...
%             indices spot_result.t_bind(find(spot_result.t_bind>indices(end),1)):spot_result.t_unbind(find(spot_result.t_unbind>indices(end),1))];
%     end
%     means_r(trans_counter) = mean(plot_data.r(indices));
%     stds_r(trans_counter) = std(plot_data.r(indices));
%     %means_state_fine(trans_counter) = mean(state_trace_fine(j:next_unbind));
%     means_state_fine(trans_counter) = mean(state_trace_fine(indices));
%     stds_state_fine(trans_counter) = std(state_trace_fine(indices));
%     %disp(j)
%     %disp(next_unbind-j)
%     %disp(trans_counter)
%     %disp(means_r(trans_counter)+3*stds_r(trans_counter))
%     %disp(means_state_fine(trans_counter)+3*stds_state_fine(trans_counter))
%     if j>1
%         tmp_states = (plot_data.r(i1:i2) < (means_r(trans_counter)+3*stds_r(trans_counter)))'.*...
%             (state_trace_fine(i1:i2) < (means_state_fine(trans_counter)+3*stds_state_fine(trans_counter)))';
%         tmp_states = [2*tmp_states(1) tmp_states(2:end)+tmp_states(1:end-1)];
%         use_previous = 1;
%         while isempty(find(tmp_states == 0,1))
%             if trans_counter-use_previous > 0
%                 tmp_states = (plot_data.r(i1:i2) < (means_r(trans_counter-use_previous)+3*stds_r(trans_counter-use_previous)))'.*...
%                 (state_trace_fine(i1-1:i2-1) < (means_state_fine(trans_counter-use_previous)+3*stds_state_fine(trans_counter-use_previous)))';
%                 tmp_states = [tmp_states(1:end-1)+tmp_states(2:end) 2*tmp_states(end)];
%                 display(['WARNING: Using mean and std from index ' num2str(trans_counter-use_previous)...
%                     ' instead of index ' num2str(trans_counter) ' for binding event correction.']);
%                 use_previous = use_previous + 1;
%             else
%                 tmp_states = [zeros(1,w_med) ones(1,w_med+1)];
%                 display(['WARNING: No binding event correction at index ' num2str(trans_counter)]);
%             end
%         end
%         spot_result.t_bind_corr(trans_counter) = tmp_interval(find(tmp_states == 0,1,'last'))+1;
%         if ~ismember(spot_result.t_bind_corr(trans_counter), ...
%                 spot_result.t_unbind_corr((spot_result.t_unbind(1)==1)+trans_counter-1):next_unbind)
%             spot_result.t_bind_corr(trans_counter) = j;
%             display(['Forcing correct transition order: No binding event correction at index ' num2str(trans_counter)]);
%         end
%     end
%     if corr_unbind
%         i1 = next_unbind-w_med; i2 = next_unbind+w_med;
%         tmp_interval = i1:i2;
%         tmp_states = (plot_data.r(i1:i2) < (means_r(trans_counter)+3*stds_r(trans_counter)))'.*...
%         (state_trace_fine(i1-1:i2-1) < (means_state_fine(trans_counter)+3*stds_state_fine(trans_counter)))';
%         tmp_states = [tmp_states(1:end-1)+tmp_states(2:end) 2*tmp_states(end)];
%         use_previous = 1;
%         while isempty(find(tmp_states == 0,1))
%             if trans_counter-use_previous > 0
%             tmp_states = (plot_data.r(i1:i2) < (means_r(trans_counter-use_previous)+3*stds_r(trans_counter-use_previous)))'.*...
%             (state_trace_fine(i1-1:i2-1) < (means_state_fine(trans_counter-use_previous)+3*stds_state_fine(trans_counter-use_previous)))';
%             tmp_states = [tmp_states(1:end-1)+tmp_states(2:end) 2*tmp_states(end)];
%             display(['WARNING: Using mean and std from index ' num2str(trans_counter-use_previous)...
%                 ' instead of index ' num2str(trans_counter) ' for unbinding event correction.']);
%             use_previous = use_previous + 1;
%             else
%                 tmp_states = [ones(1,w_med) zeros(1,w_med+1)];
%                 display(['WARNING: No unbinding event correction at index ' num2str(trans_counter)]);
%             end
%         end
%         spot_result.t_unbind_corr((spot_result.t_unbind(1)==1)+trans_counter) = tmp_interval(find(tmp_states == 0,1));
%         if j == spot_result.t_bind(end)
%             next_bind = min([next_unbind+100 length(state_trace_fine)]);
%         else
%             next_bind = spot_result.t_bind(trans_counter+1);
%         end
%         if ~ismember(spot_result.t_unbind_corr((spot_result.t_unbind(1)==1)+trans_counter), ...
%                 spot_result.t_bind_corr(trans_counter):next_bind)
%             spot_result.t_unbind_corr((spot_result.t_unbind(1)==1)+trans_counter) = next_unbind;
%             display(['Forcing correct transition order: No unbinding event correction at index ' num2str(trans_counter)]);
%         end
%     end
%     trans_counter = trans_counter+1;
% end
%% Run state calculator and append to data cell
append_result = 0;
evaluate = questdlg('Proceed to state evaluation?', 'Evaluate?', 'Yes');
if strcmp(evaluate,'Yes')
    append_result = 1;
    if isfield(spot_result, 't_bind_corr')
        spot_result.t_bind = spot_result.t_bind_corr;
        spot_result.t_unbind = spot_result.t_unbind_corr;
        spot_result = rmfield(spot_result, {'t_bind_corr'; 't_unbind_corr'});
    end
    [spot_result.states, spot_result.T_bound, spot_result.T_unbound, spot_result.k_off, spot_result.k_on] = ...
        state_calculator(spot_result, size(spot_result.states,1), 100);
    if ~isempty(find(spot_result.T_bound<0,1))
        display(['ERROR: ' num2str(length(find(spot_result.T_bound<0))) ' negative bound lifetimes.'])
        append_result = 0;
    end
    if ~isempty(find(spot_result.T_unbound<0,1))
        display(['ERROR: ' num2str(length(find(spot_result.T_unbound<0))) ' negative unbound lifetimes.'])
        append_result = 0;
    end
end
if append_result
    hop.results = [hop.results spot_result];
    display(['Appended spot #' num2str(s) ' from movie #' num2str(m) ' to hop.'])
else
    display(['Failed to append spot #' num2str(s) ' from movie #' num2str(m) ' to hop.'])
end

%% End of script
display('Done')

%% Auto save
if rem(length(hop.results),3) == 0
    save(fullfile(pwd,'hop.mat'),'hop');
    display('hop.mat saved');
elseif length(hop.results) == length(hop_list)
    save(fullfile(pwd,'hop.mat'),'hop');
    display('hop.mat saved');
end

%% Check hop
if rem(length(hop.results),3) == 0
    start_index = regexpi(hop.results{hop_counter}.index,'s');
    spot_num_hop = str2double(hop.results{hop_counter}.index(start_index+1:end));
    if isequal(spot_num_hop,hop_list(hop_counter,2))
        display([num2str(spot_num_hop) ' = ' num2str(hop_list(hop_counter,2)) '. Spots sorted correctly.']); 
    else
        display('Error: Spots not sorted correctly');
    end
end