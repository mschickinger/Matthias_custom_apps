function [ traces ] = AutocorrPlotOnlyMean( AutocorrData, varargin )
% AutocorrData
%  
p = inputParser;
addRequired(p, 'AutocorrData')
addOptional(p, 'Fs', 10, @isscalar)
addOptional(p, 'chm', 2, @isscalar)

parse(p, AutocorrData, varargin{:})
AutocorrData = p.Results.AutocorrData;
Fs = p.Results.Fs;
chm = p.Results.chm;
frames = length(AutocorrData{1}.pos_mean_x); % should be 27000
f = Fs.*(0:(frames/2))/frames;
lags = (length(AutocorrData{1}.acorr_mean_x)-1)/2;

traces = figure('units','normalized','outerposition',[0 0 1 1]);
    for m = 1:length(AutocorrData)
        subplot(3,2,1:2)
        plot(AutocorrData{m}.pos_mean_x+1)
        hold on
        plot(AutocorrData{m}.pos_mean_y-1,'k-')
        hold off
        legend('mean x +1','mean y -1')
        xlim([0 frames]);
        ylim([-2 2]);
        str1 = ['movie ',int2str(m)];
        title(str1,'FontSize',15)
        xlabel('frames','FontSize',10)

        subplot(3,2,3)
        plot(-lags:lags, AutocorrData{m}.acorr_mean_x,'k-')
        ylim([-1.1 1.2])
        title('autocorrelation mean x','FontSize',15)
        str2 = ['chm = ',int2str(chm),'; lags = ',int2str(lags),'; number of spots = ',int2str(length(AutocorrData{m}.spots))];
        xlabel(str2,'FontSize',15)

        subplot(3,2,5)
        plot(-lags:lags,AutocorrData{m}.acorr_mean_y,'k-')
        ylim([-1.1 1.2])
        title('autocorrelation mean y','FontSize',15)

        subplot(3,2,4)
        plot(f,AutocorrData{m}.spectrum_mean_x)
        title('single-sided amplitude spectrum of x','FontSize',15)
        xlabel('f [Hz]','FontSize',15)
        limity = max(max(AutocorrData{m}.spectrum_mean_x),max(AutocorrData{m}.spectrum_mean_y(:)));
        ylim([0 limity])

        subplot(3,2,6)
        plot(f,AutocorrData{m}.spectrum_mean_y)
        title('single-sided amplitude spectrum of y','FontSize',15)
        xlabel('f [Hz]','FontSize',15)
        ylim([0 limity])

        pause
    end
end

