% CHI-SQUARED STEP DETECTION FOR A WHOLE DATASET (MANY SPOT PAIRS)
% 
% Data needed: rms10 traces (sample_data), sample_list
%% Prepare parameters and containers for data

sc2.steps = cell(1, length(sample_list));
sc2.steps_raw = cell(size(sc2.steps));
sc2.chi2 = cell(size(sc2.steps));
sc2.counter_chi2 = cell(size(sc2.steps));
sc2.levels = cell(size(sc2.steps));
sc2.steptrace = cell(size(sc2.steps));

max_frame = 35980;

%% Find maximum of N steps
for i = 1:length(sample_list)
    display(['FINDING STEPS FOR SPOT PAIR #' num2str(sample_list(i)) ' (' num2str(i) ' of ' num2str(length(sample_list)) ').'])
    [sc2.steps_raw{i}, ~, sc2.chi2{i}, sc2.counter_chi2{i}] = find_steps_by_chi2(sample_data{sample_list(i),1}.rms10, 100, max_frame);
end

%% Get rid of consecutive same direction steps
N_steps_tot = 0;
for i = 1:length(sc2.steps_raw)
    sc2.steps{i} = eliminate_stairs(sample_data{sample_list(i),1}.rms10(1:max_frame), sc2.steps_raw{i});
    N_steps_tot = N_steps_tot + length(sc2.steps{i});
end
display ('all stairs have been eliminated.')

%% Get levels and all step heights
step_heights = zeros(N_steps_tot,1);
b = 0;
for i = 1:length(sc2.levels)
    a = b + 1;
    b = a + length(sc2.steps{i}) - 1;
    [sc2.levels{i} , sc2.steptrace{i}]= get_levels(sample_data{sample_list(i),1}.rms10(1:max_frame),sc2.steps{i});
    step_heights(a:b) = abs(sc2.levels{i}(2:end)-sc2.levels{i}(1:end-1));
end
hist(step_heights,.01:.02:1.5);
xlim([0 1.5])
%%