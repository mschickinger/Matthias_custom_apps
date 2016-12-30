function [ data, X ] = testData( frequency, factor, varargin )
% testData: 
% frequency = (m x f)-matrix: m movies with f different frequencies
% factor has to be same size than frequency

p = inputParser;
addRequired(p, 'frequency');
addRequired(p, 'factor');
addOptional(p, 'frames', 27000, @isscalar);
addOptional(p, 'noise', false, @islogical);
addOptional(p, 'Fs', 10, @isscalar)

parse(p, frequency, factor, varargin{:})
frequency = p.Results.frequency;
factor = p.Results.factor;
frames = p.Results.frames;
noise = p.Results.noise;
Fs = p.Results.Fs;
t = (0:frames-1).*(1/Fs);

data = cell(length(frequency),1);
fac = cell(length(frequency),1);
for m = 1:length(frequency)
    data{m} = cell(size(frequency,2),2); % 1 = red, 2 = green
    data{m}{1,1}.itrace = zeros(frames,1); % AutocorrData.m use the length of this struct to get number of frames
    fac{m} = perms(factor(m,:));
    for s = 1:size(frequency,2)
        S = zeros(frames,1);
        for p = 1:size(frequency,2)
            S = S + fac{m}(s,p).*sin(2*pi*t*frequency(m,p))';
        end
        if noise==1
            X = S + 2.*randn(frames,1);
            data{m}{s,2}.vwcm.disp100(:,1) = X;
            data{m}{s,2}.vwcm.disp100(:,2) = flipud(X); % no symmetrie
        else
            X = S;
            data{m}{s,2}.vwcm.disp100(:,1) = S;
            data{m}{s,2}.vwcm.disp100(:,2) = flipud(S); % no symmetrie
        end
    end
end

