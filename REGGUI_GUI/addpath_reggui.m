%% addpath_reggui
% Add the REGGUI folder and all its sub-folder to the Matlab path
%
%% Syntax
% |addpath_reggui()|
%
% |addpath_reggui(reggui_path)|
%
%
%% Description
% |addpath_reggui()| Add the current working folder and all its sub-folder to the Matlab path
%
% |addpath_reggui(reggui_path)| Add the |reggui_path| folder and all its sub-folder to the Matlab path
%
%
%% Input arguments
% |reggui_path| - _STRING_ - [OPTIONAL. Default: directory of the function |addpath_reggui|] Root folder of the openREGGUI directory
%
%
%% Output arguments
%
% None
%
%% Contributors
% Authors : Rudi Labarbe (open.reggui@gmail.com)

function addpath_reggui(reggui_path)
	
if (nargin < 1)
	reggui_path = fileparts(mfilename('fullpath'));
end

addpath(reggui_path);
d = dir(reggui_path);
for i=1:length(d)
    if(d(i).isdir && (not(strcmp(d(i).name(1),'.')))) % do not include hidden folder (e.g. ".git")
        addpath(genpath(fullfile(reggui_path,d(i).name)));
    end
end

return
