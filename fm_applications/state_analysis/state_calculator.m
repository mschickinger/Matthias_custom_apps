function [states, T_bound, T_unbound, k_off, k_on] = state_calculator_v2 ( spot_data, mov_length, tpf )

% state assignment from beginning
states = zeros(mov_length,1); %set length anew for every sample
if spot_data.t_bind(1) == 1
    for i = 1:length(spot_data.t_unbind)
        states(spot_data.t_bind(i):spot_data.t_unbind(i)-1) = 1;
    end
    for i = 2:length(spot_data.t_bind)
        states(spot_data.t_unbind(i-1):spot_data.t_bind(i)-1) = 2;
    end
elseif spot_data.t_unbind(1) == 1
    for i = 2:length(spot_data.t_unbind)
        states(spot_data.t_bind(i-1):spot_data.t_unbind(i)-1) = 1;
    end
    for i = 1:length(spot_data.t_bind)
        states(spot_data.t_unbind(i):spot_data.t_bind(i)-1) = 2;
    end
end
% state assignment after last transition
if spot_data.t_unbind(end)>spot_data.t_bind(end)
    states(spot_data.t_unbind(end):end) = 2;
else
    states(spot_data.t_bind(end):end) = 1;
end

% T_bound and T_unbound in seconds, correct for excluded intervals
T = 2*tpf/1000;
if spot_data.t_bind(1) == 1
    % Bound lifetimes
    t_bind_tmp = spot_data.t_bind(2:length(spot_data.t_unbind));
    t_unbind_tmp = spot_data.t_unbind(2:end);
    if ~isempty(t_unbind_tmp)
        t_bind_ex = ones(size(t_bind_tmp));
        t_unbind_ex = ones(size(t_unbind_tmp));
        for i = 1:length(t_bind_tmp)
            t_bind_ex(i) = isempty(find(spot_data.excluded(t_bind_tmp(i):t_unbind_tmp(i))==1, 1));
            t_unbind_ex(i) = isempty(find(spot_data.excluded(t_bind_tmp(i):t_unbind_tmp(i))==1, 1));
        end
        t_bind_tmp = t_bind_ex.*t_bind_tmp;
        t_unbind_tmp = t_unbind_ex.*t_unbind_tmp;    
        t_bind_tmp = t_bind_tmp(t_bind_tmp>0);
        t_unbind_tmp = t_unbind_tmp(t_unbind_tmp>0);
        T_bound = (t_unbind_tmp - t_bind_tmp).*T;
    else
        T_bound = [];
    end
    % Unbound lifetimes
    t_bind_tmp = spot_data.t_bind(2:end);
    t_unbind_tmp = spot_data.t_unbind(1:length(spot_data.t_bind)-1);
    t_bind_ex = ones(size(t_bind_tmp));
    t_unbind_ex = ones(size(t_unbind_tmp));
    for i = 1:length(t_bind_tmp)
        t_bind_ex(i) = isempty(find(spot_data.excluded(t_unbind_tmp(i):t_bind_tmp(i))==1, 1));
        t_unbind_ex(i) = isempty(find(spot_data.excluded(t_unbind_tmp(i):t_bind_tmp(i))==1, 1));
    end
    t_bind_tmp = t_bind_ex.*t_bind_tmp;
    t_unbind_tmp = t_unbind_ex.*t_unbind_tmp;    
    t_bind_tmp = t_bind_tmp(t_bind_tmp>0);
    t_unbind_tmp = t_unbind_tmp(t_unbind_tmp>0);
    T_unbound = (t_bind_tmp - t_unbind_tmp).*T;
elseif spot_data.t_unbind(1) == 1
    % Bound lifetimes
    t_bind_tmp = spot_data.t_bind(1:length(spot_data.t_unbind)-1);
    t_unbind_tmp = spot_data.t_unbind(2:end);
    t_bind_ex = ones(size(t_bind_tmp));
    t_unbind_ex = ones(size(t_unbind_tmp));
    for i = 1:length(t_bind_tmp)
        t_bind_ex(i) = isempty(find(spot_data.excluded(t_bind_tmp(i):t_unbind_tmp(i))==1, 1));
        t_unbind_ex(i) = isempty(find(spot_data.excluded(t_bind_tmp(i):t_unbind_tmp(i))==1, 1));
    end
    t_bind_tmp = t_bind_ex.*t_bind_tmp;
    t_unbind_tmp = t_unbind_ex.*t_unbind_tmp;    
    t_bind_tmp = t_bind_tmp(t_bind_tmp>0);
    t_unbind_tmp = t_unbind_tmp(t_unbind_tmp>0);
    T_bound = (t_unbind_tmp - t_bind_tmp).*T;
    % Unbound lifetimes
    t_bind_tmp = spot_data.t_bind(2:end);
    t_unbind_tmp = spot_data.t_unbind(2:length(spot_data.t_bind));
    if ~isempty(t_bind_tmp)
        t_bind_ex = ones(size(t_bind_tmp));
        t_unbind_ex = ones(size(t_unbind_tmp));
        for i = 1:length(t_bind_tmp)
            t_bind_ex(i) = isempty(find(spot_data.excluded(t_unbind_tmp(i):t_bind_tmp(i))==1, 1));
            t_unbind_ex(i) = isempty(find(spot_data.excluded(t_unbind_tmp(i):t_bind_tmp(i))==1, 1));
        end
        t_bind_tmp = t_bind_ex.*t_bind_tmp;
        t_unbind_tmp = t_unbind_ex.*t_unbind_tmp;    
        t_bind_tmp = t_bind_tmp(t_bind_tmp>0);
        t_unbind_tmp = t_unbind_tmp(t_unbind_tmp>0);
        T_unbound = (t_bind_tmp - t_unbind_tmp).*T;
    else
        T_unbound = [];
    end
end

% rates
k_off = 1./mean(T_bound);
k_on = 1./mean(T_unbound);

% finalize

%Plot lifetime distribution
close all
figure(1)
subplot(1,2,1)
hist(T_bound,20)
title(['Total number of bound states: ' num2str(length(T_bound))])
subplot(1,2,2)
hist(T_unbound,20)
title(['Total number of unbound states: ' num2str(length(T_unbound))])
figure(1)
%end of function
end