for key = 1
%% ---Input Parameters
         rotationCW = 27;
         x0 = 917;
         y0 = 1146;
         width = 512;
         height = 1024;

switch key
    case 1
         indir = '/media/OCT14M/Reconstructions/recon_proj_74';
         notch = 1726;
    case 2
         indir = '/media/OCT14M/Reconstructions/recon_proj_75';
         notch = 1726;
    case 3
         indir = '/media/OCT14M/Reconstructions/recon_proj_77';
         notch = 1726;
    case 4
         indir = '/media/OCT14M/Reconstructions/recon_proj_78';
         notch = 1726;
    case 5
         indir = '/media/OCT14M/Reconstructions/recon_proj_79';
         notch = 1866;
end


[~, samplename, ~] = fileparts(indir);
outdir = ['/media/OCT14M/Segmentations/' samplename];
numGModes = 4;
bitdepth = 8;
depth = 500;
 
%% ---Creating a Log file
start_time = tic;
mkdir( outdir );
addpath( genpath(indir) ); %got to add files to searchpath to use them
logfile = 1; %fopen( [outdir '/log.txt'], 'a' );
fprintf(logfile, ['\n' datestr(datetime('now'))]);
fprintf(logfile, '\n%s\n', indir );
    fprintf(logfile, '\n');
fprintf(logfile, 'CW Rotation: %.1f\n',rotationCW );
fprintf(logfile, 'x0: %i  y0: %i\n', x0, y0 );
fprintf(logfile, 'width: %i  height: %i\n', width, height);
fprintf(logfile, 'notch: %i ', notch );
%% ---Loading rotating cropping and scaling
if 0 == exist([ outdir '/subset' ],'dir')
    p = parpool(4);
    stack = makeSubset( indir, rotationCW, x0, y0, width, height, depth, notch );
    [~,~,depth] = size(stack);
    fprintf(logfile, 'depth: %i\n', depth );
    stack = rescale(stack, bitdepth, logfile);
    imshow(uint8(stack(:,:,1)),'InitialMagnification','fit')
    % if(~input('Is this the slice you want? (1 Yes / 0 No)\n'))
    %     return;
    % end
    disp('Saving subset ...');
    imstacksave(uint8(stack), [ outdir '/subset' ], samplename );
    delete(p);
else
    stack = imstackload([ outdir '/subset' ],sprintf('uint%i', bitdepth));
end
%% ---Finding the gaussian distribution mixture
labels = findThresholds( stack, numGModes, bitdepth, logfile );
% if(~input('Does this distribution look appropriate? (1 Yes / 0 No)\n'))
%     return;
% end
disp('Saving labels ...');
save([outdir '/labels.mat'], 'labels');
print([outdir '/mixedgaussians'], '-dpng');
%% ---Segmenting and Smoothing
if size(gcp) == 0, p = parpool(4); else p = gcp; end
segmented = woodmap(stack, labels);
raw_segmented = uint8(segmented);
save([ outdir '/raw_segmented.mat' ], 'raw_segmented');
clear('raw_segmented');
%segmented = removeislands(segmented,5,80);
output = woodcolor('c',segmented, 5, logfile, 1, stack);
imstacksave(output, [ outdir '/segmented_c' ], samplename );
print([outdir '/comparison'], '-dpng');
    fprintf(logfile, '\n');
fprintf( logfile, 'Total runtime was %.2f\n', toc(start_time) );
delete(p);
fclose( logfile );
end