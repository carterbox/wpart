function [colorImage] = mapToColor(Function, Images, lo, hi)
%MAPTOCOLOR takes a 3D Function and overlays it on stack of images.
%
%version 2.1.0
%INPUTS
% Function (double): a Nx4 matrix where the first three columns are
% coordinates and the last column is the function values at those
% coordinates. Must be a regular grid in each dimension. e.g. spacing can
% differ between dimensions, but there cannot be holes in the data.
%
% Images (matrix or cell): images (grey or color) that create a 3D 
% volume in which Function can be mapped. If numel(Images) < 2, MAPTOCOLOR
% will return only the colormapped function.
%
%OUTPUTS
% colorImage: a cell of 8 bit color image slices.
%
% version 2.1.0 - Added option of supplying no Images.
RGBmap = cool(256); % Chooses the function mapping from numbers to colors
logfile = 1;
%% -----------------------------------------------------------------------
closeit = 0;
if(numel(gcp) == 0)
    closeit  = parpool;
end 

%% GET INFORMATION ABOUT VOLUMES
Isize = size(Images);
assert(size(Function,2) == 4, 'Function must be 4 columns');

Function = double(sortrows(Function,[3,2,1]));
a = numel(unique(Function(:,1)));
b = numel(unique(Function(:,2)));
c = numel(unique(Function(:,3)));

fmin = ceil(min(Function(:,1:3),[],1));
fmax = floor(max(Function(:,1:3),[],1));

%% RESCALE FUNCTION INTO 256 COLORS
fprintf(logfile,'Normalizing values to 256 shades...');
Function(:,4) = rescale(Function(:,4),8,logfile, lo, hi);
fprintf(logfile,'DONE.\n');

%% INTERPOLATE FUNCTION INTO SLICES

% Reshape the data into an ND matrix because interpn wants it that way.
Fx = reshape(Function(:,1),a,b,c);
Fy = reshape(Function(:,2),a,b,c);
Fz = reshape(Function(:,3),a,b,c);
Ff = reshape(Function(:,4),a,b,c);
clear Function a b c

% Create a query grid for each output slice.
[Qx,Qy,Qz] = ndgrid(fmin(1):fmax(1),fmin(2):fmax(2), 1);

%pre_pad = fmin-1; post_pad = Isize-fmax;
F = zeros(size(Qx,1),size(Qx,2),fmax(3)-fmin(3)+1,'uint8');
fprintf(logfile,'Interpolating function to slices...');
parfor i = 1:(fmax(3)-fmin(3)+1)
    slice = i+fmin(3)-1;
    
    % Interpolate all the values of the function to 1 pixel spacing 
    Qf = interpn(Fx,Fy,Fz,Ff,Qx,Qy,Qz.*slice,'cubic');
    
    % Padd the results to fit on top of Image
    %Qf = padarray(Qf,pre_pad(1:2),'pre');
    F(:,:,i) = Qf; %padarray(Qf,post_pad(1:2),'post');
end
fprintf(logfile,' DONE.\n');
clear a b c pre_pad post_pad Fx Fy Fz Ff Qx Qy Qz Qf

%% COMBINE VOLUMES
if numel(Images < 2)
    colorImage = cell(size(F,3),1);
    parfor slice = 1:size(F,3)
        colorImage{slice} = label2rgb(F(:,:,slice),RGBmap,'k');
    end
else
    % Create container for color image stack
    colorImage = cell(Isize(3),1);
    %colorStrain = zeros(Isize(1:2));

    sXWorldLimits = [fmin(2),fmax(2)];
    sYWorldLimits = [fmin(1),fmax(1)];
    RefF = imref2d(size(F(:,:,1)),sXWorldLimits,sYWorldLimits);

    RefImage = imref2d(size(Images(:,:,1)));

    fprintf(logfile,'Merging colors...');
    parfor slice = 1:Isize(3)

        orig = Images(:,:,slice);

        %convert both the strain map and original to color images
        colorImage{slice} = label2rgb(orig+1,gray(256));

        if fmin(3) <= slice && slice <= fmax(3) % The range where F is valid
            colorStrain = label2rgb(F(:,:,slice-fmin(3)+1),RGBmap,'k');

            % Blend the colored strain map into the original image
            colorImage{slice} = imfuse(colorImage{slice}, RefImage, colorStrain, RefF, 'blend', 'Scaling','none');
        end
    end
    fprintf(logfile,' DONE.\n');
    clear colorStrain
end

%% SAVE IMAGES

%imstacksave(colorImage, './colortest','/gauss');

if(closeit ~= 0); delete(gcp); end
display('done');
end