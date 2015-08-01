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

% Centering the object.
dx = -(x0 - 1)/2 - 1;
dy = -(y0 - 1)/2 - 1;
dz = -(z0 - 1)/2 - 1;
scale = max([x0;y0;z0]);

OBJ = cell(5,1);
for i = 3:5
    binaryvol = segmentedvol == i;
    num_vertices = sum(binaryvol(:));
    if num_vertices > 0
        % Get the cartesian coordinates of all 'true' in binaryvol.
        [x,y,z] = ind2sub([x0,y0,z0],find(binaryvol));
        
        OBJ{i}.vertices_point = cat(2,x+dx,y+dy,z+dz)./scale;
    end
end
% Write the OBJ to file.
fid = fopen(filenamedir,'W');

names = {'air','shadow','wood','interphase','adhesive'};
for k = 3:length(OBJ)
    if ~isempty(OBJ{k})
        fprintf('\nSaving object: %s ...', names{k});
        fprintf(fid,'o %s\n', names{k});
        V = OBJ{k}.vertices_point;
        disp(size(V,1));
        tic
        for i = 1:min(1000000,size(V,1))
            fprintf(fid,'%s %5.5f %5.5f %5.5f\n', 'v', V(i,1), V(i,2), V(i,3));
        end
        disp(toc)
        fprintf(' DONE.');
    end
end
fclose(fid);
end

