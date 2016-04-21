function [EP, WP] = calc_penetration(volume, points)
%PENETRATION adhesive penetration characterizer.

% version 0.0.0

% INPUTS
% VOLUME (boolean)
% POINTS (Nx3 array)

% OUTPUTS
% EP (double) Effective Penetration: A surface density; the average mass
% per unit bondline.

% WP (double) Weighted Penetration: Similar to the second moment of area;
% accounts for both mass and perpendicular distance. Masses farther away 
% from the bondline count more. 

%% TEST

points = diag([1,1,1]);
volume = true(3,3);

%% ------------------------------------------------------------------------

% Generate a best fit plane from the points and plot it to check.
[normal, ~, point] = affine_fit(points);

scatter(points(:,1),points(:,2),points(:,3));

% For each TRUE value in volume calculate the WP and WP
EP = effective_penetration(volume,normal,point);
WP = weighted_penetration(volume,normal,point);

end

function EP = effective_penetration(volume,normal,point)
% pixels per bondline length [m^3/m^2]


area = 0;

% literally, take the sum of the number of adhesive voxels (volume) and divide by
% the area of the bondline (area).
EP = sum(volume(:))/area;

end

function WP = weighted_penetration(volume,normal,point)
% Calculates the weighted penetration of the points in the volume from the
% line defined by a normal and a point.

    WP = 0;
    
    for i = 1:numel(volume)
    if(volume(i))
        [x,y,z] = ind2sub(size(volume),i);
        distance = plane_to_point(normal,point,[x,y,z]);
        WP = WP + distance^2;
    end
    end

    WP = sqrt(WP/sum(volume(:)));
 
end

function d = plane_to_point(normal,A,B)
    w = B-A;
    d = abs(dot(w,normal)/norm(normal));
end