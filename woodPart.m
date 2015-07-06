%% ---Input Parameters
         rotationCW = 35;
         x0 = 932;
         y0 = 868;
         width = 512;
         height = 1024;

switch 10
    case 1
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_61';
         notch = 1620;
    case 2
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_62';
         notch = 1620;
    case 3
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_63';
         notch = 1630;
    case 4
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_64';
         notch = 1700;
    case 5
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_65';
         notch = 1820;
    case 6
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_66';
         notch = 1814;
         rotationCW = -25;
         x0 = 712;
         y0 = 1072;
         width = 1280;
         height = 256;
    case 7
        indir = '/media/Windows/Users/chingd.FORESTRY/Google Drive/Research/MATLAB/input/EEPHDFA';
        notch = 100;
        rotationCW = 20;
        %79-100 seconds 4 Modes windows
        %59 second Linux
    case 8
        indir = '/media/Windows/Users/chingd.FORESTRY/Google Drive/Research/MATLAB/input/HPPHEL01';
        notch = 100;
        rotationCW = -8;
        %100-119 seconds 4 Modes Windows
    case 9
        indir = '/media/Windows/Users/chingd.FORESTRY/Google Drive/Research/MATLAB/input/SPPHEL00';
        notch = 200;
        rotationCW = -62;
        %265 177 seconds 4 Modes Windows
    case 10
        indir = '/media/OCT14M/Reconstructions/recon_proj_41';
        notch = 2500;
        rotationCW = -34;
         x0 = 247;
         y0 = 522;
         width = 1973;
         height = 885;
    case 11
        indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_46';
        notch = 2500;
        rotationCW = 45;
         x0 = 372;
         y0 = 906;
         width = 1854;
         height = 525;
    case 12
        indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_61';
        notch = 2500;
        rotationCW = 30.5;
         x0 = 434;
         y0 = 392;
         width = 1544;
         height = 1074;
end


[~, samplename, ~] = fileparts(indir);
outdir = ['/media/OCT14M/Segmentations/JJ/' samplename];
numGModes = 5;
bitdepth = 8;
depth = 2500;
 
%% ---Creating a Log file
start_time = tic;
mkdir( outdir );
addpath( genpath(indir) ); %got to add files to searchpath to use them
logfile = fopen( [outdir '/log.txt'], 'w' );
fprintf(logfile, '%s\n', indir );
    fprintf(logfile, '\n');
fprintf(logfile, 'CW Rotation: %.1f\n',rotationCW );
fprintf(logfile, 'x0: %i  y0: %i\n', x0, y0 );
fprintf(logfile, 'width: %i  height: %i\n', width, height);
fprintf(logfile, 'notch: %i ', notch );
%% ---Loading rotating cropping and scaling
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
%% ---Finding the gaussian distribution mixture
labels = findThresholds( stack, numGModes, bitdepth, logfile );
% if(~input('Does this distribution look appropriate? (1 Yes / 0 No)\n'))
%     return;
% end
disp('Saving labels ...');
save([outdir '/labels.mat'], 'labels');
print([outdir '/mixedgaussians'], '-dpng');
%% ---Segmenting and Smoothing
segmented = woodmap(stack, labels);
segmented = removeislands(segmented,numGModes,80);
output = woodcolor('r',segmented, numGModes, logfile, 1, stack);
imstacksave(output, [ outdir '/segmented' ], samplename );
print([outdir '/comparison'], '-dpng');

    fprintf(logfile, '\n');
fprintf( logfile, 'Total runtime was %.2f\n', toc(start_time) );
fclose( logfile );