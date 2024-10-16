%% runDRqa
% Load the irradiation logs and compute
%   * the dose map using records from the logs
%   * the dose rate map using records from the logs
% Then run some statistical tests on the DADR map
%
%% Syntax
% |handles = runDRqa(configFile)|
%
%
%% Description
% |handles = runDRqa(configFile)| Description
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

function   [handles, Plan] = runDRqa(config)

totalTimeTic = tic;
global g_totalMC2Time;
g_totalMC2Time = 0;

%Load DICOM data and run computation of dose and dose rate
DateStart = string(datetime('now'));
[handles, Plan , beamInfoInLogs] = fC_logAnalysis(config);

%Create a log file and save results
PlanData = dicominfo(config.files.planFileName);

fid = fopen(fullfile(config.files.output_path , 'Outputs' , 'Results.txt') , 'w');
fprintf(fid , 'Date (start) : %s \n', DateStart);
fprintf(fid , 'Plan name : %s \n', Plan.name);
fprintf(fid , 'Plan PatientID : %s \n', PlanData.PatientID);
fprintf(fid , 'Plan SOPInstanceUID : %s \n', PlanData.SOPInstanceUID);
fprintf(fid , 'Plan SeriesInstanceUID : %s \n', PlanData.SeriesInstanceUID);

fprintf(fid , 'Log PatientID : %s \n', beamInfoInLogs.mPatientId);
fprintf(fid , 'Log Plan ID : %s \n', beamInfoInLogs.mPlanId);
fprintf(fid , 'Log beam ID : %s \n', beamInfoInLogs.mBeamId);
fprintf(fid , 'Log fraction ID : %s \n', beamInfoInLogs.mFractionId);
fprintf(fid , 'Log Beam Delivery Point ID : %s \n', beamInfoInLogs.mBeamDeliveryPointId);
fprintf(fid , 'Log Beam Supply Point ID : %s \n', beamInfoInLogs.mBeamSupplyPointId);
fprintf(fid , 'Log gantry angle : %d \n', beamInfoInLogs.mGantryAngle);
fprintf(fid , 'Log irradiation start time : %s \n', string(beamInfoInLogs.START_BEAM_IRRADIATION , 'eeee, MMMM d, yyyy HH:mm:ss.SSS'));
fprintf(fid , 'Log irradiation end time : %s \n', string(beamInfoInLogs.END_BEAM_IRRADIATION , 'eeee, MMMM d, yyyy HH:mm:ss.SSS'));

json=savejson([],config);
fprintf(fid , '%s \n', json); %Save config data to log file


% Load the dose rate results and compute statistics
for b = 1:length(Plan.Beams)

  %load all the images
  path2beamResults = getOutputDir(Plan.output_path , b);
  DRfilename = ['DADR_beam_',num2str(b),'_in_' , Plan.CTname ,'_' , config.RTstruct.ExternalROI]; %Dose rate map already in handles


  Dfilename = fullfile(path2beamResults , 'Dose_withCEF.dcm');
  Dname = ['Dose_beam_',num2str(b)];
  [handles , DADRname] = Import_image(path2beamResults, DRfilename , 'dcm', Dname , handles); %Load dose through CEM

  RSfilename = fullfile(path2beamResults , 'Dose_withCEF.dcm');
  [handles , structName] = Import_contour(config.files.rtstructFileName,{config.Analysis.Target},Plan.CTname,1,handles); %Load target structure

  %Get the data from the REGGUI handle
  CTV = Get_reggui_data(handles , structName);
  DADR = Get_reggui_data(handles , DADRname);
  Dose = Get_reggui_data(handles , Dname);


  %Compute the stats on the data
  Selected = logical((Dose > config.Analysis.DoseMin) .* CTV);
  DADR2test = DADR(Selected);
  DADRmin = min(DADR2test , [] , 'all');
  DADRav = mean(DADR2test , 'all');


  fprintf('Beam %d [%s] : Minimum DADR in %s (D> %f Gy) = %f Gy/s \n', b, Plan.Beams(b).name, config.Analysis.Target , config.Analysis.DoseMin , DADRmin);
  fprintf('Beam %d [%s] : Average DADR in %s (D> %f Gy) = %f Gy/s \n', b, Plan.Beams(b).name, config.Analysis.Target , config.Analysis.DoseMin , DADRav);

  fprintf(fid ,'Beam %d [%s] : Minimum DADR in %s (D> %f Gy) = %f Gy/s \n', b, Plan.Beams(b).name, config.Analysis.Target , config.Analysis.DoseMin , DADRmin);
  fprintf(fid ,'Beam %d [%s] : Average DADR in %s (D> %f Gy) = %f Gy/s \n', b, Plan.Beams(b).name, config.Analysis.Target , config.Analysis.DoseMin , DADRav);

end

fprintf(fid , 'Date (end) : %s \n', string(datetime('now')));
fclose(fid);

fprintf('\n*****************************************************\n')
fprintf('Script performance report\n')
totalTime = toc(totalTimeTic);
fprintf('Total time: %.0f s\n', totalTime)
fprintf('Total MCsquare Time: %.0f s\n', g_totalMC2Time)
fprintf('Total Matlab time: %.0f s\n', totalTime - g_totalMC2Time)
fprintf('*****************************************************\n')

end
