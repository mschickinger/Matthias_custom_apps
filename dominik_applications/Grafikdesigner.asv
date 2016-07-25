%best of E1
traces_E1{1} = [11 14 2 20 22 35 37 42 48 50 51 52 53 7];
traces_E1{2} = [15 21 31 34 38 45];
traces_E1{3} = [14 19 26 27 35 37 43 44 56 60];
traces_E1{4} = [13 20 30 35 38 40 43 45 48 55 56 9];

for m = 1:4
    for s = 1:size(traces_E1{m},2)
        E1{m}{s}.itracered = data{m}{traces_E1{m}(s),1}.itrace;
        E1{m}{s}.itracegreen = data{m}{traces_E1{m}(s),2}.itrace;
        E1{m}{s}.rms10 = data{m}{traces_E1{m}(s),1}.vwcm.rms10;
    
        [f_E1{m}{s},xi_E1{m}{s}] = ksdensity(E1{m}{s}.rms10,'Kernel','box');
    end
end


%%
%best of E1/E2zero_1
traces_E1E2zero_1{1} = [17 25 27 38 43 44 48 49 51 58];
traces_E1E2zero_1{2} = [13 19 22 27 36 41 9];
traces_E1E2zero_1{3} = [11 12 13 25 28 33 34 37 38];
traces_E1E2zero_1{4} = [10 12 13 14 15 17 2 21 23 26 28 29 32 33 35 4 5 6 7 8];
traces_E1E2zero_1{5} = [10 11 12 14 15 17 19 20 25 26 27 3 31 32 33 5 6 8 9];
traces_E1E2zero_1{6} = [1 11 12 13 15 16 17 2 21 23 28 29 3 32 33 34 35 38 40 45 7];
traces_E1E2zero_1{7} = [10 13 18 19 2 22 23 26 3 5 8 9];
traces_E1E2zero_1{8} = [4 8];

for m = 1:8
    for s = 1:size(traces_E1E2zero_1{m},2)
        E1E2zero_1{m}{s}.itracered = data{m}{traces_E1E2zero_1{m}(s),1}.itrace;
        E1E2zero_1{m}{s}.itracegreen = data{m}{traces_E1E2zero_1{m}(s),2}.itrace;
        E1E2zero_1{m}{s}.rms10 = data{m}{traces_E1E2zero_1{m}(s),1}.vwcm.rms10;
    
        [f_E1E2zero_1{m}{s},xi_E1E2zero_1{m}{s}] = ksdensity(E1E2zero_1{m}{s}.rms10,'Kernel','box');
    end
end


%%
%best of E1/E2zero_2
traces_E1E2zero_2{1} = [10 12 14 15 17 4 40 46 47 5 54];
traces_E1E2zero_2{2} = [1 11 12 13 15 24 3 30 33 36 6 8];
traces_E1E2zero_2{3} = [12 13 20 21 5 51 6 7 8];
traces_E1E2zero_2{4} = [12 2 23 3 4];
traces_E1E2zero_2{5} = [1 12 13 14 19 2 27 4 41 42 47 5 6 9];
traces_E1E2zero_2{6} = [11 15 32 34 36 39 4 6 7 8 9];

for m = 1:6
    for s = 1:size(traces_E1E2zero_2{m},2)
        E1E2zero_2{m}{s}.itracered = data{m}{traces_E1E2zero_2{m}(s),1}.itrace;
        E1E2zero_2{m}{s}.itracegreen = data{m}{traces_E1E2zero_2{m}(s),2}.itrace;
        E1E2zero_2{m}{s}.rms10 = data{m}{traces_E1E2zero_2{m}(s),1}.vwcm.rms10;
    
        [f_E1E2zero_2{m}{s},xi_E1E2zero_2{m}{s}] = ksdensity(E1E2zero_2{m}{s}.rms10,'Kernel','box');
    end
end
   

%% 
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_fxi_E1E2zero_1 = [];
all_fxi_E1E2zero_2 = [];
all_fxi_E1E2zero = [];
for m = 1:8
    for s = 1:size(traces_E1E2zero_1{m},2)
        all_fxi_E1E2zero_1 = [all_fxi_E1E2zero_1; [f_E1E2zero_1{m}{s}(:),xi_E1E2zero_1{m}{s}(:)]];
    end
end
for m = 1:6
    for s = 1:size(traces_E1E2zero_2{m},2)
        all_fxi_E1E2zero = [all_fxi_E1E2zero_1; [f_E1E2zero_2{m}{s}(:),xi_E1E2zero_2{m}{s}(:)]];
    end
end

all_fxi_E1E2zero = sortrows(all_fxi_E1E2zero,2);
all_fxi_E1E2zero(all_fxi_E1E2zero(:,1)<0.01,:)=[];

plot(all_fxi_E1E2zero(:,2),all_fxi_E1E2zero(:,1))


%%
%best of E1fix
traces_E1fix{1} = [10 103 12 36 68 78 90];
traces_E1fix{2} = [10 11 15 20 22 23 24 26 3 34 37 4 43 48 49 5 57 59 6 62 64 66 67 68 70 71 78 83];
traces_E1fix{3} = [1 3 4 56 8];
traces_E1fix{4} = [12 13 22 26 3 6 7];
traces_E1fix{5} = [1 10 14 16 18 19 2 20 22 26 3 35 38 4 5 59 60 7 70 73 8 85];
traces_E1fix{6} = [1 10 11 25 28 33 35 8 48 6 65 67 69 70 74 75 76 78 8];

for m = 1:6
    for s = 1:size(traces_E1fix{m},2)
        E1fix{m}{s}.itracered = data{m}{traces_E1fix{m}(s),1}.itrace;
        E1fix{m}{s}.itracegreen = data{m}{traces_E1fix{m}(s),2}.itrace;
        E1fix{m}{s}.rms10 = data{m}{traces_E1fix{m}(s),1}.vwcm.rms10;
    
        [f_E1fix{m}{s},xi_E1fix{m}{s}] = ksdensity(E1fix{m}{s}.rms10,'Kernel','box');
    end
end


%% 
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_fxi_E1fix = [];
for m = 1:6
    for s = 1:size(traces_E1fix{m},2)
        all_fxi_E1fix = [all_fxi_E1fix; [f_E1fix{m}{s}(:),xi_E1fix{m}{s}(:)]];
    end
end

all_fxi_E1fix = sortrows(all_fxi_E1fix,2);
all_fxi_E1fix(all_fxi_E1fix(:,1)<0.01,:)=[];

plot(all_fxi_E1fix(:,2),all_fxi_E1fix(:,1))


%%
%best of E2
traces_E2{1} = [15 2 20 25 3 44 5 62 67 70 72 9];
traces_E2{2} = [10 12 15 19 21 23 24 25 28 3 31 4 65 7 8];
traces_E2{3} = [10 11 12 13 14 15 17 18 19 21 22 23 26 27 28 29 3 31 32 35 36 40 42 44 45 47 48 49 5 50 51 54 58 62 63 7 9];
traces_E2{4} = [11 13 14 3 31 40 57 59 61 9];
traces_E2{5} = [12 2 20 22 26 3 32 5 51 55 56 57 7 8 9];

for m = 1:5
    for s = 1:size(traces_E2{m},2)
        E2{m}{s}.itracered = data{m}{traces_E2{m}(s),1}.itrace;
        E2{m}{s}.itracegreen = data{m}{traces_E2{m}(s),2}.itrace;
        E2{m}{s}.rms10 = data{m}{traces_E2{m}(s),1}.vwcm.rms10;
    
        [f_E2{m}{s},xi_E2{m}{s}] = ksdensity(E2{m}{s}.rms10,'Kernel','box');
    end
end


%%
%best of E3fix
traces_E3fix{1} = [11 16 19 3 32 34 38 41 44 57 6 7 9];
traces_E3fix{2} = [1 10 11 12 18 19 23 24 26 28 3 32 36 39 5 9];
traces_E3fix{3} = [1 10 13 16 18 2 25 27 29 34 5 7];
traces_E3fix{4} = [1 11 2 22 25 29 32 33 4 6 7 9];

for m = 1:4
    for s = 1:size(traces_E3fix{m},2)
        E3fix{m}{s}.itracered = data{m}{traces_E3fix{m}(s),1}.itrace;
        E3fix{m}{s}.itracegreen = data{m}{traces_E3fix{m}(s),2}.itrace;
        E3fix{m}{s}.rms10 = data{m}{traces_E3fix{m}(s),1}.vwcm.rms10;
    
        [f_E3fix{m}{s},xi_E3fix{m}{s}] = ksdensity(E3fix{m}{s}.rms10,'Kernel','box');
    end
end


%% 
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_fxi_E3fix = [];
for m = 1:4
    for s = 1:size(traces_E3fix{m},2)
        all_fxi_E3fix = [all_fxi_E3fix; [f_E3fix{m}{s}(:),xi_E3fix{m}{s}(:)]];
    end
end

all_fxi_E3fix = sortrows(all_fxi_E3fix,2);
all_fxi_E3fix(all_fxi_E3fix(:,1)<0.01,:)=[];

%plot(all_fxi_E3fix(:,2),all_fxi_E3fix(:,1))


%%
%best of E3zero
traces_E3zero{1} = [1 10 12 13 19 20 23 26 3 33 37 5 50 53 55 6 64 65 66 8 9];
traces_E3zero{2} = [10 13 14 16 18 2 20 21 22 24 26 27 28 3 35 4 40 46 48 49 5 52 54 58 59 62 7];
traces_E3zero{3} = [1 11 12 13 14 18 20 21 23 27 28 30 32 4 43 44 5 52 54 59 7 9];
traces_E3zero{4} = [10 14 16 17 2 20 23 26 27 28 30 37 39 4 40 42 43 45 5 6 8 9];

for m = 1:4
    for s = 1:size(traces_E3zero{m},2)
        E3zero{m}{s}.itracered = data{m}{traces_E3zero{m}(s),1}.itrace;
        E3zero{m}{s}.itracegreen = data{m}{traces_E3zero{m}(s),2}.itrace;
        E3zero{m}{s}.rms10 = data{m}{traces_E3zero{m}(s),1}.vwcm.rms10;
    
        [f_E3zero{m}{s},xi_E3zero{m}{s}] = ksdensity(E3zero{m}{s}.rms10,'Kernel','box');
    end
end


%% 
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_fxi_E3zero = [];
for m = 1:4
    for s = 1:size(traces_E3zero{m},2)
        all_fxi_E3zero = [all_fxi_E3zero; [f_E3zero{m}{s}(:),xi_E3zero{m}{s}(:)]];
    end
end

all_fxi_E3zero = sortrows(all_fxi_E3zero,2);
all_fxi_E3zero(all_fxi_E3zero(:,1)<0.01,:)=[];

plot(all_fxi_E3zero(:,2),all_fxi_E3zero(:,1))


%%
%best of E3_1
traces_E3_1{1} = [19 24 27];
traces_E3_1{2} = [1 10 13 23 24 28 31 36 40 50 8];
traces_E3_1{3} = [10 11 15 16 22 35 38 40 42 46 47 48 50 6];
traces_E3_1{4} = [1 13 15 18 19 21 22 23 25 27 29 3 31 34 38 39 40 42 43 45 46 48 5 6 7 8 9];
traces_E3_1{5} = [1 12 13 14 15 17 23 24 26 27 28 3 31 35 36 37 38 40 42 45 47 51 52 53 54 8 9];
traces_E3_1{6} = [1 10 11 13 15 16 17 18 20 21 22 23 25 26 28 30 33 34 35 36 4 40 41 42 44 5 8 9];

for m = 1:6
    for s = 1:size(traces_E3_1{m},2)
        E3_1{m}{s}.itracered = data{m}{traces_E3_1{m}(s),1}.itrace;
        E3_1{m}{s}.itracegreen = data{m}{traces_E3_1{m}(s),2}.itrace;
        E3_1{m}{s}.rms10 = data{m}{traces_E3_1{m}(s),1}.vwcm.rms10;
    
        [f_E3_1{m}{s},xi_E3_1{m}{s}] = ksdensity(E3_1{m}{s}.rms10,'Kernel','box');
    end
end


%%
%best of E3_2
traces_E3_2{1} = [10 11 13 14 15 16 18 25 27 3 30 33 34 35 36 5 6 7 8 9];
traces_E3_2{2} = [1 15 2 4 5 6 7 8 9];
traces_E3_2{3} = [1 10 11 14 19 22 23 24 3 4 5 9];

for m = 1:3
    for s = 1:size(traces_E3_2{m},2)
        E3_2{m}{s}.itracered = data{m}{traces_E3_2{m}(s),1}.itrace;
        E3_2{m}{s}.itracegreen = data{m}{traces_E3_2{m}(s),2}.itrace;
        E3_2{m}{s}.rms10 = data{m}{traces_E3_2{m}(s),1}.vwcm.rms10;
    
        [f_E3_2{m}{s},xi_E3_2{m}{s}] = ksdensity(E3_2{m}{s}.rms10,'Kernel','box');
    end
end


%%
%best of E4_1
traces_E4_1{1} = [1 10 15 17];
traces_E4_1{2} = [];
traces_E4_1{3} = [16 17 18 19 3 32 6];
traces_E4_1{4} = [1 10 12 17 20 4 8];

for m = 1:4
    for s = 1:size(traces_E4_1{m},2)
        E4_1{m}{s}.itracered = data{m}{traces_E4_1{m}(s),1}.itrace;
        E4_1{m}{s}.itracegreen = data{m}{traces_E4_1{m}(s),2}.itrace;
        E4_1{m}{s}.rms10 = data{m}{traces_E4_1{m}(s),1}.vwcm.rms10;
    
        [f_E4_1{m}{s},xi_E4_1{m}{s}] = ksdensity(E4_1{m}{s}.rms10,'Kernel','box');
    end
end


%%
%erstellen der Grafen
figure('Units','normalized','Position',[0 0 1 1],'PaperPositionMode','auto')
hold on

% !!! m und s anpassen !!!
%for m = 1:4
%    for s = 1:size(traces_m{m},2)
%        plot(xi_E4_1{m}{s},f_E4_1{m}{s},'Linewidth',1)
%    end
%end

plot(all_fxi_E1E2zero(:,2),all_fxi_E1E2zero(:,1),'Linewidth',1)
plot(all_fxi_E1fix(:,2),all_fxi_E1fix(:,1),'Linewidth',1)

xlabel('rms10','Linewidth',30)
ylabel('f','Linewidth',30)
title('Wahrscheinlichkeitsdichten E1')
%legend('m1s10','m1s12','m1s14','m1s15','m1s17','m1s4','m1s40','m1s46','m1s47','m1s5','m1s54')

%%
%Dateien und Grafiken abspeichern

savefig('E1fixzero_mean.fig')
print('-dpng','E1fixzero_mean.png')
