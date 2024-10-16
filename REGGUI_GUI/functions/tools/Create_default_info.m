%% Create_default_info
% Create an 'info' data structure
%
%% Syntax
% |myInfo = Create_default_info(type,handles)|
%
% |myInfo = Create_default_info(type,handles,CopyInfo)|
%
% |myInfo = Create_default_info(type,handles,CopyInfo,input_tags)|
%
% |myInfo = Create_default_info(type,handles,CopyInfo,input_tags,CopyUIDs)|
%
%
%% Description
% |myInfo = Create_default_info(type,handles)|  create the 'info' data structure.  Use default DICOM information.
%
% |myInfo = Create_default_info(type,handles,CopyInfo)|  create the 'info' data structure. Use default DICOM information. Replace the fields with those defined in |CopyInfo|.
%
% |myInfo = Create_default_info(type,handles,CopyInfo,input_tags)|  create the 'info' data structure.  Use default DICOM information. Copy the fields |input_tags| into the |info| structure. Replace the fields with those defined in |CopyInfo|.
%
% |myInfo = Create_default_info(type,handles,CopyInfo,input_tags,CopyUIDs)| create the 'info' data structure. Copy all DICOM information from the |CopyUIDs| into the info structure. Copy the fields |input_tags| into the |info| structure. Replace the fields with those defined in |CopyInfo|.
%
%
%% Input arguments
% |type| - _STRING_ -  Description of the data type. The strinc will be copied in |myInfo.Type|. for example 'image' or 'deformation_field'
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.spatialpropsettled| - _INTEGER_ - 1 = The dimensions for workspace are defined (e.g. image scale is defined). 0 otherwise
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (x,y,z) (in mm) of the voxel (1,1,1) of the image in the DICOM coordinate system
%
% |CopyInfo| - _STRUCTURE_ -  Replace all the fields of |info| by the fields contained in |CopyInfo|
%
% |input_tags| - _CELL ARRAY_ - List of fields, with associated values, to be copied in the |info| structure:
%
% |input_tags{i,1}| - _STRING_ - Name of the field i to be copied in the |info| structure
% |input_tags{i,2}| - _TYPE_ - Value of the field i
%
% |CopyUIDs| - _STRUCTURE_ -  [Optional] Meta information from the DICOM file. All the fields of the structure are copied into |info|. If absent, the following default fields are copied in |info|:
%
% * |myInfo.PatientName = 'Unknown'| - _STRING_ - Name of the patient
% * |myInfo.PatientID| - _STRING_ - DICOM unique identifier of the patient. Value returned by the Matlab function 'dicomuid.m'
% * |myInfo.FrameOfReferenceUID| - _STRING_ - Unique DICOM identifier of the coordinate system. Value returned by the Matlab function 'dicomuid.m' 
% * |myInfo.SeriesInstanceUID| - _STRING_ - Unique DICOM identifier for the series instance UID. Value returned by the Matlab function 'dicomuid.m' 
% * |myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.7'| - _STRING_ - DICOM identifier for the SOP class 
% * |myInfo.StudyInstanceUID| - _STRING_ - Unique DICOM identifier for the study instance UID. Value returned by the Matlab function 'dicomuid.m' 
% * |myInfo.PatientOrientation = [1;0;0;0;1;0]| - _SCALAR VECTOR_ - The direction cosines of the first row and the first column with respect to the patient
%
%
%% Output arguments
%
% |myInfo| - _STRUCTURE_ - Structure containing the information data about the image
%
% * |myInfo.Type|
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function myInfo = Create_default_info(type,handles,CopyInfo,input_tags,CopyUIDs)

myInfo = struct;

if(nargin<3)
    CopyInfo = [];
end
if(nargin<4)
    input_tags = [];
end
if(nargin<5)
    CopyUIDs = [];
end

if(not(isempty(CopyUIDs))) % copy all meta info (only spacing and origin will be replaced afterwards)
    myInfo = CopyUIDs;
else % create new UIDs
    myInfo.PatientName = 'Unknown';
    myInfo.PatientID = dicomuid;
    myInfo.FrameOfReferenceUID = dicomuid;
    myInfo.SeriesInstanceUID = dicomuid;
    myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
    myInfo.StudyInstanceUID = dicomuid;
    myInfo.PatientOrientation = [1;0;0;0;1;0];
end

% Recompute spacing and origin
if(handles.spatialpropsettled)
    myInfo.Spacing = handles.spacing;
    myInfo.ImagePositionPatient = handles.origin;
else
    myInfo.Spacing = [1;1;1];
    myInfo.ImagePositionPatient = [0;0;0];
end

% Replace all meta information by input
if(not(isempty(CopyInfo)))
    myInfo = CopyInfo;
end

% Replace SOPInstanceUID by empty value
myInfo.SOPInstanceUID = [];

% Replace additional tags
if(not(isempty(input_tags)))
    for i=1:size(input_tags,1)
        try
            myInfo.(input_tags{i,1}) = input_tags{i,2};
        catch
        end
    end
end

myInfo.Type = type;
