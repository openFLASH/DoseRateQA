%% Remove_image
% Deletes appointed image from the |handles.images| container. 
%
%% Syntax
% |handles = Remove_image(a, handles)|
%
%% Description
% |handles = Remove_image(a, handles)| allows clearing a dataset from |handles.images| by specifing its name.
%
%% Input arguments
% |a| - _STRING_ - the data name as specified in the |handles.images| container.
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deletion.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_image(a, handles)
index = 0;
try
    Image_remove = 1;
    Prop_remove = 0;
    if(length(handles.images.name)==2 && ~handles.auto_mode)
        Prop_remove = 1;
        Choice = questdlg('Only 1 image left. Removing this image will clear workspace properties and remove all fields', ...
            'Choose', ...
            'Continue','Cancel','Keep fields and properties','Keep fields and properties');
        if(strcmp(Choice,'Cancel'))
            Image_remove = 0;
            return
        elseif(strcmp(Choice,'Keep fields and properties'))
            Prop_remove = 0;
        end
    end
    if(Image_remove)
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},a))
                if(index~=0)
                    disp('Warning : multiple images with the same name. Remove the last of them !');
                end
                index = i;
            end
        end
        new_image_name = cell(0);
        new_image_data = cell(0);
        new_image_info = cell(0);
        for i=1:index-1
            new_image_name{i} = handles.images.name{i};
            new_image_data{i} = handles.images.data{i};
            new_image_info{i} = handles.images.info{i};
        end
        for i=index+1:length(handles.images.name)
            new_image_name{i-1} = handles.images.name{i};
            new_image_data{i-1} = handles.images.data{i};
            new_image_info{i-1} = handles.images.info{i};
        end
        handles.images.name = new_image_name;
        handles.images.data = new_image_data;
        handles.images.info = new_image_info;
        if(Prop_remove)
            handles = Remove_all_fields(handles);
            handles.size = [0;0;0];
            handles.spacing = [1;1;1];
            handles.origin = [0;0;0];
            handles.spatialpropsettled = 0;
            handles.view_point = [1;1;1];
        end
    end
catch
    disp('Error : removal aborted. You have to select an image')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
