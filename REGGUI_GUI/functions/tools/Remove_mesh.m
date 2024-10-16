%% Remove_mesh
% Deletes appointed mesh from the |handles.meshes| container. 
%
%% Syntax
% |handles = Remove_mesh(a, handles)|
%
%% Description
% |handles = Remove_mesh(a, handles)| allows clearing a dataset from |handles.meshes| by specifing its name.
%
%% Input arguments
% |a| - _STRING_ - the data name as specified in the |handles.meshes| container.
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deletion.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_mesh(a, handles)
index = 0;
try
    for i=1:length(handles.meshes.name)
        if(strcmp(handles.meshes.name{i},a))
            if(index~=0)
                disp('Warning : multiple meshes with the same name. Remove the last of them !');
            end
            index = i;
        end
    end
    new_mesh_name = cell(0);
    new_mesh_data = cell(0);
    new_mesh_info = cell(0);
    for i=1:index-1
        new_mesh_name{i} = handles.meshes.name{i};
        new_mesh_data{i} = handles.meshes.data{i};
        new_mesh_info{i} = handles.meshes.info{i};
    end
    for i=index+1:length(handles.meshes.name)
        new_mesh_name{i-1} = handles.meshes.name{i};
        new_mesh_data{i-1} = handles.meshes.data{i};
        new_mesh_info{i-1} = handles.meshes.info{i};
    end
    handles.meshes.name = new_mesh_name;
    handles.meshes.data = new_mesh_data;
    handles.meshes.info = new_mesh_info;
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
