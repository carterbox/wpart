classdef tomography
% TOMOGRAPHY an object for organizing, cropping, and segmenting tomography
%   data.
%
% TOMOGRAPHY has the following properties:
%   ROTATIONCW a list of the clockwise rotation applied before cropping.
%   X0, Y0, Z0 a list of the coordinates of min corner of the cropped
%       subset after rotation inside the raw tomography.
%   HEIGHT, WIDTH, DEPTH the size of all of the cropped subsets.
%   BITDEPTH the bitdepth of the subsets returned after cropping.
%       Default: 8
%   NUMDISTS a list of the number of gaussians fit to the subset histograms.
%       Default: 4
%   THRESH16 a list of the threshold values between background and
%       foreground data.
%       Default: 3*10^4
%   LABELS
%   SAMPLENAME the name of the group of projects. All the created files
%       will be organized under a folder of this name.
%   PROJNAME the names of each of the folders containing the raw
%       tomography.
%   RECON_DIR the directory where reconstructions are stored.
%   SUBSET_DIR the directory to put the subsets.
%   SEGMENTED_DIR the directory to put the segmented subsets.
%
%% -----------------------------------------------------------------------
    properties
        % Properties related to cropping a subset
        rotationCW = [];
        x0 = []; 
        y0 = [];
        z0 = [];
        
        % subset dimensions
        height;
        width;
        depth;
        
        bitdepth = 8;
        numdists = [4];
        thresh16 = [3*10^4];
        labels = {};
        
        samplename = '';
        projname = {};
        recon_dir = './';
        subset_dir = './';
        segmented_dir = './';
    end
    
    
    methods
        function obj = tomography(width,height,depth,samplename)
        % T = TOMOGRAPHY(WIDTH,HEIGHT,DEPTH,SAMPLENAME) is the default
        % contructor it assigns the shape and name of the subset which
        % will be created and managed.
        %% ----------------------------------------------------------------
            obj.width = width;
            obj.height = height;
            obj.depth = depth;
            
            if samplename(1) ~= '/', samplename = ['/' samplename]; end
            obj.samplename = samplename;
        end
        
        
        function obj = setnumdists(obj, num_dists)        
        % T = SETNUMDISTS(T, NUM_DISTS) returns a copy of T with the number of
        % distributions for histogram fitting to NUM_DISTS. If no inputs are given,
        % it will draw a histogram from the data and prompt the user to
        % choose an initial number of distributions.
        %% ----------------------------------------------------------------
           if exist('num_dists', 'var') == 1
               obj.numdists(1) = num_dists;
           else
               key = 1;
               if ~isempty(obj.projname) && exist([obj.subset_dir obj.samplename obj.projname{key}],'dir')
                   
                   addpath(genpath([obj.subset_dir obj.samplename obj.projname{key}]));
                   
                   stack = imstackload([obj.subset_dir obj.samplename obj.projname{key}], 'uint16', 0.02);
                                 
                   h = figure(1);
                   stack = removex(stack(:),2^16-1,1);
                   histogram(stack, 2^16,'Normalization','pdf');
%                    axis([0 2^16 0 inf]);
                   
                   while(true)
                        try
                            answer = input('Estimate the number of distributions? ');
                        catch
                        end
                        if(isa(answer,'double') && answer > 0)
                            obj.numdists(key) = floor(answer);
                            fprintf('Numdists set to %i\n', obj.numdists(key));
                            break;
                        else
                            fprintf('Only positive numbers please.\n')
                        end
                   end
                    
                   close(h);
               else
                   warning('Unable to show histogram; project name does not exist.');
               end
           end
        end
        
        
        function obj = setprojname(obj,words,numbers)
        % T = SETPROJNAME(T, WORDS, NUMBERS) returns a copy of T with
        % T.projnames set with WORDS as the same base name and NUMBERS
        % as the suffex.
        %
        % For setprojname('sample_', [4,2,9]) projname would become
        % {'/sample_4', '/sample_2', '/sample_9'}.
        %% -----------------------------------------------------------
            n = numel(numbers);
            if words(1) ~= '/', words = ['/' words]; end            
            
            obj.projname = cell(1,n);
            for i = 1:n
                obj.projname{i} = sprintf('%s%s',words,string(numbers(i)));
            end
        end
        
        
        function obj = gatherSubsets(obj, quiet, N)
        % T = GATHERSUBSETS(T, QUIET, N) Collect volumes from
        % recon_dir/projname and crop out subsets according to
        % rotationCW, x0, y0, z0, height, width, and depth.
        % Save the subsets in the subset_dir/samplename/projname.
        %
        % If QUIET is True, there will be no prompt to inspect gathered
        % slices before saving.
        %
        % If N is specified, then only subsets in the range N will be
        % gathered.
        %% ---------------------------------------------------------------
            
            if exist('quiet', 'var') == 0; quiet = false; end
            if exist('N', 'var') == 0; N = 1:numel(obj.projname); end
            
            for i = N
                
                % Creating a working directories
                outdir = [obj.subset_dir obj.samplename obj.projname{i}];
                indir = [obj.recon_dir obj.projname{i}];
                mkdir(outdir); addpath(genpath(indir));
                
                % Log the settings used to create the subset
                logfile = fopen( [outdir '/log.txt'], 'w' );
                fprintf(logfile, '%s\n\n', indir );
                fprintf(logfile, 'CW Rotation: %.1f\n',obj.rotationCW(i) );
                fprintf(logfile, 'x0: %i  y0: %i z0: %i\n', obj.x0(i), obj.y0(i), obj.z0(i) );
                fprintf(logfile, 'width: %i  height: %i depth: %i\n', obj.width, obj.height, obj.depth);

                % Loading rotating cropping and scaling
                stack = makeSubset( indir, obj.rotationCW(i), obj.x0(i), obj.y0(i), obj.z0(i), obj.width, obj.height, obj.depth, quiet);
                if(stack == false)
                    error('Didn''t crop the correct subsection.');
                end
                
                [lh,lw,ldepth] = size(stack);
                fprintf(logfile, 'depth: %i\n', ldepth );
                if ldepth ~= obj.depth, warning('Desired stack depth not reached.'); end
                stack = imadjust(stack(:),[0,1],[0,1],3); % gamma adjustment
                stack = reshape(stack,lh,lw,ldepth);
                
                stack = rescale(stack, obj.bitdepth, logfile);
                
                disp('Saving subset ...');
                imstacksave(stack, outdir, obj.projname{i});
                fclose( logfile );
                clear stack;
            end
        end

        function obj = fitDists(obj, N)
        % T = FITDISTS(T, N) Lead the user through the process of fitting
        % gaussian distributions to the histograms of randomly sampled
        % slices from each subset.
        %
        % For each subset the user will be asked to sort the fitted
        % distributions and then approve or reject the resulting
        % segmentation profile. The resulting profile will always have
        % four phases. Although, assigning a peak to phase 3 is optional.
        %
        % If N is specified, then only subsets in the range N will be
        % gathered.
        %% ---------------------------------------------------------------
            
            % Creating a Log file
            OUTDIR = [obj.segmented_dir obj.samplename]; mkdir(OUTDIR);
            logfile = fopen([OUTDIR '/log.txt'],'a');
            fprintf(logfile,['\n' datestr(datetime('now')) '\n\n']);
            
            if exist('N', 'var') == 0; N = 1:numel(obj.projname); end
            
            if usejava('awt')
            for key = N
                addpath(genpath([obj.subset_dir obj.samplename obj.projname{key}]));
                
                tryagain = true;
                while tryagain
                    fprintf('FINDING DISTRIBUTION FOR SAMPLE %i\n', key);
                    
                    % Sample 2 percent of the data to reduce memory and processing consumption.
                    stack = imstackload([obj.subset_dir obj.samplename obj.projname{key}], '', 0.0025);
                    
                    switch class(stack)
                        case 'uint8'
                            hi = 2^8 - 1;
                        case 'uint16'
                            hi = 2^16 - 1;
                        otherwise
                            hi = max(stack(:));
                    end

                    %Mask out areas not adjacent to adhesive in order to
                    %improve histogram quality.
                    h = figure(1);
                    for slice = 1:size(stack,3)
                        img = stack(:,:,slice);
                        mask = img > 0.88*hi;
                        mask = bwareaopen(mask, 10);
                        R = 33; H = 4; N = 8;
                        %SE = strel('ball', R, H, N);
                        SE = strel('octagon', R);
                        mask = imdilate(mask, SE);
                        stack(:,:,slice) = (img.*cast(mask,'like',img));
                        imshow(stack(:,:,slice));
                        pause(1);
                    end
                    close(h);

                    [llabels, stepfig, gaussfig] = findThresholds(stack, obj.numdists(1), hi, logfile);
                    print(gaussfig, [OUTDIR sprintf('/step%02ig',key)], '-dpng');
                    print(stepfig, [OUTDIR sprintf('/step%02is',key)], '-dpng');

                    obj.thresh16(key) = find(llabels>1,1);
                    obj.labels{key} = llabels;
                   
                    tryagain = ~input('Does this look good? (Yes - 1 / No - 0) ');
                    if tryagain
                        obj.numdists(1) = input('Provide a new numdists: ');
                    end
                    close all;
                end
            end
            end
            save([OUTDIR sprintf('/tomography.mat')], 'obj');
        end


        function obj = segmentSubsets(obj, method, N)
        % SEGMENTSUBSETS(T, METHOD, N) Segment the subsets according to
        % profiles created using FITDISTS.
        %
        % METHOD is either 'color' or 'no_background'.
        % 'color' assigns each of the four phases to an red, green, blue,
        % or black.
        % 'no_background' removes phase 1 and rescale the original
        % greyscale image to cover the entire grey range.
        %
        % If N is specified, then only subsets in the range N will be
        % gathered.
        %% ---------------------------------------------------------------
        
            OUTDIR = [obj.segmented_dir obj.samplename]; mkdir(OUTDIR);
            load([OUTDIR sprintf('/tomography.mat')], 'obj');
            logfile = fopen([OUTDIR '/log.txt'],'a');
                
            if exist('N', 'var') == 0; N = 1:numel(obj.projname); end
            
            if strcmp(method,'no_background')
                for key = N

                % Load each of the stacks to process them separately
                stack = imstackload([obj.subset_dir obj.samplename obj.projname{key}]);
                referenceslice = (stack(:,:,100));

                z = size(stack,3);
                stride = 100;
                if(isa(stack,'uint8'))
                    bwoutput = stack;
                else
                    % Segment the image according to the lookup-table.
                    fprintf('Mapping...\n');
                    bwoutput = zeros(size(stack),'uint8');
                    if key > numel(obj.thresh16)
                        thresh = obj.thresh16(1);
                    else
                        thresh = obj.thresh16(key);
                    end
 
                    parfor chunk_start = 1:z
                        % BW Remove background images
                        bwoutput(:,:,chunk_start) = rescale(stack(:,:,chunk_start), 8, 1, thresh, 2^16);
                    end
                end
                imstacksave(bwoutput,OUTDIR,sprintf('%s_%02i',obj.samplename,key),'raw');
                clear bwoutput;
                end
                
            elseif strcmp(method,'color')
                for key = N
                    
                % Load each of the stacks to process them separately
                stack = imstackload([obj.subset_dir obj.samplename obj.projname{key}]);
                referenceslice = (stack(:,:,100));

                z = size(stack,3);
                stride = 100;
                
                if ~isempty(obj.labels)
                for chunk_start = 1:stride:z
                    chunk = stack(:,:,chunk_start:min([chunk_start+stride-1;z]));
                    % Color Segmentation
                    chunk = obj.labels{key}(uint16(chunk) + 1);
                    chunk = removeislands(chunk, 8, 100);
                    stack(:,:,chunk_start:min([chunk_start+stride-1;z])) = chunk;
                end
                
                fprintf('Coloring...\n');
                coutput = woodcolor('c', uint8(stack), 4, logfile, 1, referenceslice);
                imstacksave(coutput,sprintf('%s/color_%02i',OUTDIR,key),obj.samplename);
                print([OUTDIR '/comparisonc' num2str(key,'%02i')],'-dpng');
                end
                clear stack;
                end
                
            else
               error('Please provide a method for segmentation as input. Choose "color" or "no_background".'); 
            end
            
            fprintf(logfile,'\n');
            fclose(logfile); close all;
        end

        
        function obj = penetrationStats(obj, bondline_file, N)
        % PENETRATIONSTATS(BONDLINE_FILE) Calculate the effective
        % penetration (EP) and weighted penetration (WP) of the bondline
        % from the segmented volume and a csv file containing points
        % marking the bondline. Print the result to the log file.
        %
        % BONDLINE_FILE is the location of the csv file which contains a
        % list of points along the bondline. Each point is its own row. The
        % columns are X, Y, Z coordinates.
        %% ---------------------------------------------------------------

            OUTDIR = [obj.segmented_dir obj.samplename]; mkdir(OUTDIR);
            %load([OUTDIR sprintf('/tomography.mat')], 'obj');
            logfile = fopen([OUTDIR '/log.txt'],'a');
            %if size(gcp) == 0, p = parpool(4); else p = gcp; end
            if exist('N', 'var') == 0; N = 1; end
            key = N; % Only need bondline stats for the first step
            
            color = imstackload(sprintf('%s/color_%02i',OUTDIR,key));

            binary = color(:,:,:,1) | color(:,:,:,3); 
            
            bondline = importdata(bondline_file);
            try
                bondline = bondline.data;
            catch
            end
            [EP, WP] = calc_penetration(binary, bondline);
            fprintf(logfile, ['\nEffective Penetration: %f' ...
                              '\n Weighted Penetration: %f'], EP, WP);
        end
    end
end


function A = removex(A,hi,lo)
% A = REMOVEX(A, HI, LO) Return a copy of A where values outside the range
% (LO, HI) are removed.
%% -----------------------------------------------------------------------
    if(nargin) < 3, lo = -1; end

    A = sort(A);
    right = sum(A < hi);
    left = find(A > lo,1);
    A = A(left:right);
end

