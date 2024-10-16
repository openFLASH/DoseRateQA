%% Remove_field
% Deletes appointed deformation field from the |handles.fields| container. 
%
%% Syntax
% |handles = Remove_field(a, handles)|
%
%% Description
% |handles = Remove_field(a, handles)| allows clearing a dataset from |handles.fields| by specifing its name.
%
%% Input arguments
% |a| - _STRING_ - the data name as specified in the |handles.fields| container.
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deletion.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_field(a, handles)
index = 0;
try
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},a))
            if(index~=0)
                disp('Warning : multiple fields with the same name. Remove the last of them !');
            end
            index = i;
        end
    end
    new_field_name = cell(0);
    new_field_data = cell(0);
    new_field_info = cell(0);
    for i=1:index-1
        new_field_name{i} = handles.fields.name{i};
        new_field_data{i} = handles.fields.data{i};
        new_field_info{i} = handles.fields.info{i};
    end
    for i=index+1:length(handles.fields.name)
        new_field_name{i-1} = handles.fields.name{i};
        new_field_data{i-1} = handles.fields.data{i};
        new_field_info{i-1} = handles.fields.info{i};
    end
    handles.fields.name = new_field_name;
    handles.fields.data = new_field_data;
    handles.fields.info = new_field_info;
catch
    disp('Error : removal aborted. You have to select a field')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
