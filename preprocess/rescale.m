function [ stack ] = rescale( in, bitdepth, logfile )
%RESCALE rescales the pixel values for more information in 16 bits
%   Detailed explanation goes here

large = max(max(max(in)));
small = min(min(min(in)));
fprintf(logfile, '\nOLD MAX: %.1f   OLD MIN: %.1f \n', large, small);

stack = im2double(in);
large = max(max(max(stack)));
small = min(min(min(stack)));

assert(length(small) == 1);
assert(length(large) == 1);

stack = (stack - small)./(large - small) * double(2^bitdepth - 1);

fprintf(logfile, 'NEW MAX: %.1f   NEW MIN: %.1f \n', max(max(max(stack))), min(min(min(stack))));
end

