for iteration = 1:6
%% ---Input Parameters
         rotationCW = 27;
         x0 = 936;
         y0 = 844;
         width = 512;
         height = 512;
         notch = 1866; % Location of bottom slice

switch iteration
    case 1
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_74';
    case 2
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_75';
    case 3
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_76';
    case 4
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_77';
    case 5
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_78';
    case 6
         indir = '/media/OCT14B/OCT14B/Reconstructions/recon_proj_79';
end


        [~, samplename, ~] = fileparts(indir);
        outdir = ['/media/OCT14M/Segmentations/Chad/' samplename];
        bitdepth = 8;
        depth = 800;
 
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

%% ---Clean uP
fprintf( logfile, 'Total runtime was %.2f\n', toc(start_time) );
fclose( logfile );
end