function [ SimuParam ] = MCsquare_Param_GUI(handles)

HEIGHT = 790;
WIDTH = 700;

MC2_lib_path = fullfile(getPluginPath('openMCsquare'),'lib');

ScannerFiles = dir(fullfile(MC2_lib_path, 'Scanners'));
ScannerString = {};
numScanners = 0;
for i=1:length(ScannerFiles)
    if(~strcmp(ScannerFiles(i).name, '.') && ~strcmp(ScannerFiles(i).name, '..'))
        numScanners = numScanners + 1;
        ScannerString{numScanners} = ScannerFiles(i).name;
    end
end

BDLFiles = dir(fullfile(MC2_lib_path, 'BDL', '*.txt'));
BDL_String = {};
numBDL = 0;
for i=1:length(BDLFiles)
    if(~strcmp(BDLFiles(i).name, '.') && ~strcmp(BDLFiles(i).name, '..'))
        numBDL = numBDL + 1;
        BDL_String{numBDL} = BDLFiles(i).name;
    end
end

CT_Id_list = [];
Contour_Id_list = [];
Overwrite_Id_list = [];
for i=1:numel(handles.images.name)
    Modality = '';
    
    try
        Modality = handles.images.info{i}.OriginalHeader.Modality;
        if(isfield(handles.images.info{i}, 'Color'))
            Modality = 'RS';
        end
    catch
        continue
    end
    
    switch Modality
        case 'CT'
            CT_Id_list(end+1) = i;
        case 'RS'
            Contour_Id_list(end+1) = i;
            if(isfield(handles.images.info{i}, 'ElectronDensity'))
                Overwrite_Id_list(end+1) = i;
            end
        case 'OT'
            CT_Id_list(end+1) = i; % To accept images generated in Matlab referred as "Other Modality"
    end
end

if(numel(CT_Id_list) > 0)
    CTString = handles.images.name(CT_Id_list);
else
    CTString = {'CT image not found !!'};
end

Plan_Id_list = [];
for i=1:numel(handles.plans.name)
    Modality = '';
    try
        Modality = handles.plans.info{i}.Type;
    catch
        continue
    end
    if(strcmpi(Modality, 'pbs_plan'))
        Plan_Id_list(end+1) = i;
    end
end

if(numel(Plan_Id_list) > 0)
    PlanString = handles.plans.name(Plan_Id_list);
else
    disp('Warning: no PBS plan could be found.')
    PlanString = {'(No plan available)'};
end

% Number of CPU threads
import java.lang.*;
r=Runtime.getRuntime;
ncpu=r.availableProcessors;

SimuParam = {};
SimuParam.RunSimu = 0;
SimuParam.Folder = fullfile(handles.dataPath, ['MCsquare_',strrep(strrep(strrep(datestr(now,'yy-mm-dd-HH-MM-SS'),'-','_'),' ','_'),':','_')]);
SimuParam.CT = CTString{1};
SimuParam.Plan = PlanString{1};
SimuParam.Scanner = ScannerString{1};
SimuParam.BDL = BDL_String{1};
SimuParam.NumberOfPrimaries = '1E7';
SimuParam.ComputeStat = 0;
SimuParam.StatUncertainty = 2.0;
SimuParam.NumberOfThreads = ncpu;
SimuParam.Dose = 1;
SimuParam.DoseName = 'MCsquare_dose';
SimuParam.Energy = 0;
SimuParam.EnergyName = 'MCsquare_energy';
SimuParam.LET = 0;
SimuParam.LETName = 'MCsquare_LET';
SimuParam.DoseToWater = 0;
SimuParam.CropBody = 0;
SimuParam.BodyContour = '';
SimuParam.OverwriteHU = {};
SimuParam.ProtonOnly = 0;
SimuParam.Scoring_voxel_spacing = [1.5 1.5 1.5];

if(sum(handles.spacing' > SimuParam.Scoring_voxel_spacing) == 3)
    SimuParam.Scoring_voxel_spacing = handles.spacing';
end


AdvancedParam = [];

[HU_data, ~, SPR_data, ~, RelElecDensity_data] = Compute_SPR_data(SimuParam.Scanner);
[unique_RelElecDensity, Id] = unique(RelElecDensity_data);
HU_data = HU_data(Id);
SPR_data = SPR_data(Id);
OverwriteData = {};
for i=Overwrite_Id_list
    RelElecDensity = handles.images.info{i}.ElectronDensity;
    hu = interp1(unique_RelElecDensity, HU_data, RelElecDensity, 'linear', 'extrap');
    spr = interp1(unique_RelElecDensity, SPR_data, RelElecDensity, 'linear', 'extrap');
    OverwriteData = [OverwriteData ; {false, handles.images.name{i}, sprintf('%.0f', hu), sprintf('%.2f', RelElecDensity), sprintf('%.2f', spr)}];
end

% Create a window for the GUI
window = figure('Name', 'Simulation parameters', ...
    'Units', 'Pixels', ...
    'Color', [0.8 0.8 0.8], ...
    'Position', [200 200 WIDTH*1.2 HEIGHT]);

LeftPosition = HEIGHT - 25;
LeftPadding = WIDTH*0.05;


% Simulation folder
Folder_label = uicontrol('Parent', window, ...
    'Style', 'text', ...
    'String', 'Simulation folder', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition WIDTH*1.1 20]);

LeftPosition = LeftPosition - 25;

Folder = uicontrol(     'Parent', window, ...
    'Style', 'edit', ...
    'String', SimuParam.Folder, ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition WIDTH 22]);

Folder_button = uicontrol(   'Parent', window, ...
    'Style', 'pushbutton', ...
    'String', 'Select', ...
    'HorizontalAlignment', 'left', ...
    'Position', [(LeftPadding+WIDTH*1.025) LeftPosition 50 20], ...
    'Callback', @Folder_button_Callback);

LeftPosition = LeftPosition - 50;



RightPosition = LeftPosition;
RightPadding = WIDTH*0.65;


%%%%%%%%%%% Left pannel %%%%%%%%%%%%


% CT image
CT_label = uicontrol(  'Parent', window, ...
    'Style', 'text', ...
    'String', 'Select CT image', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition WIDTH/2 20]);

LeftPosition = LeftPosition - 75;

CT_list = uicontrol(   'Parent', window, ...
    'Style', 'listbox', ...
    'String', CTString, ...
    'Position', [LeftPadding LeftPosition WIDTH/2 75]);

CT_button = uicontrol(   'Parent', window, ...
    'Style', 'pushbutton', ...
    'String', 'All img', ...
    'HorizontalAlignment', 'left', ...
    'Position', [(LeftPadding+WIDTH/2-65) LeftPosition 50 20], ...
    'Callback', @CT_button_Callback);

LeftPosition = LeftPosition - 40;


% Plan
Plan_label = uicontrol(  'Parent', window, ...
    'Style', 'text', ...
    'String', 'Select plan', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition WIDTH/2 20]);

LeftPosition = LeftPosition - 75;

Plan_list = uicontrol(   'Parent', window, ...
    'Style', 'listbox', ...
    'String', PlanString, ...
    'Position', [LeftPadding LeftPosition WIDTH/2 75]);

LeftPosition = LeftPosition - 40;



% CT scanner calibration curve
Scanner_label = uicontrol(  'Parent', window, ...
    'Style', 'text', ...
    'String', 'Select CT scanner calibration', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition WIDTH/2 20]);

LeftPosition = LeftPosition - 75;

Scanner_list = uicontrol(   'Parent', window, ...
    'Style', 'listbox', ...
    'String', ScannerString, ...
    'Position', [LeftPadding LeftPosition WIDTH/2 75], ...
    'Callback', @CT_scanner_Callback);

LeftPosition = LeftPosition - 40;



% Beam model
BDL_label = uicontrol(   'Parent', window, ...
    'Style', 'text', ...
    'String', 'Select beam model', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition WIDTH/2 20]);

LeftPosition = LeftPosition - 75;

BDL_list = uicontrol(    'Parent', window, ...
    'Style', 'listbox', ...
    'String', BDL_String, ...
    'Position', [LeftPadding LeftPosition WIDTH/2 75]);

LeftPosition = LeftPosition - 40;


% Overwrite HU
Overwrite_label = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', 'Overwrite HU in CT image', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition WIDTH/2 20]);

LeftPosition = LeftPosition - 85;

Overwrite_table = uitable(  window, ...
    'ColumnName', {'', 'Contour', 'HU', 'Elec Density', 'SPR'}, ...
    'ColumnEditable', [true false true true true], ...
    'ColumnFormat', {'logical', 'char', 'char', 'char', 'char'}, ...
    'RowName', [], ...
    'Data', OverwriteData, ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'ColumnWidth', {20, (WIDTH/2 -199), 45, 85, 45}, ...
    'Position', [LeftPadding LeftPosition WIDTH/2 85], ...
    'celleditcallback', @Overwrite_table_Callback);

LeftPosition = LeftPosition - 20;

AddContour = uicontrol(   'Parent', window, ...
    'Style', 'pushbutton', ...
    'String', 'Add', ...
    'HorizontalAlignment', 'left', ...
    'Position', [LeftPadding LeftPosition 50 20], ...
    'Callback', @AddContour_Callback);


LeftPosition = LeftPosition - 40;



%%%%%%%%%%% Right pannel %%%%%%%%%%%%

% Number of protons to simulate
Stat_Category_label = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', 'Statistical uncertainty', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition WIDTH/2 20]);

RightPosition = RightPosition - 25;

Enable_stat_eval =  uicontrol( 'Parent', window, ...
    'Style', 'checkbox', ...
    'String', 'Estimate stat uncertainty', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Value', SimuParam.ComputeStat, ...
    'Callback', @EnableStat_Callback, ...
    'Position', [RightPadding RightPosition WIDTH/2 22]);

RightPosition = RightPosition - 30;

NumParticles_label = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', 'Min number of protons to simulate', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition (WIDTH/2 -120) 22]);

NumberOfPrimaries = uicontrol(   'Parent', window, ...
    'Style', 'edit', ...
    'String', SimuParam.NumberOfPrimaries, ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+(WIDTH/2 -60) RightPosition 60 22]);

RightPosition = RightPosition - 25;

StatUncertainty_label = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', 'Max statistical uncertainty (%)', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition (WIDTH/2 -120) 22]);

StatUncertainty = uicontrol(   'Parent', window, ...
    'Style', 'edit', ...
    'String', SimuParam.StatUncertainty, ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+(WIDTH/2 -60) RightPosition 60 22]);

if(SimuParam.ComputeStat == 0)
    StatUncertainty_label.Visible = 'off';
    StatUncertainty.Visible = 'off';
end

RightPosition = RightPosition - 40;



% Number of CPU threads
NumThreads_label = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', 'Number of CPU threads', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition WIDTH/2 20]);

RightPosition = RightPosition - 25;

NumThreads = uicontrol(   'Parent', window, ...
    'Style', 'slider', ...
    'Min', 1, ...
    'Max', ncpu, ...
    'Value', ncpu, ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition (WIDTH/2 -100) 22]);

NumThreads_value = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', num2str(ncpu), ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+(WIDTH/2 -50) RightPosition 50 20]);

RightPosition = RightPosition - 40;



% Output options
Output_label = uicontrol(  'Parent', window, ...
    'Style', 'text', ...
    'String', 'Outputs', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition WIDTH/2 20]);

RightPosition = RightPosition - 25;

%Export dose
Export_dose =  uicontrol('Parent', window, ...
    'Style', 'checkbox', ...
    'String', 'Dose map', ...
    'Value', 1.0, ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Callback', @Export_Callback, ...
    'Position', [RightPadding RightPosition WIDTH/2 22]);

DoseName = uicontrol(    'Parent', window, ...
    'Style', 'edit', ...
    'String', 'MCsquare_dose', ...
    'Visible', 'on', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+125 RightPosition (WIDTH/2 - 125) 22]);

RightPosition = RightPosition - 25;



%Export energy
Export_energy =  uicontrol('Parent', window, ...
    'Style', 'checkbox', ...
    'String', 'Energy map', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Callback', @Export_Callback, ...
    'Position', [RightPadding RightPosition WIDTH/2 22]);

EnergyName = uicontrol(  'Parent', window, ...
    'Style', 'edit', ...
    'String', 'MCsquare_energy', ...
    'Visible', 'off', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+125 RightPosition (WIDTH/2 - 125) 22]);

RightPosition = RightPosition - 25;



%Export LET
Export_LET =  uicontrol( 'Parent', window, ...
    'Style', 'checkbox', ...
    'String', 'LET map', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Callback', @Export_Callback, ...
    'Position', [RightPadding RightPosition WIDTH/2 22]);

LETName = uicontrol(     'Parent', window, ...
    'Style', 'edit', ...
    'String', 'MCsquare_LET', ...
    'Visible', 'off', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+125 RightPosition (WIDTH/2 - 125) 22]);

RightPosition = RightPosition - 25;

Proton_only =  uicontrol( 'Parent', window, ...
    'Style', 'checkbox', ...
    'String', 'Simulate proton only', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Visible', 'off', ...
    'Position', [RightPadding+125 RightPosition WIDTH/2 22]);

RightPosition = RightPosition - 30;


% Scoring grid resolution
Scoring_grid_label = uicontrol(  'Parent', window, ...
    'Style', 'text', ...
    'String', 'Resolution (mm):', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition WIDTH/2 20]);

Scoring_voxel_spacing = uicontrol(    'Parent', window, ...
    'Style', 'edit', ...
    'String', ['[' num2str(SimuParam.Scoring_voxel_spacing(1), 3) ' ' num2str(SimuParam.Scoring_voxel_spacing(2), 3) ' ' num2str(SimuParam.Scoring_voxel_spacing(3), 3) ']'], ...
    'Visible', 'on', ...
    'HorizontalAlignment', 'center', ...
    'Position', [RightPadding+115 RightPosition 130 22]);

Scoring_with_CT_resolution = uicontrol(   'Parent', window, ...
    'Style', 'pushbutton', ...
    'String', 'Workspace', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+260 RightPosition 90 20], ...
    'Callback', @Resolution_Callback);

RightPosition = RightPosition - 70;



%Beam dose
Export_label = uicontrol(  'Parent', window, ...
    'Style', 'text', ...
    'String', 'Export', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition WIDTH/2 20]);

RightPosition = RightPosition - 46;

Export_Group = uibuttongroup('Parent', window, ...
    'Units', 'Pixels', ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [RightPadding+80 RightPosition WIDTH/2 100]);

Export_total = uicontrol( 'Parent', Export_Group, ...
    'Style', 'radiobutton', ...
    'String', 'full plan', ...
    'Value', 1, ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0 75 WIDTH*0.5 20]);

Export_beam = uicontrol( 'Parent', Export_Group, ...
    'Style', 'radiobutton', ...
    'String', 'each beam individually', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0 50 WIDTH*0.5 20]);

Export_beamlet = uicontrol( 'Parent', Export_Group, ...
    'Style', 'radiobutton', ...
    'String', 'each spot individually (MHD beamlets)', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0 25 WIDTH*0.5 20]);

Export_sparse_beamlet = uicontrol( 'Parent', Export_Group, ...
    'Style', 'radiobutton', ...
    'String', 'each spot individually (Sparse beamlets)', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0 0 WIDTH*0.5 20]);

RightPosition = RightPosition - 40;



% Dose to water
DoseWater_label = uicontrol(   'Parent', window, ...
    'Style', 'text', ...
    'String', 'Dose to water conversion', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition WIDTH/2 20]);

RightPosition = RightPosition - 30;


DoseWaterGroup = uibuttongroup('Parent', window, ...
    'Units', 'Pixels', ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [RightPadding RightPosition WIDTH/2 30]);

DoseWater_disable = uicontrol( 'Parent', DoseWaterGroup, ...
    'Style', 'radiobutton', ...
    'String', 'Disable', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [10 5 100 20]);

DoseWater_enable = uicontrol( 'Parent', DoseWaterGroup, ...
    'Style', 'radiobutton', ...
    'String', 'Enable', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [150 5 100 20]);

set(DoseWaterGroup,'SelectedObject',DoseWater_disable);


RightPosition = RightPosition - 40;



% Crop Body contour
CropBody_label = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', 'Crop CT image with Body contour', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition WIDTH/2 20]);

RightPosition = RightPosition - 25;

SelectBody = uicontrol(   'Parent', window, ...
    'Style', 'pushbutton', ...
    'String', 'Select', ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding RightPosition 50 20], ...
    'Callback', @SelectedBody_Callback);

SelectedBody = uicontrol( 'Parent', window, ...
    'Style', 'text', ...
    'String', 'No contour selected', ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'Position', [RightPadding+75 RightPosition (WIDTH/2 - 75) 20]);


RightPosition = RightPosition - 60;


% Advanced simulations
AdvancedButton = uicontrol(   'Parent', window, ...
    'Style', 'pushbutton', ...
    'String', 'Advanced parameters', ...
    'Position', [RightPadding RightPosition 200 20], ...
    'Callback', @Advanced_Button_Callback);


RightPosition = RightPosition - 40;



%%%%%%% Submit button %%%%%%%%
Button = uicontrol(   'Parent', window, ...
    'Style', 'pushbutton', ...
    'String', 'Run simulation', ...
    'Position', [WIDTH*0.6-75 min(LeftPosition,RightPosition) 150 20], ...
    'Callback', @OK_Button_Callback);


%%%%%%%%%%%%%% Callback functions %%%%%%%%%%%%%%%%%%

addlistener(NumThreads, 'Value', 'PostSet', @(hObject, event) CPU_slider_Callback(hObject, event));

    function CPU_slider_Callback(hObject, event)
        NumThreads_value.String = num2str(round(event.AffectedObject.Value));
    end

    function Advanced_Button_Callback(source, data)
        
        if(isempty(AdvancedParam))
            AdvancedParam = MCsquare_advanced_GUI(handles)
        else
            AdvancedParam = MCsquare_advanced_GUI(handles, AdvancedParam)
        end
        
        if(AdvancedParam.Simu4D == 1)
            if(strcmp(AdvancedParam.CT_button, CT_button.String) ~= 1)
                CT_button_Callback();
            end
            
            set(CT_list, 'max', numel(AdvancedParam.CT_phases));
            CT_list.Value = AdvancedParam.CT_list;
        end
        
        SimuParam.Simu4D = AdvancedParam.Simu4D;
        SimuParam.CT_phases = AdvancedParam.CT_phases;
        SimuParam.ref_4D = AdvancedParam.reference;
        SimuParam.register = AdvancedParam.register;
        SimuParam.Robustness_Mode = AdvancedParam.Robustness;
        SimuParam.ScenarioSampling = AdvancedParam.ScenarioSampling;
        SimuParam.setup_systematic = AdvancedParam.setup_systematic;
        SimuParam.setup_random = AdvancedParam.setup_random;
        SimuParam.range_systematic = AdvancedParam.range_systematic;
        SimuParam.TV = AdvancedParam.TV;
        SimuParam.OAR = AdvancedParam.OAR;
        SimuParam.TV = AdvancedParam.TV;
        SimuParam.OAR = AdvancedParam.OAR;
        SimuParam.NumScenarios = AdvancedParam.NumScenarios;
        SimuParam.Dose_4D_Accumulation = AdvancedParam.DoseAccumulation;
    end

    function EnableStat_Callback(source, data)
        if(source.Value == 0)
            StatUncertainty_label.Visible = 'off';
            StatUncertainty.Visible = 'off';
        else
            StatUncertainty_label.Visible = 'on';
            StatUncertainty.Visible = 'on';
        end
    end


    function Export_Callback(source, data)
        if(source.Value == 0)
            visible = 'off';
        else
            visible = 'on';
        end
        
        switch source.String
            case 'Dose map'
                DoseName.Visible = visible;
            case 'Energy map'
                EnergyName.Visible = visible;
            case 'LET map'
                LETName.Visible = visible;
                Proton_only.Visible = visible;
        end
    end


    function Resolution_Callback(source, data)
        Scoring_voxel_spacing.String = ['[' num2str(handles.spacing(1), 3) ' ' num2str(handles.spacing(2), 3) ' ' num2str(handles.spacing(3), 3) ']'];
    end


    function CT_scanner_Callback(source, data)
        Scanner = ScannerString{source.Value};
        [HU_data, ~, SPR_data, ~, RelElecDensity_data] = Compute_SPR_data(Scanner);
        [unique_RelElecDensity, Id] = unique(RelElecDensity_data);
        HU_data = HU_data(Id);
        SPR_data = SPR_data(Id);
        OverwriteData = Overwrite_table.Data;
        for i=1:size(OverwriteData,1)
            OverwriteData{i,3} = sprintf('%.0f', interp1(unique_RelElecDensity, HU_data, str2double(OverwriteData{i,4}), 'linear', 'extrap'));
            OverwriteData{i,5} = sprintf('%.2f', interp1(unique_RelElecDensity, SPR_data, str2double(OverwriteData{i,4}), 'linear', 'extrap'));
        end
        Overwrite_table.Data = OverwriteData;
    end


    function SelectedBody_Callback(source, data)
        Selection = Display_Contour_List();
        if(isempty(Selection))
            SelectedBody.String = 'No contour selected';
            SimuParam.CropBody = 0;
            SimuParam.BodyContour = '';
            
        else
            SelectedBody.String = Selection;
            SimuParam.CropBody = 1;
            SimuParam.BodyContour = Selection;
        end
    end


    function Overwrite_table_Callback(source, data)
        if(data.Indices(2) < 3)
            return
        end
        
        if(isempty(data.NewData))
            NewValue = 0;
        else
            NewValue = str2double(data.NewData);
        end
        
        Scanner = ScannerString{get(Scanner_list, 'Value')};
        [calib(3,:), ~, calib(5,:), ~, calib(4,:)] = Compute_SPR_data(Scanner);
        [~, Id] = unique(calib(data.Indices(2),:));
        unique_calib(3,:) = calib(3,Id); % HU
        unique_calib(4,:) = calib(4,Id); % RelElecDensity
        unique_calib(5,:) = calib(5,Id); % SPR
        hu = interp1(unique_calib(data.Indices(2),:), unique_calib(3,:), NewValue, 'linear', 'extrap');
        ElecDensity = interp1(unique_calib(data.Indices(2),:), unique_calib(4,:), NewValue, 'linear', 'extrap');
        spr = interp1(unique_calib(data.Indices(2),:), unique_calib(5,:), NewValue, 'linear', 'extrap');
        Overwrite_table.Data{data.Indices(1),3} = sprintf('%.0f', hu);
        Overwrite_table.Data{data.Indices(1),4} = sprintf('%.2f', ElecDensity);
        Overwrite_table.Data{data.Indices(1),5} = sprintf('%.2f', spr);
    end


    function AddContour_Callback(source, data)
        OverwriteData = Overwrite_table.Data;
        Selection = Display_Contour_List();
        if(not(isempty(Selection)))
            for i=1:size(OverwriteData, 1)
                if(strcmp(OverwriteData{i,2}, Selection))
                    msgbox('Error: contour already in the list', 'Error')
                    return
                end
            end
            Scanner = ScannerString{get(Scanner_list, 'Value')};
            [HU_data, ~, SPR_data, ~, RelElecDensity_data] = Compute_SPR_data(Scanner);
            [unique_HU Id] = unique(HU_data);
            RelElecDensity_data = RelElecDensity_data(Id);
            SPR_data = SPR_data(Id);
            hu = 0;
            ElecDensity = interp1(unique_HU, RelElecDensity_data, hu, 'linear', 'extrap');
            spr = interp1(unique_HU, SPR_data, hu, 'linear', 'extrap');
            OverwriteData = [OverwriteData ; {false, Selection, sprintf('%.0f', hu), sprintf('%.2f', ElecDensity), sprintf('%.2f', spr)}];
        end
        Overwrite_table.Data = OverwriteData;
    end



    function Contour = Display_Contour_List()
        Contour = '';
        
        if(numel(Contour_Id_list) < 1)
            msgbox('Error: no contour found', 'Error')
            return
        end
        
        ContourString = handles.images.name(Contour_Id_list);
        
        [Selection,ok] = listdlg('Name','Select contour', ...
            'SelectionMode', 'single', ...
            'ListString', {'none', ContourString{:}});
        
        if(ok == 1 && numel(Selection) == 1)
            if(Selection ~= 1)
                Contour = handles.images.name{Contour_Id_list(Selection-1)};
            end
        end
    end


    function CT_button_Callback(source, data)
        if(strcmp(CT_button.String, 'All img'))
            CT_list.Value = 1;
            CT_list.String = handles.images.name(2:end);
            CT_button.String = 'CT only';
        else
            CT_list.Value = 1;
            CT_list.String = CTString;
            CT_button.String = 'All img';
        end
    end


    function Folder_button_Callback(source, data)
        dname = uigetdir(handles.dataPath, 'Select simulation folder');
        Folder.String = dname;
    end



    function OK_Button_Callback(source, data)
        
        SimuParam.RunSimu = 1;
        SimuParam.Folder = get(Folder, 'String');
        if(strcmp(CT_button.String, 'CT only'))
            CTString = handles.images.name(2:end);
        else
            SimuParam.CT = CTString{get(CT_list, 'Value')};
        end
        SimuParam.CT = CTString{get(CT_list, 'Value')};
        SimuParam.Plan = PlanString{get(Plan_list, 'Value')};
        SimuParam.Scanner = ScannerString{get(Scanner_list, 'Value')};
        SimuParam.BDL = BDL_String{get(BDL_list, 'Value')};
        SimuParam.NumberOfPrimaries = str2num(get(NumberOfPrimaries, 'String'));
        SimuParam.NumberOfThreads = round(get(NumThreads, 'Value'));
        SimuParam.Dose = (get(Export_dose, 'Value') ~= 0);
        SimuParam.DoseName = get(DoseName, 'String');
        SimuParam.Energy = (get(Export_energy, 'Value') ~= 0);
        SimuParam.EnergyName = get(EnergyName, 'String');
        SimuParam.LET = (get(Export_LET, 'Value') ~= 0);
        SimuParam.LETName = get(LETName, 'String');
        SimuParam.ProtonOnly = (get(Proton_only, 'Value') ~= 0);
        SimuParam.Export_beam_dose = (get(Export_beam, 'Value') ~= 0);
        SimuParam.Export_beamlet = (get(Export_beamlet, 'Value') ~= 0 || get(Export_sparse_beamlet, 'Value') ~= 0);
        SimuParam.SparseFormat = (get(Export_sparse_beamlet, 'Value') ~= 0);
        SimuParam.StatUncertainty = str2num(get(StatUncertainty, 'String'));
        SimuParam.ComputeStat = (get(Enable_stat_eval, 'Value') ~= 0);
        SimuParam.Scoring_voxel_spacing = str2num(get(Scoring_voxel_spacing, 'String'));
        
        if(norm(SimuParam.Scoring_voxel_spacing - handles.spacing') < 0.002)
            SimuParam.Scoring_voxel_spacing = handles.spacing';
        end
        
        
        if(strcmpi(get(get(DoseWaterGroup,'SelectedObject'),'String'), 'Enable') == 1)
            SimuParam.DoseToWater = 1;
        else
            SimuParam.DoseToWater = 0;
        end
        
        OverwriteData = Overwrite_table.Data;
        if(numel(OverwriteData) > 0)
            count = 0;
            for i=1:size(OverwriteData,1)
                if(OverwriteData{i,1} == 1)
                    count = count + 1;
                    SimuParam.OverwriteHU{count,1} = OverwriteData{i,2};
                    SimuParam.OverwriteHU{count,2} = str2num(OverwriteData{i,3});
                end
            end
        else
            SimuParam.OverwriteHU = {};
        end
        
        if(isempty(SimuParam.CT) || strcmp(SimuParam.CT, 'none') || strcmp(SimuParam.CT, 'CT image not found !!'))
            msgbox('Error: no CT image selected', 'Error')
            return
        end
        if(isempty(SimuParam.Plan) || strcmp(SimuParam.Plan, 'none') || strcmp(SimuParam.Plan, 'Plan not found !!'))
            msgbox('Error: no plan selected', 'Error')
            return
        end
        
        if(length(SimuParam.Scoring_voxel_spacing) ~= 3)
            msgbox('Error: Scoring resolution is not valid', 'Error')
            return
        end
        
        if(~isfield(SimuParam, 'Simu4D'))
            SimuParam.Simu4D = 0;
            SimuParam.CT_phases = CTString{1};
            SimuParam.reference = CTString{1};
            SimuParam.register = 1;
            SimuParam.Robustness_Mode = 0;
            SimuParam.ScenarioSampling = 0;
            SimuParam.setup_systematic = [5.0 5.0 5.0];
            SimuParam.setup_random = [1.0 1.0 1.0];
            SimuParam.range_systematic = 3.0;
            SimuParam.TV = {};
            SimuParam.OAR = {};
            SimuParam.NumScenarios = 0;
            SimuParam.Dose_4D_Accumulation = 1;
        end
        
        if(SimuParam.Simu4D == 1)
            SimuParam.CT = SimuParam.ref_4D;
        end
        
        close(window);
    end

uiwait(window)


end

