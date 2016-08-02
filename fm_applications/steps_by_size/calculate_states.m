function [hi, lo, Tu, Tb, state_trace] = calculate_states(steps, steptrace, ex_int, tpf)

    % Start frames and lengths of states
    S = reshape(steps(1:end-1),length(steps)-1,1);
    L = reshape(steps(2:end)-steps(1:end-1),length(steps)-1,1);

    % Assign type of states
    updn = zeros(size(S));
    for i = 1:length(updn)
        updn(i) = sign(steptrace(steps(i))-steptrace(steps(i)-1));
    end
    hi = [S(updn==1) L(updn==1)];
    lo = [S(updn==-1) L(updn==-1)];

    % Lifetimes in seconds (discard lifetimes of states within excluded
    % intervals)


    t_ex = [];
    for i = 1:size(ex_int,1)
        t_ex = [t_ex ex_int(i,1):ex_int(i,2)]; % pre-allocation to complicated?
    end
    % unbound lifetimes
    tmp = ones(size(hi,1),1);
    for i = 1:length(tmp)
        tmp(i) = isempty(intersect(hi(i,1):sum(hi(i,:))-1,t_ex));
    end
    Tu = hi(tmp==1,2)*2*tpf/1000;
    % bound lifetimes
    tmp = ones(size(lo,1),1);
    for i = 1:length(tmp)
        tmp(i) = isempty(intersect(lo(i,1):sum(lo(i,:))-1,t_ex));
    end
    Tb = lo(tmp==1,2)*2*tpf/1000;

    % Produce state_trace with 1s and 2s
    state_trace = zeros(size(steptrace));
    state_trace(1:steps(1)-1) = 1+(updn(1)==-1);
    state_trace(steps(end):end) = 1+(updn(end)==-1);
    for i = 1:size(hi,1)
        state_trace(hi(i,1):sum(hi(i,:))-1) = 2;
    end
    for i = 1:size(lo,1)
        state_trace(lo(i,1):sum(lo(i,:))-1) = 1;
    end
end
