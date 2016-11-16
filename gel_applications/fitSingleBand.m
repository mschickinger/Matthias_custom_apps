function output = fitSingleBand(profile, lower, width)     
    % peak
    [pk, loc] = max(profile(lower+(1:width)));
    loc = loc+lower;
    hm = profile(loc:end);
    hm = find(hm<pk/2,1);
    c_start = 1.2*hm;
    
    % Set up fittype and options for pre-fit:
    ft = fittype( 'gauss1' );
    
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 0 0];
    opts.Upper = [Inf Inf Inf];
    opts.StartPoint = [pk loc c_start];
        
    xData = (lower+(1:width))';
    yData = reshape(profile(lower+(1:width)),width,1);
    
    % Fit model to data.
    presult = fit(xData, yData, ft, opts);
    
    % Update fit type and options for actual fit:
    skewGauss = @(A,mu,sigma,alpha,x) A.*exp(-(x-mu).^2/(2*sigma^2)).*2.*normcdf(alpha.*(x-mu)./sigma); % Integrated area: A*sigma.
    opts.Lower = [0 0 0 -3];
    opts.Upper = [Inf Inf Inf 0];
    opts.StartPoint = [presult.a1/presult.c1 presult.b1 presult.c1 -1];
    
    % Fit skew normal to data using output from pre-fit as start values:
    [result, gof] = fit(xData, yData, skewGauss, opts);
    
    % prepare output data
    output = struct('pk', pk, 'loc', loc, 'fit_skg1', result, 'gof', gof, ...
        'arxv', struct('start', opts.StartPoint, 'lower', lower));
end