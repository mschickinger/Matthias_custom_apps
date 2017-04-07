function [simStraj, simXY, simRMS] = sim_twostate_XY_RMS(params)

tau = params.tau;
tpf = params.tpf;
L = params.L;
simMu = params.mu;
simSigma = params.sigma;
wSize = params.wSize;

% start state
Pcrit = tau(1)/sum(tau);
tmp = random('Uniform',0,1e6);
if tmp/1e6 <= Pcrit
    S1 = 1;
else
    S1 = 2;
end

% simulate trajectories
simStraj = zeros(1,L);
simXY = zeros(2,L);


sumT = 0;
tmpF = 1;
st = S1;
while sumT < L*tpf
    sumT = sumT + random('exp',tau(st));
    tmpE = min(floor(sumT/tpf),L);
    simStraj(tmpF:tmpE) = st;
    simXY(:,tmpF:tmpE) = random('norm',simMu,simSigma(st),2,tmpE-tmpF+1);
    tmpF = ceil(sumT/tpf);
    st = mod(st,2)+1;
end
simRMS = RMSfilt2d(simXY,wSize);
return