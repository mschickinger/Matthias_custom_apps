function [ autokorr ] = AutoKorrData( AutocorrData, varargin )
% AutoKorrData: to correct Data by add pos and -mean_pos 

p = inputParser;
addRequired(p, 'AutocorrData')

parse(p, AutocorrData, varargin{:})
AutocorrData = p.Results.AutocorrData;
lags = (length(AutocorrData{1}.acorr_mean_x)-1)/2;

autokorr = AutocorrData;

    for m = 1:length(AutocorrData)
        xKorr = AutocorrData{m}.pos_mean_x;
        yKorr = AutocorrData{m}.pos_mean_y;
        for s = 1:length(AutocorrData{m}.spots)
            tmp_x = AutocorrData{m}.spots{s}.pos_x - xKorr(1:length(AutocorrData{m}.spots{s}.pos_x));
            autokorr{m}.spots{s}.pos_x = tmp_x;
            autokorr{m}.spots{s}.acorr_x = xcorr(tmp_x,lags,'coeff');
            autokorr{m}.spots{s}.spectrum_x = singlesidedspectrum(tmp_x);

            tmp_y = AutocorrData{m}.spots{s}.pos_y - yKorr(1:length(AutocorrData{m}.spots{s}.pos_y));
            autokorr{m}.spots{s}.pos_y = tmp_y;        
            autokorr{m}.spots{s}.acorr_y = xcorr(tmp_y,lags,'coeff');
            autokorr{m}.spots{s}.spectrum_y = singlesidedspectrum(tmp_y);
        end
    end
    function P1 = singlesidedspectrum(position)
        FFT = fft(position);
        P2 = abs(FFT./length(position));
        P1 = P2(1:(length(position)/2+1));
        P1(2:end-1) = 2.*P1(2:end-1);        
    end
end