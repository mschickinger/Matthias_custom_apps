function [ autocorr ] = AutocorrData( data, indices, chm, varargin )
% AutocorrData
%  
p = inputParser;
addRequired(p, 'data')
addRequired(p, 'indices')
addRequired(p, 'chm') % 1 = red; 2 = green;
addOptional(p, 'lags', 200, @isscalar)

parse(p, data, indices, chm, varargin{:})
data = p.Results.data;
indices = p.Results.indices; % form of cell for movies including vector of spot numbers
chm = p.Results.chm;
lags = p.Results.lags;
frames = length(data{1}{1,1}.itrace); % should be 27000

autocorr = cell(length(indices),1); % number of movies
    for m = 1:length(indices)
        tmp_x = zeros(frames,length(indices{m}));
        tmp_y = zeros(size(tmp_x));
        autocorr{m}.spots = cell(length(indices{m}),1);
        for i = 1:length(indices{m})
            tmp_x(:,i) = data{m}{indices{m}(i),chm}.vwcm.disp100(:,1); % 1 = x
            tmp_y(:,i) = data{m}{indices{m}(i),chm}.vwcm.disp100(:,2); % 2 = y

            autocorr{m}.spots{i}.spot_numb = indices{m}(i);
            autocorr{m}.spots{i}.pos_x = tmp_x(:,i);
            autocorr{m}.spots{i}.acorr_x = xcorr(tmp_x(:,i),lags,'coeff');
            autocorr{m}.spots{i}.spectrum_x = singlesidedspectrum(tmp_x(:,i));
            autocorr{m}.spots{i}.pos_y = tmp_y(:,i);
            autocorr{m}.spots{i}.acorr_y = xcorr(tmp_y(:,i),lags,'coeff');
            autocorr{m}.spots{i}.spectrum_y = singlesidedspectrum(tmp_y(:,i));
        end
        autocorr{m}.pos_mean_x = mean(tmp_x,2);
        autocorr{m}.acorr_mean_x = xcorr(autocorr{m}.pos_mean_x,lags,'coeff');
        autocorr{m}.spectrum_mean_x = singlesidedspectrum(autocorr{m}.pos_mean_x);
        autocorr{m}.pos_mean_y = mean(tmp_y,2);
        autocorr{m}.acorr_mean_y = xcorr(autocorr{m}.pos_mean_y,lags,'coeff');
        autocorr{m}.spectrum_mean_y = singlesidedspectrum(autocorr{m}.pos_mean_y);    
    end
    function P1 = singlesidedspectrum(position)
        FFT = fft(position);
        P2 = abs(FFT./length(position));
        P1 = P2(1:(length(position)/2+1));
        P1(2:end-1) = 2.*P1(2:end-1);        
    end
end
    
