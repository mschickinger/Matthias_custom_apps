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
addOptional(p, 'N', 200, @isscalar)

parse(p, data, vector, varargin{:})
data = p.Results.data;
vector = p.Results.vector;
N = p.Results.N; % Fensterbreite (+1)

%% Rohdaten
m = vector(1);
s = vector(2);
itrace = data{m}{s,1}.itrace;
x = data{m}{s,1}.vwcm.disp100(:,1);
y = data{m}{s,1}.vwcm.disp100(:,2);

%% 
C = zeros(length(itrace)-N,2,2);
I_mean = zeros(length(itrace)-N,1);
I_median = zeros(length(itrace)-N,1);
for i = 1:(length(itrace)-N)
    C(i,:,:) = cov(x(i:i+N),y(i:i+N));
    I_mean(i) = mean(itrace(i:i+N));
    I_median(i) = median(itrace(i:i+N));
end

output.C = C;
output.I_mean = I_mean;
output.I_median = I_median;
output.N = N;

%%
D = zeros(floor(length(itrace)/N),2,2);
D_mean = zeros(length(D),1);
D_median = zeros(length(D),1);
for i = 1:length(D)
   D(i,:,:) = cov(x((i-1)*N+(1:N)),y((i-1)*N+(1:N)));
   D_mean(i) = mean(itrace((i-1)*N+(1:N)));
   D_median(i) = median(itrace((i-1)*N+(1:N)));
end

output.D = D;
output.D_mean = D_mean;
output.D_median = D_median;


end

