function [ labels, probabilities ] = getlabels(range,means,sigma,proportions)
%GETLABELS assigns each of the points in RANGE according the pdfs described
%   by MEANS, SIGMA, and PROPORTIONS.
%
% INPUTS
%
% OUTPUTS
%   labels (uint8): a lookup table from each pixel value to a group. Always
%   contains 4 groups. group = labels(pixel_value).
%   probabilities: RxN table where R is the length of RANGE and N is the
%   number of pdfs. Each column is the the values of one of the pdfs.
%
%% -----------------------------------------------------------------------
if isrow(means), disp('means is row!'); end
if isrow(sigma), disp('sigma is row!'); end
numdists = length(means);

% Make a table of the probabilities that each point belongs to a give mode.
probabilities(length(range),numdists) = double(0);
for i = 1:numdists
    thispdf = pdf('Normal',range, means(i), sqrt(sigma(i)));
    %thispdf = pdf(gmdistribution(means(i),sigma(i)),range);
    probabilities(:,i) = proportions(i).*thispdf;
end

% For each of the numbers in the range find the most probable label.
[~,labels] = max(probabilities,[],2);
labels = uint8(labels);

% TODO: Figure out a way to better sort the distributions.  
% Finds the center of each group in the vector LABEL.
centroids(numdists,2) = double(0);
centroids(:,2) = (1:numdists)';
for j = 1:numdists
    points = find(labels == j);
    centroids(j,1) = mean(points);
end

% Sort the distributions by the centroid of their most probable region.
probabilities = sortrows([centroids(:,1),probabilities'], 1);
probabilities = probabilities(:,2:end)';

centroids = sortrows(centroids,1);
centroids(:,1) = (1:numdists)';
centroids = sortrows(centroids,2);
sorter = centroids(:,1);
labels = sorter(labels);

% Fix any non-contiguous label assignments buy reassigning them to their
% next most probable distribution.
[labels,~] = checklabels(labels,probabilities,0,length(labels));

%% Add a fifth phase -----------------------------------------------------
% The final output should always have 4 groups: 1-background, 2-wood, 
% 3-mix, 4-adhesive. mixture is artificially created between the last two 
% groups. background is either the first two groups combined or the first 
% pixel color because it has already been cropped off the histogram.

BUFFER = 0.5; % The distance on either side of the logroup-higroup boundary
              % to insert the fifth phase.

if(numdists < 2 && numdists > 5), error('numdists cannot be: %i', numdists);
              
% numdists = 2: Add 1-background
if numdists == 2
    warning('numdists is 2. An additional phase at 0 will be created.');
    labels = labels+1;
    labels(1) = 1;
    numdists = 3;
end

% numdists = 3,4: insert 3-mix
if numdists < 5
    higroup = numdists;
    logroup = higroup -1;

    warning('numdists is 3 or 4. An additional phase between last groups +/- %g will be created.',BUFFER);
    % Find where the 4th and 3rd group intersect. We have to check from the
    % right because checklabels still doesn't do it's job.
    right = length(labels);
    while labels(right-1) > logroup, right = right - 1; end

    % Make a new pdf.
    pdf5 = (probabilities(:,higroup) - probabilities(:,logroup))./(probabilities(:,higroup) + probabilities(:,logroup));

    % Determine which grays are in the new region (left,right).
    left = right - 1; hi = length(range);
    while right < hi && pdf5(right) <= BUFFER
        right = right + 1;
    end
    while left > 0 && pdf5(left) >= -BUFFER
        left = left - 1;
    end

    % Relabel the region.
    labels(left+1:right-1) = higroup;
    labels(right:end) = higroup+1;
    numdists = numdists + 1;
end

% numdists = 5: merge groups 1 and 2
if numdists == 5
    
    labels = labels - 1;
    labels = labels + uint8(labels == 0);
        
    numdists = numdists-1;
end
        
assert(numdists == 4);
end

