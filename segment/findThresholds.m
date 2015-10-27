function [labels, stepfig, gaussfig] = findThresholds( sample, numdists, bitdepth, logfile )
%FINDTHRESHOLDS uses expectation maximization to cluster pixel
% intensitities into groups.
% 
% INPUTS
%   sample: a nonempty stack of grayscale images
%   numdists: the expected number of fittable distributions in the
%   histogram of the stack
%   bitdepth (double): the bitdepth of the images in the stack
%
% OUTPUTS
%   labels (uint8): a lookup table from each pixel value a group. There
%   should probably be less than 256 groups.
%   group = labels(pixel_value). If NUMDISTS = 4 -> 5, NUMDISTS = 2 -> 3
%
% NOTES
% http://en.wikipedia.org/wiki/Expectation%E2%80%93maximization_algorithm
% http://www.mathworks.com/help/stats/fitgmdist.html
%
%% -----------------------------------------------------------------------
% GLOBAL VARIABLES
MAXITER = 800; % Maxium iterations for EM fitting of gaussians
TERMCRIT = 1e-7;
REPS = 3; % Number of times to attempt EM fitting of guassians
MAXINT = 2^bitdepth - 1;
UPPERTHRESH = MAXINT*0.99;
LOWERTHRESH = 0;
sample = double(sample(:));

COLORORDER = false;
switch numdists
    case 2
        COLORORDER = [0 0 0;0.2 0.2 0.2;0 1 0;0 0 1];
    case 3
        COLORORDER = [0 0 0;0.2 0.2 0.2;0 0 0;0 1 0;0 0 1];
    case 4
        COLORORDER = [0 0 0;0.2 0.2 0.2;0 0 0;0 0 0;0 1 0;0 0 1];
    case 5
        COLORORDER = [0 0 0;0.2 0.2 0.2;0 0 0;0 0 0;0 1 0;1 0 0;0 0 1];
end

% Peaks at the edges of the space hinder fitgmdist in doing its job, so 
% we remove them. 
sample = removex(sample, UPPERTHRESH, LOWERTHRESH);
fprintf( logfile, 'REMOVED DATA ABOVE %.1f \n', UPPERTHRESH);
fprintf( logfile, 'NUMBER OF POINTS IS %i \n', length(sample));
if(length(sample) < 10000)
    error('Data sample has no length. Maybe the threshold is too high.');
end

%% Fit Guassians to the data ---------------------------------------------

fprintf( logfile,'\nGaussian mixture for %i peaks:\n',numdists);
options = statset('Display','final','MaxIter',MAXITER,'TolFun',TERMCRIT);
gaussianmix = fitgmdist(sample, numdists,'Start','plus',...
                        'Replicates',REPS,'Options', options);

%% Record and display the results ----------------------------------------

a = squeeze(gaussianmix.mu); %disp(a);
s = squeeze(gaussianmix.Sigma); %disp(s);
c = squeeze(gaussianmix.ComponentProportion)'; %disp(c);

% Making a table in the log file.
fprintf(logfile,'%6s %12s %15s\n','mean','sigma','amplitude');
for i = 1:numdists
    fprintf(logfile,'%6.2f %12.2f %15.5f\n',a(i),s(i),c(i));
end

% Assign each gray to a group.
range = 0:MAXINT;
[labels, separatedpdfs] = getlabels(range',a,s,c);

% Save labels to logfile
if MAXINT < 256
fprintf(logfile, '\r\n greys group assignments: \r\n');
fprintf(logfile, '%i %i %i %i %i %i %i %i | %i %i %i %i %i %i %i %i \r\n', labels);
end

stepfig = figure(1); plot(labels);

% Set a new color order that matches our segmentation scheme.
set(groot,'defaultAxesColorOrder',COLORORDER);
gaussfig = figure(2);
% Plot the histogram in the background.
histogram(sample, MAXINT,'Normalization','pdf',...
          'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5]);
hold on;
% Put the gaussian mixture in black on top of that.
plot(range, pdf(gaussianmix, range'),'LineWidth', 2.0);
% Plot each gaussian separately as well.
plot(range, separatedpdfs, 'LineWidth', 2.0);
axis([0 MAXINT 0 inf]);
hold off;

set(groot,'defaultAxesColorOrder','remove')
end

%% Auxillary Functions ---------------------------------------------------

function A = removex(A,hi,lo)
%REMOVEX removes values in A that are outside the range (lo,hi).
if(nargin) < 3, lo = -1; end

A = sort(A);
right = sum(A < hi);
left = find(A > lo,1);
A = A(left:right);
end
