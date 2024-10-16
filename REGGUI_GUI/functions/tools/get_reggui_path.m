%% get_reggui_path
% Return the name of the root REGGUI directory and of the directory containing the user data.
% The user data folder is constructed as: |[REGGUIroot / 'REGGUI_userdata']|
%
%% Syntax
% |[reggui_dir,reggui_config_dir] = get_reggui_path()|
%
% |[reggui_dir,reggui_config_dir] = get_reggui_path(reggui_dir)|
%
%
%% Description
% |[reggui_dir,reggui_config_dir] = get_reggui_path()| Return the root REGGUI directory based on directory of function |get_reggui_path|
%
% |[reggui_dir,reggui_config_dir] = get_reggui_path(reggui_dir)| Build user data directory using the provided |reggui_dir|
%
%
%% Input arguments
% |reggui_dir| - _STRING_ -  [OPTIONAL. Default: root REGGUI path based on |get_reggui_path| folder] Name of the directory to use as the root for creating the user data folder.
%
%
%% Output arguments
%
% |reggui_dir| - _STRING_ - Name of the root REGGUI directory. Either based on function folder or on the folder name provided in input
%
% |reggui_config_dir| - _STRING_ - Name of the user data directory. Either based on function folder or on the folder name provided in input
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [reggui_dir,reggui_config_dir] = get_reggui_path(reggui_dir)

if(nargin<1)
    reggui_filename = which('reggui');
    reggui_dir = fileparts(reggui_filename);
end

reggui_config_dir = fullfile(fileparts(reggui_dir),'REGGUI_userdata');
