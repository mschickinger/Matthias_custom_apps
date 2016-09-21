function output = fitBands_obo( prfl )
% Fit a not-well-separated double-band one-by-one: first dominant band,
% then the smaller band, then both with starting values from the first two
% fits.

    fobo = figure('Units', 'normalized', 'Position', [0 .5 1 .7]);
    subplot(3,1,1)
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
    start = [1.5*fit2.fit_g1.a1 fit2.fit_g1.b1 fit2.fit_g1.c1 fit1.fit_g1.a1/1.5 fit1.fit_g1.b1 fit1.fit_g1.c1];
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

    %prepare output
    output = fit3;
end

