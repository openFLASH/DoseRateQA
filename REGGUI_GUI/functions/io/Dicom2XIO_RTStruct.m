%% Dicom2XIO_RTStruct
% Read a DICOM RT struct file from disk, udate the DICOM tags with information contained in an image stored in |handles.images| or |handles.mydata| and save the result to disk as a DICOM file readable by XIO.
% The DICOM frame of reference is copied from the CT scan (= |imageName|)
%
%% Syntax
% |res = Dicom2XIO_RTStruct(handles)|
%
% |res = Dicom2XIO_RTStruct(handles,imageName)|
%
% |res = Dicom2XIO_RTStruct(handles,imageName,RTFileName)|
%
%
%% Description
% |res = Dicom2XIO_RTStruct(handles)| The RT struc file and the associated REGGUI image are selected manually.
%
% |res = Dicom2XIO_RTStruct(handles,imageName)| The RT struc file is selected manually.
%
% |res = Dicom2XIO_RTStruct(handles,imageName,RTFileName)| Export the DICOM file of the RT-struct
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "images" or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.XXX.info{i}.Spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the images
% * |handles.XXX.info{i}.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
%
% |imageName| - _STRING_ -  [OPTIONAL] Name of the image contained in |handles.XXX.name| containing the DICOM information to use for the RT-struct. If absent, a dialog box is displayed.
%
% |RTFileName| - _STRING_ - [OPTIONAL] Name of the DICOM file containing the RT-struct. If absent, a dialog box is displayed.
%
%
%% Output arguments
%
% |res = handles| - _STRUCTURE_ -  REGGUI data structure. No change to the input.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Dicom2XIO_RTStruct(handles,imageName,RTFileName)


res = handles;

current_dir = pwd;

if(nargin<2)
    imageName = Image_list(handles,'To which image the RTStruct must be associated?',1);
end

if(nargin<3)
    [myContourFilename, myContourDir] = uigetfile( ...
        {'*.*','RTSTRUCT Files (*)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a file', [handles.dataPath '/Untitled']);
    RTFileName = fullfile(myContourDir,myContourFilename);
end

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},imageName))
        spacing = handles.mydata.info{i}.Spacing;
        origin = handles.mydata.info{i}.ImagePositionPatient;
        imageSize = size(handles.mydata.data{i});
        infoImage = handles.mydata.info{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},imageName))
        spacing = handles.images.info{i}.Spacing;
        origin = handles.images.info{i}.ImagePositionPatient;
        imageSize = size(handles.images.data{i})';
        infoImage = handles.images.info{i};
    end
end

if(isempty(infoImage))
    cd(current_dir)
    error('Error: image not found');
end

% Correction
correction_vector = - (origin + imageSize/2 .* spacing);

% current time
Date = datestr(now,'yyyymmdd');
Time = datestr(now,'HHMMSS');

try
    input_RT = read_dicomrtstruct(RTFileName,infoImage);
    infoRS = input_RT.DicomHeader;
    infoRS.InstanceCreationDate = Date;
    infoRS.InstanceCreationTime = Time;
    onum = input_RT.StructNum;
    
    % frame of reference taken from CT scan
    infoRS.StudyInstanceUID
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = infoImage.FrameOfReferenceUID;
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID = infoRS.StudyInstanceUID;
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = infoImage.SeriesInstanceUID;
    for StructCur=1:onum
        StructCurItem   =   ['Item_',num2str(StructCur)];
        infoRS.StructureSetROISequence.(StructCurItem).ReferencedFrameOfReferenceUID = infoImage.FrameOfReferenceUID;
        SliceCur        =   1;
        SliceCurItem    =   'Item_1';
        while isfield(infoRS.ROIContourSequence.(StructCurItem).ContourSequence,SliceCurItem)
            % X correction
            infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(1:3:end) = infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(1:3:end) + correction_vector(1);
            % Y correction
            infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(2:3:end) = infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(2:3:end) + correction_vector(2);
            % UIDs adaptation
            Z = infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(3:3:end);
            slice_index = (Z(1)-infoImage.ImagePositionPatient(3))/infoImage.Spacing(3) + 1;
            infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourImageSequence.Item_1.ReferencedSOPInstanceUID = infoImage.SOPInstanceUID(slice_index).SOPInstanceUID;
            SliceCur        =   SliceCur+1;
            SliceCurItem    =   ['Item_',num2str(SliceCur)];
        end
    end
    
    % structure set info
    infoRS.StructureSetLabel = 'REGGUI';
    infoRS.StructureSetDate = Date;
    infoRS.StructureSetTime = Time;
    
    % for each slice
    nslis = handles.size(3);
    for isli = 1:nslis
        % Item_<isli> string
        Item_isli = ['Item_', sprintf('%i',nslis-isli+1)];
        % refer to CT SOP
        infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(Item_isli).ReferencedSOPClassUID = infoImage.SOPClassUID; % normally '1.2.840.10008.5.1.4.1.1.2' for CT
        infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(Item_isli).ReferencedSOPInstanceUID = infoImage.SOPInstanceUID(isli).SOPInstanceUID;
    end
    
    dicomwrite([],[RTFileName '_xio.dcm'],infoRS,'CreateMode','Copy');
    
catch ME
    reggui_logger.info(['This might not be a valid RTStruct file. ',ME.message],handles.log_filename);
    cd(current_dir)
    rethrow(ME);
end

res = handles;
