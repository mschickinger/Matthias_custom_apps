function plot_twostate(XY, S, w, R)

XY = reshape(XY,2,length(XY));
X = XY(1,:);
Y = XY(2,:);

if nargin < 4
    R = sqrt(X.^2+Y.^2);
    if nargin < 3
        w = 2;
    end
end

T{2} = 1:length(X);
T{1} = T{2};

% median filtered R-vector
%w = 11;
%mR = medfilt1_trunc(R,w);
mR = RMSfilt2d(XY',w)';

transitions = find(diff(S)~=0)+1;
interS = S(transitions);
interT = transitions - 0.5;
interR = (mR(transitions)+mR(transitions-1))./2;

[mT{2}, IDX] = sort([T{2} interT]);
mT{1} = mT{2};
mS = [S interS];
mS = mS(IDX);
mR = [mR interR];
mR = mR(IDX);

s = mS(1);
mT{mod(s,2)+1}(1) = NaN;
i = 1;
while i<=length(mT{1})-1
    d = find(mS(i+1:end)~=s,1);
    if ~isempty(d)
        mT{mod(s,2)+1}(i+1:i+d-1) = NaN;
        i = i + d;
        s = mod(s,2) + 1;
    else
        mT{mod(s,2)+1}(i+1:end) = NaN;
        i = length(mT{1});
    end
end

T{1}(S==2) = NaN;
T{2}(S==1) = NaN;

% parameters for plotting
c = {'red','blue'};
mSize = 5;

subplot(4,1,1)
% median filtered radius
hold off
for s = 1:2
    plot(mT{s},mR,'-','Color',c{s})
    hold on
end

subplot(4,1,2)
% radius
hold off
for s = 1:2
    plot(T{s},R,'.','Color',c{s},'MarkerSize', mSize)
    hold on
end

subplot(4,1,3)
% x-displacement
hold off
for s = 1:2
    plot(T{s},X,'.','Color',c{s},'MarkerSize', mSize)
    hold on
end

subplot(4,1,4)
% y-displacement
hold off
for s = 1:2
    plot(T{s},Y,'.','Color',c{s},'MarkerSize', mSize)
    hold on
end

end