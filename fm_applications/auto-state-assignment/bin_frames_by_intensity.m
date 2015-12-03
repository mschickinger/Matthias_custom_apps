function [ frames_in_bin, intensity_edges, N_frames_in_bin ] = bin_frames_by_intensity( movie_data, behaviour )
%BIN_FRAMES_BY_INTENSITY
%   For spot data from one movie set:
%   Divide full intensity range in bins of width W counts.
%   Return bin edge intensity values and frame numbers within that bin for 
%   each spot pair.

W = 100;

intensity_edges = cell(3,1);
minmax = zeros(2);

% get global intensity minima / maxima and bin edges
for ch = 1:2
    tmp_minmax = zeros(size(movie_data,1),2);
    for s = find(behaviour==2)'
        tmp_minmax(s,1) = min(movie_data{s,ch}.itrace);
        tmp_minmax(s,2) = max(movie_data{s,ch}.itrace);
    end
    minmax(ch,1) = min(nonzeros(tmp_minmax(:,1)));
    minmax(ch,2) = max(nonzeros(tmp_minmax(:,2)));
    intensity_edges{ch} = (floor(minmax(ch,1)/W):ceil(minmax(ch,2)/W)).*W;
end

% find indices of frames with intensity values in respective bins
tic
frames_in_bin = cell(3,1);
N_frames_in_bin = cell(3,1);
for ch = 1:2
    frames_in_bin{ch} = cell(size(movie_data,1),length(intensity_edges{ch})-1);
    N_frames_in_bin{ch} = zeros(size(movie_data,1),length(intensity_edges{ch})-1);
end
frames_in_bin{3} = cell(size(movie_data,1),length(intensity_edges{1})-1, length(intensity_edges{2})-1);
N_frames_in_bin{3} = zeros(size(movie_data,1),length(intensity_edges{1})-1, length(intensity_edges{2})-1);

for s = find(behaviour==2)'
    for ch = 1:2
        for i = 1:size(frames_in_bin{ch},2)
            frames_in_bin{ch}{s,i} = find(movie_data{s,ch}.itrace > intensity_edges{ch}(i) & movie_data{s,ch}.itrace <= intensity_edges{ch}(i+1));
            N_frames_in_bin{ch}(s,i) = length(frames_in_bin{ch}{s,i});
        end
    end
    for i = 1:size(frames_in_bin{1},2)
        for j = 1:size(frames_in_bin{2},2)
            frames_in_bin{3}{s,i,j} = find(movie_data{s,1}.itrace > intensity_edges{1}(i) & movie_data{s,1}.itrace <= intensity_edges{1}(i+1) ...
                                        & movie_data{s,2}.itrace > intensity_edges{2}(j) & movie_data{s,2}.itrace <= intensity_edges{2}(j+1));
            N_frames_in_bin{3}(s,i,j) = length(frames_in_bin{3}{s,i,j});
        end
    end
end
toc            

end

