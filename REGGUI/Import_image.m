%% Import_image
% Image import into REGGUI data-structure. The image can be stored as a file on the local disk (several format are supported) or on the Orthanc PACS  if |format = 0|.
% If the image has the same dimensions as the |handles.images| workspace, then the image is loaded in |handles.images|. Otherwise, if the automatic mode is turned off, the image is stored in |handles.mydata|. If the automatic mode is turned on, a dialog box is displayed to let the user choose where the field should be stored.
%%

%% Syntax
% |[handles , myImageName] = Import_image(myImageDir,myImageFilename,format,myImageName,handles)|

%% Description
% |[handles , myImageName] = Import_image(myImageDir,myImageFilename,format,myImageName,handles)|
% imports into DICOM images into REGGUI

%% Input arguments
% |myImageDir| - _STRING_ - the directory on disk holding the image. The expected string is of form _'home/user/workingDir'_.
%
% |myImageFilename| - _STRING_ - When loading the image from disk the image filename. Takes the form _'0123456789image.dcm'_. When loading the image from the PACS, myImageFilename gives the UID of the serie or the the UID of the instance (e.g. 3D dose image)
%
% |format| - _INTEGER_ - defines the type of import that will be
% perfomed. The following indices are expected:
%
% * 0 - Retrieve the image from the Orthanc PACS
% * 1 - 3D Dicom files
% * 2 - 3D dose files
% * 3 - Matlab files
% * 4 - Analyze75 files
% * 5 - Meta image files
% * 6 - 2D image files
% * 7 - NifTi image files
% * 8 - Matlab structure
%
% |myDataName| - _STRING_ - name of the imported data structure stored
% inside |handles.images|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the images to
% be processed.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the
% loaded images (where XXX is either |images| or |mydata|):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the new image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info|
%
% |myImageName| -_STRING_- Name of the loaded image in |handles|. This is the input |myImageName| corrected for any unauthorised characters
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [handles , myImageName] = Import_image(myImageDir,myImageFilename,format,myImageName,handles)
% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 0
            format = 'pacs';
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
            format = 'nifti';
        case 8
            format = 'unknown';
        otherwise
            error('Invalid type number.')
    end
end

% ------------------------------------------------------------------------
% if PACS, import dicom from orthanc and save it locally
if(strcmp(format,'pacs'))
    [~,reggui_config_dir] = get_reggui_path();
    temp_dir = fullfile(reggui_config_dir,'temp_dcm_data');
    if(not(exist(temp_dir,'dir')))
        mkdir(temp_dir);
    end
    image_dir = fullfile(temp_dir,myImageDir); % myImageDir gives the image (series) name    
    if(exist(image_dir,'dir'))
        try
            rmdir(image_dir,'s');
        catch
            disp(['Warning: cannot delete folder ',image_dir]);
        end
    end
    mkdir(image_dir);
    try
        temp = orthanc_get_info(['series/',myImageFilename]); % myImageFilename gives the UID of the serie
    catch
        temp = orthanc_get_info(['instances/',myImageFilename]); % myImageFilename gives the UID of the instance (e.g. 3D dose image)
    end
    if(isfield(temp,'Instances'))
        instance_ids = temp.Instances;
    else
        instance_ids{1} = temp.ID;
    end
    for n=1:length(instance_ids)
        orthanc_save_to_disk(['instances/',instance_ids{n},'/file'],fullfile(image_dir,[num2str(n),'.dcm']))
    end
    handles = Import_image(image_dir,'1.dcm','dcm',myImageName,handles);
    try
        rmdir(image_dir,'s');
    catch
    end
    return
end
% ------------------------------------------------------------------------

% import image
myImage = [];
myInfo = struct;
if(not(isfield(handles,'correct_dcm')))
    if(not(handles.auto_mode))
        handles.correct_dcm = -1;
    else
        handles.correct_dcm = 0;
    end
end
try
    [myImage,myInfo,handles.correct_dcm] = load_Image(myImageDir,myImageFilename,format,handles.correct_dcm);
catch ME
    reggui_logger.info(['This file is not a valid image. ',ME.message],handles.log_filename);
    rethrow(ME);
end
% Setting or checking image properties
Image_load = 1;
Data_load = 0;
Convert = 0;
Set_spatialprop = 1;
FourD = 0;
if(~isfield(myInfo,'Spacing') || ~isfield(myInfo,'ImagePositionPatient') || ~isfield(myInfo,'PatientID') || ...
        ~isfield(myInfo,'FrameOfReferenceUID') || ~isfield(myInfo,'SOPInstanceUID') || ~isfield(myInfo,'SeriesInstanceUID') || ...
        ~isfield(myInfo,'SOPClassUID') || ~isfield(myInfo,'StudyInstanceUID') || ~isfield(myInfo,'PatientOrientation') || isempty(myImage) )
    disp(myInfo)
    error('Error : unable to import images because of empty data or unknown properties.')
end
if(~handles.spatialpropsettled)
    if(~handles.auto_mode && 0)
        Choice = questdlg(['Loading this image (',myImageName,') will set spatial properties for this project'], ...
            'Choose', ...
            'Continue', 'Load as data','Cancel','Continue');
        if(strcmp(Choice,'Load as data'))
            Data_load = 1;
            Image_load = 0;
            Set_spatialprop = 0;
        end
        if(strcmp(Choice,'Cancel'))
            return
        end
    end
    if(Set_spatialprop)
        disp('Setting spatial properties for this project !')
        handles.size(1) = size(myImage,1);
        handles.size(2) = size(myImage,2);
        handles.size(3) = size(myImage,3);
        handles.spacing = myInfo.Spacing;
        handles.origin = myInfo.ImagePositionPatient;
        handles.spatialpropsettled = 1;
        iso_voxel = round(handles.size/2);% in voxel space
        handles.view_point = iso_voxel;
    end
else
    Not_in_workspace = sum(~(round(handles.origin*1e3) == round(myInfo.ImagePositionPatient*1e3))) || sum(~(round(handles.spacing*1e3) == round(myInfo.Spacing*1e3))) || ~(handles.size(1) == size(myImage,1) && handles.size(2) == size(myImage,2) && handles.size(3) == size(myImage,3));
    if(Not_in_workspace)
        Image_load = 0;
        disp('Warning : this image has not the same spatial properties (origin, size or spacing) as previous images !')
        if(~handles.auto_mode)
            Choice = questdlg(['This image (',myImageName,') has a different spatial configuration than previous images'], ...
                'Choose', ...
                'Load as data','Convert to image','Register (rigid)','Load as data');
            if(strcmp(Choice,'Load as data'))
                Data_load = 1;
            elseif(strcmp(Choice,'Convert to image'))
                Data_load = 1;
                Convert = 1;
            elseif(strcmp(Choice,'Register (rigid)'))
                Data_load = 1;
                Convert = 2;
            end
        else
            Data_load = 1;
            Convert = 1;
        end
    end
end
if(Image_load)
    if(size(myImage,4)>1) % 4D dataset
        disp('Adding images to the list...')
        FourD = 1;
        for i=1:size(myImage,4)
            myPhaseName = check_existing_names([myImageName,num2str(i)],handles.images.name);
            handles.images.name{length(handles.images.name)+1} = myPhaseName;
            handles.images.data{length(handles.images.data)+1} = single(myImage(:,:,:,i));
            handles.images.info{length(handles.images.info)+1} = myInfo;
        end
    else
        disp('Adding image to the list...')
        myImageName = check_existing_names(myImageName,handles.images.name);
        handles.images.name{length(handles.images.name)+1} = myImageName;
        handles.images.data{length(handles.images.data)+1} = single(myImage);
        handles.images.info{length(handles.images.info)+1} = myInfo;
    end
    %[handles.minscale,handles.maxscale] = get_image_scale({myImage},handles.scale_prctile);
elseif(Data_load)
    if(size(myImage,4)>1) % 4D dataset
        disp('Adding images to the list...')
        FourD = 1;
        for i=1:size(myImage,4)
            myPhaseName{i} = check_existing_names([myImageName,num2str(i)],handles.mydata.name);
            myPhaseName{i} = check_existing_names(myPhaseName{i},handles.images.name);
            handles.mydata.name{length(handles.mydata.name)+1} = myPhaseName{i};
            handles.mydata.data{length(handles.mydata.data)+1} = single(myImage(:,:,:,i));
            handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
        end
    else
        disp('Adding data to the list...')
        myImageName = check_existing_names(myImageName,handles.mydata.name);
        myImageName = check_existing_names(myImageName,handles.images.name);
        handles.mydata.name{length(handles.mydata.name)+1} = myImageName;
        handles.mydata.data{length(handles.mydata.data)+1} = single(myImage);
        handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
    end
    if(Convert==1)
        if(FourD)
            for i=1:size(myImage,4)
                disp('Converting data to image...')
                handles = Data2image(myPhaseName{i},myPhaseName{i},handles);
                disp('Removing data from the list...')
                handles = Remove_data(myPhaseName{i}, handles);
            end
        else
            disp('Converting data to image...')
            handles = Data2image(myImageName,myImageName,handles);
            disp('Removing data from the list...')
            handles = Remove_data(myImageName, handles);
        end
        %[handles.minscale,handles.maxscale] = get_image_scale({myImage},handles.scale_prctile);
    elseif(Convert==2)
        if(length(handles.images.name)>2)
            [im1,type1] = Image_list(handles,['To which image should the new image (',myImageName,') be registered ?'],1);
        else
            type1 = 1;
            im1 = handles.images.name{2};
        end
        if(type1==1)
            for index = 2:length(handles.images.name)
                if(strcmp(handles.images.name{index},im1))
                    break
                end
            end
            if(isempty(index))
                index = 2;
            end
            modality_fixed = '';
            if(isfield(handles.images.info{index},'OriginalHeader'))
                if(isfield(handles.images.info{index}.OriginalHeader,'Modality'))
                    modality_fixed = handles.images.info{index}.OriginalHeader.Modality;
                end
            end
            modality_moving = '';
            if(isfield(myInfo,'OriginalHeader'))
                if(isfield(myInfo.OriginalHeader,'Modality'))
                    modality_moving = myInfo.OriginalHeader.Modality;
                end
            end
            try
                if( (strcmp(modality_fixed,'CT')&&strcmp(modality_moving,'CT')) || (strcmp(modality_fixed,'PT')&&strcmp(modality_moving,'PT')))
                    disp('Register data to image (MONO-modal rigid registration)...')
                    handles = Registration_ITK_rigid(handles.images.name{index}, myImageName, myImageName,[myImageName,'_rigid_trans'],handles);
                else
                    disp('Register data to image (MULTI-modal rigid registration)...')
                    handles = Registration_ITK_rigid_multimodal(handles.images.name{index}, myImageName, myImageName,[myImageName,'_rigid_trans'],handles);
                end
            catch
                disp('Error !')
                err = lasterror;
                disp(['    ',err.message]);
                disp(err.stack(1));
                handles = Registration_rigid(handles.images.name{index}, myImageName, myImageName, [myImageName,'_rigid_trans'], 3, 'ssd', handles);
            end
        else
            disp('You have to select an image');
        end
        disp('Removing data from the list...')
        handles = Remove_data(myImageName, handles);
        %[handles.minscale,handles.maxscale] = get_image_scale({myImage},handles.scale_prctile);
    end
end
