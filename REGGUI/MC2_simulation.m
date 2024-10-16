%% MC2_simulation
% Compute the dose distribution delivered by a PBS proton treatment plan using the MCsquare dose engine.
% The function will:
%
% * Reformat the input data nad the simulation parameter and save them to text files that can be read by the MCsquare executable
% * Run the MCsquare simulation by calling |MC2_compute|
%
% Depending on the simulation parameter, up to three images will be added to |handles.images| : a dose map, a deposited energy map and a LET map.
%
%% Syntax
% |handles = MC2_simulation(handles)|
%
% |handles = MC2_simulation(handles,SimuParam)|
%
% |handles = MC2_simulation(handles,image_name,plan_name,im_dest,Simu_dir)|
%
% |handles = MC2_simulation(handles,image_name,plan_name,im_dest,Simu_dir,SimulatedProtons)|
%
% |handles = MC2_simulation(handles,image_name,plan_name,im_dest,Simu_dir,SimulatedProtons,CT_CalibFiles)|
%
% |handles = MC2_simulation(handles,image_name,plan_name,im_dest,Simu_dir,SimulatedProtons,CT_CalibFiles,BDL_File)|
%
% |handles = MC2_simulation(handles,image_name,plan_name,im_dest,Simu_dir,SimulatedProtons,CT_CalibFiles,BDL_File,DoseToWater)|
%
% |handles = MC2_simulation(handles,image_name,plan_name,im_dest,Simu_dir,SimulatedProtons,CT_CalibFiles,BDL_File,DoseToWater,LET)|
%
%
%% Description
% |handles = MC2_simulation(handles)| Display a GUI to define the parameters, then run the MCsquare computation. For the parameters not selected by the GUI, their default value will be used.
%
% % |handles = MC2_simulation(handles,SimuParam)| Run the MCsquare computation using the parameters defined in the structure |SimuParam|
%
% |handles = MC2_simulation(handles,image_name,plan_name,im_dest,Simu_dir,SimulatedProtons,CT_CalibFiles,BDL_File,DoseToWater,LET)| Run the MCsquare computation using the specified parameters.
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images|
% * |handles.mydata|
% * |handles.plans|
%
% |image_name| - _STRING_ - Name of the planning CT scan in |handles.images| or |handles.mydata|
%
% |plan_name| - _STRING_ - Name ofthe RT-Ion plan (PBS mode) in |handles.plans|
%
% |im_dest| - _STRING_ - Name of the resulting dose map that will be stored in |handles.images|
%
% |Simu_dir| - _STRING_ - Directory where the temporary files will be saved.
%
% |SimulatedProtons| - _INTEGER_ - [OPTIONAL. Default 1e7] Number of protons to use in MC computations
%
% |CT_CalibFiles| - _STRING_ - [OPTIONAL. Default: 'SolidWater_Phantom'] Name of the folder (in ./openREGGUI-mc2/lib/Scanners) containing the files for the conversion model from HU to stopping power
%
% |BDL_File| - _STRING_ - [OPTIONAL. Default = 'BDL_default_1.txt' ] Name of the file with the description of the beam data library (BDL) of the treatment machine. The file is stored in the directory './openREGGUI-mc2/lib/BDL'.
%
% |DoseToWater| - _INTEGER_ - [OPTIONAL. Default = 0] 1 = Convert the dose computed by MCsquare (= dose to medium) into the dose to water (which is typically computed by the TPS). MCsquare uses the true elemental ocmposition of the material and therefore compute the dose to medium by default (|DoseToWater=0|).
%
% |LET| - _INTEGER_ - [OPTIONAL. Default = 0] 1 = export the LET map
%
% |SimuParam| - _STRUCTURE_ - Structure defining the simulation parameters:
%
% * -- |SimuParam.RunSimu| - _INTEGER_ - 1 = Run the MC simulation. Otherwise, do not run the MC simulation
% * -- |SimuParam.Folder| - _STRING_ -  See parameter |Simu_dir|
% * -- |SimuParam.CT|- _STRING_ -  See parameter |image_name|
% * -- |SimuParam.Plan|- _STRING_ -  See parameter |plan_name|
% * -- |SimuParam.Scanner|- _STRING_ -  See parameter |CT_CalibFiles|
% * -- |SimuParam.BDL|- _STRING_ -  See parameter |BDL_File|
% * -- |SimuParam.NumberOfPrimaries| - _INTEGER_ -   See parameter |SimulatedProtons|
% * -- |SimuParam.NumberOfThreads| - _INTEGER_ - Number of thread to use for computation. |SimuParam.NumberOfThreads=0| will use ALL the threads.
% * -- |SimuParam.Dose| - _INTEGER_ - 1 = Export the dose map.
% * -- |SimuParam.DoseFileName| - _STRING_ - File name of the dose map. If empty; do not save dose file on disk
% * -- |SimuParam.DoseName| - _STRING_ - Name of the dose map in |handles.images| where to save the dose map
% * -- |SimuParam.Energy| - _INTEGER_ - 1 = Export the energy map
% * -- |SimuParam.EnergyName| - _STRING_ - File name of the energy map
% * -- |SimuParam.LET| - _INTEGER_ -  See parameter |LET|
% * -- |SimuParam.LETName| - _STRING_ - File name of the LET map
% * -- |SimuParam.DoseToWater| - _INTEGER_ - See parameter |DoseToWater|
% * -- |SimuParam.CropBody| - _INTEGER_ -  1 = replace all voxel outside of the body contour by HU = -1000 (air)
% * -- |SimuParam.BodyContour| - _STRING_ - Name of the image in |handles.images| that contains the definition of the body mask
% * -- |SimuParam.OverwriteHU| - _CELL VECTOR_ - Definition of the structure for which the Hounsfield unit of the CT scan must be overwritten:
% * ----|SimuParam.OverwriteHU{j,1}| - _STRING_ - Name of the image in |handles.images| containing the mask defining the jth structure
% * ----|SimuParam.OverwriteHU{j,2}| - _INTEGER_ - The j-th structure shall be overwritten with this value of HU
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated :
%
% * |handles.image.name{i}| - _STRING_ - Name of the ith image
% * |handles.image.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| resulting intensity at voxel (x,y,z)
% * |handles.image.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
%
% Up to three images will be added to |handles.images| : a dose map (|im_dest| in Gy), a deposited energy map ('MCsquare_energy' in J) and a LET map ('MCsquare_LET' in keV/um).
%
%
%% Contributors
% Authors : K. Souris, G.Janssens (open.reggui@gmail.com)

function [handles,DoseNames] = MC2_simulation(handles, varargin)
global g_totalMC2Time;

current_dir = pwd;

% add folders to path
%[~ , MC2_lib_path ] = get_MCsquare_folders();


if(nargin==1) % call from regguiC (i.e. without input argument)
    SimuParam = MCsquare_Param_GUI(handles);

    if(norm(SimuParam.Scoring_voxel_spacing - handles.spacing') > 0.01)
        SimuParam.Independent_scoring_grid = 1;
    end

    ParamList = fieldnames(SimuParam);

    if(handles.reggui_mode)
        endl = '';
    else
        endl = sprintf('\n');
    end

    instructions = cell(1);
    instructions{1} = [instructions{1}, endl];

    for i=1:length(ParamList)
        Value = getfield(SimuParam, ParamList{i});
        if(isnumeric(Value) || islogical(Value))
	  if(length(Value) == 1)
            instructions{1} = [instructions{1}, 'SimuParam.', ParamList{i} ,' = ', num2str(Value) ,'; ', endl];
          else
            instructions{1} = [instructions{1}, 'SimuParam.', ParamList{i} ,' = [', num2str(Value) ,']; ', endl];
	  end
        elseif(ischar(Value))
            instructions{1} = [instructions{1}, 'SimuParam.', ParamList{i} ,' = ''', num2str(Value) ,'''; ', endl];
        elseif(iscell(Value))
            NumRows = size(Value, 1);
            NumCols = size(Value, 2);
            tmp = ['SimuParam.', ParamList{i} ,' = {'];
            for j=1:NumRows
                for k=1:NumCols
                    if(isnumeric(Value{j,k}) || islogical(Value{j,k}))
                        tmp = [tmp num2str(Value{j,k})];
                    elseif(ischar(Value{j,k}))
                        tmp = [tmp '''' num2str(Value{j,k}) ''''];
                    end
                    if(k < NumCols)
                        tmp = [tmp ', '];
                    end
                end
                if(j < NumRows)
                    tmp = [tmp '; '];
                end
            end
            tmp = [tmp '}; ' endl];
            instructions{1} = [instructions{1}, tmp];
        else
            warning(['Class not compatible for SimulationParam.' ParamList{i} ': ' class(Value)]);
        end
    end

    if(handles.reggui_mode)
        instructions{1} = [instructions{1},' handles = MC2_simulation(handles, SimuParam);'];
    else
        instructions{end+1} = 'handles = MC2_simulation(handles, SimuParam);';
    end

    handles = instructions;

    return

elseif(nargin == 2)
    SimuParam = varargin{1};
    MC2_lib_path = SimuParam.openMCsquarePath;
else

    if(nargin < 5)
        error('At least 5 inputs are required: handles, image_name, plan_name, im_dest, Simu_dir');
    end

    SimuParam.RunSimu = 1;
    SimuParam.Folder = varargin{4};
    SimuParam.CT = varargin{1};
    SimuParam.Plan = varargin{2};
    SimuParam.Dose = 1;
    SimuParam.DoseName = varargin{3};
    SimuParam.EnergyName = 'MCsquare_energy';
    SimuParam.LETName = 'MCsquare_LET';

    if(nargin < 6)
        SimuParam.NumberOfPrimaries = 1E7;
    else
        SimuParam.NumberOfPrimaries = varargin{5};
    end

    if(nargin < 7)
        SimuParam.Scanner = 'default';
    else
        SimuParam.Scanner = varargin{6};
    end

    if(nargin < 8)
        SimuParam.BDL = 'BDL_default_1.txt';
    else
        SimuParam.BDL = varargin{7};
    end

    if(nargin < 9)
        SimuParam.DoseToWater = 0;
    else
        SimuParam.DoseToWater = varargin{8};
    end

    if(nargin < 10)
        SimuParam.LET = 0;
    else
        SimuParam.LET = varargin{9};
    end

    if(nargin < 11)
        SimuParam.NumberOfThreads = 0;
    else
        SimuParam.NumberOfThreads = varargin{10};
    end

end

% Set default parameters
SimuParam = Add_Default_MC2_SimuParams(SimuParam);

% Check that simulation must be started
if(SimuParam.RunSimu < 1)
    return
end

% Check BDL and Scanner filenames
%[~ , ~ , SimuParam.BDL , ~ , SimuParam.Scanner] = get_MCsquare_folders(SimuParam.Scanner , SimuParam.BDL); %This will not work with the compiler


if(not(isfield(SimuParam,'SparseFormat')))
    SimuParam.SparseFormat = 0;
end

% Create simulation folder
if(not(exist(SimuParam.Folder,'dir')))
    mkdir(SimuParam.Folder)
end

% Export CT image
[ ct, info ] = Prepare_CT_for_MC2( handles, SimuParam );
Export_MC2_CT(SimuParam, ct, info);

% Export 4D data (CT phases, deformation fields)
if(SimuParam.Simu4D == 1)
  mkdir(fullfile(SimuParam.Folder, '4DCT'))
  for p=1:length(SimuParam.CT_phases)
    [ phase_data, phase_info ] = Prepare_CT_for_MC2( handles, SimuParam, SimuParam.CT_phases{p} );
    Export_MC2_CT(SimuParam, phase_data, phase_info, fullfile(SimuParam.Folder, '4DCT', ['CT_' num2str(p) '.mhd']));
  end
  handles = Prepare_deformation_fields(handles, SimuParam, 1); % 1 = log_domain
end


% Export PBS Plan
[ plan, plan_info ] = Prepare_Plan_for_MC2( handles, SimuParam, info );
disp(['Export PBS Plan: ' fullfile(SimuParam.Folder, 'PlanPencil.txt')]);
Save_MC2_Plan(plan, plan_info, fullfile(SimuParam.Folder, 'PlanPencil.txt'), 'gate');


% Generate MC2 configuration file
MC2_Config = Generate_MC2_Config(SimuParam.Folder, SimuParam.NumberOfPrimaries, 'CT.mhd', 'PlanPencil.txt', SimuParam.Scanner, SimuParam.BDL , MC2_lib_path);
MC2_Config.NumberOfThreads = SimuParam.NumberOfThreads;
if(SimuParam.Dose == 0)
    MC2_Config.Out_Dose_MHD = 0;
end
if(SimuParam.Energy == 1)
    MC2_Config.Out_Energy_MHD = 1;
end
if(SimuParam.LET == 1)
    MC2_Config.Out_LET_MHD = 1;
end
if(SimuParam.Export_beam_dose == 1)
    MC2_Config.Export_beam_dose = 1;
end
if(SimuParam.Export_beamlet == 1)
    MC2_Config.Beamlet_Mode = 1;
    MC2_Config.Beamlet_Parallelization = 1;
end
if(SimuParam.DoseToWater == 1)
    %MC2_Config.DoseToWater = 'PostProcessing';
    MC2_Config.DoseToWater = 'OnlineSPR';
end
if(SimuParam.ProtonOnly == 1)
    MC2_Config.Simulate_Nuclear_Interactions = 1;
    MC2_Config.Simulate_Secondary_Protons = 1;
    MC2_Config.Simulate_Secondary_Deuterons = 0;
    MC2_Config.Simulate_Secondary_Alphas = 0;
end
if(SimuParam.ComputeStat ~= 0)
    MC2_Config.ComputeStat = 1;
    MC2_Config.StatUncertainty = SimuParam.StatUncertainty;
    if(isfield(SimuParam,'Ignore_low_density_voxels'))
        if(not(isempty(SimuParam.Ignore_low_density_voxels)))
            MC2_Config.Ignore_low_density_voxels = SimuParam.Ignore_low_density_voxels;
        end
    end
    if(isfield(SimuParam,'Export_batch_dose'))
        if(not(isempty(SimuParam.Export_batch_dose)))
            MC2_Config.Export_batch_dose = SimuParam.Export_batch_dose;
        end
    end
    if(isfield(SimuParam,'Max_Num_Primaries'))
        if(not(isempty(SimuParam.Max_Num_Primaries)))
            MC2_Config.Max_Num_Primaries = SimuParam.Max_Num_Primaries;
        end
    end
    if(isfield(SimuParam,'Max_Simulation_time'))
        if(not(isempty(SimuParam.Max_Simulation_time)))
            MC2_Config.Max_Simulation_time = SimuParam.Max_Simulation_time;
        end
    end
end

if(SimuParam.Simu4D == 1)
    MC2_Config.Simu_4D_Mode = 1;
    MC2_Config.Dose_4D_Accumulation = SimuParam.Dose_4D_Accumulation;
    MC2_Config.Field_type = 'Velocity'; % 'Velocity' if log_domain, 'Displacement' otherwise;
    MC2_Config.Create_Ref_from_4DCT = 0;
    MC2_Config.Create_4DCT_from_Ref = 0;
    MC2_Config.Dynamic_delivery = 0;
end

if(isfield(SimuParam,'E_Cut_Pro'))
    MC2_Config.E_Cut_Pro = SimuParam.E_Cut_Pro;
end
if(isfield(SimuParam,'D_Max'))
    MC2_Config.D_Max = SimuParam.D_Max;
end
if(isfield(SimuParam,'Epsilon_Max'))
    MC2_Config.Epsilon_Max = SimuParam.Epsilon_Max;
end
if(isfield(SimuParam,'Te_Min'))
    MC2_Config.Te_Min = SimuParam.Te_Min;
end
if(isfield(SimuParam,'Simulate_Nuclear_Interactions'))
    MC2_Config.Simulate_Nuclear_Interactions = SimuParam.Simulate_Nuclear_Interactions;
end
if(isfield(SimuParam,'Simulate_Secondary_Protons'))
    MC2_Config.Simulate_Secondary_Protons = SimuParam.Simulate_Secondary_Protons;
end
if(isfield(SimuParam,'Simulate_Secondary_Deuterons'))
    MC2_Config.Simulate_Secondary_Deuterons = SimuParam.Simulate_Secondary_Deuterons;
end
if(isfield(SimuParam,'Simulate_Secondary_Alphas'))
    MC2_Config.Simulate_Secondary_Alphas = SimuParam.Simulate_Secondary_Alphas;
end

if(SimuParam.Robustness_Mode == 1)
   MC2_Config.Robustness_Mode = 1;
   if(SimuParam.ScenarioSampling == 0)
   	MC2_Config.ScenarioSelection = 'All';
   else
   	MC2_Config.ScenarioSelection = 'Random';
   	MC2_Config.Num_Random_Scenarios = SimuParam.NumScenarios;
   end
   MC2_Config.Robust_Compute_Nominal = 1;
   MC2_Config.Robust_Systematic_Setup = SimuParam.setup_systematic / 10;
   MC2_Config.Robust_Random_Setup = SimuParam.setup_random / 10;
   MC2_Config.Robust_Range_Error = SimuParam.range_systematic;
   MC2_Config.Robust_Systematic_Amplitude = 0.0;
   MC2_Config.Robust_Random_Amplitude = 0.0;
   MC2_Config.Robust_Systematic_Period = 0.0;
   MC2_Config.Robust_Random_Period = 0.0;
end

if(SimuParam.SparseFormat == 1 && SimuParam.Dose == 1)
  MC2_Config.Out_Dose_Sparse = 1;
  MC2_Config.Out_Dose_MHD = 0;
end
if(SimuParam.SparseFormat == 1 && SimuParam.Energy == 1)
  MC2_Config.Out_Energy_Sparse = 1;
  MC2_Config.Out_Energy_MHD = 0;
end
if(SimuParam.SparseFormat == 1 && SimuParam.LET == 1)
  MC2_Config.Out_LET_Sparse = 1;
  MC2_Config.Out_LET_MHD = 0;
end

if(SimuParam.Independent_scoring_grid == 1)
    if(not(isfield(SimuParam,'Scoring_voxel_spacing')))
        SimuParam.Scoring_voxel_spacing = handles.spacing';
    end
    if(not(isfield(SimuParam,'Scoring_grid_size')))
        SimuParam.Scoring_grid_size = floor( (size(ct)' .* info.Spacing(:)) ./ SimuParam.Scoring_voxel_spacing(:) - 1e-3);
    end
    if(not(isfield(SimuParam,'Scoring_origin')))
        SimuParam.Scoring_origin = info.ImagePositionPatient;
    end
    % transfer scoring grid geometry into MC2 config space
    MC2_Config.Independent_scoring_grid = 1;
    MC2_Config.Scoring_grid_size = SimuParam.Scoring_grid_size;
    MC2_Config.Scoring_voxel_spacing = SimuParam.Scoring_voxel_spacing/10;% mm -> cm
    MC2_Config.Scoring_origin = Dicom_to_MC2_coordinates(SimuParam.Scoring_origin, SimuParam.Scoring_voxel_spacing, SimuParam.Scoring_voxel_spacing(:).*SimuParam.Scoring_grid_size(:))' /10;% mm -> cm and inversion of Y, which is flipped in MCsquare
    MC2_Config.Dose_weighting_algorithm = SimuParam.Dose_weighting_algorithm;

end

Export_MC2_Config(MC2_Config, MC2_lib_path);

% Check pathnames
if(not(isempty(strfind(MC2_Config.ScannerDirectory,' '))))
    disp('Warning: space in scanner path name.')
end
if(not(isempty(strfind(MC2_Config.BDL_File,' '))))
    disp('Warning: space in BDL path name.')
end

% Run simulation
tempMC2Tic = tic;
try
    MC2_compute(SimuParam.Folder, MC2_lib_path, MC2_Config );
catch
    fprintf(2,'    ERROR during MCsquare instruction preparation:');
    err = lasterror;
    disp([' ',err.message]);
    disp(err.stack(1));
    return
end
g_totalMC2Time = g_totalMC2Time + toc(tempMC2Tic);

if(SimuParam.Robustness_Mode == 1)
   SimuParam.plan_info = plan_info;
   SimuParam.ct_info = info;
   SimuParam.MC2_Config = MC2_Config;
   handles = Robustness_analysis(handles, SimuParam);
   return;
end


suffix = {};
if(SimuParam.Export_beam_dose == 1)
    for i=1:length(plan)
        suffix{i} = ['_Beam' num2str(i)];
    end
end
if(SimuParam.Export_beamlet == 1)
    fid = fopen(fullfile(SimuParam.Folder, 'Outputs', 'Beamlet_info.txt'), 'w');
    fprintf(fid, '# Beamlet_beamID_layerID_spotID = Gantry angle [°], Couch angle [°], Beam energy [MeV], Spot X [mm], Spot Y [mm], Spot weight [MU]\n')
    for f=1:length(plan)
        for j=1:length(plan{f}.spots)
            for k=1:length(plan{f}.spots(j).weight)
                suffix{end+1} = ['_Beamlet_' num2str(f-1) '_' num2str(j-1) '_' num2str(k-1)];
                fprintf(fid,'Beamlet_%d_%d_%d = %f, %f, %f, %f, %f, %f \n', f-1, j-1, k-1, plan{f}.gantry_angle, plan{f}.table_angle, plan{f}.spots(j).energy, plan{f}.spots(j).xy(k,1), plan{f}.spots(j).xy(k,2), plan{f}.spots(j).weight(k));
            end
        end
    end
    fclose(fid);
end
if(MC2_Config.Simu_4D_Mode == 1 && MC2_Config.Dose_4D_Accumulation == 0)
    for i=1:length(SimuParam.CT_phases)
        suffix{i} = ['_Phase' num2str(i)];
    end
end
if(isempty(suffix))
    suffix{1} = '';
end

if(SimuParam.SparseFormat == 1)
  SpotScaling = 1.602176e-19 * 1000 * cell2mat(plan_info.SpotNumProtons);
  fid = fopen(fullfile(SimuParam.Folder, 'Outputs', 'Spot_Scaling_Factors.txt'), 'w');
  fprintf(fid, '%e\n', SpotScaling);
  fclose(fid);
  disp(['Sparse data were exported to: ' fullfile(SimuParam.Folder, 'Outputs')])
  return
end

DoseNames = {};
for i=1:length(suffix)

    info_out = Create_patient_dose_info( handles, info, plan_info, SimuParam );
    if(SimuParam.Independent_scoring_grid)
        dose_type = 'mydata';
    else
        dose_type = 'images';
    end

    % Import resulting dose map (image)
    if(SimuParam.Dose == 1)

        FileName = fullfile(SimuParam.Folder,'Outputs',['Dose' suffix{i} '.mhd']);

        Dose_data = Import_MC2_MHD_image( FileName );

        % Convert in Gray units
        if(SimuParam.Export_beamlet == 1)
          Dose_data = Dose_data * 1.602176e-19 * 1000 * plan_info.SpotNumProtons{i};
        else
          Dose_data = Dose_data * 1.602176e-19 * 1000 * plan_info.DeliveredProtons * plan_info.NumberOfFractions;
        end

         % Add the resulting image to reggui
        [handles,DoseNames{i}] = Set_reggui_data(handles,[SimuParam.DoseName suffix{i}],single(Dose_data),info_out,dose_type,0);

        % Crop body
        if(SimuParam.CropBody)
            handles = Crop_body_contour( handles, DoseNames{i}, SimuParam.BodyContour, dose_type);
        end

        % Export Dicom Dose
        if isfield(SimuParam, 'DoseFileName')
          if ~isempty(SimuParam.DoseFileName)
            %Save the dose map at DICOM format on disk only if were asked to do so
            fprintf('Saving DICOM dose map \n')
            handles = Export_image(DoseNames{i},fullfile(SimuParam.Folder, 'Outputs', [SimuParam.DoseFileName suffix{i}]),'dcm',handles);
          else
            fprintf('Skipping saving DICOM dose map \n')
          end
        else
          handles = Export_image(DoseNames{i},fullfile(SimuParam.Folder, 'Outputs', ['MCsquare_Dose' suffix{i}]),'dcm',handles);
        end


        % Transfer to workspace if independent grid was used
        if ~isfield(SimuParam, 'resampleScoringGrid')
          SimuParam.resampleScoringGrid = true;
        end
        if(SimuParam.Independent_scoring_grid & SimuParam.resampleScoringGrid)
            DoseName = check_existing_names([DoseNames{i},'_resampled'], handles.images.name);
            handles = Data2image(DoseNames{i}, DoseName, handles);
        end
    end


    % Import resulting energy map (image)
    if(SimuParam.Energy == 1)

        FileName = fullfile(SimuParam.Folder,'Outputs',['Energy' suffix{i} '.mhd']);
        Energy_data = Import_MC2_MHD_image( FileName );

        % Convert in Joule units
        if(SimuParam.Export_beamlet == 1)
          Energy_data = Energy_data * 1.602176e-19 * plan_info.SpotNumProtons{i};
        else
          Energy_data = Energy_data * 1.602176e-19 * plan_info.DeliveredProtons * plan_info.NumberOfFractions;
        end

        % Add the resulting image to reggui data
        info_out.OriginalHeader.DoseUnits = 'J';
        [handles,EnergyNames{i}] = Set_reggui_data(handles,[SimuParam.EnergyName suffix{i}],single(Energy_data),info_out,dose_type,0);

        % Crop body
        if(SimuParam.CropBody)
            handles = Crop_body_contour( handles, EnergyNames{i}, SimuParam.BodyContour, dose_type);
        end

        % Export energy in DICOM
        handles = Export_image(EnergyNames{i},fullfile(SimuParam.Folder, 'Outputs', ['MCsquare_Energy' suffix{i}]),'dcm',handles);

        % Transfer to workspace if independent grid was used
        if(SimuParam.Independent_scoring_grid)
            EnergyName = check_existing_names(EnergyNames{i}, handles.images.name);
            handles = Data2image(EnergyNames{i}, [EnergyName,'_resampled'], handles);
        end

    end


    % Import resulting LET map (image)
    if (SimuParam.LET == 1)

        FileName = fullfile(SimuParam.Folder,'Outputs',['LET' suffix{i} '.mhd']);
        LET_data = Import_MC2_MHD_image( FileName );

        % Add the resulting image to reggui data
        info_out.OriginalHeader.DoseUnits = 'keV/um';
        [handles,LETNames{i}] = Set_reggui_data(handles,[SimuParam.LETName suffix{i}],single(LET_data),info_out,dose_type,0);

        % Crop body
        if(SimuParam.CropBody)
            handles = Crop_body_contour( handles, LETNames{i}, SimuParam.BodyContour, dose_type);
        end

        % Export energy in DICOM
        handles = Export_image(LETNames{i},fullfile(SimuParam.Folder, 'Outputs', ['MCsquare_LET' suffix{i}]),'dcm',handles);

        % Transfer to workspace if independent grid was used
        if(SimuParam.Independent_scoring_grid)
            LETName = check_existing_names(LETNames{i}, handles.images.name);
            handles = Data2image(LETNames{i}, [LETName,'_resampled'], handles);
        end

    end

end

cd(current_dir)
