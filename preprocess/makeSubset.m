function stack = makeSubset(indir, rotationCW, x_corner, y_corner, width, height, depth, notch )
%MAKESUBSET prepares a subset from a directory of images.
%
% INPUTS
%   rotationCW (degrees): a clockwise rotation angle to rotate the images
%   in INDIR before cutting out the region of interest.
%   x_corner, y_corner: the post-rotation coordinates of the corner of the
%   STACK to [0,0].
%   [width, height, depth]: the desired 3D size of the STACK.
%   notch: the location of the bottom of the STACK.
%
% NOTES
%   If the depth of the stack is greater than the number of available
%   images, then imnamestack will throw a warning and depth with be reduced
%   accordingly.
%
%% -----------------------------------------------------------------------
% Get the names of all the images in the directory.
[namestack, numslices] = imnamestack( indir, notch, depth);
% Preallocate space for the images.
[m,n] = size(imread(namestack{1}));

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

fprintf('Rotating and cropping ... ');

% Check that the corner location is within the size of the image.
assert(x_corner > 0 && x_corner < m);
assert(y_corner > 0 && y_corner < n);

% Load the images from the list of names and do the tranformations.
parfor i = 1:numslices
    img = imread(namestack{i});
    %disp(namestack{i});
    %figure, imshow(uint8(img));
    img = imrotate(img, -rotationCW, 'bilinear', 'crop');
    img = imcrop(img, [x_corner, y_corner, width - 1, height - 1]);
    stack(:,:,i) = img;
end

fprintf('DONE.\n');
end

