%% Vector_field_propagation
% Aplly Gaussian smoothing regularisation to a deformation field.
% See section "3.2.1 Gaussian smoothing" of reference [1] for more information
%
%% Syntax
% |res = Vector_field_propagation(field_name,output_name,handles,sigma)|
%
%
%% Description
% |res = Vector_field_propagation(field_name,output_name,handles,sigma)| describes the function
%
%
%% Input arguments
% |field_name|| - _STRING_ -  Name of the field  to be processed, contained in |handles.fields.name|.
%
% |output_name| - _STRING_ - Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
%
% |sigma| - _SCALAR_ -  Standard deviation (in pixel) of the gaussian filter along the 3 dimensions.
%
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated  in the destimation image |i|:
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

function res = Vector_field_propagation(field_name,output_name,handles,sigma)

myField = [];
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},field_name))
        myField = handles.fields.data{i};
        myInfo = handles.fields.info{i};
    end
end
if(isempty(myField))
    error('Error : input image not found in the current list !')
end

% find non-zero region
field_norm = sqrt(squeeze(myField(1,:,:,:)).^2+squeeze(myField(2,:,:,:)).^2+squeeze(myField(3,:,:,:)).^2);
[i,j,~] = find(field_norm>0);
[j,k] = ind2sub([handles.size(2) handles.size(3)],j);
minimum = [max(1,min(i));max(1,min(j));max(1,min(k))];
maximum = [min(handles.size(1),max(i));min(handles.size(2),max(j));min(handles.size(3),max(k))];

% compute certitude map (heuristic)
cert = single(ones(size(field_norm)));
cert(minimum(1):maximum(1),minimum(2):maximum(2),minimum(3):maximum(3)) = 10;

% propatation (heuristic)
while sigma>0    
    temp = myField;
    % perform normalized convolution
    for i=1:(ndims(myField)-1)
        temp(i,:,:,:) = normgauss_smoothing(squeeze(myField(i,:,:,:)),cert,sigma);
    end
    % restore previous values in non-zero region
    myField(:,field_norm==0) = temp(:,field_norm==0);
    sigma = sigma-1;
end

output_name = check_existing_names(output_name,handles.fields.name);
handles.fields.name{length(handles.fields.name)+1} = output_name;
handles.fields.data{length(handles.fields.data)+1} = single(myField);
info = Create_default_info('deformation_field',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.fields.info{length(handles.fields.info)+1} = info;

res = handles;
cd(handles.path)
