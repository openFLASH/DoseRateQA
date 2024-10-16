%% Import_field
% Import a deformation field from file into the |handles| workspace. If the field has the same dimensions as the |handles.images| workspace, then the deformation field is loaded in |handles.fields|. Otherwise, if the automatic mode is turned off, the deformation field is stored in |handles.mydata|. If the automatic mode is turned on, a dialog box is displayed to let the user choose where the field should be stored.
%
%% Syntax
% |handles = Import_field(myFieldDir,myFieldFilename,format,myFieldName,handles)|
%
% |handles = Import_field(myFieldDir,myFieldFilename,format,myFieldName,handles,merge_rigid_and_deformable)|
%
%
%% Description
% |handles = Import_field(myFieldDir,myFieldFilename,format,myFieldName,handles)| Load the deformation fields and the pre and post rigid transforms. Keep them in separate data fields.
%
% |handles = Import_field(myFieldDir,myFieldFilename,format,myFieldName,handles,merge_rigid_and_deformable)| Load the deformation fields and the pre and post rigid transforms. Combine the fields if required.
%
%
%% Input arguments
% |myFieldDir| - _STRING_ - the directory on disk holding the deformation field.
%
% |myFieldFilename| - _STRING_ - the deformation field filename. 
%
% |format| - _INTEGER_ - defines the type of import that will be perfomed. The following indices are expected:
%
% * 1 - 3D Dicom files
% * 2 - Matlab files
% * 3 - Meta image files
% * 4 - Text format
%
% |myFieldName| - _STRING_ - Name of the data structure stored inside |handles.myfield| or |handles.mydata|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be processed.
%
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
% * |handles.spatialpropsettled| - _INTEGER_ - 1 = The dimensions for workspace are defined (e.g. image scale is defined). 0 otherwise
% * |handles.auto_mode| - _INTEGER_ - 0 = auto mode is not active. 1 = auto mode is active
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
%
% |merge_rigid_and_deformable| - _INTEGER_ - [OPTIONAL. Default = 0] 1 = The final deformation field |myField| is the combination of the rigid pre-tranform, the deformation field and the rigid post-transform (see |linear_deformation|). 0 = The fields are not combined. |handles.myfield| or |handles.mydata| will contain 2 new fields [myFieldName '_pre'] [myFieldName] [myFieldName '_post'].
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the loaded data (whre XXX is |fields| or |mydata|):
%
% * |handles.XXX.name|
% * |handles.XXX.data|
% * |handles.XXX.info|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Import_field(myFieldDir,myFieldFilename,format,myFieldName,handles,merge_rigid_and_deformable)
% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 1
            format = 'dcm';
        case 2
            format = 'mat';
        case 3
            format = 'mhd';
        case 4
            format = 'txt';
        otherwise
            error('Invalid type number.')
    end
end
% import image
Field_load = 1;
Data_load = 0;
Convert = 0;
if(nargin<6)
    merge_rigid_and_deformable = 0;
end
myField = [];
myInfo = struct;
try
    [myField,myInfo,myRigidPreDef,myDeformableDef,myRigidPostDef] = load_Field(myFieldDir,myFieldFilename,format);
catch ME
    reggui_logger.info(['This file is not a valid field. ',ME.message],handles.log_filename);
    rethrow(ME);
end
% Setting or checking image properties
if(~isfield(myInfo,'Spacing') || ~isfield(myInfo,'ImagePositionPatient') || isempty(myField) )
    disp(myInfo)
    error('Error : unable to import field because of empty data or unknown properties.')
end
if(~handles.spatialpropsettled)
    if(strcmp(myInfo.Type,'rigid_transform'))
        Data_load = 0;
        Field_load = 1;
        Set_spatialprop = 0;
    elseif(~handles.auto_mode)
        Choice = questdlg(['Loading this field (',myFieldName,') will set spatial properties for this project'], ...
            'Choose', ...
            'Continue', 'Load as data','Cancel','Continue');
        if(strcmp(Choice,'Continue'))
            Data_load = 0;
            Field_load = 1;
            Set_spatialprop = 1;
        end
        if(strcmp(Choice,'Load as data'))
            Data_load = 1;
            Field_load = 0;
            Set_spatialprop = 0;
        end
        if(strcmp(Choice,'Cancel'))
            return
        end
    else
        Set_spatialprop = 1;
    end
    if(Set_spatialprop)
        disp('Setting spatial properties for this project !')
        handles.size(1) = size(myField,2);
        handles.size(2) = size(myField,3);
        handles.size(3) = size(myField,4);
        handles.spacing = myInfo.Spacing;
        handles.origin = myInfo.ImagePositionPatient;
        handles.spatialpropsettled = 1;
    end
else
    if((~(handles.size(1) == size(myField,2) && handles.size(2) == size(myField,3) && handles.size(3) == size(myField,4)) || sum(~(handles.spacing == myInfo.Spacing))) && strcmp(myInfo.Type,'deformation_field') && Field_load)
        Field_load = 0;
        disp('Warning: this field has different spatial properties than workspace images!')
        if(~handles.auto_mode)
            Choice = questdlg(['This field (',myFieldName,') has different spatial properties than workspace images'], ...
                'Choose', ...
                'Load as data','Convert to field in workspace','Load as data');
            if(strcmp(Choice,'Load as data'))
                Data_load = 1;
                Convert = 0;
            elseif(strcmp(Choice,'Convert to field in workspace'))
                Data_load = 1;
                Convert = 1;
            end
        else
            Data_load = 1;
            Convert = 1;
        end
    end
end
if(isempty(myRigidPreDef)&&isempty(myDeformableDef)&&isempty(myRigidPostDef))
    merge_rigid_and_deformable = 1;
elseif(not(Convert) && not(isempty(myDeformableDef)) && not(isempty(myRigidPreDef)&&isempty(myRigidPostDef)))
    if(~handles.auto_mode)
        Choice = questdlg(['Pre/post rigid transformation are associated with this deformation field (',myFieldName,') . Would you like to:'], ...
            'Choose', ...
            'Merge', 'Import separately','Cancel','Merge');
        if(strcmp(Choice,'Merge'))
            merge_rigid_and_deformable = 1;
        elseif(strcmp(Choice,'Import separately'))
            merge_rigid_and_deformable = 0;
        elseif(strcmp(Choice,'Cancel'))
            return
        end
    end
elseif(Convert && not(isempty(myRigidPreDef)&&isempty(myDeformableDef)&&isempty(myRigidPostDef)))
    merge_rigid_and_deformable = 0;
end
myFields = cell(0);
myInfos = cell(0);
myFieldNames = cell(0);
if(not(merge_rigid_and_deformable))
    if(not(isempty(myRigidPreDef)))
        myFields{length(myFields)+1} = myRigidPreDef;
        myInfos{length(myInfos)+1} = myInfo;
        myInfos{length(myInfos)}.Type = 'rigid_transform';
        myFieldNames{length(myFieldNames)+1} = [myFieldName,'_pre'];
    end
    if(not(isempty(myDeformableDef)))
        myFields{length(myFields)+1} = myDeformableDef;
        myInfos{length(myInfos)+1} = myInfo;
        myFieldNames{length(myFieldNames)+1} = myFieldName;
    end
    if(not(isempty(myRigidPostDef)))
        myFields{length(myFields)+1} = myRigidPostDef;
        myInfos{length(myInfos)+1} = myInfo;
        myInfos{length(myInfos)}.Type = 'rigid_transform';
        myFieldNames{length(myFieldNames)+1} = [myFieldName,'_post'];
    end
else
    myFields{1} = myField;
    myInfos{1} = myInfo;
    myFieldNames{1} = myFieldName;
end
if(Field_load)
    for n=1:length(myFields)
        if(size(myFields{n},5)>1) % 4D dataset
            disp('Adding fields to the list...')
            for i=1:size(myFields{n},5)
                myPhaseName = check_existing_names(myFieldNames{n},handles.fields.name);
                handles.fields.name{length(handles.fields.name)+1} = myPhaseName;
                handles.fields.data{length(handles.fields.data)+1} = single(myFields{n}(:,:,:,:,i));
                handles.fields.info{length(handles.fields.info)+1} = myInfos{n};
            end
        else
            disp('Adding field to the list...')
            myFieldNames{n} = check_existing_names(myFieldNames{n},handles.fields.name);
            handles.fields.name{length(handles.fields.name)+1} = myFieldNames{n};
            handles.fields.data{length(handles.fields.data)+1} = single(myFields{n});
            handles.fields.info{length(handles.fields.info)+1} = myInfos{n};
        end
    end
elseif(Data_load)
    myDataNames = myFieldNames;
    for n=1:length(myFields)
        myDataNames{n} = check_existing_names(myFieldNames{n},handles.mydata.name);
        disp(['Adding data (',myDataNames{n},') to the list...'])
        handles.mydata.name{length(handles.mydata.name)+1} = myDataNames{n};
        handles.mydata.data{length(handles.mydata.data)+1} = single(myFields{n});
        handles.mydata.info{length(handles.mydata.info)+1} = myInfos{n};
    end
    if(Convert==1)
        for n=1:length(myFields)
            disp(['Converting data (',myDataNames{n},') to field...'])
            handles = Data2field(myDataNames{n},myFieldNames{n},handles);
            disp('Removing data from the list...')
            handles = Remove_data(myDataNames{n}, handles);
            if(n>1 && merge_rigid_and_deformable)
                disp('Compositon with previous transformation...')
                handles.fields.name{length(handles.fields.name)} = [myFieldNames{n},'_temp'];
                handles = Composition(myFieldNames{n-1},[myFieldNames{n},'_temp'],myFieldNames{n},handles);
                handles = Remove_field(myFieldNames{n-1}, handles);
                handles = Remove_field([myFieldNames{n},'_temp'], handles);
            end
        end
    end
end
