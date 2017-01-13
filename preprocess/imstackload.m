function [ stack ] = imstackload( directory, type, fraction )
%IMSTACKLOAD Returns a 3D images stack of all images in the directory. Only
%works for stacks of images whose largest images is listed first. Does not
%sort directory before loading images.

% version = 1.1.0
% INPUTS:
% directory: the folder of images from which the stack will be constructed.
% type (string): OPTIONAL determines the type of data returned e.g. uint8, 
%   double, uint16, etc.
% fraction (optional): Some number in the range (0,1]. The returned stack
%   will be a randomly selected fraction of the images in directory.
%% -----------------------------------------------------------------------
if nargin < 3, fraction = 1; end
kEXTENSION = {'.tif', '.png', '.tiff'};

if exist(directory) == 2
    stack = imread(directory);
    return
end

%% Load the names of all the files in the directory
fcontents = dir(directory);
addpath( genpath(directory) );
fprintf('Loading files from %s ... ', directory);

image_count = 0;
namestack = cell(numel(fcontents),1);
for i = 1:numel(fcontents)
    % Check that the entry is not a directory.
    if(~fcontents(i).isdir)
        [~,~,ext] = fileparts(fcontents(i).name);
        % Check for the desired filetype.
        if strcmp(ext, kEXTENSION{1}) || strcmp(ext, kEXTENSION{2}) || strcmp(ext, kEXTENSION{3})
            image_count = image_count + 1;
            namestack{image_count} = fcontents(i).name;
        end
    end
end

if image_count == 0
    error('No images found!');
end
clear fcontents;

%% Load the actual file data

if fraction < 1
    numsamples = ceil(fraction*image_count);
    %warning('NUM SAMPLED SLICES IS %i \n', numsamples);
    namestack = namestack(random('unid', image_count, [1,numsamples]));
    image_count = numsamples;
end

if nargin < 2 || length(type) < 2
    % Automagically check the bitdepth of the first loaded image and
    % allocate the appropriate array.
    info = imfinfo(namestack{1});
    switch(info.BitDepth)
        case 8
            type = 'uint8';
        case 16
            type = 'uint16';
        case 32
            type = 'single';
        otherwise
            type = 'double';
    end 
end

% Determines the size of the images that will be loaded
[m,n,o] = size(imread(namestack{1}));

if o == 1 % the images are not color
    % preallocate the array for the images
    stack = zeros([m,n,image_count], type);

    %loads all the files into the matrix
    for i = 1:image_count
        stack(:,:,i) = imread(namestack{i});
    end
    
    fprintf('LOADED %i FILES\n', image_count);
    
else % the images are color and need a cell
    stack = cell(image_count,1);
    
    %loads all the files into the cell
    for i = 1:image_count;
            stack{i} = imread(namestack{i});
    end
    
    fprintf('LOADED %i FILES\n', image_count);
    warning('Color images detected. Returning a cell.');
end
end