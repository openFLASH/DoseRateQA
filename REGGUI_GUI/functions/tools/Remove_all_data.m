%% Remove_all_data
% Deletes all data from the |handles.mydata| structure. 
% 
%% Syntax
% |handles = Remove_all_data(handles)|

%% Description
% |handles = Remove_all_data(handles)| clears all data contained inside |handles.mydata|.

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all data.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_data(handles)
handles.mydata = struct('name',[],'data',[],'info',[]);
handles.mydata.name{1} = 'none';
handles.mydata.data{1} = [];
handles.mydata.info{1} = struct;
