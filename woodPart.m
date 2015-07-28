% This script segments datasets of various sizes for each of the wood types
%: Poplar, earlywood, and latewood.

for key = 2:10
%% Input Parameters ------------------------------------------------------

kSTACKWIDTH = 256;
kSTACKHEIGHT = 256;
STACKDEPTH = 2048;
notch = 2048+16;
kNUMGDISTS = 4;

if key < 4
    % Earlywood Samples
    INDIR = '/media/OCT14M/Reconstructions/recon_proj_97';
    ROTATIONCW = 15;
    notch = 1536+16;
    STACKDEPTH = 1536;
    switch key
        case 1
            % Bulk No Adhesive
            samplename = 'earlywood0';
            X_CORNER = 454;
            Y_CORNER = 1281;
        case 2
            % Bulk
            samplename = 'earlywood1';
            X_CORNER = 927;
            Y_CORNER = 1668;
        case 3
            % Bondline
            samplename = 'earlywood2';
            X_CORNER = 1223;
            Y_CORNER = 1519;
    end
elseif key > 3 && key < 7
    % Latewood Samples
    INDIR = '/media/OCT14M/Reconstructions/recon_proj_97';
    ROTATIONCW = -10;
    switch key
        case 4
            % Bulk
            samplename = 'latewood0';
            X_CORNER = 793;
            Y_CORNER = 843;
        case 5
            % Bulk
            samplename = 'latewood1';
            X_CORNER = 1295;
            Y_CORNER = 786;
        case 6
            % Bondline maxdepth 1500
            samplename = 'latewood2';
            X_CORNER = 1570;
            Y_CORNER = 1319;
    end
else
    % Hybrid Poplar Samples
    INDIR = '/media/OCT14M/Reconstructions/recon_proj_81';
    ROTATIONCW = -7;
    kNUMGDISTS = 5;
    switch key
        case 7
            % Bulk
            samplename = 'hybridpoplar0';
            X_CORNER = 722;
            Y_CORNER = 1573;
        case 8
            % Bulk
            samplename = 'hybridpoplar1';
            X_CORNER = 1202;
            Y_CORNER = 1414;
        case 9
            % Bulk No Adhesive
            samplename = 'hybridpoplar2';
            X_CORNER = 1484;
            Y_CORNER = 1691;
        case 10
            % Bondline Max Depth 1700
            samplename = 'hybridpoplar3';
            X_CORNER = 1439;
            Y_CORNER = 1136;
            notch = 1536+16;
            STACKDEPTH = 1536;
    end
end
%[~, samplename, ~] = fileparts(INDIR);
OUTDIR = ['/media/OCT14M/Segmentations/' samplename];
kBITDEPTH = 8;
numworkers = 4;
 
%% Creating a Log file ---------------------------------------------------

start_time = tic;
mkdir(OUTDIR); addpath(genpath(INDIR)); % Files need on searchpath to use.
logfile = fopen([OUTDIR '/log.txt'],'a');
fprintf(logfile,['\n' datestr(datetime('now'))]);
fprintf(logfile, '\n%s\n', INDIR );
fprintf(logfile, '\n');
fprintf(logfile, 'CW Rotation: %.1f\n', ROTATIONCW );
fprintf(logfile, 'x0: %i  y0: %i\n', X_CORNER, Y_CORNER );
fprintf(logfile, 'width: %i  height: %i\n', kSTACKWIDTH, kSTACKHEIGHT);
fprintf(logfile, 'notch: %i ', notch);

%% Loading rotating cropping and scaling ---------------------------------

if 0 == exist([ OUTDIR '/subset' ],'dir')
    if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end
    
    stack = makeSubset(INDIR, ROTATIONCW, X_CORNER, Y_CORNER, kSTACKWIDTH,...
                       kSTACKHEIGHT, STACKDEPTH, notch);
    % Redefine stackdepth just in case it was too big.
    STACKDEPTH = size(stack,3);
    fprintf(logfile, 'depth: %i\n', STACKDEPTH );
    stack = uint8(rescale(stack, kBITDEPTH, logfile));
    imshow(uint8(stack(:,:,1)),'InitialMagnification','fit')
    %if(~input('Is this the slice you want? (1 Yes / 0 No)\n'))
    %    return;
    %end
    disp('Saving subset ...');
    imstacksave(uint8(stack), [ OUTDIR '/subset' ], samplename );
    delete(p);
else
    stack = imstackload([ OUTDIR '/subset' ],sprintf('uint%i', kBITDEPTH));
end

%% Finding the gaussian distribution mixture -----------------------------

labels = findThresholds(stack, kNUMGDISTS, kBITDEPTH, logfile);
%if(~input('Does this distribution look appropriate? (1 Yes / 0 No)\n'))
%    return;
%end
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
output = woodcolor('r', segmented, 5, logfile, 1, stack);

imstacksave(output,[ OUTDIR '/segmented_c' ],samplename);
print([OUTDIR '/comparison'],'-dpng');
fprintf(logfile,'\n');
fprintf(logfile,'Total runtime was %.2f\n',toc(start_time));

delete(p); fclose(logfile);
end
