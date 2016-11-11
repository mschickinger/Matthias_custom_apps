function [ output ] = beyond_limits( data_E4, vector, data_E4_zero, vec_E4_zero,data_E4_fix, vec_E4_fix)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% parameter
intervals = 5000:200:14000;
variable_zero = IntAndRMSD(data_E4_zero,vec_E4_zero,intervals); % get the data for limits of different intensity by other function
variable_fix = IntAndRMSD(data_E4_fix,vec_E4_fix,intervals);

%% maximum and minimum
maximum = zeros(1,length(variable_zero.minmax));
minimum = cell(1,length(variable_fix.minmax));

%HIER IF ISEMPTY ABFRAGE; SONST DEFAULT WERTE MAX=5 UND MIN=0.4
for i = 1:length(variable_zero.minmax) %RICHTIGE KLAMMERN?!
    %maximum(i) = variable_zero.minmax{i}(2)*1.05; % maximum of each intensity interval times 1.05
    %minimum{i} = variable_fix.minmax{i}(1)*0.95; % minimum of each intensity interval times 0.95
end

%% traces
output_over = cell(1,length(data_E4));
output_under = cell(1,length(data_E4));
output_overdensity = cell(1,length(data_E4));
output_underdensity = cell(1,length(data_E4));
for h = 1:size(vector,1) % search through every spot 
    m = vector(h,1);
    s = vector(h,2);
    output_over{m} = cell(1,length(data_E4{m})); % create empty cells in the same size as data cells
    output_under{m} = cell(1,length(data_E4{m}));
    output_overdensity{m} = cell(1,length(data_E4{m}));
    output_underdensity{m} = cell(1,length(data_E4{m}));
    for j = 1:length(data_E4{m}{s,1}.itrace) % search through every frame
        member = [];
        over = [];
        under = [];
        %numb = [];
        if data_E4{m}{s,1}.itrace<intervals(1) % is the intensity lower than the first interval
            member(1) = 1;
        elseif data_E4{m}{s,1}.itrace>intervals(end) % is the intensity higher than the largest interval
            member(length(intervals)+1) = 1;
        else
            for i = 2:length(intervals) % in which interval is the value of intensity of this frame
                member(i) = ismember(data_E4{m}{s,1}.itrace(j),intervals(i-1):intervals(i));
            end
        end
        numb = find(member==1); % number of interval to get the corresponding max or min
     %   if data_E4{m}{s,1}.vwcm.rms10(j)>maximum(numb) %RICHTIGE KLAMMERN?!
      %      over = [over; j]; % frames over the maximum RMSD of the corresponding interval
     %   elseif data_E4{m}{s,1}.vwcm.rms10(j)<minimum{numb}
     %       under = [under; j]; % frames under the minimum RMSD of the corresponding interval
     %   end
        output_over{m}{s} = over;
        output_under{m}{s} = under;
        %counter_over = [];
        %counter_under = [];
        if j>5 && j<(length(data_E4{m}{s,1})-4)
            output_overdensity{m}{s}(j) = sum(ismember(j-5:j+5,over))/11;
            output_underdensity{m}{s}(j) = sum(ismember(j-5:j+5,under))/11;
        elseif j<=5
            output_overdensity{m}{s}(j) = 0;
            
        else
            output_overdensity{m}{s}(j) = 0;
            output_underdensity{m}{s}(j) = 0;
        end
        
    end
end

%% output
output.over = output_over;
output.under = output_under;
output.overdensity = output_overdensity;
output.underdensity = output_underdensity;

end

