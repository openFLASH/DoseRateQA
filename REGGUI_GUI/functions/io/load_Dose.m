%% load_Dose
% Load a DICOM file containing a dose map.
%
%% Syntax
% |[myMat myInfo] = load_Dose(dicom_filename)|
%
%
%% Description
% |[myMat myInfo] = load_Dose(dicom_filename)| Load a DICOM file containing a dose map.
%
%
%% Input arguments
% |dicom_filename| - _STRING_ - Name of the DICOM file to load
%
%
%% Output arguments
%
% |myMat| - _SCALAR MATRIX_ - |myMat(x,y,z)| or |myMat(x,y,z,t)| Dose (in Gy) at voxel (x,y,z) and at time t.
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Contributors
% % Authors : G.Janssens, J.Orban (open.reggui@gmail.com)

function [myMat myInfo] = load_Dose(dicom_filename)

myMat = [];
Current_dir = pwd;

SOP = struct;
disp_warning_no_SOPInstanceUID = false;

myInfo = dicominfo(dicom_filename);
myInfo.OriginalHeader = myInfo;
if(~isfield(myInfo,'ImagePositionPatient'))
    myInfo.ImagePositionPatient = [0;0;0];
end

myInfo.Spacing = [myInfo.PixelSpacing(2);myInfo.PixelSpacing(1);1];

if(isfield(myInfo,'SliceThickness'))
    if(not(isempty(myInfo.SliceThickness)))
        myInfo.Spacing(3) = myInfo.SliceThickness;
    end
end

if(isfield(myInfo,'SpacingBetweenSlices'))
    if(not(isempty(myInfo.SpacingBetweenSlices)))
        myInfo.Spacing(3) = myInfo.SpacingBetweenSlices;
    end
end

inverse_Z = 0;
if(isfield(myInfo,'GridFrameOffsetVector'))
    if(length(myInfo.GridFrameOffsetVector)>1)
        myInfo.Spacing(3) = myInfo.GridFrameOffsetVector(2)-myInfo.GridFrameOffsetVector(1);
    end
    if(myInfo.Spacing(3)<0)
        inverse_Z = 1;
    end
end

myInfo.Spacing = abs(myInfo.Spacing);

if(~isfield(myInfo,'SOPClassUID'))
    [imageType,OK] = listdlg('PromptString','This image was not recognized automatically, what type of image is it?',...
        'SelectionMode','single','ListString',{'CT','MR','RTDose','PET','Label (!unrecognised format)'});
    switch imageType
        case 1
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
        case 2
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
        case 3
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2';
        case 4
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.128';
        case 5
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
    end
end
if(~isfield(myInfo,'SeriesInstanceUID'))
    myInfo.SeriesInstanceUID = dicomuid;
    disp('Warning: The dicom header does not contain a serieInstanceUID. One was just created.')
end
if(~isfield(myInfo,'FrameOfReferenceUID'))
    myInfo.FrameOfReferenceUID = 'tag not initialized';
    disp('Warning: The dicom header does not contain a FrameOfReferenceUID.')
end
if(~isfield(myInfo,'StudyInstanceUID'))
    myInfo.StudyInstanceUID = dicomuid;
end
if(~isfield(myInfo,'PatientID'))
    myInfo.PatientID = 'noID';
end
if(~isfield(myInfo,'ImageOrientationPatient'))
    myInfo.ImageOrientationPatient = [1;0;0;0;1;0];
    disp('Warning: no orientation was found for this image');
end

if(isfield(myInfo,'DoseGridScaling'))
    myMat = single(dicomread(dicom_filename))*myInfo.DoseGridScaling;% Put the dose in Gy
    myInfo.rescaled = 1;
else
    myMat = single(dicomread(dicom_filename));
end

myMat = permute(myMat,[2,1,4,3]);

if(inverse_Z)
    myMat = myMat(:,:,end:-1:1);
    myInfo.ImagePositionPatient(3) = myInfo.ImagePositionPatient(3) - size(myMat,3)*myInfo.Spacing(3);
end

myInfo.SOPInstanceUID = SOP;

cd(Current_dir);
