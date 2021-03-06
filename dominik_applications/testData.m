function [ data, X ] = testData( varargin )
% testData: 
% frequency = (m x f)-matrix: m movies with f different frequencies
% factor has to be same size than frequency

p = inputParser;
addOptional(p, 'frequency', [5 3 0;4 3 2;2 2 1;1 0 0]);
addOptional(p, 'factor', [1.0 0.3 0.2;0.4 0.4 0.5;0.1 0.2 0.0;1.0 0.4 0.2]);
addOptional(p, 'frames', 27000, @isscalar);
addOptional(p, 'noise', false, @islogical);
addOptional(p, 'Fs', 10, @isscalar)

parse(p, varargin{:})
frequency = p.Results.frequency;
factor = p.Results.factor;
frames = p.Results.frames;
noise = p.Results.noise;
Fs = p.Results.Fs;
t = (0:frames-1).*(1/Fs);

data = cell(length(frequency),1);
fac = cell(length(frequency),1);
for m = 1:length(frequency)
    data{m} = cell(size(frequency,2)+1,2); % 1 = red, 2 = green
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
data{1}{end,2}.vwcm.disp100 = [data{1}{1,2}.vwcm.disp100(1:13500,:);data{1}{2,2}.vwcm.disp100(13501:27000,:)];
data{2}{end,2}.vwcm.disp100 = [data{2}{1,2}.vwcm.disp100(1:9000,:);data{2}{2,2}.vwcm.disp100(9001:18000,:);data{2}{3,2}.vwcm.disp100(18001:27000,:)];
data{3}{end,2}.vwcm.disp100 = [data{3}{1,2}.vwcm.disp100(1:6000,:);data{3}{2,2}.vwcm.disp100(6001:12000,:);data{3}{3,2}.vwcm.disp100(12001:18000,:);data{3}{2,2}.vwcm.disp100(18001:24000,:);data{3}{1,2}.vwcm.disp100(24001:27000,:)];
data{4}{end,2}.vwcm.disp100 = [data{4}{1,2}.vwcm.disp100(1:10000,:);data{4}{2,2}.vwcm.disp100(10001:20000,:);data{4}{3,2}.vwcm.disp100(20001:27000,:)];
end


