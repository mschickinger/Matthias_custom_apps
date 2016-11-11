function [output] = IntAndRMSD(data,vector,intervals)
%IntAndRMSD: Intensitaet und RMSD Werte von ausgesuchten traces

% input:    data, des Experiments
%           vector, der die ausgewaehlten traces angibt, mit [movie spot; movie spot; ...]
%           intervals, mit unterer und oberer Grenze und Abstand, also 
%           zB 5000:200:14000

% output:   struct mit folgenden Unterpunkten:
%           .interval   enthaelt die Intensitaets- und RMSD-Werte des Intervals
%                       sortiert nach Intensitaet
%           .median     enthaelt den Medianwert des jeweiligen Intervals
%           .minmax     enthaelt zwei Eintraege, oben min und unten max des
%                       jeweiligen Intervals
%           .iqr        enthaelt den Interquartilsabstand des jeweiligen
%                       Intervals, also den Abstand zweischen Q_25 und Q_75
%           .center     enthaelt die mittleren 95 Prozent der RMSD-Werte des
%                       jeweiligen Intervals
%           .midpoint   enthaelt den jeweiligen
%                       Intensitaetintervallmittelpunkt



%% parameters
chm = 1; % mobile channel: Rot
indices = cell(size(data)); % data aus data_spot_pairs
nFrames = cell(size(indices));
for m = 1:length(indices)
    indices{m} = [vector(vector(:,1)==m,2)]; % hier die spot indices fuer diesen Film angeben
    nFrames{m} = zeros(length(indices{m}),1);
    for s = 1:length(nFrames{m})
        %nFrames{m}(s) = min(floor(fit_cutoff{m,chm}(indices{m}(s))),length(data{m}{indices{m}(s),chm}.med_itrace));
        nFrames{m}(s) = length(data{m}{indices{m}(s),chm}.med_itrace);
    end % bin mir nicht sicher, ob das fuer deine Daten noetig ist... braucht man nur fuer traces, die nicht ueber die volle Laenge gehen.
end


%% arrays
all_ints = cell(size(indices));
all_rms10 = cell(size(indices));
counter = 0;
for m = 1:length(indices)
    all_ints{m} = zeros(sum(nFrames{m}),1);
    all_rms10{m} = zeros(sum(nFrames{m}),1);
    for s = 1:length(indices{m})
        all_ints{m}(counter+(1:nFrames{m}(s))) = data{m}{indices{m}(s),chm}.itrace(1:nFrames{m}(s));
        all_rms10{m}(counter+(1:nFrames{m}(s))) = data{m}{indices{m}(s),chm}.vwcm.rms10(1:nFrames{m}(s));
        counter = counter + nFrames{m}(s);
    end
end

%% intervals
intervals_comb = [];
for i = 1:length(all_ints)
    intervals_comb = [intervals_comb; all_ints{i} all_rms10{i}]; % 2 Spalten Vektor mit Intensitaets-(1) und RMSD-Werten(2)
end
intervals_comb = sortrows(intervals_comb,1); % nach Intensitaet sortiert
intervals_comb = intervals_comb(find(intervals_comb(:,1)>0):end,:); % alle Null-Eintraege werden wieder entfernt (keine Ahnung woher diese kommen)

output_intervals = cell(1,length(intervals)+1);
for i = 1 % erstes Intervall liegt links der ersten Grenze
    output_intervals{i} = intervals_comb(intervals_comb(:,1)<intervals(i),:);
end
for i = 2:length(intervals) % Intervalle nach den vorgegebenen Breiten
    output_intervals{i} = intervals_comb(intervals_comb(:,1)>intervals(i-1)&intervals_comb(:,1)<intervals(i),:);
end
for i = length(intervals)+1 % letztes Intervall liegt rechts von letzter Grenze; bei i Unterteilungen gibt es i+1 Intervalle!
    output_intervals{i} = intervals_comb(intervals_comb(:,1)>intervals(i-1),:);
end

%% median
output_median = cell(1,length(intervals)+1);
for i = 1:length(intervals)+1
    output_median{i} = median(output_intervals{i}(:,2));
end

%% Max and Min
output_minmax = cell(1,length(intervals)+1);
for i = 1:length(intervals)+1
    output_minmax{i} = [min(output_intervals{i}(:,2));max(output_intervals{i}(:,2))];
end

%% Interquartils-distance
output_iqr = cell(1,length(intervals)+1);
for i = 1:length(intervals)+1
    output_iqr{i} = iqr(output_intervals{i}(:,2));
end

%% center 95 percent
output_center = cell(1,length(intervals)+1);
for i = 1:length(intervals)+1
    if ~isempty(output_intervals{i})
        variable = []; % Hilfsvariable
        variable = output_intervals{i};
        variable = sortrows(variable,2); % das Intervall nach RMSD-Werten sortieren und nur 95 Prozent auswaehlen
        variable = variable(ceil(length(variable)*0.025):floor(length(variable)*0.975),:);   
        output_center{i} = sortrows(variable,1); % wieder nach Intensitaet sortieren
end

%% interval midpoint
output_midpoints = cell(1,length(intervals)+1);
output_midpoints{1} = [];
output_midpoints{end} = [];
abs = intervals(2)-intervals(1);
for i = 2:length(intervals)
    output_midpoints{i} = intervals(i)-abs*0.5; % Mittelpunkte nur von Intervall i+1 bis i-1, da sonst keine zweite Grenze vorhanden
end

%% output
output.intervals = output_intervals;
output.median = output_median;
output.minmax = output_minmax;
output.iqr = output_iqr;
output.center = output_center;
output.midpoints = output_midpoints;


end

