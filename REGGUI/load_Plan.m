%% load_Plan
% Load a treatment plan from file
%
%% Syntax
% |[myBeamData,myInfo] = load_Plan(plan_filename,format)|
%
%
%% Description
% |[myBeamData,myInfo] = load_Plan(plan_filename,format)| Load a treatment plan from file
%
%
%% Input arguments
% |plan_filename| - _STRING_ - File name (including path) of the data to be loaded
%
% |format| - _STRING or INTEGER_ -   Format of the file. The options are: 
%
% * 1 or 'dcm' : DICOM File 
% * 2 or 'pld' : PLD File or ZIP containing multiple PLDs
% * 3 or 'gate' : GATE  File 
%
%
%% Output arguments
%
% |myBeamData| - _CELL VECTOR of STRUCTURE_ -  |myBeamData{i}| Description of the the geometry of the i-th proton beam. See |load_DICOM_RT_Plan| or |load_PLD| or |load_Gate_Plan| for more details.
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file. See |load_DICOM_RT_Plan| or |load_PLD| or |load_Gate_Plan| for more details.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [myBeamData,myInfo] = load_Plan(plan_filename,format,ask_details)

% Authors : G.Janssens (open.reggui@gmail.com)

if(nargin<3)
    ask_details = 0;
end

switch format
    case 'dcm'
        [myBeamData,myInfo] = load_DICOM_RT_Plan(plan_filename , ask_details);
    case 'pld'
        [~,~,ext] = fileparts(plan_filename);
        if(strcmp(ext,'.zip'))
            [myBeamData,myInfo] = load_PLD_folder(plan_filename,ask_details);
        else
            [myBeamData,myInfo] = load_PLD(plan_filename,ask_details);
        end
    case 'gate'
        [myBeamData,myInfo] = load_Gate_Plan(plan_filename);
    case 'json'
        [myBeamData,myInfo] = load_JSON_Plan(plan_filename,ask_details);
    otherwise
        error('Unknown type. Available input formats are: dcm, pld and gate.')
end
