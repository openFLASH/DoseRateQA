%% Verify_Plan_PBS
% This function remove low MU spots from a PBS plan.

%
%% Syntax
% |handles = Verify_Plan_PBS(handles, plan_name)|
%
%
%% Description
% |handles = Verify_Plan_PBS(handles, plan_name)| Remove low MU spots from a PBS plan.
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.plans.names{i}| - _CELL VECTOR of STRING_ - Name of the ith treatment plan
% * |handles.plans.data{i}{f}.spots(j).weight(s)| - _STRUCTURE_ Weight of post s in layer j in beam/field f for the ith treatment plan
%
% |plan_name| - _STRING_ - Name of the plan in |handles.plans| to be verified
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated
%
% * |handles.plans.data{i}{f}.spots(j).weight(s)| - _STRUCTURE_ Weight of post s in layer j in beam/field f for the ith treatment plan
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Verify_Plan_PBS(handles, plan_name)


MU_threshold = 0.02;

index = 0;
for i=1:length(handles.plans.name)
    if(strcmp(handles.plans.name{i},plan_name))
        index = i;
    end
end

if(index == 0)
    disp('Error: plan not found!');
end

plan = handles.plans.data{index};
nb_fields = length(plan);

for f=1:nb_fields
    nb_layers = length(plan{f}.spots);
    for j=1:nb_layers
        nb_spots = length(plan{f}.spots(j).weight);
        for s = 1:nb_spots
            
% Not working: ScanAlgo complains about 0 MU spots.
%             if(plan{f}.spots(j).weight(s) < 0.01)
%                 plan{f}.spots(j).weight(s) = 0;
%             elseif(plan{f}.spots(j).weight(s) < 0.02)
%                 plan{f}.spots(j).weight(s) = 0.02;
%             end

            if(plan{f}.spots(j).weight(s) < 0.02)
                plan{f}.spots(j).weight(s) = 0.02001;
            end
            
        end
    end
end

handles.plans.data{index} = plan;

end

