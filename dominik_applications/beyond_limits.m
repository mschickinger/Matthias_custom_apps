function [ output ] = beyond_limits( itrace,rms,midpoints,limits,varargin )
% beyond_limits: this function finds RMSD values over or under defined
% limits in a trace an outputs the frame number
%{

input. minmax = [min; max]
%}

p = inputParser;
addRequired(p, 'itrace')
addRequired(p, 'rms')
addRequired(p, 'midpoints')
addRequired(p, 'limits')

parse(p,itrace,rms,midpoints,limits, varargin{:})
itrace = p.Results.itrace;
rms = p.Results.rms;
midpoints = p.Results.midpoints;
limits = p.Results.limits;

%% maximum and minimum
minimum = limits(1,:);
%minimum = limits(1,:)*0.95; % in the first email of tasks (10.11.2016)
%were this factors mentioned; but i think we don't need them
maximum = limits(2,:);
%maximum = limits(2,:)*1.05;
    
%% traces
nFrames = length(itrace);
output_over = zeros(nFrames,1);
output_under = zeros(nFrames,1);
output_overdensity = zeros(nFrames,1);
output_underdensity = zeros(nFrames,1);
delta = 0.5*(midpoints(2)-midpoints(1));
tic
for i = 1:length(midpoints) % this deltas (100 and 99) implies that each interval has width 200 frames
    %output_over = output_over + (itrace >= (midpoints(i)-100) & itrace <= (midpoints(i)+99) & rms > maximum);
    output_over = output_over + (itrace >= (midpoints(i)-delta) & itrace < (midpoints(i)+delta) & rms > maximum); %fehler: maximum ist vektor!
    toc
    %output_under = output_under + (itrace >= (midpoints(i)-100) & itrace <= (midpoints(i)+99) & rms < minimum);
    output_under = output_under + (itrace >= (midpoints(i)-delta) & itrace < (midpoints(i)+delta) & rms < minimum);
    toc
    disp(i)
end
over = find(output_over==1);
under = find(output_under==1);

if sum(output_over)>0
    for i = 1:length(over) %fehler bei over = {4}...
        output_overdensity((over(i)-5):(over(i)+5)) = output_overdensity((over(i)-5):(over(i)+5)) + 1;
    end
end
if sum(output_under)>0
    for i = 1:length(output_under==1)
        output_underdensity((under(i)-5):(under(i)+5)) = output_underdensity((under(i)-5):(under(i)+5)) + 1;
    end
end

%% output
output.over = over;
output.under = under;
output.overdensity = output_overdensity;
output.underdensity = output_underdensity;

end

