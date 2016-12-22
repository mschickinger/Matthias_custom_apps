data = data_E4zero;
movie = traces_E4zero;
chm = 2; % 1 = red; 2 = green;
lags = 200;
frames = 27000;
acorr = cell(length(movie),2); % always first column x and second column y
acorrmean = cell(length(movie),2);
XY = cell(length(movie),2);

Fs = 1000; % fft example from help
T = 1/Fs;
L = frames;
t = (0:L-1)*T;
FFT = cell(length(movie),2);
P1 = cell(length(movie),2);
P2 = cell(length(movie),2);
tmp = cell(2,1);
for c = 1:2
    for m = 1:length(movie)
        tmp{c} = zeros(frames,length(movie{m}));
        for i = 1:length(movie{m})
            acorr{m,c}{i} = xcorr(data{m}{movie{m}(i),chm}.vwcm.disp100(:,c),lags,'coeff');
            tmp{c}(:,i) = data{m}{movie{m}(i),chm}.vwcm.disp100(:,c);
        end
        tmp{c} = mean(tmp{c},2);
        acorrmean{m,c} = xcorr(tmp{c},lags,'coeff');
        XY{m,c} = tmp{c};

        FFT{m,c} = fft(XY{m,c});
        P2{m,c} = abs(FFT{m,c}/L);
        P1{m,c} = P2{m,c}(1:(L/2+1));
        P1{m,c}(2:end-1) = 2*P1{m,c}(2:end-1);
        f = Fs*(0:(L/2))/L;
    end
end
%% PLOT
figure
for m = 1:length(movie)
    subplot(2,2,1)
    plot(acorrmean{m,1},'k-')
    ylim([-1.1 1.1])
    xlim([0 2*lags])
    title('x','FontSize',15)
    str = ['chm = ',int2str(chm),'; lags = ',int2str(lags),'; number of spots = ',int2str(length(movie{m}))];
    xlabel(str,'FontSize',15)
    subplot(2,2,3)
    plot(acorrmean{m,2},'k-')
    ylim([-1.1 1.1])
    xlim([0 2*lags])
    title('y','FontSize',15)
    
    subplot(2,2,2)
    plot(f,P1{m,1})
    xlabel('f [Hz]','FontSize',15)
    title('of x','FontSize',15)
    subplot(2,2,4)
    plot(f,P1{m,2})
    xlabel('f [Hz]','FontSize',15)
    title('of y','FontSize',15)
    
    pause
end

