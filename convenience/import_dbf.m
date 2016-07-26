function import_dbf
%Import temperature logger data from text file.


%% Initialize variables.
start_path = '/Users/matthiasschickinger/PhD/TIRFM Setup/Temperature_logs/';
[filename, pathname] = uigetfile({'*.dbf', 'DataBaseFiles'},  'Pick a temperature log file', start_path);
delimiter = ' ';
startRow = 3;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, '%s', 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
% raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
raw = dataArray{1};
times = zeros(size(raw));
T = zeros(size(raw));
i = 1;
go_on = 1;
while i <= length(raw) && go_on
    go_on = length(raw{i})>1;
    if go_on
        times(i) = str2double(raw{i}(1:end-4));
        T(i) = str2double(raw{i}(end-3:end));
        i = i+1;
    end
end
times = times(1:i-1);
T = T(1:i-1);
dtimes = datetime(times,'ConvertFrom', 'excel', 'Format', 'yyyy-MM-dd HH:mm:ss');

%% Plot and save

if strcmp(questdlg('Show temperatures in figure?',''), 'Yes')
    figure('Units', 'normalized', 'Position', [0 0 1 1], 'PaperPositionMode', 'auto');
    plot(T); hold on;
    YLIM = [min(T)-.5 max(T)+.5];
    FirstMidnight = find(dtimes.Hour==0,1);
    tmp = find(dtimes.Day>dtimes.Day(FirstMidnight),1);
    if isempty(tmp)
        tmp = find(dtimes.Month>dtimes.Month(FirstMidnight),1);
        if isempty(tmp)
            tmp = find(dtimes.Year>dtimes.Year(FirstMidnight),1);
        end
    end
    PointsPerDay = tmp - FirstMidnight;
    LastMidnight = FirstMidnight + PointsPerDay*floor((length(T)-FirstMidnight)/PointsPerDay);
    for i = FirstMidnight:PointsPerDay:length(dtimes)
        plot([i i], YLIM + [-.1 .1], 'k--')
        plot([i i]+720, YLIM + [-.1 .1], 'r--')   
    end
    set(gca, 'Xlim', [0 length(T)], 'Ylim', YLIM, 'XTick', [FirstMidnight LastMidnight], ...
        'XTickLabel', {datestr(dtimes(FirstMidnight),'mmm dd, HH:MM') ; datestr(dtimes(LastMidnight),'mmm dd, HH:MM')}, ...
        'YTick', ceil(YLIM(1)*2)/2:.5:floor(YLIM(2)*2)/2, 'YGrid', 'on');
    xlabel('Datetime', 'FontSize', 14);
    ylabel('Temperature (? C)', 'FontSize', 14);
    title(['Temperatures measured between ' datestr(dtimes(1),'mmm-dd-yyyy') ' and ' datestr(dtimes(end),'mmm-dd-yyyy')], 'FontSize', 18)
    whattodo = questdlg('Save figure?', 'Save?', 'Figure', 'Figure & .png', 'None', 'Figure & .png');
    if strcmp(whattodo, 'None') == 0;
        savefig([pathname 'temperature_log.fig'])
    end
    if strcmp(whattodo, 'Figure & .png')
        print('-dpng', [pathname 'temperature_log.png'])
    end
end

%% Save variables
save temperature_log.mat times T dtimes FirstMidnight LastMidnight PointsPerDay
end