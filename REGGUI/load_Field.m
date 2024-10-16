%% load_Field
% Load from file the information about transformation field. The field can be a rigid transform, a deformation field or a composition of both.
% An additional rigid transformation |myDeformableDef| can be applied before or after (depending on "PreDeformationMatrixRegistrationSequence" or "PostDeformationMatrixRegistrationSequence") the deformation field. It is stored as a "FrameOfReferenceTransformationMatrix" in the file.
% The final deformation field |myField| is the combination of the rigid pre-tranform, the deformation field and the rigid post-transform (see |linear_deformation|).
%
%% Syntax
% |[myField,myInfo,myRigidPreDef,myDeformableDef,myRigidPostDef] = load_Field(myFieldDir,myFieldFilename,format)|
%
%
%% Description
% |[myField,myInfo,myRigidPreDef,myDeformableDef,myRigidPostDef] = load_Field(myFieldDir,myFieldFilename,format)| Load the deformation fields and the pre and post rigid transforms.
%
%
%% Input arguments
% |myFieldDir| - _STRING_ - the directory on disk holding the deformation field.
%
% |myFieldFilename| - _STRING_ - the deformation field filename.
%
% |format| - _STRING_ - Specify the format of the file to load:
%
% * 'dcm'  : DICOM Serie
% * 'mat'  : MATLAB Files
% * 'mhd'  : Meta Image Files
% * 'txt'  : TEXT Files
%
%
%% Output arguments
%
% |myField| _MATRIX of SCALAR_ Deformation field resulting of the combination of the rigid pre-transform, the deformation field and the rigid post-transform. |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
%
% |myInfo| - _STRUCTURE_ DICOM Information about the field. If the field is loaded from a DICOM file, the DICOM information is updated.
%
% * |myInfo.Type| - _STRING_ - Type of transformation field. The options are: 'rigid_transform', 'deformation_field'
%
% |myRigidPreDef| - _SCALAR MATRIX_ -  Additional rigid transformation applied BEFORE the deformation field. "PreDeformationMatrixRegistrationSequence"
%
% * ---- |rigid_transform(1,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in pixels) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * -----|rigid_transform(2,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * -----|rigid_transform(3-5,:)| - _SCALAR VECTOR_ Rotation matrix 3x3 matrix
%
% |myDeformableDef| _MATRIX of SCALAR_ Deformation field. |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
%
% |myRigidPostDef| - _SCALAR MATRIX_ -  Additional rigid transformation applied AFTER the deformation field. "PostDeformationMatrixRegistrationSequence"
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [myField,myInfo,myRigidPreDef,myDeformableDef,myRigidPostDef] = load_Field(myFieldDir,myFieldFilename,format)

% Authors : G.Janssens, J.Orban, C. Veiga

myField = [];
myInfo = struct;
myRigidPreDef = [];
myDeformableDef = [];
myRigidPostDef = [];
myInfo.ImagePositionPatient = [0;0;0];
myInfo.PatientID = '';
myInfo.FrameOfReferenceUID = '';
myInfo.SOPInstanceUID = '';
myInfo.SeriesInstanceUID = '';
myInfo.SOPClassUID = '';
myInfo.StudyInstanceUID = '';
myInfo.PatientOrientation = [1;0;0;0;1;0];
myInfo.Spacing = [1;1;1];

switch format
    case 'dcm' % DICOM File
        
        % Dicom info
        info = dicominfo(fullfile(myFieldDir,myFieldFilename));
        myInfo.PatientID = info.PatientID;
        myInfo.FrameOfReferenceUID = info.FrameOfReferenceUID;
        myInfo.SOPInstanceUID = info.SOPInstanceUID;
        myInfo.SeriesInstanceUID = info.SeriesInstanceUID;
        myInfo.SOPClassUID = info.SOPClassUID;
        myInfo.StudyInstanceUID = info.StudyInstanceUID;
        
        % if rigid transform ONLY
        if(isfield(info,'RegistrationSequence'))
            myRigidPreDef4x4 = eye(4);
            for n=1:length(fieldnames(info.RegistrationSequence))
                if(isfield(info.RegistrationSequence.(['Item_',num2str(n)]),'MatrixRegistrationSequence'))
                    if(not(isempty(info.RegistrationSequence.(['Item_',num2str(n)]).MatrixRegistrationSequence.Item_1.MatrixSequence)))
                        myRigidPreDef4x4 = myRigidPreDef4x4*reshape(info.RegistrationSequence.(['Item_',num2str(n)]).MatrixRegistrationSequence.Item_1.MatrixSequence.Item_1.FrameOfReferenceTransformationMatrix,[4,4])';
                    end
                end
            end
            myRigidPreDef5x3 = [0 0 0];
            if(not(isempty(myRigidPreDef4x4)))
                myRigidPreDef5x3(2,:) = myRigidPreDef4x4(1:3,4)';
                myRigidPreDef5x3(3:5,:) = myRigidPreDef4x4(1:3,1:3);
            else
                myRigidPreDef5x3(2:5,:)=[0 0 0;1 0 0;0 1 0;0 0 1];
            end
            % rigid-only dicom are inverse of rig-deformable dicom
            myRigidPreDef5x3 = rigid_trans_inversion(myRigidPreDef5x3);
            myField = myRigidPreDef5x3;
            
            myInfo.Type = 'rigid_transform';
        end
        
        %if deformable registration
        if(isfield(info,'DeformableRegistrationSequence'))
            myInfo.ImagePositionPatient = info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.ImagePositionPatient;
            myInfo.ImageOrientationPatient = info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.ImageOrientationPatient;
            myInfo.Spacing = info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.GridResolution;
            myInfo.Type = 'deformation_field';
            
            myDeformableDef = reshape(single(info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.VectorGridData),[3,info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.GridDimensions']);
            for n=1:3
                myDeformableDef(n,:,:,:) = myDeformableDef(n,:,:,:)/myInfo.Spacing(n);
            end
            myField = myDeformableDef;
            
            % Pre rigid transform
            if(isfield(info.DeformableRegistrationSequence.Item_1,'PreDeformationMatrixRegistrationSequence'))
                if(not(isempty(info.DeformableRegistrationSequence.Item_1.PreDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrix)))
                    myRigidPreDef4x4 = reshape(info.DeformableRegistrationSequence.Item_1.PreDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrix,[4,4])';
                else
                    myRigidPreDef4x4 = [];
                end
                myRigidPreDef5x3 = [0 0 0];
                if(not(isempty(myRigidPreDef4x4)))
                    myRigidPreDef5x3(2,:) = myRigidPreDef4x4(1:3,4)';
                    myRigidPreDef5x3(3:5,:) = myRigidPreDef4x4(1:3,1:3);
                else
                    myRigidPreDef5x3(2:5,:)=[0 0 0;1 0 0;0 1 0;0 0 1];
                end
            end
            if(not(sum(sum(myRigidPreDef5x3(2:5,:)==[0 0 0;1 0 0;0 1 0;0 0 1]))>=12))% if not identity transform
                disp('Pre rigid transformation found...')
                preField = rigid_trans_to_def_field(myRigidPreDef5x3,info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.GridDimensions,myInfo.Spacing,myInfo.ImagePositionPatient);
                myField(1,:,:,:) = linear_deformation(squeeze(preField(1,:,:,:)), ' ', myDeformableDef, []) + squeeze(myDeformableDef(1,:,:,:));
                myField(2,:,:,:) = linear_deformation(squeeze(preField(2,:,:,:)), ' ', myDeformableDef, []) + squeeze(myDeformableDef(2,:,:,:));
                myField(3,:,:,:) = linear_deformation(squeeze(preField(3,:,:,:)), ' ', myDeformableDef, []) + squeeze(myDeformableDef(3,:,:,:));
                myRigidPreDef = myRigidPreDef5x3;
            end
            
            % Post rigid transform
            if(isfield(info.DeformableRegistrationSequence.Item_1,'PostDeformationMatrixRegistrationSequence'))
                if(not(isempty(info.DeformableRegistrationSequence.Item_1.PostDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrix)))
                    myRigidPostDef4x4 = reshape(info.DeformableRegistrationSequence.Item_1.PostDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrix,[4,4])';
                else
                    myRigidPostDef4x4 = [];
                end
                myRigidPostDef5x3 = [0 0 0];
                if(not(isempty(myRigidPostDef4x4)))
                    myRigidPostDef5x3(2,:) = myRigidPostDef4x4(1:3,4)';
                    myRigidPostDef5x3(3:5,:) = myRigidPostDef4x4(1:3,1:3);
                else
                    myRigidPostDef5x3(2:5,:)=[0 0 0;1 0 0;0 1 0;0 0 1];
                end
            end
            if(not(sum(sum(myRigidPostDef5x3(2:5,:)==[0 0 0;1 0 0;0 1 0;0 0 1]))>=12))% if not identity transform
                disp('Post rigid transformation found...')
                postField = rigid_trans_to_def_field(myRigidPostDef5x3,info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.GridDimensions,myInfo.Spacing,myInfo.ImagePositionPatient);
                myField(1,:,:,:) = linear_deformation(squeeze(myField(1,:,:,:)), ' ', postField, []) + squeeze(postField(1,:,:,:));
                myField(2,:,:,:) = linear_deformation(squeeze(myField(2,:,:,:)), ' ', postField, []) + squeeze(postField(2,:,:,:));
                myField(3,:,:,:) = linear_deformation(squeeze(myField(3,:,:,:)), ' ', postField, []) + squeeze(postField(3,:,:,:));
                myRigidPostDef = myRigidPostDef5x3;
            end
            
            for n=1:3
                myField(n,:,:,:) = myField(n,:,:,:)*myInfo.Spacing(n);
            end
            
            info.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.VectorGridData = [];% empties vector data for storing dicom header only
        end
        
        % Save original dicom header
        myInfo.OriginalHeader = info;
    case 'mat' % Mat File
        try
            firstdata = whos('-file',fullfile(myFieldDir,myFieldFilename));
            myField = load(fullfile(myFieldDir,myFieldFilename));
            eval(['myField = myField.',firstdata.name,';']);
            if(isstruct(myField))
                myInfo = myField.info;
                myField = myField.data;
            else % Old versions...
                for n=1:3
                    myField(n,:,:,:) = myField(n,:,:,:)/myInfo.Spacing(n);
                end
                myInfo.Type = 'deformation_field';
            end
        catch ME
            disp('Error : not a valid mat file !')
            rethrow(ME);
        end
    case 'mhd' % META File
        try
            temp_mha = open_meta(myFieldDir,myFieldFilename);
            myInfo.Spacing = temp_mha.dspa;
            myInfo.ImagePositionPatient = temp_mha.zoff;
            if(size(temp_mha.dval,5)>1) % 4D field
                myField = flipdim(permute(temp_mha.dval,[5 1 2 3 4]),3);
            else
                myField = flipdim(permute(temp_mha.dval,[4 1 2 3]),3);
            end
            if(ndims(myField)>2)
                myInfo.Type = 'deformation_field';
            else
                error('Error : this is not a deformation field');
            end
            disp('Warning: Patient Orientation is not guaranteed through meta files!');
            clear temp_mha;
        catch ME
            disp('Error while reading field as a meta file')
            rethrow(ME);
        end
    case 'txt' % Text File
        try
            myField = load(fullfile(myFieldDir,myFieldFilename));
            x_length = myField(1);
            y_length = myField(2);
            z_length = myField(3);
            dims = 3 - double(z_length==1);
            if(length(myField)==dims*x_length*y_length*z_length)
                myInfo.Spacing = [myField(4);myField(5);myField(6)];
                myField = myField(7:end);
                myField = single(reshape(myField,dims,x_length,y_length,z_length));
                myInfo.Type = 'deformation_field';
            else
                myField = reshape(myField,3,5)';
                myInfo.Type = 'rigid_transform';
            end
        catch ME
            disp('Error : not a valid txt file !')
            rethrow(ME);
        end
    otherwise
        error('Unknown type of field. Available input formats are: dcm, mat, mhd, and txt.')
end

if(strcmp(myInfo.Type,'deformation_field'))
    for n=1:size(myField,1)
        myField(n,:,:,:,:) = myField(n,:,:,:,:)/myInfo.Spacing(n);
    end
else
    myField(1,:) = myField(1,:)./myInfo.Spacing';
end

if(~isempty(find(myInfo.Spacing==0)))
    disp('Warning : invalid spacing !')
end

myField = single(myField);
