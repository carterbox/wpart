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

% Ask the user to label the distributions
h = figure();
peaklabels = ones(numdists,1,'uint8')*2;
newprobs = zeros(length(range),4);
for i = 1:numdists
    figure(h); hold on;
    plot(range,probabilities(:,:),'k'); 
    plot(range,probabilities(:,i),'r');
    hold off;
    acceptable = false;
    while ~acceptable
        peaklabels(i) = input('Label this peak: (1-Void, 2-Wood, 3-Mix, 4-Adhesive) ');
        if(peaklabels(i) > 0 && peaklabels(i) < 5)
            acceptable = true;
        end
    end
    newprobs(:,peaklabels(i)) = max([newprobs(:,peaklabels(i))';probabilities(:,i)'])';
end
close(h);
numdists = numel(unique(peaklabels));
probabilities = newprobs;

% For each of the numbers in the range find the most probable label.
[~,labels] = max(probabilities,[],2);
labels = uint8(labels);

% Fix any non-contiguous label assignments buy reassigning them to their
% next most probable distribution.
[labels,~] = checklabels(labels,probabilities,0,0);

%% Add a fifth phase -----------------------------------------------------
% The final output should always have 4 groups: 1-background, 2-wood, 
% 3-mix, 4-adhesive. mixture is artificially created between the last two 
% groups. background is either the first two groups combined or the first 
% pixel color because it has already been cropped off the histogram.

BUFFER = 0.5; % The distance on either side of the logroup-higroup boundary
              % to insert the fifth phase.

if(numdists < 2 || numdists > 5)
    error('numdists cannot be: %i', numdists);
end
              
% numdists = 2,3: insert 3-mix
if numdists < 4
    higroup = 4;
    logroup = 2;

    warning('numdists is less than 4. An additional phase between last groups +/- %g will be created.',BUFFER);
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
    labels(left+1:right-1) = 3;
    labels(right:end) = 4;
    numdists = numdists + 1;
end

% numdists = 3: Add 1-background
if numdists == 3
    warning('numdists is 2. An additional phase at 0 will be created.');
    labels(1) = 1;
    numdists = numel(unique(labels));
end

% % numdists = 5: merge groups 1 and 2
% if numdists == 5
%     
%     labels = labels - 1;
%     labels = labels + double(labels == 0);
%         
%     numdists = numel(unique(labels));
% end

plot(labels);
assert(numdists == 4);
end

