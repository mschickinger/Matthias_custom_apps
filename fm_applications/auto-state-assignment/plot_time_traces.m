function [ traces, primary_ax ] = plot_time_traces(spot_pair_data, varargin)

%plot_time_traces
    %   displays position (r-trace, rms10-trace)
    %   plus intensity trace of both spots over time (frames). 
    %   color code:
    %   red for channel 1
    %   green for channel 2
    
    %   INPUT
    %   spot_pair_data: data from both channels of one spot pair (1x2 cell)
    %   YLIM: 1x2 vector, y-axis limits for r/rms10-trace (default: [0 2])
    %   cl: true/false, determines if all open figures are closes at start
    
    %   OUTPUT
    %   traces: figure handle
    %   primary_ax: handle to axis in channel 1 position trace subplot
    
    %% parse input

    p = inputParser;
    
    addRequired(p, 'spot_pair_data', @iscell);
    addParamter(p, 'YLIM', [0 2], @isvector);
    addParameter(p, 'cl', true, @islogical);
    
    parse(p, spot_pair_data, varargin{:});
    
    if p.Results.cl
        close all
    end
    
    %% set parameters
    
    colors = {'r', 'g'};
    channels = {'unbound', 'bound'};
    
    traces = figure('units','normalized','outerposition',[0 0 1 1]);
    ax = cell(4,1);

    for ch = 1:2
        ax{2*(ch-1)+1} = subplot('Position', [0.025, 0.25+(2-ch)*.45, .95, .19]);
        plot(spot_pair_data{ch}.vwcm.r, [colors{ch} '.'], 'MarkerSize', 5)
        hold on
        plot(spot_pair_data{ch}.vwcm.rms10, 'k-', 'LineWidth', .5)
        xlim([0 length(spot_pair_data{ch}.pos0)])
        ylim(p.Results.YLIM)
        title(['Position trace for ' channels{ch} ' channel.'])

        ax{2*ch} = subplot('Position', [0.025, 0.03+(2-ch)*.45, .95, .19]);
        plot(spot_pair_data{ch}.itrace, [colors{ch} '-'], 'LineWidth', .5)
        hold on
        plot(spot_pair_data{ch}.med_itrace, 'k-', 'LineWidth', .5)
        xlim([0 length(spot_pair_data{ch}.pos0)])
        ylim([.9*min(spot_pair_data{ch}.itrace) 1.1*max(spot_pair_data{ch}.itrace)])
        title(['Intensity trace for ' channels{ch} ' channel.'])
    end
    xlabel('frames')
    primary_ax = ax{1};

end

