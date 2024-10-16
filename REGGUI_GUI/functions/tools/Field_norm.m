%% Field_norm
% Compute the norm of the vector of a deformation field. The norm is computed at each voxel of the field. The result is stored in an image of |handsles.images|
%
%% Syntax
% |handles = Field_norm(field,im_dest,handles)|
%
%
%% Description
% |handles = Field_norm(field,im_dest,handles)| compute the norm of the field vectors at each voxels
%
%
%% Input arguments
% |field| - _STRING_ -  Name of the field  to be processed, contained in |handles.fields.name|.
%
% |im_dest| - _STRING_ -  Name of the new image created in |handles.images|
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
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

function handles = Field_norm(field,im_dest,handles)

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
if(ndims(myField)<4)
    error('Not implemented for rigid transforms and 2D field')
else
    
    %im_res = sqrt((squeeze(myField(1,:,:,:)).*myInfo.Spacing(1)).^2+(squeeze(myField(2,:,:,:)).*myInfo.Spacing(2)).^2+(squeeze(myField(3,:,:,:)).*myInfo.Spacing(3)).^2); %Avoid temporary variables
    
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = single(sqrt((squeeze(myField(1,:,:,:)).*myInfo.Spacing(1)).^2+(squeeze(myField(2,:,:,:)).*myInfo.Spacing(2)).^2+(squeeze(myField(3,:,:,:)).*myInfo.Spacing(3)).^2)); %Avoid temporary variables
    info = Create_default_info('image',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.images.info{length(handles.images.info)+1} = info;
end
