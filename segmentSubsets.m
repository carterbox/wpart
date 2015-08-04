% This script is for the segmentation of a precut and rotated group as a
% whole.

samplename = 'SPPHEL00';
OUTDIR = ['/media/OCT14M/Segmentations/lookbook/' samplename];
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
fprintf(logfile,['\n' datestr(datetime('now'))]);

%% Gather all the images -------------------------------------------------

INDIR = {...
'/media/OCT14M/Segmentations/Chad/recon_proj_74';...
'/media/OCT14M/Segmentations/Chad/recon_proj_75';...
'/media/OCT14M/Segmentations/Chad/recon_proj_76';...
'/media/OCT14M/Segmentations/Chad/recon_proj_77';...
'/media/OCT14M/Segmentations/Chad/recon_proj_78';...
'/media/OCT14M/Segmentations/Chad/recon_proj_79'};
NUMSTACKS = length(INDIR);

%% ---------------------
diary([OUTDIR '/log.txt']);

% Sample 2 percent of the data to reduce memory and processing consumption.
numsamples = ceil(0.02*STACKDEPTH);
sample(HEIGHT,WIDTH,numsamples,NUMSTACKS) = uint8(0); 

for key = 1:NUMSTACKS
    addpath(genpath(INDIR{key})); % Files need on searchpath to use.
    stack = imstackload([ INDIR{key} '/subset' ],sprintf('uint%i', kBITDEPTH));

    stack = stack(:,:,random('unid', STACKDEPTH, [1,numsamples]));
    fprintf('NUM SAMPLED SLICES IS %i \n\n', numsamples);

    sample(:,:,:,key) = stack;
end
sample = double(sample(:));

diary off;
%% Finding the gaussian distribution mixture -----------------------------

labels = findThresholds(sample, kNUMGDISTS, kBITDEPTH, logfile);
clear sample;
disp('Saving labels ...');
save([OUTDIR '/labels.mat'], 'labels');
print([OUTDIR '/mixedgaussians'], '-dpng');

%% Segmenting and Smoothing ----------------------------------------------
if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end

for key = 1:NUMSTACKS
    % Load each of the stacks to process them separately
    stack = imstackload([INDIR{key} '/subset'],...
                        sprintf('uint%i', kBITDEPTH));
    
    % Segment the image according to the lookup-table.
    %fprintf('Mapping...\n');
    %segmented = labels(stack + 1);
    segmented = woodmap(stack, labels);

    segmented = removeislands(segmented, 5, 80);
    objcrop = segmented(1:2:min(512,HEIGHT),1:2:min(512,WIDTH),1:2:min(512,STACKDEPTH));
    objname = sprintf('%s/step%02i.obj', OUTDIR, key);
    if exist(objname, 'file') == 0, makeobj(objcrop, objname); end;
    
%     output = woodcolor('remove', segmented, 5, logfile, 1, stack);
%     imstacksave(output,sprintf('%s/nobackground_%02i',OUTDIR,key),samplename);
%     print([OUTDIR '/comparisonr' num2str(key)],'-dpng');
%     
%     output = woodcolor('c', segmented, 5, logfile, 1, stack);
%     imstacksave(output,sprintf('%s/color%02i',OUTDIR,key),samplename);
%     print([OUTDIR '/comparisonc' num2str(key)],'-dpng');
    
end
fprintf(logfile,'\n');
fprintf(logfile,'Total runtime was %.2f\n',toc(start_time));

delete(p); fclose(logfile);
