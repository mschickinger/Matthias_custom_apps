% estimate half-value inhibitor concentration
%% Functions
p_A = @(params,X) (1-params(1)).*1./(1+(X-params(2))./params(3));
%p_A2 = @(params10,X) (1-params10(1)).*1./(1+(X-10)./params10(2));

%% Calculations
indices = [2 3 5:8 10:13 15];
c = [248/2 1417/2 2867/2 2166/2];
C_oligo_nM = 1/50*[c(1)*[2.5 5 7.5] c(2)*[2 2.5 3 4 5] c(3)*5 c(4)*[5 10]];
% load bands_maxima.mat

for i = 1:3
params_fit(i,:) = nlinfit(C_oligo_nM(2:end), maxima.ratios(indices(2:end),i+1)', p_A, [.25 10 100]);
end

%% Plots
times = {'3:00 h','4:30 h','6:00 h'};
close all
figure('Position', [1 1 1920 1080], 'PaperPositionMode', 'auto')
for i = 1:3
subplot(3,1,i)
hold off
plot(0:.5:250, p_A(params_fit(i,:), 0:.5:250))
hold on
plot(C_oligo_nM, maxima.ratios(indices,i+1), 'o')
plot(sum(params_fit(i,2:3))*[1 1], [0 1])
plot([0 C_oligo_nM(2)], [0 2*maxima.ratios(indices(1),i+1)], '--')
grid on
ylabel('Fraction of active particles')
xlabel('[interaction oligos] (nM)')
ylim([0 1])
legend({'Fit function', 'Gel Data', 'C_{eff}+ [scaffold]'})
title(['Data from gel scan after ' times{i}])
plot([0 250], (1-params_fit(i,1))./2*[1 1], '--', 'Color', .6*[1 1 1])
plot([0 250], (1-params_fit(i,1).*[1 1]), '--', 'Color', .6*[1 1 1])
end

%% Save
save fit_data.mat p_A c C_oligo_nM params_fit times indices
print('-depsc2', '-tiff', 'C_eff_fit_plots.eps')