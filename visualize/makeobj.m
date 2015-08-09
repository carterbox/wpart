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
%% Find the isosurface ---------------------------------------------------
OBJ = cell(5,1);

for phase = 3:5
    OBJ{phase} = isosurface(segmentedvol, phase, 'verbose');
end

%% Scaling and centering the vertices ------------------------------------

[x0,y0,z0] = size(segmentedvol);

% Centering the object.
dx = -(x0 - 1)/2 - 1;
dy = -(y0 - 1)/2 - 1;
dz = -(z0 - 1)/2 - 1;
scale = max([x0;y0;z0]);

for phase = 3:5
if ~isempty(OBJ{phase}) && ~isempty(OBJ{phase}.vertices)
    tempvertexarray = OBJ{phase}.vertices;
    
    tempvertexarray(:,1) =  tempvertexarray(:,1) + dx;
    tempvertexarray(:,2) =  tempvertexarray(:,2) + dy;
    tempvertexarray(:,3) =  tempvertexarray(:,3) + dz;
    
    tempvertexarray = tempvertexarray./scale;
    
    OBJ{phase}.vertices = tempvertexarray;
end
end

%% Write the OBJ to file -------------------------------------------------
fid = fopen(filenamedir,'w');
names = {'air','shadow','wood','interphase','adhesive'};

for phase = 1:length(OBJ)
if ~isempty(OBJ{phase}) && ~isempty(OBJ{phase}.vertices)
        fprintf('\nSaving object: %s ...', names{phase}); %tic
        fprintf(fid,'o %s\n', names{phase});
        
        % Generate a string
        verts = OBJ{phase}.vertices'; %disp(size(verts,1));
        %assert(size(verts,1) == 3);
        string1 = sprintf('v %5.5f %5.5f %5.5f\n', verts);
        % Save string to file all at once.
        fprintf(fid,'%s',string1);
        clear string1 verts
        
        % Generate a string
        faces = OBJ{phase}.faces'; %disp(size(faces,1));
        %assert(size(faces,1) == 3);
        string2 = sprintf('f %i %i %i\n', faces);
        % Save string to file all at once.
        fprintf(fid,'%s',string2);
        clear string2 faces
        
        %disp(toc)
        fprintf(' DONE.\n');
        fprintf(fid,'\r\n');
end
end
fclose(fid);
end

