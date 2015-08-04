function labels = findThresholds( sample, numdists, bitdepth, logfile )
%FINDTHRESHOLDS uses expectation maximization to cluster pixel
% intensitities into groups.
% 
% INPUTS
%   sample (double): a nonempty stack of grayscale images
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
TERMCRIT = 1e-7;
REPS = 3; % Number of times to attempt EM fitting of guassians
MAXINT = 2^bitdepth - 1;
UPPERTHRESH = MAXINT;%*0.99;
sample = double(sample(:));

COLORORDER = false;
switch numdists
    case 3
        COLORORDER = [0 0 0;0.2 0.2 0.2;0 0 0;0 1 0;0 0 1];
    case 4
        COLORORDER = [0 0 0;0.2 0.2 0.2;0 0 0;0 0 0;0 1 0;0 0 1];
    case 5
        COLORORDER = [0 0 0;0.2 0.2 0.2;0 0 0;0 0 0;0 1 0;1 0 0;0 0 1];
end

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
c = squeeze(gaussianmix.ComponentProportion)'; %disp(c);

% Making a table in the log file.
fprintf(logfile,'%6s %12s %18s\n','mean','sigma','amplitude');
for i = 1:numdists
    fprintf(logfile,'%6.2f %12.2f %15.5f\n',a(i),s(i),c(i));
end

range = 0:MAXINT;

% Assign each gray to a group.
[labels, separatedpdfs] = getlabels(range',a,s,c);

% Set a new color order that matches our segmentation scheme.
set(groot,'defaultAxesColorOrder',COLORORDER);
figure, %subplot(2,1,2),
% plot(range',labels'); % Plot the ranges.
% axis([0 MAXINT 1 5]);
% daspect([5 1 1]);

%subplot(2,1,1),
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

function A = removex(A,x)
%REMOVEX removes values in A that are greater than or equal to x.
A = sort(A);
numlower = sum(A < x);
A = A(1:numlower);
end
