%% Generate_MC2_Config
% Generate a structure containing the parameter that can be used by the MCsquare dose engine. The structure contains the default value of most of the parameters and the value that are provided in input to the function.. The parameters are saved in a text file in the |WorkDir|
%
%% Syntax
% |MC2_Config = Generate_MC2_Config( WorkDir, NumberOfPrimaries, CT, Plan )|
%
% |MC2_Config = Generate_MC2_Config( WorkDir, NumberOfPrimaries, CT, Plan, ScannerDirectory)|
%
% |MC2_Config = Generate_MC2_Config( WorkDir, NumberOfPrimaries, CT, Plan, ScannerDirectory, BDL_File)|
%
%
%% Description
% |MC2_Config = Generate_MC2_Config( WorkDir, NumberOfPrimaries, CT, Plan)| Description
%
% |MC2_Config = Generate_MC2_Config( WorkDir, NumberOfPrimaries, CT, Plan, ScannerDirectory, BDL_File )| Description
%
%
%% Input arguments
% |WorkDir| - _STRING_ - Directory where the temporary files will be saved.
%
% |NumberOfPrimaries| - _INTEGER_ - Number of protons to use in MC computations
%
% |CT| - _STRING_ - Name of the MHD file containing the CT scan. The file is in the |WorkDir|
%
% |Plan| - _STRING_ - Name of the text file containing the description of the PBS spots. The file is in the |WorkDir|
%
% |ScannerDirectory| - _STRING_ - [OPTIONAL. Default: './plugins/openMCsquare/lib/Scanners/SolidWater_Phantom'] Name of the folder (with full path) (in ./openREGGUI-mc2/lib/Scanners) containing the files for the conversion model from HU to stopping power
%
% |BDL_File| - _STRING_ - [OPTIONAL. Default = './plugins/openMCsquare/lib/BDL/BDL_default_1.txt' ] Name of the file (iwth full path) with the description of the beam data library (BDL) of the treatment machine. The file is stored in the directory './openREGGUI-mc2/lib/BDL'.
%
%
%% Output arguments
%
% |MC2_Config| - _STRUCTURE_ - Structure containing the parameters used by the MCsquare dose engine
%
%
%% Contributors
% Authors : K. Souris (open.reggui@gmail.com)

function  MC2_Config = Generate_MC2_Config( WorkDir, NumberOfPrimaries, CT, Plan, ScannerDirectory, BDL_File , MCsqExecPath)


if(nargin < 5)
    [~  , ~ , ~ , ~ , ScannerDirectory] = get_MCsquare_folders('SolidWater_Phantom');
end
if(nargin < 6)
    [~ , ~ , BDL_File , ~ , ~] = get_MCsquare_folders([] , 'BDL_default_1.txt');
end

%Complete the full path to scanner directory and BDL
%[~ , ~ , BDL_File , ~ , ScannerDirectory] = get_MCsquare_folders(ScannerDirectory , BDL_File); %Tjhis will not work with compiler

MC2_Config.WorkDir = WorkDir;

% Simulation parameters
MC2_Config.NumberOfThreads = 0;
MC2_Config.RNG_seed = 1;
MC2_Config.NumberOfPrimaries = NumberOfPrimaries;
MC2_Config.E_Cut_Pro = 0.5;
MC2_Config.D_Max = 0.2;
MC2_Config.Epsilon_Max = 0.25;
MC2_Config.Te_Min = 0.05;

% Input files
MC2_Config.CT = CT;
MC2_Config.ScannerDirectory = ScannerDirectory;
MC2_Config.BDL_File = BDL_File;
MC2_Config.Plan = Plan;

% Physical parameters
MC2_Config.Simulate_Nuclear_Interactions = 1;
MC2_Config.Simulate_Secondary_Protons = 1;
MC2_Config.Simulate_Secondary_Deuterons = 1;
MC2_Config.Simulate_Secondary_Alphas = 1;

% 4D simulation
MC2_Config.Simu_4D_Mode = 0;
MC2_Config.Dose_4D_Accumulation = 0;
MC2_Config.Field_type = 'Velocity';
MC2_Config.Create_Ref_from_4DCT = 0;
MC2_Config.Create_4DCT_from_Ref = 0;
MC2_Config.Dynamic_delivery = 0;
MC2_Config.Breathing_period = 7.0;
MC2_Config.CT_phases=0;

% Robustness simulation
MC2_Config.Robustness_Mode = 0;
MC2_Config.ScenarioSelection = 'All';
MC2_Config.Robust_Compute_Nominal = 1;
MC2_Config.Num_Random_Scenarios = 100;
MC2_Config.Robust_Systematic_Setup = [0.25 0.25 0.25];
MC2_Config.Robust_Random_Setup = [0.1  0.1  0.1];
MC2_Config.Robust_Range_Error = 3.0;
MC2_Config.Robust_Systematic_Amplitude = 5.0;
MC2_Config.Robust_Random_Amplitude = 5.0;
MC2_Config.Robust_Systematic_Period = 5.0;
MC2_Config.Robust_Random_Period = 5.0;

% Beamlet simulation
MC2_Config.Beamlet_Mode = 0;
MC2_Config.Beamlet_Parallelization = 0;

% Statistical noise and stopping criteria
MC2_Config.ComputeStat = 0;
MC2_Config.StatUncertainty = 0.0;
MC2_Config.Ignore_low_density_voxels = 1;
MC2_Config.Export_batch_dose = 0;
MC2_Config.Max_Num_Primaries = 0;
MC2_Config.Max_Simulation_time = 0;

% Output parameters
MC2_Config.Output_Directory = 'Outputs';
MC2_Config.Out_Energy_ASCII = 0;
MC2_Config.Out_Energy_MHD = 0;
MC2_Config.Out_Energy_Sparse = 0;
MC2_Config.Out_Dose_ASCII = 0;
MC2_Config.Out_Dose_MHD = 1;
MC2_Config.Out_Dose_Sparse = 0;
MC2_Config.Out_LET_ASCII = 0;
MC2_Config.Out_LET_MHD = 0;
MC2_Config.Out_LET_Sparse = 0;
MC2_Config.Out_Densities = 0;
MC2_Config.Out_Materials = 0;
MC2_Config.Compute_DVH = 0;
MC2_Config.Dose_Sparse_Threshold = 0.0;
MC2_Config.Energy_Sparse_Threshold = 0.0;
MC2_Config.LET_Sparse_Threshold = 0.0;
MC2_Config.PG_scoring = 0;
MC2_Config.PG_LowEnergyCut = 0.0;
MC2_Config.PG_HighEnergyCut = 50.0;
MC2_Config.PG_Spectrum_NumBin = 150;
MC2_Config.PG_Spectrum_Binning = 0.1;
MC2_Config.LET_Method = 'StopPow';
MC2_Config.Export_beam_dose = 0;
MC2_Config.DoseToWater = 'Disabled';
MC2_Config.Dose_Segmentation = 0;
MC2_Config.Density_Threshold_for_Segmentation = 0.01;

MC2_Config.Independent_scoring_grid = 0;
MC2_Config.Scoring_origin = [0.0 0.0 0.0];
MC2_Config.Scoring_grid_size = [100 100 100];
MC2_Config.Scoring_voxel_spacing = [0.15 0.15 0.15];
MC2_Config.Dose_weighting_algorithm = 'Volume';

Export_MC2_Config(MC2_Config , MCsqExecPath);
end
