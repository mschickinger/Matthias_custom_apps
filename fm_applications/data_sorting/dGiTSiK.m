% Selects spot pairs that will be analyzed further based on criteria: 
% Interference by neighbouring spots? Attachment issues? Promiscuity?
% Short lifetime and/or bad SNR? 

close all
clear data
clear GiTSiK
data_path = cd;
%% Load data
tmp = 0;
if exist('GiTSiK.mat', 'file')
    tmp = strcmp(questdlg('Load existing GiTSiK file?'),'Yes');
end
display('Loading data...')
load('data_spot_pairs.mat')
if tmp
    load('GiTSiK.mat')
else
    GiTSiK.sample = [];
end
clear tmp

% Old analysis scheme:
%load('all_data_struct.mat')

display('data loaded')
%% Prepare array
N_movie = size(data,1);
if ~isfield(GiTSiK, 'sample') || isempty(GiTSiK.sample)
    ident = inputdlg({'Sample:', 'Date: JJJJ_MM_DD'}, 'Identify');
    GiTSiK.sample = ident(1);
    GiTSiK.date = ident(2);
    GiTSiK.categorized = cell(N_movie,1);
    GiTSiK.behaviour = cell(N_movie,1);
    for m = 1:N_movie
        GiTSiK.categorized{m} = zeros(size(data{m},1),1);
        GiTSiK.behaviour{m} = zeros(size(GiTSiK.categorized{m}));
    end
end

%% set display settings
scrsz = get(groot,'ScreenSize');
vert = [10 165 218 380 420 560 615 760 25 166 167 345];
%figure('OuterPosition', [0 scrsz(4)./10 scrsz(3).*.65 scrsz(4).*9/10])
%figure('OuterPosition', [scrsz(3).*.6 scrsz(2) scrsz(3).*.4 scrsz(3)./3])
%% Show images and assign spot (pair) category
close all
f = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0 0 1 1]);
m = 1;
while m <= N_movie
    if isempty(GiTSiK.categorized{m})
        GiTSiK.categorized{m} = zeros(size(data{m},1),1);
        s = 1;
    else
        s = find(GiTSiK.categorized{m} == 0, 1);
        if isempty(s)
            s = size(data{m},1) + 1;
        end
    end
    while s <= size(data{m},1)
        tmp_vwcm = imread([data_path filesep 'vwcm_traces' filesep 'traces_RMS_hist_m' num2str(m) '_s' num2str(s) '.png']);
        tmp_disp = imread([data_path filesep 'disp_from_map_traces' filesep 'disp_from_map_m' num2str(m) '_s' num2str(s) '.png']);
        tmp_traces = [tmp_vwcm([vert(1):vert(2) vert(3):vert(4) vert(5):vert(6) vert(7):vert(8)],:,:) ;...
            tmp_disp([vert(9):vert(10) vert(11):vert(12)],:,:)];
        tmp_pos = imread([data_path filesep 'positions' filesep 'positions_m' num2str(m) '_s' num2str(s) '.png']);
        subplot('Position',[0 0 .61 1])
        imshow(tmp_traces, 'Border', 'tight')
        subplot('Position',[.63 .42 .44 .58])
        imshow(tmp_pos, 'Border', 'tight')
        set(f, 'Visible','on');
        
        category = 0; 
        categorylist = {'Keep', 'Neighbour too close', 'Attachment issues', 'Promiscuous particle' ,'Bad lifetime/SNR', 'REVIEW PREVIOUS PAIR'};
        %[category, ok] = listdlg('PromptString', 'What up with that spot pair?', 'ListString', categorylist, 'SelectionMode', 'single');
        bg = uibuttongroup('Position', [.7 .2 .18 .2], 'Visible', 'off');
        
        p1 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [20 150 50 30],...
            'String', categorylist{1}, 'Callback', 'category=1; uiresume(gcbf)');
        
        p2 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 150 120 30],...
            'String', categorylist{2}, 'Callback', 'category=2; uiresume(gcbf)');
        
        p3 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [210 150 100 30],...
            'String', categorylist{3}, 'Callback', 'category=3; uiresume(gcbf)');
        
        p4 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [40 110 120 30],...
            'String', categorylist{4}, 'Callback', 'category=4; uiresume(gcbf)');
        
        p5 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [170 110 120 30],...
            'String', categorylist{5}, 'Callback', 'category=5; uiresume(gcbf)');
        
        p6 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 70 150 30],...
            'String', categorylist{6}, 'Callback', 'category=6; uiresume(gcbf)');
        
        e1 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 30 150 30],...
            'String', 'Abort sorting', 'Callback', ['m = N_movie; s = size(data{N_movie},1)+1; ' ...
            'uiresume(gcbf); close all']);
        
        set(bg, 'Visible', 'on')
        uiwait(gcf)
        %pause

        %if ok            
            if category == size(categorylist, 2)
                s = s-1;
                if s == 0
                    if m==1
                        s = 1;
                    else
                        m = m-1;
                        s = size(data{m},1);
                    end
                end
            elseif m <= N_movie
                GiTSiK.categorized{m}(s) = category; % Keep:1,Neighbour:2, Attachment:3, Promiscuous:4, Lifetime/SNR:5, Cancel:0
                s = s+1;
            end
        %end
        %}
       %close all
    end
    m = m+1;
end

%% Assign spot behaviour (permanently mobile, permanently stationary, switching of unknown)
close all
f = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0 0 1 1]);
m = 1;
while m <= N_movie
    keeps = find(GiTSiK.categorized{m} == 1);
    if isempty(GiTSiK.behaviour{m})
        GiTSiK.behaviour{m} = zeros(size(data{m},1),1);
        i = 1;
    else
        i = find(GiTSiK.behaviour{m}(keeps') == 0, 1);
        if isempty(i)
            i = length(find(GiTSiK.categorized{m} == 1)) + 1;
        end
    end
    while i <= length(find(GiTSiK.categorized{m} == 1))
        s = keeps(i);
        tmp_vwcm = imread([data_path filesep 'vwcm_traces' filesep 'traces_RMS_hist_m' num2str(m) '_s' num2str(s) '.png']);
        tmp_disp = imread([data_path filesep 'disp_from_map_traces' filesep 'disp_from_map_m' num2str(m) '_s' num2str(s) '.png']);
        tmp_traces = [tmp_vwcm([vert(1):vert(2) vert(3):vert(4) vert(5):vert(6) vert(7):vert(8)],:,:) ;...
            tmp_disp([vert(9):vert(10) vert(11):vert(12)],:,:)];
        tmp_pos = imread([data_path filesep 'positions' filesep 'positions_m' num2str(m) '_s' num2str(s) '.png']);
        subplot('Position',[0 0 .61 1])
        imshow(tmp_traces, 'Border', 'tight')
        subplot('Position',[.63 .42 .44 .58])
        imshow(tmp_pos, 'Border', 'tight')
        set(f, 'Visible','on');
        
        behave = 0;
        behavelist = {'Permanently bound/unbound', 'Clearly switching states', 'Not sure', 'REVIEW PREVIOUS PAIR'};
        %[behave, ok] = listdlg('PromptString', 'Spot pair behaviour?', 'ListString', behavelist, 'SelectionMode', 'single');
        bg = uibuttongroup('Position', [.7 .2 .18 .2], 'Visible', 'off');
        
        p1 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [20 150 150 30],...
            'String', behavelist{1}, 'Callback', 'behave=1; uiresume(gcbf)');
        
        p2 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [180 150 130 30],...
            'String', behavelist{2}, 'Callback', 'behave=2; uiresume(gcbf)');
        
        p3 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [20 110 100 30],...
            'String', behavelist{3}, 'Callback', 'behave=3; uiresume(gcbf)');
        
        p4 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 70 150 30],...
            'String', behavelist{4}, 'Callback', 'behave=4; uiresume(gcbf)');
        
        %p5 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [170 110 120 30],...
         %   'String', behavelist{5}, 'Callback', 'behave=5;');
        
        %p6 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 70 150 30],...
        %    'String', behavelist{6}, 'Callback', 'behave=6;');
        
        e1 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 30 150 30],...
            'String', 'Abort sorting', 'Callback', ['m = N_movie; s = size(data{N_movie},1)+1; ' ...
            'uiresume(gcbf); close all']);
        
        set(bg, 'Visible', 'on')
        uiwait(gcf)
        %pause
        
        %if ok
            if behave == size(behavelist, 2)
                i = i-1;
                if i == 0
                    if m == 1
                        i = 1;
                    else
                        m = m-1;
                        i = length(find(GiTSiK.categorized{m} == 1));
                    end
                end
            else
                GiTSiK.behaviour{m}(s) = behave; % Permanent:1, Switching:2, Don't know:3, Cancel:0
                i = i+1;
            end
        %end
    end
    m = m+1;
end
close all

%% save data
close all
display('Saving GiTSiK file...')
save([data_path filesep 'GiTSiK.mat'], 'GiTSiK')
display('Done.')
display('End of program.')

%% Appendix A: Display 'interesting' spot pairs
close all
m = 1;
f = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0 0 1 1]);
while m <= length(GiTSiK.behaviour)
    behaved = find(GiTSiK.behaviour{m}==2);
    i = 1;
    while i <= length(behaved)
        s = behaved(i);
        tmp_vwcm = imread([data_path filesep 'vwcm_traces' filesep 'traces_RMS_hist_m' num2str(m) '_s' num2str(s) '.png']);
        tmp_pos = imread([data_path filesep 'positions' filesep 'positions_m' num2str(m) '_s' num2str(s) '.png']);
        subplot('Position',[0 0 .61 1])
        imshow(tmp_vwcm, 'Border', 'tight')
        subplot('Position',[.63 .42 .44 .58])
        imshow(tmp_pos, 'Border', 'tight')
        set(f, 'Visible','on');
        
        viewlist = {'Proceed to next pair', 'REVIEW PREVIOUS PAIR'};
        bg = uibuttongroup('Position', [.7 .2 .18 .2], 'Visible', 'off');
        
        p1 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [20 150 150 30],...
            'String', viewlist{1}, 'Callback', 'ok=1; uiresume(gcbf)');
        
        p2 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 70 150 30],...
            'String', viewlist{2}, 'Callback', 'ok=0; uiresume(gcbf)');
        
        e1 = uicontrol(bg, 'Style', 'Pushbutton', 'Position', [80 30 150 30],...
            'String', 'Abort review', 'Callback', ['i=length(GiTSiK.behaviour{m})+1; m = N_movie;' ...
            'ok = 1; uiresume(gcbf); close all;']);
        
        set(bg, 'Visible', 'on')
        uiwait(gcf)
        
        switch ok
            case 0
                i = i-1;
                if i == 0
                    if m == 1
                        i = 1;
                    else
                        m = m-1;
                        i = sum(GiTSiK.behaviour{m} == 2);
                    end
                end
            case 1
            i = i+1;
        end
    end
    m = m+1;
end
close(gcf),
%% Appendix B: Output bar graphs of category / behaviour counts + summary pie chart:
close all
figure(1)
categories = {'OK', 'Neighbour close', 'Attachment', 'Promiscuous' ,'Lifetime'};
counts = hist(vertcat(GiTSiK.categorized{:}),1:5);
bar(counts)
text(1:5,counts',num2str(counts'),'HorizontalAlignment','center','VerticalAlignment','bottom')
ylim([0 round(1.1*max(counts))])
set(gca, 'XTickLabel', categories)
ylabel('count')
title(['Categories assigned in sample: ' GiTSiK.sample{1} ', Date: ' GiTSiK.date{1} ', N_tot: ' num2str(sum(counts))])
%annotation('textbox', [0.8 0.8 0.1 0.05], 'String', ['Total #: ' num2str(length(counts))])
cd(data_path)
print('-dpng', '-r150', 'category_barplot.png')

figure(2)
behaviours = {'Static', 'Switching', 'Not sure'};
tmp = vertcat(GiTSiK.behaviour{:});
counts = hist(tmp(tmp>0),1:3);
bar(counts, 'r')
text(1:3,counts',num2str(counts'),'HorizontalAlignment','center','VerticalAlignment','bottom')
ylim([0 round(1.1*max(counts))])
set(gca, 'XTickLabel', behaviours)
ylabel('count')
title(['Behaviour assigned in sample: ' GiTSiK.sample{1} ', Date: ' GiTSiK.date{1} ', N_tot: ' num2str(sum(counts))])
cd(data_path)
print('-dpng', '-r150', 'behaviour_barplot.png')