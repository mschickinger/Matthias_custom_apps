function [ eingabe ] = post_transition_detective( eingabe, radius ,rms10)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

zahl=0;
for i=1:length(eingabe)-1
   if eingabe(i+1)-eingabe(i)~=0
       zahl=zahl+1;
   end
end
         
     zaehler=1;
     zustand(10000000,5)=0;
     
     %sigmas entfernung von bound mittel
     x1=1.5;
     %sigmas entfernung von unbound mittel
     x2=1.5;
     
     %mindestradius f?r unbound
     y1=0.5;
     %mindestradius f?r bound
     y2=0.5;
     
     zustand(1,2)=1;
     
     %?nderung der zust?nde und jeweiligezust?nde merken
     for i=1:length(ausgabe)
         
        if ausgabe(i+1)-ausgabe(i)~=0

            zustand(zaehler,1)=ausgabe(i);
            zustand(zaehler,3)=i;
            zustand(zaehler+1,2)=i+1;

            zaehler=zaehler+1;
        end
     end
    
zustand(zaehler,1)=ausgabe(length(ausgabe));
    zustand(zaehler,3)=length(ausgabe);
     
     %mittel und std f?r alle zust?nde berechnen
    for i=1:length(zustand(:,1));

        zustand(i,4)=mean(zustand(i,2):zustand(i,3));
        zustand(i,5)=std(zustand(i,2):zustand(i,3));
    end
    %aussortieren
    for i=1:length(zustand(:,1))
        for j=zustand(i,2):zustand(i,3)
            %je nach Zustand
            if zustand(i,1)==1 && vector(j)>zustand(i,4)+x1*zustand(i,5)
                for k=j-4:j+4
                    if vector2(j)>y1
                        ausgabe(j)=2;
                    end
                end
            elseif zustand(i,1)==2 && vector(j)<zustand(i,4)-x2*zustand(i,5)
                for k=j-4:j+4
                    if vector2(j)<y2
                        ausgabe(j)=1;
                    end
                end
            end
        end
   end
end

