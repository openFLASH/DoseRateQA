%% Composition
% Composition of the field D1 and D2: Dr = D1 (+) D2 (See reference [1], section "2.1.9 Displacement field composition").
% D1 and D2 can either be deformation field or rigid translations.
%
%% Syntax
% |handles = Composition(firstField,secondField,im_dest,handles)|
%
%
%% Description
% |handles = Composition(firstField,secondField,im_dest,handles)| Compose the first and second deformation fields
%
%
%% Input arguments
% |firstField| - _STRING_ -  Name of the first field D1, contained in |handles.fields.name|.
%
% |secondField| - _STRING_ -  Name of the second field D2, contained in |handles.fields.name|.
%
% |im_dest| - _STRING_ -  Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated  in the destination image |i|:
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

function handles = Composition(firstField,secondField,im_dest,handles)

% Authors : G.Janssens

output_type = 'deformation_field';

for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},secondField))
        mySecondInfo = handles.fields.info{i};
        if(strcmp(mySecondInfo.Type,'deformation_field'))
            mySecondField = cell(0);
            mySecondField{1} = squeeze(handles.fields.data{i}(2,:,:,:));
            mySecondField{2} = squeeze(handles.fields.data{i}(1,:,:,:));
            if(size(handles.fields.data{i},1)==3)
                mySecondField{3} = squeeze(handles.fields.data{i}(3,:,:,:));
            end
        elseif(strcmp(mySecondInfo.Type,'rigid_transform'))
            mySecondTransform = handles.fields.data{i};
            myTemp = rigid_trans_to_def_field(handles.fields.data{i},handles.size',handles.spacing,handles.origin);
            mySecondField = cell(0);
            mySecondField{1} = squeeze(myTemp(2,:,:,:));
            mySecondField{2} = squeeze(myTemp(1,:,:,:));
            if(size(myTemp,1)==3)
                mySecondField{3} = squeeze(myTemp(3,:,:,:));
            end
        else
            error('Not a valid type. Must be ''deformation_field'' or ''rigid_transform''')
        end
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},firstField))
        myFirstInfo = handles.fields.info{i};
        if(strcmp(myFirstInfo.Type,'deformation_field'))
            myFirstField = handles.fields.data{i};
        elseif(strcmp(myFirstInfo.Type,'rigid_transform'))
            myFirstTransform = handles.fields.data{i};
            myFirstField = rigid_trans_to_def_field(handles.fields.data{i},handles.size',handles.spacing,handles.origin,mySecondField);
        else
            error('Not a valid type. Must be ''deformation_field'' or ''rigid_transform''')
        end
    end
end
try
    if(strcmp(myFirstInfo.Type,'deformation_field'))
        
        myRes(1,:,:,:) = linear_deformation(squeeze(myFirstField(1,:,:,:)), ' ', mySecondField, []) + mySecondField{2};
        myRes(2,:,:,:) = linear_deformation(squeeze(myFirstField(2,:,:,:)), ' ', mySecondField, []) + mySecondField{1};
        myRes(3,:,:,:) = linear_deformation(squeeze(myFirstField(3,:,:,:)), ' ', mySecondField, []) + mySecondField{3};
        
    elseif(strcmp(mySecondInfo.Type,'deformation_field') && strcmp(myFirstInfo.Type,'rigid_transform'))
        
        myRes(1,:,:,:) = squeeze(myFirstField(1,:,:,:)) + mySecondField{2};
        myRes(2,:,:,:) = squeeze(myFirstField(2,:,:,:)) + mySecondField{1};
        myRes(3,:,:,:) = squeeze(myFirstField(3,:,:,:)) + mySecondField{3};
        
    elseif(strcmp(mySecondInfo.Type,'rigid_transform') && strcmp(myFirstInfo.Type,'rigid_transform'))
        
        output_type = 'rigid_transform';        
        myRes = [[myFirstTransform(3:5,1:3),myFirstTransform(2,1:3)'];0 0 0 1]*[[mySecondTransform(3:5,1:3),mySecondTransform(2,1:3)'];0 0 0 1];
        myRes = [0 0 0;myRes(1:3,4)';myRes(1:3,1:3)];
        
    else
        error('Not a valid type. Must be ''deformation_field'' or ''rigid_transform''')
    end
    im_dest = check_existing_names(im_dest,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = im_dest;
    handles.fields.data{length(handles.fields.data)+1} = single(myRes);
    info = Create_default_info(output_type,handles);
    if(isfield(mySecondInfo,'OriginalHeader'))
        info.OriginalHeader = mySecondInfo.OriginalHeader;
    elseif(isfield(myFirstInfo,'OriginalHeader'))
        info.OriginalHeader = myFirstInfo.OriginalHeader;
    end
    handles.fields.info{length(handles.fields.info)+1} = info;
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
