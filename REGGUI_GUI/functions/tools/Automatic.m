%% Automatic
% Turn on and off the auto mode in REGGUI. When the auto mode is active, no dialog boxes requiring user interaction are displayed. The processing is done automatically, without user interaction.
%
%% Syntax
% |handles = Automatic(handles)|
%
% |handles = Automatic(handles,on_off)|
%
%
%% Description
% |handles = Automatic(handles)| Turn ON the auto mode.
%
% |handles = Automatic(handles,on_off)| Define new settings for the auto-mode
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The definition of the auto mode will be added / modified in this structure
%
% |on_off| - _INTEGER_ - 0 = auto mode is not active. Dialog boxes can be displayed. 1 = auto mode is active. No dialog boxes are displayed.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.auto_mode| - _INTEGER_ - 0 = auto mode is not active. 1 = auto mode is active
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Automatic(handles,on_off)

if(nargin<2)
    handles.auto_mode = 1;
else
    handles.auto_mode = on_off;
end
