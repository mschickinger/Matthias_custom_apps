[status, list] = system('find /Users/matthiasschickinger/PhD/TIRFM_Data -iname dataPostHMM_nost.mat','-echo');
cr = regexp(list,'\n');
initial = [1 cr(1:end-1)+1];
final = cr-1;
pathlist = cell(size(cr));
for i= 1:length(pathlist)
    pathlist{i} = list(initial(i):final(i));
end

%%
output_dir = '/Users/matthiasschickinger/PhD/TIRFM_Data/00_TIRFM_Analysis/2018_04_24_dwells_fifths/CDFs';
counter = 0;
for batchi = 1:length(pathlist)
    current_dir = pathlist{batchi}(1:find(pathlist{batchi}==filesep,1,'last'));
    display(current_dir)
    cd(current_dir)
    clear inputPostHMM_nost
    display('loading data...')
    load('dataPostHMM_nost.mat', 'inputPostHMM_nost')
    display('evaluating...')
    
    cd(output_dir)
    prefix_out = sprintf('%03d',batchi);
    qualityControl
    
    display('done')
    display('moving on...')   
end
display('All done')