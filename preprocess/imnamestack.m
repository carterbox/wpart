function [namestack, count] = imnamestack(directory, depth)
%IMNAMESTACK returns the names of all images in the directory.
%   Does not sort directory before loading image names.
%
% version 2.0.0
% INPUTS
%   directory: the folder where the images are located.
%   depth: the total number of names to be loaded.
%
% OUTPUT
%   namestack (cell): list of filenames.
%
% GLOBAL VARIABLES

kEXTENSION = {'.tif', '.png', '.tiff'}; % The filetype to be loaded.

%% -----------------------------------------------------------------------

if exist(directory,'dir')
    % Get the details of all the files in DIRECTORY.
    fcontents = dir(directory);
    fprintf('Loading filenames from %s ... ', directory);
    % Skip the first two entries (./ and ../) and determine if DIRECTORY is
    % empty.
    start = 1;
    while fcontents(start).isdir == 1
        start = start + 1;
        if start > length(fcontents), error('There are no files there!'); end
    end

    % Preallocate a cell for the names.
    namestack = cell(min(depth,length(fcontents)+1-start),1);

    % Loads all the names into the cell.
    count = 0;
    stop = min((start + depth - 1), length(fcontents));
    for i = start:stop
        % Check that the entry is not a directory.
        if(~fcontents(i).isdir)
            [~,~,ext] = fileparts(fcontents(i).name);
            % Check for the desired filetype.
            if strcmp(ext, kEXTENSION{1}) || strcmp(ext, kEXTENSION{2}) || strcmp(ext, kEXTENSION{3})
                count = count + 1;
                namestack{count} = fcontents(i).name;
            end
        end
    end
    fprintf('LOADED %i NAMES\n', count);

    if(depth ~= inf && count ~= depth)
        warning('Matrix size does not match desired depth.');
        namestack = namestack(1:count);
    end
else
    error('%s does not exist!', directory);
end

% TODO: Sort the files by name incase the OS doesn't return the filenames
% in order.

% list = dir(fullfile(cd, '*.mat'));
% name = {list.name};
% str  = sprintf('%s#', name{:});
% num  = sscanf(str, 'r_%d.mat#');
% [dummy, index] = sort(num);
% name = name(index);