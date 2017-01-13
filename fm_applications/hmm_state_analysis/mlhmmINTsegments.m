function [ mlmodels, state_trajectory, arxv ] = mlhmmINTsegments( XY, iTrace, iThreshs, init, varargin )
%mlhmmINTsegments: Maximum-likelihood Hidden Markov Model Analyis of a
%single particle XY-time-trace, divided into similar-intensity segments. 

%% parse input
p = inputParser;
addRequired(p,'XY');
addRequired(p, 'iTrace');
addRequired(p, 'iThreshs');
addRequired(p, 'init');
%addOptional(p, 'xyLims', [Inf Inf]);
addParameter(p, 'options', []);
parse(p, XY, iTrace, iThreshs, init, varargin{:})

XY = p.Results.XY;
iTrace = p.Results.iTrace;
iThreshs = p.Results.iThreshs;

if ~isempty(p.Results.options)
    mlhmmOptions = p.Results.options;
else
    mlhmmOptions.verbosity = 1;
    mlhmmOptions.convergenceTolerance = 1e-4;
    mlhmmOptions.reversible = 1;
    mlhmmOptions.maximumIterations = 1000;
    mlhmmOptions.equilibrium = 1;
    mlhmmOptions.use_java = 1;
    mlhmmOptions.tau = 0.1;
    mlhmmOptions.assign_states = 1;
end

segments = iSegments(iTrace, iThreshs);

if ~isempty(segments)
    XY = XY(:,1:segments(end,2));
    [mlmodels, state_trajectory] = mlhmmXYsegments(XY, segments, 2, mlhmmOptions);    
    arxv.XY = XY;
else
    mlmodels = [];
    state_trajectory = [];
    arxv.XY = [];
end
arxv.segments = segments + init - 1;
end

