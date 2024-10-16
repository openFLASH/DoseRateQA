%% rigid_deformation
% Deforms a *3D* image or volume according to a given rigid transformation.
% The method uses simple trilinear interpolation.
%
% If no rotation is required, one can provide either a null matrix or an identity matrix. The identity matrix respects the mathematical formalism for "no rotation". However, if the function |rigid_deformation| receives a null matrix, it will ignore it and will simply apply a translation. The result is the same (if mathematically less formal) but the results are computed faster.
%
%% Syntax
% |output = rigid_deformation(indata,rigid_transform = _SCALAR VECTOR_)|
%
% |[output new_origin] = rigid_deformation(indata,rigid_transform = _SCALAR MATRIX_ ,spacing,origin)|
%
%
%% Description
% |output = rigid_deformation(indata,rigid_transform)| Translate the origin of the *patient* C.S.
%
% |[output new_origin] = rigid_deformation(indata,rigid_transform,spacing,origin)| Translate and rotate the origin of the *image* C.S.
%
%
%% Input arguments
% |indata| - _SCALAR MATRIX_ -  |indata(x,y,z)| Intensity at voxel (x,y,z) of the inital image
%
% |rigid_transform| - _SCALAR VECTOR or SCALAR MATRIX_ -  Depending on the function call syntax, |rigid_transform| can be:
%
% * Syntax 1: function with 2 input parameters and |rigid_transform| is a _SCALAR VECTOR_
% * ---- |rigid_transform(1,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in pixels) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * Syntax 2: function with 5 input parameters and |rigid_transform| is a _SCALAR MATRIX_
% * ---- |rigid_transform(1,:)| : Ignored
% * -----|rigid_transform(2,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * -----|rigid_transform(3-5,:)| - _SCALAR VECTOR_ Rotation matrix (3x3 matrix). If no rotation is required, provided either a null matrix or an identity matrix. 
% 
% NB: The translation information is expressed either in the image coordinate system or in the patient coordinate system. The link between these 2 transforms are: |rigid_transform(1,:) = round(( rigid_transform(2,:) - (handles.origin - handles.images.info.ImagePositionPatient)')./ handles.spacing')|
%
% |spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the |indata| image
%
% |origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
%
%% Output arguments
%
% |output| - _SCALAR MATRIX_ -  |output(x,y,z)| Intensity at voxel (x,y,z) of the transformed image
%
% |new_origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the *translated* image
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [output new_origin] = rigid_deformation(indata,rigid_transform,spacing,origin)

output = zeros(size(indata),'single')+min(indata(:));
new_origin = origin;
istranslation = 1;
isrotation = 1;

try
    inttranslation = rigid_transform(1,:);
catch
    istranslation = 0;
    disp('Warning : empty transform ! Nothing to do with this!')
    return
end
try
    rotation = rigid_transform(3:5,:);
    translation = rigid_transform(2,:);
    isrotation = (sum(sum(find(rotation)))~=0);
catch
    isrotation = 0;
    disp('Warning : no rotation matrix in this transform !')
end

if(isrotation && (round(abs(det(rotation))*1000)/1000~=1))% Affine transform
    disp('Affine transformation')
    output = zeros(ceil([size(indata,1)/min(1,abs(rotation(1,1))),size(indata,2)/min(1,abs(rotation(2,2))),size(indata,3)/min(1,abs(rotation(3,3)))]),'single')+min(indata(:));
end

if(isrotation && nargin>3)
    new_fov = nargout>1;
    [output,new_origin] = myTransformation(translation,rotation,output,indata,spacing,origin,new_fov);
elseif(istranslation)
    output = myIntTranslation(inttranslation,output,indata);
end

end

function A = myIntTranslation(x,A,B)
x = -round(x);
A(1+max(0,x(1)):min(size(A,1),size(B,1)+x(1)),1+max(0,x(2)):min(size(A,2),size(B,2)+x(2)),1+max(0,x(3)):min(size(A,3),size(B,3)+x(3)))=...
    B(1+max(0,-x(1)):min(size(B,1),size(A,1)-x(1)),1+max(0,-x(2)):min(size(B,2),size(A,2)-x(2)),1+max(0,-x(3)):min(size(B,3),size(A,3)-x(3)));
end

function [A,new_origin] = myTransformation(x,r,A,B,spacing,origin,new_fov)
if(new_fov)
    % find new fov
    bb(:,1) = r\origin;
    bb(:,2) = r\(origin+[spacing(1)*size(A,1);0;0]);
    bb(:,3) = r\(origin+[0;spacing(2)*size(A,2);0]);
    bb(:,4) = r\(origin+[0;0;spacing(3)*size(A,3)]);
    bb(:,5) = r\(origin+[spacing(1)*size(A,1);spacing(2)*size(A,2);0]);
    bb(:,6) = r\(origin+[spacing(1)*size(A,1);0;spacing(3)*size(A,3)]);
    bb(:,7) = r\(origin+[0;spacing(2)*size(A,2);spacing(3)*size(A,3)]);
    bb(:,8) = r\(origin+[spacing(1)*size(A,1);spacing(2)*size(A,2);spacing(3)*size(A,3)]);    
    bb = (bb - repmat(origin,1,8))./repmat(spacing,1,8);
    bb_min = min(bb,[],2);
    bb_max = max(bb,[],2);    
    [Y X Z] = meshgrid([1+bb_min(2):bb_max(2)],[1+bb_min(1):bb_max(1)],[1+bb_min(3):bb_max(3)]);
    new_origin = bb_min.*spacing + origin;
else
    % crop to original fov
    [Y X Z] = meshgrid([1:size(A,2)],[1:size(A,1)],[1:size(A,3)]);
    new_origin = origin;
end
X = (X -1)*spacing(1) +origin(1);
Y = (Y -1)*spacing(2) +origin(2);
Z = (Z -1)*spacing(3) +origin(3);
X_t = r(1,1)*X+r(1,2)*Y+r(1,3)*Z;
Y_t = r(2,1)*X+r(2,2)*Y+r(2,3)*Z;
Z_t = r(3,1)*X+r(3,2)*Y+r(3,3)*Z;
X_t = (X_t-origin(1)+x(1))/spacing(1) +1;
Y_t = (Y_t-origin(2)+x(2))/spacing(2) +1;
Z_t = (Z_t-origin(3)+x(3))/spacing(3) +1;
if(size(A,1)*size(A,2)*size(A,3)>1e8)
    nbr_interps = round(size(A,1)*size(A,2)*size(A,3)/4e6);
    nbr_pixels = floor(size(A,1)*size(A,2)*size(A,3)/nbr_interps);
    for i=1:nbr_interps
        A(1+(i-1)*nbr_pixels:i*nbr_pixels) = interp3(B,Y_t(1+(i-1)*nbr_pixels:i*nbr_pixels),X_t(1+(i-1)*nbr_pixels:i*nbr_pixels),Z_t(1+(i-1)*nbr_pixels:i*nbr_pixels));
    end
    A(nbr_interps*nbr_pixels:end) = interp3(B,Y_t(nbr_interps*nbr_pixels:end),X_t(nbr_interps*nbr_pixels:end),Z_t(nbr_interps*nbr_pixels:end));
else
    A = interp3(B,Y_t,X_t,Z_t);
end
A(find(isnan(A)))=min(B(:));
end
