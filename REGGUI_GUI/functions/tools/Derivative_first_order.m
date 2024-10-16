%% Derivative_first_order
% Compute the intensity gradient of an image from |handles.images|. The result is a vector fields (stored in |handles.fields|) representing the gradient at each voxel.
%
%% Syntax
% |handles = Derivative_first_order(image,f_dest,handles)|
%
%
%% Description
% |handles = Derivative_first_order(image,f_dest,handles)| compute the image intensity gradient
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed
%
% |f_dest| - _STRING_ -  Name of the new field created in |handles.fields|
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
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Derivative_first_order(image,f_dest,handles)

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
    
    for n=1:ndims(myImage)
        f_res(n,:,:,:) = zeros(size(myImage));
    end
    [gx,gy,gz] = gradient(myImage);
    f_res(2,:,:,:) = gx;
    f_res(1,:,:,:) = gy;
    f_res(3,:,:,:) = gz;
    clear gx gy gz;
    
    f_dest = check_existing_names(f_dest,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = f_dest;
    handles.fields.data{length(handles.fields.data)+1} = single(f_res);
    info = Create_default_info('deformation_field',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.fields.info{length(handles.fields.info)+1} = info;
end
