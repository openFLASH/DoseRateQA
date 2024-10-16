%% Initialize_reggui_workflow
% Reset the REGGUI workspace: turn on the automatic mode, reset error count, delete all ROI, images, data, plan, frames and DVH from the workspace
%
%% Syntax
% |handles = Initialize_reggui_workflow(handles)|
%
%
%% Description
% |handles = Initialize_reggui_workflow(handles)| Reset the REGGUI workspace
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Initialize_reggui_workflow(handles)

handles = Automatic(handles);
handles = Reset_error_count(handles);
handles = On_region_of_interest(handles,0);
handles = Remove_all_images(handles);
handles = Remove_all_data(handles);
handles = Remove_all_plans(handles);
handles = Remove_all_frames(handles);
handles = Remove_all_dvhs(handles);

handles.time = clock;
