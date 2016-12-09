function [ output ] = IntAndFriends( data, vector, varargin )
% IntAndFriends:
%{
data        = 
vector      =

C           =
I_mean      =
I_median    =
%}

p = inputParser;
addRequired(p, 'rohdaten')
addRequired(p, 'vector')

parse(p, data, vector, varargin{:})
data = p.Results.data;
vector = p.Results.vector;

%% Rohdaten
m = vector(1);
s = vector(2);
itrace = data{m}{s,1}.itrace;
x = data{m}{s,1}.vwcm.pos(:,1);
y = data{m}{s,1}.vwcm.pos(:,2);
N = 200; % Fensterbreite

%% 
for i = 1:(length(itrace)-N)
    C(i,:,:) = cov(x(i:i+N),y(i:i+N));
    I_mean(i) = mean(itrace(i:i+N));
    I_median(i) = median(itrace(i:i+N));
end


end

