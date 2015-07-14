% This script is for the segmentation of a precut and rotated group as a
% whole.

samplename = 'pubfigure';
OUTDIR = ['/media/OCT14M/Segmentations/' samplename];
kNUMGDISTS = 4;
kBITDEPTH = 8;
STACKDEPTH = 1600;
WIDTH = 500;
HEIGHT = 1000;
numworkers = 6;
 
%% Creating a Log file ---------------------------------------------------

start_time = tic;
mkdir(OUTDIR);
logfile = fopen([OUTDIR '/log.txt'],'a');
fprintf(logfile,['\n' datestr(datetime('now'))]);

%% Gather all the images -------------------------------------------------
if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end

stack(6*STACKDEPTH,HEIGHT,WIDTH) = uint8(0); %sprintf('uint%i', kBITDEPTH))
for key = 1:6

switch key
    case 1
         INDIR = '/media/OCT14M/Segmentations/recon_proj_74';
    case 2
         INDIR = '/media/OCT14M/Segmentations/recon_proj_75';
    case 6
         INDIR = '/media/OCT14M/Segmentations/recon_proj_76';
    case 3
         INDIR = '/media/OCT14M/Segmentations/recon_proj_77';
    case 4
         INDIR = '/media/OCT14M/Segmentations/recon_proj_78';
    case 5
         INDIR = '/media/OCT14M/Segmentations/recon_proj_79';
end

addpath(genpath(INDIR)); % Files need on searchpath to use.

lo = (key-1)*STACKDEPTH + 1; 
hi = key*STACKDEPTH;
stack(:,:,lo:hi) = imstackload([ INDIR '/subset' ],sprintf('uint%i', kBITDEPTH));

end

delete(p);

%% Finding the gaussian distribution mixture -----------------------------

labels = findThresholds(stack, kNUMGDISTS, kBITDEPTH, logfile);
% if(~input('Does this distribution look appropriate? (1 Yes / 0 No)\n'))
%     return;
% end
disp('Saving labels ...');
save([OUTDIR '/labels.mat'], 'labels');
print([OUTDIR '/mixedgaussians'], '-dpng');

%% Segmenting and Smoothing ----------------------------------------------
if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end

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
