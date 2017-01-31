function [EP, WP] = calc_penetration(volume, points)
%CALC_PENETRATION adhesive penetration characterizer.
% version 0.0.1
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
% version 0.0.1 - fixed calculations so they operate on XZ planes, and
% fixed graphics so they show at the proper scale.
%% TEST CASE

%points = [1,1,1;0,0,1;1,0,1];
%volume = true(3,3,3);

%% ------------------------------------------------------------------------

% Generate a best fit plane from the points and plot it to check.
[normal, V, point] = affine_fit(points);

h = figure(1); clf(h); hold on; daspect([1 1 1]);
% plot the points
scatter3(points(:,1),points(:,2),points(:,3));
% plot a marker on plane and normal vector
plot3(point(1),point(2),point(3),'ro','markersize',5,...
      'markerfacecolor','red');
quiver3(point(1),point(2),point(3),100*normal(1),100*normal(2),100*normal(3),...
        'r','linewidth',2, 'AutoScale','off');
%plot the fitted plane
xmin = min(points(:,1));
xmax = max(points(:,1));
zmin = min(points(:,3));
zmax = max(points(:,3));

[X,Z] = meshgrid(linspace(xmin,xmax,3),linspace(zmin,zmax,3));

surf(X, -(normal(1)/normal(2)*X + normal(3)/normal(2)*Z -...
     dot(normal,point)/normal(2)), Z,'facecolor','red','facealpha',0.5);
%surf(X,repmat(point(2),size(X)),Z);
title('Best Fit Plane for Bondline'); hold off;

% For each TRUE value in volume calculate the WP and WP
EP = effective_penetration(volume,normal,point);
WP = weighted_penetration(volume,normal,point);

end

function EP = effective_penetration(volume,normal,point)
% pixels per bondline length [m^3/m^2]

% Calculate the area of the plane. The plane normal contains a z
% component. Otherwise, this calculated area will be infinite.
if(normal(2) == 0), error('Bondline should horizontal in slices!' + ...
                          ' Caclulated area is infinite!'); end

                  
fprintf('\nCalculating EP...');
%z = @(x,y) (dot(normal,point) - (normal(1)*x + normal(2)*y)) / normal(3);
%area = integral2(z,0,1,0,1);
[~,xmax,zmax] = size(volume);
% Switch x,y because matlab imageJ coordinate difference
area = sqrt((-normal(1)/normal(2)).^2 + (-normal(3)/normal(2)).^2 + 1) ...
       * (xmax - 1) * (zmax - 1);

% Literally, take the sum of the number of adhesive voxels (volume)
% and divide by the area of the bondline (area).
EP = sum(volume(:))/area; %m^3/m^2
fprintf(' %f', EP);
end

function WP = weighted_penetration(volume,normal,point)
% Calculates the weighted penetration of the points in the volume from the
% line defined by a normal and a point.
fprintf('\nCalculating WP...');

    trus = find(volume);
    [y,x,z] = ind2sub(size(volume),trus);
    % Switch x,y because matlab imageJ coordinate difference
    clear trus;
    
    normal = normal/norm(normal);
    
    distance = (x-point(1))*normal(1) + (y-point(2))*normal(2) + (z-point(3))*normal(3);
    figure(2); boxplot(distance); title('Particle Distance from Bondline');
    drawnow;
    %figure, scatter(x,y);
    WP = sqrt( sum(distance.^2)/ sum(volume(:)) ); %m^2/m^3
    
    fprintf(' %f\n', WP);
end

function d = plane_to_point(normal,A,B)
    w = B-A;
    d = abs(dot(w,normal)/norm(normal));
end
