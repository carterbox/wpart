function [strain3Dgrey] = mapToColor( strain3D, originals, spacing, samplename)
%takes a cell of 3D matricies and creates colorized images
RGBmap = colormap(jet(256));

closeit = 0;
if(matlabpool('size') == 0)
    matlabpool open;
    closeit = 1;
end

n = length(strain3D);
assert(length(spacing) == 3, 'Spacing must be vector with 3 entries');

%choose a colorscheme, convert the strain map to 256 values, and
%interpolate the strain map up to the approximate size of the original
factor = floor(spacing./2-1);
display(sprintf('Interpolating strain map by factor of [%i, %i, %i]', factor(1), factor(2), factor(3)));
for i = 1:n 
    assert(length(size(strain3D{i})) == 3, 'Strain data must be 3D');
    strain3D{i} = matchsize(interp3(strain3D{i}, factor , 'spline'), originals{i});
end

display('Normalizing values to 256 shades...');
strain3Dgrey = mapTo256(strain3D);

for i = 1:n
    orig = originals{i};
    grey = strain3Dgrey{i};
    [~,~,z] = size(grey);
    %create containers for color image stack
    colorImage = cell(1,z);
    colorStrain = cell(1,z);

    %convert both the strain map and original to color images
    parfor k = 1:z
        colorImage{k} = label2rgb(orig(:,:,k),colormap(gray(256)));
        colorStrain{k} = label2rgb(grey(:,:,k),RGBmap);
    end

    %blend the colored strain map into the original image
    display('Blending images.');
    parfor k = 1:z
       colorImage{k} = imfuse(colorImage{k}, colorStrain{k}, 'blend');
    end

    %save the stack of processed images
    display(sprintf('Saving Images for stack %i', i));
    mkdir(sprintf('./results%02i',i));
    parfor k = 1:z
        filename = sprintf('./results%02i/%s%03i.bmp',i,samplename,k); 
        imwrite(colorImage{k},filename,'bmp');
    end
    %imshow(colorImage{16});
    %out = colorImage;
end

if(closeit == 1); matlabpool close; end
display('done');
end

function [A] = matchsize(A, B)
%Changes the size of A to match the size of B. Throws an exception if the
%dimensionality of the two matricies are not the same. Only supports up to
%3 dimensions.

    b = size(B);
    a = size(A);
    dimensions = length(a);
    assert(dimensions == length(b));
    
    for i = 1:dimensions
        %if the dx > 0 then A has to get bigger and vise versa
        dx = b(i)-a(i);
        %display(dx);
        
        if(dx > 0) %pad a with replicated values
            padding = zeros(1,dimensions);
            padding(i) = floor(dx/2);
            A = padarray(A, padding,'replicate');
            if(mod(dx,2) == 1) %for odd numbers
                padding(i) = 1;
                A = padarray(A, padding, 'replicate', 'pre');
            end
        end
        
        if(dx < 0) %take a subset of A
            padding = zeros(1,dimensions);
            padding(i) = ceil(dx/2);
            start = ones(1,dimensions) - padding;
            stop = size(A) + padding;
            if(mod(dx,2) == 1) %for odd numbers
                padding(i) = 1;
                start = start + padding;
            end
            A = A(start(1):stop(1),start(2):stop(2),start(3):stop(3));
        end
        
    end

    [a1,a2,a3] = size(A);
    [b1,b2,b3] = size(B);
    %display(size(A));
    %display(size(B));
    assert(a1==b1 && a2==b2 && a3==b3);
end