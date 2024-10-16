
%% Remove_data
% Deletes appointed data from the |handles.mydata| container. 
%
%% Syntax
% |handles = Remove_data(a, handles)|
%
%% Description
% |handles = Remove_data(a, handles)| allows clearing a dataset from |handles| by specifing its name.
%
%% Input arguments
% |a| - _STRING_ - the data name as specified in the |handles.mydata| container.
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deletion.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_data(a, handles)

% if input is a cell, apply removal recursively
if(iscell(a))
    for i=1:length(a)
        handles = Remove_data(a{i}, handles);
    end
    return
end

index = 0;
try
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},a))
            if(index~=0)
                disp('Warning : multiple data with the same name. Remove the last of them !');
            end
            index = i;
        end
    end
    new_data_name = cell(0);
    new_data_data = cell(0);
    new_data_info = cell(0);
    for i=1:index-1
        new_data_name{i} = handles.mydata.name{i};
        new_data_data{i} = handles.mydata.data{i};
        new_data_info{i} = handles.mydata.info{i};
    end
    for i=index+1:length(handles.mydata.name)
        new_data_name{i-1} = handles.mydata.name{i};
        new_data_data{i-1} = handles.mydata.data{i};
        new_data_info{i-1} = handles.mydata.info{i};
    end
    handles.mydata.name = new_data_name;
    handles.mydata.data = new_data_data;
    handles.mydata.info = new_data_info;
catch
    disp('Error : removal aborted. You have to select a data')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
