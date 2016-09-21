for g = 1:length(lanes)
    lanes{g}.doubleBand = cell(size(lanes{g}.profiles));
    l = 1;
    while l<=length(lanes{g}.profiles)
        prfl = lanes{g}.profiles{l};
        fig = figure('Units', 'normalized', 'Position', [0 .5 1 .5]);
        plot(prfl)
        title(['Gel number ' num2str(g) ', lane number ' num2str(l) ' of ' num2str(length(lanes{g}.profiles))])
        action = questdlg('Fit?', 'Fit', 'Yes', 'One-by-one', 'Skip', 'Yes');
        if strcmp(action, 'Yes')
                h = imrect(gca);
                setResizable(h,'true');
                pos = round(wait(h));
                lanes{g}.doubleBand{l} = fitDoubleBand(prfl, pos(1), pos(3));
        elseif strcmp(action, 'One-by-one')
                lanes{g}.doubleBand{l} = fitDoubleBand_obo(prfl);
        end
        if ~strcmp(action, 'Skip')
            plot(prfl, 'o', 'MarkerSize', 8)
            hold on
            fit_x = lanes{g}.doubleBand{l}.arxv.boundaries(1):lanes{g}.doubleBand{l}.arxv.boundaries(2);
            plot(fit_x,lanes{g}.doubleBand{l}.fit_g2(fit_x),'--')
            plot(lanes{g}.doubleBand{l}.fit_g2.a1* ...
                exp(-(((1:length(prfl))-lanes{g}.doubleBand{l}.fit_g2.b1)/ ...
                lanes{g}.doubleBand{l}.fit_g2.c1).^2))
            plot(lanes{g}.doubleBand{l}.fit_g2.a2* ...
                exp(-(((1:length(prfl))-lanes{g}.doubleBand{l}.fit_g2.b2)/ ...
                lanes{g}.doubleBand{l}.fit_g2.c2).^2))
            title(['Gel number ' num2str(g) ', lane number ' num2str(l) ' of ' num2str(length(lanes{g}.profiles)) ...
                ': registered ' num2str(1+lanes{g}.doubleBand{l}.twopeaks) ' peak(s).'])
            pause
            xlim(lanes{g}.doubleBand{l}.arxv.boundaries)
            ok = questdlg('Fit OK?', 'Check fit', 'Yes', 'No', 'Cancel', 'Yes');
            if strcmp(ok,'Yes')
                l = l+1;
            else
                lanes{g}.doubleBand{l} = [];                    
            end
        else
            l = l+1;        
        end
        close(fig)        
    end
end

%% Fit bands one-by-one

g = 1;
l = 13;

fobo = figure('Units', 'normalized', 'Position', [0 .3 1 .7]);
subplot(3,1,1)
prfl = lanes{g}.profiles{l};
plot(prfl)
h = imrect(gca);
setResizable(h,'true');
pos1 = round(wait(h));
fit1 = fitMainBand(prfl, pos1(1), pos1(3));
f1 = fit1.fit_g1(1:length(prfl));
plot(prfl, 'o', 'MarkerSize', 8)
hold on
plot(f1)

subplot(3,1,2)
plot(prfl-f1);
h = imrect(gca);
setResizable(h,'true');
pos2 = round(wait(h));
fit2 = fitMainBand(prfl-f1, pos2(1), pos2(3));
f2 = fit2.fit_g1(1:length(prfl));
plot(prfl-f1, 'o', 'MarkerSize', 8)
hold on
plot(f2)

subplot(3,1,1)
hold on
plot(f2)

lower = min(pos1(1),pos2(1));
width = max(pos1(1)+pos1(3),pos2(1)+pos2(3))-lower;
start = [fit1.fit_g1.a1 fit1.fit_g1.b1 fit1.fit_g1.c1 fit2.fit_g1.a1 fit2.fit_g1.b1 fit2.fit_g1.c1];
fit3 = fitDoubleBand(prfl, lower, width, 'start', start);
f3 = fit3.fit_g2(1:length(prfl));

subplot(3,1,3)
plot(prfl, 'o', 'MarkerSize', 8)
hold on
plot(fit3.fit_g2.a1* ...
            exp(-(((1:length(prfl))-fit3.fit_g2.b1)/ ...
            fit3.fit_g2.c1).^2))
        plot(fit3.fit_g2.a2* ...
            exp(-(((1:length(prfl))-fit3.fit_g2.b2)/ ...
            fit3.fit_g2.c2).^2))
plot(f3,'k--')

close(fobo)
