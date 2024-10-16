%% save_Field
% Save to disk a deformation field |outdata|. An additional rigid transformation |rigidPreDef5x3| can be applied after the deformation field. It will be stored as a "FrameOfReferenceTransformationMatrix".
% The format of the file can be specified.
%
%% Syntax
% |info = save_Field(outdata,info,outname,format)|
%
% |info = save_Field(outdata,info,outname,format,rigidPreDef5x3)|
%
% |info = save_Field(outdata,info,outname,format,rigidPreDef5x3,input_dicom_tags)|
%
%
%% Description
% |info = save_Field(outdata,info,outname,format)| Save the deformation field on disk at the specified format.
%
% |info = save_Field(outdata,info,outname,format,rigidPreDef5x3)| Save the deformation field on disk at the specified format and save the 4x4 matrix descrbing a post-rigid transform.
%
% |info = save_Field(outdata,info,outname,format,rigidPreDef5x3,input_dicom_tags)| Save the deformation field with additional DICOM tags on disk at the specified format and save the 4x4 matrix descrbing a post-rigid transform.
%
%
%
%% Input arguments
% |outdata| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
%
% |info| - _STRUCTURE_ - Meta information from the DICOM file that will be saved to the file
%
% * |info.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|)
% * |info.StudyInstanceUID|
% * |info.OriginalHeader.PatientID|
% * |info.OriginalHeader.PatientName|
% * |info.OriginalHeader.PatientBirthDate|
% * |info.OriginalHeader.PatientSex|
% * |info.ImagePositionPatient|
% * |myMeta.FrameOfReferenceUID|
% * |info.PatientOrientation|
%
% |outname| - _STRING_ - Name of the file in which the field should be saved
%
% |format| - _STRING_ -   Format to use to save the file. The options are:
%
% * 'dcm' : DICOM file
% * 'mat' : Matlab binary file
% * 'mhd' : ITK text format [https://itk.org/Wiki/ITK/File_Formats]
% * 'txt': text file
%
% |rigidPreDef5x3| - _SCALAR MATRIX_ - [OPTIONAL] Matrix describing a rigid transform to be applied before the deformation field
% * |rigid_transform(1,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in pixels) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * |rigid_transform(2,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * |rigid_transform(3-5,:)| - _SCALAR VECTOR_ Rotation matrix 3x3 matrix
%
% |input_dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the file
%
% * |input_dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |input_dicom_tags{i,2}| - _ANY_ Value of the tag
%
%
%% Output arguments
%
% |info| - _STRUCTURE_ - Meta information from the DICOM file. Some fields have been updated.
%
%
%% Contributors
% Authors : G.Janssens, J.Orban (open.reggui@gmail.com)

function info = save_Field(outdata,info,outname,format,rigidPreDef5x3,input_dicom_tags)

current_dir = pwd;
[dirname,imname] = fileparts(outname);
try
    cd(dirname);
catch
    disp('Unknown path directory. Writing field in current folder...')
    dirname = current_dir;
end
imname = strrep(imname,' ','_');

try
    switch format
        case 'dcm' % Export in Dicom format
            
            % Initialize dicom header
            myMeta = struct;
            if isfield(info,'OriginalHeader')
                if not(isempty(info.OriginalHeader))
                    disp(['Using original header information.']);
                    myMeta = info.OriginalHeader;
                    try
                        myMeta = rmfield(myMeta,'ImageType');
                    catch
                    end
                end
            end
            if(length(fieldnames(myMeta))<1)
                disp('Can''t use original header information. Creating new header.');
                dicomwrite([],[imname,'.dcm']);
                myMeta = dicominfo([imname,'.dcm']);
                delete([imname,'.dcm']);
            end
            
            Date = datestr(now,'yyyymmdd');
            Time = datestr(now,'HHMMSS');
            
            % study info
            myMeta.SOPClassUID = '1.2.840.10008.5.1.4.1.1.66.3';
            myMeta.StudyDescription = 'REGGUI simulation';
            myMeta.StudyDate = Date;
            myMeta.StudyTime = Time;
            if not(isfield(myMeta,'StudyInstanceUID'))
                myMeta.StudyInstanceUID = info.StudyInstanceUID;
            end
            myMeta.SeriesDescription = 'REGGUI created data';
            myMeta.SeriesInstanceUID = dicomuid;
            myMeta.SeriesNumber = '';
            myMeta.SeriesDate           = Date;
            myMeta.SeriesTime           = Time;
            myMeta.InstanceCreationDate = Date;
            myMeta.InstanceCreationTime = Time;
            myMeta.Modality = 'REG';
            if(info.Spacing(1)~=info.Spacing(2))
                myMeta.PixelAspectRatio = [round(1e4*info.Spacing(2))/1e4 round(1e4*info.Spacing(1))/1e4];
                info.Spacing(1) = round(1e4*info.Spacing(1))/1e4;
                info.Spacing(2) = round(1e4*info.Spacing(2))/1e4;
            end
            myMeta.PixelSpacing(1) = double(info.Spacing(2));
            myMeta.PixelSpacing(2) = double(info.Spacing(1));
            myMeta.SpacingBetweenSlices = info.Spacing(3);
            
            % reset content info
            myMeta.ContentLabel = '';
            myMeta.ContentDescription = '';
            
            % patient info
            myMeta.PatientID = info.PatientID;
            if isfield(info,'OriginalHeader')
                myMeta.PatientID = info.OriginalHeader.PatientID;
                myMeta.PatientName = info.OriginalHeader.PatientName;
                myMeta.PatientBirthDate = info.OriginalHeader.PatientBirthDate;
                myMeta.PatientSex = info.OriginalHeader.PatientSex;
            end
            myMeta.ImagePositionPatient = info.ImagePositionPatient;
            if (isempty(info.FrameOfReferenceUID))
                myMeta.FrameOfReferenceUID = dicomuid;
                info.FrameOfReferenceUID = myMeta.FrameOfReferenceUID;
            else
                myMeta.FrameOfReferenceUID = info.FrameOfReferenceUID;
            end
            myMeta.ImageOrientationPatient = info.PatientOrientation;
            
            % input dicom data
            if(nargin>5)
                for i=1:size(input_dicom_tags,1)
                    try
                        myMeta.(input_dicom_tags{i,1}) = input_dicom_tags{i,2};
                    catch
                    end
                end
            end
            
            % registration-specific info
            myMeta.DeformableRegistrationSequence.Item_1 = struct;
            myMeta.DeformableRegistrationSequence.Item_1.SourceFrameOfReferenceUID = info.FrameOfReferenceUID;
            % deformable field
            myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1 = struct;
            myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.ImagePositionPatient = info.ImagePositionPatient;
            myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.ImageOrientationPatient = info.PatientOrientation;
            myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.GridDimensions = [size(outdata,2);size(outdata,3);size(outdata,4)];
            myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.GridResolution = info.Spacing;
            for n=1:size(outdata,1)
                outdata(n,:,:,:) = single(outdata(n,:,:,:)*info.Spacing(n));
            end
            myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1.VectorGridData = reshape(single(outdata),[size(outdata,1)*size(outdata,2)*size(outdata,3)*size(outdata,4) 1]);
            % rigid pre-transform
            myMeta.DeformableRegistrationSequence.Item_1.PreDeformationMatrixRegistrationSequence.Item_1 = struct;
            myMeta.DeformableRegistrationSequence.Item_1.PreDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrixType = 'RIGID';
            if(nargin>4 && not(isempty(rigidPreDef5x3)))
                try
                    rigidPreDef4x4 = diag(ones(1,4));
                    rigidPreDef4x4(1:3,4) = rigidPreDef5x3(2,:)';
                    rigidPreDef4x4(1:3,1:3) = rigidPreDef5x3(3:5,:);
                    rigidPreDef = reshape(rigidPreDef4x4',[16,1]);
                catch ME
                    disp('Error in rigid pre-def matrix ! Abort...');
                    cd(current_dir)
                    rethrow(ME);
                end
                myMeta.DeformableRegistrationSequence.Item_1.PreDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrix = rigidPreDef;
            else
                myMeta.DeformableRegistrationSequence.Item_1.PreDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrix = [];
            end
            % rigid post-transform
            myMeta.DeformableRegistrationSequence.Item_1.PostDeformationMatrixRegistrationSequence.Item_1 = struct;
            myMeta.DeformableRegistrationSequence.Item_1.PostDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrixType = 'RIGID';
            myMeta.DeformableRegistrationSequence.Item_1.PostDeformationMatrixRegistrationSequence.Item_1.FrameOfReferenceTransformationMatrix = [];
            
            % write dicom file
            cd(dirname);
            try
                dicomwrite([],[imname,'.dcm'],myMeta,'CreateMode','Copy');
            catch
                myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1 = rmfield(myMeta.DeformableRegistrationSequence.Item_1.DeformableRegistrationGridSequence.Item_1,'VectorGridData');
                try
                    dicomwrite([],[imname,'.dcm'],myMeta,'CreateMode','Copy');
                    disp('Cannot export dicom field. (There might be a problem for writing VectorGridData, if ever ''OF'' variable type is not supported by your Matlab version. If so, you might need to modify ''dicom_add_attr.m'' in order to add ''OF'' in the list of supported types) ...');
                    err = lasterror;
                    disp(['    ',err.message]);
                    disp(err.stack(1));
                    delete([imname,'.dcm']);
                catch ME
                    disp('Error while trying to write dicom file ! Abort...');
                    cd(current_dir)
                    rethrow(ME);
                end
            end
            
            info.OriginalHeader = myMeta;
            
        case 'mat' % Export as .mat
            for n=1:size(outdata,1)
                outdata(n,:,:,:) = outdata(n,:,:,:)*info.Spacing(n);
            end
            out = struct;
            out.data = outdata;
            out.info = info;
            save(outname,'out');
        case 'mhd'
            % raw file name
            imname_raw = [imname,'.raw'];
            imname = [imname,'.mhd'];
            % data type
            for n=1:size(outdata,1)
                outdata(n,:,:,:) = single(outdata(n,:,:,:)*info.Spacing(n));
            end
            % shortcuts
            dims = [size(outdata)';1;1];
            spas = info.Spacing;
            % offsets
            offs = info.ImagePositionPatient;
            % write header file
            fid = fopen(imname,'wt');
            fprintf(fid, 'ObjectType = Image \n');
            ndims = 4;
            fprintf(fid, 'NDims = %i \n',3);
            fprintf(fid, 'BinaryData = %s \n','True');
            fprintf(fid,['DimSize = ',repmat('%i ',1,ndims)],dims(2:ndims));
            fprintf(fid,'\n');
            fprintf(fid, 'ElementNumberOfChannels = %i',dims(1));
            fprintf(fid,'\n');
            fprintf(fid, 'ElementType = %s \n','MET_FLOAT');
            fprintf(fid,['ElementSpacing = ',repmat('%f ',1,ndims)],spas(1:ndims-1));
            fprintf(fid,'\n');
            fprintf(fid,['Offset = ',repmat('%f ',1,ndims)],offs(1:ndims-1));
            fprintf(fid,'\n');
            fprintf(fid,'ElementByteOrderMSB = %s \n','False');
            %fprintf(fid,'ElementDataFile = %s \n',imname_raw);
            fprintf(fid,'ElementDataFile = %s \n',imname_raw);
            fclose(fid);
            % write data file
            fid = fopen(imname_raw,'wb');
            for vec = 1:dims(4)
                tmp = outdata(:,:,:,vec);
                % TODO TO BE CHECKED (look at the image orientation ??) - And
                % TODO change in load_Field as well !!!
                fwrite(fid, tmp,'float');
            end
            fclose(fid);
        case 'txt' % Export as txt file
            for n=1:size(outdata,1)
                outdata(n,:,:,:) = outdata(n,:,:,:)*info.Spacing(n);
            end
            try
                fid = fopen(strcat(outname,'.txt'),'w');
                fprintf(fid,int2str(size(outdata,2)));
                fprintf(fid,'\n');
                fprintf(fid,int2str(size(outdata,3)));
                fprintf(fid,'\n');
                fprintf(fid,int2str(size(outdata,4)));
                fprintf(fid,'\n');
                fprintf(fid,int2str(info.Spacing(1)));
                fprintf(fid,'\n');
                fprintf(fid,int2str(info.Spacing(2)));
                fprintf(fid,'\n');
                fprintf(fid,int2str(info.Spacing(3)));
                fprintf(fid,'\n');
                for i=1:size(outdata,4)
                    for j=1:size(outdata,3)
                        for k=1:size(outdata,2)
                            for dim=1:size(outdata,1)
                                fprintf(fid,'%d',outdata(dim,k,j,i));
                                fprintf(fid,'\n');
                            end
                        end
                    end
                end
                fclose(fid);
            catch ME
                disp('Error occured !')
                cd(current_dir)
                rethrow(ME);
            end
        otherwise
            error('Invalid type. Available output formats are: dcm, mat, mhd, and txt.')
    end
catch ME
    disp('Error occured during field export!')
    cd(current_dir)
    rethrow(ME);
end
cd(current_dir)
