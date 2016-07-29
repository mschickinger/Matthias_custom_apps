%E4
fzero = [(pts_E4fix(1):0.015:(pts_E4zero(1)-0.015))',zeros(length((pts_E4fix(1):0.015:(pts_E4zero(1)-0.015))),1)];
fzero = [fzero; [pts_E4zero',f_all_E4zero']];

ffix = [pts_E4fix',f_all_E4fix'];
ffix = [ffix; [((pts_E4fix(end)+0.015):0.015:pts_E4zero(end))' zeros(length(((pts_E4fix(end)+0.015):0.015:pts_E4zero(end))),1)]];

%%
%Schnittpunkt

delta = ffix - fzero;

stp = min(find(delta(:,2)<0));

%%
%Schnittfläche
%Fläche unter zero
afix = 0;
for i = 1:stp
    afix = afix + fzero(i,2) * 0.015;
end

%Fläche unter fix

azero = 0;
for i = stp:154
    azero = azero + ffix(i,2) * 0.015;
end

A = azero + afix


%%
%E1
fzero = [(pts_E1fix(1):0.015:(pts_E1E2zero_1(1)-0.015))',zeros(length((pts_E1fix(1):0.015:(pts_E1E2zero_1(1)-0.015))),1)];
fzero = [fzero; [pts_E1E2zero_1',f_all_E1E2zero']];

ffix = [pts_E1fix',f_all_E1fix'];
ffix = [ffix; [((pts_E1fix(end)+0.015):0.015:pts_E1E2zero_1(end))' zeros(length(((pts_E1fix(end)+0.015):0.015:pts_E1E2zero_1(end))),1)]];

%%
%Schnittpunkt

delta = ffix - fzero;

stp = min(find(delta(:,2)<0));

%%
%Schnittfläche
%Fläche unter zero
afix = 0;
for i = 1:stp
    afix = afix + fzero(i,2) * 0.015;
end

%Fläche unter fix

azero = 0;
for i = stp:154
    azero = azero + ffix(i,2) * 0.015;
end

A = azero + afix


%%
%E2
fzero = [(pts_E2fix(1):0.015:(pts_E1E2zero_1(1)-0.015))',zeros(length((pts_E2fix(1):0.015:(pts_E1E2zero_1(1)-0.015))),1)];
fzero = [fzero; [pts_E1E2zero_1',f_all_E1E2zero']];

ffix = [pts_E2fix',f_all_E2fix'];
ffix = [ffix; [((pts_E2fix(end)+0.015):0.015:pts_E1E2zero_1(end))' zeros(length(((pts_E2fix(end)+0.015):0.015:pts_E1E2zero_1(end))),1)]];

%%
%Schnittpunkt

delta = ffix - fzero;

stp = min(find(delta(:,2)<0));

%%
%Schnittfläche
%Fläche unter zero
afix = 0;
for i = 1:stp
    afix = afix + fzero(i,2) * 0.015;
end

%Fläche unter fix

azero = 0;
for i = stp:154
    azero = azero + ffix(i,2) * 0.015;
end

A_E2 = azero + afix


%%
%E3
fzero = [(pts_E3fix(1):0.015:(pts_E3zero(1)-0.015))',zeros(length((pts_E3fix(1):0.015:(pts_E3zero(1)-0.015))),1)];
fzero = [fzero; [pts_E3zero',f_all_E3zero']];

ffix = [pts_E3fix',f_all_E3fix'];
ffix = [ffix; [((pts_E3fix(end)+0.015):0.015:pts_E3zero(end))' zeros(length(((pts_E3fix(end)+0.015):0.015:pts_E3zero(end))),1)]];

%%
%Schnittpunkt

delta = ffix - fzero;

stp = min(find(delta(:,2)<0));

%%
%Schnittfläche
%Fläche unter zero
afix = 0;
for i = 1:stp
    afix = afix + fzero(i,2) * 0.015;
end

%Fläche unter fix

azero = 0;
for i = stp:154
    azero = azero + ffix(i,2) * 0.015;
end

A_E3 = azero + afix