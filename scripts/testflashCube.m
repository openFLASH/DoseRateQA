clear
close all

config.files.output_path = 'D:\programs\openREGGUI\REGGUI_userdata\raystation\cube_out_G0';
config.files.planFileName = 'D:\programs\openREGGUI\REGGUI_userdata\raystation\cube444-at4-600mm\plan_FLASH_Pplus.dcm';
config.files.rtstructFileName = 'D:\programs\openREGGUI\REGGUI_userdata\raystation\cube444-at4-600mm\RS1.2.752.243.1.1.20230112085023538.3510.62085.dcm';
config.files.CTname = fullfile('D:\programs\openREGGUI\REGGUI_userdata\UPENN\logAnalysisAzar\DICOM\reggui_water' , 'reggui_water_0001.dcm');
config.files.output_path = 'D:\programs\openREGGUI\REGGUI_userdata\raystation\cube_out_G0';

config.files.AggregatePaintings = 0;


config.RTstruct.ExternalROI = 'WaterCube'; %name for external ROI - the body contour
config.RTstruct.DRPercentile = 0.95; %Not used anyway

config.BeamProp.CEFDoseGrid = [2, 2, 2]; % Size (mm) of final dose scoring grid. Compute the final dose through CEF on a different grid than the high-res
config.BeamProp.protonsHighResDose = 1e5; %TODO Number of protons in the dose in high resolution CT
config.BeamProp.BDL = 'D:\programs\openREGGUI\flash_qa\data\BDL\BDL_default_UN1_G0_Al_RangeShifter_tilted.txt'; %Identify the BDL file name from the treatment machine name in the plan
config.BeamProp.ScannerDirectory = 'D:\programs\openREGGUI\flash_qa\data\Scanners\default';
config.BeamProp.MCsqExecPath = 'D:\programs\openREGGUI\flash_qa\openMCsquare';

config.BeamProp.DICOMdict = fullfile(config.BeamProp.MCsqExecPath , 'dicom-dict.txt');


[handles, Plan] = PlanSecondaryCheck(config);
