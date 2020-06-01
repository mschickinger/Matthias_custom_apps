function [simStraj, simXY, simT] = sim_twostate_XY(params)

tau = params.tau;
tpf = params.tpf*2/1000;
L = params.L;
simMu = params.mu;
simSigma = params.sigma;

% taus in units of sampling intervals
drawTau = tau./tpf;

% determine initial state
Pcrit = tau(1)/sum(tau);
tmp = random('Uniform',0,1e6);
if tmp/1e6 <= Pcrit
    st = 1;
else
    st = 2;
end

% simulate trajectories
simStraj = zeros(1,L);
simXY = zeros(2,L);
Tdraw = zeros(ceil(2*tpf*L/sum(tau)),1);

sumT = rand*exprnd(drawTau(st));
while sumT<1
    st = mod(st,2)+1;
    sumT = sumT + exprnd(drawTau(st));
end
simStraj(1:floor(sumT)) = st;
simXY(:,1:floor(sumT)) = random('norm',simMu,simSigma(st),2,floor(sumT));
currentRecorded = [1 floor(sumT)];
S1rec = mod(st,2)+1;
counter = 0;
while simStraj(L)==0
    st = mod(st,2)+1;
    counter = counter+1;
    Tdraw(counter) = exprnd(drawTau(st));
    sumT = sumT + Tdraw(counter);
    if floor(sumT)>currentRecorded(2)
        currentRecorded(1) = currentRecorded(2)+1;
        currentRecorded(2) = min(L,floor(sumT));
        simStraj(currentRecorded(1):currentRecorded(2)) = st;
        simXY(:,currentRecorded(1):currentRecorded(2)) = ...
                random('norm',simMu,simSigma(st),2,diff(currentRecorded)+1);
    end
end
Tdraw = Tdraw(1:counter-1);

% 'real' lifetime distributions
for i = 2:-1:1
    simT{1,i} = tpf.*Tdraw((1+(S1rec~=i)):2:end);
end

    
return