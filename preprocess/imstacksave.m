function [] = imstacksave( stack, outdir, samplename, format )
%IMSTACKSAVE saves an image stack to outdir/samplename_0000.png Images are 
% slice in dimension 3.
%
% version 1.1.0
% INPUTS
%   stack (cell or matrix) color images have to be a cell because they are
%   MxNx3 wheras grey images are MxN
%
%   format (string, optional) specifies how the ouput stack is saved can be
%   GIF, HDF, JPEG, TIFF, PNG, PBM, PGM, PPM, or RAW
%
% version 1.1.0 - adds capability to save BW images as raw files
%% -----------------------------------------------------------------------
if samplename(1) ~= '/', samplename = ['/' samplename]; end
if nargin < 4; format = 'tiff'; end

mkdir(outdir);
fprintf('Saving images from stack to %s\n', outdir);
addpath(outdir);

if strcmpi(format,'RAW')
    stack = permute(stack,[2,1,3]); % Matlab indexes columns first instead of rows.
    [width,height,depth] = size(stack);
    
    % Generate the full raw image.
    name = sprintf('%s%s_%i_%i_%iuint8.raw',outdir,samplename,width,height,depth);
    fid = fopen(name, 'w'); % Replace exisiting file contents.
    cnt = fwrite(fid, stack, 'uint8');
    fclose(fid);
    
elseif iscell(stack)
    z = length(stack);
    parfor k = 1:z
        filename = [outdir sprintf('%s_%04i.%s', samplename, k, format )]; 
        %disp(filename);
        imwrite( stack{k}, filename, format );
    end
else
    [~,~,z] = size(stack); 
    parfor k = 1:z
        filename = [ outdir sprintf('%s_%04i.%s', samplename, k, format )];
        imwrite( stack(:,:,k), filename, format );
    end
end
end

