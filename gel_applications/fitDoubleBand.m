function output = fitDoubleBand(profile, lower, width, varargin)
    
    %parse input
    p = inputParser;
    addRequired(p, 'profile', @isnumeric)
    addRequired(p, 'lower', @isscalar)
    addRequired(p, 'width', @isscalar)
    addParameter(p, 'start', [], @isnumeric)
    
    parse(p, profile, lower, width, varargin{:})
    start = p.Results.start;
       
    % peaks
    sub_profile = profile(lower+1:lower+width);
    [pks, locs, w, prom] = findpeaks(sub_profile);
    [~,I] = sort(prom);
    if length(I)>1
        I = sort(I(end-1:end));
    end
    pks = pks(I);
    locs = locs(I)+lower;
    w = w(I);
    diffs = zeros(size(profile));
    diffs(2:end) = sign(profile(2:end)-profile(1:end-1));
    
    if min(prom(I))>0.001*max(pks) && length(I)>1 && isempty(p.Results.start)
        % sigmas
        hm1 = profile(1:locs(1));
        hm1 = find(hm1<pks(1)/2,1,'last');
        if ~isempty(hm1)
            c1_start = 1.2*(locs(1)-hm1);
        else
            c1_start = w(1);
        end
        
        hm2 = profile(locs(2)+1:end);
        hm2 = find(hm2<pks(2)/2,1);
        if ~isempty(hm2)
            c2_start = 1.2*hm2;
        else
            c2_start = w(2);
        end
        a = find(diffs==-1);
        b = find(diffs==1);
        ai = find(a<locs(1),1,'last');
        if ~isempty(ai)
            ai = a(ai);
        else
            ai = lower+1;
        end
        bi = find(b>locs(2),1);
        if ~isempty(bi)
            bi = b(bi)-1;
        else
            bi = lower+width;
        end   
        start = [pks(1) locs(1) c1_start pks(2) locs(2) c2_start];
        twopeaks = 1;
    else
        ai = lower+find(diffs(lower+1:end)>0,1)-1;
        bi = find(diffs(1:(lower+width))<0,1,'last');
        twopeaks = 0;
    end
    xData = (ai:bi)';
    yData = reshape(profile(xData),length(xData),1);
    
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    if isempty(p.Results.start)
        % Set up fittype and options for pre-fit:
        ft = fittype( 'gauss2' ); 
        opts.Lower = [0 0 0 0 0 0];
        opts.StartPoint = start;

        % Pre-fit gauss2 model to data.
        presult = fit( xData, yData, ft, opts);
        start = [presult.a1/presult.c1 presult.b1 presult.c1 ...
            presult.a2/presult.c2 presult.b2 presult.c2 -1];
    end
    
    % Update fit type and options for actual fit:
    skewGauss = @(A,mu,sigma,alpha,x) A.*exp(-(x-mu).^2/(2*sigma^2)).*2.*pi.*normcdf(alpha.*(x-mu)./sigma); % Integrated area: A*sigma.
    ft = @(A1,mu1,sigma1,A2,mu2,sigma2,alpha,x) skewGauss(A1,mu1,sigma1,alpha,x) + skewGauss(A2,mu2,sigma2,alpha,x);
    
    opts.Lower = [0 0 0 0 0 0 -3];
    opts.Upper = [Inf Inf Inf Inf Inf Inf 0];
    opts.StartPoint = start;
    
    % Fit model to data.
    [result, gof] = fit( xData, yData, ft, opts);
    
    % prepare output data
    %tmp = sub_profile(ceil(min(result.b1,result.b2)):floor(max(result.b1,result.b2)));
    %[~,ind] = min(tmp);
    %twopeaks = ind ~= 1 & ind ~= length(tmp);
    if ~isempty(opts.StartPoint)
        start = opts.StartPoint;
    end
    output = struct('pks', pks, 'locs', locs, 'fit_skg2', result, 'gof', gof, ...
        'arxv', struct('start', start, 'boundaries', [ai bi], 'lower', lower, ...
        'width', width), 'twopeaks', twopeaks);
    if exist('presult', 'var')
        output.fit_g2 = presult;
    end
end