function review_transitions(plot_data, spot_data)

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
    for j = spot_data.t_bind'
        plot([j,j],YLIM,'b-', 'LineWidth', .5);
        plot(j,.1*YLIM(2),'bv', 'MarkerFaceColor', 'b')
    end
    for j = spot_data.t_unbind'
        plot([j,j],YLIM,'b-', 'LineWidth', .5);
        plot(j,.9*YLIM(2),'b^', 'MarkerFaceColor', 'b')
    end
    xlim([first_frame first_frame+w_plot])
    ylim(YLIM)

    %% Start state reviewing
    go_on = 1;
    while go_on == 1
        % Take action
        next_action = questdlg('What now?', 'Next step', 'Move on', 'Stop reviewing', 'Move on');
        switch next_action
        case 'Move on'
            for i = 1:100
                xlim([first_frame first_frame+w_plot] + i*15)
                pause(.02)
            end
            first_frame = first_frame + 1500;
        case 'Stop reviewing'
            go_on = 0;
        end
    end
    close all

    %% End of function
    display('Done')
end