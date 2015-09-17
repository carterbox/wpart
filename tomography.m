classdef tomography
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rotationCW = [];
        x0 = [];
        y0 = [];
        
        height;
        width;
        depth;
        bottom = []; % Location of bottom slice
        
        bitdepth = 8;
        numdists = 2;
        thresh16 = [];
        
        samplename = ''; % The name of the sample with leading /
        projname = {}; % The names of each of the scans of the sample with leading /
        recon_dir = './'; % The directory of the reconstructions
        subset_dir = './'; % The directory to put the subsets
        segmented_dir = './'; % The directory to put the segmented subsets
    end
    
    methods
        function obj = tomography(height,width,depth,samplename)
            % Class constructor
            
            obj.width = width;
            obj.height = height;
            obj.depth = depth;
            
            if samplename(1) ~= '/', samplename = ['/' samplename]; end
            obj.samplename = samplename;
        end
        function obj = setProjname(obj,words,numbers)
            % Allows for quickly setting a series of projnames with the 
            % same start but different numbers at the end. e.g. /sample_1,
            % /sample_2, /sample_3
            
            n = numel(numbers);
            if words(1) ~= '/', words = ['/' words]; end            
            
            obj.projname = cell(1,n);
            for i = 1:n
                obj.projname{i} = sprintf('%s%i',words,numbers(i));
            end
        end
        function obj = gatherSubsets(obj)
            % Collects subsets from tomography volumes and saves them in
            % the subset directory.
            
            for i = 1:numel(obj.samplename)
                % Creating a working directories
                outdir = [obj.subset_dir obj.projname{i}];
                indir = [obj.recon_dir obj.projname{i}];
                mkdir(outdir);addpath(genpath(indir));
                
                logfile = fopen( [outdir '/log.txt'], 'w' );
                fprintf(logfile, '%s\n\n', indir );
                fprintf(logfile, 'CW Rotation: %.1f\n',obj.rotationCW(i) );
                fprintf(logfile, 'x0: %i  y0: %i\n', obj.x0(i), obj.y0(i) );
                fprintf(logfile, 'width: %i  height: %i\n', obj.width, obj.height);
                fprintf(logfile, 'notch: %i ', obj.bottom(i) );

                % Loading rotating cropping and scaling
                stack = makeSubset( indir, obj.rotationCW(i), obj.x0(i), obj.y0(i), obj.width, obj.height, obj.depth, obj.bottom(i) );
                [~,~,ldepth] = size(stack);
                fprintf(logfile, 'depth: %i\n', ldepth );
                if ldepth ~= obj.depth, warning('Desired stack depth not reached.'); end
                stack = rescale(stack, 16, logfile);
                imshow(uint8(stack(:,:,1)),'InitialMagnification','fit')
                
                % if(~input('Is this the slice you want? (1 Yes / 0 No)\n'))
                %     return;
                % end
                
                disp('Saving subset ...');
                imstacksave(uint16(stack), outdir , obj.projname{i} );
                fclose( logfile );
            end
        end
        function obj = segmentSubsets(obj) 
            % Creating a Log file
            OUTDIR = [obj.segmented_dir obj.samplename]; mkdir(OUTDIR);
            logfile = fopen([OUTDIR '/log.txt'],'a');
            fprintf(logfile,['\n' datestr(datetime('now')) '\n\n']);
            
            NUMSTACKS = length(obj.projname);

            
            
            % Sample 2 percent of the data to reduce memory and processing consumption.
            numsamples = ceil(0.02*obj.depth);
            fprintf('NUM SAMPLED SLICES IS %i \n', numsamples);
            
            sample(obj.height,obj.width,numsamples,NUMSTACKS) = uint8(0);
            obj.thresh16 = zeros(NUMSTACKS,1);
            for key = 1:NUMSTACKS
                addpath(genpath([obj.subset_dir obj.projname{key}]));
                stack = imstackload([obj.subset_dir obj.projname{key}], 'uint16');

                stack = stack(:,:,random('unid', obj.depth, [1,numsamples]));
                
                fprintf('FINDING DISTRIBUTION FOR SAMPLE %i\n', key);
                labels = findThresholds(stack, 3, 16, 1);
                
                obj.thresh16(key) = find(labels>1,1);
                stack = rescale(stack, 8, logfile, obj.thresh16(key));
                
                sample(:,:,:,key) = stack;
            end
            sample = double(sample(:));

            
            %% Finding the gaussian distribution mixture -----------------------------

            fprintf('FINDING DISTRIBUTIONS FOR GROUP\n');
            diary([OUTDIR '/log.txt']);
            labels = findThresholds(sample, 3, obj.bitdepth, logfile);
            clear sample;
            disp('Saving labels ...');
            save([OUTDIR '/labels.mat'], 'labels', 'obj');
            print([OUTDIR '/mixedgaussians'], '-dpng');
            diary off; 
            %% Segmenting and Smoothing ----------------------------------------------
            %if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end

            for key = 1:NUMSTACKS
                % Load each of the stacks to process them separately
                stack = imstackload([obj.subset_dir obj.projname{key}],...
                                    sprintf('uint%i', 16));
                stack = rescale(stack, obj.bitdepth, 1, obj.thresh16(key));
                stack = uint8(stack);

                % Segment the image according to the lookup-table.
                %fprintf('Mapping...\n');
                %segmented = labels(stack + 1);
                segmented = woodmap(stack, labels);

                segmented = removeislands(segmented, 0, 80);

                output = woodcolor('remove', segmented, 4, logfile, 1, stack);
                imstacksave(output,sprintf('%s/nobackground_%02i',OUTDIR,key),obj.samplename);
                print([OUTDIR '/comparisonr' num2str(key)],'-dpng');

                output = woodcolor('c', segmented, 4, logfile, 1, stack);
                imstacksave(output,sprintf('%s/color%02i',OUTDIR,key),obj.samplename);
                print([OUTDIR '/comparisonc' num2str(key)],'-dpng');

            end
            fprintf(logfile,'\n');
            fclose(logfile); close all;
        end
    end
    
end

