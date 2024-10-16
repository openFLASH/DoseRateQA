%% Remove_all_plans
% Deletes all treatment plans from the |handles.plans| structure. 
% 
%% Syntax
% |handles = Remove_all_plans(handles)|

%% Description
% |handles = Remove_all_plans(handles)| clears all treatment plans from the |handles.plans| structure. 

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all data.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_plans(handles)
handles.plans = struct('name',[],'data',[],'info',[]);
handles.plans.name{1} = 'none';
handles.plans.data{1} = [];
handles.plans.info{1} = struct;
