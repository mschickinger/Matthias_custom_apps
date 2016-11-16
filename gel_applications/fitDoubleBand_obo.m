function output = fitDoubleBand_obo( prfl )
% Fit a not-well-separated double-band one-by-one: first dominant band,
% then the smaller band, then both with starting values from the first two
% fits.

    fobo = figure('Units', 'normalized', 'Position', [0 .5 1 .7]);
    subplot(3,1,1)
    plot(prfl)
    h = imrect(gca);
    setResizable(h,'true');
    pos1 = round(wait(h));
    fit1 = fitSingleBand(prfl, pos1(1), pos1(3));
    f1 = fit1.fit_skg1(1:length(prfl));
    plot(prfl, 'o', 'MarkerSize', 8)
    hold on
    plot(f1)

    subplot(3,1,2)
    plot(prfl-f1);
    h = imrect(gca);
    setResizable(h,'true');
    pos2 = round(wait(h));
    fit2 = fitSingleBand(prfl-f1, pos2(1), pos2(3));
    f2 = fit2.fit_skg1(1:length(prfl));
    plot(prfl-f1, 'o', 'MarkerSize', 8)
    hold on
    plot(f2)

    subplot(3,1,1)
    hold on
    plot(f2)

    lower = min(pos1(1),pos2(1));
    width = max(pos1(1)+pos1(3),pos2(1)+pos2(3))-lower;
    %start = [fit2.fit_g1.a1 fit2.fit_g1.b1 fit2.fit_g1.c1 fit1.fit_g1.a1 fit1.fit_g1.b1 fit1.fit_g1.c1];
    start = [fit2.fit_skg1.A fit2.fit_skg1.mu fit2.fit_skg1.sigma ...
            fit1.fit_skg1.A fit1.fit_skg1.mu fit1.fit_skg1.sigma ...
            min(fit2.fit_skg1.alpha,fit1.fit_skg1.alpha)];
    fit3 = fitDoubleBand(prfl, lower, width, 'start', start);
    f3 = fit3.fit_skg2(1:length(prfl));
    
    subplot(3,1,3)
    plot(prfl, 'o', 'MarkerSize', 8)
    hold on
    skewGauss = @(A,mu,sigma,alpha,x) A.*exp(-(x-mu).^2/(2*sigma^2)).*2.*pi.*normcdf(alpha.*(x-mu)./sigma);
%     plot(fit3.fit_g2.a1* ...
%                 exp(-(((1:length(prfl))-fit3.fit_g2.b1)/ ...
%                 fit3.fit_g2.c1).^2))
%             plot(fit3.fit_g2.a2* ...
%                 exp(-(((1:length(prfl))-fit3.fit_g2.b2)/ ...
%                 fit3.fit_g2.c2).^2))
    plot(skewGauss(fit3.fit_skg2.A1,fit3.fit_skg2.mu1,fit3.fit_skg2.sigma1,fit3.fit_skg2.alpha,1:length(prfl)))
    plot(skewGauss(fit3.fit_skg2.A2,fit3.fit_skg2.mu2,fit3.fit_skg2.sigma2,fit3.fit_skg2.alpha,1:length(prfl)))
    plot(f3,'k--')
    pause
    close(fobo)

    %prepare output
    output = fit3;
end

