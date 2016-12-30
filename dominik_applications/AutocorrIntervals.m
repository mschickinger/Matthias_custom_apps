function [ autocorr ] = AutocorrIntervals( data, indices, chm, varargin )
% AutocorrIntervals:

p = inputParser;
addRequired(p, 'data')
addRequired(p, 'indices')
addRequired(p, 'chm') % 1 = red; 2 = green;
addOptional(p, 'lags', 200, @isscalar)
addOptional(p, 'interval', 3000, @isscalar)

parse(p, data, indices, chm, varargin{:})
data = p.Results.data;
indices = p.Results.indices; % form of cell for movies including vector of spot numbers
chm = p.Results.chm;
lags = p.Results.lags;
interval = p.Results.interval;

autocorr = cell(length(indices),1); % number of movies
    for m = 1:length(indices)
        frames = 2*floor(length(data{m}{1,1}.itrace)/2); % should be 27000
        tmp_x = zeros(frames,length(indices{m}));
        tmp_y = zeros(size(tmp_x));
        autocorr{m} = cell(length(indices{m}),1);
        for s = 1:length(indices{m})
            tmp_x(:,s) = data{m}{indices{m}(s),chm}.vwcm.disp100(:,1); % 1 = x
            tmp_y(:,s) = data{m}{indices{m}(s),chm}.vwcm.disp100(:,2); % 2 = y
            
            autocorr{m}{s}.spot_numb = indices{m}(s);
            autocorr{m}{s}.intervals = cell(length(1:interval:frames),1);
            
            j = 1;
            for p = 1:interval:frames
                autocorr{m}{s}.intervals{j}.frames = [p min(p+interval-1,frames)];
                autocorr{m}{s}.intervals{j}.acorr_x = xcorr(tmp_x(p:min(p+interval-1,frames),s),lags,'coeff');
                autocorr{m}{s}.intervals{j}.spectrum_x = singlesidedspectrum(tmp_x(p:min(p+interval-1,frames),s));
                autocorr{m}{s}.intervals{j}.acorr_y = xcorr(tmp_y(p:min(p+interval-1,frames),s),lags,'coeff');
                autocorr{m}{s}.intervals{j}.spectrum_y = singlesidedspectrum(tmp_y(p:min(p+interval-1,frames),s));
                j = j+1;
            end
        end
    end
    function P1 = singlesidedspectrum(position)
        FFT = fft(position);
        P2 = abs(FFT./length(position));
        P1 = P2(1:(length(position)/2+1));
        P1(2:end-1) = 2.*P1(2:end-1);        
    end
end
    