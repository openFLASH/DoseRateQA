%% save_Transform
% Save to disk a rigid transform |outdata|.
%
%% Syntax
% |info = save_Transform(outdata,info,outname,format)|
%
%% Description
% |info = save_Transform(outdata,info,outname,format)| Save the transform on disk at the specified format.
%
%% Input arguments
% |outdata| _MATRIX of SCALAR_ |data| is the transformation matrix.
%
% |info| - _STRUCTURE_ - Meta information from the DICOM file that will be saved to the file
%
% |outname| - _STRING_ - Name of the file in which the transform should be saved
%
% |format| - _STRING_ -   Format to use to save the file. The options are: 
%
% * 'dcm' : DICOM file
% * 'mat' : Matlab binary file
% * 'txt': text file 
%
%% Output arguments
%
% |info| - _STRUCTURE_ - Meta information from the DICOM file. Some fields have been updated.
%
%% Contributors
% Authors : G.Janssens, J.Orban (open.reggui@gmail.com)

function info = save_Transform(outdata,info,outname,format)

current_dir = pwd;
[dirname,imname] = fileparts(outname);
try
    cd(dirname);
catch
    disp('Unknown path directory. Writing transform in current folder...')
    dirname = current_dir;
end
imname = strrep(imname,' ','_');

% try
    switch format
        case 'dcm' % Export in Dicom format
                        
            % Initialize dicom header
            myMeta = struct;
            if(isfield(info,'OriginalHeader'))
                if(not(isempty(info.OriginalHeader)))
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
            
            % meta info
            Date = datestr(now,'yyyymmdd');
            Time = datestr(now,'HHMMSS');
            if(not(isfield(myMeta,'StudyDescription')))
                myMeta.StudyDescription = 'REGGUI simulation';
            end
            if(not(isfield(myMeta,'StudyDate')))
                myMeta.StudyDate = Date;
            end
            if(not(isfield(myMeta,'StudyTime')))
                myMeta.StudyTime = Time;
            end
            if(not(isfield(myMeta,'StudyInstanceUID')))
                myMeta.StudyInstanceUID = info.StudyInstanceUID;
            end
            myMeta.SeriesDescription = 'REGGUI correction vector';
            myMeta.SeriesInstanceUID = dicomuid;
            myMeta.SeriesNumber = '';
            myMeta.SeriesDate           = Date;
            myMeta.SeriesTime           = Time;
            myMeta.InstanceCreationDate = Date;
            myMeta.InstanceCreationTime = Time;  
            myMeta.Modality = 'REG';
            
            % reset content info
            myMeta.ContentLabel = '';
            myMeta.ContentDescription = '';
            
            % patient info
            myMeta.PatientID = info.PatientID;
            if(isfield(info,'OriginalHeader'))
                myMeta.PatientID = info.OriginalHeader.PatientID;
                myMeta.PatientName = info.OriginalHeader.PatientName;
                if(isfield(info.OriginalHeader,'PatientBirthDate'))
                    myMeta.PatientBirthDate = info.OriginalHeader.PatientBirthDate;
                end
                if(isfield(info.OriginalHeader,'PatientSex'))
                    myMeta.PatientSex = info.OriginalHeader.PatientSex;
                end
                if(isfield(info.OriginalHeader,'PatientPosition'))
                    myMeta.PatientPosition = info.OriginalHeader.PatientPosition;
                end
            end
            myMeta.ImagePositionPatient = info.ImagePositionPatient;
            myMeta.ImageOrientationPatient = info.PatientOrientation;            
            if(isempty(info.FrameOfReferenceUID))
                myMeta.FrameOfReferenceUID = dicomuid;
                info.FrameOfReferenceUID = myMeta.FrameOfReferenceUID;
            else
                myMeta.FrameOfReferenceUID = info.FrameOfReferenceUID;
            end            
                        
            % registration-specific info
            myMeta.RegistrationSequence.Item_1 = struct;
            if(isfield(info,'FrameOfReferenceUID'))
                myMeta.RegistrationSequence.Item_1.FrameOfReferenceUID = info.FrameOfReferenceUID;
            end
            if(isfield(info,'ReferencedSeriesSequence'))
                myMeta.ReferencedSeriesSequence.Item_1.SeriesInstanceUID = info.ReferencedSeriesSequence.Item_1.SeriesInstanceUID;
            end
            
            % transform            
            outdata = rigid_trans_inversion(outdata); % rigid-only dicom are inverted
            transform4x4 = diag(ones(1,4));
            transform4x4(1:3,4) = outdata(2,:)';
            transform4x4(1:3,1:3) = outdata(3:5,:);
            transform = reshape(transform4x4',[16,1]);
            myMeta.RegistrationSequence.Item_1.MatrixRegistrationSequence.Item_1.MatrixSequence.Item_1.FrameOfReferenceTransformationMatrixType = 'RIGID';
            myMeta.RegistrationSequence.Item_1.MatrixRegistrationSequence.Item_1.MatrixSequence.Item_1.FrameOfReferenceTransformationMatrix = transform;
            
            % write dicom file
            cd(dirname);
            try
                dicomwrite([],[imname,'.dcm'],myMeta,'CreateMode','Copy');
            catch ME
                disp('Error while trying to write dicom file ! Abort...');
                cd(current_dir)
                rethrow(ME);
            end
            
            info.OriginalHeader = myMeta;
            
        case 'mat' % Export as .mat
            outdata(1,:) = outdata(1,:).*info.Spacing';
            out = struct;
            out.data = outdata;
            out.info = info;
            save(outname,'out');
        case 'txt' % Export as txt file            
                outdata(1,:) = outdata(1,:).*info.Spacing';
                try
                    fid = fopen(strcat(outname,'.txt'),'w');
                    for i=1:size(outdata,1)
                        for j=1:size(outdata,2)
                            fprintf(fid,'%d',outdata(i,j));
                            fprintf(fid,'\n');
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
% catch ME
%     disp('Error occured during transform export!')
%     cd(current_dir)
%     rethrow(ME);
% end
cd(current_dir)
