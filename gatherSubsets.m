
%% ---Input Parameters
rotationCWs = [-47 -47 -55 -55];
x0s = [506 528 1317 867];
y0s = [204 1305 987 315];
width = 512;
height = 512;
notch = 2014; % Location of bottom slice
bitdepth = 8;
depth = 1900;

for i = 2:4
for proj_number = 290:291

rotationCW = rotationCWs(i);
x0 = x0s(i);
y0 = y0s(i);
    
indir = ['/home/chingd/OCT14C/sam13_D1228RH1_10x_dimax_110mm_20DegPerSec_180Deg_5msecExpTime_1500proj_Rolling_100umLuAG_1mmC_2mmGlass_pink_2.657mrad_BHutch/recon_proj_' num2str(proj_number)];
%[~, samplename, ~] = fileparts(indir);

samplename = sprintf('sam%i_%i', proj_number,i-1);

outdir = ['/home/chingd/OCT14M/Jakes/' samplename];
 
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
end