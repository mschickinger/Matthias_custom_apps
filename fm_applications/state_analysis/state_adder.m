close all

%% Assign parameters

%{
m = 1;
s = 5;
plot_data = data{m}{s,1}.vwcm;
%}

w_plot = 2000; %Plot window size
YLIM = [0 2];

first_frame = str2double(inputdlg('Enter start frame number'));

%% Prepare graph
close all
fg_traces = figure('OuterPosition', [scrsz(1) scrsz(2) scrsz(3) scrsz(4)*.6]);
hold off
plot(plot_data.r, 'r.', 'MarkerSize', 8)
hold on
plot(plot_data.rms10, 'k-', 'LineWidth', 1.5)
%plot(state_trace_fine, '-', 'LineWidth', .5)
set(gca, 'ColorOrderIndex', 3);
plot(state_trace_coarse, 'LineWidth', 4.5)
plot(threshold, 'b-', 'Linewidth', 1.5)
for j = spot_result.t_bind'
    plot([j,j],YLIM,'b-', 'LineWidth', .5);
    plot(j,.1*YLIM(2),'bv', 'MarkerFaceColor', 'b')
end
for j = spot_result.t_unbind'
    plot([j,j],YLIM,'b-', 'LineWidth', .5);
    plot(j,.9*YLIM(2),'b^', 'MarkerFaceColor', 'b')
end
xlim([first_frame first_frame+w_plot])
ylim(YLIM)

%% Start state addition
go_on = 1;
while go_on == 1
    % Take action
    next_action = questdlg('What now?', 'Next step', 'Add', 'Move on', 'Stop adding', 'Move on');
    switch next_action
    case 'Move on'
        for i = 1:100
            xlim([first_frame first_frame+w_plot] + i*15)
            pause(.02)
        end
        first_frame = first_frame + 1500;
    case 'Stop adding'
        go_on = 0;
    case 'Add'
        add_here = 1;
        while add_here
            figure(fg_traces)
            h3 = impoint(gca);
            pos3 = round(getPosition(h3));
            state_type = questdlg('Binding or UNbinding event?', 'Type of event', 'Binding', 'Unbinding', 'Discard', 'Unbinding');
            switch state_type
                case 'Binding'
                    spot_result.t_bind = sort(horzcat(spot_result.t_bind, pos3(1)));
                    plot(pos3(1).*[1,1], YLIM, 'b-');
                    plot(pos3(1),.1*YLIM(2),'bv', 'MarkerFaceColor', 'b')
                case 'Unbinding'
                    spot_result.t_unbind = sort(horzcat(spot_result.t_unbind, pos3(1)));
                    plot(pos3(1).*[1,1], YLIM, 'b-');
                    plot(pos3(1),.9*YLIM(2),'b^', 'MarkerFaceColor', 'b')
            end
            move_on = questdlg('Stay here or set new?', 'Keep adding?', 'Stay here', 'Set new', 'Stop adding', 'Stay here');
            switch move_on
                case 'Set new'
                    first_frame = str2double(inputdlg('Enter start frame number', 'Start frame', 1, {num2str(first_frame)}));
                    zoom out
                    xlim([first_frame first_frame+w_plot])
                    ylim(YLIM)
                    add_here = 0;
                case 'Stop adding'
                    add_here = 0;
                    go_on = 0;
            end
        end
    end
end
close all
%% End of script
display('Done')