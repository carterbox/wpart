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
        numdists = [4,2];
        thresh16;
        labels = {};
        
        samplename = ''; % The name of the sample with leading /
        projname = {}; % The names of each of the scans of the sample with leading /
        recon_dir = './'; % The directory of the reconstructions
        subset_dir = './'; % The directory to put the subsets
        segmented_dir = './'; % The directory to put the segmented subsets
    end
    
    methods
        % Constructor for the class.
        function obj = tomography(height,width,depth,samplename)
            % Class constructor
            
            obj.width = width;
            obj.height = height;
            obj.depth = depth;
            
            if samplename(1) ~= '/', samplename = ['/' samplename]; end
            obj.samplename = samplename;
        end
        
        % Allows for 2 or 0 inputs. If 0 inputs are given, it will draw a
        % histogram and prompt the user to give inputs.
        function obj = setnumdists(obj, varargin)
           if numel(varargin) == 2
               obj.numdists(1) = varargin{1};
               obj.numdists(2) = varargin{2};
           else
               key = 1;
               if ~isempty(obj.projname) && exist([obj.subset_dir obj.projname{key}],'dir')
                   addpath(genpath([obj.subset_dir obj.projname{key}]));
                   
                   stack = imstackload([obj.subset_dir obj.projname{key}], 'uint16');
                   stack = stack(:,:,random('unid', obj.depth, [1,round(obj.depth*0.02)]));
                                 
                   h = figure(1);
                   stack = removex(stack(:),2^16-1,1);
                   histogram(stack, 2^16,'Normalization','pdf');
                   axis([0 2^16 0 inf]);
                   
                   obj.numdists(1) = input('How many distributions for phase 1? ');
                   obj.numdists(2) = input('How many distributions for phase 2? ');

                   close(h);
               else
                   warning('Unable to show histogram; project name does not exist.');
               end
           end
            
            
        end
        
        % Allows for quickly setting a series of projnames with the 
        % same start but different numbers at the end. e.g. /sample_1,
        % /sample_2, /sample_3
        function obj = setprojname(obj,words,numbers)
            
            
            n = numel(numbers);
            if words(1) ~= '/', words = ['/' words]; end            
            
            obj.projname = cell(1,n);
            for i = 1:n
                obj.projname{i} = sprintf('%s%i',words,numbers(i));
            end
        end
        
        % Collects subsets from tomography volumes and saves them in
        % the subset directory.
        function obj = gatherSubsets(obj)
     
            for i = 1:numel(obj.projname)
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
        
        function obj = fitDists(obj)
            % Creating a Log file
            OUTDIR = [obj.segmented_dir obj.samplename]; mkdir(OUTDIR);
            logfile = fopen([OUTDIR '/log.txt'],'a');
            fprintf(logfile,['\n' datestr(datetime('now')) '\n\n']);
            
            NUMSTACKS = length(obj.projname);
            
            for key = 1:NUMSTACKS
                addpath(genpath([obj.subset_dir obj.projname{key}]));
                % Sample 2 percent of the data to reduce memory and processing consumption.
                stack = imstackload([obj.subset_dir obj.projname{key}], 'uint16', 0.01);

                tryagain = true;
                while tryagain
                    fprintf('FINDING DISTRIBUTION FOR SAMPLE %i\n', key);

                    [llabels, ~, gaussfig] = findThresholds(stack, obj.numdists(1), 16, logfile);
                    print(gaussfig, [OUTDIR sprintf('/sample%02i',key)], '-dpng');

                    obj.thresh16(key) = find(llabels>1,1);
                    obj.labels{key} = llabels;
                   
                    tryagain = ~input('Does this look good? (Yes - 1 / No - 0) ');
                    if tryagain
                        obj.numdists(1) = input('Provide a new numdists: ');
                    end
                end
            end
            save([OUTDIR sprintf('/tomography.mat')], 'obj');
        end
        
        function obj = segmentSubsets(obj)
            OUTDIR = [obj.segmented_dir obj.samplename]; mkdir(OUTDIR);
            load([OUTDIR sprintf('/tomography.mat')], 'obj');
            logfile = fopen([OUTDIR '/log.txt'],'a');
            %if size(gcp) == 0, p = parpool(numworkers); else p = gcp; end
            NUMSTACKS = length(obj.projname);
            for key = 1:NUMSTACKS
                % Load each of the stacks to process them separately
                stack = imstackload([obj.subset_dir obj.projname{key}],...
                                    sprintf('uint%i', 16));

                % Segment the image according to the lookup-table.
                fprintf('Mapping...\n');
                segmented = obj.labels{key}(stack + 1);
                %segmented = woodmap(stack, labels);

                segmentedi = removeislands(segmented, 8, 100);

                output = woodcolor('c', segmentedi, 4, logfile, 1, uint16(stack(:,:,1)));
                imstacksave(output,sprintf('%s/color_%02i',OUTDIR,key),obj.samplename);
                print([OUTDIR '/comparisonc' num2str(key,'%02i')],'-dpng');
                
                output = uint8(rescale(stack, obj.bitdepth, 1, obj.thresh16(key)));
                imstacksave(output,sprintf('%s/nobackground_%02i',OUTDIR,key),obj.samplename);             
            end
            fprintf(logfile,'\n');
            fclose(logfile); close all;
        end    
    end
end

function A = removex(A,hi,lo)
%REMOVEX removes values in A that are outside the range (lo,hi).
    if(nargin) < 3, lo = -1; end

    A = sort(A);
    right = sum(A < hi);
    left = find(A > lo,1);
    A = A(left:right);
end

