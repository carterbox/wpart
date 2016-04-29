function [EP, WP] = calc_penetration(volume, points)
%CALC_PENETRATION adhesive penetration characterizer.
% version 0.0.0
%
%INPUTS
% VOLUME (boolean): A boolean volume where true values are the locations of
% adhesive.
% POINTS (Nx3 array): Points in the volume that approximate the bondline.
%
%OUTPUTS
% EP (double) Effective Penetration: A surface density; the average mass
% per unit bondline.
% WP (double) Weighted Penetration: Similar to the second moment of area;
% accounts for both mass and perpendicular distance. Masses farther away
% from the bondline count more.
%
%% TEST CASE

%points = [1,1,1;0,0,1;1,0,1];
%volume = true(3,3,3);

%% ------------------------------------------------------------------------

% Generate a best fit plane from the points and plot it to check.
[normal, ~, point] = affine_fit(points);

h = figure(1); clf(h); hold on; daspect([1 1 1]);
% plot the points
scatter3(points(:,1),points(:,2),points(:,3));
% plot a marker on plane and normal vector
plot3(point(1),point(2),point(3),'ro','markersize',15,...
      'markerfacecolor','red');
quiver3(point(1),point(2),point(3),normal(1)/3,normal(2)/3,normal(3)/3,...
        'r','linewidth',2)
%plot the fitted plane
[X,Y] = meshgrid(linspace(0,1,3));
surf(X,Y, -(normal(1)/normal(3)*X + normal(2)/normal(3)*Y -...
     dot(normal,point)/normal(3)),'facecolor','red','facealpha',0.5);

% For each TRUE value in volume calculate the WP and WP
EP = effective_penetration(volume,normal,point);
WP = weighted_penetration(volume,normal,point);

end

function EP = effective_penetration(volume,normal,point)
% pixels per bondline length [m^3/m^2]

% Calculate the area of the plane. The plane normal contains a z
% component. Otherwise, this calculated area will be infinite.
if(normal(3) == 0), error('The bondline is too straight.' + ...
                          ' Caclulated area is infinite!'); end

%z = @(x,y) (dot(normal,point) - (normal(1)*x + normal(2)*y)) / normal(3);
%area = integral2(z,0,1,0,1);
[xmax,ymax,~] = size(volume);
area = sqrt((-normal(1)/normal(3)).^2 + (-normal(1)/normal(3)).^2 + 1) ...
       * (xmax - 1) * (ymax - 1);

% Literally, take the sum of the number of adhesive voxels (volume)
% and divide by the area of the bondline (area).
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
