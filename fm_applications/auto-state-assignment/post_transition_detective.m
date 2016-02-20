function [  ] = post_transition_detective( eingabe, radius ,rms10)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    zaehler=1;

    %sigmas entfernung von bound mittel
    x1=3;
    %sigmas entfernung von unbound mittel
    x2=3;
    %sigmas entfernung zu neuem 
    z1=1.3;
    z2=2;

    %mindestradius f?r unbound
    y1=0.5;
    %mindestradius f?r bound
    y2=0.5;
    
    %collect all frames showing beginning of new state
    zahl=[1;find((eingabe(2:end)-eingabe(1:end-1))~=0)+1];
        
    %Matrix for bound;unbound with start/end points, depending on odd/even
    %number of elements
    if eingabe(1)==1
        if rem(length(zahl),2)
            bound=[zahl(1:2:end)'; (zahl(2:2:end)-1)' length(eingabe)]';
            unbound=[zahl(2:2:end) zahl(3:2:end)-1];
        else
             bound=[zahl(1:2:end) zahl(2:2:end)-1];
             unbound=[zahl(2:2:end)'; (zahl(3:2:end)-1)' length(eingabe)]';
        end
        
    end
        
    if eingabe(1)==2
        if rem(length(zahl),2)
            unbound=[zahl(1:2:end) zahl(2:2:end)-1];
            bound=[zahl(2:2:end)'; (zahl(3:2:end)-1)' length(eingabe)]';            
        else
            unbound=[zahl(1:2:end)'; (zahl(2:2:end)-1)' length(eingabe)]';
            bound=[zahl(2:2:end) zahl(3:2:end)-1];
        end
        
    end
    %mean and deviation of bound;unbound
    average_bound(size(bound,1))=0;
    deviation_bound(size(bound,1))=0;
    
    average_unbound(size(unbound,1))=0;
    deviation_unbound(size(unbound,1))=0;
    %works without for????
    for i=1:size(bound,1)
        average_bound(i)=mean(rms10(bound(i,1):bound(i,2)));
        deviation_bound(i)=std(rms10(bound(i,1):bound(i,2)));
    end
    

    for i=1:size(unbound,1)
        average_unbound(i)=mean(rms10(unbound(i,1):unbound(i,2)));
        deviation_unbound(i)=std(rms10(unbound(i,1):unbound(i,2)));
    end
    
    %potential_unbound declare size before how??
    for i=1:size(bound,1)
        potential_unbound=find(rms10(bound(i,1):bound(i,2))>average_bound(i)+x1*deviation_bound(i));
    end
    disp(potential_unbound);
    
%     %aussortieren
%     for i=1:size(zustand,1)
%         for j=zustand(i,2):zustand(i,3)
%             %je nach Zustand
%             if zustand(i,1)==1 && rms10(j)>zustand(i,4)+x1*zustand(i,5) && abs(rms10(j)-zustand(i+1,4))<z1*zustand(i+1,5)
%                 for k=j-5:j+5
%                     if radius(k)>y1
%                         eingabe(k)=2;
%                     end
%                 end
%             elseif zustand(i,1)==2 && rms10(j)<zustand(i,4)-x2*zustand(i,5)
%                 for k=j-4:j+4   
%                     if all(radius(k-1:k+1))<y2
%                         eingabe(k-1:k+1)=1;
%                     end
%                 end
%             end
%         end
%     end
% %    plot(eingabe,'r');
% %    hold on;
% %    plot(rms10,'o', 'MarkerSize', 4);
% 
% disp('zahl');
end

