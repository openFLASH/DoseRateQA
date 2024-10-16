function [is_consistent, beamFieldNames] = check_plan_header_consistency(plan,info)

nb_fields = length(plan);

if(not(isfield(info,'Modality')))
    is_consistent = 0;
    beamFieldNames = {};
    return
end

switch info.Modality    
    case 'RTPLAN'
        beamSeq = 'IonBeamSequence';      
        layerSeq = 'IonControlPointSequence';
    case 'RTRECORD'
        beamSeq = 'TreatmentSessionIonBeamSequence';   
        layerSeq = 'IonControlPointDeliverySequence';
end
        
% Get dicom plan structure
original_nb_fields = 0;
if(isfield(info,beamSeq))
    beamFieldNames = fieldnames(info.(beamSeq));
    for s=1:length(beamFieldNames)
        if(isfield(info.(beamSeq).(beamFieldNames{s}),'TreatmentDeliveryType'))
            if(strcmp(info.(beamSeq).(beamFieldNames{s}).TreatmentDeliveryType,'TREATMENT') || strcmp(info.(beamSeq).(beamFieldNames{s}).TreatmentDeliveryType,'CONTINUATION'))
                original_nb_fields = original_nb_fields+1;
            end
        end
    end
else
    beamFieldNames = {};
end

% Check if beam sequence is similar to the original
is_consistent = nb_fields==original_nb_fields;
for i=1:nb_fields
    layerFieldNames = fieldnames(info.(beamSeq).(beamFieldNames{i}).(layerSeq));
    switch info.Modality
        case 'RTPLAN'
            nb_layers = length(layerFieldNames)/2;
        case 'RTRECORD'
            nb_layers = length(layerFieldNames);
    end    
    if(nb_layers>=1 && i<=length(plan))
        if(not(nb_layers==length(plan{i}.spots)))
            is_consistent = 0;
            break
        end
    end
end
        