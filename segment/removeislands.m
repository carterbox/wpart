function [ B ] = removeislands( A, CONNECTIVITY, minislandsize )
%REMOVEISLANDS removes islands from each phase of the image. #parallel
% The image is segmented into NUMPARTS layers where the Nth layer is a
% boolean array of x >= N. Island are removed from each layer and then
% blended downwards.
%
% INPUTS
%   A: a presegemented image whose values are between 1 and NUMPARTS
%   numparts: the total number of phases in the image.
%   minislandsize: the minimum number of pixels an island requires to
%   survive bwareopen at the give CONNECTIVITY setting.
%
% OUTPUTS
%   B (uint8): the segmented image with islands removed.
%
% GLOBAL VARIABLES

%CONNECTIVITY = 6;   % 2D: 4 or 8
                    % 3D: 6, 18, or 26;
                    
%% -----------------------------------------------------------------------
numparts = max(A(:));
binarylayers = cell(numparts,1);

% Convert the image into a sequency of binary arrays and remove islands.
parfor i = 2:numparts
    binarylayers{i} = uint8(bwareaopen(A >= i, minislandsize, CONNECTIVITY));
    %figure(i),imshow(uint8(binarylayers{i}(:,:,1)*255));
end

% Recombine the layers.
B = ones(size(A),'uint8');
for i = 2:numparts;
    B = B + binarylayers{i};
end
end

