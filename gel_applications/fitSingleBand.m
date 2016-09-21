function output = fitMainBand(profile, lower, width)     
    % peak
    [pk, loc] = max(profile);
    
    hm = profile(loc:end);
    hm = find(hm<pk/2,1);
    c_start = 1.2*hm;
    
    % Set up fittype and options.
    ft = fittype( 'gauss1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 0 0];
    opts.StartPoint = [pk loc c_start];
    
    xData = (lower+(1:width))';
    yData = reshape(profile(lower+(1:width)),width,1);
    
    % Fit model to data.
    [result, gof] = fit(xData, yData, ft, opts);
    
    % prepare output data
    output = struct('pk', pk, 'loc', loc, 'fit_g1', result, 'gof', gof, ...
        'arxv', struct('start', opts.StartPoint, 'lower', lower));
end