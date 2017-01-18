function interval = longest_good_interval(XY,thr1,thr2)
%   Find the best suited interval for HMM analysis in a XY-time-tracjectory

%   Input:  (1) XY: 2xN trajectory of X- and Y-coordinates
%           (2) thr1: threshold for strict rejection of frames
%           (3) thr2: threshold for rejection of intervals with a certain
%                       tolerance

Lmin = 10000;

% first round
I = [0 find(max(abs(XY),[],1) > thr1) size(XY,2)+1];
L = diff(I) - 1;

I = I(L>=Lmin) + 1;
L = L(L>=Lmin);

% second round
tol = 0.001;
keep = zeros(size(I));
for i = 1:length(keep)
    tmpD = max(abs(XY(:,I(i)+(0:L(i)-1))),[],1);
    keep(i) = sum(tmpD > thr2)/length(tmpD) <= tol;
end
I = I(keep==1);
L = L(keep==1);
[~,IND] = max(L);

interval = [I(IND) I(IND)+L(IND)-1];


end

