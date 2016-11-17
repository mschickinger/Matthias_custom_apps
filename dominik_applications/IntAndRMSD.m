function [output] = IntAndRMSD(data,vector)
%IntAndRMSD: Intensitaet und RMSD Werte von ausgesuchten traces

% input:    data        Daten des Experiments
%           vector      Ausgewaehlten traces angibt, mit [movie spot; movie spot; ...]

% output:   struct mit folgenden Unterpunkten:
%           .interval   enthaelt die Intensitaets- und RMSD-Werte des Intervalls
%                       sortiert nach Intensitaet
%           .median     enthaelt den Medianwert des jeweiligen Intervals
%           .minmax     enthaelt zwei Eintraege, oben min und unten max des
%                       jeweiligen Intervals
%           .iqr        enthaelt den Interquartilsabstand des jeweiligen
%                       Intervals, also den Abstand zweischen Q_25 und Q_75
%           .center     enthaelt die mittleren 95 Prozent der RMSD-Werte des
%                       jeweiligen Intervals
%           .midpoint   enthaelt den jeweiligen
%                       Intensitaetintervallmittelpunkte

%% parameters
chm = 1; % mobile channel: Rot
indices = cell(size(data)); % data aus data_spot_pairs
nFrames = cell(size(indices));
for m = 1:length(indices)
    indices{m} = vector(vector(:,1)==m,2); % hier die spot indices fuer diesen Film angeben
    nFrames{m} = zeros(length(indices{m}),1);
    for s = 1:length(nFrames{m})
        %nFrames{m}(s) = min(floor(fit_cutoff{m,chm}(indices{m}(s))),length(data{m}{indices{m}(s),chm}.med_itrace));
        nFrames{m}(s) = length(data{m}{indices{m}(s),chm}.med_itrace);
    end % bin mir nicht sicher, ob das fuer deine Daten noetig ist... braucht man nur fuer traces, die nicht ueber die volle Laenge gehen.
end

%% arrays
%all_ints = cell(size(indices)); % obsolet, aber lassen wir es mal kommentiert drin...
%all_rms10 = cell(size(indices));
intervals_comb = zeros(sum(vertcat(nFrames{:}),2)); % MS: So zum Beispiel.
counter = 0;
for m = 1:length(indices)
    %all_ints{m} = zeros(sum(nFrames{m}),1); % obsolet, aber lassen wir es mal kommentiert drin...
    %all_rms10{m} = zeros(sum(nFrames{m}),1);
    for s = 1:length(indices{m})
        %all_ints{m}(counter+(1:nFrames{m}(s))) = data{m}{indices{m}(s),chm}.itrace(1:nFrames{m}(s));
        %all_rms10{m}(counter+(1:nFrames{m}(s))) = data{m}{indices{m}(s),chm}.vwcm.rms10(1:nFrames{m}(s));
        intervals_comb(counter+(1:nFrames{m}(s)),:) = [data{m}{indices{m}(s),chm}.itrace(1:nFrames{m}(s)) ...
            data{m}{indices{m}(s),chm}.vwcm.rms10(1:nFrames{m}(s))];
        counter = counter + nFrames{m}(s);
    end
end
intervals_comb = intervals_comb(intervals_comb(:,1)>0,:); % alle Null-Eintraege werden wieder entfernt (keine Ahnung woher diese kommen)

%% intervals
midpoints = 5100:200:13900; % 45 Mittelpunkte entsprechen 45 Intervallen
output_intervals = cell(1,length(midpoints));
for i = 1:length(midpoints) % z.B.: Intervall 1 entspricht 5000 bis 5199
    output_intervals{i} = intervals_comb(intervals_comb(:,1) >= (midpoints(i)-100) & intervals_comb(:,1) <= (midpoints(i)+99),:);
end

%% Output struct
output = struct('midpoints', midpoints, 'intervals', intervals, ...
    'median', zeros(1,length(midpoints)), ...
    'minmax', zeros(2,length(midpoints)), ...
    'iqr', zeros(1,length(midpoints)),...
    'center95', zeros(2,length(midpoints)));

%% Median, Min und Max, Interquartils-distance

for i = 1:length(output.midpoints)
    output.median(i) = median(output_intervals{i}(:,2)); % median
    output.minmax(:,i) = [min(output_intervals{i}(:,2));max(output_intervals{i}(:,2))]; % minimum und maximum
    output.iqr(i) = iqr(output_intervals{i}(:,2)); % interquartils-Abstand
    output.center95(:,i) = [prctile(output_intervals{i}(:,2),97.5);prctile(output_intervals{i}(:,2),2.5)]; % zentrale 95 Prozent der RMSD-Werte, obere und untere Grenze
end


end

