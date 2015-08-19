function makeobj( segmentedvol, filenamedir )
%MAKEOBJ converts a segmented 3D matrix into a wavefront OBJ file of points
% where each group is a separate object.
%
% INPUTS
%   segmentedvol (int): an int 3D matrix to be converted to OBJ where the
%   locations of all indecies with value 1 are the first object and value 2
%   are the second object etc.
%   filenamedir (string): the name of the output location of the obj file.
%       ex. '/somedir/filename.obj'
%
% OUTPUTS
%
%% -----------------------------------------------------------------------
[x0,y0,z0] = size(segmentedvol);

%% Get the Coordinates of each vertex ------------------------------------

% Centering the object.
dx = -(x0 - 1)/2 - 1;
dy = -(y0 - 1)/2 - 1;
dz = -(z0 - 1)/2 - 1;
scale = max([x0;y0;z0]);

OBJ = cell(5,1);
for phase = 3:5
    binaryvol = segmentedvol == phase;
    num_vertices = sum(binaryvol(:));
    if num_vertices > 0
        disp(num_vertices);
        binaryvol = filterinnards(binaryvol, 9);
        disp(sum(binaryvol(:)));
        
        % Get the cartesian coordinates of all pixels in this phase.
        [x,y,z] = ind2sub([x0,y0,z0],find(binaryvol));
        
        OBJ{phase}.vertices_point = cat(2,x+dx,y+dy,z+dz)./scale;
    end
end

%% Write the OBJ to file -------------------------------------------------
fid = fopen(filenamedir,'w');
names = {'air','shadow','wood','interphase','adhesive'};

for phase = 1:length(OBJ)
if ~isempty(OBJ{phase})
    
        V = OBJ{phase}.vertices_point'; disp(size(V,1));
        fprintf('\nSaving object: %s ...', names{phase});
        
        % Generate a string
        tic
        %assert(size(V,1) == 3);
        string0 = sprintf('o %s\n', names{phase});
        string1 = sprintf('v %5.5f %5.5f %5.5f\n', V);
        
        % Save string to file all at once.
        fprintf(fid,'%s',string0);
        fprintf(fid,'%s',string1);
        disp(toc)
        fprintf(' DONE.');
        
end
end
fclose(fid);
end

function vol = filterinnards(vol, thresh)

%% Filter out innards

%h1 = [0,0,0, 0,1,0, 0,0,0, 0,1,0, 1,1,1, 0,1,0, 0,0,0, 0,1,0, 0,0,0];
h = ones(3,3,3);

vol1 = imfilter(double(vol),h);

vol = vol & (vol1 <= thresh);

end
