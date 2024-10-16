%% mkdir_reggui_userdata
% Create a new directory in the REGGUI_userdata folder.
%
% The function also checks that the folder was properly created. If not, it rises an error.
%
%% Syntax
% |mkdir_reggui_userdata(folder)|
%
%% Description
% |mkdir_reggui_userdata(folder)| Create the directory |folder| in the REGGUI_userdata folder.
%
%% Input arguments
% |folder| - _STRING_ - Name of the folder to be created
%
%% Output arguments
%
% |fullpath| -_STRING_- Full path to the newly created folder
%
%% Contributors
% Authors : Rudi (open.reggui@gmail.com)

function fullpath = mkdir_reggui_userdata(folder)

[~, temp_dir]= get_reggui_path;
fullpath = fullfile(temp_dir,folder);
if(exist(fullpath)==0)
	mkdir(fullpath);
end
if(exist(fullpath)~=7)
	%This is not a directory
	error([fullpath 'is not a directory'])
end

return
