midpoints = testAll.midpoints;
delta = 0.5*(midpoints(2)-midpoints(1));
vector_red = vector;
maximum = 1.25*testAll.percentile99;
minimum = testAll.percentile1;
loop_vector = vector;
for m = 1:length(loop_vector)
    itrace = data{loop_vector(m,1)}{loop_vector(m,2),1}.itrace;
    rms = data{loop_vector(m,1)}{loop_vector(m,2),1}.vwcm.rms10;
    i = 4;
    go_on = 1;
    while i < length(midpoints) && go_on
        if any(itrace >= (midpoints(i)-delta) & itrace < (midpoints(i)+delta) & rms > maximum(i))   
            vector_red(vector_red(:,1)==loop_vector(m,1) & vector_red(:,2)==loop_vector(m,2),:) = [];
            go_on = 0;
        end
        i=i+1;
    end
end
% unter Grenze:
loop_vector = vector_red;
for m = 1:length(loop_vector)
    itrace = data{loop_vector(m,1)}{loop_vector(m,2),1}.itrace;
    rms = data{loop_vector(m,1)}{loop_vector(m,2),1}.vwcm.rms10;
    i = 5;
    go_on = 1;
    while i < length(midpoints) && go_on
        if any(itrace >= (midpoints(i)-delta) & itrace < (midpoints(i)+delta) & rms < minimum(i))   
            vector_red(vector_red(:,1)==loop_vector(m,1) & vector_red(:,2)==loop_vector(m,2),:) = [];
            go_on = 0;
        end
        i=i+1;
    end
end