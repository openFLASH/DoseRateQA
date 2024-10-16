%% Remove_all_fields
% Deletes all deformation field from the |handles.fields| structure. 
% 
%% Syntax
% |handles = Remove_all_fields(handles)|

%% Description
% |handles = Remove_all_fields(handles)| clears all deformation field from the |handles.fields| structure.

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all data.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_fields(handles)
handles.fields = struct('name',[],'data',[],'info',[]);
handles.fields.name{1} = 'none';
handles.fields.data{1} = [];
handles.fields.info{1} = struct;
