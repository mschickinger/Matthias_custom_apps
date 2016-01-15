function [ ausgabe ] = transition_detective( vector, radius )


    %counting variables
    i=1;
    counter=0;
    %variables to be set
    savedlowmean=0.3;
    savedhighmean=0.85;

    savedlowstd=0.04;
    savedhighstd=0.1;
    %*sigmas entfernung von altem mean  1-->wird zu unbound
    a1=4.8; %  >2.6
    a2=2; %  >2  kleiner als a1  <2.8
    %*sigmas entfernung zu neuem
    b1=2;  %   
    b2=4;   %   
    
    %values for post_transition_detective
    x1=5;
    x2=3;
    y=0.5;

    %number of frames to look back for mean and std
    back=200;

    %state: 2=unbound, 1=bound
    state=1;

    %needed variables
    newmean=0;
    oldmean=0;
    ausgabe(length(vector))=0;
    changes(length(vector))=0;
    advance=4;
    
    
    %preparation
%     too_high=find(vector>1.5);
%     for i=1:length(too_high)
%         vector(too_high(i))=vector(too_high(i-1));
%     end


    %Anfangsstate
    if abs(median(vector(1:10))-max(vector))>abs(median(vector(1:10))-min(vector)) && median(vector(1:10))<0.7
        state=1;
    else
        state=2;
    end
    
    %values too high for everything to be mean of values around it

     while i<length(vector)-advance

             %DEBUGGING
%                    if 27700<i
%                   disp(i);
%                   disp(state);
%                   disp(newmean);
%                   disp(oldmean+a1*oldstandard);
%                   pause;
%                    end

        %compare with mean of 4 in starting in advance frames
        newmean=mean(vector(i+advance-4:i+advance));

        %standard and mean
        %calculation depending on if longer than "back" frames in new state
        if  counter>back
             oldmean=mean(vector(i-back:i));
             oldstandard=std(vector(i-back:i));
        else       
            if state==2
                oldmean=(mean(vector(i-counter:i))*counter+(back-counter)*savedhighmean)/back;
                oldstandard=(std(vector(i-counter:i))*counter+(back-counter)*savedhighstd)/back;
            else
                oldmean=(mean(vector(i-counter:i))*counter+(back-counter)*savedlowmean)/back;
                oldstandard=(std(vector(i-counter:i))*counter+(back-counter)*savedlowstd)/back;
            end
        end
        
    %check for new mode
    %new mode: unbound                                    
    if state==1 &&newmean>oldmean+a1*oldstandard && newmean>savedhighmean-b1*savedhighstd
         distance=newmean-oldmean;
         
         %only save data if in range of old
         if oldmean-savedlowmean>-0.2
            savedlowmean=oldmean;
            savedlowstd=oldstandard;
         end
         
        %only switch into new mode when i state is close to new mean
        while vector(i)<(oldmean+distance*0.7)
            ausgabe(i)=state;
            i=i+1;
        end
         state=2;
         counter=0;

    %new mode: bound 
    elseif state==2 && newmean<oldmean-a2*oldstandard && newmean<savedlowmean+b2*savedlowstd
            distance=oldmean-newmean;
            
         if oldmean-savedhighmean<0.2
            savedhighmean=oldmean;
            savedhighstd=oldstandard;
         end
        while vector(i)>(oldmean-distance*0.7)
            ausgabe(i)=state;
            i=i+1;
        end
         state=1;
         counter=0;
         
    end

    
    
     %post_transition_detective
     
     %new mode: unbound  REIHENFOLGE DER LOG. ABFRAGEN WICHTIG? ZEIT
    if state==1 && vector(i)>oldmean+x1*oldstandard && vector(i)>savedhighmean-b1*savedhighstd
        for k=i-4:i+4
             if radius(k)>y
                 changes(k)=2;
             end
        end
        
     %new mode: bound   
    elseif state==2 && vector(i)<oldmean-x2*oldstandard && vector(i)<savedlowmean+b2*savedlowstd
        for k=i-4:i+4
             if radius(k)<y
                 changes(k)=1;
             end
        end
    end
    ausgabe(i)=state;
    i=i+1;
    counter=counter+1;
     end

%get states of last advance
if mean(vector(end-advance:end))-savedlowmean<savedlowstd*a1
    ausgabe(end-advance:end)=1;
else
    ausgabe(end-advance:end)=2;
end

ausgabe(find(changes==1))=1;
ausgabe(find(changes==2))=2;
    
ausgabe=ausgabe';

%ausgabe  vector
plot(ausgabe,'g');
hold on;
plot(vector,'o', 'MarkerSize', 4);
ylim([0 2]);


end