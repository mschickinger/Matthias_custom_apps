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
     zustand(zahl,5)=0;
     
     %sigmas entfernung von bound mittel
     x1=4;
     %sigmas entfernung von unbound mittel
     x2=3;
     
     %mindestradius f?r unbound
     y1=0.5;
     %mindestradius f?r bound
     y2=0.5;
     
     zustand(1,2)=1;
     
     %?nderung der zust?nde und jeweiligezust?nde merken
     for i=1:length(eingabe)-1
         
        if eingabe(i+1)-eingabe(i)~=0

            zustand(zaehler,1)=eingabe(i);
            zustand(zaehler,3)=i;
            zustand(zaehler+1,2)=i+1;

            zaehler=zaehler+1;
        end
     end
    
zustand(zaehler,1)=eingabe(length(eingabe));
    zustand(zaehler,3)=length(eingabe);
     
     %mittel und std f?r alle zust?nde berechnen
    for i=1:size(zustand,1)

        zustand(i,4)=mean(rms10(zustand(i,2):zustand(i,3)));
        zustand(i,5)=std(rms10(zustand(i,2):zustand(i,3)));
    end
    %aussortieren
    for i=1:size(zustand,1)
        for j=zustand(i,2):zustand(i,3)
            %je nach Zustand
            if zustand(i,1)==1 && rms10(j)>zustand(i,4)+x1*zustand(i,5)
                for k=j-5:j+5
                    if radius(j)>y1
                        eingabe(j)=2;
                    end
                end
            elseif zustand(i,1)==2 && rms10(j)<zustand(i,4)-x2*zustand(i,5)
                for k=j-5:j+5   
                    if radius(j)<y2
                        eingabe(j)=1;
                    end
                end
            end
        end
    end
   plot(eingabe,'r');
   hold on;
    plot(rms10,'o', 'MarkerSize', 4);

end

