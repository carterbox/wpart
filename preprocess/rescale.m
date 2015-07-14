function stack = rescale(stack, bitdepth, logfile)
%RESCALE rescales the pixel values to fit inside BITDEPTH.
%   Values are scaled so the largest value become maxint of BITDEPTH and the
%   smallest value becomes minint of BITDEPTH.
%
% INPUTS
%   stack: an image stack to be converted
%   bitdepth (double): the number of bits to fit the data into.
%   logfile: the identifier of a logfile 1 is the default.
%
% OUTPUTS
%   stack (double): the rescaled stack
%
%% ----------------------------------------------------------------------------

% Record the old values and convert the old values to double.
stack = im2double(stack);
large = max(stack(:));
small = min(stack(:));
fprintf(logfile, '\nOLD MAX: %.1f   OLD MIN: %.1f \n', large, small);

% Rescale the values
stack = (stack - small)./(large - small) * double(2^bitdepth - 1);

% Log the new min and max values.
fprintf(logfile, 'NEW MAX: %.1f   NEW MIN: %.1f \n',...
        max(stack(:)), min(stack(:)));
end
