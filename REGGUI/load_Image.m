%% load_Image
% Load an image from file. Different file formats are supported
%
%% Syntax
% |[myImage,myInfo] = load_Image(myImageDir,myImageFilename,format,correct_dcm)|
%
%
%% Description
% |[myImage,myInfo] = load_Image(myImageDir,myImageFilename,format,correct_dcm)| Load the image from file
%
%
%% Input arguments
% |myImageDir| - _STRING_ - Name of the folder containing the image
%
% |myImageFilename| - _STRING_ - Name of the image file
%
% |format| - _STRING_ - Specify the format of the file:
%
% * 'dcm' : 3D DICOM Files
% * 'dose' : 3D Dose Files
% * 'mat' : Matlab Files
% * 'hdr' : Analyze75 Files
% * 'mhd' : Meta Image Files
% * 'png','jpg','opg' : 2D image Files
% * 'nii' : Read NIfTI image
%
% |correct_dcm| - _INTEGER_ - (Optional) Specify whether dicom inconsistencies must be corrected. Potential values are:
% * -1 : ask the user (pop-up)
% * 0: no correction
% * 1: corrections
%
%% Output arguments
%
% |myImage| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Contributors
% Authors : G.Janssens, J.Orban (open.reggui@gmail.com)

function [myImage,myInfo,correct_dcm] = load_Image(myImageDir,myImageFilename,format,correct_dcm)

if(nargin<4)
    correct_dcm = 0;
end

Spacings = [];
Origin = [];
PatientID = [];
FrameOfReferenceUID = [];
SOPInstanceUID = [];
SeriesInstanceUID = [];
SOPClassUID = [];
StudyInstanceUID = [];
PatientOrientation=[];
OriginalHeader=[];
StandardOrientation = [1;0;0;0;1;0];
myInfo = struct;

switch format
    case 'dcm' % 3D DICOM Files
        try
            if(isdir(fullfile(myImageDir,myImageFilename)))
                files = dir_without_hidden(fullfile(myImageDir,myImageFilename));
                myImageInfo = dicominfo(fullfile(fullfile(myImageDir,myImageFilename),files(floor(length(files)/2)).name));
                pet_image = strcmp(myImageInfo.Modality,'PT');
                dose_image = isDoseOrDoseRate(myImageInfo.Modality);
                if (dose_image)
                    dose_image = dose_image + (size(dicomread(fullfile(fullfile(myImageDir,myImageFilename),files(floor(length(files)/2)).name)),4)>1);
                end
                def_field = 0;
            else
                myImageInfo = dicominfo(fullfile(myImageDir,myImageFilename));
                pet_image = strcmp(myImageInfo.Modality,'PT');
                dose_image = isDoseOrDoseRate(myImageInfo.Modality);
                if (dose_image)
                    dose_image = dose_image + (size(dicomread(fullfile(myImageDir,myImageFilename)),4)>1);
                end
                def_field = strcmp(myImageInfo.Modality,'REG');
            end
        catch
            pet_image = 0;
            dose_image = 0;
            def_field = 0;
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
        try
            if(pet_image)
                [myImage,myImageInfo] = load_PET_serie(fullfile(myImageDir,myImageFilename));
            elseif(dose_image)
                if(dose_image==1)
                    [myImage,myImageInfo] = load_Dose_serie(fullfile(myImageDir,myImageFilename));
                elseif(dose_image==2)
                    [myImage,myImageInfo] = load_Dose(fullfile(myImageDir,myImageFilename));
                else
                    return
                end
            elseif(def_field)
                [myImage,myInfo] = load_Field(myImageDir,myImageFilename,format);
                return
            else
                [myImage,myImageInfo,correct_dcm] = load_3D_DICOM(fullfile(myImageDir,myImageFilename),correct_dcm);
            end
            Spacings = myImageInfo.Spacing;
            Origin = myImageInfo.ImagePositionPatient;
            PatientID = myImageInfo.PatientID;
            FrameOfReferenceUID = myImageInfo.FrameOfReferenceUID;
            SOPInstanceUID = myImageInfo.SOPInstanceUID;
            SeriesInstanceUID = myImageInfo.SeriesInstanceUID;
            SOPClassUID = myImageInfo.SOPClassUID;
            StudyInstanceUID = myImageInfo.StudyInstanceUID;
            PatientOrientation = myImageInfo.ImageOrientationPatient;
            OriginalHeader = myImageInfo.OriginalHeader;
        catch ME
            disp('Error while reading image as a 3D dicom serie')
            rethrow(ME);
        end
    case 'dose' % 3D Dose Files
        try
            [myImage,myImageInfo] = load_Dose(fullfile(myImageDir,myImageFilename));
            Spacings = myImageInfo.Spacing;
            Origin = myImageInfo.ImagePositionPatient;
            PatientID = myImageInfo.PatientID;
            FrameOfReferenceUID = myImageInfo.FrameOfReferenceUID;
            SOPInstanceUID = myImageInfo.SOPInstanceUID;
            SeriesInstanceUID = myImageInfo.SeriesInstanceUID;
            SOPClassUID = myImageInfo.SOPClassUID;
            StudyInstanceUID = myImageInfo.StudyInstanceUID;
            PatientOrientation = myImageInfo.ImageOrientationPatient;
            OriginalHeader = myImageInfo.OriginalHeader;
        catch ME
            disp('Error while reading image as a dicom dose image')
            rethrow(ME);
        end
    case 'mat' % Matlab Files
        try
            firstdata = whos('-file',fullfile(myImageDir,myImageFilename));
            myData = load(fullfile(myImageDir,myImageFilename));
            eval(['myData = myData.',firstdata.name,';']);
            if(isstruct(myData)) % .mat is in new the new format containing header info
                Spacings = myData.info.Spacing;
                Origin = myData.info.ImagePositionPatient;
                PatientID = myData.info.PatientID;
                if(isfield(myData.info,'FrameOfReferenceUID'))
                    FrameOfReferenceUID = myData.info.FrameOfReferenceUID;
                else
                    FrameOfReferenceUID = dicomuid;
                end
                if(isfield(myData.info,'SOPInstanceUID'))
                    SOPInstanceUID = myData.info.SOPInstanceUID;
                end
                if(isfield(myData.info,'SeriesInstanceUID'))
                    SeriesInstanceUID = myData.info.SeriesInstanceUID;
                else
                    SeriesInstanceUID = dicomuid;
                end
                if(isfield(myData.info,'SOPClassUID'))
                    SOPClassUID = myData.info.SOPClassUID;
                else
                    SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
                end
                if(isfield(myData.info,'StudyInstanceUID'))
                    StudyInstanceUID = myData.info.StudyInstanceUID;
                else
                    StudyInstanceUID = dicomuid;
                end
                PatientOrientation = myData.info.PatientOrientation;
                if isfield(myData.info,'OriginalHeader')
                    OriginalHeader = myData.info.OriginalHeader;
                    disp('Original Header loaded');
                end
                myImage = myData.data;
                % if data is a string, try to open raw data from this file
                if(isfield(myData.info,'Size'))
                    if(exist(fullfile(myImageDir,myData.data),'file'))
                        try
                            fid=fopen(fullfile(myImageDir,myData.data));%,'rb','b');
                            try
                                data=fread(fid,inf,'single');
                                myImage=single(reshape(data,myData.info.Size(1),myData.info.Size(2),myData.info.Size(3)));
                            catch
                                fclose(fid);
                                try
                                    fid=fopen(fullfile(myImageDir,myData.data));%,'rb','b');
                                    data=fread(fid,inf,'uint16');
                                    myImage=single(reshape(data,myData.info.Size(1),myData.info.Size(2),myData.info.Size(3)));
                                    modality = '';
                                    if(isfield(myData.info,'OriginalHeader'))
                                        if(strcmp(OriginalHeader.Modality,'CT'))
                                            myImage = myImage - 1024;
                                        end
                                    end
                                catch ME
                                    disp('Error while reading raw image file')
                                    rethrow(ME);
                                end
                            end
                            fclose(fid);
                        catch ME
                            disp('Error while opening raw image file')
                            rethrow(ME);
                        end
                        myImage = myImage(:,:,end:-1:1);
                    end
                end
            else% .mat is in the old format only containing the image
                Spacings = [1;1;1];
                Origin = [0;0;0];
                PatientID = '';
                FrameOfReferenceUID = dicomuid;
                SeriesInstanceUID = dicomuid;
                SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
                StudyInstanceUID = dicomuid;
                PatientOrientation = StandardOrientation;
                myImage = myData;
            end
        catch ME
            disp('Error while reading image as a mat file')
            rethrow(ME);
        end
    case 'hdr' % Analyze75 Files
        try
            %myImageInfo = analyze75info(fullfile(myImageDir,myImageFilename));
            myImage = analyze75read(fullfile(myImageDir,myImageFilename));
            %%TO BE CHANGED
            disp('Warning: Analyze format is not properly supported for the moment! There will probably be spacing and origin problems!');
            Spacings = [1;1;1];
            Origin = [0;0;0];
            PatientID = '';
            FrameOfReferenceUID = dicomuid;
            %             for isli = 1:size(myImage,3)
            %                 SOPInstanceUID(isli).SOPInstanceUID = dicomuid;
            %             end
            SeriesInstanceUID = dicomuid;
            SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
            StudyInstanceUID = dicomuid;
            PatientOrientation = StandardOrientation;
        catch ME
            disp('Error while reading image as a hdr file')
            rethrow(ME);
        end
    case 'mhd' % Meta Image Files
        try
            meta_info = mha_read_header(fullfile(myImageDir,myImageFilename));
            myImage = mha_read_volume(meta_info);
            if(isfield(meta_info,'PixelDimensions'))
                Spacings = meta_info.PixelDimensions';
            else
                Spacings = [1;1;1];
            end
            if(isfield(meta_info,'Offset'))
                Origin = meta_info.Offset';
            else
                Origin = [0;0;0];
            end
            FrameOfReferenceUID = dicomuid;
            SeriesInstanceUID = dicomuid;
            SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
            StudyInstanceUID = dicomuid;
            PatientOrientation = StandardOrientation;
        catch ME
            disp('Error while reading image as a mha/mhd file')
            rethrow(ME);
        end
    case 'nifti'
        try
            meta_info = nii_read_header(fullfile(myImageDir,myImageFilename));
            myImage = nii_read_volume(meta_info);
            if(isfield(meta_info,'PixelDimensions'))
                Spacings = meta_info.PixelDimensions(1:3);
            else
                Spacings = [1;1;1];
            end
            if(isfield(meta_info,'QoffsetX') && isfield(meta_info,'QoffsetY') && isfield(meta_info,'QoffsetZ'))
                Origin = [meta_info.QoffsetX;meta_info.QoffsetY;meta_info.QoffsetZ];
            else
                Origin = [0;0;0];
            end
            FrameOfReferenceUID = dicomuid;
            SeriesInstanceUID = dicomuid;
            SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
            StudyInstanceUID = dicomuid;
            PatientOrientation = StandardOrientation;
        catch ME
            disp('Error while reading image as a NifTi file')
            rethrow(ME);
        end
    case '2d' % 2D image Files
        if(strcmp(myImageFilename(end-3:end),'.opg'))
            try
                [myImage,myInfo] = load_OPG(myImageDir,myImageFilename);
                Spacings = myInfo.Spacing;
                Origin = myInfo.ImagePositionPatient;
                PatientID = '';
                FrameOfReferenceUID = myInfo.FrameOfReferenceUID;
                SeriesInstanceUID = myInfo.SeriesInstanceUID;
                SOPClassUID = myInfo.SOPClassUID;
                StudyInstanceUID = myInfo.StudyInstanceUID;
                PatientOrientation = StandardOrientation;
            catch ME
                disp('Error while reading image as OPG')
                rethrow(ME);
            end
        elseif (strcmp(myImageFilename(end-3:end),'.dcm'))
            try
                myImage = single(dicomread(fullfile(myImageDir,myImageFilename))');
                myInfo = dicominfo(fullfile(myImageDir,myImageFilename));
                Spacings = [myInfo.PixelSpacing;1];
                Origin = myInfo.ImagePositionPatient;
                PatientID = myInfo.PatientID;
                FrameOfReferenceUID = myInfo.FrameOfReferenceUID;
                SOPInstanceUID = myInfo.SOPInstanceUID;
                SeriesInstanceUID = myInfo.SeriesInstanceUID;
                SOPClassUID = myInfo.SOPClassUID;
                StudyInstanceUID = myInfo.StudyInstanceUID;
                PatientOrientation = myInfo.ImageOrientationPatient;
                OriginalHeader = myInfo;
            catch ME
                disp('Error while reading image as 2D dicom')
                rethrow(ME);
            end
        else
            try
                myImage = uint8(imread(fullfile(myImageDir,myImageFilename)));
                if (ndims(myImage)>2)
                    myImage = rgb2gray(myImage);
                end
                myImage = single(myImage');
                Spacings = [1;1;1];
                Origin = [0;0;0];
                PatientID = '';
                FrameOfReferenceUID = dicomuid;
                SeriesInstanceUID = dicomuid;
                SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
                StudyInstanceUID = dicomuid;
                PatientOrientation = StandardOrientation;
            catch ME
                disp('Error while reading image as common 2D image')
                rethrow(ME);
            end
        end
    case 'nii' %Read NIfTI image
        try
            myImage = niftiread(fullfile(myImageDir,myImageFilename));
            myImage = flipdim(myImage,2);
            %%TO BE CHANGED
            disp('Warning: nii format is not properly supported for the moment! There will probably be spacing and origin problems!');
            Spacings = [1;1;1];
            Origin = [0;0;0];
            PatientID = '';
            FrameOfReferenceUID = dicomuid;
            SeriesInstanceUID = dicomuid;
            SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
            StudyInstanceUID = dicomuid;
            PatientOrientation = StandardOrientation;
        catch ME
            disp('Error while reading image as a hdr file')
            rethrow(ME);
        end


    otherwise
        try
            if(isdir(fullfile(myImageDir,myImageFilename)))
                files = dir_without_hidden(fullfile(myImageDir,myImageFilename));
                myImageInfo = dicominfo(fullfile(fullfile(myImageDir,myImageFilename),files(floor(length(files)/2)).name));
                pet_image = strcmp(myImageInfo.Modality,'PT');
            else
                myImageInfo = dicominfo(fullfile(myImageDir,myImageFilename));
                pet_image = strcmp(myImageInfo.Modality,'PT');
            end
        catch
            pet_image = 0;
        end
        try
            if(pet_image)
                try
                    [myImage,myImageInfo] = load_PET_serie(fullfile(myImageDir,myImageFilename));
                catch
                    err = lasterror;
                    disp(['    ',err.message]);
                    disp(err.stack(1));
                end
            else
                [myImage,myImageInfo,correct_dcm] = load_3D_DICOM(fullfile(myImageDir,myImageFilename),correct_dcm);
            end
            Spacings = myImageInfo.Spacing;
            Origin = myImageInfo.ImagePositionPatient;
            PatientID = myImageInfo.PatientID;
            FrameOfReferenceUID = myImageInfo.FrameOfReferenceUID;
            SOPInstanceUID = myImageInfo.SOPInstanceUID;
            SeriesInstanceUID = myImageInfo.SeriesInstanceUID;
            SOPClassUID = myImageInfo.SOPClassUID;
            StudyInstanceUID = myImageInfo.StudyInstanceUID;
            PatientOrientation = myImageInfo.ImageOrientationPatient;
            OriginalHeader = myImageInfo.OriginalHeader;
        catch ME
            disp('This file is not part of a 3D dicom serie')
            rethrow(ME);
        end
end

% Check patient orientation
if(not(sum(abs(PatientOrientation))==2 && sum(PatientOrientation==0)==4))% Non-orthogonal image orientation
    disp(['Resampling image to convert from orientation [',num2str(PatientOrientation'),'] into [',num2str(round(StandardOrientation')),']']);
    x = PatientOrientation(1:3);
    y = PatientOrientation(4:6);
    z = cross(x,y);
    R = [x';y';z'];
    T = Origin - R*Origin;
    transform = [0,0,0;...
        T';...
        R];
    myImage = rigid_deformation(myImage,transform,Spacings,Origin);
    PatientOrientation = StandardOrientation;

elseif(sum(PatientOrientation == StandardOrientation)<6) % Orthogonal but non-standard orientations
    disp('Non standard image orientation: apply coordinate transformation.');
    % Re-order dimensions
    v1 = PatientOrientation(1:3);
    v2 = PatientOrientation(4:6);
    dims = [find(v1),find(v2),6-find(v1)-find(v2)];
    myImage = permute(myImage,dims);
    Spacings = Spacings(dims);

    % Invert required dimensions
    v = sum([v1,v2],2);
    v(3) = v1(1)*v2(2)-v1(2)*v2(1);
    for i=1:3
        if(v(i)<0)
            myImage = flipdim(myImage,i);
            Origin(i) = Origin(i)-(size(myImage,i)-1)*Spacings(i);
        end
    end

end

% Store meta-data
myInfo.Spacing = Spacings;
myInfo.ImagePositionPatient = Origin;
myInfo.PatientOrientation = StandardOrientation;
myInfo.PatientID = PatientID;
myInfo.FrameOfReferenceUID = FrameOfReferenceUID;
myInfo.SOPInstanceUID = SOPInstanceUID;
myInfo.SeriesInstanceUID = SeriesInstanceUID;
myInfo.SOPClassUID = SOPClassUID;
myInfo.StudyInstanceUID = StudyInstanceUID;
myInfo.OriginalHeader = OriginalHeader;
myInfo.Type = 'image';

end
