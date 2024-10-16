%% Gaussian_Smoothing
% Gaussian smoothing is applied to an image of |handles.images| using either a spherical or ellipsoidal structuring element. If a certainty matrix is provided, then normalised gaussian smoothing is applied.
%
%% Syntax
% |handles = Gaussian_Smoothing(image,params=[Sx,Sy,Sz],im_dest,handles [,cert])|
%
% |handles = Gaussian_Smoothing(image,params=S,im_dest,handles [,cert])|
%
% |handles = Gaussian_Smoothing(image,params=S,im_dest,handles,cert)|
%
%
%% Description
% |handles = Gaussian_Smoothing(image,params=[Sx,Sy,Sz],im_dest,handles)| Apply gaussian smoothing with spherical structuring element
%
% |handles = Gaussian_Smoothing(image,params=S,im_dest,handles)| Apply gaussian smoothing with spherical structuring element
%
% |handles = Gaussian_Smoothing(image,params=S,im_dest,handles,cert)| Apply *normalised* gaussian smoothing with spherical or ellipsoidal structuring element
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed
%
% |params| - _SCALAR VECTOR_ -  Size of the kernel mask. The vector can have different number of elements:
%
% * |params = [Sx,Sy,Sz]| : Three elements. Radius (in mm) of the 3D structuring element along the 3 coordinates axis. The structuring element is an ellispoid.
% * |params = S| : Radius (in mm) of the structuring element. The structuring element is a sphere
%
% |im_dest| - _STRING_ -  Name of the new image created in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
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
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info|
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Gaussian_Smoothing(image,params,im_dest,handles,cert)

myImage = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
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

if(sum(params))
    if(isempty(myCert))
        im_res = gauss_smoothing(myImage, sigma(1)/handles.spacing(1), sigma(2)/handles.spacing(2), sigma(3)/handles.spacing(3));% params(1)=STD in mm !!
    else
        im_res = normgauss_smoothing(myImage, myCert, sigma(1)/handles.spacing(1), sigma(2)/handles.spacing(2), sigma(3)/handles.spacing(3));% params(1)=STD in mm !!
    end
else
    im_res = myImage;
end

im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(im_res);
info = Create_default_info('image',handles,myInfo);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;
