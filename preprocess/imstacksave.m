function [] = imstacksave( stack, outdir, samplename )
%IMSTACKSAVE saves an image stack to outdir/samplename_0000.png Images are 
% slice in dimension 3.
%
% version 1.0.1
% INPUTS
%   stack (cell or matrix) color images have to be a cell because they are
%   MxNx3 wheras grey images are MxN
%
%
%% -----------------------------------------------------------------------
if samplename(1) ~= '/', samplename = ['/' samplename]; end

mkdir(outdir);
fprintf('Saving images from stack to %s\n', outdir);
addpath(outdir);

if iscell(stack)
    z = length(stack);
    parfor k = 1:z
        filename = [outdir sprintf('%s_%04i.png', samplename, k )]; 
        %disp(filename);
        imwrite( stack{k}, filename, 'png' );
    end
else
    [~,~,z] = size(stack); 
    parfor k = 1:z
        filename = [ outdir sprintf('%s_%04i.png', samplename, k )];
        imwrite( stack(:,:,k), filename, 'png' );
    end
end
end

