Tmin = [1.0 1.5];
TPF = 50;

lifeframes = lts_strict_cutoff(state_trajectories,Tmin/(2*TPF/1000));

taus = [0 0];
for s = 1:2
    taus(s) = mean(lifeframes{s})*2*TPF/1000;
end

%taus = [20.965 31.79];

optimfun = @(k) ...
    (exp(-Tmin(2)*k(2))-1/(k(1)*taus(1))).^2 + ...
    (exp(-Tmin(1)*k(1))-1/(k(2)*taus(2))).^2;
              
kstart = 1./taus;
khat = fminsearch(optimfun,kstart);
taus
1./khat

%%
Tmin = [1.5 0.8];
Tmax = 1000;
lifeframes = lts_strict_cutoff(state_trajectories,Tmin/(2*TPF/1000));
testdata = cell(2,1);
taus = [0 0];
for i = 1:2
    testdata{i} = lifeframes{i}.*(2*TPF/1000);
    testdata{i}(testdata{i}<Tmin(i) | testdata{i}>Tmax) = [];
    taus(i) = mean(testdata{i});
end
tauhat = [0 0];
pci = zeros(2);
for i = 1:2
    testpdf = @(t,tau)exppdf_mod(t,tau,Tmin(i),Tmax);
    testcdf = @(t,tau)expcdf_mod(t,tau,Tmin(i),Tmax);
    [tauhat(i), pci(i,:)] = mle(testdata{i},'pdf',testpdf,'start',mean(testdata{i}),'cdf',testcdf);
end

figure('Units','normalized','Position',[0 0 1 1])
for i = 1:2
    subplot(1,2,i)
    lftms = logspace(-1,3,1000);
    cumcts = zeros(size(lftms));
    for j = 1:length(lftms)
        cumcts(j) = sum(testdata{i}<=lftms(j));
    end
    cumcts = cumcts/length(testdata{i});
    semilogx(lftms,cumcts)
    hold on
    semilogx(lftms,expcdf(lftms,taus(i)),'k--')
    semilogx(lftms(lftms>Tmin(i)),expcdf_mod(lftms(lftms>Tmin(i)),tauhat(i),Tmin(i),Tmax),'r--')
    title(['Tmin = ' num2str(Tmin(i)) ', tau_hat = ' num2str(tauhat(i)) ' s, vs. tau = ' num2str(taus(i)) ' s.'],'FontSize', 16)
end

kstart = 1./tauhat;
tauhat
khat = fminsearch(optimfun,kstart);
1./khat
