function [ traces ] = AutocorrPlotSingleSpot( AutocorrData, varargin )
% AutocorrPlotSingleSpot: to plot a traces compared to the mean 

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
        for s = 1:length(AutocorrData{m}.spots)
            subplot(3,4,1:4)
            plot((AutocorrData{m}.spots{s}.pos_x+1))
            hold on
            plot((AutocorrData{m}.spots{s}.pos_y-1),'k-')
            hold off
            legend('x coordinate +1','y coordinate -1')
            xlim([0 frames]);
            %ylim([-2 2]);
            str1 = ['movie ',int2str(m),'; spot ',int2str(AutocorrData{m}.spots{s}.spot_numb)];
            title(str1,'FontSize',15)
            xlabel('frames','FontSize',10)

            subplot(3,4,5)
            plot(-lags:lags,AutocorrData{m}.spots{s}.acorr_x,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation x','FontSize',15)

            subplot(3,4,6)
            plot(-lags:lags,AutocorrData{m}.acorr_mean_x,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation mean x','FontSize',15)
            str2 = ['chm = ',int2str(chm),'; lags = ',int2str(lags),'; number of spots = ',int2str(length(AutocorrData{m}.spots))];
            xlabel(str2,'FontSize',15)

            limity = max(max(AutocorrData{m}.spots{s}.spectrum_x),max(AutocorrData{m}.spectrum_mean_x));
            subplot(3,4,7)
            plot(f,AutocorrData{m}.spots{s}.spectrum_x)
            ylim([0 limity*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of x','FontSize',15)

            subplot(3,4,8)
            plot(f,AutocorrData{m}.spectrum_mean_x)
            ylim([0 limity*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of mean x','FontSize',15)

            subplot(3,4,9)
            plot(-lags:lags,AutocorrData{m}.spots{s}.acorr_y,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation y','FontSize',15)

            subplot(3,4,10)
            plot(-lags:lags,AutocorrData{m}.acorr_mean_y,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation mean y','FontSize',15)

            limityy = max(max(AutocorrData{m}.spots{s}.spectrum_y),max(AutocorrData{m}.spectrum_mean_y));
            subplot(3,4,11)
            plot(f,AutocorrData{m}.spots{s}.spectrum_y)
            ylim([0 limityy*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of y','FontSize',15)

            subplot(3,4,12)
            plot(f,AutocorrData{m}.spectrum_mean_y)
            ylim([0 limityy*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of mean y','FontSize',15)
            pause
        end
    end 
end

