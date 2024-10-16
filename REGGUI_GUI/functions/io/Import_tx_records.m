%% Import_tx_records
% Import treatment records/logs and store as plan in reggui handles
%
%% Syntax
% |handles = Import_tx_records(myLogDir,myLogFilename,format,myPlanName,handles)|
%
% |handles = Import_tx_records(myLogDir,myLogFilename,format,myPlanName,handles,RefName,aggregate_paintings,XDRconverter)|
%
%% Description
% |handles = Import_tx_records(myLogDir,myLogFilename,format,myPlanName,handles)| : Imports delivery logs in handles
%
% |handles = Import_tx_records(myLogDir,myLogFilename,format,myPlanName,handles,RefName,aggregate_paintings,XDRconverter)| : Creates a replicata of the original plan in handles but replaces spots positions and MU delivered with data from specified logs
%
%% Input arguments
% |myLogDir| - _STRING_ - the directory on disk holding the logs. The expected string is of form _'home/user/workingDir'_.
%
% |myLogFilename| - _STRING_ - When loading the record/logs from disk the record/logs filename(s).
%
% |format| - _INTEGER_ - defines the type of import that will be perfomed. The following indices are expected:
%
% * 0 - Retrieve the RT Record from the Orthanc PACS
% * 1 - Dicom RT Record files
% * 2 - IBA log files (.zip)
% * 3 - IBA scanalgo config (.txt)
%
% |myPlanName| - _STRING_ - name of the imported data structure stored inside |handles.plans|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the images to be processed.
%
% |RefName| - _STRING_ - Name of reference plan stored in |handles|
%
% |aggregate_paintings| - _BOOL_ - Toggles the aggregation of repainted spots into single spot value
%
% |overwrite_geometry| - _BOOL_ - Toggles the overwrite of the gantry and table angles with the planned ones (if reference plan in available)
%
% |XDRconverter| - _STRING_ - Name of the XDR converter if necessary for the log conversion
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the original and the new plan reconstructed from logs
%
%% Contributors
% Author(s): G. Janssens

function handles = Import_tx_records(myLogDir,myLogFilename,format,myPlanName,handles,RefName,aggregate_paintings,overwrite_geometry,XDRconverter,merge_tuning)
% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 0
            format = 'pacs';
        case 1
            format = 'dcm';
        case 2
            format = 'iba';
        case 3
            format = 'iba_specif';
        otherwise
            error('Invalid type number.')
    end
end

% Default parameters
if(nargin<6)
    ref_data = [];
    ref_info = [];
else
    if(not(isempty(RefName)))
        [ref_data,ref_info] = Get_reggui_data(handles,RefName);
        if(not(isfield(ref_info,'Type')))
            ref_data = [];
        elseif(not(strcmp(ref_info.Type,'pbs_plan')))
            ref_data = [];
        end
    else
        ref_data = [];
        ref_info = [];
    end
end
if(nargin<7)
    aggregate_paintings = 0;
end
if(nargin<8)
    overwrite_geometry = 0;
end
if(nargin<9)
    XDRconverter = '';
end
if(nargin<10)
    merge_tuning = 0;
end

% ------------------------------------------------------------------------
% if PACS, import dicom from orthanc and save it locally
if(strcmp(format,'pacs'))
    [~,reggui_config_dir] = get_reggui_path();
    temp_dir = fullfile(reggui_config_dir,'temp_dcm_data');
    if(not(exist(temp_dir,'dir')))
        mkdir(temp_dir);
    end
    image_dir = fullfile(temp_dir,myLogDir); % myLogDir gives the record (series) name
    if(exist(image_dir,'dir'))
        try
            rmdir(image_dir,'s');
        catch
            disp(['Warning: cannot delete folder ',image_dir]);
        end
    end
    mkdir(image_dir);
    orthanc_save_to_disk(['instances/',myLogFilename,'/file'],fullfile(image_dir,'rtrecord.dcm')); % myLogFilename gives the UID of the instance
    handles = Import_tx_records(image_dir,'rtrecord.dcm','dcm',myPlanName,handles);
    try
        rmdir(image_dir,'s');
    catch
    end
    return
end
% ------------------------------------------------------------------------

% import records
Log_load = 1;
try
    if(iscell(myLogFilename))
        for i=1:length(myLogFilename)
            myLogFilename{i} = fullfile(myLogDir,myLogFilename{i});
        end
    else
        tokens = strsplit(myLogFilename,';');
        myLogFilename = {};
        for i=1:length(tokens)
            if(not(isempty(tokens{i})))
                myLogFilename{end+1} = fullfile(myLogDir,tokens{i});
            end
        end
    end
    [myBeamData,myInfo] = load_DICOM_RT_Records(myLogFilename,format,ref_data,ref_info,'aggregate_paintings',aggregate_paintings,'overwrite_geometry',overwrite_geometry,'XDRconverter',XDRconverter,'merge_tuning',merge_tuning);
catch ME
    reggui_logger.info(['This file is not a valid tx record or log file(s). ',ME.message],handles.log_filename);
    rethrow(ME);
end
if(Log_load)
    disp('Adding plan to the list...')
    myPlanName = check_existing_names(myPlanName,handles.plans.name);
    handles.plans.name{length(handles.plans.name)+1} = myPlanName;
    handles.plans.data{length(handles.plans.data)+1} = myBeamData;
    handles.plans.info{length(handles.plans.info)+1} = myInfo;
end
