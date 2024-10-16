%% Remove_all_frames
% Deletes all rendering frames from the |handles.rendering_frames| cell vector. 
% 
%% Syntax
% |handles = Remove_all_frames(handles)|

%% Description
% |handles = Remove_all_frames(handles)| clears all rendering frames from the |handles.rendering_frames| cell vector. 

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all data.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_frames(handles)
handles.rendering_frames = cell(0);
