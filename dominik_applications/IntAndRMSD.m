function [output] = IntAndRMSD(data, vector, varargin)
%IntAndRMSD: Intensitaet und RMSD Werte von ausgesuchten traces

%{
% input:    data            Daten des Experiments
%           vector          Ausgewaehlten traces angibt, mit [movie spot; movie spot; ...]
                            'all' gibt alle Spots des Datensatzes aus
            fit_cutoff      Maximaler frame bei der Positionsbestimmung am Cluster
            midpoint_range  Spannweite der Intervallmittelpunkte
                            Default:    Intervallmittelpunkte werden auf alle
                                        Punkte des Datensatzes angepasst
            chm             Index des "mobilen Kanals" (Standard ist 1 bzw. Rot)

% output:   struct mit folgenden Unterpunkten:
%           .interval       enthaelt die Intensitaets- und RMSD-Werte des Intervalls
%                           sortiert nach Intensitaet
%           .median         enthaelt den Medianwert des jeweiligen Intervals
%           .minmax         enthaelt zwei Eintraege, oben min und unten max des
%                           jeweiligen Intervals
%           .iqr            enthaelt den Interquartilsabstand des jeweiligen
%                           Intervals, also den Abstand zweischen Q_25 und Q_75
%           .center         enthaelt die mittleren 95 Prozent der RMSD-Werte des
%                           jeweiligen Intervals
%           .midpoint       enthaelt den jeweiligen
%                           Intensitaetintervallmittelpunkte
%}

p = inputParser;
addRequired(p, 'data')
addRequired(p, 'vector')
addOptional(p, 'fit_cutoff', [])
addOptional(p, 'midpoint_range', [])
addParameter(p, 'chm', 1)

parse(p, data, vector, varargin{:})
data = p.Results.data;
vector = p.Results.vector;
fit_cutoff = p.Results.fit_cutoff;
midpoint_range = p.Results.midpoint_range;
chm = p.Results.chm;

%% vector
if strcmp(vector,'all') 
    vector = zeros(size(vertcat(data{:})));
    counter = 1;
    for m = 1:size(data,1) 
        for i = 1:size(data{m},1)
            vector(counter,:) = [m i];
            counter = counter+1;
        end
    end
end

%% parameters
indices = cell(size(data)); % data aus data_spot_pairs
nFrames = cell(size(indices));
for m = 1:length(indices)
    indices{m} = vector(vector(:,1)==m,2); % hier die spot indices fuer diesen Film angeben
    nFrames{m} = zeros(length(indices{m}),1);
    for s = 1:length(nFrames{m})
        if ~isempty(fit_cutoff)
            nFrames{m}(s) = min(floor(fit_cutoff{m,chm}(indices{m}(s))),length(data{m}{indices{m}(s),chm}.itrace));
        else
            nFrames{m}(s) = length(data{m}{indices{m}(s),chm}.itrace);
        end
    end
end

%% arrays
%all_ints = cell(size(indices));
%all_rms10 = cell(size(indices));
counter = 0;
intervals_comb = zeros(sum(vertcat(nFrames{:})),2); % So z.B.
for m = 1:length(indices)
    %all_ints{m} = zeros(sum(nFrames{m}),1);
    %all_rms10{m} = zeros(sum(nFrames{m}),1);
    for s = 1:length(indices{m})
        %all_ints{m}(counter+(1:nFrames{m}(s))) = data{m}{indices{m}(s),chm}.itrace(1:nFrames{m}(s));
        %all_rms10{m}(counter+(1:nFrames{m}(s))) = data{m}{indices{m}(s),chm}.vwcm.rms10(1:nFrames{m}(s));
        intervals_comb(counter+(1:nFrames{m}(s)),:) = ...
            [data{m}{indices{m}(s),chm}.itrace(1:nFrames{m}(s)) ...
            data{m}{indices{m}(s),chm}.vwcm.rms10(1:nFrames{m}(s))];
        counter = counter + nFrames{m}(s);
    end
end
intervals_comb = intervals_comb(prod(intervals_comb,2)>0,:); % alle Null-Eintraege werden wieder entfernt (keine Ahnung woher diese kommen)

%% intervals

if isempty(midpoint_range) % default
    range_min = round((min(intervals_comb(:,1))-100)/200)*200+100;
    range_max = round((max(intervals_comb(:,1))+100)/200)*200+100;
else
    midpoint_range = sort(midpoint_range); % set range in form: [low_limit; high_limit]
    range_min = round((midpoint_range(1)-100)/200)*200+100;
    range_max = round((midpoint_range(2)+100)/200)*200+100;
end  
midpoints = range_min:200:range_max; % could lead to very high range_max for bad traces !?

output_intervals = cell(1,length(midpoints));
for i = 1:length(midpoints) % z.B.: Intervall 1 entspricht 5000 bis 5199
    output_intervals{i} = intervals_comb(intervals_comb(:,1) >= (midpoints(i)-100) & intervals_comb(:,1) <= (midpoints(i)+99),:);
end
go_on = 1;
j = 0;
k = length(midpoints)+1;
while go_on==1
    j = j+1;
    go_on = length(output_intervals{j})<=10;
end
go_on = 1;
while go_on==1
    k = k-1;
    go_on = length(output_intervals{k})<=10;
end
midpoints = midpoints(j:k);
output.midpoints = midpoints;
output.intervals = output_intervals(j:k);

%% Median, Min und Max, Interquartils-distance
output.median = zeros(1,length(midpoints));
output.minmax = zeros(2,length(midpoints));
output.iqr = zeros(1,length(midpoints));
output.center95 = zeros(2,length(midpoints));
output.percentile99 = zeros(1,length(midpoints));
output.percentile1 = zeros(1,length(midpoints));
for i = 1:length(midpoints)
    output.median(i) = median(output_intervals{i}(:,2)); % median
    if ~isempty(output_intervals{i})
        output.minmax(:,i) = [min(output_intervals{i}(:,2));max(output_intervals{i}(:,2))]; % minimum und maximum
    end
    output.iqr(i) = iqr(output_intervals{i}(:,2)); % interquartils-Abstand
    output.center95(:,i) = [prctile(output_intervals{i}(:,2),97.5);prctile(output_intervals{i}(:,2),2.5)]; % zentrale 95 Prozent der RMSD-Werte, obere und untere Grenze
    output.percentile99(i) = prctile(output_intervals{i}(:,2),99);
    output.percentile1(i) = prctile(output_intervals{i}(:,2),1);
end

end

