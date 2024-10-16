%% Empty_transform
% Create in |handles.images| a data structure containing a rigid transform representing the identity matrix.
%
%% Syntax
% |handles = Empty_transform(f_dest,handles)|
%
%
%% Description
% |handles = Empty_transform(f_dest,handles)| Create a rigid transform equal to identity matrix 
%
%
%% Input arguments
% |f_dest| - _STRING_ - Name of the empty tranform to be created inside |handles.images|
%
% |handles| - _STRUCTURE_ - REGGUI data structure to add the empty transform to
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the newly created empty transform.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Empty_transform(f_dest,handles)
if(handles.size(1) && handles.size(2) && handles.size(3))
    fEmpty = zeros(5,3);
    fEmpty(3:5,:) = eye(3,3);
    myInfo = Create_default_info('rigid_transform',handles);
    f_dest = check_existing_names(f_dest,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = f_dest;
    handles.fields.data{length(handles.fields.data)+1} = fEmpty;
    handles.fields.info{length(handles.fields.info)+1} = myInfo;
else
    disp('Error : you have to load an image first (to set dimensions) !')
end
