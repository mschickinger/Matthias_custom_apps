% Need to be loaded: 
% cell containing indices of "honest particles" and cell containing the
% corresponding rms-traces.
% hop struct (if it already exists)

% specify name of cell array containing the indices:
spotnum_cell = cell(size(data));
for m = 1:length(spotnum_cell)
    spotnum_cell{m} = find(GiTSiK.behaviour{m}==2);
end

% specify name of cell array containing the rms-traces:
rms_cell = cell(size(data));
for m = 1:length(rms_cell)
    rms_cell{m} = cell(size(spotnum_cell{m}));
    for s = 1:length(rms_cell{m})
        rms_cell{m}{s}.rms10red = data{m}{spotnum_cell{m}(s),1}.vwcm.rms10;
        rms_cell{m}{s}.rms10green = data{m}{spotnum_cell{m}(s),2}.vwcm.rms10;
    end
end
close all

%% Create hop structure
if ~exist('hop','var')
    sample_ident = inputdlg({'Date:', 'Sample:', 'Number of movies:'}, 'Identify');
    hop.sample = sample_ident{2};
    hop.date = sample_ident{1};
    hop.results = cell(str2double(sample_ident{3}),1);
    for m = 1:size(hop.results,1)
        hop.results{m} = cell(length(spotnum_cell{m}),1);
        for s = 1:size(hop.results{m},1)
            hop.results{m}{s}.spotnum = spotnum_cell{m}(s);
            hop.results{m}{s}.todo = int8(1);
            hop.results{m}{s}.ex_int = zeros(0,2);
        end
    end
end

%% Cycle through all traces
GO_ON = 1;
for m = 1:size(hop.results,1)
    if ~GO_ON
        uisave({'hop','rms_cell'}, 'hop.mat')
        return
    end
    for s = 1:size(hop.results{m})
        if hop.results{m}{s}.todo == 1
            [hop.results{m}{s}.steps, hop.results{m}{s}.steptraces, hop.results{m}{s}.ex_int, hop.results{m}{s}.arxv, GO_ON, ex_global] = ...
                reduce_steptraces(rms_cell{m}{s}.rms10red,rms_cell{m}{s}.rms10green,hop.results{m}{s}.ex_int, ...
                'movie',m,'spot',hop.results{m}{s}.spotnum);
            if ~isempty(ex_global)
                for g = 1:size(hop.results{m})
                    hop.results{m}{g}.ex_int = [hop.results{m}{g}.ex_int; ex_global];
                end
            end
            hop.results{m}{s}.todo = uint8(~GO_ON);
            if GO_ON == 0
                hop.results{m}{s}.todo = int8(~strcmp(questdlg('Also save last viewed trace?','Save last trace?'),'Yes'));
                uisave({'hop','rms_cell'}, 'hop.mat')
                return
            elseif GO_ON == 2
                hop.results{m}{s}.todo = uint8(2);
                GO_ON = 1;
            end
        end
    end
end
display(['End of datasets for sample ' hop.sample ' from ' hop.date])
close all
%% Reset todo parameter in all result arrays

for m = 1:length(hop.results)
    for s = 1:length(hop.results{m})
        hop.results{m}{s}.todo = 1;
    end
end

%% Count analyzed spot pairs
counter = 0;
for m = 1:3
for s = 1:length(hop.results{m})
counter = counter + isfield(hop.results{m}{s}, 'steps');
end
end
