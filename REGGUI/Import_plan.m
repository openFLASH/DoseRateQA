%% Import_plan
% Load a treatment plan from disk and store it in |handles.plans|. The plan can be sotred as a file on the local disk (several format are supported) or on the Orthanc PACS if |format = 'pacs'|.
%
%% Syntax
% |handles = Import_plan(myPlanDir, myPlanFilename, format, myPlanName, handles)|
%
%
%% Description
% |handles = Import_plan(myPlanDir, myPlanFilename, format, myPlanName, handles)| Load a treatment plan from disk
%
%
%% Input arguments
% |myPlanDir| - _STRING_ - Name of the folder where the data is located
%
% |myPlanFilename| - _STRING_ - When loading the plan from disk, file name of the data to be loaded. When loading the image from the PACS, myImageFilename gives the UID  of the instance
%
% |format| - _STRING or INTEGER_ -   Format of the file. The options are:
%
% * 0 or 'pacs': Retrieve the image from the Orthanc PACS
% * 1 or 'dcm' : DICOM File
% * 2 or 'pld' : PLD   File
% * 3 or 'gate' : GATE  File
%
% |myPlanName| - _STRING_ - Name of the data structure inside |handles|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be processed.
%
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the loaded plan:
%
% * |handles.plans.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th treatment plan
% * |handles.plans.data{i}| - _STRUCTURE_ Structure describing the i-th treatment plan
% * |handles.plans.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Import_plan(myPlanDir, myPlanFilename, format, myPlanName, handles)
% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 0
            format = 'pacs';
        case 1
            format = 'dcm';
        case 2
            format = 'pld';
        case 3
            format = 'gate';
        case 4
            format = 'json';
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
    image_dir = fullfile(temp_dir,myPlanDir); % myPlanDir gives the image (series) name
    if(exist(image_dir,'dir'))
        try
            rmdir(image_dir,'s');
        catch
            disp(['Warning: cannot delete folder ',image_dir]);
        end
    end
    mkdir(image_dir);
    orthanc_save_to_disk(['instances/',myPlanFilename,'/file'],fullfile(image_dir,'rtplan.dcm')); % myPlanFilename gives the UID of the instance
    handles = Import_plan(image_dir,'rtplan.dcm','dcm',myPlanName,handles);
    try
        rmdir(image_dir,'s');
    catch
    end
    return
end
% ------------------------------------------------------------------------

% import plan
try
    [myBeamData,myInfo] = load_Plan(fullfile(myPlanDir,myPlanFilename),format,not(handles.auto_mode));
catch ME
    reggui_logger.info(['This file is not a valid plan. ',ME.message],handles.log_filename);
    rethrow(ME);
end
disp('Adding plan to the list...')
myPlanName = check_existing_names(myPlanName,handles.plans.name);
handles.plans.name{length(handles.plans.name)+1} = myPlanName;
handles.plans.data{length(handles.plans.data)+1} = myBeamData;
handles.plans.info{length(handles.plans.info)+1} = myInfo;
