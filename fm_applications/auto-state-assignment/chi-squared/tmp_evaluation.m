%i = 0;
%%
i  = i+1;

%%
subplot(2,1,1)
hold off
plot(sample_data{sample_list(i),1}.rms10, 'k-')
hold on
plot(sc2.steptrace{i}, 'r')
ylim([0 2])

subplot(2,1,2)
plot(sc2.counter_chi2{i}./sc2.chi2{i})
title(['Index: ' num2str(i) ', spot pair: ' num2str(sample_list(i))], 'FontSize', 24)

figure(gcf)
pause
%%
yesno{i} = questdlg([num2str(i) ': need more?'] , [num2str(i) ': need more?']);


%%
for i = (find(strcmp(yesno,'Yes')==1))'
    subplot(3,1,1)
    hold off
    plot(sample_data{sample_list(i),1}.rms10, 'k-')
    hold on
    plot(sc2.steptrace{i}, 'r')
    ylim([0 2])
    
    subplot(3,1,2)
    divided = (sc2.counter_chi2{i}./sc2.chi2{i});
    plot(divided)
    title(['Index: ' num2str(i) ', spot pair: ' num2str(sample_list(i))], 'FontSize', 24)
    
    subplot(3,1,3)
    tmp = zeros(1,length(sc2.chi2{i}));
    for j = 6:length(tmp)
        tmp(j) = abs(divided(j)-mean(divided(j-5:j-1)));
    end
    plot(tmp)
    figure(gcf)
    pause
end