%% ComputeFinalDose
% Compute the dose distribution and the dose averaged Linear Energy Tranfer (using MCsqaure).
% The plan is defined in a DICOM file called 'Plan.dcm' and stored in the folder |Plan.output_path|.
% The results are saved in DICOM files on disk.
%
%% Syntax
% |[ handles ] = ComputeFinalDose(Plan, handles, DoseFileName, mode)|
%
% |[ handles ] = ComputeFinalDose(Plan, handles, DoseFileName)|
%
% |[ handles ] = ComputeFinalDose(Plan, handles)|
%
%
%% Description
% |[ handles ] = ComputeFinalDose(Plan, handles, DoseFileName, mode)| Description
%
%
%% Input arguments
% |Plan| - _STRUCTURE_ - MIROPT plan structure
%
% |DoseFileName| -_STRING_- [OPTIONAL. Default : do not save DICOM file] Name of the DICOM file where the dose map shall be saved.
%
% |mode| -_STRING_- [OPTIONAL. Default = 'multi-energy']
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the computation results
%    * |handles.image| The element with name |'dose_final_miropt_resampled'| has the dose map at the resolution of input CT scan
%    * |handles.mydata| The element with name |'dose_final_miropt'| has the dose map at the resolution of the scoring grid |Scoring_voxel_spacing|
%
%
%% Contributors
% Author(s): Ana Barragan, Lucian Hotoiu
%
%
%%REFERENCES
% [Cortés-Giraldo, M. A., & Carabe, A. (2015). A critical study of different Monte Carlo scoring methods of dose average linear-energy-transfer maps calculated in voxelized geometries irradiated with clinical proton beams. Physics in Medicine and Biology, 60(7), 2645–2669. https://doi.org/10.1088/0031-9155/60/7/2645]

function [ handles ] = ComputeFinalDose(Plan, handles, DoseFileName, mode)

if nargin >= 3
  SimuParam.DoseFileName = DoseFileName;
end

if nargin < 4
   mode = 'multi-energy';
end
if isempty(mode)
  mode = 'multi-energy';
end
if nargin < 5
   RemServer = [];
end


i = length(handles.plans.name)+1;

% % load data in handles using REGGUI function
handles.plans.name{i} = check_existing_names('plan_miropt',handles.plans.name);
[handles.plans.data{i},handles.plans.info{i}] = load_DICOM_RT_Plan(fullfile(Plan.output_path,'Plan.dcm'));

% input arguments for MCsquare simulation
SimuParam.openMCsquarePath = Plan.MCsqExecPath;
SimuParam.RunSimu = 1;
SimuParam.Folder = Plan.output_path;
SimuParam.CT = Plan.CTname;
SimuParam.Plan = handles.plans.name{end};
SimuParam.Scanner = Plan.ScannerDirectory;
SimuParam.BDL = Plan.BDL;
SimuParam.NumberOfPrimaries = Plan.protonsFullDose;
SimuParam.NumberOfThreads = 0;
SimuParam.Dose = 1;
SimuParam.DoseName = 'dose_final_miropt';
% if ~isempty(DoseFileName)
%   SimuParam.DoseFileName = DoseFileName;
% else
%   SimuParam.DoseFileName = 'MCsquare_Dose';
% end
SimuParam.Energy = 0;
%SimuParam.EnergyName = 'MCsquare_energy';

%MCsquare computed the dose averaged LET.
% There are two possible models to compute the NET, which can be selected with the configuration MCsqaure file:
% * deposited energy model :  corresponds to method A  (eq. 10) in [1]
% * stopping power model :  corresponds to method C (eq 12) in [1].
% By default, method C is selected because it provides higher result stability according to [1].
SimuParam.LET = 0; %Compute the LET
SimuParam.LETName  = 'LET_final_miropt';
SimuParam.DoseToWater = 0;
SimuParam.CropBody = 0;
SimuParam.OverwriteHU = {};
SimuParam.DoseToWater = 1; % use Dose to water by default

if (isfield(Plan, 'Independent_scoring_grid') && isfield(Plan, 'Scoring_voxel_spacing'))
    SimuParam.Independent_scoring_grid = Plan.Independent_scoring_grid; % Enable a different scoring grid than the base CT for the dose calculation
    SimuParam.Scoring_voxel_spacing = Plan.Scoring_voxel_spacing; % In [mm]. Set dose calcuation scorinng grid to 1mm spacing and overwrite the CT grid. This would reduce computation time if the CT resolution is very high.
    if isfield (Plan, 'Scoring_grid_size')
      SimuParam.Scoring_grid_size = Plan.Scoring_grid_size;
    end
    if isfield (Plan, 'Scoring_origin')
      SimuParam.Scoring_origin = Plan.Scoring_origin;
    end

    if isfield (Plan, 'resampleScoringGrid')
      SimuParam.resampleScoringGrid = Plan.resampleScoringGrid;
    else
      SimuParam.resampleScoringGrid = true;
    end
end


switch mode
    case 'multi-energy'
        handles = MC2_simulation(handles,SimuParam);
    case 'mono-energy'
        Plan2 = Plan;

        % Define Tusk BDL name to be used my MC2
        snoutID = string(extractBetween(Plan2.BDL, 'BDL_default_', '_'));
        originalRSMaterial = string(extractBetween(Plan.BDL, snoutID + '_', '_'));
        Plan2.BDL = convertStringsToChars(strrep(Plan2.BDL, originalRSMaterial, Plan2.Spike.MaterialID));


        for b = 1:length(handles.plans.data{1,2})
            % Compute tusk range shifter WET
            [~ , ~ , CEM_WET , ~ , ~ , ~ , ~] = getRangeShifterWet(Plan2, Plan2.BDL, Plan2.Beams(b).RSinfo.R_max, Plan2.Spike.MaterialID, Plan2.Spike.MinThickness);
            handles.plans.data{1,2}{1,b}.spots(1).RangeShifterWaterEquivalentThickness = Plan2.Beams(b).LayerSpacing; %CEM_WET * 10; %convert from cm to mm

            [~ , ~ , ~ , ~ , ~ , RSslabThickness , RangeShifterMaterial] = getRangeShifterWet(Plan2, Plan2.BDL, Plan2.Beams(b).RSinfo.R_max);
            IsocenterToRangeModulatorDistance = getIsocenterToRangeModulatorDistance(Plan2.Beams(b), Plan2.BDL);
            handles.plans.data{1,2}{1,b}.spots(1).IsocenterToRangeShifterDistance = IsocenterToRangeModulatorDistance;

            % Set energy layers to max mono-energy
            energies = [];
            for q = 1:length(handles.plans.data{1,2}{1,b}.spots)
                energies = [energies handles.plans.data{1,2}{1,b}.spots(q).energy];
            end
            maxEnergy = max(energies);
            handles.plans.data{1,2}{1,b}.spots(1).energy = maxEnergy;

            % Set layer WET for CEM material and set isocenter to variable RS (CEM) distance
            for e = 2:length(handles.plans.data{1,2}{1,b}.spots)
                handles.plans.data{1,2}{1,b}.spots(e).energy = maxEnergy;
                RSThickness = getRSThickness(energies(e-1), energies(e), RangeShifterMaterial); %Compute thickness (mm) of RS to reduce energy

                dRSwet = handles.plans.data{1,2}{1,b}.spots(e-1).RangeShifterWaterEquivalentThickness + Plan2.Beams(b).LayerSpacing;
                handles.plans.data{1,2}{1,b}.spots(e).RangeShifterWaterEquivalentThickness = dRSwet;

                dRSIsoDist = handles.plans.data{1,2}{1,b}.spots(e-1).IsocenterToRangeShifterDistance - RSThickness;
                handles.plans.data{1,2}{1,b}.spots(e).IsocenterToRangeShifterDistance = dRSIsoDist;
            end
        end
        % =================================================================

        SimuParam.BDL = Plan2.BDL;



        handles = MC2_simulation(handles,SimuParam);
end

end
