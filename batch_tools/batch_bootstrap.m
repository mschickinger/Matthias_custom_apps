[status, list] = system('find /Users/matthiasschickinger/PhD/TIRFM_Data -iname lts_main_pop.mat','-echo');
cr = regexp(list,'\n');
initial = [1 cr(1:end-1)+1];
final = cr-1;
pathlist = cell(size(cr));
for i= 1:length(pathlist)
    pathlist{i} = list(initial(i):final(i));
end

%%
for i = 1:length(pathlist)
    clear lifetimes INdices Tmin Tmax Nspecies bootstat bootsam bootkhat SID
    current_dir = pathlist{i}(1:find(pathlist{i}==filesep,1,'last'));
    cd(current_dir)
    % determine sample ID:
    [~,foo] = system('ls -1');
    foobar = regexp(foo,'_IN_');
    if ~isempty(foobar)
        foo(foobar(1):end) = '';
        foobar = regexp(foo,'\n');
        foo(1:foobar(end)) = '';
        SID = foo;
    else
        SID = 'EnterSID';
    end
    display('*************************************************')
    display(['File ' num2str(i) ' of ' num2str(length(pathlist)) ':'])
    display(pathlist{i})
    display(['Sample ID is: ' SID])
    display('Loading file...')
    load(pathlist{i})
    if iscell(lifetimes) && exist('Tmin','var')
        InOutStats
    end
    if ~iscell(lifetimes)
        display('Outdated lifetime format - moving on to next dataset')
    elseif ~exist('Tmin','var')
        display('No Tmin values stored in file - moving on to next dataset')
    elseif exist('rates_bootstrap.mat','file')
        display('Bootstrapping analysis already done - moving on to next dataset')
    else
        display('Starting bootstrap.')        
        % Error estimate by bootstrapping: Get distribution
        Nspecies = numel(lifetimes);
        bootstat = cell(Nspecies,2);
        bootsam = cell(Nspecies,2);
        bootkhat = cell(Nspecies,1);
        Nsam = 1e4;
        ax = cell(2,1);
        %
        for j = 1:Nspecies
            LT = {vertcat(lifetimes{j}.ALL{INdices{j},1}) vertcat(lifetimes{j}.ALL{INdices{j},2})};
            Tmax = max(max(LT{1}),max(LT{2}))+0.1;
            for k = 2:-1:1
                [bootstat{j,k},bootsam{j,k}] = bootstrp(Nsam,@mean,LT{k});
            end
            display(['Species #' num2str(j) ' of ' num2str(Nspecies) ': Bootstrapping done. Getting corrected rates...'])
            bootkhat{j} = zeros(Nsam,2);
            for i = 1:Nsam
                bootkhat{j}(i,:) = get_corrected_rates({LT{1}(bootsam{j,1}(:,i)) LT{2}(bootsam{j,2}(:,i))},Tmin,Tmax);
            end
            display(['Species #' num2str(j) ' of ' num2str(Nspecies) ': Obtained corrected rates - moving on...'])
            %{
            figure
            for k = 1:2
                subplot(2,2,k)
                histogram(1./bootkhat{j}(:,k))
                title([Names{j} ', state ' num2str(k) ', corrected'], 'FontSize', 12)
                ax{1} = gca;
                subplot(2,2,k+2)
                histogram(bootstat{j,k})
                title([Names{j} ', state ' num2str(k) ', mean'], 'FontSize', 12)
                ax{2} = gca;
                for i = 1:2
                    ax{i}.XLim = [min(ax{1}.XLim(1),ax{2}.XLim(1)) max(ax{1}.XLim(2),ax{2}.XLim(2))];
                end
            end
            %}
        end
        display('***************************************************')
        display('Bootstrapping done.')
        display('***************************************************')

        % Save bootstrap data
        cd(current_dir)
        save -v7.3 rates_bootstrap.mat bootsam bootstat bootkhat

        % Get mean value and 3*sigma error
        if ~exist('SID','var')
            tmp = inputdlg({'Enter sample ID:'},'SID',1,{'M000'});
            SID = tmp{1};
        end
        % make .txt file for Igor Pro plotting
        waveNames = {[SID 'koffboot'], ...
                    [SID 'konboot'], ...
                    [SID 'ekoffboot'], ...
                    [SID 'ekonboot'], ...
                    [SID 'Keqboot'], ...
                    [SID 'eKeqboot']};
        datArray = zeros(Nspecies,numel(waveNames));
        errMult = 3;
        for j = 1:Nspecies
            for k = 1:2
                datArray(j,k) = mean(bootkhat{j}(:,k));
                datArray(j,k+2) = errMult*std(bootkhat{j}(:,k));
            end
        end
        datArray(:,5) = datArray(:,2)./datArray(:,1);
        datArray(:,6) = datArray(:,5).*sqrt((datArray(:,3)./datArray(:,1)).^2+ ...
                                            (datArray(:,4)./datArray(:,2)).^2);

        fileID = fopen([SID '_bootRates.txt'],'w');
        for i = 1:numel(waveNames)
            fprintf(fileID, [waveNames{i} '\t']);
        end
        fprintf(fileID,'\n');
        fclose(fileID);
        dlmwrite([SID '_bootRates.txt'],datArray, 'delimiter', '\t', '-append')
        %}
    end
end