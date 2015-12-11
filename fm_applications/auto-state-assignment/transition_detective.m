function [ ausgabe ] = transition_detective( vector )


%z?hlvariablen
i=1;
counter=0;
%Erfahrungswerte
savedlowmean=0.3;
savedhighmean=1;

savedlowstd=0.04;
savedhighstd=0.1;

%*sigmas entfernung von altem mean  1-->wird zu unbound
a1=3.6; %  >2.6
a2=2.6; %  >2  kleiner als a1  <2.8
%*sigmas entfernung zu neuem
b1=1.3;  %   <1.6  kleiner als b2
b2=2;   %   <3

%anzahl stellen f?r oldmean, oldstd
back=200;

newmean=0;
oldmean=0;


%state: 2=unbound, 1=bound
state=1;
unbound=0;
bound=0;

%data
vector=x;

ausgabe(length(vector)-22)=0;


%Anfangsstate
if abs(median(vector(1:10))-max(vector))>abs(median(vector(1:10))-min(vector)) && median(vector(1:10))<0.7
    state=1;
else state=2;
end

 while i<length(vector)-22
     
         %DEBUGGING
%              if 35935<i
%             disp(i);
%             disp(state);
%             disp(oldmean);
%             disp(savedlowmean+2*savedlowstd);
%             pause;
%              end

    %vergleich mit 18-28 vor jetzigem i  <<18
    newmean=mean(vector(i+18:i+22));
    
             %standard und mean berechnung
    
    %wenn lange genug im zustand, oldmean ?ber "back"werte
    if  counter>back
         oldmean=mean(vector(i-back:i));
         oldstandard=std(vector(i-back:i));
         
    else
        %nicht lange genug, mittelwert zwischen so vielen werten jetzt wie
        %m?glich und gespeichertem mittelwert
        if state==2
            
            oldmean=(mean(vector(i-counter:i))*counter+(back-counter)*savedhighmean)/back;
            oldstandard=(std(vector(i-counter:i))*counter+(back-counter)*savedhighstd)/back;
        else
            oldmean=(mean(vector(i-counter:i))*counter+(back-counter)*savedlowmean)/back;
            oldstandard=(std(vector(i-counter:i))*counter+(back-counter)*savedlowstd)/back;
            
        end
    end
  


%jetzt gehts los  

%neuer Modus: unbound                                    
if newmean>oldmean+a1*oldstandard && abs(newmean-savedhighmean)<b1*savedhighstd
     distance=newmean-oldmean;
     
     %wenn bl?d geswitcht nicht speichern
      if abs(oldmean-savedlowmean)<0.3
      savedlowmean=oldmean;
      savedlowstd=oldstandard;
      end
     
    %wenn in neuen Modus geprungen wird, bleibe in altem bis mean von 3 Werten 0.7 der Diff.
    %erreicht haben
    while mean(vector(i:i+2))<(oldmean+distance*0.7)
        bound=bound+1;
        ausgabe(i)=state;
        i=i+1;
      
    end
    
     state=2;
     counter=0;
        
%neuer Modus: bound 
elseif newmean<oldmean-a2*oldstandard && abs(newmean-savedlowmean)<b2*savedlowstd
    
      distance=oldmean-newmean;
      
       if abs(oldmean-savedhighmean)<0.3
       savedhighmean=oldmean;
       savedhighstd=oldstandard;
       end
    
        while mean(vector(i:i+2))>(oldmean-distance*0.7)
        unbound=unbound+1;
        ausgabe(i)=state;
        i=i+1;

        end
        
     state=1;
     counter=0;
      
end
%jenachdem hochz?hlen
    if state==2
   unbound=unbound+1; 
    else
    bound=bound+1;
    
    end
    
ausgabe(i)=state;
i=i+1;
counter=counter+1;

 end

%ausgabe ausgabe vector
plot(ausgabe,'g');
hold on;
plot(vector,'o');


%   matthiasfreetimemachine(sample_data{15,1}.rms10)
%   matthiasfreetimemachine(sample_data{24,1}.rms10)
end