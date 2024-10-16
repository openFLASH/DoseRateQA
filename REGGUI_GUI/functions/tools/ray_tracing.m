%% ray_tracing
% Extract (and interpolate) a ray vector out of a 3D image
%
%% Syntax
% |[p,pt_in] = ray_tracing(im,im_origin,im_spacing,pt_in,pt_target,out_spacing,interp,extrap)|
%
% |[p,pt_in] = ray_tracing(im,im_origin,im_spacing,pt_in,pt_target,out_spacing,interp)|
%
%% Description
% |[p,pt_in] = ray_tracing(im,im_origin,im_spacing,pt_in,pt_target,out_spacing,interp,extrap)| returns a vector of the intensities along the ray-line traced inside the 3D volume.
%
%% Input arguments
% |im| - _MATRIX of DOUBLE_ - |im(x,y,z)| 3D image from which the ray trace are extracted
%
% |im_origin| - _VECTOR of DOUBLE_ - [x,y,z] Coordinate |mm| of first pixel in the 3D volume
%
% |im_spacing| - _VECTOR of DOUBLE_ - [dX,dY,dZ] Pixel size (in |mm|) of the input image
%
% |pt_in| - _MATRIX of DOUBLE_ - pt_in(:,i)=[x,y,z] Coordinates (in |mm|) of the source point  on ray i
%
% |pt_target| - _MATRIX of DOUBLE_ - pt_target(:,i)=[x,y,z] Coordinates (in |mm|) of the target point of the ray i. The ray profile is computed between pt_in and pt_target
%
% |out_spacing| - SCALAR_ - Size of the pixel (|mm|) of the extracted rays
%
% |interp| - STRING_ - Type of interpolation (same as function 'interp3'). Default = 'linear'
%
% |extrap| - SCALAR_ - Number filling the extrapolated section of the line
%
%% Output arguments
% |p| - _MATRIX of DOUBLE_ - p(:,i) Vector with intensities along the ray i
%
% |pt_in| - _MATRIX of DOUBLE_ - (:,i) Adapted coordinate of the first point so as to obtain an integral number of sample between PtIn and PTTarget
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [p,pt_in] = ray_tracing(im,im_origin,im_spacing,pt_in,pt_target,out_spacing,interp,extrap)

if(not(size(pt_in,1)==3 && size(pt_target,1)==3))
    disp('Input points must be 3D (i.e. 3 rows)')
    disp(pt_in)
    disp(pt_target)
    return
end

if(nargin<7)
    interp = 'linear';
end

pt1 = pt_in - repmat(im_origin,[1 size(pt_in,2)]);
pt2 = pt_target - repmat(im_origin,[1 size(pt_target,2)]);
v_norm = roundsd(sqrt(sum((pt2-pt1).^2,1)),5);
v_norm_max = max(v_norm);
v_rays = normalize_vcts(pt2-pt1);
if(sum(v_norm-v_norm_max))
    disp('Warning: Ray-tracing distances are not identical. Adjusting initial point according to the maximal distance...')
    pt1 = pt2 - v_norm_max*v_rays;
end
n_pts = ceil(v_norm_max/out_spacing) +1;

% adjust first point to get integer number of samples + update input point
pt1 = pt1 + (pt2-pt1)/v_norm_max*out_spacing*(v_norm_max/out_spacing-ceil(v_norm_max/out_spacing));
pt_in = pt1 + repmat(im_origin,[1 size(pt_in,2)]);

% compute profile between pt_in and pt_target
size_limit = 5e6;
if((size(pt1,2)*n_pts)<size_limit)
    x = linspaceNDim(pt1(1,:),pt2(1,:),n_pts)/im_spacing(1); % in voxel-space
    y = linspaceNDim(pt1(2,:),pt2(2,:),n_pts)/im_spacing(2); % in voxel-space
    z = linspaceNDim(pt1(3,:),pt2(3,:),n_pts)/im_spacing(3); % in voxel-space
    p = interp3(im,y+1,x+1,z+1,interp);
else
    p = zeros(size(pt1,2),n_pts);
    sub_computations = min(ceil(size(p,1)*size(p,2)/size_limit),size(p,1));
    sub_size = floor(size(p,1)/sub_computations);
    for i=1:sub_computations
        x = linspaceNDim(pt1(1,(i-1)*sub_size+1:i*sub_size),pt2(1,(i-1)*sub_size+1:i*sub_size),n_pts)/im_spacing(1); % in voxel-space
        y = linspaceNDim(pt1(2,(i-1)*sub_size+1:i*sub_size),pt2(2,(i-1)*sub_size+1:i*sub_size),n_pts)/im_spacing(2); % in voxel-space
        z = linspaceNDim(pt1(3,(i-1)*sub_size+1:i*sub_size),pt2(3,(i-1)*sub_size+1:i*sub_size),n_pts)/im_spacing(3); % in voxel-space
        p((i-1)*sub_size+1:i*sub_size,:) = interp3(im,y+1,x+1,z+1,interp);
    end
    x = linspaceNDim(pt1(1,(i-1)*sub_size+1:end),pt2(1,(i-1)*sub_size+1:end),n_pts)/im_spacing(1); % in voxel-space
    y = linspaceNDim(pt1(2,(i-1)*sub_size+1:end),pt2(2,(i-1)*sub_size+1:end),n_pts)/im_spacing(2); % in voxel-space
    z = linspaceNDim(pt1(3,(i-1)*sub_size+1:end),pt2(3,(i-1)*sub_size+1:end),n_pts)/im_spacing(3); % in voxel-space
    p((i-1)*sub_size+1:end,:) = interp3(im,y+1,x+1,z+1,interp);
end

if(nargin>7)
    if(not(isempty(extrap)))
        p(isnan(p))=extrap;
    end
end
