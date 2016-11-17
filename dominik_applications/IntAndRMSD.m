function [output] = IntAndRMSD(data,vector)
%IntAndRMSD: Intensitaet und RMSD Werte von ausgesuchten traces

% input:    data        Daten des Experiments
%           vector      Ausgewaehlten traces angibt, mit [movie spot; movie spot; ...]

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
    indices{m} = vector(vector(:,1)==m,2); % hier die spot indices fuer diesen Film angeben
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
intervals_comb = sortrows(intervals_comb,1); % nach Intensitaet sortiert; MS: Dieser Sortierschritt ist unnoetig.
% Ueberhaupt kannst du diesen Teil schon durch umschreiben der vorherigen
% section erledigen. die all_ints und all_rms10 werden spaeter ja eh nicht
% mehr verwendet, oder?

intervals_comb = intervals_comb(intervals_comb(:,1)>0,:); % alle Null-Eintraege werden wieder entfernt (keine Ahnung woher diese kommen)

%MS: Ich haette das gern so, dass am Rand abgeschnitten wird, also wirklich
%nur die Punkte mitgenommen werden, die in einem der vorgegebenen
%Intervalle liegen. Ausserdem: Was passiert hier mit den Werten, die genau
%auf einer Intervallgrenze liegen?

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

%MS: probier doch mal aus, um welchen Faktor sich die Rechenzeit
%reduziert, wenn du die folgenden drei oder vier for-Schleifen zu einer
%Schleife kombinierst. Das geht z.B. mit tic und toc
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
% MS: Hier hatte ich mich evtl. unklar ausgedrueckt. Es reichen mir die
% obere und untere Grenze des 95%-Intervalls, also diese ceil-/floor-Werte.
% Sollte aber auch mit dem Befehl prctile gehen, oder?

output_center = cell(1,length(intervals)+1);
for i = 1:length(intervals)+1
    if ~isempty(output_intervals{i})
        variable = []; % Hilfsvariable
        variable = output_intervals{i};
        variable = sortrows(variable,2); % das Intervall nach RMSD-Werten sortieren und nur 95 Prozent auswaehlen
        %MS: Gute Idee mit der Hilfsvariable, aber aus den vorherigen drei Schritten kannst du einen einzigen
        %machen. Und es empfiehlt sich, solche Hilfsvariablen mit "tmp" zu
        %benennen. Dann ist gleich klar, dass es nur eine 'Zwischenablage' ist.
        variable = variable(ceil(length(variable)*0.025):floor(length(variable)*0.975),:);   
        output_center{i} = sortrows(variable,1); % wieder nach Intensitaet sortieren; MS: sind sie das nicht schon?!
    end
end

%% interval midpoint
output_midpoints = cell(1,length(intervals)+1); %MS: Fuer einfache Zahlenwerte brauchst du kein cell array, da tut es auch ein normales array.
output_midpoints{1} = [];
output_midpoints{end} = [];
abs = intervals(2)-intervals(1); %MS: Achtung mit abs, das gibt es schon als Befehl in Matlab (absolute value).
%Hier wuerde auch 'delta' passen. Oder 'width'/'w'/'hw'. Und wenn du es gleich
%halbierst, dann musst du das nicht in jeder Schleifeniteration tun. Wobei
%es eh auch ohne Schleife geht, wenn du ein normales array benutzt.
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

