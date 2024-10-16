%% Median_Smoothing
% Apply the median filtering to a 3D image contained in |handles.images|.
%
%% Syntax
% |handles = Median_Smoothing(image,params,im_dest,handles)|
%
%
%% Description
% |handles = Median_Smoothing(image,params,im_dest,handles)| Apply the median filtering
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed
%
% |params| - Not used
%
% |image_dest| - _STRING_ -  Name of the new image created in |handles.images|
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
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| 1 = The voxel at coordinate (x,y,z) belongs to the object. 0, otherwise
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.images.info| or original image
%
%% References
%
% [1] http://matitk.cs.sfu.ca/usageguide
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Median_Smoothing(image,params,im_dest,handles)

% Authors : G.Janssens

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
if(ndims(myImage)==2)
    error('Not implemented for 2D images')
else
    %im_res = ordfilt3D(myImage,14); %Avoid temporary variables
    
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = single(ordfilt3D(myImage,14)); %Avoid temporary variables
    info = Create_default_info('image',handles,myInfo);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.images.info{length(handles.images.info)+1} = info;
end
