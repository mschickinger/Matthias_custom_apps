function [ output ] = IntAndFriends( data, vector, varargin )
% IntAndFriends:
%{
data        = 
vector      =

C           =
I_mean      =
I_median    =
midpoints   = 

%}

p = inputParser;
addRequired(p, 'data')
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
C = zeros(length(itrace)-N,2,2);
I_mean = zeros(length(itrace)-N,1);
I_median = zeros(length(itrace)-N,1);
midpoints = zeros(length(itrace)-N,1);
for i = 1:(length(itrace)-N)
    C(i,:,:) = cov(x(i:i+N-1),y(i:i+N-1));
    I_mean(i) = mean(itrace(i:i+N-1));
    I_median(i) = median(itrace(i:i+N-1));
    midpoints(i) = i+N/2-1;
end

output.C = C;
output.I_mean = I_mean;
output.I_median = I_median;
output.midpoints = midpoints;


end

