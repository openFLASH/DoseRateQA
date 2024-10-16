%% compute_cylindrical_ray
% Compute the coordinates of 2 points (|pts_in| and |pts_out|) belonging to each one of the rays composing a bundle of *paralell* rays.
% The ray bundle is defined by a beam axis (specified by points |pt_in| and |pt_out|). The rays inside the bundles are equaly spaced on a square grid (with distance |cyl_resolution|). The bundle has a cylindrical shape with a radius equal to |cyl_radius|. All the rays of the bundle start from the same plan (containing |pt_in|) and end in the same plane (containing |pt_out|).
% Each ray is assigned a weight which is either uniform or given by an Gaussian with standard deviation |cyl_radius/cyl_resolution/2| and centered on the beam axis.
%
%% Syntax
% |[pts_in,pts_out,weights] = compute_cylindrical_ray(pt_in,pt_out,cyl_radius,cyl_resolution,weight_type)|
%
%
%% Description
% |[pts_in,pts_out,weights] = compute_cylindrical_ray(pt_in,pt_out,cyl_radius,cyl_resolution,weight_type)| Compute the coordiantes of the rays in the bundle
%
%
%% Input arguments
% |pt_in| - _SCALAR VECTOR_ - pt_in(x,y,z) Coordinates (in |mm|) of the source point on the beam axis 
%
% |pt_out| - _SCALAR VECTOR_ - pt_out(x,y,z) Coordinates (in |mm|) of the end point on the beam axis
%
% |cyl_radius| - _SCALAR_ -  Radius (mm) of the cylindrical bundle of rays 
%
% |resolution| - _SCALAR_ - Distance (in mm) between rays on the equally spaced square grid of the ray bundle
%
% |weight_type| - _STRING_ - Type of weighting of the rays in the bundle. 'gaussian' = Gaussian with standard deviation |cyl_radius/cyl_resolution/2| and centered on the beam axis. Otherwise, it is a uniform weight.
%
%
%% Output arguments
%
% |pts_in|- _MATRIX of DOUBLE_ - |pts_in(:,i)=[x,y,z]| Coordinates (in |mm|) of the source point of the i-th ray in the bundle
%
% |pts_out|- _MATRIX of DOUBLE_ - |pts_out(:,i)=[x,y,z]| Coordinates (in |mm|) of the end point of the i-th ray in the bundle
%
% |weights| - _SCALAR MATRIX_ |weights(x,y)| Weight of the ray at position (x,y) of the ray bundle
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [pts_in,pts_out,weights] = compute_cylindrical_ray(pt_in,pt_out,cyl_radius,cyl_resolution,weight_type)

d = zeros(ceil(2*cyl_radius/cyl_resolution)+1,ceil(2*cyl_radius/cyl_resolution)+1,'single');
[x,y]=meshgrid([1:size(d,1)]-1/2,[1:size(d,2)]-1/2);
d=sqrt(((x-size(d,1)/2)).^2+((y-size(d,2)/2)).^2);
[x,y] = find(d<=cyl_radius/cyl_resolution);
x=x-size(d,1)/2-1/2;
y=y-size(d,2)/2-1/2;
pts_2D = [x(:)';y(:)'].*cyl_resolution;

[pts_in,pts_out] = compute_orthogonal_points(pt_in,pt_out,pts_2D);

if(nargin<5)
    weights = ones(size(pts_in,2))/size(pts_in,2);
else
    switch weight_type
        case 'gaussian'
            weights = exp(-(x(:).^2+y(:).^2)/(2*(cyl_radius/cyl_resolution/2)^2));
            weights = weights/sum(weights);
        otherwise
            weights = ones(size(pts_in,2))/size(pts_in,2);
    end
end
