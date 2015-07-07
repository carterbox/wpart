% This script segments proj_74-79 which are a Douglas-fir specimen that has
% a visible cracking that progresses in each scan.

for key = 3:5
%% Input Parameters ------------------------------------------------------

ROTATIONCW = 27;
X_CORNER = 917;
Y_CORNER = 1146;
kSTACKWIDTH = 512;
kSTACKHEIGHT = 1024;

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
OUTDIR = ['/media/OCT14M/Segmentations/' samplename];
kNUMGDISTS = 4;
kBITDEPTH = 8;
STACKDEPTH = 1600;
 
%% Creating a Log file ---------------------------------------------------

start_time = tic;
mkdir(OUTDIR); addpath(genpath(indir)); % Files need on searchpath to use.
logfile = fopen([OUTDIR '/log.txt'],'a');
fprintf(logfile,['\n' datestr(datetime('now'))]);
fprintf(logfile, '\n%s\n', indir );
fprintf(logfile, '\n');
fprintf(logfile, 'CW Rotation: %.1f\n', ROTATIONCW );
fprintf(logfile, 'x0: %i  y0: %i\n', X_CORNER, Y_CORNER );
fprintf(logfile, 'width: %i  height: %i\n', kSTACKWIDTH, kSTACKHEIGHT);
fprintf(logfile, 'notch: %i ', notch);

%% Loading rotating cropping and scaling ---------------------------------

if 0 == exist([ OUTDIR '/subset' ],'dir')
    if size(gcp) == 0, p = parpool(4); else p = gcp; end
    
    stack = makeSubset(indir, ROTATIONCW, X_CORNER, Y_CORNER, kSTACKWIDTH,...
                       kSTACKHEIGHT, STACKDEPTH, notch);
    % Redefine stackdepth just in case it was too big.
    STACKDEPTH = size(stack,3);
    fprintf(logfile, 'depth: %i\n', STACKDEPTH );
    stack = uint8(rescale(stack, kBITDEPTH, logfile));
    imshow(uint8(stack(:,:,1)),'InitialMagnification','fit')
    % if(~input('Is this the slice you want? (1 Yes / 0 No)\n'))
    %     return;
    % end
    disp('Saving subset ...');
    imstacksave(uint8(stack), [ OUTDIR '/subset' ], samplename );
    delete(p);
else
    stack = imstackload([ OUTDIR '/subset' ],sprintf('uint%i', kBITDEPTH));
end

%% Finding the gaussian distribution mixture -----------------------------

labels = findThresholds(stack, kNUMGDISTS, kBITDEPTH, logfile);
% if(~input('Does this distribution look appropriate? (1 Yes / 0 No)\n'))
%     return;
% end
disp('Saving labels ...');
save([OUTDIR '/labels.mat'], 'labels');
print([OUTDIR '/mixedgaussians'], '-dpng');

%% Segmenting and Smoothing ----------------------------------------------
if size(gcp) == 0, p = parpool(4); else p = gcp; end

% Segment the image according to the lookup-table.
% fprintf('Mapping...\n');
% segmented = labels(stack + 1);
segmented = woodmap(stack, labels);

% Save a copy for debugging.
raw_segmented = segmented;
save([OUTDIR '/raw_segmented.mat'],'raw_segmented');
clear raw_segmented;

segmented = removeislands(segmented, 5, 80);
output = woodcolor('c', segmented, 5, logfile, 1, stack);

imstacksave(output,[ OUTDIR '/segmented_c' ],samplename);
print([OUTDIR '/comparison'],'-dpng');
fprintf(logfile,'\n');
fprintf(logfile,'Total runtime was %.2f\n',toc(start_time));

delete(p); fclose(logfile);
end