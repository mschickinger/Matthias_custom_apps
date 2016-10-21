%% STARTUP
clc, clear all, close all
run('my_prefs')
mode = questdlg('What would you like to do?', 'Mode', 'Average only', 'Average & transform', 'Both', 'Average only');
if strcmp(mode,'Average only')
    mode = 1;
elseif strcmp(mode, 'Average & transform')
    mode = 2;
elseif strcmp(mode, 'Both')
    mode = 3;
end

%% load tform
if mode~=1
    display('Select tform .mat file')
    [map_fname, map_pname]=uigetfile([mapping_dir filesep '*.mat'],'Select tform .mat file');
    tmp = load([map_pname map_fname] );
    tform = tmp.tform;
end

%% select file(s)
cd(data_dir)
display('Select the .fits file(s) you want to average/transform')
[fname, pname]=uigetfile('*.fits','Select the .fits file(s) you want to average/transform', 'MultiSelect', 'on');
if ~iscell(fname)
    fname = {fname};
end
%% generate movie object(s)
tmp = inputdlg({'First frame:','Sequence (e.g. 10)'}, 'Sequence', 1, {'1','10'});
first = str2double(tmp{1});
sequence = zeros(1, size(tmp{2},2));
for i=1:size(tmp{2},2)
    if(tmp{2}(i) == '1')
        sequence(1,i)=1;
    end
end
mov_in = cell(size(fname));
for m = 1:length(mov_in)
    mov_in{m} = movie(pname, fname{m}, first, -1, sequence); % pname, fname, first=1, last=all, sequence=all
end


%% loop through movie(s), average and transform it/them
h = waitbar(0,'Processing movie(s)... please wait');
for m = 1:length(mov_in)
    waitbar( (m-1)/length(mov_in), h, ['Processing movie ' num2str(m) ' of ' num2str(length(mov_in))]) % update waitbar
    A_out = int16(average_image(mov_in{m},-1));
    if ismember(mode, [1 3])
        floc_out = [mov_in{m}.pname mov_in{m}.fname{1}(1:end-5) '_avg.fits'];
        fitswrite(A_out,floc_out);
    end
    if ismember(mode, [2 3])
        At_out = int16(imwarp(A_out, tform, 'OutputView', imref2d(size(A_out)))); % average and transform image
        floct_out = [mov_in{m}.pname mov_in{m}.fname{1}(1:end-5) '_avg_tformed.fits'];
        fitswrite(At_out,floct_out);
    end
end
close(h)

display('Done.')
