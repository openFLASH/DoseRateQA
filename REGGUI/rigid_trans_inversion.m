%% rigid_trans_inversion
% Invert a translation - rotation matrix
%
%% Syntax
% |trans = rigid_trans_inversion(trans)|
%
%
%% Description
% |trans = rigid_trans_inversion(trans)| describes the function
%
%
%% Input arguments
% |trans| - _SCALAR MATRIX_ -  Matrix deifning the translation / rotation
%
% * |rigid_transform(1,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in pixels) of the origin  of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * |rigid_transform(2,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * |rigid_transform(3-5,:)| - _SCALAR VECTOR_ Rotation matrix 3x3 matrix
%
%
%% Output arguments
%
% |trans| - _SCALAR MATRIX_ -  The inverted matrix deifning the translation / rotation
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function trans = rigid_trans_inversion(trans)

if(sum(sum(trans(3:end,:)~=0)))

    r = trans(3:5,:);

    if(sum(sum(r~=r')) || round(det(r)*1000)/1000~=1)% Affine transform

        disp('Inverting affine transformation...')        
        r = inv(r);

    else % rotation only
        
        disp('Inverting rigid transformation...')        
        r = r';

    end

    x1 = -r*trans(1,:)';
    x2 = -r*trans(2,:)';
    trans(1,:) = x1';
    trans(2,:) = x2';
    trans(3:5,:) = r;

else

    disp('Warning: no rotation in this transform (not enough arguments)...')
    trans(1:2,:) = -trans(1:2,:);

end

