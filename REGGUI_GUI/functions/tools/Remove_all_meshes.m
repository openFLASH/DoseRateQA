%% Remove_all_meshes
% Deletes all meshes from the |handles.meshes| structure. 
% 
%% Syntax
% |handles = Remove_all_meshes(handles)|

%% Description
% |handles = Remove_all_meshes(handles)| clears all meshes from the |handles.meshes| structure. 

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all data.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_meshes(handles)
handles.meshes = struct('name',[],'data',[],'info',[]);
handles.meshes.name{1} = 'none';
handles.meshes.data{1} = [];
handles.meshes.info{1} = struct;
