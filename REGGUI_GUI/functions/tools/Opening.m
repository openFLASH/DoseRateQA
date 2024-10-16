%% Opening
% Apply a Opening filter on an image. The function applies an |imrode| filter followed by |imdilate|.
%
%% Syntax
% |handles = Opening(image,params=[x,y,z],im_dest,handles)|
%
% |handles = Opening(image,params=[i,j],im_dest,handles)|
%
% |handles = Opening(image,params,im_dest,handles,shape)|
%
% |handles = Opening(image,params,im_dest,handles,shape)|
%
%
%% Description
% |handles = Opening(image,params,im_dest,handles)| Apply an opening filter on the image using a spheric kernel element
%
% |handles = Opening(image,params,im_dest,handles,shape)| Apply a opening filter on the image
%
%
%% Input arguments
% |image| - _STRING_ - Name of the image in |handles.XXX| to be translated (where XXX is either 'images' of "mydata", depending on |type|)
%
% |params| - _SCALAR VECTOR_ -  Size of the kernel mask. The vector can have different number of elements:
%
% * |params = [x,y,z]| : Three elements. Radius (in mm) of the 3D structuring element. 
% * |params = [i,j]| : Two elements. Radius (in pixel) of the structuring element. i is the radius in the (x,y) plane and j is the height/2 in z.
%
% |im_dest| - _STRING_ -  Name of the new image in |handles.images| or |handles.mydata| (same location as input data) where the results will be stored
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.spacing| - _VECTOR of SCALAR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |shape| - _STRING_ -  Type of erosion mask. Possible options:
%
% * 'spheric' : (Default) spherical structuring element
% * 'cubic' : Cubic structuring elemen
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the resulting data. The following data is updated in the structure (where XXX is either 'images' of "mydata" depending on input data):
%
% * |handles.XXX.name{i}| - _STRING_ - The deformed image name = |def_image_name| 
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image. Copied from input data
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Opening(image,params,im_dest,handles,shape)

myImage = [];
type = 1;
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},image))
        myImage = handles.mydata.data{i};
        myInfo = handles.mydata.info{i};
        type = 3;
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
end
if(nargin<5)
    shape = 'spheric';
end
% If 3 inputs params, convert from [mm]. Else performs in voxel space
if(length(params)==3) % in mm
    for n=1:3
        params(n) = params(n)/handles.spacing(n) +eps;
    end
    myStrel = zeros(2*ceil(params(1))+1,2*ceil(params(2))+1,2*ceil(params(3))+1);
    center = ([size(myStrel,1) size(myStrel,2) size(myStrel,3)]+1)/2;
    [Y X Z] = meshgrid(1:size(myStrel,2),1:size(myStrel,1),1:size(myStrel,3));
    if(strcmp(shape,'cubic'))
        myStrel = abs(X-center(1))./params(1)<=1 & abs(Y-center(2))./params(2)<=1 & abs(Z-center(3))./params(3)<=1;% cubic
    else
        myStrel = (X-center(1)).^2/params(1).^2+(Y-center(2)).^2/params(2).^2+(Z-center(3)).^2/params(3).^2<=1;% spheric
    end
else % in voxels
    params = round(params);
    params(2) = params(2)-1;% so that height = 1 leads to a 2D structural element
    myStrel = zeros(2*params(1)+1);
    for i = 1:2*params(2)+1
        myStrel(:,:,i)= zeros(2*params(1)+1);
        for j = 1:2*params(1)
            for k = 1:2*params(1)
                if (sqrt((i-params(2)-1)^2*params(2)/params(1)+(j-params(1)-1)^2+(k-params(1)-1)^2)<params(1))
                    myStrel(j,k,i)=1;
                end
            end
        end
    end
end

im_res = imerode(single(myImage),myStrel);
im_res(isinf(im_res)) = 0;
im_res = imdilate(single(im_res),myStrel);
im_res(isinf(im_res)) = 0;

if(type==3)
    if(ndims(im_res)==3)
        im_dest = check_existing_names(im_dest,handles.mydata.name);
        handles.mydata.name{length(handles.mydata.name)+1} = im_dest;
        handles.mydata.data{length(handles.mydata.data)+1} = single(im_res);
        handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
    else
        error('Error: this data is not an image !!')
    end
else
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = single(im_res);
    info = Create_default_info('image',handles,myInfo);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.images.info{length(handles.images.info)+1} = info;
end
