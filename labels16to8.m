function [ labels8 ] = labels16to8( labels16 )
%UNTITLED converts a 4 group 16 bit label to a 4 group 8 bit label.

MAXINT = 2^16;

start2 = find(labels16>1,1);
start3 = find(labels16>2,1);
start4 = find(labels16>3,1);

range = MAXINT-start2;

index3 = round((start3-start2)/range*256);
index4 = round((start4-start2)/range*256);


labels8 = ones(1,256);
labels8(2:index3-1) = 2;
labels8(index3:index4-1) = 3;
labels8(index4:end) = 4;

end

