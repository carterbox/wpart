
%% ---Input Parameters
rotationCW = 30;
x0 = 1023;
y0 = 1131;
width = 512;
height = 512;
notch = 1500; % Location of bottom slice
bitdepth = 8;
depth = 800;

parpool(4);

for proj_number = 60:65

indir = ['/media/OCT14B/OCT14B/Reconstructions/recon_proj_' num2str(proj_number)];
[~, samplename, ~] = fileparts(indir);
outdir = ['/media/OCT14M/Segmentations/Chad/' samplename];
 
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