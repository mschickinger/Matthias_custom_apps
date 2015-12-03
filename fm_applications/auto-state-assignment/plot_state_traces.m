function [ state_traces ] = plot_state_traces(spot_pair_data, states, varargin)
    %plot_state_traces
    %   displays assigned states in three plots (r-trace, rms10-trace, binary)
    %   plus intensity trace of mobile spot over time (frames). 
    %   color code:
    %   black for un-assigned (outliers/transitions)
    %   red for state 1 (bound)
    %   green for state 2 (unbound)
    
    %   INPUT
    %   spot_pair_data: data from both channels of one spot pair (1x2 cell)
    %   states: vector containing state assignments for every frame in ch1
    %   YLIM: 1x2 vector, y-axis limits for r/rms10-trace (default: [0 2])
    %   cl: true/false, determines if all open figures are closes at start
    
    %   OUTPUT
    %   state_traces: figure handle

    %% parse input
    p = inputParser;
    
    addRequired(p, 'spot_pair_data', @iscell);
    addRequired(p, 'states', @isvector);
    addParamter(p, 'YLIM', [0 2], @isvector);
    addParameter(p, 'cl', true, @islogical);
    
    parse(p, spot_pair_data, states, varargin{:});
    
    if p.Results.cl
        close all
    end

    %% set parameters
    colors = {'k', 'r', 'g'};
    state_traces = figure('units','normalized','outerposition',[0 0 1 1]);
    frames = 1:length(spot_pair_data{1}.pos0);

    %% plot
    subplot(4,1,1)
    hold off
    for i=0:2
        plot(frames(states==i),spot_pair_data{1}.vwcm.r(states==i), [colors{i+1} '.'], 'MarkerSize', 5)
        hold on
        ylim(p.Results.YLIM)
    end
    title('r trace')

    subplot(4,1,2)
    hold off
    for i=0:2
        plot(frames(states==i),spot_pair_data{1}.vwcm.rms10(states==i), [colors{i+1} '.'], 'MarkerSize', 5)
        hold on
        ylim(p.Results.YLIM)
    end
    title('rms10 trace')

    subplot(4,1,3)
    hold off
    for i=0:2
        plot(frames(states==i),states(states==i), [colors{i+1} '.'], 'MarkerSize', 5)
        hold on
        ylim([-.5 2.5])
    end
    title('State assignment')

    subplot(4,1,4)
    hold off
    plot(spot_pair_data{1}.itrace, [colors{2} '-'], 'LineWidth', .5)
    hold on
    plot(spot_pair_data{1}.med_itrace, 'k-', 'LineWidth', .5)
    plot([1 frames(end)],6200.*[1 1], '-.', 'Color', .7.*[1 1 1])
    ylim([.9*min(spot_pair_data{1}.itrace) 1.1*max(spot_pair_data{1}.itrace)])
    title('Intensity trace')
    xlabel('frames')

    for i = 1:4
        subplot(4,1,i)
        xlim([0 frames(end)])
    end

end

