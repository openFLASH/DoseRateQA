%% Remove_plan
% Deletes appointed treatment plan from the |handles.plans| container. 
%
%% Syntax
% |handles = Remove_plan(a, handles)|
%
%% Description
% |handles = Remove_plan(a, handles)| allows clearing a dataset from |handles.plans| by specifing its name.
%
%% Input arguments
% |a| - _STRING_ - the data name as specified in the |handles.plans| container.
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure.
%
%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deletion.
%
%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_plan(a, handles)
index = 0;
try
    for i=1:length(handles.plans.name)
        if(strcmp(handles.plans.name{i},a))
            if(index~=0)
                disp('Warning : multiple plans with the same name. Remove the last of them !');
            end
            index = i;
        end
    end
    new_plan_name = cell(0);
    new_plan_data = cell(0);
    new_plan_info = cell(0);
    for i=1:index-1
        new_plan_name{i} = handles.plans.name{i};
        new_plan_data{i} = handles.plans.data{i};
        new_plan_info{i} = handles.plans.info{i};
    end
    for i=index+1:length(handles.plans.name)
        new_plan_name{i-1} = handles.plans.name{i};
        new_plan_data{i-1} = handles.plans.data{i};
        new_plan_info{i-1} = handles.plans.info{i};
    end
    handles.plans.name = new_plan_name;
    handles.plans.data = new_plan_data;
    handles.plans.info = new_plan_info;
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
