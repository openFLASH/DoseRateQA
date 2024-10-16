%% rigid_trans_to_def_field
% Compute the deformation field resulting from the application of the rigid transform |trans| (translation + rotation) onto the transformation field |warping_field|
%
%% Syntax
% |field = rigid_trans_to_def_field(trans,outsize,spacing,origin)|
%
% |field = rigid_trans_to_def_field(trans = _SCALAR VECTOR_,outsize,spacing,origin,warping_field)|
%
% |field = rigid_trans_to_def_field(trans = _SCALAR MATRIX_,outsize,spacing,origin,warping_field)|
%
%
%% Description
% |field = rigid_trans_to_def_field(trans,outsize,spacing,origin)| Create a deformation field equal to the rigid transformation
%
% |field = rigid_trans_to_def_field(trans = _SCALAR VECTOR_,outsize,spacing,origin,warping_field)| Combine the rigid transformation (translation only) with the deformation field
%
% |field = rigid_trans_to_def_field(trans = _SCALAR MATRIX_,outsize,spacing,origin,warping_field)| Combine the rigid transformation (translation and rotation) with the deformation field
%
%
%% Input arguments
% |trans| - _SCALAR VECTOR or SCALAR MATRIX_ -  Depending on the function call syntax, |rigid_transform| can be:
%
% * Syntax 1 -  _SCALAR VECTOR_
% * ---- |rigid_transform(1,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in pixels) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * Syntax 2 - _SCALAR MATRIX_
% * ---- |rigid_transform(1,:)| : Ignored
% * -----|rigid_transform(2,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * -----|rigid_transform(3-5,:)| - _SCALAR VECTOR_ Rotation matrix 3x3 matrix 
%
% |outsize| - _TYPE_ -  description
%
% |spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the image
%
% |origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
% |warping_field| _CELL VECTOR of MATRICES_ |warping_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
%
%% Output arguments
%
% |field| _CELL VECTOR of MATRICES_ |field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}.
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function field = rigid_trans_to_def_field(trans,outsize,spacing,origin,warping_field)

if(nargin>4)
   if(not(iscell(warping_field)))
       warping_field = field_convert(warping_field);
   end
end

if(sum(sum(trans(3:end,:)~=0)) && nargin>3)
    
    r = trans(3:5,:);
    x = trans(2,:);

    [Y X Z] = meshgrid([1:outsize(2)],[1:outsize(1)],[1:outsize(3)]);    
    X = single(X)-1;
    Y = single(Y)-1;
    Z = single(Z)-1;
    
    if(nargin>4)
        X = X + warping_field{2}; % field in voxel-space
        Y = Y + warping_field{1};
        Z = Z + warping_field{3};
    end
    
    X = X*spacing(1) +origin(1) ;
    Y = Y*spacing(2) +origin(2) ;
    Z = Z*spacing(3) +origin(3) ;
    X_t = r(1,1)*X+r(1,2)*Y+r(1,3)*Z;
    Y_t = r(2,1)*X+r(2,2)*Y+r(2,3)*Z;
    Z_t = r(3,1)*X+r(3,2)*Y+r(3,3)*Z;
    X_t = (X_t-origin(1)+x(1))/spacing(1) +1;
    Y_t = (Y_t-origin(2)+x(2))/spacing(2) +1;
    Z_t = (Z_t-origin(3)+x(3))/spacing(3) +1;
    
    [Y X Z] = meshgrid([1:outsize(2)],[1:outsize(1)],[1:outsize(3)]);
    X = single(X);
    Y = single(Y);
    Z = single(Z);
    
    if(nargin>4)
        X = X + warping_field{2};
        Y = Y + warping_field{1};
        Z = Z + warping_field{3};
    end
    
    field = zeros([ndims(X),size(X)],'single');
    
    if(length(outsize)==2)
        field(1,:,:) = X_t - X;
        field(2,:,:) = Y_t - Y;
    elseif(length(outsize)==3)
        field(1,:,:,:) = X_t - X;
        field(2,:,:,:) = Y_t - Y;
        field(3,:,:,:) = Z_t - Z;
    else
        disp('Error: wrong output size ! Must be 2D or 3D.')
        return
    end

else
    disp('Warning: no rotation in this transform (not enough arguments)...')
    if(length(outsize)==2)
        field = zeros([2 outsize],'single');
        field(1,:,:) = -trans(1,1);
        field(2,:,:) = -trans(1,2);
    elseif(length(outsize)==3)
        field = zeros([3 outsize],'single');
        field(1,:,:,:) = -trans(1,1);
        field(2,:,:,:) = -trans(1,2);
        field(3,:,:,:) = -trans(1,3);
    else
        disp('Error: wrong output size ! Must be 2D or 3D.')
        return
    end
end

