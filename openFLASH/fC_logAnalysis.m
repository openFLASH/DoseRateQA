%% fC_logAnalysis
% Load the irradiation logs and compute
%   * the dose map using records from the logs
%   * the dose rate map using records from the logs
%
%% Syntax
% |handles = fC_logAnalysis(configFile)|
%
%
%% Description
% |handles = fC_logAnalysis(configFile)| Description
%
%
%% Input arguments
% |config| -_STRUCT_- Structure with all the file name and data for computation
%
%
%% Output arguments
%
% |handles| -_STRUCT_- REGGUI structure
%   * |handles.plans| -CELL VECTOR of STRUCT- The treatment plan from TPS and the plan reconstructed from logs
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function   [handles, Plan , beamInfoInLogs] = fC_logAnalysis(config)


  % Load the JSON file with the parameters for the computation
  %-----------------------------------------------------------
  %config = loadjson(configFile)

  RSplanFileName = config.files.planFileName;
  CTname = config.files.CTname;
  rtstructFileName = config.files.rtstructFileName;


  %Load the data
  %-------------
  handles = struct;
  handles.path = config.files.output_path;
  handles.dataPath = config.files.output_path;
  handles = Initialize_reggui_handles(handles);


  %Load reference plan from TPS
  %----------------------------
  [plan_dir,plan_file] = fileparts2(config.files.planFileName);
  handles= Import_plan(plan_dir,plan_file,'dcm','plan', handles);

  %Load irradiation logs
  %---------------------
  [record_dir,record_file] = fileparts2(config.files.RecordName);

  XDRconverter = fullfile(config.BeamProp.MCsqExecPath , 'data-recorder-proc-PlatfC-R8.FLASH_ER23-deploy.jar');
  [handles, beamInfoInLogs] = Import_tx_records(record_dir,record_file,'iba','logs',handles,'plan',config.files.AggregatePaintings , 0 , XDRconverter);

  %Convert date (string) into Matlab date format
  if isfield(beamInfoInLogs , 'START_BEAM_IRRADIATION')
    beamInfoInLogs.START_BEAM_IRRADIATION = datetime(beamInfoInLogs.START_BEAM_IRRADIATION,'InputFormat','dd/MM/yyyy HH:mm:ss.SSS');
  end
  if isfield(beamInfoInLogs , 'END_BEAM_IRRADIATION')
    beamInfoInLogs.END_BEAM_IRRADIATION   = datetime(beamInfoInLogs.END_BEAM_IRRADIATION,'InputFormat','dd/MM/yyyy HH:mm:ss.SSS');
  end

  %Compute the dose map
  %--------------------
  logID = find(strcmp(handles.plans.name , 'logs')); %identify the logs in handles

  BeamProp.NbScarves = 1; %umber of scarves to paint on the BEV
  BeamProp.FLAGOptimiseSpotOrder = false; %Do not optimise trajectory. Use the one read from logs
  BeamProp.FLAGcheckSpotOrdering = false; %Check that spot ordering in plan matches scanAlgo output

  BeamProp = copyFields(config.BeamProp , BeamProp);
  BeamProp.CEFDoseGrid =  num2cell(BeamProp.CEFDoseGrid);
  if isfield(config.RTstruct , 'DRPercentile')
    %If the percentile is provided copy it.
    BeamProp.DRPercentile = config.RTstruct.DRPercentile;
  end
  CEMprop.makeSTL = false;

  %Checking that the info in the log matches the info in the treatment plan
  setFlashDICOMdict(config.BeamProp.DICOMdict); %If not already defined, load the DICOM dictionary with private FLASH tags
  monoPlan = dicominfo(config.files.planFileName);
  validateLogsWithPlan(beamInfoInLogs , config);


  %Remove the tuning spots
  fprintf('Removing tuning spots \n')
  records = handles.plans.data{logID}{1};

  records.spots.spot_id = records.spots.spot_id(~records.spots.tuning);
  records.spots.xy = records.spots.xy(~records.spots.tuning , :);
  records.spots.weight = records.spots.weight(~records.spots.tuning);
  records.spots.metersetRate = records.spots.metersetRate(~records.spots.tuning);
  records.spots.timeStart = records.spots.timeStart(~records.spots.tuning);
  records.spots.timeStop = records.spots.timeStop(~records.spots.tuning);
  records.spots.time = records.spots.time(~records.spots.tuning);
  records.spots.duration= records.spots.duration(~records.spots.tuning);

  records.spots.tuning = records.spots.tuning(~records.spots.tuning);
  records.beamInfoInLogs = beamInfoInLogs;


  %Load plan from TPS and create a MIROPT |PLan| structure with the monolayer plan
  [handles, Plan] = flashLoadAndCompute(RSplanFileName, CTname , rtstructFileName , config.files.output_path , BeamProp , config.RTstruct.ExternalROI , CEMprop , [] , records);

end

%--------------------------------------------------------------------
function flag = validateLogsWithPlan(beamInfoInLogs , config)

  %Load the plan
  setFlashDICOMdict(config.BeamProp.DICOMdict); %If not already defined, load the DICOM dictionary with private FLASH tags
  monoPlan = dicominfo(config.files.planFileName);

  flag = true;
  flag = checkField(beamInfoInLogs.mPatientId , monoPlan.PatientID) .* flag;
  flag = checkField(beamInfoInLogs.mPlanId , monoPlan.SOPInstanceUID) .* flag;

end

%--------------------------------------------------------------------
function flag = checkField(logField , planField)
    flag = strcmp(logField , planField);

  if ~flag
    fprintf('In plan : %s \n', planField )
    fprintf('In logs : %s \n', logField )
    warning('Mismatch between log and plan')
  end

end
