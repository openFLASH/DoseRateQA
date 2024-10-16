%% Field_exponential
% Compute the exponential of a deformation field contained in |handles.fields|.
% See section  "2.2.1 Field exponential" of reference [1] for more information
%
%% Syntax
% |handles = Field_exponential(field,im_dest,handles)|
%
% |handles = Field_exponential(field,im_dest,handles,inverse)|
%
%
%% Description
% |handles = Field_exponential(field,im_dest,handles)| Take the exponential of the deformation field
%
% |handles = Field_exponential(field,im_dest,handles,inverse)| Take the exponential of the (inverse) deformation field
%
%
%% Input arguments
% |field| - _STRING_ -  Name of the field  to be processed, contained in |handles.fields.name|.
%
% |im_dest| - _STRING_ - Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'fields' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith field
% * |handles.XXX.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
%
% |inverse| - _BOOLEAN_ -  If true, take the exponential of the inverse deformation field. Otherwise (=default), take the exponential of the direct deformation field.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated  in the destimation image |i| (where XXX is either 'fields' of "mydata" depending on input data):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the field
% * |handles.XXX.data{i}| _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the field
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Field_exponential(field,im_dest,handles,inverse)

myField = [];
type = 2;
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},field))
        myField = handles.mydata.data{i};
        myInfo = handles.mydata.info{i};
        type = 3;
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},field))
        myField = handles.fields.data{i};
        myInfo = handles.fields.info{i};
        type = 2;
    end
end
if(isempty(myField))
    error('Error : input field not found in the current list !')
end
if(nargin<4)
    inverse = 0;
end

if(inverse)
    est_field = field_convert(-myField);
else
    est_field = field_convert(myField);
end
est_field = field_exponentiation(est_field);
myField = field_convert(est_field);

if(type==2)
    im_dest = check_existing_names(im_dest,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = im_dest;
    handles.fields.data{length(handles.fields.data)+1} = single(myField);
    info = Create_default_info('deformation_field',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.fields.info{length(handles.fields.info)+1} = info;
elseif(type==3)
    im_dest = check_existing_names(im_dest,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = im_dest;
    handles.mydata.data{length(handles.mydata.data)+1} = single(myField);
    info = Create_default_info('deformation_field',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    info.ImagePositionPatient = myInfo.ImagePositionPatient;
    info.PatientOrientation = myInfo.PatientOrientation;
    info.Spacing = myInfo.Spacing;
    info.ImageOrientationPatient = myInfo.ImageOrientationPatient;
    handles.mydata.info{length(handles.mydata.info)+1} = info;
end
