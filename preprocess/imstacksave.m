function [] = imstacksave( stack, outdir, samplename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
mkdir(outdir);
fprintf('Saving images from stack to %s\n', outdir);
addpath(outdir);

if iscell(stack)
    z = length(stack);
    parfor k = 1:z
        filename = [outdir '/' sprintf('%s_%04i.png', samplename, k )]; 
        %disp(filename);
        imwrite( stack{k}, filename, 'png' );
    end
else
    [~,~,z] = size(stack); 
    parfor k = 1:z
        filename = [ outdir '/' sprintf('%s_%04i.png', samplename, k )];
        imwrite( stack(:,:,k), filename, 'png' );
    end
end
end

