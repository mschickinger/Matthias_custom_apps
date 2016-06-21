function [ output ] = transition_detective( vector, varargin )

    %% parse input
    p = inputParser;
    addRequired(p, 'vector', @isnumeric); % these are the rms10 values from "data"
    addOptional(p, 'radius', @isnumeric); % these are the r values from "data"
    addOptional(p, 'xxyy', [2.6 0.35], @isnumeric); %these are variable input values for xx and yy; the default values are empirical
    addParameter(p, 'plot', false, @islogical);
    
   
    parse(p, vector, varargin{:});

    %% identify state transitions

    %counting variables
    i = 1;
    counter = 0;

    %variables to be set
    
    %starting values
    savedlowmean = 1.28; %0.3
    savedhighmean = 1.90; %0.85
    savedlowstd = 0.16; %0.04
    savedhighstd = 0.29; %0.1

    %*sigmas entfernung zu vorigem mean
    % new thresholding variables
    xx=p.Results.xxyy(1); % 2.6
    yy=p.Results.xxyy(2); % 0.35
    %xx = 3;
    %yy = 0.4;
    
    
    %{
    %values for post_transition_detective
    b1 = 1.6;  %  vorher 2, 1.1
    b2 = 2.5;   %   
    x1 = 5;
    x2 = 3;
    y = 0.5;
    x = 3;
    
    r_max = 3;
    old_r(20) = 0;
    
    changes = coarse;
    different = coarse;
    fine_single = coarse;
    fine_distribution = coarse;
    %}
    
    %number of frames to look back for mean and std
    back = 400;  % vorher 200

    %needed variables
    coarse(length(vector)) = 0;    
    advance = 5;
    rms_max = 3; %2.5


    %Anfangsstate
    if max(vector)-median(vector(1:10))>median(vector(1:10))-min(vector) %&& median(vector(1:10))<0.7 
        state=1;
    else
        state=2;
    end
    

    while i<=length(vector)-advance
        %compare with mean of 4 in starting in advance frames
        tmp_vector = vector(i:end);
        newmean=mean(tmp_vector(find(tmp_vector < rms_max,advance)));

        %standard and mean
        %calculation depending on if longer than "back" frames in new state

        tmp_vector = vector(1:i);
        if  counter>back
             oldmean = mean(tmp_vector(find(tmp_vector < rms_max,back,'last')));
             oldstandard=std(tmp_vector(find(tmp_vector < rms_max,back,'last')));
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

        if state==1 && (abs(newmean-oldmean)/(oldstandard*xx))>abs(savedhighmean+0-newmean)/savedhighstd %+0.2
            distance=newmean-oldmean;

            %only save data if in range of old
            if abs(oldmean-savedlowmean)>0.2
                savedlowmean=oldmean;
                savedlowstd=oldstandard;
            end

            %only switch into new mode when i state is close to new mean
            while vector(i)<(oldmean+distance*0.7) && vector(i)<rms_max
                coarse(i) = state;
                i=i+1;
            end
            state=2;
            counter=0;

        %new mode: bound 
        elseif state==2 && (abs(newmean-oldmean)/(oldstandard*yy))>abs(savedlowmean-0-newmean)/savedlowstd %-0.1

            distance=oldmean-newmean;

            if abs(oldmean-savedhighmean)<0.2 % ??? richtig?
                savedhighmean=oldmean;
                savedhighstd=oldstandard;
            end
            while vector(i)>(oldmean-distance*0.7)
                coarse(i)=state;
                i=i+1;
            end
            state=1;
            counter=0;     
        end

%     %post_transition_detective
%      
%     %new mode: unbound
%     if state==1 && vector(i)>oldmean+x1*oldstandard && vector(i) < rms_max && newmean>savedhighmean-b1*savedhighstd
%          first = find(radius(i-4:i+4)>y & radius(i-4:i+4)<r_max,1);
%          last = find(radius(i-4:i+4)>y & radius(i-4:i+4)<r_max,1,'last');
%          if ~isempty(first) && ~isempty(last)
%              changes(i-5+first:i-5+last)=2;
%          end
%     
%     %new mode: bound   
%     elseif state==2 && vector(i)<oldmean-x2*oldstandard && newmean<savedlowmean+b2*savedlowstd && radius(i) < y
%          first = find(radius(i-10:i-1)>y & radius(i-10:i-1)<r_max,1, 'last') +1;
%          last = find(radius(i+1:i+10)>y & radius(i-10:i-1)<r_max,1) -1;
%          if ~isempty(first) && ~isempty(last)
%              changes(i-5+first:i-5+last)=1;
%          end
%     end
% 
%     %radius with mean
%     %new mode: unbound
%     if state==1 && vector(i)>oldmean+x1*oldstandard && vector(i) < rms_max && newmean>savedhighmean-b1*savedhighstd
%         for j=i-4:i+4
%                 if mean(radius(j-1:j+1))>x
%                     different(j)=2;
%                 end
%         end
%     
%     %new mode: bound
%     elseif state==2 && vector(i)<oldmean-x2*oldstandard && newmean<savedlowmean+b2*savedlowstd && radius(i) < y
%         for j=i-4:i+4
%             if mean(radius(j-1:j+1))<x
%                 different(j)=1;
%             end
%         end
%     end
% 
%     %first/last value of radius bigger/smaller than threshhold 
%     %new mode: unbound
%     if state==1 && vector(i)>oldmean+x1*oldstandard && vector(i) < rms_max && newmean>savedhighmean-b1*savedhighstd
%          first = find(radius(i-4:i+4)>y & radius<r_max,1);
%          last = find(radius(i-4:i+4)>y & radius<r_max,1,'last');
%          if ~isempty(first) && ~isempty(last)
%              changes(i-5+first:i-5+last)=2;
%          end
%     
%     %new mode: bound   
%     elseif state==2 && vector(i)<oldmean-x2*oldstandard && newmean<savedlowmean+b2*savedlowstd && radius(i) < y
%          first = find(radius(i-10:i-1)>y & radius<r_max,1, 'last') +1;
%          last = find(radius(i+1:i+10)>y & radius<r_max,1) -1;
%          if ~isempty(first) && ~isempty(last)
%              changes(i-5+first:i-5+last)=1;
%          end
%     end
% 
%     %mean of radius bigger/smaller than threshhold
%     %new mode: unbound
%     if state==1 && vector(i)>oldmean+x1*oldstandard && vector(i) < rms_max && newmean>savedhighmean-b1*savedhighstd
%         for j=i-4:i+4
%                 if mean(radius(j-1:j+1))>x
%                     different(j)=2;
%                 end
%         end
%     
%     %new mode: bound
%     elseif state==2 && vector(i)<oldmean-x2*oldstandard && newmean<savedlowmean+b2*savedlowstd && radius(i) < y
%         for j=i-4:i+4
%             if mean(radius(j-1:j+1))<x
%                 different(j)=1;
%             end
%         end
%     end
    
    
    coarse(i)=state;
    i=i+1;
    counter=counter+1;
    end

    %get states of last advance

    coarse(end-advance+1:end)=state;
    
%     %complement free_single and free_distribution with coarse vector
%     fine_single = coarse;
%     fine_single(changes==1) = 1;
%     fine_single(changes==2) = 2;
%     
%     fine_distribution = coarse;
%     fine_distribution(different==1) = 1;
%     fine_distribution(different==2) = 2;
    
    
    %plot
    if p.Results.plot
        if strcmp(questdlg('Close all open figures?', 'Close all?', 'Yes'), 'Yes')
            close all
        end
        figure('Units', 'normalized', 'OuterPosition', [0 0 1 1])
        plot(coarse,'g');
        hold on;
        plot(vector,'o', 'MarkerSize', 4);
        hold on;
        %plot(changes,'r');
        %plot(fine_distribution,'b');
        ylim([min(vector)-0.5 max(vector)+0.5]);
    end
    
    %% output structure
    
    %coarse
    t_bind_coarse = find((coarse(2:end)-coarse(1:end-1))==-1)+1;
    t_unbind_coarse = find((coarse(2:end)-coarse(1:end-1))==1)+1;
    
    %fine_dustribution
    %t_bind_fine_distribution = find((fine_distribution(2:end)-fine_distribution(1:end-1))==-1)+1;
    %t_unbind_fine_distribution = find((fine_distribution(2:end)-fine_distribution(1:end-1))==1)+1;
    
    %fine_single
    %t_bind_fine_single = find((fine_single(2:end)-fine_single(1:end-1))==-1)+1;
    %t_unbind_fine_single = find((fine_single(2:end)-fine_single(1:end-1))==1)+1;
    
    output.states = coarse;

    %output.states_fine_single = fine_single;
    %output.states_fine_distribution = fine_distribution;

    output.t_bind_coarse = t_bind_coarse;
    output.t_unbind_coarse = t_unbind_coarse;
    
    %output.t_bind_fine_distribution = t_bind_fine_distribution;
    %output.t_unbind_fine_distribution = t_unbind_fine_distribution;
    %output.t_bind_fine_single = t_bind_fine_single;
    %output.t_unbind_fine_single = t_unbind_fine_single;

end