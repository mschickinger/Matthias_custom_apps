%% What is hop?

hop = outputPostHMM.hop;


%% Calculate relative occupancies and store in hop.results struct
% (Take into account excluded time intervals)
for m = 1:size(hop.results,1)
    for s = 1:size(hop.results{m},1)
        hop.results{m}{s}.rocc = zeros(1,2);
%         tmp_ex = [];
%         for i = 1:size(hop.results{m}{s}.ex_int,1)
%             tmp_ex = [tmp_ex hop.results{m}{s}.ex_int(i,1):hop.results{m}{s}.ex_int(i,2)]; % pre-allocation too complicated?
%         end
%         tmp_ex(tmp_ex>length(hop.results{m}{s}.state_trajectory)) = [];
        tmp_st = hop.results{m}{s}.state_trajectory;
%         tmp_st(tmp_ex) = [];
        hop.results{m}{s}.rocc(2) = sum(tmp_st==2)/length(tmp_st);
        hop.results{m}{s}.rocc(1) = sum(tmp_st==1)/length(tmp_st);
    end
end

%% Get total number of particles in hop.results struct
L = 0;
for m = 1:size(hop.results,1)
    L = L + size(hop.results{m},1);
end

%% Get relative occupancies from all particles in hop.results struct
spotident = zeros(L,3);
rocc_all = zeros(L,2);
counter = 0;
for m = 1:size(hop.results,1)
    for s = 1:size(hop.results{m},1)
        counter = counter + 1;
        spotident(counter,1) = m;
        spotident(counter,2) = s;
        spotident(counter,3) = hop.results{m}{s}.spotnum;
        rocc_all(counter,:) = hop.results{m}{s}.rocc;
    end
end

%% Sort relative occupancy values
[ROb_asc, ROb_I] = sort(rocc_all(:,1));

%% Get number of un-/bound events from all particles in hop.results struct
Nu = zeros(L,1);
Nb = zeros(L,1);
counter = 0;
for m = 1:size(hop.results,1)
    for s = 1:size(hop.results{m},1)
        counter = counter + 1;
        Nu(counter) = size(hop.results{m}{s}.hi,1);
        Nb(counter) = size(hop.results{m}{s}.lo,1);
    end
end

%% Create RMS cell
rms_cell = cell(size(hop.results));
for m = 1:length(rms_cell)
    tmpS = hop.indices(hop.indices(:,1)==m,2);
    tmpF = hop.ranges(hop.indices(:,1)==m,:);
    rms_cell{m} = cell(length(tmpS),1);
    for i = 1:length(tmpS)
        rms_cell{m}{i}.rms10 = data{m}{tmpS(i),1}.vwcm.rms10(tmpF(i,1):tmpF(i,2));
    end
end
%% Display RMS traces
figure
%%
%for i = find(isnan(rocc_all(:,1)))'
subplot(6,1,1)
hold off
plot(rocc_all(:,1),Nu+Nb,'.')
hold on
for i = 5:length(ROb_I)
    xl = 0;
    for p = 2:6
        spind = i-p+2;
        subplot(6,1,p)
        plot(rms_cell{spotident(ROb_I(spind),1)}{spotident(ROb_I(spind),2)}.rms10)
        %hold on
        %plot(hop.results{spo}{}
        ylim([0 3.5])
        xl = max(xl,length(rms_cell{spotident(ROb_I(i-p+2),1)}{spotident(ROb_I(i-p+2),2)}.rms10));
        title(['Fraction bound: ' num2str(rocc_all(ROb_I(spind),1)) ', # of events: ' ...
            num2str(Nu(ROb_I(spind))+Nb(ROb_I(spind)))], 'Fontsize', 14)
    end
    for p = 2:6
        subplot(6,1,p)
        xlim([0 xl])
    end
    subplot(6,1,1)
    hold on
    curcle = plot(rocc_all(ROb_I(i),1),Nu(ROb_I(i))+Nb(ROb_I(i)), 'ro');
    %title(['Fraction bound: ' num2str(rocc_all(ROb_I(i),1)) ', # of events: ' num2str(Nu(ROb_I(i))+Nb(ROb_I(i)))], 'Fontsize', 16)
    title([num2str(i) ' / ' num2str(length(ROb_I))], 'FontSize', 14)
    pause
    delete(curcle)
end


 %% Tapete
tapete = figure('Units', 'centimeters', 'Position', [-100 00 21 29.7], ...
'PaperType', 'a4', 'PaperOrientation', 'portrait', 'PaperUnits', 'centimeters', ...
'PaperPositionMode', 'auto', 'Visible', 'on');
st_y_offset = 2;
YLIM = [0 3.5+st_y_offset];
XMAX = 0;
P = ceil(length(ROb_I)/10);
num_on_page = 10*ones(P,1);
num_on_page(end) = length(ROb_I)-(P-1)*10;
for p = 1:P
    clf('reset')
    set(tapete, 'PaperType', 'a4', 'PaperOrientation', 'portrait', 'PaperUnits', 'centimeters', ...
        'PaperPositionMode', 'auto', 'Visible', 'on');
    for j = 1:num_on_page(p)
        i = (p-1)*10+j;
        tmult = hop.tpf(spotident(ROb_I(i),1))/30000; %conversion from frames to minutes
        subplot(10,1,j)
        hold off
        if isfield(hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)},'ex_int')
            if ~isempty(hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.ex_int)
                for k = 1:size(hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.ex_int,1)
                    area(tmult*hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.ex_int(k,:), YLIM(2)*[1 1], 'FaceColor', [.95 0.1 0.1], 'EdgeColor', [1 0.15 0.15], 'FaceAlpha', .4);
                    hold on
                end
            end
        end
        hold on
        plot(tmult*(hop.ranges(ROb_I(i),1):hop.ranges(ROb_I(i),2)), ...
            hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.state_trajectory + st_y_offset, 'LineWidth', .1)
%         if hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.arxv.max_frame < length(rms_cell{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.rms10)
%             plot(tmult*(1:hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.arxv.max_frame), ...
%                 rms_cell{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.rms10(1:hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.arxv.max_frame), 'k', 'LineWidth', .1)
%             plot(tmult*(hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.arxv.max_frame:length(rms_cell{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.rms10)), ...
%                 rms_cell{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.rms10(hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.arxv.max_frame:end), 'Color', .7*[1 1 1], 'LineWidth', .1)
%             plot(tmult*[1 1]*hop.results{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.arxv.max_frame, YLIM, 'k:', 'LineWidth', .1)
%         else
            plot(tmult*(hop.ranges(ROb_I(i),1):hop.ranges(ROb_I(i),2)), ...
                rms_cell{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.rms10, 'k', 'LineWidth', .1)
%         end
        XMAX = max(XMAX,tmult*length(rms_cell{spotident(ROb_I(i),1)}{spotident(ROb_I(i),2)}.rms10));
        title([sprintf('%.2f', 100*ROb_asc(i)) ' % bound'], 'Fontsize', 9, 'Units', 'normalized', 'Position', [1 1], 'HorizontalAlignment', 'right')
    end
    for j = 1:10
        subplot(10,1,j)
        ax = gca;
        if j < 10
            set(ax.XAxis, 'TickLabels', {}, 'LineWidth', .2)
        end
        set(ax.YAxis, 'Visible', 'off')
        set(ax, 'Xlim', [0 XMAX], 'ylim', YLIM, 'Box', 'off', 'TickDir', 'out'); %, 'XGrid', 'on', 'XMinorGrid', 'on', 'YMinorGrid', 'on')
    end
    xlabel('Time (minutes)')
    suplabel([hop.sample ' from ' hop.date ', page ' num2str(p) ' of ' num2str(P)], 't');
    print('-dpdf', '-r0', ['tapete' sprintf('%02i', p) '.pdf'])
end