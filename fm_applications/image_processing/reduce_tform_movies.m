%% STARTUP
clc, clear all, close all
run('my_prefs')
mode = questdlg('What would you like to do?', 'Mode', 'Reduce only', 'Reduce & transform', 'Both', 'Reduce only');
if strcmp(mode,'Reduce only')
    mode = 1;
elseif strcmp(mode, 'Reduce & transform')
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
display('Select the .fits file(s) you want to reduce/transform')
[fname, pname]=uigetfile('*.fits','Select the .fits file(s) you want to reduce/transform', 'MultiSelect', 'on');
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


%% loop through movie(s) and transform it/them
for m = 1:length(mov_in)
    h = waitbar(0, ['Movie ' num2str(m) ' of ' num2str(length(mov_in))]); % update waitbar
    A_out = zeros(mov_in{m}.sizeX, mov_in{m}.sizeY, length(mov_in{m}.frames), 'int16');
    counter = 0;
    mov_in{m}.initRead();
    go_on = 1;
    while go_on
        [mov,~, go_on] = mov_in{m}.readNext;
        A_out(:,:,counter+(1:size(mov,3))) = mov;
        counter = counter + size(mov,3);
    end
    if ismember(mode, [1 3])
        floc_out = [mov_in{m}.pname mov_in{m}.fname{1}(1:end-5) '_red.fits'];
        fitswrite(A_out,floc_out);
    end
    if ismember(mode, [2 3])
        At_out = zeros(size(A_out),'int16');
        for i = 1:size(A_out,3)
            At_out(:,:,i) = int16(imwarp(A_out(:,:,i), tform, 'OutputView', imref2d(size(A_out)))); % transform frames
            waitbar(i/size(A_out,3), h, ...
                ['Movie ' num2str(m) ' of ' num2str(length(mov_in)) ': ' num2str(round(i/size(A_out,3),1)) ' %']); 
        end
        floct_out = [mov_in{m}.pname mov_in{m}.fname{1}(1:end-5) '_red_tformed.fits'];
        fitswrite(At_out,floct_out);
    end
    close(h)
end
%close(h)
display('Done.')
