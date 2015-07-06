function [ normalized ] = mapTo256( stackof3D )
%Takes a cell of 3D matricies and normalizes all values to the same [0,255] scale.  
closeit = 0;
if(matlabpool('size') == 0)
    matlabpool open;
    closeit = 1;
end

%Find the largest and smallest values from each
n = length(stackof3D);
large = zeros(1,n); small = zeros(1,n);
display(sprintf('Finding the smallest and largest values in %i matricies...', n));
for i = 1:n
    assert(length(size(stackof3D{i})) == 3, 'Matrix %i is not 3D.', n);
    large(i) = max(max(max(stackof3D{i})));
    small(i) = min(min(min(stackof3D{i})));
end

largest = max(large);
smallest = min(small);
range = (largest - smallest)./255;

display(largest);
display(smallest);

%Recalculate the values of all of the matricies
normalized = cell(n,1);
for a = 1:n
    display(sprintf('Normalizing stack number %i...', a));
    stackTemp = stackof3D{a};
    [~,~,d] = size(stackTemp);
    parfor k = 1:d
        slice = stackTemp(:,:,k);
        slice = floor((slice - smallest)./range);
        stackTemp(:,:,k) = slice;
    end
    normalized{a} = stackTemp;
end

%Double check that all the values have been scaled correctly
for i = 1:n
    large(i) = max(max(max(normalized{i})));
    small(i) = min(min(min(normalized{i})));
end
largest = max(large);
smallest = min(small);
assert(smallest == 0 && largest == 255);

display('All stacks normalized.');

if(closeit == 1); matlabpool close; end
end