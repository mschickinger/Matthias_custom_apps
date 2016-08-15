%best of E1

for m = 1:4
    for s = 1:size(traces_E1{m},2)
        E1{m}{s}.itracered = data{m}{traces_E1{m}(s),1}.itrace;
        E1{m}{s}.itracegreen = data{m}{traces_E1{m}(s),2}.itrace;
        E1{m}{s}.rms10 = data{m}{traces_E1{m}(s),1}.vwcm.rms10;
        E1{m}{s}.rms10green = data{m}{traces_E1{m}(s),2}.vwcm.rms10;
    end
end


%%
%mittel of E1

for m = 1:4
    for s = 1:size(traces_E1_mittel{m},2)
        E1_mittel{m}{s}.itracered = data{m}{traces_E1_mittel{m}(s),1}.itrace;
        E1_mittel{m}{s}.itracegreen = data{m}{traces_E1_mittel{m}(s),2}.itrace;
        E1_mittel{m}{s}.rms10 = data{m}{traces_E1_mittel{m}(s),1}.vwcm.rms10;
    end
end


%%
%E1/E2 zero 1
pts_E1E2zero_1 = 1:0.015:3;
bw = 0.0750; %0.0750 entspricht 5mal delta pts 0.0150
for m = 1:7
    for s = 1:size(traces_E1E2zero_1{m},2)
        E1E2zero_1{m}{s}.itracered = data{m}{traces_E1E2zero_1{m}(s),1}.itrace;
        E1E2zero_1{m}{s}.itracegreen = data{m}{traces_E1E2zero_1{m}(s),2}.itrace;
        E1E2zero_1{m}{s}.rms10 = data{m}{traces_E1E2zero_1{m}(s),1}.vwcm.rms10;
            
        [f_E1E2zero_1{m}{s}] = ksdensity(E1E2zero_1{m}{s}.rms10,pts_E1E2zero_1,'Kernel','box','Bandwidth',bw);
    end
end


%%
%E1/E2 zero 2
pts_E1E2zero_2 = 1:0.015:3;
bw = 0.0750;
for m = 1:6
    for s = 1:size(traces_E1E2zero_2{m},2)
        E1E2zero_2{m}{s}.itracered = data{m}{traces_E1E2zero_2{m}(s),1}.itrace;
        E1E2zero_2{m}{s}.itracegreen = data{m}{traces_E1E2zero_2{m}(s),2}.itrace;
        E1E2zero_2{m}{s}.rms10 = data{m}{traces_E1E2zero_2{m}(s),1}.vwcm.rms10;
        
        [f_E1E2zero_2{m}{s}] = ksdensity(E1E2zero_2{m}{s}.rms10,pts_E1E2zero_2,'Kernel','box','Bandwidth',bw);
    end
end
   

%%
%E1/E2 zero 1 und 2
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
E1E2zero = E1E2zero_1;
for m = 1:6
    for s = 1:size(traces_E1E2zero_2{m},2)
        E1E2zero{m}{size(E1E2zero_1{m},2) + s} = E1E2zero_2{m}{s};
    end
end

all_E1E2zero = [];
for m = 1:7
    for s = 1:size(E1E2zero{m},2)
        all_E1E2zero = [all_E1E2zero; E1E2zero{m}{s}.rms10];
    end
end

[f_all_E1E2zero] = ksdensity(all_E1E2zero,pts_E1E2zero_1,'Kernel','box','Bandwidth',bw);
%plot(pts_E1E2zero_1,f_all_E1E2zero)


%%
%E1 fix
pts_E1fix = 0.5:0.015:2.;
bw = 0.075;
for m = 1:6
    for s = 1:size(traces_E1fix{m},2)
        E1fix{m}{s}.itracered = data{m}{traces_E1fix{m}(s),1}.itrace;
        E1fix{m}{s}.itracegreen = data{m}{traces_E1fix{m}(s),2}.itrace;
        E1fix{m}{s}.rms10 = data{m}{traces_E1fix{m}(s),1}.vwcm.rms10;
    
        [f_E1fix{m}{s}] = ksdensity(E1fix{m}{s}.rms10,pts_E1fix,'Kernel','box','Bandwidth',bw);
    end
end


%%
%E1 fix all
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_E1fix = [];
for m = 1:6
    for s = 1:size(traces_E1fix{m},2)
        all_E1fix = [all_E1fix; E1fix{m}{s}.rms10];
    end
end

[f_all_E1fix] = ksdensity(all_E1fix,pts_E1fix,'Kernel','box','Bandwidth',bw);
%plot(pts_E1fix,f_all_E1fix)


%%
%E2

for m = 1:5
    for s = 1:size(traces_E2{m},2)
        E2{m}{s}.itracered = data{m}{traces_E2{m}(s),1}.itrace;
        E2{m}{s}.itracegreen = data{m}{traces_E2{m}(s),2}.itrace;
        E2{m}{s}.rms10 = data{m}{traces_E2{m}(s),1}.vwcm.rms10;
        E2{m}{s}.rms10green = data{m}{traces_E2{m}(s),2}.vwcm.rms10;
    end
end


%%
%mittel of E2

for m = 1:5
    for s = 1:size(traces_E2_mittel{m},2)
        E2_mittel{m}{s}.itracered = data{m}{traces_E2_mittel{m}(s),1}.itrace;
        E2_mittel{m}{s}.itracegreen = data{m}{traces_E2_mittel{m}(s),2}.itrace;
        E2_mittel{m}{s}.rms10 = data{m}{traces_E2_mittel{m}(s),1}.vwcm.rms10;
        E2_mittel{m}{s}.rms10green = data{m}{traces_E2_mittel{m}(s),2}.vwcm.rms10;
    end
end


%%
%E2 fix
pts_E2fix = 0.5:0.015:2;
bw = 0.075;
for m = 1:4
    for s = 1:size(traces_E2fix{m},2)
        E2fix{m}{s}.itracered = data{m}{traces_E2fix{m}(s),1}.itrace;
        E2fix{m}{s}.itracegreen = data{m}{traces_E2fix{m}(s),2}.itrace;
        E2fix{m}{s}.rms10 = data{m}{traces_E2fix{m}(s),1}.vwcm.rms10;
    
        [f_E2fix{m}{s}] = ksdensity(E2fix{m}{s}.rms10,pts_E2fix,'Kernel','box','Bandwidth',bw);
    end
end


%%
%E2 fix all
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_E2fix = [];
for m = 1:4
    for s = 1:size(traces_E2fix{m},2)
        all_E2fix = [all_E2fix; E2fix{m}{s}.rms10];
    end
end

[f_all_E2fix] = ksdensity(all_E2fix,pts_E2fix,'Kernel','box','Bandwidth',bw);
%plot(pts_E2fix,f_all_E2fix)


%%
%E3 fix
pts_E3fix = 0.8:0.015:3;
bw = 0.075;
for m = 1:4
    for s = 1:size(traces_E3fix{m},2)
        E3fix{m}{s}.itracered = data{m}{traces_E3fix{m}(s),1}.itrace;
        E3fix{m}{s}.itracegreen = data{m}{traces_E3fix{m}(s),2}.itrace;
        E3fix{m}{s}.rms10 = data{m}{traces_E3fix{m}(s),1}.vwcm.rms10;
     
        [f_E3fix{m}{s}] = ksdensity(E3fix{m}{s}.rms10,pts_E3fix,'Kernel','box','Bandwidth',bw);
    end
end


%%
%E3 fix all
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_E3fix = [];
for m = 1:4
    for s = 1:size(traces_E3fix{m},2)
        all_E3fix = [all_E3fix; E3fix{m}{s}.rms10];
    end
end

[f_all_E3fix] = ksdensity(all_E3fix,pts_E3fix,'Kernel','box','Bandwidth',bw);
%plot(pts_E3fix,f_all_E3fix)


%%
%E3 zero
pts_E3zero = 1.2:0.015:3.5;
bw = 0.075;
for m = 1:4
    for s = 1:size(traces_E3zero{m},2)
        E3zero{m}{s}.itracered = data{m}{traces_E3zero{m}(s),1}.itrace;
        E3zero{m}{s}.itracegreen = data{m}{traces_E3zero{m}(s),2}.itrace;
        E3zero{m}{s}.rms10 = data{m}{traces_E3zero{m}(s),1}.vwcm.rms10;
    
        [f_E3zero{m}{s}] = ksdensity(E3zero{m}{s}.rms10,pts_E3zero,'Kernel','box','Bandwidth',bw);
    end
end


%%
%E3 zero all
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_E3zero = [];
for m = 1:4
    for s = 1:size(traces_E3zero{m},2)
        all_E3zero = [all_E3zero; E3zero{m}{s}.rms10];
    end
end

[f_all_E3zero] = ksdensity(all_E3zero,pts_E3zero,'Kernel','box','Bandwidth',bw);
%plot(pts_E3zero,f_all_E3zero)


%%
%best of E3_1

for m = 1:6
    for s = 1:size(traces_E3_1{m},2)
        E3_1{m}{s}.itracered = data{m}{traces_E3_1{m}(s),1}.itrace;
        E3_1{m}{s}.itracegreen = data{m}{traces_E3_1{m}(s),2}.itrace;
        E3_1{m}{s}.rms10 = data{m}{traces_E3_1{m}(s),1}.vwcm.rms10;
        E3_1{m}{s}.rms10green = data{m}{traces_E3_1{m}(s),2}.vwcm.rms10;
    end
end


%%
%best of E3_2

for m = 1:3
    for s = 1:size(traces_E3_2{m},2)
        E3_2{m}{s}.itracered = data{m}{traces_E3_2{m}(s),1}.itrace;
        E3_2{m}{s}.itracegreen = data{m}{traces_E3_2{m}(s),2}.itrace;
        E3_2{m}{s}.rms10 = data{m}{traces_E3_2{m}(s),1}.vwcm.rms10;
        E3_2{m}{s}.rms10green = data{m}{traces_E3_2{m}(s),2}.vwcm.rms10;
    end
end


%%
%best of E4_1

for m = 1:4
    for s = 1:size(traces_E4_1{m},2)
        E4_1{m}{s}.itracered = data{m}{traces_E4_1{m}(s),1}.itrace;
        E4_1{m}{s}.itracegreen = data{m}{traces_E4_1{m}(s),2}.itrace;
        E4_1{m}{s}.rms10 = data{m}{traces_E4_1{m}(s),1}.vwcm.rms10;
        E4_1{m}{s}.rms10green = data{m}{traces_E4_1{m}(s),2}.vwcm.rms10;
    end
end


%%
%mittel of E4_1

for m = 1:4
    for s = 1:size(traces_E4_1_mittel{m},2)
        E4_1_mittel{m}{s}.itracered = data{m}{traces_E4_1_mittel{m}(s),1}.itrace;
        E4_1_mittel{m}{s}.itracegreen = data{m}{traces_E4_1_mittel{m}(s),2}.itrace;
        E4_1_mittel{m}{s}.rms10 = data{m}{traces_E4_1_mittel{m}(s),1}.vwcm.rms10;
        %E4_1{m}{s}.rms10green = data{m}{traces_E4_1{m}(s),2}.vwcm.rms10;

    end
end


%%
%best of E4_2

for m = 1:8
    for s = 1:size(traces_E4_2{m},2)
        %E4_2{m}{s}.itracered = data{m}{traces_E4_2{m}(s),1}.itrace;
        %E4_2{m}{s}.itracegreen = data{m}{traces_E4_2{m}(s),2}.itrace;
        %E4_2{m}{s}.rms10 = data{m}{traces_E4_2{m}(s),1}.vwcm.rms10;
        %E4_1{m}{s}.rms10green = data{m}{traces_E4_1{m}(s),2}.vwcm.rms10;
    end
end


%%
%best of E4zero
pts_E4zero = 0.8:0.015:2.5;
bw = 0.075;
for m = 1:4
    for s = 1:size(traces_E4zero{m},2)
        E4zero{m}{s}.itracered = data{m}{traces_E4zero{m}(s),1}.itrace;
        E4zero{m}{s}.itracegreen = data{m}{traces_E4zero{m}(s),2}.itrace;
        E4zero{m}{s}.rms10 = data{m}{traces_E4zero{m}(s),1}.vwcm.rms10;
    
        [f_E4zero{m}{s}] = ksdensity(E4zero{m}{s}.rms10,pts_E4zero,'Kernel','box','Bandwidth',bw);
    end
end


%%
%E4 zero
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_E4zero = [];
for m = 1:4
    for s = 1:size(traces_E4zero{m},2)
        all_E4zero = [all_E4zero; E4zero{m}{s}.rms10];
    end
end

[f_all_E4zero] = ksdensity(all_E4zero,pts_E4zero,'Kernel','box','Bandwidth',bw);
plot(pts_E4zero,f_all_E4zero)


%%
%best of E4fix
pts_E4fix = 0.2:0.015:1.6;
bw = 0.075;
for m = 1:4
    for s = 1:size(traces_E4fix{m},2)
        %E4fix{m}{s}.itracered = data{m}{traces_E4fix{m}(s),1}.itrace;
        %E4fix{m}{s}.itracegreen = data{m}{traces_E4fix{m}(s),2}.itrace;
        %E4fix{m}{s}.rms10 = data{m}{traces_E4fix{m}(s),1}.vwcm.rms10;
    
        [f_E4fix{m}{s}] = ksdensity(E4fix{m}{s}.rms10,pts_E4fix,'Kernel','box','Bandwidth',bw);
    end
end


%%
%E4 fix
%zusammenfügen der Wahrscheinlichkeitsdichten und sortieren
all_E4fix = [];
for m = 1:4
    for s = 1:size(traces_E4fix{m},2)
        all_E4fix = [all_E4fix; E4fix{m}{s}.rms10];
    end
end

[f_all_E4fix] = ksdensity(all_E4fix,pts_E4fix,'Kernel','box','Bandwidth',bw);
%plot(pts_E4fix,f_all_E4fix)


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

%plot(pts_E1E2zero_1,f_all_E1E2zero,'-r','Linewidth',1)
%plot(pts_E1fix,f_all_E1fix,'-b','Linewidth',1)

%plot(pts_E1E2zero_1,f_all_E1E2zero,'-r','Linewidth',1)
%plot(pts_E2fix,f_all_E2fix,'-b','Linewidth',1)

%plot(pts_E3zero,f_all_E3zero,'-r','Linewidth',1)
%plot(pts_E3fix,f_all_E3fix,'-b','Linewidth',1)

plot(pts_E4zero,f_all_E4zero,'-r','Linewidth',1)
plot(pts_E4fix,f_all_E4fix,'-b','Linewidth',1)

xlabel('rms10','Linewidth',50)
ylabel('Wahrscheinlichkeitsdichte','Linewidth',50)
axis([0 4 0 3])
title('E4 Kontrollexperimente')
legend('E4zero','E4fix')


%%
%FWHM
%Pfeile in der figure-Bearbeitung anpassen!!!
%E1
%plot([1.0500 1.5050],[0.9877 0.9877],'-k','Linewidth',0.5)
%plot([1.5100 2.1850],[0.6843 0.6843],'-k','Linewidth',0.5)
%E2
%plot([0.9500 1.3700],[1.0793 1.0793],'-k','Linewidth',0.5)
%plot([1.5100 2.1850],[0.6843 0.6843],'-k','Linewidth',0.5)
%E3
%plot([1.4600 2.0900],[0.7262 0.7262],'-k','Linewidth',0.5)
%plot([1.8600 2.6850],[0.5659 0.5659],'-k','Linewidth',0.5)
%area([1.8600 2.0900],[3 3],'FaceColor',[0.5 1 1],'EdgeColor',[0.5 0.5 0.5])
%annotation('textarrow',[0.3 0.4],[0.5 0.6],'String','Überlapp = 0.230','FontSize',20)
%E4
plot([0.6050 0.9800],[1.2114 1.2114],'-k','Linewidth',0.5)
plot([1.2950 1.8500],[0.8150 0.8150],'-k','Linewidth',0.5)

%Werte anpassen!!!
annotation('textarrow',[0.25 0.33],[0.5 0.38],'String','FWHM = 0.375','FontSize',20)
annotation('textarrow',[0.64 0.555],[0.5 0.3],'String','FWHM = 0.555','FontSize',20)


%%
%Überlapp für E1
pts_E1 = 1:0.015:1.99;

f1 = [pts_E1fix' f_all_E1fix'];
f1 = f1(f1(:,1)>=pts_E1(1),:);
f2 = [pts_E1E2zero_1' f_all_E1E2zero'];
f2 = f2(f2(:,1)<=pts_E1(end),:);
%Schnittpunkt ist ungefähr (1.544,0.814)
f1 = f1(f1(:,1)>1.544,:);
f2 = f2(f2(:,1)<1.544,:);
f = [f2;f1];

hold on
area(f(:,1),f(:,2),'FaceColor',[1 1 0.5],'EdgeColor',[0.5 0.5 0.5])
legend('E1zero','E1fix','Überlapp')


%%
%Überlapp für E2
pts_E2 = 1:0.015:1.99;

f1 = [pts_E2fix' f_all_E2fix'];
f1 = f1(f1(:,1)>=pts_E2(1),:);
f2 = [pts_E1E2zero_1' f_all_E1E2zero'];
f2 = f2(f2(:,1)<=pts_E2(end),:);
%Schnittpunkt ist ungefähr (1.461,0.572)
f1 = f1(f1(:,1)>1.4651,:);
f2 = f2(f2(:,1)<1.4651,:);
f = [f2;f1];

hold on
area(f(:,1),f(:,2),'FaceColor',[1 1 0.5],'EdgeColor',[0.5 0.5 0.5])
legend('E2zero','E2fix','Überlapp')
%annotation('textarrow',[%zw 0 und 1],[%zw 0 und 1],'String','A = 7.34 %')


%%
%Überlapp für E3
pts_E3 = 1.2:0.015:2.99;

f1 = [pts_E3fix' f_all_E3fix'];
f1 = f1(f1(:,1)>=pts_E3(1),:);
f2 = [pts_E3zero' f_all_E3zero'];
f2 = f2(f2(:,1)<=pts_E3(end),:);
%Schnittpunkt ist ungefähr (2.035,0.908)
f1 = f1(f1(:,1)>2.035,:);
f2 = f2(f2(:,1)<2.035,:);
f = [f2;f1];

hold on
area(f(:,1),f(:,2),'FaceColor',[1 1 0.5],'EdgeColor',[0.5 0.5 0.5])
legend('E3zero','E3fix','Überlapp')
%annotation('textarrow',[%zw 0 und 1],[%zw 0 und 1],'String','A = 7.34 %')


%%
%Überlapp für E4
pts_E4 = 0.8:0.015:1.5950;

f1 = [pts_E4fix' f_all_E4fix'];
f1 = f1(f1(:,1)>=pts_E4(1),:);
f2 = [pts_E4zero' f_all_E4zero'];
f2 = f2(f2(:,1)<=pts_E4(end),:);
f = min(f1(:,2),f2(:,2));
hold on
area(pts_E4,f,'FaceColor',[1 1 0.5],'EdgeColor',[0.5 0.5 0.5])
legend('E4zero','E4fix','Überlapp')
%annotation('textarrow',[%zw 0 und 1],[%zw 0 und 1],'String','A = 7.34 %')
%%
%Dateien und Grafiken abspeichern

savefig('E4fixzeroFWHM.fig')
print('-dpng','E4fixzeroFWHM.png')
