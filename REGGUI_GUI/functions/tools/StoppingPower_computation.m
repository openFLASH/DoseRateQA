%% StoppingPower_computation
% Convert a CT scan (HU unit) into a stopping power image.
% The calibration curve is defined in the function hu_to_we.m 
%
%% Syntax
% |handles = StoppingPower_computation(image,params,im_dest,handles)|
%
%
%% Description
% |handles = StoppingPower_computation(image,params,im_dest,handles)| describes the function
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| with the CT scan
%
% |params| - _STRING VECTOR_ -  description
%
% * |params{1}| : Calibration model for HU to Water equivalent length conversion. See hu_to_we.m for description.
%
% |im_dest| - _STRING_ -  Name of the new image created in |handles.images| with the stopping power map
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
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = StoppingPower_computation(image,params,im_dest,handles)

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

model = params{1};

% Compute WE
myImage = hu_to_we(myImage,model);

im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(myImage);
info = Create_default_info('image',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;
