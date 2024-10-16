%% Transform2field
% Compute the deformation field resulting from the application of the rigid transform |trans| (translation + rotation)
%
%% Syntax
% |handles = Transform2field(transform_name,field_dest,handles)|
%
%
%% Description
% |handles = Transform2field(transform_name,field_dest,handles)| Compute the deformation field resulting from the application of the rigid transform
%
%
%% Input arguments
% |transform_name| - _STRING_ -   - _STRING_ - Name of the rigid transform in |handles.XXX| (where XXX is 'fields' or 'mydata')
%
% |field_dest| - _STRING_ - Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is 'fields' or 'mydata'):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith field
% * |handles.XXX.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
% * |handles.spatialpropsettled| - _INTEGER_ - 1 = The dimensions for workspace are defined (e.g. image scale is defined). 0 otherwise
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated  in the destimation image |i|:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the field
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Transform2field(transform_name,field_dest,handles)

myTransform = [];

for i=1:length(handles.fields.name)
    if(isfield(handles.fields.info{i},'Type'))
        if(strcmp(handles.fields.name{i},transform_name) && strcmp(handles.fields.info{i}.Type,'rigid_transform'))
            myTransform = single(handles.fields.data{i});
            myInfo = handles.fields.info{i};
        end
    end
end
for i=1:length(handles.mydata.name)
    if(isfield(handles.mydata.info{i},'Type'))
        if(strcmp(handles.mydata.name{i},transform_name) && strcmp(handles.mydata.info{i}.Type,'rigid_transform'))
            myTransform = single(handles.mydata.data{i});
            myInfo = handles.mydata.info{i};
        end
    end
end

if(not(isempty(myTransform)))
    
    if(~handles.spatialpropsettled)
        error('Spatial properties not set! Impossible to convert this data into field')
    end
    
    for j=1:3
        myTransform(1,j) = round(myTransform(1,j)*myInfo.Spacing(j)/handles.spacing(j));
    end
    
    field = rigid_trans_to_def_field(myTransform,handles.size,handles.spacing,handles.origin);
    
    info = Create_default_info('deformation_field',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    
else
    error('Transformation not found.');
end

field_dest = check_existing_names(field_dest,handles.fields.name);
handles.fields.name{length(handles.fields.name)+1} = field_dest;
handles.fields.data{length(handles.fields.data)+1} = field;
handles.fields.info{length(handles.fields.info)+1} = info;
