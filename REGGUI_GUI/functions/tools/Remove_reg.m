%% Remove_reg
% Deletes appointed rigid registration data from the |handles.registrations| container. 
%
%% Syntax
% |handles = Remove_reg(a, handles)|
%
%% Description
% |handles = Remove_reg(a, handles)| allows clearing a dataset from |handles.registrations| by specifing its name.
%
%% Input arguments
% |a| - _STRING_ - the data name as specified in the |handles.registrations| container.
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deletion.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_reg(a, handles)
index = 0;
try
    for i=1:length(handles.registrations.name)
        if(strcmp(handles.registrations.name{i},a))
            if(index~=0)
                disp('Warning : multiple registrations with the same name. Remove the last of them !');
            end
            index = i;
        end
    end
    new_reg_name = cell(0);
    new_reg_data = cell(0);
    for i=1:index-1
        new_reg_name{i} = handles.registrations.name{i};
        new_reg_data{i} = handles.registrations.data{i};
    end
    for i=index+1:length(handles.registrations.name)
        new_reg_name{i-1} = handles.registrations.name{i};
        new_reg_data{i-1} = handles.registrations.data{i};
    end
    handles.registrations.name = new_reg_name;
    handles.registrations.data = new_reg_data;
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
