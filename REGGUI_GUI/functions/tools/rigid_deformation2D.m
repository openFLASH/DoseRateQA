%% rigid_deformation2D
% Deforms a *2D* image or volume according to a given rigid transformation.
% The method uses simple bilinear interpolation.
%
% If no rotation is required, one can provide either a null matrix or an identity matrix. The identity matrix respects the mathematical formalism for "no rotation". However, if the function |rigid_deformation| receives a null matrix, it will ignore it and will simply apply a translation. The result is the same (if mathematically less formal) but the results are computed faster.
%
%% Syntax
% |output = rigid_deformation2D(indata,rigid_transform = _SCALAR VECTOR_)|
%
% |output = rigid_deformation2D(indata,rigid_transform = _SCALAR MATRIX_,spacing,origin)|
%
%
%% Description
% |output = rigid_deformation2D(indata,rigid_transform,spacing,origin)| Translate the origin of the *patient* C.S.
%
% |output = rigid_deformation2D(indata,rigid_transform,spacing,origin)| Translate and rotate the origin of the *image* C.S.
%
%
%% Input arguments
% |indata| - _SCALAR MATRIX_ -  |indata(x,y,z)| Intensity at voxel (x,y,z) of the inital image
%
% |rigid_transform| - _SCALAR VECTOR or SCALAR MATRIX_ -  Depending on the function call syntax, |rigid_transform| can be:
%
% * Syntax 1: function with 2 input parameters and |rigid_transform| is a _SCALAR VECTOR_
% * ---- |rigid_transform(1,:)| - _SCALAR VECTOR_ Translation vector (x,y) (in pixels) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * Syntax 2: function with 5 input parameters and |rigid_transform| is a _SCALAR MATRIX_
% * ---- |rigid_transform(1,:)| : Ignored
% * -----|rigid_transform(2,:)| - _SCALAR VECTOR_ Translation vector (x,y) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * -----|rigid_transform(3-5,:)| - _SCALAR VECTOR_  Rotation matrix (2x2 matrix). If no rotation is required, provided either a null matrix or an identity matrix. 
% 
% NB: The translation inoframtion is expressed either in the image coordinate system or in the patient coordinate system. The link between these 2 transforms are: |rigid_transform(1,:) = round(( rigid_transform(2,:) - (handles.origin - handles.images.info.ImagePositionPatient)')./ handles.spacing')|
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

function output = rigid_deformation2D(indata,rigid_transform,spacing,origin)

output = zeros(size(indata),'single')+min(indata(:));
istranslation = 1;
isrotation = 1;

try
    inttranslation = rigid_transform(1,:);
%     disp(['Translation vector = ',num2str(inttranslation)]);
catch
    istranslation = 0;
    disp('Warning : empty transform ! Nothing to do with this!')
    return
end
try
    rotation = rigid_transform(3:5,:);
    rotation = rotation(1:2,1:2);
    translation = rigid_transform(2,:);
    translation = translation(1:2);
%     disp(['Real translation vector = ',num2str(translation)]);
%     disp('Rotation matrix = ');
%     disp(num2str(rotation));
    isrotation = (sum(sum(rotation))~=0);
catch
    isrotation = 0;
    disp('Warning : no rotation matrix in this transform !')
end

if(sum(sum(rotation~=rotation')) || round(det(rotation)*1000)/1000~=1)% Affine transform  
   output = zeros(ceil([size(indata,1)*rotation(1,1),size(indata,2)*rotation(2,2)]),'single'); 
end

if(isrotation && nargin>3)    
    output = myTransformation2D(translation,rotation,output,indata,spacing,origin);
elseif(istranslation)
    output = myIntTranslation2D(inttranslation,output,indata);
end

end

function A = myIntTranslation2D(x,A,B)
x = round(x);
A(1+max(0,x(1)):min(size(A,1),size(B,1)+x(1)),1+max(0,x(2)):min(size(A,2),size(B,2)+x(2)))=...
    B(1+max(0,-x(1)):min(size(B,1),size(A,1)-x(1)),1+max(0,-x(2)):min(size(B,2),size(A,2)-x(2)));
end

function A = myTransformation2D(x,r,A,B,spacing,origin)
[Y X] = meshgrid([1:size(A,2)],[1:size(A,1)]);
X = (X -1)*spacing(1) +origin(1) ;
Y = (Y -1)*spacing(2) +origin(2) ;
X_t = r(1,1)*X+r(1,2)*Y;
Y_t = r(2,1)*X+r(2,2)*Y;
X_t = (X_t-origin(1)+x(1))/spacing(1) +1;
Y_t = (Y_t-origin(2)+x(2))/spacing(2) +1;
if(size(A,1)*size(A,2)>1e7)
    nbr_interps = round(size(A,1)*size(A,2)/4e6);
    nbr_pixels = floor(size(A,1)*size(A,2)/nbr_interps);
    for i=1:nbr_interps
        A(1+(i-1)*nbr_pixels:i*nbr_pixels) = interp2(B,Y_t(1+(i-1)*nbr_pixels:i*nbr_pixels),X_t(1+(i-1)*nbr_pixels:i*nbr_pixels));
    end
    A(nbr_interps*nbr_pixels:end) = interp2(B,Y_t(nbr_interps*nbr_pixels:end),X_t(nbr_interps*nbr_pixels:end));
else
    A = interp2(B,Y_t,X_t);
end
A(find(isnan(A)))=min(B(:));
end
