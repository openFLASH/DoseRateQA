%% Remove_all_images
% Deletes all images from the |handles.images| structure. 
% Optionally, remove the parameters controlling the display in GUI
% 
%% Syntax
% |handles = Remove_all_images(handles)|
%
% |handles = Remove_all_images(handles,clear_workspace)|

%% Description
% |handles = Remove_all_images (handles)| clears all images contained inside |handles.images| and keeps the corresponding variables into the workspace.
%
% |handles = Remove_all_images (handles, clear_workspace)| clears all images contained inside |handles| and deletes the corresponding variables from the workspace.

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
% |clear_workspace| - _INTEGER_ - binary value, 1 or 0.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all images.

%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_images(handles,clear_workspace)
Image_remove = 1;
Prop_remove = 1;
if(~handles.auto_mode && nargin<2)
    Choice = questdlg('This operation will clear workspace properties and remove all fields', ...
        'Choose', ...
        'Continue','Cancel','Keep fields and properties','Continue');
    if(strcmp(Choice,'Cancel'))
        Image_remove = 0;
        return
    elseif(strcmp(Choice,'Keep fields and properties'))
        Prop_remove = 0;
    end
end
if(nargin>1)
    Prop_remove = clear_workspace;
end
if(Image_remove)
    handles.images = struct('name',[],'data',[],'info',[]);
    handles.images.name{1} = 'none';
    handles.images.data{1} = [];
    handles.images.info{1} = struct;    
    if(Prop_remove)
        handles = Remove_all_fields(handles);
        handles.size(1) = 0;
        handles.size(2) = 0;
        handles.size(3) = 0;
        handles.spacing = [1;1;1];
        handles.origin = [0;0;0];
        handles.spatialpropsettled = 0;
        handles.view_point = [1;1;1];
    end
end
