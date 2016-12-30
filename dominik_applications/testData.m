function [ data, X ] = testData( frequency, varargin )
% testData: 

p = inputParser;
addRequired(p, 'frequency');
addOptional(p, 'frames', 27000, @isscalar);
addOptional(p, 'noise', false, @islogical);

parse(p, frequency, varargin{:})
frequency = p.Results.frequency;
frames = p.Results.frames;
noise = p.Results.noise;
Fs = 27000;
t = (0:frames-1).*(1/Fs);
data = cell(1);
data{1} = cell(1,2); % 1 = red, 2 = green
for c = 1:2
    data{1}{1,c}.itrace = zeros(frames,1); % AutocorrData.m use the length of this struct to get number of frames
    data{1}{1,c}.vwcm.disp100 = zeros(frames,2); % 1 = x, 2 = y
    S = zeros(length(t),1);
    factor = 1;
    for f = 1:length(frequency)
        S = S + factor.*0.5.*sin(2*pi*t*frequency(f))';
        factor = factor - min(0.1*f,0.9);
    end
    if noise==1
        X = S + 2*randn(length(t),1);
        data{1}{1,c}.vwcm.disp100(:,1) = X;
        data{1}{1,c}.vwcm.disp100(:,2) = X;
    else
        X = S;
        data{1}{1,c}.vwcm.disp100(:,1) = S;
        data{1}{1,c}.vwcm.disp100(:,2) = S;
    end
end

