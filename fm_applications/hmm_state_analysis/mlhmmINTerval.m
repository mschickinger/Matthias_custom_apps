function [ mlmodel, arxv ] = mlhmmINTerval( Selection, iLims, varargin)
%mlhmmINTerval: Maximum-likelihood Hidden Markov Model Analyis of a
%selection of data within an intensity interval defined by iLims.

%   Input:
%   'Selection' is a struct with fields 'indices','XY','medI'

%% parse input
p = inputParser;
addRequired(p,'Selection');
addRequired(p, 'iLims');
addOptional(p, 'xyLims', [Inf Inf]);
addParameter(p, 'options', []);
parse(p, Selection, iLims, varargin{:})

Selection = p.Results.Selection;
hiLim = max(p.Results.iLims);
loLim = min(p.Results.iLims);
Dmax = max(p.Results.xyLims);
THR = min(p.Results.xyLims);
if ~isempty(p.Results.options)
    mlhmmOptions = p.Results.options;
else
    mlhmmOptions.verbosity = 10;
    mlhmmOptions.convergenceTolerance = 1e-4;
    mlhmmOptions.reversible = 1;
    mlhmmOptions.maximumIterations = 1000;
    mlhmmOptions.equilibrium = 1;
    mlhmmOptions.use_java = 1;
    mlhmmOptions.tau = 0.1;
    mlhmmOptions.assign_states = 1;
end

%% crop to intensity intervals
arxv.nINT = 0;
arxv.nALL = 0;
tmpRange = zeros(size(Selection.indices));
tmpXY = cell(size(Selection.XY));
for i = 1:length(Selection.medI)
    tmpLo = find(Selection.medI{i}>loLim,1,'last');
    if ~isempty(tmpLo)
        tmpLo = min(tmpLo, length(Selection.XY{i}));
        tmpHi = find(Selection.medI{i}>hiLim,1,'last');
        if isempty(tmpHi)
            tmpHi = 0;
        end
        arxv.nINT = arxv.nINT + tmpLo-tmpHi;
        tmpRange(i,:) = [tmpHi+1 tmpLo];        
        tmpXY{i} = Selection.XY{i}(:,tmpHi+1:tmpLo);
        arxv.medI{i} = Selection.medI{i}(tmpHi+1:tmpLo);      
    end
    arxv.nALL = arxv.nALL + nnz(Selection.medI{i});
end

if mlhmmOptions.verbosity>2
    fprintf(['Total number of frames: %2.2e '...
    '\nNumber in range between %d and %d: %2.2e'...
    '\nThat is %3.1f percent of all frames.\n'], ... 
    arxv.nALL, hiLim, loLim, arxv.nINT, 100*arxv.nINT/arxv.nALL)
end

keep = find(tmpRange(:,1)>0);
arxv.INTrange = tmpRange(keep,:);
arxv.indicesINT = Selection.indices(keep,:);
xyINT = tmpXY(keep);

%% Pick best-suited interval of each trace for HMM evaluation:
arxv.nHMM = 0;
tmpRange = zeros(size(arxv.INTrange));
tmpXY = cell(size(xyINT));
for i = 1:length(tmpXY)
    tmpI = longest_good_interval(xyINT{i},Dmax,THR);
    if ~isempty(tmpI)
        tmpRange(i,:) = tmpI;
        tmpXY{i} = xyINT{i}(:,tmpI(1):tmpI(2));
        arxv.nHMM = arxv.nHMM + diff(tmpI) + 1;
    end
end

if mlhmmOptions.verbosity>2
    fprintf(['Number of frames used for HMM analysis: %2.2e'...
    '\nThat is %3.1f percent of all frames' ...
    '\nand %3.1f percent of the frames in intensity range.\n'], ... 
    arxv.nHMM, 100*arxv.nHMM/arxv.nALL, 100*arxv.nHMM/arxv.nINT)
end

keep = find(tmpRange(:,1)>0);
arxv.HMMrange = tmpRange(keep,:);
arxv.indicesHMM = arxv.indicesINT(keep,:);
arxv.xyHMM = tmpXY(keep);

%% start HMM analysis
mlmodel = mlhmmXY(arxv.xyHMM,2,mlhmmOptions);
end

