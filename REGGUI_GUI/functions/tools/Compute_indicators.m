%% Compute_indicators
% Compute the clinical indicators using the specified data sets.
%
% The clinical indicators are related to the anatomical RT-struct. They can be related to dose distribution (e.g. D95), volume properties (V20), water equivalent pathlength (WET) properties inside these anatomical structures. They can also be related to the difference of these properties between two maps. They can also be related to gamma index comparison between these properties in two maps.
%
% The allowed combination of indicators specifications are described on the web page [1]. A easy way to specify indicators and tolerance check on indicators is to specify the indicators in a JSON file and then to import it into REGGUI using the function Import_indicators. The function will automatically load the indicators and tests into the handle structure.
%
%% Syntax
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model,sad)|
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model,sad,def_field_name)|
%
%% Description
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name)| Compute the clinical indicators with default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model,sad)| Compute the clinical indicators with specified and default parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model,sad,def_field_name)| Compute the clinical indicators with specified parameters
%
% |[indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model,sad,def_field_name,illustration_output_dir)| Compute the clinical indicators with specified parameters
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed.  The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.indicators| - _STRUCTURE_ - Structure with the clinical indicators. It contains the following fields:
% * --|handles.indicators.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th treatment indicators
% * --|handles.indicators.data{i}| - _STRUCTURE_ Structure describing the i-th treatment indicators. 
% * ----|handles.indicators.data{}.type| - _STRING_ - Type of clinical indicator. Options are: "D" = dose in the specified volume, "V" = volume with specified dose, "D_index" = conformity or homogeneity index, "D_diff"= dose difference, "D_gamma" = gamma index comparing two dose maps, "WET_3D" = WET along the beam let path to each voxel inside the structure, "WET_3D_diff" = difference of WET along the beam let path to each voxel inside the same structure in 2 WET maps, "WET_3D_gamma" = gamma index test computed on this WET difference, "WET_distal" = WET computed to the distal surface of the structure, "WET_distal_diff" = difference of WET computed to the distal surface of the same structure in 2 WET maps, "WET_proximal" = WET computed to the proximal surface of the structure, "WET_distal_diff" = difference of WET computed to the distal surface of the same structure in 2 WET maps , "WET_proximal_diff" = difference of WET computed to the distal surface of the same structure in 2 WET maps, "Intensity" = properties of the voxels intensities inside the structure, "Intensity_diff" = difference of voxel intensities inside the same structure in 2 maps , "Distance" = distance (in real space) between 2 structures, "Distance_WET" = distance (in water equivalent llength) between 2 structures, "Motion" = properties of the vectors of a deformation field.
% * ----|handles.indicators{i}.beam| - _INTEGER_ - Index of the beam (in the cell vector |dose_name|) associated with this indicator.
% * ----|handles.indicators{i}.unit| -_STRING_- Unit of the clinical indicator. The description of the available options can be found on the web site [1].
% * ----|handles.indicators{i}.param| - _ANY_ - Parameter to use to compute the clinical indicator. Depending on the type of indicator, the nature and meaning of the parameter will be different. The description of the parameters can be found on the web site [1].
% * ----|handles.indicators{i}.param_unit| - _STRING_ - Units in which the parameter is expressed
% * ----|handles.indicators{i}.value| - _STRING_ Statistical function to apply to the clinical indicator (e.g. "min", "max", "percentile",...). The description of the available options can be found on the web site [1].
% * ----|handles.indicators{i}.prescription| - _SCALAR_ - Dose (in Gy) prescribed inside the specified anatomical structure
% * ----|handles.indicators{i}.acceptance_test| -_STRING_- Comparison operator for performing the test on the indicator. Options are: ">", "<"
% * ----|handles.indicators{i}.acceptance_level| -_SCALAR_- Threshold value for the test. The clinical indicator is compared to this threshold. 
% * ----|handles.indicators{i}.acceptance_unit| -_STRING_- Unit of the acceptance level.
% * ----|handles.indicators{i}.acceptance_tolerance (Scalar: e.g. 0).  Define the tolerance level for a soft constraint. If the parameter is satisfying the acceptance_level, it will be defined as "pass". If it is within the tolerance, than a "soft constraint" has failed. The parameter will be "within_tolerance". If the parameter is outside of the tolerance, then a "hard constrain" is failed. The parameter will be "fail".
% * --|handles.indicators.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
%
% |indicator_name| - _STRING_ - Name of the indicator data structure (in |handles|) containing the definition of the clinical indicators
%
% |contour_names| - _STRING_ - Name of the binary mask in |handles| of the anatomical structures
%
% |dose_name| - _CELL VECTOR of STRING_ - |dose_name{i}| Name of the image (in |handles|) containing the dose map for the i-th beam
%
% |ct_name| - _STRING_ - [OPTIONAL. Default : empty] Name of the CT scan (in |handles|)
%
% |body_name| - _STRING_ - [OPTIONAL. Default : empty] Name of the binary mask in |handles| with the definition of the body contour. This is used in the computation of the WET to define the skin surface 
%
% |not_process| - _CELL VECTOR of STRING_ - [OPTIONAL. Default : empty] Disable computation. When a string is present, then the corresponding computation is not carried out. The results from previous computations (stored in |handles|) will be used. Possible ptions: no_dose, no_dose_gamma, no_wet, no_distance, no_motion
%
% |ref_dose_name| - _STRING_ - [OPTIONAL. Default : empty] |ref_dose_name{i}| Name of the image (in |handles|) containing the reference dose map for the i-th beam. The reference dose map is used to compute difference indicators or gamma indices.
%
% |ref_ct_name| - _STRING_ - [OPTIONAL. Default : empty] Name of the reference CT scan (in |handles|) used to compute the reference WET map. It is used to compute the difference WET and the gamma index on WET
%
% |ref_body_name| - _STRING_ - [OPTIONAL. Default : empty] Name of the binary mask in |handles| with the definition of the body contour for the reference CT. This is used in the computation of the WET to define the skin surface 
%
% |plan_name| - _STRING_ - [OPTIONAL. Default : empty] Name of the pencil beam scanning (PBS) treatment plan (in |handles|) .
%
% |model| - _STRING_ - [OPTIONAL. Default : empty] Name of the file containing the HU to SPR calibration curve. See function WEPL_computation.m for more information
%
% |sad| - _FLOAT_ -  [OPTIONAL. Default : empty] Source to axis distance (mm).  See function WEPL_computation.m for more information
%
% |def_field_name| - _STRING_ -  [OPTIONAL. Default : empty] Name of the deformation field (in |handles.fields.name|). Used only for indicator of type "Motion"
%
% |illustration_output_dir| - _STRING_ -  [OPTIONAL. Default : empty] Name of the directory in which the results will be saved as png image
%
%% Output arguments
%
% |indicators|  - _CELL VECTOR od STRUCTURE_ - |indicators{i}| Structure with the clinical i-th  indicators. It contains the input data and the additional fields:
% * |indicators{i}.evaluation| - _SCALAR_ - Value of the i-th clinical indicator
% * |indicators{i}.struct_color| -_STRING_- Colour used for the display of the anatomical contour used for the i-th clinical indicator
% * |indicators{i}.acceptance_evaluation| -_STRING_- Result of the test on the clinical indicator. The posible results are "pass" (= test passed), "within_tolerance" (= indicator within soft constraints), "fail" (= hard constraint failed)
%
% |handles| - _STRUCTURE_ -  Identical to the input |handles|  
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)
%
%% Reference
% [1] https://openreggui.org/git/open/REGGUI/wikis/QA_indicators


function [indicators,handles] = Compute_indicators(handles,indicator_name,contour_names,dose_name,ct_name,body_name,not_process,ref_dose_name,ref_ct_name,ref_body_name,plan_name,model,sad,def_field_name,illustration_output_dir)

% Default parameters
if(nargin<4)
    disp('Not enough input arguments. Abort.')
    return
end
if(nargin<5)
    ct_name = '';
end
if(nargin<6)
    body_name = '';
end
if(nargin<7)
    not_process = {};
end
if(nargin<8)
    ref_dose_name = '';
end
if(nargin<9)
    ref_ct_name = '';
end
if(nargin<10)
    ref_body_name = '';
end
if(nargin<11)
    plan_name = '';
    smearing_size = 2; % default "smearing" size for PBS (i.e. gamma-like analysis)
else
    if(not(isempty(plan_name)))
        [~,plan_info] = Get_reggui_data(handles,plan_name,'plans');
        if(strcmp(plan_info.Type,'passive_scattering_plan'))
            smearing_size = 10; % default smearing size for passive scattering
        else
            smearing_size = 2; % default "smearing" size for PBS (i.e. gamma-like analysis)
        end
    else
        smearing_size = 2; % default "smearing" size for PBS (i.e. gamma-like analysis)
    end
end
if(nargin<12)
    model = [];
end
if(nargin<13)
    sad = [];
end
if(nargin<14)
    def_field_name = '';
end
if(nargin<15)
    illustration_output_dir = [];
end

% Get indicators
indicators = Get_reggui_data(handles,indicator_name,'indicators');

% Get contours
contours = struct;
contour_rt_names = struct;
contour_colors = struct;
if(ischar(contour_names))
    contour_names = {contour_names};
end
for c=1:length(contour_names)
    [temp_data,info] = Get_reggui_data(handles,contour_names{c},'images');
    if(isfield(info,'Contour_name'))
        contour_rt_names.(lower(remove_bad_chars(info.Contour_name))) = contour_names{c};
    else
        contour_rt_names.(lower(contour_names{c})) = contour_names{c};
    end
    if(isfield(info,'Contour_name'))
        if(isfield(info,'Color'))
            contour_colors.(lower(remove_bad_chars(info.Contour_name))) = info.Color;
        else
            contour_colors.(lower(remove_bad_chars(info.Contour_name))) = [0;0;0];
        end
    else
        if(isfield(info,'Color'))
            contour_colors.(lower(contour_names{c})) = info.Color;
        else
            contour_colors.(lower(contour_names{c})) = [0;0;0];
        end
    end
    if(isfield(info,'Contour_name'))
        contours.(lower(remove_bad_chars(info.Contour_name))) = temp_data;
    else
        contours.(lower(contour_names{c})) = temp_data;
    end
end

% Get evaluation data
if(ischar(dose_name))
    dose_name = {dose_name};
end
Dose_per_beam = {};
if(length(dose_name)>1)
    Dose = 0;
    for i=1:length(dose_name)
        [Dose_per_beam{i},dose_info] = Get_reggui_data(handles,dose_name{i},'images');
        Dose = Dose + Dose_per_beam{i};
    end
    [handles,dose_name{end+1}] = Set_reggui_data(handles,'Dose',Dose,dose_info,'images',0);
elseif(not(isempty(dose_name{1})))
    Dose = Get_reggui_data(handles,dose_name{1},'images');
else
    Dose = [];
end
if(not(isempty(ct_name)))
    CT = Get_reggui_data(handles,ct_name,'images');
else
    CT = [];
end
if(not(isempty(body_name)))
    body = Get_reggui_data(handles,body_name,'images');
else
    body = [];
end

% Get reference (planning) data
if(ischar(ref_dose_name))
    ref_dose_name = {ref_dose_name};
end
pDose_per_beam = {};
if(length(ref_dose_name)>1)
    pDose = 0;
    for i=1:length(ref_dose_name)
        [pDose_per_beam{i},dose_info] = Get_reggui_data(handles,ref_dose_name{i},'images');
        pDose = pDose + pDose_per_beam{i};
    end
    [handles,ref_dose_name{end+1}] = Set_reggui_data(handles,'pDose',pDose,dose_info,'images',0);
elseif(not(isempty(ref_dose_name{1})))
    pDose = Get_reggui_data(handles,ref_dose_name{1},'images');
else
    pDose = [];
end
if(not(isempty(ref_ct_name)))
    pCT = Get_reggui_data(handles,ref_ct_name,'images');
else
    pCT = [];
end
if(not(isempty(ref_body_name)))
    ref_body = Get_reggui_data(handles,ref_body_name,'images');
else
    ref_body = [];
end

% Define what needs to be computed
% Potential "not process tags": no_dose, no_dose_gamma, no_wet, no_distance, no_motion
process.dose = [];
process.dose_gamma = struct;
process.wet_3D = struct;
process.wet_3D_gamma = struct;
process.wet_2D = struct;
process.distance = struct;
process.distance_wet = struct;
process.motion = not(sum(strcmp(not_process,'no_motion'))) && not(isempty(def_field_name));
for i=1:length(indicators)
    % check if contour is found
    if(not(isfield(contour_rt_names,lower(remove_bad_chars(indicators{i}.struct)))))
        disp(['Cannot find structure ''',indicators{i}.struct,'''. Skip indicator.']);
        continue
    end
    % check which dose has to be evaluated
    if(not(sum(strcmp(not_process,'no_dose'))) && (strcmp(indicators{i}.type,'D') || strcmp(indicators{i}.type,'V') || strcmp(indicators{i}.type,'D_diff') || strcmp(indicators{i}.type,'D_gamma')))
        process.dose = unique([process.dose,indicators{i}.beam]);
    end
    % check which gamma dose map has to be computed
    if(not(sum(strcmp(not_process,'no_dose'))) && not(sum(strcmp(not_process,'no_dose_gamma'))) && (not(isempty(pDose)) && strcmp(indicators{i}.type,'D_gamma')))
        if(not(isfield(process.dose_gamma,contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))))))
            process.dose_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = struct;
        end
        param_string = ['param_',num2str(indicators{i}.param)];
        for j=1:8
            param_string = strrep(param_string,'  ',' ');
        end
        param_string = strrep(strrep(strrep(strrep(strrep(param_string,',','_'),';','_'),' ','_'),'[',''),']','');
        if(not(isfield(process.dose_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))),param_string)))
            process.dose_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string) = [];
        end
        process.dose_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string) = unique([process.dose_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string),indicators{i}.beam]);
    end
    % check which 3D wet map has to be computed
    if(not(sum(strcmp(not_process,'no_wet'))) && (strcmp(indicators{i}.type,'WET_3D') || strcmp(indicators{i}.type,'WET_3D_diff') || strcmp(indicators{i}.type,'WET_3D_gamma')))
        if(not(isfield(process.wet_3D,contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))))))
            process.wet_3D.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = [];
        end
        if(indicators{i}.beam>0)
            process.wet_3D.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = unique([process.wet_3D.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))),indicators{i}.beam]);
        end
    end
    % check which gamma wet map has to be computed
    if(not(sum(strcmp(not_process,'no_wet'))) && strcmp(indicators{i}.type,'WET_3D_gamma'))
        if(not(isfield(process.wet_3D_gamma,contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))))))
            process.wet_3D_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = struct;
        end
        param_string = ['param_',num2str(indicators{i}.param)];
        for j=1:8
            param_string = strrep(param_string,'  ',' ');
        end
        param_string = strrep(strrep(strrep(param_string,',','_'),';','_'),' ','_');
        if(not(isfield(process.wet_3D_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))),param_string)))
            process.wet_3D_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string) = [];
        end
        if(indicators{i}.beam>0)
            process.wet_3D_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string) = unique([process.wet_3D_gamma.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string),indicators{i}.beam]);
        end
    end
    % check which 2D wet map has to be computed
    if(not(sum(strcmp(not_process,'no_wet'))) && (strcmp(indicators{i}.type,'WET_distal') || strcmp(indicators{i}.type,'WET_distal_diff') || strcmp(indicators{i}.type,'WET_proximal') || strcmp(indicators{i}.type,'WET_proximal_diff')))
        if(not(isfield(process.wet_2D,contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))))))
            process.wet_2D.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = [];
        end
        if(indicators{i}.beam>0)
            process.wet_2D.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = unique([process.wet_2D.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))),indicators{i}.beam]);
        end
    end
    % check which distance has to be computed
    if(not(sum(strcmp(not_process,'no_distance'))) && (not(isempty(contour_names)) && strcmp(indicators{i}.type,'Distance')) && isfield(contour_rt_names,lower(remove_bad_chars(indicators{i}.param))))
        if(not(isfield(process.distance,contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))))))
            process.distance.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = struct;
        end
        param_string = contour_rt_names.(lower(remove_bad_chars(indicators{i}.param)));
        if(not(isfield(process.distance.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))),param_string)))
            process.distance.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string) = 0;
        end
    end
    % check which WET distance has to be computed
    if(not(sum(strcmp(not_process,'no_distance'))) && (not(isempty(contour_names)) && strcmp(indicators{i}.type,'Distance_WET')) && isfield(contour_rt_names,lower(remove_bad_chars(indicators{i}.param))))
        if(not(isfield(process.distance_wet,contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))))))
            process.distance_wet.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))) = struct;
        end
        param_string = contour_rt_names.(lower(remove_bad_chars(indicators{i}.param)));
        if(not(isfield(process.distance_wet.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))),param_string)))
            process.distance_wet.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string) = [];
        end
        if(indicators{i}.beam>0)
            process.distance_wet.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string) = unique([process.distance_wet.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(param_string),indicators{i}.beam]);
        end
    end
end

% Compute 3D gamma dose maps
gamma_contours = fieldnames(process.dose_gamma);
for c=1:length(gamma_contours)
    gamma_params = fieldnames(process.dose_gamma.(gamma_contours{c}));
    for p=1:length(gamma_params)
        for f=1:length(process.dose_gamma.(gamma_contours{c}).(gamma_params{p}))
            disp(['Computing Gamma index for beam ',num2str(process.dose_gamma.(gamma_contours{c}).(gamma_params{p})(f)),' in ',gamma_contours{c},' (',gamma_params{p},')...'])
            eval(['gamma_options = [',strrep(strrep(gamma_params{p},'param_',''),'_',','),'];'])
            gamma_options = [gamma_options(2),gamma_options(1),0];
            if(process.dose_gamma.(gamma_contours{c}).(gamma_params{p})(f)>0) % per-beam analysis
                handles = Gamma_index(dose_name{process.dose_gamma.(gamma_contours{c}).(gamma_params{p})(f)},ref_dose_name{process.dose_gamma.(gamma_contours{c}).(gamma_params{p})(f)},gamma_contours{c},['Gamma_',gamma_contours{c},'_',gamma_params{p},'_',num2str(process.dose_gamma.(gamma_contours{c}).(gamma_params{p})(f))],handles,gamma_options);
            else % analysis on the total dose
                handles = Gamma_index(dose_name{end},ref_dose_name{end},gamma_contours{c},['Gamma_',gamma_contours{c},'_',gamma_params{p},'_',num2str(0)],handles,gamma_options);
            end
        end
    end
end

% Compute 3D wet maps
wet_contours = fieldnames(process.wet_3D);
for c=1:length(wet_contours)
    for f=1:length(process.wet_3D.(wet_contours{c}))
        disp(['Computing 3D WET map for beam ',num2str(process.wet_3D.(wet_contours{c})(f)),' in ',wet_contours{c},'...'])
        handles = WEPL_computation(ct_name,{model;sad;plan_name;process.wet_3D.(wet_contours{c})(f)},[ct_name,'_wet_',wet_contours{c},'_',num2str(process.wet_3D.(wet_contours{c})(f))],handles,wet_contours{c});
        if(not(isempty(ref_ct_name)))
            handles = WEPL_computation(ref_ct_name,{model;sad;plan_name;process.wet_3D.(wet_contours{c})(f)},[ref_ct_name,'_wet_',wet_contours{c},'_',num2str(process.wet_3D.(wet_contours{c})(f))],handles,wet_contours{c});
        end
    end
end

% Compute 3D gamma wet maps
gamma_wet_contours = fieldnames(process.wet_3D_gamma);
for c=1:length(gamma_wet_contours)
    gamma_wet_params = fieldnames(process.wet_3D_gamma.(gamma_wet_contours{c}));
    for p=1:length(gamma_wet_params)
        for f=1:length(process.wet_3D_gamma.(gamma_wet_contours{c}).(gamma_wet_params{p}))
            disp(['Computing Gamma WET for beam ',num2str(process.wet_3D_gamma.(gamma_wet_contours{c}).(gamma_wet_params{p})(f)),' in ',gamma_wet_contours{c},' (',gamma_wet_params{p},')...'])
            eval(['gamma_options = [',strrep(strrep(gamma_wet_params{p},'param_',''),'_',','),'];'])
            gamma_options = [gamma_options(2),gamma_options(1),0];
            if(process.wet_3D_gamma.(gamma_wet_contours{c}).(gamma_wet_params{p})(f)>0) % per-beam analysis
                handles = Gamma_index([ct_name,'_wet_',wet_contours{c},'_',num2str(process.wet_3D.(wet_contours{c})(f))],[ref_ct_name,'_wet_',wet_contours{c},'_',num2str(process.wet_3D.(wet_contours{c})(f))],gamma_wet_contours{c},['Gamma_',ref_ct_name,'_wet_',gamma_wet_contours{c},'_',gamma_wet_params{p},'_',num2str(process.wet_3D_gamma.(gamma_wet_contours{c}).(gamma_wet_params{p})(f))],handles,gamma_options);
            end
        end
    end
end

% Compute 2D wet maps
wet_contours = fieldnames(process.wet_2D);
wet_distal = struct;
wet_proximal = struct;
ref_wet_distal = struct;
ref_wet_proximal = struct;
for c=1:length(wet_contours)
    for f=1:length(process.wet_2D.(wet_contours{c}))
        disp(['Computing distal 2D WET map for beam ',num2str(process.wet_2D.(wet_contours{c})(f)),' in ',wet_contours{c},'...'])
        [wet_distal.(wet_contours{c}){f},wet_proximal.(wet_contours{c}){f}] = WEPL_on_distal_surface(handles,ct_name,{model;sad;plan_name;process.wet_2D.(wet_contours{c})(f)},wet_contours{c},body_name);
        if(not(isempty(ref_ct_name)))
            [ref_wet_distal.(wet_contours{c}){f},ref_wet_proximal.(wet_contours{c}){f}] = WEPL_on_distal_surface(handles,ref_ct_name,{model;sad;plan_name;process.wet_2D.(wet_contours{c})(f)},wet_contours{c},ref_body_name);
        end
    end
end

% Compute distances
distance_1st_contours = fieldnames(process.distance);
distance = struct;
for c=1:length(distance_1st_contours)
    distance_2nd_contours = fieldnames(process.distance.(distance_1st_contours{c}));
    for p=1:length(distance_2nd_contours)
        for f=1:length(process.distance.(distance_1st_contours{c}).(distance_2nd_contours{p}))
            disp(['Computing geometrical distance between ',distance_1st_contours{c},' and ',distance_2nd_contours{p},' ...'])
            distance.(distance_1st_contours{c}).(distance_2nd_contours{c}){f} = Contour_distance(distance_1st_contours{c},distance_2nd_contours{p},handles);
        end
    end
end

% Compute WET distances
distance_1st_contours = fieldnames(process.distance_wet);
distance_wet = struct;
for c=1:length(distance_1st_contours)
    distance_2nd_contours = fieldnames(process.distance_wet.(distance_1st_contours{c}));
    for p=1:length(distance_2nd_contours)
        for f=1:length(process.distance_wet.(distance_1st_contours{c}).(distance_2nd_contours{p}))
            disp(['Computing WET distance for beam ',num2str(process.distance_wet.(distance_1st_contours{c}).(distance_2nd_contours{p})(f)),' between ',distance_1st_contours{c},' and ',distance_2nd_contours{p},' ...'])
            if(process.distance_wet.(distance_1st_contours{c}).(distance_2nd_contours{p})(f)>0) % per-beam analysis
                distance_wet.(distance_1st_contours{c}).(distance_2nd_contours{c}){process.distance_wet.(distance_1st_contours{c}).(distance_2nd_contours{p})(f)} = WE_contour_distance(ct_name,distance_1st_contours{c},distance_2nd_contours{p},{model;sad;plan_name;process.distance_wet.(distance_1st_contours{c}).(distance_2nd_contours{p})(f)},handles,body_name);
            end
        end
    end
end

% Compute motion
if(process.motion)
    handles = Field_norm(def_field_name,[def_field_name,'_norm'],handles);
    motion_amplitude = Get_reggui_data(handles,[def_field_name,'_norm'],'images');
end


% ------------------
% Compute indicators
% ------------------

for i=1:length(indicators)
    
    if(not(ischar(indicators{i}.type)))
        disp('Uncorrect type format. Skip.');
        continue
    end
    
    % by default, put NaN as evaluation result
    indicators{i}.evaluation = NaN;
    
    if(not(isfield(contours,lower(remove_bad_chars(indicators{i}.struct)))))
        disp(['Cannot find structure ''',indicators{i}.struct,'''. Skip indicator.']);
        continue
    end
    
    % display indicator being computed
    if(indicators{i}.beam>0)
        disp([indicators{i}.type,'_',indicators{i}.value,num2str(indicators{i}.param),indicators{i}.param_unit,' in ',indicators{i}.struct,' (for beam ',num2str(indicators{i}.beam),') ...'])
    else
        disp([indicators{i}.type,'_',indicators{i}.value,num2str(indicators{i}.param),indicators{i}.param_unit,' in ',indicators{i}.struct,' ...'])
    end
    
    % get current mask
    mask = contours.(lower(remove_bad_chars(indicators{i}.struct)));
    
    % define beam or full plan
    beam = 0;
    if(isfield(indicators{i},'beam'))
        if(not(isempty(indicators{i}.beam)))
            beam = indicators{i}.beam;
        end
    end
    if(beam>0)
        if(not(isempty(Dose_per_beam)))
            D = Dose_per_beam{beam};
        elseif(sum(strcmp(indicators{i}.type,{'D','V','D_diff','D_gamma'})))
            disp(['Warning: cannot find dose for beam ',num2str(beam)])
            D = Dose*NaN;
        end
        if(not(isempty(pDose_per_beam)))
            pD = pDose_per_beam{beam};
        elseif(sum(strcmp(indicators{i}.type,{'D','V','D_diff','D_gamma'})))
            disp(['Warning: cannot find reference dose for beam ',num2str(beam)])
            pD = Dose*NaN;
        end
    else
        D = Dose;
        pD = pDose;
    end
    
    % Select appropriate calculation method according to type
    switch indicators{i}.type
        
        case 'D' % -----------------------------------------------------
            %   value: -; min; max; mean; geud;
            %   units: [Gy]; [%p] (of prescribed dose);
            %   param_units: [%]; [cc];
            if(isempty(process.dose))
                disp('    Skip indicator computation.')
                continue
            end
            if(isempty(D))
                disp('No dose map. Abort indicator computation.')
                continue
            end
            % Compute dosimetric indicator
            switch indicators{i}.value
                case 'min'
                    temp = min(D(mask>=0.5));% in Gy
                case 'max'
                    temp = max(D(mask>=0.5));% in Gy
                case 'mean'
                    temp = mean(D(mask>=0.5));% in Gy
                case 'geud'
                    temp = (mean(D(mask>=0.5).^(-indicators{i}.param)))^(-1/indicators{i}.param);% in Gy
                otherwise % Dx
                    switch indicators{i}.param_unit
                        case '[%]'
                            temp = dose_to_volume(D(mask>=0.5),indicators{i}.param/100);% in Gy
                        otherwise
                            disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                    end
            end
            % Store with appropriate unit
            switch indicators{i}.unit
                case '[Gy]'
                    indicators{i}.evaluation = temp;
                case '[%p]'
                    if(not(isempty(indicators{i}.prescription)))
                        indicators{i}.evaluation = temp / indicators{i}.prescription*100;
                    else
                        disp('Cannot compute indicator without prescription')
                        continue
                    end
                otherwise
                    disp(['Unit ',indicators{i}.unit,' not recognized for indicator ',indicators{i}.type])
                    continue
            end
            
        case 'V' % -----------------------------------------------------
            %   value: -;
            %   units: [%]; [cc];
            %   param_units: [Gy]; [%p];
            if(isempty(process.dose))
                disp('    Skip indicator computation.')
                continue
            end
            if(isempty(D))
                disp('No dose map. Abort indicator computation.')
                continue
            end
            if(isempty(indicators{i}.param))
                temp = 100;% in %
            else
                switch indicators{i}.param_unit
                    case '[Gy]'
                        temp = volume_to_dose(D,mask,indicators{i}.param);% in %
                    case '[%p]'
                        if(not(isempty(indicators{i}.prescription)))
                            temp = volume_to_dose(D,mask,indicators{i}.param/100*indicators{i}.prescription);% in %
                        else
                            disp('Cannot compute indicator without prescription')
                            temp = NaN;
                        end
                    otherwise
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                end
            end
            % Store with appropriate unit
            switch indicators{i}.unit
                case '[%]'
                    indicators{i}.evaluation = temp;
                case '[cc]'
                    indicators{i}.evaluation = 1e-3*temp/100*length(mask(mask>=0.5))*handles.spacing(1)*handles.spacing(2)*handles.spacing(3);
                otherwise
                    disp(['Unit ',indicators{i}.unit,' not recognized for indicator ',indicators{i}.type])
                    continue
            end
            
        case 'D_index' % ----------------------------------------------
            %   value: conformity; homogeneity;
            %   units: [-];
            %   param_units: [Gy]; [%p]; [%];
            if(isempty(process.dose))
                disp('    Skip indicator computation.')
                continue
            end
            if(isempty(D))
                disp('No dose map. Abort indicator computation.')
                continue
            end
            switch indicators{i}.value
                case 'conformity' % CI = V(d) / TV where V(d) is the volume receiving a dose d (RTOG). Alternative: CI = V(d) / TV(d), where TV(d) is the intersection between V(d) and TV.
                    switch indicators{i}.param_unit
                        case '[Gy]'
                            vd = length(D(D>=indicators{i}.param));
                        case '[%p]'
                            if(not(isempty(indicators{i}.prescription)))
                                vd = length(D(D>=indicators{i}.param/100*indicators{i}.prescription));
                            else
                                disp('Cannot compute indicator without prescription')
                                vd = NaN;
                            end
                        otherwise
                            disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                            vd = NaN;
                    end
                    tv = length(mask(mask>=0.5));
                    indicators{i}.evaluation = vd/tv;
                case 'homogeneity' % HI = D(x) / D(100-x) where D(x) is dose at x% of the volume
                    d1 = dose_to_volume(D(mask>=0.5),indicators{i}.param/100);% in Gy
                    d2 = dose_to_volume(D(mask>=0.5),1-indicators{i}.param/100);% in Gy
                    indicators{i}.evaluation = min(d1,d2)/max(d1,d2);
            end
            
        case 'D_diff' % -----------------------------------------------
            %   value: min; max; mean; max_abs; mean_abs; percentile; percentile_abs
            %   units: [Gy]; [%p]; relative
            %   param_units: []; [%] (for percentile value)
            if(isempty(process.dose))
                disp('    Skip indicator computation.')
                continue
            end
            if(isempty(D) || isempty(pD))
                disp('No dose map. Abort indicator computation.')
                continue
            end
            temp = D-pD;
            if(strcmp(indicators{i}.unit,'relative'))
                temp = temp./(pD+eps);
            end
            switch indicators{i}.value
                case 'min'
                    temp = min(temp(mask>=0.5));
                case 'max'
                    temp = max(temp(mask>=0.5));
                case 'mean'
                    temp = mean(temp(mask>=0.5));
                case 'max_abs'
                    temp = max(abs(temp(mask>=0.5)));
                case 'mean_abs'
                    temp = mean(abs(temp(mask>=0.5)));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(temp(mask>=0.5),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'percentile_abs'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(abs(temp(mask>=0.5)),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            % Store with appropriate unit
            switch indicators{i}.unit
                case '[Gy]'
                    indicators{i}.evaluation = temp;
                case '[%p]'
                    if(not(isempty(indicators{i}.prescription)))
                        indicators{i}.evaluation = temp / indicators{i}.prescription*100;
                    else
                        disp('Cannot compute indicator without prescription')
                        continue
                    end
                case 'relative'
                    indicators{i}.evaluation = temp;
                otherwise
                    disp(['Unit ',indicators{i}.unit,' not recognized for indicator ',indicators{i}.type])
                    continue
            end
            
        case 'D_gamma' % ----------------------------------------------
            %   value: min; max; mean; passing_rate;
            %   units: [-];
            %   param_units: [%,mm];
            if(not(length(fieldnames(process.dose_gamma))))
                disp('    Skip indicator computation.')
                continue
            end
            param_string = ['param_',num2str(indicators{i}.param)];
            for j=1:8
                param_string = strrep(param_string,'  ',' ');
            end
            param_string = strrep(strrep(strrep(strrep(strrep(param_string,',','_'),';','_'),' ','_'),'[',''),']','');
            G = Get_reggui_data(handles,['Gamma_',contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))),'_',param_string,'_',num2str(indicators{i}.beam)]);
            switch indicators{i}.value
                case 'min'
                    temp = min(G(mask>=0.5));
                case 'max'
                    temp = max(G(mask>=0.5));
                case 'mean'
                    temp = mean(G(mask>=0.5));
                case 'passing_rate'
                    temp = sum(sum(sum((mask>=0.5).*(G<=1))))/sum(sum(sum(mask>=0.5)));
            end
            indicators{i}.evaluation = temp;
            
        case 'WET_3D' % ------------------------------------------------
            %   value:  min; max; mean; percentile;
            %   units: [mm];
            %   param_units: []; [%] (for percentile value)
            if(not(length(fieldnames(process.wet_3D))))
                disp('    Skip indicator computation.')
                continue
            end
            if(indicators{i}.beam<1)
                disp('     Cannot compute WET without beam index.')
                continue
            end
            W = Get_reggui_data(handles,[ct_name,'_wet_',contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))),'_',num2str(indicators{i}.beam)]);
            switch indicators{i}.value
                case 'min'
                    temp = min(W(mask>=0.5));
                case 'max'
                    temp = max(W(mask>=0.5));
                case 'mean'
                    temp = mean(W(mask>=0.5));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(W(mask>=0.5),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'WET_3D_diff' % -------------------------------------------
            %   value:  min; max; mean; max_abs; mean_abs; percentile; percentile_abs
            %   units: [mm];
            %   param_units: []; [%] (for percentile value)
            if(not(length(fieldnames(process.wet_3D))))
                disp('    Skip indicator computation.')
                continue
            end
            if(indicators{i}.beam<1)
                disp('     Cannot compute WET without beam index.')
                continue
            end
            W = Get_reggui_data(handles,[ct_name,'_wet_',contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))),'_',num2str(indicators{i}.beam)]);
            pW = Get_reggui_data(handles,[ref_ct_name,'_wet_',contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))),'_',num2str(indicators{i}.beam)]);
            W = W-pW;
            if(strcmp(indicators{i}.unit,'relative'))
                W = W./(pW+eps);
            end
            switch indicators{i}.value
                case 'min'
                    temp = min(W(mask>=0.5));
                case 'max'
                    temp = max(W(mask>=0.5));
                case 'mean'
                    temp = mean(W(mask>=0.5));
                case 'max_abs'
                    temp = max(abs(W(mask>=0.5)));
                case 'mean_abs'
                    temp = mean(abs(W(mask>=0.5)));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(W(mask>=0.5),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'percentile_abs'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(abs(W(mask>=0.5)),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'WET_3D_gamma' % ---------------------------------------------
            %   value: min; max; mean; passing_rate;
            %   units: [-];
            if(not(length(fieldnames(process.wet_3D_gamma))))
                disp('    Skip indicator computation.')
                continue
            end
            param_string = ['param_',num2str(indicators{i}.param)];
            for j=1:8
                param_string = strrep(param_string,'  ',' ');
            end
            param_string = strrep(strrep(strrep(param_string,',','_'),';','_'),' ','_');
            G = Get_reggui_data(handles,['Gamma_',ref_ct_name,'_wet_',contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct))),'_',param_string,'_',num2str(indicators{i}.beam)]);
            switch indicators{i}.value
                case 'min'
                    temp = min(G(mask>=0.5));
                case 'max'
                    temp = max(G(mask>=0.5));
                case 'mean'
                    temp = mean(G(mask>=0.5));
                case 'passing_rate'
                    temp = sum(sum(sum((mask>=0.5).*(G<=1))))/sum(sum(sum(mask>=0.5)));
            end
            indicators{i}.evaluation = temp;
            
        case 'WET_distal' % --------------------------------------------
            %   value:  min; max; mean; percentile;
            %   units: [mm];
            %   param_units: []; [%] (for percentile value)
            if(not(length(fieldnames(process.wet_2D))))
                disp('    Skip indicator computation.')
                continue
            end
            map = wet_distal.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))){beam};            
            if(not(isempty(illustration_output_dir)))
                export_illustration(map,strrep(fullfile(illustration_output_dir,['wet_vCT_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet');
            end
            map = map(not(isnan(map)));
            switch indicators{i}.value
                case 'min'
                    temp = min(map);
                case 'max'
                    temp = max(map);
                case 'mean'
                    temp = mean(map);
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(map,indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'WET_distal_diff' % ---------------------------------------
            %   value:  min; max; mean; max_abs; mean_abs; percentile; percentile_abs; overrange_mean; overrange_max; overrange_rate; underrange_mean; underrange_max; underrange_rate
            %   units: [mm]; [];
            %   param_units: []; [%] (for percentile value); [mm] for over/underranges_rate
            if(not(length(fieldnames(process.wet_2D))))
                disp('    Skip indicator computation.')
                continue
            end
            map = wet_distal.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))){beam};
            ref_map = ref_wet_distal.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))){beam};
            temp = map-ref_map;            
            if(not(isempty(illustration_output_dir)))
                export_illustration(ref_map,strrep(fullfile(illustration_output_dir,['wet_pCT_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet');
                export_illustration(map,strrep(fullfile(illustration_output_dir,['wet_vCT_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet');
                export_illustration(temp,strrep(fullfile(illustration_output_dir,['wet_diff_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_diff');
            end
            temp = temp(not(isnan(temp)));
            switch indicators{i}.value
                case 'min'
                    temp = min(temp);
                case 'max'
                    temp = max(temp);
                case 'mean'
                    temp = mean(temp);
                case 'max_abs'
                    temp = max(abs(temp));
                case 'mean_abs'
                    temp = mean(abs(temp));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(temp,indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'percentile_abs'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(abs(temp),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'overrange_mean'
                    [overrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(overrange_map,strrep(fullfile(illustration_output_dir,['wet_overranges_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_overrange');
                    end
                    overrange_map = overrange_map(not(isnan(overrange_map)));
                    temp = max(overrange_map);
                case 'overrange_max'
                    [overrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(overrange_map,strrep(fullfile(illustration_output_dir,['wet_overranges_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_overrange');
                    end
                    overrange_map = overrange_map(not(isnan(overrange_map)));
                    temp = max(overrange_map);
                case 'overrange_rate'
                    [overrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(overrange_map,strrep(fullfile(illustration_output_dir,['wet_overranges_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_overrange');
                    end
                    overrange_map = overrange_map(not(isnan(overrange_map)));
                    if(strcmp(indicators{i}.param_unit,'[mm]'))
                        temp = sum(abs(overrange_map)>indicators{i}.param)/length(overrange_map);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'underrange_mean'
                    [~,underrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(underrange_map,strrep(fullfile(illustration_output_dir,['wet_underranges_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_underrange');
                    end
                    underrange_map = underrange_map(not(isnan(underrange_map)));
                    temp = max(underrange_map);
                case 'underrange_max'
                    [~,underrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(underrange_map,strrep(fullfile(illustration_output_dir,['wet_underranges_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_underrange');
                    end
                    underrange_map = underrange_map(not(isnan(underrange_map)));
                    temp = max(underrange_map);
                case 'underrange_rate'
                    [~,underrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(underrange_map,strrep(fullfile(illustration_output_dir,['wet_underranges_2D_distal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_underrange');
                    end
                    underrange_map = underrange_map(not(isnan(underrange_map)));
                    if(strcmp(indicators{i}.param_unit,'[mm]'))
                        temp = sum(abs(underrange_map)>indicators{i}.param)/length(underrange_map);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'WET_proximal' % ------------------------------------------
            %   value:  min; max; mean; percentile;
            %   units: [mm];
            %   param_units: []; [%] (for percentile value)
            if(not(length(fieldnames(process.wet_2D))))
                disp('    Skip indicator computation.')
                continue
            end
            map = wet_proximal.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))){beam};            
            if(not(isempty(illustration_output_dir)))
                export_illustration(map,strrep(fullfile(illustration_output_dir,['wet_vCT_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet');
            end
            map = map(not(isnan(map)));
            switch indicators{i}.value
                case 'min'
                    temp = min(map);
                case 'max'
                    temp = max(map);
                case 'mean'
                    temp = mean(map);
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(map,indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'WET_proximal_diff' % -------------------------------------
            %   value:  min; max; mean; max_abs; mean_abs; percentile; percentile_abs; overrange_mean; overrange_max; overrange_rate; underrange_mean; underrange_max; underrange_rate
            %   units: [mm]; [];
            %   param_units: []; [%] (for percentile value); [mm] for over/underranges_rate
            if(not(length(fieldnames(process.wet_2D))))
                disp('    Skip indicator computation.')
                continue
            end
            map = wet_proximal.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))){beam};
            ref_map = ref_wet_proximal.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))){beam};
            temp = map-ref_map;            
            if(not(isempty(illustration_output_dir)))
                export_illustration(ref_map,strrep(fullfile(illustration_output_dir,['wet_pCT_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet');
                export_illustration(map,strrep(fullfile(illustration_output_dir,['wet_vCT_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet');
                export_illustration(temp,strrep(fullfile(illustration_output_dir,['wet_diff_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_diff');
            end
            temp = temp(not(isnan(temp)));
            switch indicators{i}.value
                case 'min'
                    temp = min(temp);
                case 'max'
                    temp = max(temp);
                case 'mean'
                    temp = mean(temp);
                case 'max_abs'
                    temp = max(abs(temp));
                case 'mean_abs'
                    temp = mean(abs(temp));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(temp,indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'percentile_abs'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(abs(temp),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'overrange_mean'
                    [overrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(overrange_map,strrep(fullfile(illustration_output_dir,['wet_overranges_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_overrange');
                    end
                    overrange_map = overrange_map(not(isnan(overrange_map)));
                    temp = max(overrange_map);
                case 'overrange_max'
                    [overrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(overrange_map,strrep(fullfile(illustration_output_dir,['wet_overranges_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_overrange');
                    end
                    overrange_map = overrange_map(not(isnan(overrange_map)));
                    temp = max(overrange_map);
                case 'overrange_rate'
                    [overrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(overrange_map,strrep(fullfile(illustration_output_dir,['wet_overranges_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_overrange');
                    end
                    overrange_map = overrange_map(not(isnan(overrange_map)));
                    if(strcmp(indicators{i}.param_unit,'[mm]'))
                        temp = sum(abs(overrange_map)>indicators{i}.param)/length(overrange_map);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'underrange_mean'
                    [~,underrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(underrange_map,strrep(fullfile(illustration_output_dir,['wet_underranges_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_underrange');
                    end
                    underrange_map = underrange_map(not(isnan(underrange_map)));
                    temp = max(underrange_map);
                case 'underrange_max'
                    [~,underrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(underrange_map,strrep(fullfile(illustration_output_dir,['wet_underranges_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_underrange');
                    end
                    underrange_map = underrange_map(not(isnan(underrange_map)));
                    temp = max(underrange_map);
                case 'underrange_rate'
                    [~,underrange_map] = wepl_analysis_on_target_surface(ref_map,map,smearing_size);                    
                    if(not(isempty(illustration_output_dir)))
                        export_illustration(underrange_map,strrep(fullfile(illustration_output_dir,['wet_underranges_2D_proximal_',num2str(indicators{i}.beam),'.png']),'\','/'),'wet_underrange');
                    end
                    underrange_map = underrange_map(not(isnan(underrange_map)));
                    if(strcmp(indicators{i}.param_unit,'[mm]'))
                        temp = sum(abs(underrange_map)>indicators{i}.param)/length(underrange_map);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'Intensity' % ---------------------------------------------
            %   value:  mean; std; percentile;
            %   units: [HU]; [SP];
            %   param_units: []; [%] (for percentile value)
            switch indicators{i}.unit
                case '[HU]'
                    temp = CT;
                case '[SP]'
                    if(not(isempty(model)))
                        temp = hu_to_we(CT,model);
                    else
                        disp('Cannot convert CT image into stopping power without conversion model. Abort.')
                        continue
                    end
                otherwise
                    disp(['Unit ',indicators{i}.unit,' not recognized for indicator ',indicators{i}.type])
                    continue
            end
            switch indicators{i}.value
                case 'mean'
                    temp = mean(temp(mask>=0.5));
                case 'std'
                    temp = std(temp(mask>=0.5));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(temp(mask>=0.5),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'Intensity_diff' % ---------------------------------------------
            %   value:  min; max; mean; max_abs; mean_abs; percentile; percentile_abs
            %   units: [HU]; [SP]; relative;
            %   param_units: []; [%] (for percentile value)
            switch indicators{i}.unit
                case '[HU]'
                    temp = CT-pCT;
                case '[SP]'
                    if(not(isempty(model)))
                        temp = hu_to_we(CT,model) - hu_to_we(pCT,model);
                    else
                        disp('Cannot convert CT image into stopping power without conversion model. Abort.')
                        continue
                    end
                case 'relative'
                    temp = (CT-pCT)./(pCT+eps);
                otherwise
                    disp(['Unit ',indicators{i}.unit,' not recognized for indicator ',indicators{i}.type])
                    continue
            end
            switch indicators{i}.value
                case 'min'
                    temp = min(temp(mask>=0.5));
                case 'max'
                    temp = max(temp(mask>=0.5));
                case 'mean'
                    temp = mean(temp(mask>=0.5));
                case 'mean_abs'
                    temp = mean(abs(temp(mask>=0.5)));
                case 'max_abs'
                    temp = max(abs(temp(mask>=0.5)));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(temp(mask>=0.5),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
                case 'percentile_abs'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(abs(temp(mask>=0.5)),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
        case 'Distance' % ----------------------------------------------
            %   value:  min; max; mean;
            %   units: [mm];
            if(not(length(fieldnames(process.distance))) || not(isfield(contour_rt_names,lower(remove_bad_chars(indicators{i}.param)))))
                disp('    Skip indicator computation.')
                continue
            end
            d = distance.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(contour_rt_names.(lower(remove_bad_chars(indicators{i}.param)))){1};%minimum,mean,maximum,std,median
            switch indicators{i}.value
                case 'min'
                    indicators{i}.evaluation = d(1);
                case 'max'
                    indicators{i}.evaluation = d(3);
                case 'mean'
                    indicators{i}.evaluation = d(2);
            end
            
        case 'Distance_WET' % ------------------------------------------
            %   value:  min; max; mean;
            %   units: [mm];
            if(not(length(fieldnames(process.distance))) || not(isfield(contour_rt_names,lower(remove_bad_chars(indicators{i}.param)))))
                disp('    Skip indicator computation.')
                continue
            end
            d = distance_wet.(contour_rt_names.(lower(remove_bad_chars(indicators{i}.struct)))).(contour_rt_names.(lower(remove_bad_chars(indicators{i}.param)))){beam};%minimum,mean,maximum,std,median
            switch indicators{i}.value
                case 'min'
                    indicators{i}.evaluation = d(1);
                case 'max'
                    indicators{i}.evaluation = d(3);
                case 'mean'
                    indicators{i}.evaluation = d(2);
            end
            
        case 'Motion' % ------------------------------------------------
            %   value:  min; max; mean; percentile;
            %   units: [mm];
            %   param_units: []; [%] (for percentile value)
            if(not(process.motion))
                disp('    Skip indicator computation.')
                continue
            end
            switch indicators{i}.value
                case 'min'
                    temp = min(motion_amplitude(mask>=0.5));
                case 'max'
                    temp = max(motion_amplitude(mask>=0.5));
                case 'mean'
                    temp = mean(motion_amplitude(mask>=0.5));
                case 'percentile'
                    if(strcmp(indicators{i}.param_unit,'[%]'))
                        temp = compute_prctile(motion_amplitude(mask>=0.5),indicators{i}.param);
                    else
                        disp(['Parameter unit ',indicators{i}.param_unit,' not recognized for indicator ',indicators{i}.type,' ',indicators{i}.value,' ',num2str(indicators{i}.param)])
                        temp = NaN;
                    end
            end
            indicators{i}.evaluation = temp;
            
            
        otherwise
            disp(['Unrecognized type ''',indicators{i}.type])
    end
    
    % Evaluate acceptance
    if(isfield(indicators{i},'evaluation') && isfield(indicators{i},'acceptance_test') && isfield(indicators{i},'acceptance_level'))
        if(not(isempty(indicators{i}.acceptance_test)) && not(isempty(indicators{i}.acceptance_level)))
            level = indicators{i}.acceptance_level;
            res = indicators{i}.evaluation;
            tol = 0;
            if(not(strcmp(indicators{i}.unit,indicators{i}.acceptance_unit)) && not(isempty(indicators{i}.unit)) && not(isempty(indicators{i}.acceptance_unit)))
                switch [indicators{i}.unit,indicators{i}.acceptance_unit]
                    case '[Gy][%p]'
                        if(not(isempty(indicators{i}.prescription)))
                            res = res/indicators{i}.prescription*100;
                        else
                            disp('Cannot convert in relative dose without prescription.')
                            temp = NaN;
                        end
                    case '[%p][Gy]'
                        if(not(isempty(indicators{i}.prescription)))
                            res = res*indicators{i}.prescription/100;
                        else
                            disp('Cannot convert in absolute dose without prescription.')
                            temp = NaN;
                        end
                    case '[cc][%]'                                              
                        res = 1e3*res*100/length(mask(mask>=0.5))/(handles.spacing(1)*handles.spacing(2)*handles.spacing(3));
                    case '[%][cc]'
                        res = 1e-3*res/100*length(mask(mask>=0.5))*handles.spacing(1)*handles.spacing(2)*handles.spacing(3);
                    otherwise
                        disp(['Cannot convert ',indicators{i}.unit,' into ',indicators{i}.acceptance_unit])
                        res = NaN;
                end
            end
            if(isfield(indicators{i},'acceptance_tolerance'))
                if(not(isempty(indicators{i}.acceptance_tolerance)))
                    tol = indicators{i}.acceptance_tolerance;
                end
            end
            switch indicators{i}.acceptance_test
                case '>'
                    test = res-level;
                case '<'
                    test = level-res;
            end
            if(test>=0)
                indicators{i}.acceptance_evaluation = 'pass';
            elseif(abs(test)<=tol)
                indicators{i}.acceptance_evaluation = 'within_tolerance';
            else
                indicators{i}.acceptance_evaluation = 'fail';
            end
        end
    end
    
    try
        disp(['   ',num2str(indicators{i}.evaluation),' ',indicators{i}.unit,' -> ',indicators{i}.acceptance_evaluation])
    catch
    end
    
    % Retrieve structure color
    indicators{i}.struct_color = contour_colors.(lower(remove_bad_chars(indicators{i}.struct)));
    
end

end


% -----------------------------------------------------------------------
function export_illustration(image_value,image_filename,type)

% wet maps
cm_wet_1 = [1,1,1;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;...
    0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;...
    0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;...
    0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,0.9375;0.125,1,0.875;0.1875,1,0.8125;...
    0.25,1,0.75;0.3125,1,0.6875;0.375,1,0.625;0.4375,1,0.5625;0.5,1,0.5;...
    0.5625,1,0.4375;0.625,1,0.375;0.6875,1,0.3125;0.75,1,0.25;0.8125,1,0.1875;...
    0.8750,1,0.125;0.9375,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;...
    1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;...
    1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;...
    0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0;0.5,0,0];
cm_wet_2 = [[1,1,1];[linspace(0,1,50)';ones(50,1)]*0.95,sqrt([linspace(0,1,40)';ones(20,1);linspace(1,0,40)'])*0.95,[ones(50,1);linspace(1,0,50)']*0.95];

switch type
    case 'wet'
        image_value = image_value-min(image_value(:));
        image_value = image_value/max(image_value(:))*size(cm_wet_2,1);
        imwrite(image_value,cm_wet_2,image_filename);
    case 'wet_diff'
        image_value = image_value/max(abs(image_value(:)))*size(cm_wet_1,1)/2+size(cm_wet_1,1)/2;
        imwrite(image_value,cm_wet_1,image_filename);
    case 'wet_underrange'
        image_value = -image_value;
        image_value = image_value-min(image_value(:));
        image_value = image_value/max(image_value(:))*size(cm_wet_2,1);
        imwrite(image_value,cm_wet_2,image_filename);
    case 'wet_overrange'
        image_value = image_value-min(image_value(:));
        image_value = image_value/max(image_value(:))*size(cm_wet_2,1);
        imwrite(image_value,cm_wet_2,image_filename);
end
end
