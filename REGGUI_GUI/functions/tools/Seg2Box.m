%% Seg2Box
% Create an image containing the smallest paralellipedic box (with voxel set to 1) that enclose all the pixels of a mask image. 
% If a second mask image is provided, then the paralellipipedic box enclude all the pixels of the union of both masks.
%
%% Syntax
% |handles = Seg2Box(image_name,borders,im_dest,handles,image2_name)|
%
%
%% Description
% |handles = Seg2Box(image_name,borders,im_dest,handles,image2_name)| Description
%
%
%% Input arguments
% |image_name| - _STRING_ -  Name of the image mask contained in |handles.images.name| to be processed
%
% |borders| - _SCALAR VECTOR_ - [dx,dy,dz] Add a border of the specified size around the paralellipipedic box
%
% |im_dest| - _STRING_ -  Name of the new image created in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) = the resampled sub-volume of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
%
% |image2_name| - _STRING_ -  Name 
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
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Seg2Box(image_name,borders,im_dest,handles,image2_name)

bb = round(borders./handles.spacing);%borders in [mm], bb in voxels.

myImage = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image_name))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
if(isempty(myImage))
    error(['Error : input mask (',image_name,') not found in the current list !'])
end

[i j s] = find(myImage);
[j k] = ind2sub([handles.size(2) handles.size(3)],j);
minimum = [max(1,min(i)-bb(1));max(1,min(j)-bb(2));max(1,min(k)-bb(3))];
maximum = [min(handles.size(1),max(i)+bb(1));min(handles.size(2),max(j)+bb(2));min(handles.size(3),max(k)+bb(3))];

if(nargin>4)
    myImage = [];
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},image2_name))
            myImage = handles.mydata.data{i};
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},image2_name))
            myImage = handles.images.data{i};
        end
    end
    if(isempty(myImage))
        error('Error : second input image not found in the current list !')
    end
    [i j s] = find(myImage);
    [j k] = ind2sub([handles.size(2) handles.size(3)],j);
    minimum = min([max(1,min(i)-bb(1));max(1,min(j)-bb(2));max(1,min(k)-bb(3))],minimum);
    maximum = max([min(handles.size(1),max(i)+bb(1));min(handles.size(2),max(j)+bb(2));min(handles.size(3),max(k)+bb(3))],maximum);
end

myImage = myImage*0;
myImage(minimum(1):maximum(1),minimum(2):maximum(2),minimum(3):maximum(3)) = 1;

im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(myImage);
info = Create_default_info('image',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;
