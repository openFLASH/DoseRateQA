%% load_DICOM_RT_Plan
% Load a treatment plan from a file at the DICOM format
%
%% Syntax
% |[myBeamData,myInfo] = load_DICOM_RT_Plan(dicom_filename)|
%
%
%% Description
% |[myBeamData,myInfo] = load_DICOM_RT_Plan(dicom_filename)| Load a treatment plan from a file
%
%
%% Input arguments
% |dicom_filename| - _STRING_ - File name (including path) of the data to be loaded
%
% |verbose| -_BOOL_- [OPTIONAL. Default = true] If false, silently load the file without displaying text
%
%% Output arguments
%
% |myBeamData| - _CELL VECTOR of STRUCTURE_ -  |myBeamData{i}| Description of the the geometry of the i-th proton beam
%
% * |beam{i}.gantry_angle| - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
% * |beam{i}.table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
% * |beam{i}.isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
% * |beam{i}.final_weight| - _SCALAR_ -Final Cumulative Meter set Weight
% * |beam{i}.BeamMeterset| - _SCALAR_ - Beam Meter set
% * |beam{i}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).nb_paintings| - _INTEGER_ - Number of painting for the j-th energy layer
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file.
%
% * |myInfo.Type| - _STRING_ - Type of treatment plan: 'pbs_plan' or 'passive_scattering_plan' or 'photon_plan'
% * |myInfo.PatientID|
% * |myInfo.FrameOfReferenceUID| - _STRING_ - UID of the frame of reference (DICOM tag [0020,0052]). If the tag is absent from the plan (e.g. because the plan was anonymised, then the string will be 'UNKNOWN.UNKNOWN'
% * |myInfo.SOPInstanceUID|
% * |myInfo.SeriesInstanceUID|
% * |myInfo.SOPClassUID|
% * |myInfo.StudyInstanceUID|
% * |myInfo.OriginalHeader|
%
%
%% Contributors
% Authors : G.Janssens, K. Souris, R. Labarbe, L. Hotoiu (open.reggui@gmail.com)

function [myBeamData,myInfo , info] = load_DICOM_RT_Plan(dicom_filename , verbose)

if nargin < 2
  verbose = true; %VErbose is the default
end

myBeamData = struct;

Current_dir = pwd;

[myDir,myPlan] = fileparts(dicom_filename);

info = struct;
try
    info = dicominfo(fullfile(myDir,myPlan));
    myBeamData = [];
    myInfo = struct;
catch ME
    disp('Failed to read file as dicom... ');
    rethrow(ME);
end

ion_plan = 0;
if(isfield(info,'IonBeamSequence'))
    ion_plan = 1;
else
    disp(['Loading dicom RT plan (',dicom_filename,')']);
end

correct_orientation = 'HFS';
if(isfield(info,'PatientPosition') && isfield(info,'RTPlanGeometry'))
    if(strcmp(info.RTPlanGeometry,'PATIENT'))
        correct_orientation = info.PatientPosition;
    end
elseif(isfield(info,'PatientSetupSequence'))
    correct_orientation = 'TBD_per_beam';
end

if(ion_plan)

    pbs_plan = 0;
    if(isfield(info,'TreatmentProtocols'))
        if(contains(lower(info.TreatmentProtocols),'scanning'))
            pbs_plan = 1;
        end
    end
    try
        beamFieldNames = fieldnames(info.IonBeamSequence);
        nb_fields = length(beamFieldNames);
        for i=1:nb_fields
            if(isfield(info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.Item_1,'ScanSpotPositionMap'))
                pbs_plan = 1;
            end
        end
    catch
    end
    
    if(pbs_plan)

        if verbose
          disp(['Loading PBS dicom RT ion plan (',dicom_filename,')']);
        end
        myInfo.Type = 'pbs_plan';
        
        beamFieldNames = fieldnames(info.IonBeamSequence);	%Field names for the treatment beams.
        nb_fields = length(beamFieldNames);
        ReferencedBeamFieldNames = fieldnames(info.FractionGroupSequence.Item_1.ReferencedBeamSequence);
        
        n = 0;
        
        for f=1:nb_fields
            realFractionationNo(f)=info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(ReferencedBeamFieldNames{f}).ReferencedBeamNumber;
        end
        
        for i=1:nb_fields
            
            if(strcmp(info.IonBeamSequence.(beamFieldNames{i}).TreatmentDeliveryType,'TREATMENT'))
                n = n+1;
            else
                continue
            end
            
            beamSequence = info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence;
            FractionSequenceBeamID = find(realFractionationNo==info.IonBeamSequence.(beamFieldNames{i}).BeamNumber); % The beam order may be different in IonBeamSequence and FractionGroupSequence
            ReferencedBeamSequence = info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(ReferencedBeamFieldNames{FractionSequenceBeamID});
            layerFieldNames = fieldnames(info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence);
            nb_layers = length(layerFieldNames)/2;
            
            myBeamData{n}.name = info.IonBeamSequence.(beamFieldNames{i}).BeamName;
            myBeamData{n}.isocenter = beamSequence.(layerFieldNames{1}).IsocenterPosition;
            if(strcmp(correct_orientation,'TBD_per_beam'))
                current_orientation = 'HFS';
                try
                    setup_id = info.IonBeamSequence.(beamFieldNames{i}).ReferencedPatientSetupNumber;
                    setup_list = fieldnames(info.PatientSetupSequence);
                    for setup=1:length(setup_list)
                        if(info.PatientSetupSequence.(setup_list{setup}).PatientSetupNumber==setup_id)
                            current_orientation = info.PatientSetupSequence.(setup_list{setup}).PatientPosition;
                        end
                    end
                catch
                    disp('Could not find patient setup sequence. Assume HFS.');
                end
            else
                current_orientation = correct_orientation;
            end
            [myBeamData{n}.gantry_angle,myBeamData{n}.table_angle] = correct_beam_angles_for_orientation(beamSequence.(layerFieldNames{1}).GantryAngle,beamSequence.(layerFieldNames{1}).PatientSupportAngle,current_orientation);
            myBeamData{n}.final_weight = info.IonBeamSequence.(beamFieldNames{i}).FinalCumulativeMetersetWeight;
            myBeamData{n}.BeamMeterset = ReferencedBeamSequence.BeamMeterset;
            
            if(isfield(info.IonBeamSequence.(beamFieldNames{i}),'RadiationType'))
                myBeamData{n}.radiation_type = info.IonBeamSequence.(beamFieldNames{i}).RadiationType;
            else
                myBeamData{n}.radiation_type = 'PROTON';
            end
            
            if(strcmp(myBeamData{n}.radiation_type,'ION'))
                myBeamData{n}.ion_AZQ = [info.IonBeamSequence.(beamFieldNames{i}).RadiationAtomicNumber,info.IonBeamSequence.(beamFieldNames{i}).RadiationMassNumber,info.IonBeamSequence.(beamFieldNames{i}).RadiationChargeState];
            end
            
            if(info.IonBeamSequence.(beamFieldNames{i}).NumberOfRangeShifters == 0)
                myBeamData{n}.NumberOfRangeShifters = 0;
                myBeamData{n}.RangeShifters = [];
            else

                myBeamData{n}.NumberOfRangeShifters = info.IonBeamSequence.(beamFieldNames{i}).NumberOfRangeShifters;
                
                RS_Name = fieldnames(info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence);
                
                if(numel(RS_Name) ~= myBeamData{n}.NumberOfRangeShifters)

                    error(['ERROR: Number of range shifters does not match'])
                end
                
                for r=1:numel(RS_Name)
                    myBeamData{n}.RangeShifters(r).RangeShifterNumber = info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(RS_Name{r}).RangeShifterNumber;
                    myBeamData{n}.RangeShifters(r).RangeShifterID = info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(RS_Name{r}).RangeShifterID;
                    myBeamData{n}.RangeShifters(r).RangeShifterType = info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(RS_Name{r}).RangeShifterType;

                    if isfield(info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(RS_Name{r}) , 'AccessoryCode')
                      myBeamData{n}.RangeShifters(r).AccessoryCode = info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(RS_Name{r}).AccessoryCode;
                    end

                    % Binary type: Device is composed of different thickness materials that can be moved in or out of the beam in various stepped combinations
                    if(strcmpi(myBeamData{n}.RangeShifters(r).RangeShifterType, 'BINARY') == 0)
                        error(['ERROR: Range shifter ' myBeamData{n}.RangeShifters(r).RangeShifterID ' of type ' myBeamData{n}.RangeShifters(r).RangeShifterType ' is not supported'])
                    end
                end
            end
            
            
            SnoutPosition = 0;
            if(isfield(beamSequence.(layerFieldNames{1}),'SnoutPosition'))
                SnoutPosition = beamSequence.(layerFieldNames{1}).SnoutPosition;   
                myBeamData{n}.snout_position = SnoutPosition;
            end
            
            IsocenterToRangeShifterDistance = SnoutPosition;
            RangeShifterWaterEquivalentThickness = 0;
            RangeShifterSetting = 'OUT';
            ReferencedRangeShifterNumber = 0;
            
            if(isfield(beamSequence.(layerFieldNames{1}), 'RangeShifterSettingsSequence'))
                if(isfield(beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1,'IsocenterToRangeShifterDistance'))
                    IsocenterToRangeShifterDistance = beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1.IsocenterToRangeShifterDistance;
                end
                if(isfield(beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1,'RangeShifterWaterEquivalentThickness'))
                    RangeShifterWaterEquivalentThickness = beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1.RangeShifterWaterEquivalentThickness;
                end
                if(isfield(beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1,'RangeShifterSetting'))
                    RangeShifterSetting = beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1.RangeShifterSetting;
                end
                if(isfield(beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1,'ReferencedRangeShifterNumber'))
                    ReferencedRangeShifterNumber = beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1.ReferencedRangeShifterNumber;
                end
            end
            
            
            % fill redundant data in layer sequence and detect arc plan
            arc = 0;
            for j=2:length(layerFieldNames)
                if(not(isfield(beamSequence.(layerFieldNames{j}),'GantryAngle')))
                    beamSequence.(layerFieldNames{j}).GantryAngle = beamSequence.(layerFieldNames{j-1}).GantryAngle;
                elseif(isempty(beamSequence.(layerFieldNames{j}).GantryAngle))
                    beamSequence.(layerFieldNames{j}).GantryAngle = beamSequence.(layerFieldNames{j-1}).GantryAngle;
                end
                if(not(isfield(beamSequence.(layerFieldNames{j}),'PatientSupportAngle')))
                    beamSequence.(layerFieldNames{j}).PatientSupportAngle = beamSequence.(layerFieldNames{j-1}).PatientSupportAngle;
                elseif(isempty(beamSequence.(layerFieldNames{j}).GantryAngle))
                    beamSequence.(layerFieldNames{j}).PatientSupportAngle = beamSequence.(layerFieldNames{j-1}).PatientSupportAngle;
                end
                if(beamSequence.(layerFieldNames{j-1}).GantryAngle ~= beamSequence.(layerFieldNames{j}).GantryAngle)
                    arc = 1;
                end
            end
            
            % parse layer sequence
            for j=1:nb_layers
                
                fprintf('%s, Layer %d (%g MeV)\n',info.IonBeamSequence.(beamFieldNames{i}).BeamName,j,beamSequence.(layerFieldNames{2*j-1}).NominalBeamEnergy);
                
                %Check spot data
                if(not(isfield(beamSequence.(layerFieldNames{2*j}),'ScanSpotMetersetWeights')))
                    fprintf('ScanSpotMetersetWeights not found. \n')
                    break
                end
                if any(beamSequence.(layerFieldNames{2*j}).ScanSpotMetersetWeights~=0)
                    fprintf('Non-zero ScanSpotMetersetWeights found in info.IonBeamSequence.%s.IonControlPointSequence.%s!\n',beamFieldNames{1},layerFieldNames{2*j});
                end
                if(not(isfield(beamSequence.(layerFieldNames{2*j}),'NumberOfScanSpotPositions')) || not(isfield(beamSequence.(layerFieldNames{2*j-1}),'NumberOfScanSpotPositions')))
                    beamSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions = length(beamSequence.(layerFieldNames{2*j}).ScanSpotMetersetWeights);
                    beamSequence.(layerFieldNames{2*j}).NumberOfScanSpotPositions = length(beamSequence.(layerFieldNames{2*j}).ScanSpotMetersetWeights);
                end
                if beamSequence.(layerFieldNames{2*j}).NumberOfScanSpotPositions~=beamSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions
                    fprintf('info.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions does not match info.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions!\n',...
                        beamFieldNames{1},layerFieldNames{2*j},beamFieldNames{1},layerFieldNames{2*j-1});
                end
                if any(beamSequence.(layerFieldNames{2*j}).ScanSpotPositionMap~=beamSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap)
                    fprintf('info.IonBeamSequence.%s.IonControlPointSequence.%s.ScanSpotPositionMap does not match info.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions!\n',...
                        beamFieldNames{1},layerFieldNames{2*j},beamFieldNames{1},layerFieldNames{2*j-1});
                end       
                if(isfield(beamSequence.(layerFieldNames{2*j-1}),'ScanningSpotSize'))
                    myBeamData{n}.spots(j).spot_size = beamSequence.(layerFieldNames{2*j-1}).ScanningSpotSize;
                end
                if(isfield(beamSequence.(layerFieldNames{2*j-1}),'ScanSpotTuneID'))
                    myBeamData{n}.spots(j).spot_tune_id = beamSequence.(layerFieldNames{2*j-1}).ScanSpotTuneID;
                end
                if(isfield(beamSequence.(layerFieldNames{2*j-1}),'NumberOfPaintings'))
                    myBeamData{n}.spots(j).nb_paintings = beamSequence.(layerFieldNames{2*j-1}).NumberOfPaintings;
                end
                
                myBeamData{n}.spots(j).energy = beamSequence.(layerFieldNames{2*j-1}).NominalBeamEnergy;
                myBeamData{n}.spots(j).xy = [reshape(beamSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap,2,beamSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions).'];
                if(myBeamData{n}.final_weight == 0)
                    myBeamData{n}.spots(j).weight = [beamSequence.(layerFieldNames{2*j-1}).ScanSpotMetersetWeights] * 0;
                else
                    myBeamData{n}.spots(j).weight = [beamSequence.(layerFieldNames{2*j-1}).ScanSpotMetersetWeights] * myBeamData{n}.BeamMeterset / myBeamData{n}.final_weight;
                end

                if(arc)
                    myBeamData{n}.spots(j).gantry_angle = [correct_beam_angles_for_orientation(beamSequence.(layerFieldNames{2*j-1}).GantryAngle,beamSequence.(layerFieldNames{2*j-1}).PatientSupportAngle,current_orientation);...
                        correct_beam_angles_for_orientation(beamSequence.(layerFieldNames{2*j}).GantryAngle,beamSequence.(layerFieldNames{2*j}).PatientSupportAngle,current_orientation)];
                end

                
                if(myBeamData{n}.NumberOfRangeShifters > 0)
                    

                    if(isfield(beamSequence.(layerFieldNames{2*j-1}), 'RangeShifterSettingsSequence'))
                        RangeShifterSetting = beamSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item_1.RangeShifterSetting;
                        ReferencedRangeShifterNumber = beamSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item_1.ReferencedRangeShifterNumber;
                        if(isfield(beamSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence, 'IsocenterToRangeShifterDistance'))
                            IsocenterToRangeShifterDistance = beamSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item_1.IsocenterToRangeShifterDistance;
                        end
                        if(isfield(beamSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence, 'RangeShifterWaterEquivalentThickness'))
                            RangeShifterWaterEquivalentThickness = beamSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item_1.RangeShifterWaterEquivalentThickness;
                        end
                    end
                    
                    myBeamData{n}.spots(j).RangeShifterSetting = RangeShifterSetting;
                    myBeamData{n}.spots(j).IsocenterToRangeShifterDistance = IsocenterToRangeShifterDistance;
                    myBeamData{n}.spots(j).RangeShifterWaterEquivalentThickness = RangeShifterWaterEquivalentThickness;
                    myBeamData{n}.spots(j).ReferencedRangeShifterNumber = ReferencedRangeShifterNumber;
                    
                end
                
            end	%for j=1:nb_layers
            
        end %for i=1:nb_fields
        
    else % passive scattering plan
        
        disp(['Loading Passive Scattering dicom RT plan (',dicom_filename,')']);
        myInfo.Type = 'passive_scattering_plan';
        
        beamFieldNames = fieldnames(info.IonBeamSequence);	%Field names for the treatment beams.
        nb_fields = length(beamFieldNames);
        n = 0;
        
        for i=1:nb_fields
            
            if(strcmp(info.IonBeamSequence.(beamFieldNames{i}).TreatmentDeliveryType,'TREATMENT'))
                n = n+1;
            else
                continue
            end
            
            beamSequence = info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence;
            layerFieldNames = fieldnames(info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence);
            
            myBeamData{n}.name = info.IonBeamSequence.(beamFieldNames{i}).BeamName;
            myBeamData{n}.isocenter = beamSequence.(layerFieldNames{1}).IsocenterPosition;
            myBeamData{n}.gantry_angle = beamSequence.(layerFieldNames{1}).GantryAngle;
            myBeamData{n}.table_angle = beamSequence.(layerFieldNames{1}).PatientSupportAngle;
            myBeamData{n}.final_weight = info.IonBeamSequence.(beamFieldNames{i}).FinalCumulativeMetersetWeight;
            
            if(isfield(info.IonBeamSequence.(beamFieldNames{i}),'RadiationType'))
                myBeamData{n}.radiation_type = info.IonBeamSequence.(beamFieldNames{i}).RadiationType;
            else
                myBeamData{n}.radiation_type = 'PROTON';
            end
            
            if(strcmp(myBeamData{n}.radiation_type,'ION'))
                myBeamData{n}.ion_AZQ = [info.IonBeamSequence.(beamFieldNames{i}).RadiationAtomicNumber,info.IonBeamSequence.(beamFieldNames{i}).RadiationMassNumber,info.IonBeamSequence.(beamFieldNames{i}).RadiationChargeState];
            end
            
        end %for i=1:nb_fields
        
    end
    
else % photon plan
    
    myInfo.Type = 'photon_plan';
    
    beamFieldNames = fieldnames(info.BeamSequence);	%Field names for the treatment beams.
    nb_fields = length(beamFieldNames);
    n = 0;
    for i=1:nb_fields
        if(strcmp(info.BeamSequence.(beamFieldNames{i}).TreatmentDeliveryType,'TREATMENT'))
            n = n+1;
        else
            continue
        end
        
        beamSequence = info.BeamSequence.(beamFieldNames{i}).ControlPointSequence;
        layerFieldNames = fieldnames(info.BeamSequence.(beamFieldNames{i}).ControlPointSequence);
        
        myBeamData{n}.name = info.BeamSequence.(beamFieldNames{i}).BeamName;
        myBeamData{n}.isocenter = beamSequence.(layerFieldNames{1}).IsocenterPosition;
        myBeamData{n}.gantry_angle = [];
        myBeamData{n}.table_angle = [];
        myBeamData{n}.final_weight = info.BeamSequence.(beamFieldNames{i}).FinalCumulativeMetersetWeight;
        myBeamData{n}.radiation_type = 'PHOTON';
        
    end
end

myInfo.PatientID = info.PatientID;
if(isfield(info,'FrameOfReferenceUID'))
    myInfo.FrameOfReferenceUID = info.FrameOfReferenceUID;
else
    myInfo.FrameOfReferenceUID = 'UNKNOWN.UNKNOWN'; % The 'FrameOfReferenceUID' has been removed during the anonymisation process
end
myInfo.SOPInstanceUID = info.SOPInstanceUID;
myInfo.SeriesInstanceUID = info.SeriesInstanceUID;
myInfo.SOPClassUID = info.SOPClassUID;
myInfo.StudyInstanceUID = info.StudyInstanceUID;
if(isfield(info,'FractionGroupSequence'))
    myInfo.NumberOfFractions = info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
end
myInfo.OriginalHeader = info;

cd(Current_dir);
