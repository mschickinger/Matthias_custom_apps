function [ autocorr ] = AutocorrIntervals( data, indices, chm, varargin )
% AutocorrData
%  
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
frames = length(data{1}{1,1}.itrace); % should be 27000

autocorr = cell(length(indices),1); % number of movies
    for m = 1:length(indices)
        tmp_x = zeros(frames,length(indices{m}));
        tmp_y = zeros(size(tmp_x));
        autocorr{m} = cell(length(indices{m}),1);
        for i = 1:length(indices{m})
            tmp_x(:,i) = data{m}{indices{m}(i),chm}.vwcm.disp100(:,1); % 1 = x
            tmp_y(:,i) = data{m}{indices{m}(i),chm}.vwcm.disp100(:,2); % 2 = y
            
            autocorr{m}{i}.spot_numb = indices{m}(i);
            autocorr{m}{i}.intervals = cell(length(1:interval:frames),1);
            
            j = 1;
            for p = 1:interval:frames
                autocorr{m}{i}.intervals{j}.frames = [p min(p+interval-1,frames)];
                autocorr{m}{i}.intervals{j}.acorr_x = xcorr(tmp_x(p:min(p+interval-1,frames),i),lags,'coeff');
                autocorr{m}{i}.intervals{j}.spectrum_x = singlesidedspectrum(tmp_x(p:min(p+interval-1,frames),i));
                autocorr{m}{i}.intervals{j}.acorr_y = xcorr(tmp_y(p:min(p+interval-1,frames),i),lags,'coeff');
                autocorr{m}{i}.intervals{j}.spectrum_y = singlesidedspectrum(tmp_y(p:min(p+interval-1,frames),i));
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
    