figure
tau = 5;
N = [2 5 10 50 100];
ts = cell(numel(N),1);
for p = 1:2
    subplot(2,1,p)
    hold off
end
for i = 1:numel(N)
    ts{i} = linspace(0,5*N(i)*tau,10000);
    subplot(2,1,1)
    plot(ts{i}./N(i),N(i)*erlangpdf(ts{i},1./tau,N(i)))
    hold on
    subplot(2,1,2)
    plot(ts{i}./N(i),erlangcdf(ts{i},1./tau,N(i)))
    hold on
end
