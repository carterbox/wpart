function stack = makeSubset(indir, rotationCW, x_corner, y_corner, z_corner, width, height, depth, runquiet )
%MAKESUBSET prepares a subset from a directory of images.
%
% version 2.0.0
% INPUTS
%   rotationCW (degrees): a clockwise rotation angle to rotate the images
%   in INDIR before cutting out the region of interest.
%   x_corner, y_corner, z_corner: the post-rotation coordinates of the corner of the
%   STACK to [0,0].
%   [width, height, depth]: the desired 3D size of the STACK.
%
% NOTES
%   If the depth of the stack is greater than the number of available
%   images, then imnamestack will throw a warning and depth with be reduced
%   accordingly.
%
%% -----------------------------------------------------------------------
if(nargin < 8), runquiet = false; end;

% Get the names of all the images in the directory.
[namestack, numslices] = imnamestack( indir, inf );
% Preallocate space for the images.
[m,n] = size(imread(namestack{1}));

% Extract the slice index of the first image.
[~,number,~] = fileparts(namestack{1});
[~, number] = strtok(number,'_');
[~, number] = strtok(number,'_');
[~, number] = strtok(number,'_');
number = strtok(number,'_');
z0 = str2num(number);
z0 = z_corner - z0;
assert(z_corner >= 0);

numslices = min(depth, numslices-z0);

% Automagically check the bitdepth of the first loaded image and
% allocate the appropriate array.
info = imfinfo(namestack{1});
switch(info.BitDepth)
    case 8
        stack(height, width, numslices) = uint8(0);
    case 16
        stack(height, width, numslices) = uint16(0);
    case 32
        stack(height, width, numslices) = single(0);
end

% Check that the corner location is within the size of the image.
assert(x_corner >= 0 && x_corner < m);
assert(y_corner >= 0 && y_corner < n);

if(~runquiet && usejava('awt'))
try
    img = imread(namestack{z0+1});
    img = imrotate(img, -rotationCW, 'bilinear', 'crop');
    img = imcrop(img, [x_corner, y_corner, width - 1, height - 1]);
    h = figure(); imshow(img,'InitialMagnification','fit')
    if(~input('Is this the slice you want? (1 Yes / 0 No) '))
        stack = false;
        close(h);
        return;
    end
    close(h);
catch
end
end

fprintf('Rotating and cropping ... ');
% Load the images from the list of names and do the tranformations.
parfor i = 1:numslices
    img = imread(namestack{i+z0});
    %disp(namestack{i});
    %figure, imshow(uint8(img));
    img = imrotate(img, -rotationCW, 'bilinear', 'crop');
    img = imcrop(img, [x_corner, y_corner, width - 1, height - 1]);
    stack(:,:,i) = img;
end

fprintf('DONE.\n');
end

