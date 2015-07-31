% This script is for the segmentation of a precut and rotated group as a
% whole.

samplename = 'chad0';
OUTDIR = ['/media/OCT14M/Segmentations/' samplename];
kNUMGDISTS = 4;
kBITDEPTH = 8;
STACKDEPTH = 1600;
WIDTH = 512;
HEIGHT = 1024;
numworkers = 6;
 
%% Creating a Log file ---------------------------------------------------

start_time = tic;
mkdir(OUTDIR);
logfile = fopen([OUTDIR '/log.txt'],'a');
diary([OUTDIR '/log.txt']);
fprintf(logfile,['\n' datestr(datetime('now'))]);

%% Gather all the images -------------------------------------------------
if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end

NUMSTACKS = 6;
INDIR = cell(NUMSTACKS,1);
INDIR{1} = '/media/OCT14M/Segmentations/Chad/recon_proj_74';
INDIR{2} = '/media/OCT14M/Segmentations/Chad/recon_proj_75';
INDIR{3} = '/media/OCT14M/Segmentations/Chad/recon_proj_76';
INDIR{4} = '/media/OCT14M/Segmentations/Chad/recon_proj_77';
INDIR{5} = '/media/OCT14M/Segmentations/Chad/recon_proj_78';
INDIR{6} = '/media/OCT14M/Segmentations/Chad/recon_proj_79';

stack(HEIGHT,WIDTH,STACKDEPTH,NUMSTACKS) = uint8(0); %sprintf('uint%i', kBITDEPTH))
diary on;
parfor key = 1:6
addpath(genpath(INDIR{key})); % Files need on searchpath to use.
temp = imstackload([ INDIR{key} '/subset' ],sprintf('uint%i', kBITDEPTH));
stack(:,:,:,key) = rescale(temp,8,1);
end
diary off;

delete(p);


% Sample 2 percent of the data to reduce memory and processing consumption.
fprintf('Sampling dataset... \n');
numsamples = ceil(0.02*STACKDEPTH);
sample = stack(:,:,random('unid', STACKDEPTH, [1,numsamples]), :);
fprintf( logfile, '\nNUM SAMPLED SLICES IS %i \n', numsamples);

clear stack;
sample = double(sample(:));

%% Finding the gaussian distribution mixture -----------------------------

labels = findThresholds(sample, kNUMGDISTS, kBITDEPTH, logfile);
clear stack;
disp('Saving labels ...');
save([OUTDIR '/labels.mat'], 'labels');
print([OUTDIR '/mixedgaussians'], '-dpng');

%% Segmenting and Smoothing ----------------------------------------------
if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end

for key = 1:6
    % Load each of the stacks to process them separately
    stack = imstackload([INDIR{key} '/subset'],...
                        sprintf('uint%i', kBITDEPTH));
    
    % Segment the image according to the lookup-table.
    % fprintf('Mapping...\n');
    % segmented = labels(stack + 1);
    segmented = woodmap(stack, labels);

    segmented = removeislands(segmented, 5, 80);
    output = woodcolor('b', segmented, 5, logfile, 1, stack);

    imstacksave(output,sprintf('%s/segmented_c%2i',OUTDIR,key),samplename);
end

print([OUTDIR '/comparison'],'-dpng');
fprintf(logfile,'\n');
fprintf(logfile,'Total runtime was %.2f\n',toc(start_time));

delete(p); fclose(logfile);
