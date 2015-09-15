function [ stack ] = imstackload( directory, type )
%imstack Returns a 3D images stack of all images in the directory. Only
%works for stacks of images whose largest images is listed first. Does not
%sort directory before loading images.

kEXTENSION = {'.tif', '.png', '.tiff'};

%loads the names of all the files in the directory
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

if image_count == 0, return; end
clear fcontents;

%determines the size of the images that will be loaded
[m,n,o] = size(imread(namestack{1}));

if o == 1 % the images are not color
    % preallocate the array for the images
    stack = zeros([m,n,image_count], type);

    %loads all the files into the matrix
    for i = 1:image_count
        stack(:,:,image_count) = imread(namestack{i});
    end
else % the images are color and need a cell
    stack = cell(image_count,1);
    
    %loads all the files into the cell
    for i = 1:image_count;
            stack{i} = imread(namestack{i});
    end
    warning('Color images detected. Returning a cell.');
end
fprintf('LOADED %i FILES\n', image_count);

end