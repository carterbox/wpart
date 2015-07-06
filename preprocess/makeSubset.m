function [ stack ] = makeSubset(  indir, rotationCW, x0, y0, width, height, depth, notch )
%MAKESUBSET prepares a subset from a directory of images.
%   Detailed explanation goes here.

%loads all the files into the matrix
namestack = imnamestack( indir, notch, depth);
o = length(namestack);
%disp(namestack{1});
[m,n] = size(imread(namestack{1}));
stack = zeros([height, width, o], 'uint16');
fprintf('Rotating and cropping ... ');

assert(x0 > 0 && x0 < m);
assert(y0 > 0 && y0 < n);

parfor i = 1:o
    img = imread(namestack{i});
    %disp(namestack{i});
    %figure, imshow(uint8(img));
    img = imrotate( img, -rotationCW, 'bilinear', 'crop');
    img = imcrop( img, [x0, y0, width - 1, height - 1]);
    stack(:,:,i) = img;
end

fprintf('DONE.\n');
end

