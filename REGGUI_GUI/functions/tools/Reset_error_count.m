%% Reset_error_count
% Reset the error counter in |handles| to zero.
%
%% Syntax
% |handles = Reset_error_count(handles)|
%
%
%% Description
% |handles = Reset_error_count(handles)| Description
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated 
%
% * |handles.error_count| - _INTEGER_ - Number of error encountered during the processing of instructions
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Reset_error_count(handles)
handles.error_count = 0;
disp('Resetting the error counter to 0');

end
