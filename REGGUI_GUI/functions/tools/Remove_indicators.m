%% Remove_indicators
% Deletes appointed treatment indicators from the |handles.indicators| container. 
%
%% Syntax
% |handles = Remove_indicators(a, handles)|
%
%% Description
% |handles = Remove_indicators(a, handles)| allows clearing a dataset from |handles.indicators| by specifing its name.
%
%% Input arguments
% |a| - _STRING_ - the data name as specified in the |handles.indicators| container.
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deletion.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_indicators(a, handles)
index = 0;
try
    for i=1:length(handles.indicators.name)
        if(strcmp(handles.indicators.name{i},a))
            if(index~=0)
                disp('Warning : multiple indicators with the same name. Remove the last of them !');
            end
            index = i;
        end
    end
    new_indicators_name = cell(0);
    new_indicators_data = cell(0);
    new_indicators_info = cell(0);
    for i=1:index-1
        new_indicators_name{i} = handles.indicators.name{i};
        new_indicators_data{i} = handles.indicators.data{i};
        new_indicators_info{i} = handles.indicators.info{i};
    end
    for i=index+1:length(handles.indicators.name)
        new_indicators_name{i-1} = handles.indicators.name{i};
        new_indicators_data{i-1} = handles.indicators.data{i};
        new_indicators_info{i-1} = handles.indicators.info{i};
    end
    handles.indicators.name = new_indicators_name;
    handles.indicators.data = new_indicators_data;
    handles.indicators.info = new_indicators_info;
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
