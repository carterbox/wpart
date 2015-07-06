function [ B ] = removeislands( A, numparts, islandsize )

P = islandsize;
z = 8; %6,18, or 26;

BW = cell(numparts,1);
%make some binary arrays of each of layers of segements and remove islands
parfor i = 3:numparts
    BW{i} = A >= i;
    BW{i} = bwareaopen(BW{i}, P, z);
    %figure(i),imshow(uint8(BW{i}(:,:,1)*255));
end

B = ones(size(A)) + 1; %merge the two bottom segments into one
for i = 3:numparts;
    B = B + BW{i};
end

end

