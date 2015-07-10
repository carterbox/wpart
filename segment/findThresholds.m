function labels = findThresholds( stack, numdists, bitdepth, logfile )
%FINDTHRESHOLDS uses expectation maximization to cluster pixel
% intensitities into groups.
% 
% INPUTS
%   stack (double): a nonempty stack of grayscale images
%   numdists: the expected number of fittable distributions in the
%   histogram of the stack
%   bitdepth: the bitdepth of the images in the stack
%
% OUTPUTS
%   labels (uint8): a lookup table from each pixel value a group.
%   group = labels(pixel_value). If NUMDISTS = 4, then an additional group
%   will be added to boost that number to 5.
%
% NOTES
% http://en.wikipedia.org/wiki/Expectation%E2%80%93maximization_algorithm
% http://www.mathworks.com/help/stats/fitgmdist.html
%
%% -----------------------------------------------------------------------
% GLOBAL VARIABLES
MAXITER = 500; % Maxium iterations for EM fitting of gaussians
TERMCRIT = 1e-6;
REPS = 1; % Number of times to attempt EM fitting of guassians
MAXINT = 2^bitdepth - 1;
UPPERTHRESH = MAXINT;%*0.99;
[~,~,z] = size(stack);

fprintf('Sampling dataset... \n');
% Create a histogram from a 2 percent random sample of the data to reduce
% memory and processing consumption.
numsamples = ceil(0.02*z);
sample = stack(:,:,random('unid', z, [1,numsamples]));
sample = double(sample(:));
fprintf( logfile, '\nNUM SAMPLED SLICES IS %i \n', numsamples);

% Sometimes, due to over exposure, there is a peak at the right edge of the
% histogram. It hinders fitgmdist in doing its job, so we remove it. 
sample = removex(sample, UPPERTHRESH);
fprintf( logfile, 'REMOVED DATA ABOVE %.1f \n', UPPERTHRESH);
fprintf( logfile, 'LENGTH IS %i \n', length(sample));
if(length(sample) < 10000)
    error('Data sample has no length. Maybe the threshold is too high.');
end

%% Fit Guassians to the data ---------------------------------------------
fprintf( logfile, '\nFinding Gaussian mix for %i peaks...\n',numdists);
%%seed = gmdistribution([20;80;118;250],[sigma(:,:,I); sigma(:,:,I);sigma(:,:,I)]);
options = statset('Display','final','MaxIter',MAXITER,'TolFun',TERMCRIT);
gaussianmix = fitgmdist(sample, numdists,'Start','plus',...
                        'Replicates',REPS,'Options', options);

%% Record and display the results ----------------------------------------

a = squeeze(gaussianmix.mu); %disp(a);
s = squeeze(gaussianmix.Sigma); %disp(s);
c = squeeze(gaussianmix.ComponentProportion); %disp(c);

% Making a table in the log file.
fprintf(logfile,'%6s %12s %18s\n','mean','sigma','amplitude');
for i = 1:numdists
    fprintf(logfile,'%6.2f %12.2f %15.5f\n',a(i),s(i),c(i));
end

range = 0:MAXINT;

% Assign each gray to a group.
[labels, separatedpdfs] = getlabels(range',a,s,c);
figure, %subplot(2,1,2),
% plot(range',labels'); % Plot the ranges.
% axis([0 255 1 5]);
% daspect([5 1 1]);

%subplot(2,1,1),
% Plot the histogram in the background.
histogram(sample, MAXINT,'Normalization','pdf',...
                  'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5]);
hold on;
% Put the gaussian mixture in black on top of that.
plot(range, pdf(gaussianmix, range'), 'Color','k','LineWidth', 2.0);
% Plot each gaussian separately as well.
plot(range, separatedpdfs, 'LineWidth', 2.0);
axis([0 255 0 inf]);
hold off;

end

%% Auxillary Functions ---------------------------------------------------

function A = removex(A,x)
%REMOVEX removes values in A that are greater than or equal to x.
A = sort(A);
isit = A >= x;
n = find(isit, 1, 'first');
A = A(1:n-1);
end

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

% TODO: Figure out a way to better sort the distributions.
% Sort the distributions by their right edge.
sortme = sortrows([means,sigma,means+2.*sigma],3);
means = sortme(:,1); sigma = sortme(:,2);
clear sortme;

% Make a table of the probabilities that each point belongs to a give mode.
probabilities(length(range),numdists) = double(0);
for i = 1:numdists
    thispdf = normpdf(range, means(i), sqrt(sigma(i)));
    %thispdf = pdf(gmdistribution(means(i),sigma(i)),range);
    probabilities(:,i) = proportions(i).*thispdf;
end

% For each of the numbers in the range find the most probable label.
[~,labels] = max(probabilities,[],2);
labels = uint8(labels);

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


