%% eval_image_at_points
% Evaluate the image intensity at non-integer pixel index coordinate
%
%% Syntax
% |val_res = eval_image_at_points(pts,im)|
%
%
%% Description
% |val_res = eval_image_at_points(pts,im)| Interpolate the image intensity at the specified pixel coordinates
%
%
%% Input arguments
% |pts| - _SCALAR MATRIX_ - |pts(:,i)=[x,y,z]| Coordinate (in pixel) of the points at which the image intensity is interpolated. Non integer pixel coordinates are allowed
%
% |im| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
%
%
%% Output arguments
%
% |val_res| - _SCALAR VECTOR_ - |val_res(i)| is the interpolated image intensity at coordinate |pts(:,i)|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function val_res = eval_image_at_points(pts,im)

val_res = zeros(1,size(pts,2));

if(size(pts,1)==3)
    
    for i=1:size(pts,2)

            val_res(i) = interp3(im,pts(2,i),pts(1,i),pts(3,i));

    end
    
else
    disp('Error: wrong dimension')
end
