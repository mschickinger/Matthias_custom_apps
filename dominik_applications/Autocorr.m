data = data_E4zero;
movies = traces_E4zero;
chm = 2; % 1 = red; 2 = green;
lags = 200;
frames = 27000;
acorr = cell(length(movies),2); % always first column x and second column y
acorrmean = cell(length(movies),2);
acorrparted = cell(length(movies),2);
XY = cell(length(movies),2);
XYmean = cell(length(movies),2);

Fs = 10; % fft example from help
T = 1/Fs;
L = frames;
t = (0:L-1).*T;
f = Fs.*(0:(L/2))/L;
FFT = cell(length(movies),2);
P1 = cell(length(movies),2);
P2 = cell(length(movies),2);
FFTmean = cell(length(movies),2);
P1mean = cell(length(movies),2);
P2mean = cell(length(movies),2);

interval = 3000;
Lp = interval;
tp = (0:Lp-1).*T;
fp = Fs.*(0:(Lp/2))/Lp;
FFTparted = cell(length(movies),2);
P1parted = cell(length(movies),2);
P2parted = cell(length(movies),2);
for c = 1:2
    for m = 1:length(movies)
        XY{m,c} = zeros(frames,length(movies{m}));
        acorr{m,c} = zeros(2*lags+1,length(movies{m}));
        FFT{m,c} = zeros(frames,length(movies{m}));
        P2{m,c} = zeros(frames,length(movies{m}));
        P1{m,c} = zeros((frames/2)+1,length(movies{m}));
        FFTparted{m,c} = zeros(interval,length(movies{m}),length(1:interval:frames));
        P2parted{m,c} = zeros(interval,length(movies{m}),length(1:interval:frames));
        P1parted{m,c} = zeros((interval/2)+1,length(movies{m}),length(1:interval:frames));
        
        for i = 1:length(movies{m})
            XY{m,c}(:,i) = data{m}{movies{m}(i),chm}.vwcm.disp100(:,c);
            acorr{m,c}(:,i) = xcorr(XY{m,c}(:,i),lags,'coeff');
            
            FFT{m,c}(:,i) = fft(XY{m,c}(:,i));
            P2{m,c}(:,i) = abs(FFT{m,c}(:,i)./L);
            P1{m,c}(:,i) = P2{m,c}(1:(L/2+1),i);
            P1{m,c}(2:end-1,i) = 2.*P1{m,c}(2:end-1,i);
                        
            j = 1;
            for p = 1:interval:frames
                acorrparted{m,c}(:,i,j) = xcorr(XY{m,c}(p:p+interval-1,i),lags,'coeff');
                FFTparted{m,c}(:,i,j) = fft(XY{m,c}(p:p+interval-1,i));
                P2parted{m,c}(:,i,j) = abs(FFTparted{m,c}(:,i,j)./Lp);
                P1parted{m,c}(:,i,j) = P2parted{m,c}(1:(Lp/2+1),i,j);
                P1parted{m,c}(2:end-1,i,j) = 2.*P1parted{m,c}(2:end-1,i,j);
                j = j+1;
            end
        end
        XYmean{m,c} = mean(XY{m,c},2);
        acorrmean{m,c} = xcorr(XYmean{m,c},lags,'coeff');
        
        FFTmean{m,c} = fft(XYmean{m,c});
        P2mean{m,c} = abs(FFTmean{m,c}./L);
        P1mean{m,c} = P2mean{m,c}(1:(L/2+1));
        P1mean{m,c}(2:end-1) = 2.*P1mean{m,c}(2:end-1);
        
    end
end
%% PLOT only mean
figure
for m = 1:length(movies)
    subplot(3,2,1:2)
    plot(XYmean{m,1}+1)
    hold on
    plot(XYmean{m,2}-1,'k-')
    hold off
    legend('mean x +1','mean y -1')
    xlim([0 frames]);
    ylim([-2 2]);
    str2 = ['movie ',int2str(m)];
    xlabel(str2,'FontSize',15)
    
    subplot(3,2,3)
    plot(-lags:lags, acorrmean{m,1},'k-')
    ylim([-1.1 1.1])
    title('autocorrelation mean x','FontSize',15)
    str = ['chm = ',int2str(chm),'; lags = ',int2str(lags),'; number of spots = ',int2str(length(movies{m}))];
    xlabel(str,'FontSize',15)
    
    subplot(3,2,5)
    plot(-lags:lags,acorrmean{m,2},'k-')
    ylim([-1.1 1.1])
    title('autocorrelation mean y','FontSize',15)
    
    subplot(3,2,4)
    plot(f,P1mean{m,1})
    title('single-sided amplitude spectrum of x','FontSize',15)
    xlabel('f [Hz]','FontSize',15)
    
    subplot(3,2,6)
    plot(f,P1mean{m,2})
    title('single-sided amplitude spectrum of y','FontSize',15)
    xlabel('f [Hz]','FontSize',15)
    
    pause
end
%% PLOT single spots with mean to compare
figure
for m = 1:length(movies)  
    for i = 1:length(movies{m})
        subplot(3,4,1:4)
        plot((XY{m,1}(:,i)+1))
        hold on
        plot((XY{m,2}(:,i)-1),'k-')
        hold off
        legend('x coordinate +1','y coordinate -1')
        xlim([0 frames]);
        ylim([-2 2]);
        str1 = ['movie ',int2str(m),'; spot ',int2str(movies{m}(i))];
        xlabel(str1,'FontSize',15)

        subplot(3,4,5)
        plot(-lags:lags,acorr{m,1}(:,i),'k-')
        ylim([-1.1 1.1])
        title('autocorrelation x','FontSize',15)
        
        subplot(3,4,6)
        plot(-lags:lags,acorrmean{m,1},'k-')
        ylim([-1.1 1.1])
        title('autocorrelation mean x','FontSize',15)
        str = ['chm = ',int2str(chm),'; lags = ',int2str(lags),'; number of spots = ',int2str(length(movies{m}))];
        xlabel(str,'FontSize',15)
        
        limit1 = max(max(P1{m,1}(:,i)),max(P1mean{m,1}));
        subplot(3,4,7)
        plot(f,P1{m,1}(:,i))
        ylim([0 limit1*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of x','FontSize',15)
        
        subplot(3,4,8)
        plot(f,P1mean{m,1})
        ylim([0 limit1*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of mean x','FontSize',15)
        
        subplot(3,4,9)
        plot(-lags:lags,acorr{m,2}(:,i),'k-')
        ylim([-1.1 1.1])
        title('autocorrelation y','FontSize',15)
        
        subplot(3,4,10)
        plot(-lags:lags,acorrmean{m,2},'k-')
        ylim([-1.1 1.1])
        title('autocorrelation mean y','FontSize',15)
        
        limit2 = max(max(P1{m,2}(:,i)),max(P1mean{m,2}));
        subplot(3,4,11)
        plot(f,P1{m,2}(:,i))
        ylim([0 limit2*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of y','FontSize',15)
        
        subplot(3,4,12)
        plot(f,P1mean{m,2})
        ylim([0 limit2*1.05])
        xlabel('f [Hz]','FontSize',15)
        title('of mean y','FontSize',15)
        pause
    end
end

%% PLOT single interval parted spots with total spot to compare
figure
for m = 1:length(movies)  
    for i = 1:length(movies{m})
        j = 1;
        for p = 1:interval:frames
            subplot(3,4,1:4)
            plot((XY{m,1}(:,i)+1))
            hold on
            plot((XY{m,2}(:,i)-1),'k-')
            plot(p:p+interval-1,(XY{m,1}(p:p+interval-1,i)+1),'r-')
            plot(p:p+interval-1,(XY{m,2}(p:p+interval-1,i)-1),'r-')
            hold off
            legend('x coordinate +1','y coordinate -1','interval')
            xlim([0 frames]);
            ylim([-2 2]);
            str3 = ['movie ',int2str(m),'; spot ',int2str(movies{m}(i)),'; interval ',int2str(p),':',int2str(p+interval-1)];
            xlabel(str3,'FontSize',15)

            subplot(3,4,5)
            plot(-lags:lags,acorrparted{m,1}(:,i,j),'k-')
            ylim([-1.1 1.1])
            title('autocorrelation of part of x','FontSize',15)

            subplot(3,4,6)
            plot(-lags:lags,acorr{m,1}(:,i),'k-')
            ylim([-1.1 1.1])
            title('autocorrelation total x','FontSize',15)
            str4 = ['chm = ',int2str(chm),'; lags = ',int2str(lags)];
            xlabel(str4,'FontSize',15)

            limit3 = max(max(P1parted{m,1}(:,i,j)),max(P1{m,1}(:,i)));
            subplot(3,4,7)
            plot(fp,P1parted{m,1}(:,i,j))
            ylim([0 limit3*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of part of x','FontSize',15)

            subplot(3,4,8)
            plot(f,P1{m,1}(:,i))
            ylim([0 limit3*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of total x','FontSize',15)

            subplot(3,4,9)
            plot(-lags:lags,acorrparted{m,2}(:,i,j),'k-')
            ylim([-1.1 1.1])
            title('autocorrelation of part of y','FontSize',15)

            subplot(3,4,10)
            plot(-lags:lags,acorr{m,2}(:,i),'k-')
            ylim([-1.1 1.1])
            title('autocorrelation total y','FontSize',15)

            limit4 = max(max(P1{m,2}(:,i)),max(P1parted{m,2}(:,i,j)));
            subplot(3,4,11)
            plot(fp,P1parted{m,2}(:,i,j))
            ylim([0 limit4*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of part of y','FontSize',15)

            subplot(3,4,12)
            plot(f,P1{m,2}(:,i))
            ylim([0 limit4*1.05])
            xlabel('f [Hz]','FontSize',15)
            title('of total y','FontSize',15)
            j = j+1;
            pause
        end
    end
end
