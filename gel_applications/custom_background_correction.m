function imageData = custom_background_correction(imageData, varargin)
%% Loads image, fits lanes according to step function convolved with gaussian
%   INPUTS: imageData from load_gel_image.m
%           'offset' (optional parameter) = determines whether
%           background_correct_interp removes a constant offset as final
%           step.
%   OUTPUT:
%   imageData struct from load_gel_image.m with .images replaced by background corrected images
% Example = background_correct_gel_image(img, 'offset', false)

%% parse input
p = inputParser;
addRequired(p,'imageData');
addParameter(p,'offset',true, @islogical); 

parse(p, imageData, varargin{:});
offset = p.Results.offset;  % number of references for background correction

%% apply background correction to images
images_bg = cell(imageData.nrImages, 1);
background = cell(imageData.nrImages, 1); % stores background values
for i=1:imageData.nrImages
    display(['Calculating interpolated background for image ' num2str(i) ' of ' num2str(imageData.nrImages)])
    [images_bg{i}, background{i}] = background_correct_interp(imageData.images{i}, 'offset', offset);  
end

%% replace/add data in imageData struct

imageData.images=images_bg;
imageData.background = background;
end