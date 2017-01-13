function [ traces ] = AutocorrPlotIntMean( AutocorrData, AutocorrIntMean, varargin )
% AutocorrPlotIntervals: to plot parts of movie compared to the whole movie 
  
p = inputParser;
addRequired(p, 'AutocorrData')
addRequired(p, 'AutocorrIntMean')
addOptional(p, 'Fs', 10, @isscalar)
addOptional(p, 'chm', 2, @isscalar)

parse(p, AutocorrData, AutocorrIntMean, varargin{:})
AutocorrData = p.Results.AutocorrData;
AutocorrIntMean = p.Results.AutocorrIntMean;
Fs = p.Results.Fs;
chm = p.Results.chm;
frames = length(AutocorrData{1}.pos_mean_x); % should be 27000
f = Fs.*(0:(frames/2))/frames;
lags = (length(AutocorrData{1}.acorr_mean_x)-1)/2;
interval = AutocorrIntMean{1}.intervals{1}.frames(2); % interval length 
fp = Fs.*(0:(interval/2))/interval;

traces = figure('units','normalized','outerposition',[0 0 1 1]);
for m = 1:length(AutocorrData)  
    j = 1;
    for p = 1:interval:frames
        subplot(3,4,1:4)
        level = ceil(prctile(AutocorrData{m}.spots{s}.pos_x,99));
        plot((AutocorrData{m}.pos_mean_x+level))
        hold on
        plot((AutocorrData{m}.pos_mean_y-level),'k-')
        plot(p:min(min(p+interval-1,frames),length(AutocorrData{m}.pos_mean_x)),(AutocorrData{m}.pos_mean_x(p:min(min(p+interval-1,frames),length(AutocorrData{m}.pos_mean_x)))+level),'r-')
        plot(p:min(min(p+interval-1,frames),length(AutocorrData{m}.pos_mean_y)),(AutocorrData{m}.pos_mean_y(p:min(min(p+interval-1,frames),length(AutocorrData{m}.pos_mean_y)))-level),'r-')
        hold off
        legend('mean x coordinate +1','mean y coordinate -1','interval')
        xlim([0 frames]);
        ylim([-2.5*level 2.5*level]);
        str1 = ['movie ',int2str(m)];
        title(str1,'FontSize',15)
        str2 = ['interval ',int2str(p),':',int2str(min(p+interval-1,frames))];
        xlabel(str2,'FontSize',15)

        subplot(3,4,5)
        plot(-lags:lags,AutocorrIntMean{m}.intervals{j}.acorr_x,'k-')
        ylim([-1.1 1.1])
        title('autocorrelation of interval of mean x','FontSize',15)

        subplot(3,4,6)
        plot(-lags:lags,AutocorrData{m}.acorr_mean_x,'k-')
        ylim([-1.1 1.1])
        title('autocorrelation mean x','FontSize',15)
        str4 = ['chm = ',int2str(chm),'; lags = ',int2str(lags)];
        xlabel(str4,'FontSize',15)

        limity = max(max(AutocorrIntMean{m}.intervals{j}.spectrum_x),max(AutocorrData{m}.spectrum_mean_x));
        subplot(3,4,7)
        plot(fp(1:length(AutocorrIntMean{m}.intervals{j}.spectrum_x)),AutocorrIntMean{m}.intervals{j}.spectrum_x)
        ylim([0 limity*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of interval of mean x','FontSize',15)

        subplot(3,4,8)
        plot(f(1:length(AutocorrData{m}.spectrum_mean_x)),AutocorrData{m}.spectrum_mean_x)
        ylim([0 limity*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of mean x','FontSize',15)

        subplot(3,4,9)
        plot(-lags:lags,AutocorrIntMean{m}.intervals{j}.acorr_y,'k-')
        ylim([-1.1 1.1])
        title('autocorrelation of interval of mean y','FontSize',15)

        subplot(3,4,10)
        plot(-lags:lags,AutocorrData{m}.acorr_mean_y,'k-')
        ylim([-1.1 1.1])
        title('autocorrelation mean y','FontSize',15)

        limityy = max(max(AutocorrIntMean{m}.intervals{j}.spectrum_y),max(AutocorrData{m}.spectrum_mean_y));
        subplot(3,4,11)
        plot(fp(1:length(AutocorrIntMean{m}.intervals{j}.spectrum_y)),AutocorrIntMean{m}.intervals{j}.spectrum_y)
        ylim([0 limityy*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of interval of mean y','FontSize',15)

        subplot(3,4,12)
        plot(f(1:length(AutocorrData{m}.spectrum_mean_y)),AutocorrData{m}.spectrum_mean_y)
        ylim([0 limityy*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of mean y','FontSize',15)
        j = j+1;
        pause
    end
end
end