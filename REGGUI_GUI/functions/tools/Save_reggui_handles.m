%% Save_reggui_handles
% Save the REGGUI workspace (contained in |handles|) into a file on disk
%
%% Syntax
% |Save_reggui_handles(handles,myProject_Name)|
%
%
%% Description
% |Save_reggui_handles(handles,myProject_Name)| Save the workspace
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be saved.
%
% |myProject_Name| - _STRING_ -  Name (including path) of the file where the workspace is to be saved
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Save_reggui_handles(handles,myProject_Name)

% remove ui and graphics objects (starting from Matlab 2014b)
names = fieldnames(handles);
myProject = struct;
myProject.handles = struct;
for i=1:length(names)
    field_class = class(getfield(handles,names{i}));
    if(isempty(strfind(field_class,'matlab.ui')) && isempty(strfind(field_class,'matlab.graphics')) && not(strcmp(names{i},'instructions_handles')))
        myProject.handles = setfield(myProject.handles,names{i},getfield(handles,names{i}));
    end
end

% check the size of the project and save
s = whos('handles');
bytes = s.bytes;
if(bytes<2e9)
    try
        save(myProject_Name,'myProject');
    catch
        cd(handles.path);
        disp('Failed to save project')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
else
    try
        save(myProject_Name,'myProject','-V7.3');
    catch
        cd(handles.path);
        disp('Failed to save project')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
end
