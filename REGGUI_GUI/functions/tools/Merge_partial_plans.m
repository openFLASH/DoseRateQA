%% Merge_partial_plans
% Combine the PBS spots from partial plans (each one allocated to the different phases of a 4D-CT scan) into a single treatment plan
%
%% Syntax
% |handles = Merge_partial_plans(handles,myPlanName,planList)|
%
%
%% Description
% |handles = Merge_partial_plans(handles,myPlanName,planList)| Description
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.plan{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer 
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
%
% |myPlanName| - _STRING_ - Name ofthe new treatment plan combining all the parital plans to be added to |handles.plans|
%
% |planList| - _CELL VECTOR of STRING_ - List ofthe name of the parital treatment plans contained in |handles.plans|
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure. There is one new plan in |handles.plans|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Merge_partial_plans(handles,myPlanName,planList)

for i=1:length(handles.plans.name)
    if(strcmp(handles.plans.name{i},planList{1}))
        plan = handles.plans.data{i};
        info = handles.plans.info{i};
    end
end

for n=2:length(planList)
    for i=1:length(handles.plans.name)
        if(strcmp(handles.plans.name{i},planList{1}))
            plan_add = handles.plans.data{i};
        end
    end
    if(not(length(plan)==length(plan_add)))
       disp('Not the same number of fields! Abort.') 
       return
    end
    for f=1:length(plan)
        if(not(length(plan{f}.spots)==length(plan_add{f}.spots)))
            disp('Not the same number of layers! Abort.')
            return
        end
        for layer=1:length(plan{f}.spots)
            plan{f}.spots(layer).xy(end+1:end+size(plan_add{f}.spots(layer).xy,1),:) = plan_add{f}.spots(layer).xy;
            plan{f}.spots(layer).weight(end+1:end+length(plan_add{f}.spots(layer).weight),1) = plan_add{f}.spots(layer).weight;
        end
    end
end

disp('Adding plan to the list...')
myPlanName = check_existing_names(myPlanName,handles.plans.name);
handles.plans.name{length(handles.plans.name)+1} = myPlanName;
handles.plans.data{length(handles.plans.data)+1} = plan;
handles.plans.info{length(handles.plans.info)+1} = info;
