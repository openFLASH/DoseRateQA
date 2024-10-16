%% newpatient
% Create a new meta ('*.mha') patient data structure
%
%% Syntax
% |patient = newpatient()|
%
% |patient = newpatient(fname)|
%
% |patient = newpatient(fname,gname)|
%
%
%% Description
% |patient = newpatient()| Create a new patient data structure with default name and default Patient first
%
% |patient = newpatient(fname)| Create a new patient data structure with specified name and default Patient first
%
% |patient = newpatient(fname,gname)| Create a new patient data structure with specified name and specified Patient first
%
%
%% Input arguments
% |fname| - _STRING_ - [OPTIONAL. Default = ''] Patient name
%
% |gname| - _STRING_ - [OPTIOANL. Default = ''] Patient first name
%
%
%% Output arguments
%
% |patient| - _STRUCTURE_ - Patient data structure
%
% * |patient.fname| - _STRING_ - Patient name
% * |patient.gname| - _STRING_ - Gender name
% * |patient.birth| - _STRING_ - Date of birth
% * |patient.weight| - _SCALAR_ - Weight
% * |patient.dose| - _SCALAR_ - Dose
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function patient = newpatient(fname,gname)

if nargin<2, gname = ''; end;
if nargin<1, fname = ''; end;

patient = struct(...
    'fname',fname,...
    'gname',gname,...
    'birth','',...
    'weight',0,...
    'dose',0);
