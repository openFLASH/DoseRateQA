%% Remove_all_dvhs
% Deletes all dose volume historgram from the |handles.dvhs| cell vector. 
% 
%% Syntax
% |handles = Remove_all_dvhs(handles)|

%% Description
% |handles = Remove_all_dvhs(handles)| clears all dose volume historgram from the |handles.dvhs| cell vector.

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all data.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_dvhs(handles)
handles.dvhs = cell(0);
