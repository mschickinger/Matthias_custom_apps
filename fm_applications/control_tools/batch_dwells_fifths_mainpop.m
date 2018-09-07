[status, list] = system('find /Users/matthiasschickinger/PhD/TIRFM_Data -iname *InOut3*','-echo');
cr = regexp(list,'\n');
initial = [1 cr(1:end-1)+1];
final = cr-1;
pathlist = cell(size(cr));
for i= 1:length(pathlist)
    pathlist{i} = list(initial(i):final(i));
end

%% Kick out all entries containing 'naive'
keep = ones(size(pathlist));
for i = length(pathlist):-1:1
    if ~isempty(regexp(pathlist{i},'naive','ONCE')) || ...
            ~isempty(regexp(pathlist{i},'Synthetic','ONCE')) || ...
            isempty(pathlist{i})
        keep(i) = 0;
    end
end
pathlist = pathlist(keep==1);
%%
output_dir = '/Users/matthiasschickinger/PhD/TIRFM_Data/00_TIRFM_Analysis/2018_04_25_dwells_fifths_mainpop/CDFs/';
if ~exist(output_dir,'dir')
    mkdir(output_dir)
end
for batchi = 1:length(pathlist)
    mainpop_dir = pathlist{batchi};
    display(mainpop_dir)
    cd(mainpop_dir)
    
    load('lts_main_pop.mat', 'INdices', 'filepaths')
    Nsamples = numel(filepaths);
    Nspecies = numel(INdices);
    Noffset = 0;
    display(Nspecies)
    if Nspecies == 1;
        SL{2} = zeros(0,4);
        SL{1} = SL{2};
        for nr_dataset = 1:Nsamples
            current_dir = filepaths{nr_dataset}(1:find(filepaths{nr_dataset}==filesep,1,'last'));
            display(current_dir)
            cd(current_dir)
            clear inputPostHMM_nost
            display('loading data...')
            load('dataPostHMM_nost.mat', 'inputPostHMM_nost')
            display('done')
            display('adding dataset...')
            setN = size(inputPostHMM_nost.indices,1);
            origIN = INdices{1}(INdices{1}>Noffset & ...
                    INdices{1}<=(Noffset+setN)) ...
                    - Noffset;
                display(numel(origIN))
            %origOUT = setdiff(1:setN,origIN);
            for i = reshape(origIN,1,[])
                tmp_straj = inputPostHMM_nost.state_trajectories{i};
                tmp_ex = inputPostHMM_nost.ex_int{i};
                tmp_states = getStates(tmp_straj, tmp_ex);
                for s = 1:2
                    if ~isempty(tmp_states{s})
                        tmp_states{s}(:,1) = tmp_states{s}(:,1)+inputPostHMM_nost.ranges(1);
                        tmp_states{s} = tmp_states{s}./10;
                        SL{s} = [SL{s}; ...
                            ones(size(tmp_states{s},1),1)*inputPostHMM_nost.indices(i,:) [tmp_states{s}]];
                    end
                end
            end
            Noffset = Noffset + setN;
            display('done')
        end

        % Split up in 15-minute intervals
        display('Splitting data up into 15-minute intervals...')
        Fmax = 0;
        for s = 1:2
            Fmax = max(Fmax,max(sum(SL{s}(:,3:4),2)));
        end
        Fmax = 900*ceil(Fmax/900);
        Fmax = min(Fmax,4500);

        boxes = cell(Fmax/900,2);
        for s = 1:2
            for i = 1:size(boxes,1)
                boxes{i,s} = SL{s}(SL{s}(:,3)>900*(i-1) & (sum(SL{s}(:,3:4),2)-1)<=900*i,:);
            end
        end
        display('done')

        % Produce histograms
        display('making plots...')
        close all
        sz = [800 600];
        fsz = 8;
        state_names = {'bound','unbound'};
        histfig = figure('Units','Pixels','Position',[1 1 sz],'Color',[1 1 1],...
            'Visible','on','PaperUnits','points','PaperSize',sz,'PaperPosition',[1 1 sz]);

        for s = 1:2
            T1=0.5;
            T99=0;
            subplot(2,1,s)
            legendary = cell(size(boxes,1),1);
            for i = 1:size(boxes,1)
                if ~isempty(boxes{i,s})
                    [counts, edges] = histcounts(boxes{i,s}(:,4),0:max(boxes{i,s}(:,4))/1000:max(boxes{i,s}(:,4))-1, ...
                    'Normalization','cdf');
                    if any(counts<1e-2)
                        T1 = min(T1,edges(find(counts<1e-2,1,'last')));
                    end
                    T99 = max(T99,edges(find(counts>=0.99,1)));
                    plot(edges(1:end-1)+diff(edges(1:2)),counts,'LineWidth',1.5)
                    legendary{i} = ['Group ', num2str(i) ' (' num2str(size(boxes{i,s},1)) ')'];
                else
                    plot(NaN,NaN)
                    legendary{i} = 'NaN';
                end
                hold on
            end
            ax = gca;
            ax.TickDir = 'out';
            ax.Layer = 'top';
            ax.LineWidth = .5;
            ax.FontName = 'Helvetica';
            ax.FontSize = fsz;
            ax.XLim = [T1 T99];
            ax.YLim = [0 1.0];
            ylabel('CDF','FontSize',fsz)
            xlabel([state_names{s} ' dwell times (s)'])
            box off
            legend(legendary,'Location','southeast','FontSize',12)
            if s==1
                title(mainpop_dir,'FontSize',14)
            end
        end
        prefix_out = sprintf('%03d',batchi);
        display('Printing...')
        print('-dpng',[output_dir prefix_out '_cdf.png'])
        for s = 1:2
            subplot(2,1,s)
            ax = gca;
            ax.XScale = 'log';
        end
        print('-dpng',[output_dir prefix_out '_logcdf.png'])

        display('done')
    else
        display('skipping this dataset...')
    end
    display('moving on...')   
end
display('All done')
