function [ mlmodel, spotdata ] = mlhmmINTerval( Selection, hiLim, loLim )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

mlhmmOptions.verbosity = 10;
mlhmmOptions.convergenceTolerance = 1e-4;
mlhmmOptions.reversible = 1;
mlhmmOptions.maximumIterations = 1000;
mlhmmOptions.equilibrium = 1;
mlhmmOptions.use_java = 1;
mlhmmOptions.tau = 0.1;

spotdata.N_in_range = 0;
spotdata.N_all = 0;
spotdata.range = zeros(size(Selection.indices));
spotdata.XYred = cell(size(Selection.XYred));
spotdata.medIred = cell(size(Selection.medIred));
for i = 1:length(Selection.medIred)
    tmpLo = find(Selection.medIred{i}>loLim,1,'last');
    if ~isempty(tmpLo)
        tmpLo = min(tmpLo, length(Selection.XYred{i}));
        tmpHi = find(Selection.medIred{i}>hiLim,1,'last');
        if isempty(tmpHi)
            tmpHi = 0;
        end
        spotdata.range(i,:) = [tmpHi+1 tmpLo];        
        spotdata.XYred{i} = Selection.XYred{i}(:,tmpHi+1:tmpLo);
        spotdata.medIred{i} = Selection.medIred{i}(tmpHi+1:tmpLo);      
    end
    spotdata.N_all = spotdata.N_all + nnz(Selection.medIred{i});
end

L = 100;
aboveL = zeros(size(spotdata.medIred));
for i = 1:length(aboveL)
    if spotdata.range(i,2)-spotdata.range(i,1)>=L;
        aboveL(i) = 1;
        spotdata.N_in_range = spotdata.N_in_range + length(spotdata.XYred{i});
    end
end

if mlhmmOptions.verbosity>2
    fprintf(['Total number of frames: %2.2e '...
    '\nNumber in range between %d and %d: %2.2e'...
    '\nThat is %3.1f percent.\n'], ... 
    spotdata.N_all, hiLim, loLim, spotdata.N_in_range, 100*spotdata.N_in_range/spotdata.N_all)
end

spotdata.XYred = spotdata.XYred(aboveL==1);
spotdata.medIred = spotdata.medIred(aboveL==1);
spotdata.indices = Selection.indices(aboveL==1,:);
spotdata.range = spotdata.range(aboveL==1,:);

mlmodel = mlhmmXY(spotdata.XYred,2,mlhmmOptions);
end

