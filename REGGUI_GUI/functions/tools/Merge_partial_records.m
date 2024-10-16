%% Merge_partial_records
% Combine the PBS spots from partial records into a single treatment record
%
%% Syntax
% |handles = Merge_partial_records(handles,outputName,inputList)|
%
%
%% Description
% |handles = Merge_partial_records(handles,outputName,inputList)| Description
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.plan{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
%
% |outputName| - _STRING_ - Name ofthe new treatment record combining all the parital records to be added to |handles.plans|
%
% |inputList| - _CELL VECTOR of STRING_ - List of names of partial treatment records contained in |handles.plans|
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure. There is one new plan in |handles.plans|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Merge_partial_records(handles,outputName,inputList,aggregate_paintings)

if(nargin<4)
    aggregate_paintings = 0;
end

[plan, info] = Get_reggui_data(handles,inputList{1},'plans');
if isfield(info,'OriginalHeader')
    [update_header, beamFieldNames] = check_plan_header_consistency(plan, info.OriginalHeader);
else
    update_header = 0;
end

for n=2:length(inputList)
    [plan_new, info_new] = Get_reggui_data(handles,inputList{n},'plans');
    if isfield(info_new,'OriginalHeader')
        [new_update_header, newBeamFieldNames] = check_plan_header_consistency(plan_new, info_new.OriginalHeader);
        update_header = update_header && new_update_header;
    else
        update_header = 0;
    end
    % Merge beam data
    for f_new=1:length(plan_new)
        for f=1:length(plan)
            if(strcmp(plan{f}.name,plan_new{f_new}.name)) % add layers to existing beam
                for layer=1:length(plan_new{f_new}.spots)
                    plan{f}.spots(end+1) = plan_new{f_new}.spots(layer);
                    if(update_header)
                        newLayerFieldName = ['Item_',num2str(length(plan{f}.spots))];
                        info.OriginalHeader.TreatmentSessionIonBeamSequence.(beamFieldNames{f}).IonControlPointDeliverySequence.(newLayerFieldName) = info_new.OriginalHeader.TreatmentSessionIonBeamSequence.(newBeamFieldNames{f}).IonControlPointDeliverySequence.(['Item_',num2str(layer)]);
                    end
                end
                if(update_header)
                    info.OriginalHeader.TreatmentSessionIonBeamSequence.(beamFieldNames{f}).NumberOfControlPoints = length(plan{f}.spots);
                end
            else % add new beam
                plan{end+1} = plan_new{f_new};
                if(update_header)
                    newBeamFieldName = ['Item_',num2str(length(plan))];
                    info.OriginalHeader.TreatmentSessionIonBeamSequence.(newBeamFieldName) = info_new.OriginalHeader.TreatmentSessionIonBeamSequence.(['Item_',num2str(f_new)]);
                end
            end
        end
    end    
end

% Check consistency of meta data
if(update_header)
    header_is_consistent = check_plan_header_consistency(plan, info.OriginalHeader);
    if(not(header_is_consistent))
        warning('The header of merged record is not consistent with the data.')
    end
end

% Aggregate paintings if required
if(aggregate_paintings)
    plan = aggregate_PBS_paintings(plan);
end

disp('Adding plan to the list...')
handles = Set_reggui_data(handles,outputName,plan,info,'plans');
