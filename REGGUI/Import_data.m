%% Import_data
% Unconstrained image import from file, inside the data container.
%%

%% Syntax
% |handles = Import_data(myDataDir,myDataFilename,format,myDataName,handles)|

%% Description
% |handles = Import_data(myDataDir,myDataFilename,format,myDataName,handles)|
% allows flexible import of  multiple images, unconstrained by pixel spacing.
% The information in |handles.mydata| has computational purposes. By instance,
% for rigid registration, an image is down-sampled to isotropic pixels.

%% Input arguments
% |myDataDir| - _STRING_ - the directory on disk holding the image. The
% expected string is of form _'home/user/workingDir'_.
%
% |myDataFilename| - _STRING_ - the image filename. Takes the form
% _'0123456789image.dcm'_
%
% |format| - _INTEGER_ - defines the type of import that will be
% perfomed. The following indices are expected:
%
% * 1 - 3D Dicom files
% * 2 - 3D dose files
% * 3 - Matlab files
% * 4 - Analyze75 files
% * 5 - Meta image files
% * 6 - 2D image files
% * 7 - Text format
% * 8 - Matlab structure
%
% |myDataName| - _STRING_ - name of the data structure stored inside
% |handles.mydata|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be
% processed.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the
% loaded data:
%
% * handles.mydata.name
% * handles.mydata.data
% * handles.mydata.info

%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Import_data(myDataDir,myDataFilename,format,myDataName,handles)
myData = [];
myInfo = Create_default_info('image',handles);
try_as_image = 1;
% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 1
            format = 'dcm';
        case 2
            format = 'dose';
        case 3
            format = 'mat';
        case 4
            format = 'hdr';
        case 5
            format = 'mhd';
        case 6
            format = '2d';
        case 7
            format = 'txt';
        case 8
            format = 'not_set';
        otherwise
            error('Invalid type number.')
    end
end
% import data
if(strcmp(format,'mat'))
    myData = load(fullfile(myDataDir,myDataFilename));
    firstdata = whos('-file',fullfile(myDataDir,myDataFilename));
    eval(['myData = myData.',firstdata.name,';']);
    if(~isfield(myData,'data') || ~isfield(myData,'info'))
        try_as_image = 0;
    elseif(isfield(myData,'info'))
        if (isfield(myData.info, 'Type') && ~strcmp(myData.info.Type,'image')) || (isfield(myData.info, 'type') && ~strcmp(myData.info.type,'image'))
            myInfo = myData.info;
            myData = myData.data;
            try_as_image = 0;
        end
    end
elseif(strcmp(format,'2d'))
    try
        myData = uint8(imread(fullfile(myImageDir,myImageFilename)));
        myInfo.Spacing = [1;1;1];
        myInfo.ImagePositionPatient = [0;0;0];
        try_as_image = 0;
    catch
    end
elseif(strcmp(format,'not_set') && not(isdir(fullfile(myDataDir,myDataFilename))))
    try
        dc = dicominfo(fullfile(myDataDir,myDataFilename));
        try_as_image = 1;
    catch
        try_as_image = 0;
        firstdata = whos('-file',fullfile(myDataDir,myDataFilename));
        myData = load(fullfile(myDataDir,myDataFilename));
        eval(['myData = myData.',firstdata.name,';']);
        if(isstruct(myData))
            myInfo = myData.info;
            myData = myData.data;
        end
        if(isfield(myInfo,'Type'))
            if(strcmp(myInfo.Type,'deformation_field'))
                for n=1:size(myData,1)
                    myData(n,:,:,:) = myData(n,:,:,:)/myInfo.Spacing(n);
                end
            end
        end
    end
end
if(try_as_image)
    try
        disp('Try to find info about this data...')
        [myData,myInfo] = load_Image(myDataDir,myDataFilename,format);
        myData = single(myData);
    catch
        reggui_logger.info('This file is not a valid image data. Continue.',handles.log_filename);
    end
end
% Setting or checking image properties
Data_load = 1;
if(try_as_image && (~isfield(myInfo,'Spacing') || ~isfield(myInfo,'ImagePositionPatient') || ~isfield(myInfo,'PatientID') || ...
        ~isfield(myInfo,'FrameOfReferenceUID') || ~isfield(myInfo,'SOPInstanceUID') || ~isfield(myInfo,'SeriesInstanceUID') || ...
        ~isfield(myInfo,'SOPClassUID') || ~isfield(myInfo,'StudyInstanceUID') || ~isfield(myInfo,'PatientOrientation') || isempty(myData)) )
    error('Error : unable to import image-like data because of empty data or unknown properties.')
end
if(Data_load)
    disp('Adding data to the list...')
    myDataName = check_existing_names(myDataName,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = myDataName;
    handles.mydata.data{length(handles.mydata.data)+1} = myData;
    handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
end
