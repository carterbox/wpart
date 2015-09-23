function fixbands( indir, bandwidth, width, height )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Get all the names.
[names, count ]= imnamestack(indir, 3000, 3000);

right = 0; stack(width, height, bandwidth) = uint16(0);
while right < count
    % Break the names into chunks of size bandwidth
    left = right + 1;
    right = min(right + bandwidth, count);
    
    chunk = names(left:right);
    chunksize = numel(chunk);
    
    % Load the chunks
    for i = 1:chunksize
        stack(:,:,i) = imread([indir '/' chunk{i}]);
    end
    
    % Normalize the chunks
    %stack(:,:,1:chunksize) = rescale(stack(:,:,1:chunksize), 16, 1);
    
    % Resave the chunks
    for i = 1:chunksize
        imwrite(stack(:,:,i),[indir '/' chunk{i}]);
    end
end

end

