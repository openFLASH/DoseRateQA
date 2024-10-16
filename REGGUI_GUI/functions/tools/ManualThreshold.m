%% ManualThreshold
% Segment an image be selecting the pixels with an intensity between a specified minimum and maximum.
%
%% Syntax
% |handles = ManualThreshold(image,params,im_dest,handles)|
%
%
%% Description
% |handles = ManualThreshold(image,params,im_dest,handles)| Segment the image
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image in |handles.images| to be tresholded
%
% |params| - _SCALAR VECTOR_ - |params= [min,max]| The selected pixels have an intensity min <= I <= max
%
% |im_dest| - _STRING_ - Name of the resulting image in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
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

function handles = ManualThreshold(image,params,im_dest,handles)


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

im_res = single( myImage>=params(1) & myImage<=params(2) );
if(max(max(max(im_res)))>1)
    im_res = round(im_res/max(max(max(im_res))));
end

im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(im_res);
info = Create_default_info('image',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;
