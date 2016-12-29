%% create vectorAll
vectorAll = zeros(size(vertcat(data{:})));
counter = 1;
for m = 1:size(data,1) 
    for i = 1:size(data{m},1)
        vectorAll(counter,:) = [m i];
        counter = counter+1;
    end
end

%% create testAll
testAll = IntAndRMSD(data,vectorAll);

%% plot testAll
figure
for i = 1:size(testAll.intervals,2)
    plot(testAll.intervals{i}(:,1),testAll.intervals{i}(:,2),'.','MarkerSize',8)
    hold on
end
ylim([0 10])
set(gca,'Xdir','reverse')
set(gcf,'Units','normalized','Position',[0,0,1,0.9])

%% reduction, upper limit:
vector_red = vector_qs;
testAll_red = testAll_qs;
%midpoints = testAll.midpoints;
midpoints = testAll_red.midpoints;
delta = 0.5*(midpoints(2)-midpoints(1));

% FACTORS
max_factor = 1.5; 
%maximum1 = max_factor*testAll.center98(1,:);
%maximum1 = max_factor*testAll_red.center98(1,:);
maximum1 = 4.0*ones(size(midpoints));
loop_vector = vector_red;
for m = 1:length(loop_vector)
    itrace = data{loop_vector(m,1)}{loop_vector(m,2),1}.itrace;
    rms = data{loop_vector(m,1)}{loop_vector(m,2),1}.vwcm.rms10;
    i = find(midpoints == 5300);
    go_on = 1; 
    while i < find(midpoints == 14100) && go_on % criterion 1: intervals 1:25
        if any(itrace >= (midpoints(i)-delta) & itrace < (midpoints(i)+delta) & rms > maximum1(i))   
            vector_red(vector_red(:,1)==loop_vector(m,1) & vector_red(:,2)==loop_vector(m,2),:) = [];
            go_on = 0;
        end
        i=i+1;
    end
%     while i < length(midpoints) && go_on % criterion 2: intervals 26:45
%         if any(itrace >= (midpoints(i)-delta) & itrace < (midpoints(i)+delta) & rms > maximum2(i))   
%             vector_red(vector_red(:,1)==loop_vector(m,1) & vector_red(:,2)==loop_vector(m,2),:) = [];
%             go_on = 0;
%         end
%         i=i+1;
%     end
end

%% lower limit
midpoints = testAll_red.midpoints;
delta = 0.5*(midpoints(2)-midpoints(1));
min_factor = 1;
minimum = 0.5*ones(size(midpoints));%min_factor*testAll_red.center98(2,:);
loop_vector = vector_red;
for m = 1:length(loop_vector)
    itrace = data{loop_vector(m,1)}{loop_vector(m,2),1}.itrace;
    rms = data{loop_vector(m,1)}{loop_vector(m,2),1}.vwcm.rms10;
    i = find(midpoints==5500); % INPUT!
    go_on = 1;
    while i < length(midpoints) && go_on
        if any(itrace >= (midpoints(i)-delta) & itrace < (midpoints(i)+delta) & rms < minimum(i))   
            vector_red(vector_red(:,1)==loop_vector(m,1) & vector_red(:,2)==loop_vector(m,2),:) = [];
            go_on = 0;
        end
        i=i+1;
    end
end

%% create and plot testAll_red
testAll_red = IntAndRMSD(data,vector_red);
figure
for i = 1:size(testAll_red.intervals,2)
    plot(testAll_red.intervals{i}(:,1),testAll_red.intervals{i}(:,2),'.','MarkerSize',8)
    hold on
end
ylim([0 5])
set(gca,'Xdir','reverse')
set(gcf,'Units','normalized','Position',[0,0,1,0.9])