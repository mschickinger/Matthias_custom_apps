function [ traces ] = AutocorrPlotIntervals( AutocorrData, AutocorrIntervals, varargin )
% AutocorrData
%  
p = inputParser;
addRequired(p, 'AutocorrData')
addRequired(p, 'AutocorrIntervals')
addOptional(p, 'Fs', 10, @isscalar)
addOptional(p, 'chm', 2, @isscalar)

parse(p, AutocorrData, AutocorrIntervals, varargin{:})
AutocorrData = p.Results.AutocorrData;
AutocorrIntervals = p.Results.AutocorrIntervals;
Fs = p.Results.Fs;
chm = p.Results.chm;
frames = length(AutocorrData{1}.pos_mean_x); % should be 27000
f = Fs.*(0:(frames/2))/frames;
lags = (length(AutocorrData{1}.acorr_mean_x)-1)/2;
interval = AutocorrIntervals{1}{1}.intervals{1}.frames(2); % interval length 
fp = Fs.*(0:(interval/2))/interval;

traces = figure('units','normalized','outerposition',[0 0 1 1]);
for m = 1:length(AutocorrData)  
    for s = 1:length(AutocorrData{m}.spots)
        j = 1;
        for p = 1:interval:frames
            subplot(3,4,1:4)
            plot((AutocorrData{m}.spots{s}.pos_x+1))
            hold on
            plot((AutocorrData{m}.spots{s}.pos_y-1),'k-')
            plot(p:min(p+interval-1,frames),(AutocorrData{m}.spots{s}.pos_x(p:min(p+interval-1,frames))+1),'r-')
            plot(p:min(p+interval-1,frames),(AutocorrData{m}.spots{s}.pos_y(p:min(p+interval-1,frames))-1),'r-')
            hold off
            legend('x coordinate +1','y coordinate -1','interval')
            xlim([0 frames]);
            ylim([-2 2]);
            str1 = ['movie ',int2str(m),'; spot ',int2str(AutocorrData{m}.spots{s}.spot_numb)];
            title(str1,'FontSize',15)
            str2 = ['interval ',int2str(p),':',int2str(min(p+interval-1,frames))];
            xlabel(str2,'FontSize',15)

            subplot(3,4,5)
            plot(-lags:lags,AutocorrIntervals{m}{s}.intervals{j}.acorr_x,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation of interval of x','FontSize',15)

            subplot(3,4,6)
            plot(-lags:lags,AutocorrData{m}.spots{s}.acorr_x,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation total spot x','FontSize',15)
            str4 = ['chm = ',int2str(chm),'; lags = ',int2str(lags)];
            xlabel(str4,'FontSize',15)

            limity = max(max(AutocorrIntervals{m}{s}.intervals{j}.spectrum_x),max(AutocorrData{m}.spots{s}.spectrum_x));
            subplot(3,4,7)
            plot(fp,AutocorrIntervals{m}{s}.intervals{j}.spectrum_x)
            ylim([0 limity*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of interval of x','FontSize',15)

            subplot(3,4,8)
            plot(f,AutocorrData{m}.spots{s}.spectrum_x)
            ylim([0 limity*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of total spot x','FontSize',15)

            subplot(3,4,9)
            plot(-lags:lags,AutocorrIntervals{m}{s}.intervals{j}.acorr_y,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation of interval of y','FontSize',15)

            subplot(3,4,10)
            plot(-lags:lags,AutocorrData{m}.spots{s}.acorr_y,'k-')
            ylim([-1.1 1.1])
            title('autocorrelation total spot y','FontSize',15)

            limityy = max(max(AutocorrIntervals{m}{s}.intervals{j}.spectrum_y),max(AutocorrData{m}.spots{s}.spectrum_y));
            subplot(3,4,11)
            plot(fp,AutocorrIntervals{m}{s}.intervals{j}.spectrum_y)
            ylim([0 limityy*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of interval of y','FontSize',15)

            subplot(3,4,12)
            plot(f,AutocorrData{m}.spots{s}.spectrum_y)
            ylim([0 limityy*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of total spot y','FontSize',15)
            j = j+1;
            pause
        end
    end
end
end

