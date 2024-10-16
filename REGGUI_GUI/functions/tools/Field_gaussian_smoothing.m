%% Field_gaussian_smoothing
% Gaussian smoothing is applied to a deformation field in |handles.fields| using either a spherical or ellipsoidal structuring element. If a certainty matrix is provided, then normalised gaussian smoothing is applied.
%
%% Syntax
% |handles = Field_gaussian_smoothing(image,params=[Sx,Sy,Sz],im_dest,handles [,cert])|
%
% |handles = Field_gaussian_smoothing(image,params=S,im_dest,handles [,cert])|
%
% |handles = Field_gaussian_smoothing(image,params=S,im_dest,handles,cert)|
%
%
%% Description
% |handles = Field_gaussian_smoothing(image,params=[Sx,Sy,Sz],im_dest,handles)| Apply gaussian smoothing with spherical structuring element
%
% |handles = Field_gaussian_smoothing(image,params=S,im_dest,handles)| Apply gaussian smoothing with spherical structuring element
%
% |handles = Field_gaussian_smoothing(image,params=S,im_dest,handles,cert)| Apply *normalised* gaussian smoothing with spherical or ellipsoidal structuring element
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the field contained in |handles.fields.name| to be processed
%
% |params| - _SCALAR VECTOR_ -  Size of the kernel mask. The vector can have different number of elements:
%
% * |params = [Sx,Sy,Sz]| : Three elements. Radius (in mm) of the 3D structuring element along the 3 coordinates axis. The structuring element is an ellispoid.
% * |params = S| : Radius (in mm) of the structuring element. The structuring element is a sphere
%
% |im_dest| - _STRING_ -  Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |cert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the field
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Field_gaussian_smoothing(field,params,im_dest,handles,cert)

% Authors : G.Janssens

myField = [];
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},field))
        myField = handles.fields.data{i};
        myInfo = handles.fields.info{i};
    end
end
if(isempty(myField))
    error('Error : input field not found in the current list !')
end

myCert = [];
if(nargin>4)
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},cert))
            myCert = handles.images.data{i};
        end
    end
end

sigma = params;
if(length(sigma)<3)
    sigma(1) = params(1);
    sigma(2) = params(1);
    sigma(3) = params(1);
end

if(ndims(myField)<4)
    disp('Not implemented for rigid transforms and 2D field')
else
    im_res = myField*0;    
    for i=1:(ndims(myField)-1)
        if(isempty(myCert))
            im_res(i,:,:,:) = gauss_smoothing(squeeze(myField(i,:,:,:)), sigma(1)/handles.spacing(1), sigma(2)/handles.spacing(2), sigma(3)/handles.spacing(3));% params(1)=STD in mm !!
        else
            im_res(i,:,:,:) = normgauss_smoothing(squeeze(myField(i,:,:,:)), myCert, sigma(1)/handles.spacing(1), sigma(2)/handles.spacing(2), sigma(3)/handles.spacing(3));% params(1)=STD in mm !!
        end
    end
    
    im_dest = check_existing_names(im_dest,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = im_dest;
    handles.fields.data{length(handles.fields.data)+1} = single(im_res);
    info = Create_default_info('deformation_field',handles,myInfo);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.fields.info{length(handles.fields.info)+1} = info;
end
