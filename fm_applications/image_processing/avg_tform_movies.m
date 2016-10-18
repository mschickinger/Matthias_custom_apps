%% STARTUP
clc, clear all, close all
run('my_prefs')


%% load tform
cd(data_dir)
[map_fname, map_pname]=uigetfile([mapping_dir filesep '*.mat'],'Select tform_red2green.mat');
tmp = load([map_pname map_fname] );
tform_r2g = tmp.tform;


%% select file(s)
cd(data_dir)
[fname, pname]=uigetfile('*.fits','Select any RED .fits file(s)', 'MultiSelect', 'on');

%% generate movie file(s)
if iscell(fname)
    mov_in = cell(size(fname));
    for m = 1:length(mov_in)
        mov_in{m} = movie(pname, fname{m}, 1, -1, 1); % pname, fname, first=1, last=all, sequence=all
    end
else
    mov_in = movie(pname, fname, 1, -1, 1);
end

%% loop through movie(s), average and transform it/them

if iscell(fname)
    h = waitbar(0,'Transforming movies... please wait');
    for m = 1:length(mov_in)
        waitbar( (m-1)/length(mov_in), h, ['Transforming movie ' num2str(m) ' of ' num2str(length(mov_in))]) % update waitbar
        floc_out = [mov_in{m}.pname mov_in{m}.fname{1}(1:end-5) '_avg_tformed.fits'];
        A_out = int16(average_image(mov_in{m},-1));
        A_out = int16(imwarp(A_out, tform_r2g, 'OutputView', imref2d(size(A_out)))); % average and transform image
        fitswrite(A_out,floc_out);
    end
    close(h)
else
    display('Transforming movie... please wait')
    floc_out = [mov_in.pname mov_in.fname{1}(1:end-5) '_avg_tformed.fits'];
    A_out = int16(average_image(mov_in,-1));
    A_out = int16(imwarp(A_out, tform_r2g, 'OutputView', imref2d(size(A_out)))); % average and transform image
    fitswrite(A_out,floc_out);
end
display('Done.')
