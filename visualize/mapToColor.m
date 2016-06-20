function [colorImage] = mapToColor(Function, images_dir, lo, hi,outdir, samplename)
%MAPTOCOLOR takes a 3D Function and overlays it on stack of images.
%
%version 2.2.0
%INPUTS
% Function (double): a Nx4 matrix where the first three columns are
% coordinates and the last column is the function values at those
% coordinates. Must be a regular grid in each dimension. e.g. spacing can
% differ between dimensions, but there cannot be holes in the data.
%
% images_dir: directory to the image slices where Function can be mapped.
% If images_dir = '', MAPTOCOLOR will return only the colormapped function.
%
% lo,hi: the high and low values for rescaling the Function.
%
%OUTPUTS
% colorImage: a cell of 8 bit color image slices.
%
% version 2.2.0 - Switched the interpolator to allow for scattered data.
% version 2.1.2 - Fixed bug where worldLimits caused incorrect size of
% fused image.
%% -----------------------------------------------------------------------
RGBmap = jet(256); % Chooses the function mapping from numbers to colors
logfile = 1;
%% GET INFORMATION ABOUT VOLUMES
assert(size(Function,2) == 4, 'Function must be 4 columns');

Function = double(sortrows(Function,[3,2,1]));
% a = numel(unique(Function(:,1)));
% b = numel(unique(Function(:,2)));
% c = numel(unique(Function(:,3)));

fmin = ceil(min(Function(:,1:3),[],1));
fmax = floor(max(Function(:,1:3),[],1));

try
    [images_names, count] = imnamestack(images_dir, inf);
catch
    count = 0;
end

%% RESCALE FUNCTION INTO 256 COLORS
fprintf(logfile,'Normalizing values to 256 shades...');
Function(:,4) = rescale(Function(:,4),8,logfile, lo, hi);
fprintf(logfile,'DONE.\n');

%% CREATE INTERPOLATOR FUNCTION

Fx = Function(:,1);
Fy = Function(:,2);
Fz = Function(:,3);
Ff = Function(:,4);
clear Function a b c

fprintf(logfile,'Initializing interpolator...');
Interpolator = scatteredInterpolant(Fx,Fy,Fz,Ff,'nearest','none');
fprintf(logfile,' DONE.\n');

% Create a query grid for each output slice.
Qx = fmin(1):fmax(1);
Qy = fmin(2):fmax(2);

fprintf(logfile,'Interpolating function to slices...');

%slices = [1:numSlices]+fmin(3)-1;
slices = 105:1645;

%if(numel(gcp) > 0), delete(gcp); end 
%c = parcluster();
%j = createJob(c);
%delete(c.Jobs);
mkdir(outdir);
parfor i = 1:numel(slices)
    % Interpolate all the values of the function to 1 pixel spacing
    if slices(i) > count
        dir = false;
    else
        dir = [images_dir '/' images_names{slices(i)}];
    end
    %createTask(j,@doslice,1,...
    %           {Interpolator,Qx,Qy,slices(i),dir,RGBmap,fmin,fmax});
    x = doslice(Interpolator,Qx,Qy,slices(i),dir,RGBmap,fmin,fmax,outdir,samplename,i);
end

%submit(j);
%wait(j);
%colorImage = fetchOutputs(j);
colorImage = 0;
%delete(c.Jobs);

fprintf(logfile,' DONE.\n');
end

function f = doslice(Interpolator,x,y,z,image_name,RGBmap,fmin,fmax,outdir,samplename,k)
if image_name == false
    I = false;
else
    I = imread(image_name);
    I = permute(I,[2,1,3]);
end
f = Interpolator({x,y,z});
f = COMBINE_VOLUMES(f,I,RGBmap,fmin,fmax);
filename = [ outdir sprintf('%s_%04i.%s', samplename, k, 'png' )];
imwrite(f, filename, 'png' );
end

function colorImage = COMBINE_VOLUMES(F, I, RGBmap, fmin, fmax)
% F - function
% I - image
%% -----------------------------------------------------------------------
F(isnan(F)) = 0;

if numel(I) < 2
    % Image is not a volume
    colorImage = label2rgb(F,RGBmap,'k');
    colorImage = permute(colorImage,[2,1,3]);
else
    % Align each of the images to the same coordinate system
    sXWorldLimits = [fmin(2),fmax(2)+1];
    sYWorldLimits = [fmin(1),fmax(1)+1];
    RefF = imref2d(size(F),sXWorldLimits,sYWorldLimits);

    RefImage = imref2d(size(I),[0,size(I,2)],[0,size(I,1)]);

    % Convert both the strain map and original to color images
    colorImage = label2rgb(I+1,gray(2^16));
    colorStrain = label2rgb(F,RGBmap,'k');

    % Blend the colored strain map into the original image
    colorImage = imfuse(colorImage, RefImage, colorStrain, RefF, 'blend', 'Scaling','none');
    colorImage = permute(colorImage,[2,1,3]);
end
end
