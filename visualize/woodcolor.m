function [ output ] = woodcolor( CorBW, segmented, numSegments, varargin )
% woodcolor( CorBW, segmented, numSegments )
% woodcolor( CorBW, segmented, numSegments, logfile, showresult, image )
%WOODCOLOR takes images segmented into parts 1...NUMSEGMENTS and remaps the
%   numbers to colors or grescale values from 1...255.
%
% INPUTS
%   CorBW (string): 'c' segments according to colormap
%                   'b' segments according to greymap
%                   '' or anything else removes the backround but leaves original grey
%                   colors.
% OUTPUTS
%   output (cell or array): stack of grey or color 8 bit images.
% ------------------------------------------------------------------------
if isempty(varargin)
    logfile = 1;
    showresult = 0;
    image = 0;
else
    logfile = varargin{1};
    showresult = varargin{2};
    image = varargin{3};
end

[~,~,z] = size(segmented);
cmap = ones( 6,1 );
output = cell(z,1);

    if strcmp(CorBW, 'c')
        disp('You chose color');
        if numSegments == 5
            cmap = [
                0,0,0
                0,0,0
                0,1,0
                1,0,0
                0,0,1];
        else
            cmap = [
                0,0,0
                0,0,0
                0,1,0
                0,0,1];
        end
        fprintf(logfile, '\n#Colormap\n');
        for i = 1:numSegments
            fprintf(logfile, '%i %i %i\n', cmap(i,:));
        end
        fprintf(logfile, '\n');
        
        parfor i = 1:z
           output{i} = label2rgb(segmented(:,:,i),cmap);
        end
    elseif strcmp(CorBW, 'b')
        disp('You chose black and white');
        cmap = floor([0:numSegments-1]*255/(numSegments-1));
        cmap(1:2) = 0;
        cmap = uint8(cmap);
        
        fprintf(logfile, '\n#Colormap\n');
        fprintf(logfile, '%i \n', cmap);
        fprintf(logfile, '\n');
        
        parfor i = 1:z
            output{i} = cmap(segmented(:,:,i));
        end
    else %strcmp(CorBW, 'r')
        disp('You chose remove background');
        mask = segmented > 2;
        
        parfor i = 1:z
            output{i} = image(:,:,i).*uint8(mask(:,:,i));
        end
    end
        
if showresult
    fig = output{1};
    figure('Name','Comparison of original and segmented image.'), subplot(1,2,1),imshow(fig);
    subplot(1,2,2), imshow(uint8(image(:,:,1)));
end

end

