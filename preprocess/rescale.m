function stack = rescale(stack, bitdepth, logfile, lowerthresh, upperthresh)
%RESCALE rescales the pixel values to fit inside BITDEPTH.
%   Values are scaled so the largest value become maxint of BITDEPTH and the
%   smallest value becomes minint of BITDEPTH.
%
% version 1.1.1
% INPUTS
%   stack: an image stack to be converted
%   bitdepth (double): the number of bits to fit the data into.
%   logfile: the identifier of a logfile 1 is the default.
%   lowerthresh:
%   upperthresh:
%
% OUTPUTS
%   stack (bitdepth): the rescaled stack
%
% version 1.1.1 - Properly scale values outside the range
% [lowerthresh,upperthresh] to 0 and MAXINT.
%
%% ----------------------------------------------------------------------------

% Record the old values and convert the old values to double.
stack = double(stack);

if(nargin) < 5, upperthresh = max(stack(:)); end
large = upperthresh;

if(nargin) < 4, lowerthresh = min(stack(:)); end
small = lowerthresh;

fprintf(logfile, '\nOLD MIN: %.1f   OLD MAX: %.1f \n', small, large);

if large ~= double(2^bitdepth - 1) || small ~= 0
    % Rescale the values
    stack = (stack - small)./(large - small);
    
    % Set any values outside the range to zero and MAXINT.
    stack(stack < 0) = 0.0;
    stack(stack > 1) = 1.0;
    
    stack = stack .* double(2^bitdepth - 1);  

    % Log the new min and max values.
    fprintf(logfile, 'NEW MIN: %.1f   NEW MAX: %.1f \n',...
            min(stack(:)), max(stack(:)));
end

% Change the class of stack to match desired bitdepth
switch(bitdepth)
    case 8
        stack = uint8(stack);
    case 16
        stack = uint16(stack);
    case 32
        stack = single(stack);
    otherwise
end
end

