%% Export_transform_and_field
% Save to disk a deformation field stored in |handles.mydata| or |handles.fields|. An additional rigid transformation is applied after the deformation field. It will be stored as a "FrameOfReferenceTransformationMatrix".
% The files are saved at the DICOM format.
%
%% Syntax
% |info = Export_transform_and_field(name1,name2,outname,handles,dicom_tags)|
%
% |info = Export_transform_and_field(name1,name2,outname,handles,dicom_tags)|
%
%
%% Description
% |info = Export_transform_and_field(name1,name2,outname,handles)| Save the rigid transform and deformation field on disk
%
% |info = Export_transform_and_field(name1,name2,outname,handles,dicom_tags)| Save the rigid transform and deformation field and additional DICOM tags on disk
%
%
%% Input arguments
% |name1| - _STRING_ -  Name of the RIGID transformation contained in |handles.mydata| or |handles.fields| to be saved on disk
%
% |name2| - _STRING_ -  Name of the deformation field contained in |handles.fields| to be saved on disk 
%
% |outname| - _STRING_ - Name of the file in which the field should be saved
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "mydata" or "fields"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith field
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - [OPTIONAL] Matrix describing a RIGID transform to be applied before the deformation field
% * ---|handles.XXX.data{i}(1,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in pixels) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * ---|handles.XXX.data{i}(2,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * ---|handles.XXX.data{i}(3-5,:)| - _SCALAR VECTOR_ Rotation matrix 3x3 matrix
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
%
% |dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the file 
%
% * |dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |dicom_tags{i,2}| - _ANY_ Value of the tag  
%
%
%% Output arguments
%
% |info| - _STRUCTURE_ - Meta information from the DICOM file. Some fields have been updated.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function info = Export_transform_and_field(name1,name2,outname,handles,dicom_tags)
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},name1) && strcmp(handles.mydata.info{i}.Type,'rigid_transform'))
        myField1 = handles.mydata.data{i};
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},name1) && strcmp(handles.fields.info{i}.Type,'rigid_transform'))
        myField1 = handles.fields.data{i};
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},name2)  && strcmp(handles.fields.info{i}.Type,'deformation_field'))
        myField2 = handles.fields.data{i};
        myInfo2 = handles.fields.info{i};
    end
end
try
    if(nargin>4)
        info = save_Field(myField2,myInfo2,outname,'dcm',myField1,dicom_tags);
    else
        info = save_Field(myField2,myInfo2,outname,'dcm',myField1);
    end
catch
    cd(handles.path);
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
