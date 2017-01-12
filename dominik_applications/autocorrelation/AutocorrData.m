function [ autocorr ] = AutocorrData( data, indices, chm, varargin )
% AutocorrData:

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

autocorr = cell(length(indices),1); % number of movies
    for m = 1:length(indices)
        frames = 2*floor(length(data{m}{1,1}.itrace)/2); % should be 27000
        tmp_x = zeros(frames,length(indices{m}));
        tmp_y = zeros(size(tmp_x));
        autocorr{m}.spots = cell(length(indices{m}),1);
        for s = 1:length(indices{m})
            tmp_x(:,s) = data{m}{indices{m}(s),chm}.vwcm.disp100(1:frames,1); % 1 = x
            tmp_y(:,s) = data{m}{indices{m}(s),chm}.vwcm.disp100(1:frames,2); % 2 = y

            autocorr{m}.spots{s}.spot_numb = indices{m}(s);
            autocorr{m}.spots{s}.pos_x = tmp_x(:,s);
            autocorr{m}.spots{s}.acorr_x = xcorr(tmp_x(:,s),lags,'coeff');
            autocorr{m}.spots{s}.spectrum_x = singlesidedspectrum(tmp_x(:,s));
            autocorr{m}.spots{s}.pos_y = tmp_y(:,s);
            autocorr{m}.spots{s}.acorr_y = xcorr(tmp_y(:,s),lags,'coeff');
            autocorr{m}.spots{s}.spectrum_y = singlesidedspectrum(tmp_y(:,s));
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
    
