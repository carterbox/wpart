function [ stack ] = imstackload( directory, type )
%imstack Returns a 3D images stack of all images in the directory. Only
%works for stacks of images whose largest images is listed first. Does not
%sort directory before loading images.

%loads the names of all the files in the directory
fcontents = dir(directory);
addpath( genpath(directory) );
fprintf('Loading files from %s ... ', directory);
start = 1;
while fcontents(start).isdir == 1
    start = start + 1;
    if start > length(fcontents), error('There are no files there!'); end
end

%determines the size of the images that will be loaded
[m,n,o] = size(imread(fcontents(start).name));

color = 0;
if o == 1 % the images are not color
    %preallocates the array for the images
    o = length(fcontents) - start + 1;
    stack = zeros([m,n,o], type);

    %loads all the files into the matrix
    count = 0;
    for i = start:length(fcontents);
        %checks that the entry is not a directory
        if(~fcontents(i).isdir)
            %disp(fcontents(i).name);
            count = count + 1;
            stack(:,:,count) = imread(fcontents(i).name);
        end
    end
else % the images are color and need a cell
    color = 1;
    z = length(fcontents) - start + 1;
    stack = cell(z,1);
    
    %loads all the files into the cell
    count = 0;
    for i = start:length(fcontents);
        %checks that the entry is not a directory
        if(~fcontents(i).isdir)
            %disp(fcontents(i).name);
            count = count + 1;
            stack{count} = imread(fcontents(i).name);
        end
    end
end
fprintf('LOADED %i FILES\n', count);

if color == 1, warning('Color images detected. Returning a cell.');

end