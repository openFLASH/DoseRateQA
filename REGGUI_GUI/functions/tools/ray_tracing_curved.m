%% ray_tracing_curved
% Extract (and interpolate) a *DIVERGENT* bundle of ray vectors out of a 3D image
% The ray bundle is defined by a beam axis (specified by points |pt_in| and |pt_out|). The rays inside the bundles are equaly spaced on a square grid (with distance |cyl_resolution| at the entrance). The bundle has a cylindrical shape with a radius equal to |1.5*cyl_sigma*2|. The increase of the diameter of the bundle as the beam progresses though matter is described by the vector |curve|.
% Each ray is assigned a weight given by an Gaussian with standard deviation |cyl_sigma| and centered on the beam axis.
%
%% Syntax
% |[p,pNN,weights] = ray_tracing_curved(im,im_origin,im_spacing,pt_in,pt_entrance,pt_peak,pt_out,curve,cyl_sigma,cyl_resolution,out_spacing,extrap)|
%
%
%% Description
% |[p,pNN,weights] = ray_tracing_curved(im,im_origin,im_spacing,pt_in,pt_entrance,pt_peak,pt_out,curve,cyl_sigma,cyl_resolution,out_spacing,extrap)| Description
%
%
%% Input arguments
% |im| - _MATRIX of DOUBLE_ - |im(x,y,z)| 3D image from which the ray trace are extracted
%
% |im_origin| - _SCALAR VECTOR_ - [x,y,z] Coordinate of first pixel in |mm|
%
% |im_spacing| - _SCALAR VECTOR_ - [dX,dY,dZ] Pixel size (in |mm|) of the input image
%
% |pt_in| - _SCALAR VECTOR_ - pt_in(x,y,z) Coordinates (in |mm|) of the source point on the beam axis 
%
% |pt_entrance| - _SCALAR VECTOR_ - pt_entrance(x,y,z) Coordinates (in |mm|) of the point where the beam axis enters in matter 
%
% |pt_peak| - _SCALAR VECTOR_ - pt_peak(x,y,z) Coordinates (in |mm|) of the point where the Bragg peak is located on the beam axis
%
% |pt_out| - _SCALAR VECTOR_ - pt_out(x,y,z) Coordinates (in |mm|) of the end point on the beam axis 
%
% |curve| - _SCALAR VECTOR_ -  Relative diameter of the ray bundle at EQUALLY space points between the entrance point |pt_entrance| and the Bragg peak position |pt_peak|. 
%
% |cyl_sigma| - _SCALAR_ - Standard deviation of the Gaussian wieght assigned to each ray of the bundle. It also define the radius (mm) of the ray bundle: radius = 1.5*cyl_sigma*2
%
% |cyl_resolution| - _SCALAR_ - Distance (in mm) between rays on the equally spaced square grid of the ray bundle
%
% |out_spacing| - SCALAR_ - Size of the pixel (|mm|) of the extracted rays
%
% |extrap| - SCALAR_ - Number filling the extrapolated section of the line
%
%
%% Output arguments
%
% |p| - _SCALAR MATRIX_ - p(x,y,:) Vector with intensities along the ray at position (x,y) using linear interpolation
%
% |pNN| - _SCALAR MATRIX_ - pNN(x,y,:) Vector with intensities along the ray at position (x,y) using nearest neighbourgh interpolation
%
% |weights| - _SCALAR MATRIX_ |weights(x,y)| Weight of the ray at position (x,y) of the ray bundle
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


% TODO Use function compute_cylindrical_ray to generate the ray bundle. Avoid duplicating similar code
% TODO compute_orthogonal_points and this function use similar code to compute the start and stop coodinate of the ray bundle. Create a function doing that thawt will then be called by ray_tracing_curved and compute_orthogonal_points

function [p,pNN,weights] = ray_tracing_curved(im,im_origin,im_spacing,pt_in,pt_entrance,pt_peak,pt_out,curve,cyl_sigma,cyl_resolution,out_spacing,extrap)

% compute cylinder size
cyl_radius = 1.5*cyl_sigma*2;

% Compute points in the central ray and adapt input point
dist_full = roundsd(sqrt(sum((pt_out-pt_in).^2)),5);
dist_entrance = roundsd(sqrt(sum((pt_entrance-pt_in).^2)),5);
dist_peak = roundsd(sqrt(sum((pt_peak-pt_in).^2)),5);

n_pts = ceil(dist_full/out_spacing) +1;
% adjust first point to get integer number of samples
pt1 = pt_in - im_origin;
pt2 = pt_out - im_origin;
pt1 = pt1 + (pt2-pt1)/dist_full*out_spacing*(dist_full/out_spacing-ceil(dist_full/out_spacing));
pt_in = pt1 + im_origin;
v_rays = normalize_vcts(pt_out-pt_in);
pts_ray = repmat(pt_in,[1,n_pts]) + repmat([0:n_pts-1]*out_spacing,[3 1]).*repmat(v_rays,[1,n_pts]);

% Compute beam size factor along full path
beam_size_factor = interp1(linspace(dist_entrance,dist_peak,length(curve)),curve,[0:n_pts-1])./curve(1);
beam_size_factor(1:ceil(dist_entrance)) = 1;
beam_size_factor(ceil(dist_peak)+1:end) = curve(end)./curve(1);

% Create 2D plane
d = zeros(ceil(2*cyl_radius/cyl_resolution)+1,ceil(2*cyl_radius/cyl_resolution)+1,'single');
[x,y]=meshgrid([1:size(d,1)]-1/2,[1:size(d,2)]-1/2);
d=sqrt(((x-size(d,1)/2)).^2+((y-size(d,2)/2)).^2);
[x,y] = find(d<=cyl_radius/cyl_resolution);
x=x-size(d,1)/2-1/2;
y=y-size(d,2)/2-1/2;
pts_2D = [x(:)';y(:)'].*cyl_resolution;

% Compute weights corresponding to the sub-rays
weights = exp(-(x(:).^2+y(:).^2)/(2*(2*cyl_sigma/cyl_resolution)^2));
weights = weights/sum(weights);

% Compute orthogonal vectors
v = pt_out-pt_in;
v = v/norm(v);
v_bis = -v([3;1;2]);
if(sum(not(v==-v_bis))==0)
    v_bis(3) = v_bis(3)+1;
end
ortho_x = cross(v_bis,v);
ortho_y = cross(ortho_x,v);
ortho_x = ortho_x/norm(ortho_x);
ortho_y = ortho_y/norm(ortho_y);

% Compute 3D coordinates
pts_cyl = repmat(pts_ray,[1,1,size(pts_2D,2)])...
    + permute(repmat(pts_2D(1,:),[3,1,n_pts]),[1 3 2]).*repmat(ortho_x,[1,n_pts,size(pts_2D,2)]).*repmat(beam_size_factor,[3 1 size(pts_2D,2)])...
    + permute(repmat(pts_2D(2,:),[3,1,n_pts]),[1 3 2]).*repmat(ortho_y,[1,n_pts,size(pts_2D,2)]).*repmat(beam_size_factor,[3 1 size(pts_2D,2)])...
    - repmat(im_origin,[1,n_pts,size(pts_2D,2)]);

% interpolation
p = interp3(im,squeeze(pts_cyl(2,:,:))/im_spacing(2)+1,squeeze(pts_cyl(1,:,:))/im_spacing(1)+1,squeeze(pts_cyl(3,:,:))/im_spacing(3)+1,'linear');
pNN = interp3(im,squeeze(pts_cyl(2,:,:))/im_spacing(2)+1,squeeze(pts_cyl(1,:,:))/im_spacing(1)+1,squeeze(pts_cyl(3,:,:))/im_spacing(3)+1,'nearest');

if(nargin>11)
    if(not(isempty(extrap)))
        p(isnan(p))=extrap;
        pNN(isnan(pNN))=extrap;
    end
end

