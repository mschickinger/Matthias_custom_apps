function plot_twostate(X, Y, R, S)

T{2} = 1:length(X);
T{1} = T{2};
mT = T;
s = S(1);
mT{mod(s,2)+1}(1) = NaN;
i = 1;
while i<=length(mT{1})-1
    d = find(S(i+1:end)~=s,1);
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

c = {'red','blue'};
mSize = 5;

% median filtered R-vector
w = 11;
mR = medfilt1_trunc(R,w);

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