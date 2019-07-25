function [ output ] = even_iEdges (traces, N_threshs, min_thresh )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

thresholds = min_thresh;

tmp = N_below(traces,min_thresh);
%disp(thresholds)
%disp(tmp.N./tmp.N_all)
    
Pgood = 1-tmp.N/tmp.N_all;
deltaP = Pgood/N_threshs;

i = 2;
while i<=N_threshs
    thresholds = [thresholds thresholds(i-1)+100];
    tmp = N_below(traces,thresholds);
    %disp(threshs)
    %disp(tmp.N./tmp.N_all)
    while tmp.N(i)/tmp.N_all < (tmp.N(1)/tmp.N_all+(i-1)*deltaP)
        thresholds(i) = thresholds(i)+100;
        tmp = N_below(traces,thresholds);
        %disp(threshs)
        %disp(tmp.N./tmp.N_all)
    end
    i = i+1;
end
display(thresholds)
fractions_below = tmp.N./tmp.N_all;
display(fractions_below)
output = tmp;
end

