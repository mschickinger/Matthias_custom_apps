%% LOAD DATA
clear lanes
[FileName, PathName] = uigetfile([gel_dir filesep '*.mat'], 'Pick a data file');
tmp = load([PathName FileName], 'lanes');
lanes = tmp.lanes;

%%
for g = 1:length(lanes)
    lanes{g}.doubleBand = cell(size(lanes{g}.profiles));
    l = 1;
    while l<=length(lanes{g}.profiles)
        prfl = lanes{g}.profiles{l};
        fig = figure('Units', 'normalized', 'Position', [0 .5 1 .5]);
        plot(prfl)
        title(['Gel number ' num2str(g) ', lane number ' num2str(l) ' of ' num2str(length(lanes{g}.profiles))])
        action = questdlg('Fit?', 'Fit', 'Yes', 'One-by-one', 'Skip', 'Yes');
        if strcmp(action, 'Yes')
                h = imrect(gca);
                setResizable(h,'true');
                pos = round(wait(h));
                lanes{g}.doubleBand{l} = fitDoubleBand(prfl, pos(1), pos(3));
        elseif strcmp(action, 'One-by-one')
                lanes{g}.doubleBand{l} = fitDoubleBand_obo(prfl);
                figure(fig)
        end
        if ~strcmp(action, 'Skip')
            plot(prfl, 'o', 'MarkerSize', 8)
            hold on
            fit_x = lanes{g}.doubleBand{l}.arxv.boundaries(1):lanes{g}.doubleBand{l}.arxv.boundaries(2);
            plot(fit_x,lanes{g}.doubleBand{l}.fit_skg2(fit_x),'--')
%             plot(lanes{g}.doubleBand{l}.fit_g2.a1* ...
%                 exp(-(((1:length(prfl))-lanes{g}.doubleBand{l}.fit_g2.b1)/ ...
%                 lanes{g}.doubleBand{l}.fit_g2.c1).^2))
%             plot(lanes{g}.doubleBand{l}.fit_g2.a2* ...
%                 exp(-(((1:length(prfl))-lanes{g}.doubleBand{l}.fit_g2.b2)/ ...
%                 lanes{g}.doubleBand{l}.fit_g2.c2).^2))
            skewGauss = @(A,mu,sigma,alpha,x) A.*exp(-(x-mu).^2/(2*sigma^2)).*2.*pi.*normcdf(alpha.*(x-mu)./sigma);
            plot(skewGauss(lanes{g}.doubleBand{l}.fit_skg2.A1,lanes{g}.doubleBand{l}.fit_skg2.mu1,lanes{g}.doubleBand{l}.fit_skg2.sigma1,lanes{g}.doubleBand{l}.fit_skg2.alpha,1:length(prfl)))
            plot(skewGauss(lanes{g}.doubleBand{l}.fit_skg2.A2,lanes{g}.doubleBand{l}.fit_skg2.mu2,lanes{g}.doubleBand{l}.fit_skg2.sigma2,lanes{g}.doubleBand{l}.fit_skg2.alpha,1:length(prfl)))
            title(['Gel number ' num2str(g) ', lane number ' num2str(l) ' of ' num2str(length(lanes{g}.profiles)) ...
                ': registered ' num2str(1+lanes{g}.doubleBand{l}.twopeaks) ' peak(s).'])
            pause
            xlim(lanes{g}.doubleBand{l}.arxv.boundaries)
            ok = questdlg('Fit OK?', 'Check fit', 'Yes', 'No', 'Cancel', 'Yes');
            if strcmp(ok,'Yes')
                l = l+1;
            else
                lanes{g}.doubleBand{l} = [];                    
            end
        else
            l = l+1;        
        end
        close(fig)        
    end
end
display('Done.')
%% Save data
save([PathName FileName], 'lanes', '-append')
display('Data saved.')
display('End of program.')