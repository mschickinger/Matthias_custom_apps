function [ ratio ] = ratio_from_skg2( skg2 )
% Get ratio of leading band over sum of both bands from a sum of two skewed
% normal distributions

params = [skg2.A1*skg2.sigma1 skg2.mu1; skg2.A2*skg2.sigma2 skg2.mu2];
[~,I] = max(params(:,2));
ratio = params(I,1)/sum(params(:,1));


end

