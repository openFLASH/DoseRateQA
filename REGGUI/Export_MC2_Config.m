%% Export_MC2_Config
% Save the structure with the parameter for the MCsquare computation in a text file which will be read by the MCsquare executable. The parameters are saved in a text file in the |MC2_Config.WorkDir|.
%
%% Syntax
% |Export_MC2_Config(MC2_Config)|
%
%
%% Description
% |Export_MC2_Config(MC2_Config)| Save the parameters into a text file.
%
%
%% Input arguments
% |MC2_Config| - _STRUCTURE_ - Structure containing the parameters used by the MCsquare dose engine
%
% * |MC2_Config.WorkDir| - _STRING_ - Directory where the file will be saved.
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : K. Souris (open.reggui@gmail.com)

function Export_MC2_Config(MC2_Config , MCsqExecPath)

% MC2_functions_path = fileparts(mfilename('fullpath'));
% Template = fileread([MC2_functions_path '/ConfigTemplate.txt']); %This will not work with the compiler
Template = fileread(fullfile(MCsqExecPath , 'ConfigTemplate.txt'));

% Simulation parameters
Template = strrep(Template, '{NUMBER_OF_THREADS}', num2str(MC2_Config.NumberOfThreads));
Template = strrep(Template, '{RNG_SEED}', num2str(MC2_Config.RNG_seed));
Template = strrep(Template, '{NUMBER_OF_PRIMARIES}', num2str(MC2_Config.NumberOfPrimaries));
Template = strrep(Template, '{E_CUT_PRO}', num2str(MC2_Config.E_Cut_Pro));
Template = strrep(Template, '{D_MAX}', num2str(MC2_Config.D_Max));
Template = strrep(Template, '{EPSILON_MAX}', num2str(MC2_Config.Epsilon_Max));
Template = strrep(Template, '{TE_MIN}', num2str(MC2_Config.Te_Min));

% Input files
Template = strrep(Template, '{CT_FILE_NAME}', strrep(MC2_Config.CT, '\', '/'));
Template = strrep(Template, '{SCANNER_HU_DENSITY_CONVERSION}', strrep([MC2_Config.ScannerDirectory '/HU_Density_Conversion.txt'], '\', '/'));
Template = strrep(Template, '{SCANNER_HU_MATERIAL_CONVERSION}', strrep([MC2_Config.ScannerDirectory '/HU_Material_Conversion.txt'], '\', '/'));
Template = strrep(Template, '{BDL_FILE_NAME}', strrep(MC2_Config.BDL_File, '\', '/'));
Template = strrep(Template, '{PBS_PLAN_FILE_NAME}', strrep(MC2_Config.Plan, '\', '/'));

% Physical parameters
Template = Bool_MC2_Config(Template, '{ENABLE_NUCLEAR_INTER}', MC2_Config.Simulate_Nuclear_Interactions);
Template = Bool_MC2_Config(Template, '{ENABLE_SECONDARY_PROTONS}', MC2_Config.Simulate_Secondary_Protons);
Template = Bool_MC2_Config(Template, '{ENABLE_SECONDARY_DEUTERONS}', MC2_Config.Simulate_Secondary_Deuterons);
Template = Bool_MC2_Config(Template, '{ENABLE_SECONDARY_ALPHAS}', MC2_Config.Simulate_Secondary_Alphas);

% 4D simulation
Template = Bool_MC2_Config(Template, '{ENABLE_4D_MODE}', MC2_Config.Simu_4D_Mode);
Template = Bool_MC2_Config(Template, '{ENABLE_DOSE_ACCUMULATION}', MC2_Config.Dose_4D_Accumulation);
Template = strrep(Template, '{FIELD_TYPE}', MC2_Config.Field_type);
Template = Bool_MC2_Config(Template, '{ENABLE_REF_FROM_4DCT}', MC2_Config.Create_Ref_from_4DCT);
Template = Bool_MC2_Config(Template, '{ENABLE_4DCT_FROM_REF}', MC2_Config.Create_4DCT_from_Ref);
Template = Bool_MC2_Config(Template, '{ENABLE_DYNAMIC_DELIVERY}', MC2_Config.Dynamic_delivery);
Template = strrep(Template, '{BREATHING_PERIOD}', num2str(MC2_Config.Breathing_period));

% Robustness simulation
Template = Bool_MC2_Config(Template, '{ENABLE_ROBUSTNESS_MODE}', MC2_Config.Robustness_Mode);
Template = strrep(Template, '{ROBUSTNESS_SCENARIO_SELECTION}', MC2_Config.ScenarioSelection);
Template = Bool_MC2_Config(Template, '{ROBUSTNESS_COMPUTE_NOMINAL}',  MC2_Config.Robust_Compute_Nominal);
Template = strrep(Template, '{ROBUSTNESS_NUMBER_SCENARIOS}', num2str(MC2_Config.Num_Random_Scenarios));
Template = Vec_MC2_Config(Template, '{ROBUSTNESS_SYSTEMATIC_SETUP}', MC2_Config.Robust_Systematic_Setup);
Template = Vec_MC2_Config(Template, '{ROBUSTNESS_RANDOM_SETUP}', MC2_Config.Robust_Random_Setup);
Template = strrep(Template, '{ROBUSTNESS_RANGE_ERROR}', num2str(MC2_Config.Robust_Range_Error));
Template = strrep(Template, '{ROBUSTNESS_SYSTEMATIC_AMPLI}', num2str(MC2_Config.Robust_Systematic_Amplitude));
Template = strrep(Template, '{ROBUSTNESS_RANDOM_AMPLI}', num2str(MC2_Config.Robust_Random_Amplitude));
Template = strrep(Template, '{ROBUSTNESS_SYSTEMATIC_PERIOD}', num2str(MC2_Config.Robust_Systematic_Period));
Template = strrep(Template, '{ROBUSTNESS_RANDOM_PERIOD}', num2str(MC2_Config.Robust_Random_Period));

% Beamlet simulation
Template = Bool_MC2_Config(Template, '{ENABLE_BEAMLET_MODE}', MC2_Config.Beamlet_Mode);
Template = Bool_MC2_Config(Template, '{ENABLE_BEAMLET_PARALLEL}', MC2_Config.Beamlet_Parallelization);

% Statistical noise and stopping criteria
Template = Bool_MC2_Config(Template, '{ENABLE_STAT}', MC2_Config.ComputeStat);
Template = strrep(Template, '{STAT_UNCERTAINTY}', num2str(MC2_Config.StatUncertainty));
Template = Bool_MC2_Config(Template, '{STAT_IGNORE_LOW_DENSITY}', MC2_Config.Ignore_low_density_voxels);
Template = Bool_MC2_Config(Template, '{EXPORT_BATCH_DOSE}', MC2_Config.Export_batch_dose);
Template = strrep(Template, '{MAX_NUMBER_OF_PRIMARIES}', num2str(MC2_Config.Max_Num_Primaries));
Template = strrep(Template, '{MAX_SIMU_TIME}', num2str(MC2_Config.Max_Simulation_time));

% Output parameters
Template = strrep(Template, '{OUTPUT_DIR}', MC2_Config.Output_Directory);
Template = Bool_MC2_Config(Template, '{ENABLE_ENERGY_ASCII_OUT}', MC2_Config.Out_Energy_ASCII);
Template = Bool_MC2_Config(Template, '{ENABLE_ENERGY_MHD_OUT}', MC2_Config.Out_Energy_MHD);
Template = Bool_MC2_Config(Template, '{ENABLE_ENERGY_SPARSE_OUT}', MC2_Config.Out_Energy_Sparse);
Template = Bool_MC2_Config(Template, '{ENABLE_DOSE_ASCII_OUT}', MC2_Config.Out_Dose_ASCII);
Template = Bool_MC2_Config(Template, '{ENABLE_DOSE_MHD_OUT}', MC2_Config.Out_Dose_MHD);
Template = Bool_MC2_Config(Template, '{ENABLE_DOSE_SPARSE_OUT}', MC2_Config.Out_Dose_Sparse);
Template = Bool_MC2_Config(Template, '{ENABLE_LET_ASCII_OUT}', MC2_Config.Out_LET_ASCII);
Template = Bool_MC2_Config(Template, '{ENABLE_LET_MHD_OUT}', MC2_Config.Out_LET_MHD);
Template = Bool_MC2_Config(Template, '{ENABLE_LET_SPARSE_OUT}', MC2_Config.Out_LET_Sparse);
Template = Bool_MC2_Config(Template, '{ENABLE_DENSITIES_OUT}', MC2_Config.Out_Densities);
Template = Bool_MC2_Config(Template, '{ENABLE_MATERIALS_OUT}', MC2_Config.Out_Materials);
Template = Bool_MC2_Config(Template, '{ENABLE_COMPUTE_DVH}', MC2_Config.Compute_DVH);
Template = strrep(Template, '{DOSE_SPARSE_THRESHOLD}', num2str(MC2_Config.Dose_Sparse_Threshold));
Template = strrep(Template, '{ENERGY_SPARSE_THRESHOLD}', num2str(MC2_Config.Energy_Sparse_Threshold));
Template = strrep(Template, '{LET_SPARSE_THRESHOLD}', num2str(MC2_Config.LET_Sparse_Threshold));
Template = Bool_MC2_Config(Template, '{ENABLE_PG_SCORING}', MC2_Config.PG_scoring);
Template = strrep(Template, '{PG_LOW_CUT}', num2str(MC2_Config.PG_LowEnergyCut));
Template = strrep(Template, '{PG_HI_CUT}', num2str(MC2_Config.PG_HighEnergyCut));
Template = strrep(Template, '{PG_SPECTRUM_NUMBIN}', num2str(MC2_Config.PG_Spectrum_NumBin));
Template = strrep(Template, '{PG_SPECTRUM_BINNING}', num2str(MC2_Config.PG_Spectrum_Binning));
Template = strrep(Template, '{LET_METHOD}', MC2_Config.LET_Method);
Template = Bool_MC2_Config(Template, '{ENABLE_BEAM_DOSE}', MC2_Config.Export_beam_dose);
Template = strrep(Template, '{DOSE_TO_WATER}', MC2_Config.DoseToWater);
Template = Bool_MC2_Config(Template, '{ENABLE_SEGMENTATION}', MC2_Config.Dose_Segmentation);
Template = strrep(Template, '{SEGMENTATION_THRESHOLD}', num2str(MC2_Config.Density_Threshold_for_Segmentation));

if(MC2_Config.Independent_scoring_grid==1)
    Template = Bool_MC2_Config(Template, '{ENABLE_INDEPENDENT_SCORING}', MC2_Config.Independent_scoring_grid);
    Template = Vec_MC2_Config(Template, '{SCORING_ORIGIN}', MC2_Config.Scoring_origin);
    Template = Vec_MC2_Config(Template, '{SCORING_SIZE}', MC2_Config.Scoring_grid_size);
    Template = Vec_MC2_Config(Template, '{SCORING_SPACING}', MC2_Config.Scoring_voxel_spacing);
    Template = strrep(Template, '{SCORING_WEIGHTING_ALGO}', MC2_Config.Dose_weighting_algorithm);
else
    Template = Template(1:strfind(Template,'Independent_scoring_grid')-1);
end

disp(['Write configuration file: ' fullfile(MC2_Config.WorkDir , 'config.txt')]);
Destination = fopen(fullfile(MC2_Config.WorkDir , 'config.txt'), 'w', 'l');
fprintf(Destination, Template);
fclose(Destination);

end

function Template_out = Bool_MC2_Config(Template, Tag, Value)

if(Value == 1 || strcmpi(Value, 'true') == 1)
    Template_out = strrep(Template, Tag, 'True');
else
    Template_out = strrep(Template, Tag, 'False');
end

end

function Template_out = Vec_MC2_Config(Template, Tag, Values)

tmp = [num2str(Values(1)) ' ' num2str(Values(2)) ' ' num2str(Values(3))];
Template_out = strrep(Template, Tag, tmp);

end
