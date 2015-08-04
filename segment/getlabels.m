function [ labels, probabilities ] = getlabels(range,means,sigma,proportions)
%GETLABELS assigns each of the points in RANGE according the pdfs described
%   by MEANS, SIGMA, and PROPORTIONS.
%
% INPUTS
%
% OUTPUTS
%   labels (uint8): a lookup table from each pixel value to a group.
%   group = labels(pixel_value).
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

% Merge groups 1 & 2
for i = 1:length(labels)
    if labels(i) == 1, labels(i) = 2; end
end

% Fix any non-contiguous label assignments buy reassigning them to their
% next most probable distribution.
[labels,~] = checklabels(labels,probabilities,0,length(labels));

%% Add a fifth phase -----------------------------------------------------

BUFFER = 0.5; % The distance on either side of the 3-4 boundary to insert the fifth phase.

if numdists == 4
    warning('numdists is 4. An additional phase between 3 and 4 +/- %g will be created.',BUFFER);
    % Find where the 4th and 3rd group intersect. We have to check from the
    % right because checklabels still doesn't do it's job.
    right = length(labels);
    while labels(right-1) > 3, right = right - 1; end

    % Make a new pdf.
    pdf5 = (probabilities(:,4) - probabilities(:,3))./(probabilities(:,4) + probabilities(:,3));

    % Determine which grays are in the new region (left,right).
    left = right - 1; hi = length(range);
    while right < hi && pdf5(right) <= BUFFER
        right = right + 1;
    end
    while left > 0 && pdf5(left) >= -BUFFER
        left = left - 1;
    end
    
    % Relabel the region.
    labels(left+1:right-1) = 4;
    labels(right:end) = 5;
end
end

