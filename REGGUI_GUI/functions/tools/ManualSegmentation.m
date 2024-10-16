%% ManualSegmentation
% Open a viewer to manually segment an image. REturn a segmented image (= mask)
%
%% Syntax
% |handles = ManualSegmentation(handles,image,im_dest)|
%
% |handles = ManualSegmentation(handles,image,im_dest,b)|
%
%
%% Description
% |handles = ManualSegmentation(handles,image,im_dest)| Open a viewer to manually segment the image
%
% |handles = ManualSegmentation(handles,image,im_dest,b)| Open a viewer to manually segment the image, starting with an inital segmentation mask
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |image| - _STRING_ -  Name of the image in |handles.images| to be segmented
%
% |im_dest| - _STRING_ - Name of the segmented image in |handles.images|
%
% |b| - _STRING_ -  [OPTIONAL] Name of the initial segmentaiton mask  in |handles.images|
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

function handles = ManualSegmentation(handles,image,im_dest,b)

% Authors : G.Janssens

myImage = [];
myInitMask = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
if(not(isempty(b)))
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},b))
            myInitMask = single(handles.images.data{i}>0.5*max(max(max(handles.images.data{i}))));
        end
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
end
try
    if(isempty(myInitMask))
        im_res = image_viewer(myImage,myInfo,'mask',handles.view_point);
    else
        im_res = image_viewer(myImage,myInfo,'mask',handles.view_point,myInitMask);
    end
catch ME
    reggui_logger.info(['Error occured during manual segmentation. ',ME.message],handles.log_filename);
    rethrow(ME);
end
im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(im_res);
info = Create_default_info('image',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;
