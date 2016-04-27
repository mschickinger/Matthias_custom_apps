% estimate half-value inhibitor concentration
%% Functions
%p_A = @(params,X) (1-params(1)).*1./(1+X./params(2));
p_A = @(params,X) 1./(1+X./params(1));
%p_A2 = @(params10,X) (1-params10(1)).*1./(1+(X-10)./params10(2));

%% Calculations
indices = {1:6 ; 7:12};
%c = [248/2 1417/2 2867/2 2166/2];
C_oligo_nM = [.1 .5 1 2 4 20];
% load bands_maxima.mat

for i = 1:2
    params_fit(i,:) = nlinfit(C_oligo_nM, gel271215.R8.max(:,2)', p_A, [.5]);
end

%% Plots
times = {'3:00 h';'6:02 h'};
close all
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
for i = 1:2
subplot(2,1,i)
hold off
plot(0:.5:50, p_A(params_fit(i,:), 0:.5:50))
hold on
plot(C_oligo_nM(1:end), [1 maxima.ratios(indices{i})'], 'o')
grid on
ylabel('Fraction of active particles')
xlabel('[competitor oligo] (nM)')
ylim([0 1])
legend({'Fit function', 'Gel Data'})
title(['Data from gel scan after ' times{i}])
end

%% Save
save fit_data.mat p_A c C_oligo_nM params_fit times indices
print('-depsc2', '-tiff', 'C_eff_fit_plots.eps')