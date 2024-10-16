%% load_DICOM_RT_Records
% Load treatment records/logs from file
%
%% Syntax
% |[myBeamData,myInfo] = load_DICOM_RT_Records(log_filename,format)|
%
%
%% Description
% |[myBeamData,myInfo] = load_DICOM_RT_Records(log_filename,format)| Load a treatment plan from file
%
%
%% Input arguments
% |log_filename| - _STRING_ or _CELL_ - File name(s) (including path) of the data to be loaded
%
% |format| - _STRING or INTEGER_ -   Format of the file(s). The options are:
%
% * 'dcm' - Dicom RT Record files
% * 'iba' - IBA log files (.zip)
%
%
%% Output arguments
%
% |myBeamData| - _CELL VECTOR of STRUCTURE_ -  |myBeamData{i}| Description of the the geometry of the i-th proton beam. See |load_DICOM_RT_Plan| or |load_PLD| or |load_Gate_Plan| for more details.
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file. See |load_DICOM_RT_Plan| or |load_PLD| or |load_Gate_Plan| for more details.
%
%
%% Contributors
% Authors : G.Janssens, K. Souris, R. Labarbe, L. Hotoiu (open.reggui@gmail.com)

function [myBeamData,myInfo] = load_DICOM_RT_Records(log_filename,format,ref_data,ref_info,varargin)

myBeamData = cell(0);
myInfo = struct;
Current_dir = pwd;

% Default parameters
aggregate_paintings = 0;
overwrite_geometry = 0;
merge_tuning = 1;
XDRconverter = '';
oneday = 8.6400e+10;

% Input parameters
if(nargin>4)
    for i=1:2:length(varargin)
        if(ischar(varargin{i}))
            try
                eval([varargin{i},' = varargin{i+1};']);
            catch
                disp(['Cannot create variable: ',varargin{i}]);
            end
        end
    end
end

switch format

    case 'dcm' % DICOM RT RECORD

        if(iscell(log_filename))
            log_filename = log_filename{1};
        end

        % load dicom file
        try
            info = dicominfo(log_filename);
        catch ME
            disp('Failed to read file as dicom... ');
            rethrow(ME);
        end

        % check input
        if(not(isfield(info,'TreatmentSessionIonBeamSequence')))
            error('Not an ion beam tx record. Abort.');
        elseif(not(isfield(info.TreatmentSessionIonBeamSequence.Item_1.IonControlPointDeliverySequence.Item_1,'ScanSpotPositionMap')))
            error('Not a pbs tx record. Abort.');
        end

        % correct for patient position if needed
        correct_orientation = 'HFS';
        if(isfield(info,'PatientPosition') && isfield(info,'RTPlanGeometry'))
            if(strcmp(info.RTPlanGeometry,'PATIENT'))
                correct_orientation = info.PatientPosition;
            end
        elseif(isfield(info,'PatientSetupSequence'))
            correct_orientation = 'TBD_per_beam';
        end

        % create plan from dicom record data
        myInfo.Type = 'pbs_plan';

        beamFieldNames = fieldnames(info.TreatmentSessionIonBeamSequence);	%Field names for the treatment beams.
        nb_fields = length(beamFieldNames);

        n = 0;
        for i=1:nb_fields

            if(strcmp(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).TreatmentDeliveryType,'TREATMENT') || strcmp(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).TreatmentDeliveryType,'CONTINUATION'))
                n = n+1;
            else
                continue
            end

            beamSequence = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence;
            layerFieldNames = fieldnames(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence);
            nb_layers = length(layerFieldNames);

            % check whether layers are defined with 1 or 2 control points
            double_control_point_per_layer = 1;
            for j=1:2:nb_layers-1
                if(not(sum(beamSequence.(layerFieldNames{j+1}).ScanSpotMetersetsDelivered)==0 && beamSequence.(layerFieldNames{j}).NominalBeamEnergy==beamSequence.(layerFieldNames{j+1}).NominalBeamEnergy))
                    double_control_point_per_layer = 0;
                end
            end
            if(nb_layers>1 && double_control_point_per_layer)
                dummyLayerFieldNames = layerFieldNames(2:2:end);
                layerFieldNames = layerFieldNames(1:2:end-1);
                nb_layers = nb_layers/2;
            else
                dummyLayerFieldNames = layerFieldNames;
            end

            myBeamData{n}.name = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamName;

            % Get additional info from the reference plan
            ref_beam_index = 0;
            if(not(isempty(ref_data)))
                for r=1:length(ref_data)
                    if(strcmp(myBeamData{n}.name,ref_data{r}.name)) % look for beam with same name
                        ref_beam_index = r;
                    end
                end
            end
            if(ref_beam_index==0 && not(isempty(ref_data)))
                for r=1:length(ref_data)
                    if(not(isempty(strfind(myBeamData{n}.name,ref_data{r}.name)))) % if no ref beam found, look for beam name that contains the ref beam bame
                        ref_beam_index = r;
                    end
                end
            end
            if(length(myBeamData)==1 && length(ref_data)==1)  % if only one beam in both plan and record, associate by default
                ref_beam_index = 1;
            end
            if(ref_beam_index>0)
                myBeamData{n}.isocenter = ref_data{ref_beam_index}.isocenter;
            else
                myBeamData{n}.isocenter = [0,0,0];
            end

            % Correct for patient orientation
            if ref_beam_index>0 && (overwrite_geometry || not(isfield(beamSequence.(layerFieldNames{1}),'GantryAngle')) || not(isfield(beamSequence.(layerFieldNames{1}),'PatientSupportAngle')))
                myBeamData{n}.gantry_angle = ref_data{ref_beam_index}.gantry_angle;
                myBeamData{n}.table_angle = ref_data{ref_beam_index}.table_angle;
            else
                if(strcmp(correct_orientation,'TBD_per_beam'))
                    current_orientation = 'HFS';
                    try
                        setup_id = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).ReferencedPatientSetupNumber;
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
            end

            % Compute cumulative weight
            myBeamData{n}.final_weight = 0;
            myBeamData{n}.final_weight_specif = 0;
            for j=1:nb_layers
                myBeamData{n}.final_weight = myBeamData{n}.final_weight + beamSequence.(dummyLayerFieldNames{j}).DeliveredMeterset;
                if(isfield(beamSequence.(dummyLayerFieldNames{j}),'SpecifiedMeterset'))
                    myBeamData{n}.final_weight_specif = myBeamData{n}.final_weight_specif + beamSequence.(dummyLayerFieldNames{j}).SpecifiedMeterset;
                else
                    myBeamData{n}.final_weight_specif = NaN;
                end
            end
            myBeamData{n}.BeamMeterset = myBeamData{n}.final_weight;

            % Get radiation type
            if(isfield(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}),'RadiationType'))
                myBeamData{n}.radiation_type = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RadiationType;
            else
                myBeamData{n}.radiation_type = 'PROTON';
            end

            if(strcmp(myBeamData{n}.radiation_type,'ION'))
                myBeamData{n}.ion_AZQ = [info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RadiationAtomicNumber,info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RadiationMassNumber,info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RadiationChargeState];
            end

            % Read recorded RS or copy from plan
            myBeamData{n}.NumberOfRangeShifters = 0;
            if(ref_beam_index>0 && isfield(ref_data{ref_beam_index},'RangeShifters') && not(isfield(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}),'RecordedRangeShifterSequence')) || not(isfield(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}),'NumberOfRangeShifters')))
                myBeamData{n}.RangeShifters = ref_data{ref_beam_index}.RangeShifters;
            elseif(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).NumberOfRangeShifters > 0)
                myBeamData{n}.NumberOfRangeShifters = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).NumberOfRangeShifters;

                RS_Name = fieldnames(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RecordedRangeShifterSequence);

                if(numel(RS_Name) ~= myBeamData{n}.NumberOfRangeShifters)
                    error('ERROR: Number of range shifters does not match')
                end

                for r=1:numel(RS_Name)
                    myBeamData{n}.RangeShifters(r).RangeShifterNumber = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RecordedRangeShifterSequence.(RS_Name{r}).ReferencedRangeShifterNumber;
                    myBeamData{n}.RangeShifters(r).RangeShifterID = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RecordedRangeShifterSequence.(RS_Name{r}).RangeShifterID;

                    if(ref_beam_index>0)
                        for r_ref=1:length(ref_data{ref_beam_index}.RangeShifters)
                            if(strcmp(myBeamData{n}.RangeShifters(r).RangeShifterID,ref_data{ref_beam_index}.RangeShifters(r_ref).RangeShifterID))
                                myBeamData{n}.RangeShifters(r).RangeShifterType = ref_data{ref_beam_index}.RangeShifters(r_ref).RangeShifterType;
                            end
                        end
                    end

                end

            end

            RangeShifterSetting = 'OUT';
            ReferencedRangeShifterNumber = 0;
            if(isfield(beamSequence.(layerFieldNames{1}), 'RangeShifterSettingsSequence'))
                if(isfield(beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1,'RangeShifterSetting'))
                    RangeShifterSetting = beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1.RangeShifterSetting;
                end
                if(isfield(beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1,'ReferencedRangeShifterNumber'))
                    ReferencedRangeShifterNumber = beamSequence.(layerFieldNames{1}).RangeShifterSettingsSequence.Item_1.ReferencedRangeShifterNumber;
                end
            end

            for j=1:nb_layers

                fprintf('%s, Layer %d (%g MeV)\n',info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamName,j,beamSequence.(layerFieldNames{j}).NominalBeamEnergy);

                if(isfield(beamSequence.(layerFieldNames{j}),'NumberOfPaintings'))
                    myBeamData{n}.spots(j).nb_paintings = beamSequence.(layerFieldNames{j}).NumberOfPaintings;
                end

                myBeamData{n}.spots(j).energy = beamSequence.(layerFieldNames{j}).NominalBeamEnergy;
                if(not(isfield(beamSequence.(layerFieldNames{j}),'NumberOfScanSpotPositions')))
                    beamSequence.(layerFieldNames{j}).NumberOfScanSpotPositions = length(beamSequence.(layerFieldNames{j}).ScanSpotMetersetsDelivered);
                end
                myBeamData{n}.spots(j).xy = reshape(beamSequence.(layerFieldNames{j}).ScanSpotPositionMap,2,beamSequence.(layerFieldNames{j}).NumberOfScanSpotPositions)';
                if(myBeamData{n}.final_weight == 0)
                    myBeamData{n}.spots(j).weight = [beamSequence.(layerFieldNames{j}).ScanSpotMetersetsDelivered] * 0;
                else
                    myBeamData{n}.spots(j).weight = [beamSequence.(layerFieldNames{j}).ScanSpotMetersetsDelivered] * myBeamData{n}.BeamMeterset / myBeamData{n}.final_weight;
                end
                if(isfield(beamSequence.(layerFieldNames{j}),'TreatmentControlPointTime') && isfield(beamSequence.(layerFieldNames{j}),'ScanSpotTimeOffset'))
                    if(length(beamSequence.(layerFieldNames{j}).TreatmentControlPointTime)>=13 && strcmp(beamSequence.(layerFieldNames{j}).TreatmentControlPointTime(7),'.')) % format 000000.000000
                        myBeamData{n}.spots(j).timeStart = beamSequence.(layerFieldNames{j}).ScanSpotTimeOffset/1e6 + (timenum_s(beamSequence.(layerFieldNames{j}).TreatmentControlPointTime) - timenum_s(beamSequence.(layerFieldNames{1}).TreatmentControlPointTime));
                    else
                        disp(['Warning: wrong format for TreatmentControlPointTime (layer ',num2str(j),')'])
                    end
                end

                if(myBeamData{n}.NumberOfRangeShifters > 0)

                    if(isfield(beamSequence.(layerFieldNames{j}), 'RangeShifterSettingsSequence'))
                        RangeShifterSetting = beamSequence.(layerFieldNames{j}).RangeShifterSettingsSequence.Item_1.RangeShifterSetting;
                        ReferencedRangeShifterNumber = beamSequence.(layerFieldNames{j}).RangeShifterSettingsSequence.Item_1.ReferencedRangeShifterNumber;
                    end

                    myBeamData{n}.spots(j).RangeShifterSetting = RangeShifterSetting;
                    myBeamData{n}.spots(j).ReferencedRangeShifterNumber = ReferencedRangeShifterNumber;
                    if(ref_beam_index>0)
                        if(not(isempty(ref_data{ref_beam_index}))) % Information copied from referenced plan
                            try
                                ref_layer_index = 0;
                                for index=1:length(ref_data{ref_beam_index}.spots)
                                    if(abs(ref_data{ref_beam_index}.spots(index).energy - myBeamData{n}.spots(j).energy)<0.1)
                                        ref_layer_index = index;
                                        break
                                    end
                                end
                                if(ref_data{ref_beam_index}.spots(ref_layer_index).ReferencedRangeShifterNumber==myBeamData{n}.spots(j).ReferencedRangeShifterNumber && isfield(ref_data{ref_beam_index}.spots(ref_layer_index),'RangeShifterWaterEquivalentThickness'))
                                    myBeamData{n}.spots(j).RangeShifterWaterEquivalentThickness = ref_data{ref_beam_index}.spots(ref_layer_index).RangeShifterWaterEquivalentThickness;
                                end
                                if(ref_data{ref_beam_index}.spots(ref_layer_index).ReferencedRangeShifterNumber==myBeamData{n}.spots(j).ReferencedRangeShifterNumber && isfield(ref_data{ref_beam_index}.spots(ref_layer_index),'IsocenterToRangeShifterDistance'))
                                    myBeamData{n}.spots(j).IsocenterToRangeShifterDistance = ref_data{ref_beam_index}.spots(ref_layer_index).IsocenterToRangeShifterDistance;
                                end
                            catch
                                disp('Record does not correspond to plan.')
                            end
                        end
                    end

                end
            end	%for j=1:nb_layers

        end %for i=1:nb_fields

        % Look for tuning information (private tag)
        if(isfield(info,'Private_3003_1001'))
            tunings = loadjson(char(info.Private_3003_1001(info.Private_3003_1001>0)'));
            for n=1:nb_fields
                for j=1:length(myBeamData{n}.spots)
                    myBeamData{n}.spots(j).tuning = myBeamData{n}.spots(j).weight*0;
                    try
                        for s=1:length(tunings.beams{n}.layers{j}.spots)
                            myBeamData{n}.spots(j).tuning(tunings.beams{n}.layers{j}.spots{s}.spotIndex) = tunings.beams{n}.layers{j}.spots{s}.tuningRatio;
                        end
                    catch
                        disp('Warning: error in tuning spot parsing. Continue...')
                    end
                end
            end
        end

        % Look for gantry angle information (private tag)
        if(isfield(info,'Private_3003_1003'))
            gantry_angles = loadjson(char(info.Private_3003_1003(info.Private_3003_1003>0)'));
            for n=1:nb_fields
                for j=1:length(myBeamData{n}.spots)
                    myBeamData{n}.spots(j).gantry_angle = myBeamData{n}.spots(j).weight*0;
                    try
                        for s=1:length(gantry_angles.beams{n}.layers{j}.spots)
                            myBeamData{n}.spots(j).gantry_angle(gantry_angles.beams{n}.layers{j}.spots{s}.spotIndex) = gantry_angles.beams{n}.layers{j}.spots{s}.gantryAngle;
                        end
                    catch
                        disp('Warning: error in gantry angle spot parsing. Continue...')
                    end
                end
            end
        end

        % Look for meterset rate information (private tag)
        if(isfield(info,'Private_3003_1005'))
            metersetRates = loadjson(char(info.Private_3003_1005(info.Private_3003_1005>0)'));
            for n=1:nb_fields
                for j=1:length(myBeamData{n}.spots)
                    myBeamData{n}.spots(j).metersetRate = myBeamData{n}.spots(j).weight*0;
                    try
                        for s=1:length(metersetRates.beams{n}.layers{j}.spots)
                            myBeamData{n}.spots(j).metersetRate(metersetRates.beams{n}.layers{j}.spots{s}.spotIndex) = metersetRates.beams{n}.layers{j}.spots{s}.metersetRate;
                        end
                    catch
                        disp('Warning: error in meterset rate spot parsing. Continue...')
                    end
                end
            end
        end

        % Look for duration information (private tag)
        if(isfield(info,'Private_3003_1009'))
            durations = loadjson(char(info.Private_3003_1009(info.Private_3003_1009>0)'));
            for n=1:nb_fields
                for j=1:length(myBeamData{n}.spots)
                    try
                        for s=1:length(durations.beams{n}.layers{j}.spots)
                            myBeamData{n}.spots(j).duration(durations.beams{n}.layers{j}.spots{s}.spotIndex) = durations.beams{n}.layers{j}.spots{s}.duration;                            
                        end
                    catch
                        disp('Warning: error in spot duration parsing. Continue...')
                    end
                    if(isfield(myBeamData{n}.spots(j),'timeStart'))
                        myBeamData{n}.spots(j).timeStop = myBeamData{n}.spots(j).timeStart + myBeamData{n}.spots(j).duration;
                    end
                end
            end
        end

        % Look for average time information (private tag)
        if(isfield(info,'Private_3003_1007'))
            times = loadjson(char(info.Private_3003_1007(info.Private_3003_1007>0)'));
            for n=1:nb_fields
                for j=1:length(myBeamData{n}.spots)
                    myBeamData{n}.spots(j).time = myBeamData{n}.spots(j).weight*0;
                    try
                        for s=1:length(times.beams{n}.layers{j}.spots)
                            myBeamData{n}.spots(j).time(times.beams{n}.layers{j}.spots{s}.spotIndex) = times.beams{n}.layers{j}.spots{s}.time;
                        end
                    catch
                        disp('Warning: error in spot time parsing. Continue...')
                    end
                end
            end
        elseif(isfield(info,'Private_3003_1009') && isfield(myBeamData{n}.spots(j),'timeStart') && isfield(myBeamData{n}.spots(j),'timeStop')) % compute spot time as the average between start and stop
            for n=1:nb_fields
                for j=1:length(myBeamData{n}.spots)
                    myBeamData{n}.spots(j).time = (myBeamData{n}.spots(j).timeStart + myBeamData{n}.spots(j).timeStop)/2;
                end
            end
        end

        % Look for spot ID information (private tag)
        if(isfield(info,'Private_3003_1011'))
            ids = loadjson(char(info.Private_3003_1011(info.Private_3003_1011>0)'));
            for n=1:nb_fields
                for j=1:length(myBeamData{n}.spots)
                    try
                        for s=1:length(ids.beams{n}.layers{j}.spots)
                            myBeamData{n}.spots(j).spot_id(ids.beams{n}.layers{j}.spots{s}.spotIndex) = ids.beams{n}.layers{j}.spots{s}.spotId;                            
                        end
                    catch
                        disp('Warning: error in spot id parsing. Continue...')
                    end
                end
            end
        end

        % Dicom information copied from the reference plan
        if(isfield(ref_info,'NumberOfFractions'))
            info.NumberOfFractionsPlanned = ref_info.NumberOfFractions;
        end

        cd(Current_dir);


    case 'iba' % IBA LOG FILES ------------------------------------------

        if(ischar(log_filename))
            log_filename = {log_filename};
        end

        % Create dicom header
        if(isfield(ref_info,'OriginalHeader'))
            ref_info = ref_info.OriginalHeader;
        end
        info = create_default_dicom_header('RTRECORD',ref_info);
        myInfo.Type = 'pbs_plan';

        % Beam reconstruction from logs
        if(not(iscell(log_filename)))
            log_filename = flip(strsplit(log_filename,';'));
            log_filename = log_filename(2:end);
        end
        nb_logs = length(log_filename);

        for f=1:nb_logs

            partial = 0;
            continuation = 0;

            % Load logs
            [C,~,final_weight] = load_IBA_logs(log_filename{f},'',XDRconverter,merge_tuning);
            beam_delivered = C{1,1};

            % Beam values
            beam_continuation_index = 0;
            for j=1:length(myBeamData)
                if(strcmp(myBeamData{j}.name,beam_delivered.BeamName))
                    beam_continuation_index = j;
                end
            end
            if(beam_continuation_index>0)
                i = beam_continuation_index;
                myBeamData{i}.final_weight = myBeamData{i}.final_weight + final_weight;
                myBeamData{i}.BeamMeterset = myBeamData{i}.BeamMeterset + final_weight;
            else
                i = length(myBeamData)+1;
                myBeamData{i}.final_weight = final_weight;
                myBeamData{i}.BeamMeterset = final_weight;
                myBeamData{i}.spots = [];
            end
            myBeamData{i}.name = beam_delivered.BeamName;
            beamFieldName = ['Item_',num2str(i)];
            info.TreatmentSessionIonBeamSequence.(beamFieldName) = info.TreatmentSessionIonBeamSequence.Item_1; % transfer default info to all beams

            % Find corresponding beamset in reference plan
            ref_beam_index = 0;
            if(not(isempty(ref_data)))
                for r=1:length(ref_data)
                    if(strcmp(beam_delivered.BeamName,ref_data{r}.name)) % look for beam with same name
                        ref_beam_index = r;
                        break
                    end
                end
            end
            if(ref_beam_index==0 && not(isempty(ref_data)))
                for r=1:length(ref_data)
                    if(not(isempty(strfind(beam_delivered.BeamName,ref_data{r}.name))) || not(isempty(strfind(ref_data{r}.name,beam_delivered.BeamName)))) % if no ref beam found, look for beam name that contains the ref beam bame
                        ref_beam_index = r;
                        break
                    end
                end
            end
            if(length(myBeamData)==1 && length(ref_data)==1)  % if only one beam in both plan and record, associate by default
                ref_beam_index = 1;
            end
            if(ref_beam_index>0 && ref_beam_index<=length(ref_data))
                myRefData = ref_data{ref_beam_index};
            else
                myRefData = [];
            end
            myRefInfo = [];
            if(isfield(ref_info,'IonBeamSequence'))
                field_list = fieldnames(ref_info.IonBeamSequence);
                for j=1:length(field_list)
                    RefBeamName = ref_info.IonBeamSequence.(field_list{j}).BeamName;
                    RefBeamName = strsplit(RefBeamName,{'/',':'});
                    RefBeamName = RefBeamName{1};
                    if(not(isempty(strfind(beam_delivered.BeamName,RefBeamName))))
                        myRefInfo = ref_info.IonBeamSequence.(field_list{j});
                        myBeamData{i}.final_weight_specif = myRefInfo.FinalCumulativeMetersetWeight;
                        break
                    end
                end
            end

            % Transfer geometric plan values to record
            if(not(beam_continuation_index>0))
                if(not(isempty(myRefData)))
                    myBeamData{i}.isocenter = myRefData.isocenter;
                    if(overwrite_geometry || isnan(beam_delivered.GantryAngle))
                        myBeamData{i}.gantry_angle = myRefData.gantry_angle;
                        myBeamData{i}.table_angle = myRefData.table_angle;
                    else
                        % correct for patient position if needed
                        current_orientation = 'HFS';
                        if(isfield(ref_info,'PatientPosition') && isfield(ref_info,'RTPlanGeometry'))
                            if(strcmp(ref_info.RTPlanGeometry,'PATIENT'))
                                current_orientation = ref_info.PatientPosition;
                            end
                        elseif(isfield(ref_info,'PatientSetupSequence'))
                            try
                                setup_id = myRefInfo.ReferencedPatientSetupNumber;
                                setup_list = fieldnames(ref_info.PatientSetupSequence);
                                for setup=1:length(setup_list)
                                    if(ref_info.PatientSetupSequence.(setup_list{setup}).PatientSetupNumber==setup_id)
                                        current_orientation = ref_info.PatientSetupSequence.(setup_list{setup}).PatientPosition;
                                    end
                                end
                            catch
                                disp('Could not find patient setup sequence. Assume HFS.');
                            end
                        end
                        [myBeamData{i}.gantry_angle,myBeamData{i}.table_angle] = correct_beam_angles_for_orientation(beam_delivered.GantryAngle,myRefData.table_angle,current_orientation);
                    end
                else
                    myBeamData{i}.isocenter = [0;0;0];
                    if(isnan(beam_delivered.GantryAngle))
                        myBeamData{i}.gantry_angle = 0;
                    else
                        myBeamData{i}.gantry_angle = beam_delivered.GantryAngle;
                    end
                    myBeamData{i}.table_angle = 0;
                end
            end

            % Get spot information from logs
            layer = 1;
            for n=1:length(beam_delivered.spots)
                if(n>1)
                    if(beam_delivered.spots(n).range ~= beam_delivered.spots(n-1).range)
                        layer = layer + 1;
                    end
                else
                    % find layer in plan corresponding to first recorded layer to identify treatment continuation
                    if(not(isempty(myRefData)))
                        plan_energies = [];
                        for j=1:length(myRefData.spots)
                            plan_energies(j) = myRefData.spots(j).energy;
                        end
                        [~,layer] = min(abs(plan_energies-beam_delivered.spots(1).energy));
                    end
                    if(layer>1)
                        continuation = 1;
                    end
                end
                if(length(myBeamData{i}.spots) < layer)
                    myDeliveryData{i}.spots(layer).date = beam_delivered.spots(n).date;
                    myDeliveryData{i}.spots(layer).time = beam_delivered.spots(n).timeStart(1)/1e6;% in [s]
                end
                % Information copied from referenced plan
                if(not(isempty(myRefData)))
                    if(isfield(myRefData.spots(layer),'nb_paintings'))
                        myBeamData{i}.spots(layer).nb_paintings = myRefData.spots(layer).nb_paintings;
                    else
                        myBeamData{i}.spots(layer).nb_paintings = 1;
                    end
                    if(isfield(myRefData.spots(layer),'energy'))
                        myBeamData{i}.spots(layer).energy = myRefData.spots(layer).energy;
                        if(isfield(beam_delivered.spots(n),'energy'))
                            if(abs(1-(beam_delivered.spots(n).energy+eps)/(myRefData.spots(layer).energy+eps))>2e-2)
                                warning(['Log energy (',num2str(beam_delivered.spots(n).energy),') does not correspond to plan (',num2str(myRefData.spots(layer).energy),') in layer ',num2str(layer)])
                            end
                        end
                    else
                        if(isfield(beam_delivered.spots(n),'energy'))
                            myBeamData{i}.spots(layer).energy = beam_delivered.spots(n).energy;
                        else
                            myBeamData{i}.spots(layer).energy = 0;
                        end
                    end
                    if(isfield(myRefData.spots(layer),'gantry_angle'))
                        myBeamData{i}.spots(layer).target_gantry_angle = myRefData.spots(layer).gantry_angle;
                    end
                    if(isfield(myRefData,'RangeShifters'))
                        myBeamData{i}.RangeShifters = myRefData.RangeShifters;
                    end
                    if(isfield(myRefData.spots(layer),'RangeShifterSetting'))
                        myBeamData{i}.spots(layer).RangeShifterSetting = myRefData.spots(layer).RangeShifterSetting;
                    end
                    if(isfield(myRefData.spots(layer),'IsocenterToRangeShifterDistance'))
                        myBeamData{i}.spots(layer).IsocenterToRangeShifterDistance = myRefData.spots(layer).IsocenterToRangeShifterDistance;
                    end
                    if(isfield(myRefData.spots(layer),'RangeShifterWaterEquivalentThickness'))
                        myBeamData{i}.spots(layer).RangeShifterWaterEquivalentThickness = myRefData.spots(layer).RangeShifterWaterEquivalentThickness;
                    end
                    if(isfield(myRefData.spots(layer),'ReferencedRangeShifterNumber'))
                        myBeamData{i}.spots(layer).ReferencedRangeShifterNumber = myRefData.spots(layer).ReferencedRangeShifterNumber;
                    end
                else
                    myBeamData{i}.spots(layer).nb_paintings = 1;
                    if(isfield(beam_delivered.spots(n),'energy'))
                        myBeamData{i}.spots(layer).energy = beam_delivered.spots(n).energy;
                    else
                        myBeamData{i}.spots(layer).energy = 0;
                    end
                end
                % Information extracted from logs
                fields = {'spot_id',1;...
                    'xy',1;...
                    'weight',1;...
                    'metersetRate',1;...
                    'tuning',1;...  
                    'timeTuning',1e-3;... % from [ms] to [s]
                    'gantry_angle',1;...
                    'gantry_speed',1;...
                    'timeStart',1e-6;... % from [us] to [s]
                    'timeStop',1e-6;... % from [us] to [s]
                    'time',1e-6;... % from [us] to [s]
                    'duration',1e-6}; % from [us] to [s]

                for k=1:size(fields,1)
                    if(isfield(beam_delivered.spots(n),fields{k,1}))
                        if(not(isfield(myBeamData{i}.spots(layer),fields{k,1})))
                            myBeamData{i}.spots(layer).(fields{k,1}) = beam_delivered.spots(n).(fields{k,1})*fields{k,2};
                        else
                            myBeamData{i}.spots(layer).(fields{k,1}) = [myBeamData{i}.spots(layer).(fields{k,1});beam_delivered.spots(n).(fields{k,1})*fields{k,2}];
                        end
                    end
                end

            end % layer loop

            % Check if no subsequent layer is missing to identify partial treatment
            if(not(isempty(myRefData)))
                if(layer<length(myRefData.spots))
                    disp(['WARNING: partial irradiation - ',num2str(length(myRefData.spots)-layer),' last layers are missing (out of ',num2str(length(myRefData.spots)),')'])
                    partial = 1;
                end
            end

            % Dicom information extracted from logs
            nb_layers = length(myBeamData{i}.spots);
            layerFieldNames = cell(nb_layers,1);
            for j=1:nb_layers
                layerFieldNames{j} = ['Item_',num2str(j)];
            end
            info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.Item_1.GantryAngle = beam_delivered.GantryAngle;
            info.TreatmentSessionIonBeamSequence.(beamFieldName).BeamName = beam_delivered.BeamName;
            info.TreatmentSessionIonBeamSequence.(beamFieldName).NumberOfControlPoints = nb_layers;
            for layer=1:nb_layers
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).NumberOfScanSpotPositions = length(myBeamData{i}.spots(layer).weight);
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).TreatmentControlPointDate = myDeliveryData{i}.spots(layer).date;
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).TreatmentControlPointTime = timestr_us(myDeliveryData{i}.spots(layer).time(1));
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).DeliveredMeterset = sum(myBeamData{i}.spots(layer).weight);
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotPositionMap = reshape(myBeamData{i}.spots(layer).xy',size(myBeamData{i}.spots(layer).xy,1)*2,1);
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotMetersetsDelivered = myBeamData{i}.spots(layer).weight;
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).NumberOfPaintings = myBeamData{i}.spots(layer).nb_paintings;
            end

            % Dicom information copied from the reference plan
            if(not(isempty(myRefInfo)))
                rlayerFieldNames = fieldnames(myRefInfo.IonControlPointSequence);
                info.TreatmentSessionIonBeamSequence.(beamFieldName).ReferencedBeamNumber = myRefInfo.BeamNumber;
                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.Item_1.PatientSupportAngle = myRefInfo.IonControlPointSequence.Item_1.PatientSupportAngle;
                if(isfield(myRefInfo,'NumberOfRangeShifters') && isfield(myRefInfo,'RangeShifterSequence'))
                    info.TreatmentSessionIonBeamSequence.(beamFieldName).NumberOfRangeShifters = myRefInfo.NumberOfRangeShifters;
                    rsFieldNames = fieldnames(myRefInfo.RangeShifterSequence);
                    for rs = 1:length(rsFieldNames)
                        if(isfield(myRefInfo.RangeShifterSequence.(rsFieldNames{rs}),'RangeShifterNumber'))
                            info.TreatmentSessionIonBeamSequence.(beamFieldName).RecordedRangeShifterSequence.(rsFieldNames{rs}).RangeShifterID = myRefInfo.RangeShifterSequence.(rsFieldNames{rs}).RangeShifterID;
                            info.TreatmentSessionIonBeamSequence.(beamFieldName).RecordedRangeShifterSequence.(rsFieldNames{rs}).ReferencedRangeShifterNumber = myRefInfo.RangeShifterSequence.(rsFieldNames{rs}).RangeShifterNumber;
                        end
                    end
                    myBeamData{i}.NumberOfRangeShifters = myRefInfo.NumberOfRangeShifters;
                end
                if(isfield(myRefInfo,'ReferencedPatientSetupNumber'))
                    info.TreatmentSessionIonBeamSequence.(beamFieldName).ReferencedPatientSetupNumber = myRefInfo.ReferencedPatientSetupNumber;
                end
                for layer=1:nb_layers
                    % find corresponding layer in reference plan
                    for rlayer=1:length(rlayerFieldNames)
                        if(abs(1-(myBeamData{i}.spots(layer).energy+eps)/(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).NominalBeamEnergy+eps))<1e-2) % if energy is approximately the same
                            info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).ReferencedControlPointIndex = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).ControlPointIndex;
                            info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).SpecifiedMeterset = sum(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).ScanSpotMetersetWeights);
                            info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).NominalBeamEnergy = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).NominalBeamEnergy;
                            if(isfield(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}),'ScanSpotTuneID'))
                                info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotTuneID = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).ScanSpotTuneID;
                            end
                            if(isfield(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}),'RangeShifterSettingsSequence'))
                                rsFieldNames = fieldnames(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).RangeShifterSettingsSequence);
                                for rs = 1:length(rsFieldNames)
                                    info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).RangeShifterSetting = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).RangeShifterSetting;
                                    info.TreatmentSessionIonBeamSequence.(beamFieldName).IonControlPointDeliverySequence.(layerFieldNames{layer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).ReferencedRangeShifterNumber = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).ReferencedRangeShifterNumber;
                                end
                            end
                            break
                        end
                    end
                end
            end

            if(partial)
                info.TreatmentSessionIonBeamSequence.(beamFieldName).TreatmentTerminationStatus = 'UNKNOWN';
            else
                info.TreatmentSessionIonBeamSequence.(beamFieldName).TreatmentTerminationStatus = 'NORMAL';
            end
            if(continuation)
                info.TreatmentSessionIonBeamSequence.(beamFieldName).TreatmentDeliveryType = 'CONTINUATION';
            else
                info.TreatmentSessionIonBeamSequence.(beamFieldName).TreatmentDeliveryType = 'TREATMENT';
            end

        end %beam loop

        % convert timings from start of beam irradiation        
        nb_beams = length(myBeamData);
        for n=1:nb_beams
            nb_layers = length(myBeamData{n}.spots);
            start_time = myBeamData{1}.spots(1).timeStart(1,1);
            myBeamData{n}.TreatmentDate = myDeliveryData{n}.spots(1).date;
            myBeamData{n}.TreatmentTime = start_time;
            for layerIndex=1:nb_layers
                myBeamData{n}.spots(layerIndex).timeStart = myBeamData{n}.spots(layerIndex).timeStart - start_time;
                myBeamData{n}.spots(layerIndex).timeStop = myBeamData{n}.spots(layerIndex).timeStop - start_time;
                myBeamData{n}.spots(layerIndex).time = myBeamData{n}.spots(layerIndex).time - start_time;                
            end
        end

        try
            info.TreatmentDate = myDeliveryData{1}.spots(1).date;
            info.TreatmentTime = timestr_us(myDeliveryData{1}.spots(1).time(1));            
        catch
            disp('WARNING: no time delivery data available in spot information.')
        end

        % Dicom information copied from the reference plan
        if(isfield(ref_info,'SOPInstanceUID'))
            info.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID = ref_info.SOPInstanceUID;
        end
        if(isfield(ref_info,'FractionGroupSequence'))
            info.NumberOfFractionsPlanned = ref_info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
        end
        if(isfield(ref_info,'PatientSetupSequence'))
            info.PatientSetupSequence = ref_info.PatientSetupSequence;
        end


    case 'iba_specif' % IBA SCANALGO -----------------------------------

        myInfo.Type = 'pbs_plan';

        % Create dicom header
        if(isfield(ref_info,'OriginalHeader'))
            ref_info = ref_info.OriginalHeader;
        end
        info = create_default_dicom_header('RTRECORD',ref_info);
        nb_fields = length(ref_data);

        % Transfer default info to all beams
        beamFieldNames = cell(nb_fields,1);
        for i=1:nb_fields
            beamFieldNames{i} = ['Item_',num2str(i)];
        end
        for i=2:nb_fields
            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}) = info.TreatmentSessionIonBeamSequence.(beamFieldNames{1});
        end

        % Call scanalgo gateway
        if(not(exist('nb_paintings','var')))
            if(isfield(ref_data{1}.spots(1),'nb_paintings'))
                nb_paintings = ref_data{1}.spots(1).nb_paintings;
            else
                nb_paintings = 1;
            end
        end
        if(iscell(log_filename))
            log_filename = log_filename{1};
        end
        options = {'config_file',log_filename,'nb_paintings',nb_paintings};
        if(exist('gateway_IP','var'))
            if(not(isempty(gateway_IP)))
                options = [options,'gateway_IP',gateway_IP];
            end
        end
        if(exist('room_id','var'))
            if(not(isempty(room_id)))
                options = [options,'room_id',room_id];
            end
        end
        if(exist('spot_tune_id','var'))
            if(not(isempty(spot_tune_id)))
                options = [options,'spot_tune_id',spot_tune_id];
            end
        end
        if(exist('snout_id','var'))
            if(not(isempty(snout_id)))
                options = [options,'snout_id',snout_id];
            end
        end
        if(exist('sort_spots','var'))
            if(not(isempty(sort_spots)))
                options = [options,'sort_spots',sort_spots];
            end
        end
        if(exist('energy_switching_time','var'))
            if(not(isempty(energy_switching_time)))
                options = [options,'energy_switching_time',energy_switching_time];
            end
        end
        beam_delivered = pbs_convert_ScanAlgo(ref_data,options);

        % Convert delivery info into record plan
        myBeamData = ref_data;
        old_ref_data = ref_data;

        for i=1:nb_fields

            ref_energies = zeros(length(old_ref_data{i}.spots),1);
            for n = 1:length(old_ref_data{i}.spots)
                ref_energies(n) = old_ref_data{i}.spots(n).energy;
            end

            % clear existing spot information
            myBeamData{i}.spots = [];

            % Get beam data from the plan
            if(isfield(ref_info,'IonBeamSequence'))
                set_dicom_info = 1;
                myRefInfo = ref_info.IonBeamSequence.(beamFieldNames{i});
                myBeamData{i}.final_weight_specif = myRefInfo.FinalCumulativeMetersetWeight;
            else
                set_dicom_info = 0;
            end

            % Information extracted from logs
            nb_layers = length(beam_delivered{i}.spots);
            for n=1:nb_layers

                % find corresponding layer in plan
                if(length(old_ref_data{i}.spots) ~= nb_layers)
                    [~,n_ref] = min(abs(ref_energies - beam_delivered{i}.spots(n).energy));
                else
                    n_ref = n;
                end

                myBeamData{i}.spots(n).energy = old_ref_data{i}.spots(n_ref).energy;
                if(isfield(beam_delivered{i}.spots(n),'spot_id'))
                    myBeamData{i}.spots(n).spot_id = beam_delivered{i}.spots(n).spot_id;
                end
                myBeamData{i}.spots(n).xy = beam_delivered{i}.spots(n).xy;
                myBeamData{i}.spots(n).weight = beam_delivered{i}.spots(n).weight;
                myBeamData{i}.spots(n).time = beam_delivered{i}.spots(n).time;
                myBeamData{i}.spots(n).duration = beam_delivered{i}.spots(n).duration/1e3; % convert ms to s
                myBeamData{i}.spots(n).nb_paintings = beam_delivered{i}.spots(n).nb_paintings;
                if(isfield(beam_delivered{i}.spots(n),'gantry_angle'))
                    if(isfield(myBeamData{i}.spots(n),'gantry_angle'))
                        myBeamData{i}.spots(n).target_gantry_angle = myBeamData{i}.spots(n).gantry_angle; % copy expected gantry angle as 'target gantry angle'
                    end
                    myBeamData{i}.spots(n).gantry_angle = beam_delivered{i}.spots(n).gantry_angle;
                end
                if(isfield(beam_delivered{i}.spots(n),'gantry_speed'))
                    myBeamData{i}.spots(n).gantry_speed = beam_delivered{i}.spots(n).gantry_speed;
                end
                if isfield(old_ref_data{i}.spots(n_ref), 'RangeShifterSetting')
                    myBeamData{i}.spots(n).RangeShifterSetting = old_ref_data{i}.spots(n_ref).RangeShifterSetting;
                end
                if isfield(old_ref_data{i}.spots(n_ref), 'IsocenterToRangeShifterDistance')
                    myBeamData{i}.spots(n).IsocenterToRangeShifterDistance = old_ref_data{i}.spots(n_ref).IsocenterToRangeShifterDistance;
                end
                if isfield(old_ref_data{i}.spots(n_ref), 'RangeShifterWaterEquivalentThickness')
                    myBeamData{i}.spots(n).RangeShifterWaterEquivalentThickness = old_ref_data{i}.spots(n_ref).RangeShifterWaterEquivalentThickness;
                end

                myDeliveryData{i}.spots(n).date = datetime('today');
                myDeliveryData{i}.spots(n).time = beam_delivered{i}.spots(n).time;
                if(nb_layers==length(ref_data{i}.spots))
                    if(abs(sum(myBeamData{i}.spots(n).weight)-sum(ref_data{i}.spots(n).weight))>1e-3)
                        disp(['Warning: layer weights do not correspond (',num2str(sum(myBeamData{i}.spots(n).weight)),' instead of ',num2str(sum(ref_data{i}.spots(n).weight)),')']);
                    end
                end
            end % layer loop

            % Dicom information
            if(set_dicom_info)

                layerFieldNames = cell(nb_layers,1);
                for j=1:nb_layers
                    layerFieldNames{j} = ['Item_',num2str(j)];
                end
                rlayerFieldNames = fieldnames(myRefInfo.IonControlPointSequence);

                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.Item_1.GantryAngle = beam_delivered{i}.gantry_angle;
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamName = beam_delivered{i}.name;
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).NumberOfControlPoints = nb_layers;
                for layer=1:nb_layers
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).NumberOfScanSpotPositions = length(myBeamData{i}.spots(layer).weight);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).TreatmentControlPointDate = myDeliveryData{i}.spots(layer).date;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).TreatmentControlPointTime = timestr_us(myDeliveryData{i}.spots(layer).time(1));
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).DeliveredMeterset = sum(myBeamData{i}.spots(layer).weight);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotPositionMap = reshape(myBeamData{i}.spots(layer).xy',size(myBeamData{i}.spots(layer).xy,1)*2,1);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotMetersetsDelivered = myBeamData{i}.spots(layer).weight;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).NumberOfPaintings = myBeamData{i}.spots(layer).nb_paintings;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).ReferencedBeamNumber = myRefInfo.BeamNumber;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.Item_1.PatientSupportAngle = myRefInfo.IonControlPointSequence.Item_1.PatientSupportAngle;

                    % find corresponding layer in reference plan
                    for rlayer=1:length(rlayerFieldNames)
                        if(abs(1-(myBeamData{i}.spots(layer).energy+eps)/(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).NominalBeamEnergy+eps))<1e3) % if energy is approximately the same
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ReferencedControlPointIndex = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).ControlPointIndex;
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).SpecifiedMeterset = sum(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).ScanSpotMetersetWeights);
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).NominalBeamEnergy = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).NominalBeamEnergy;
                            if(isfield(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}),'ScanSpotTuneID'))
                                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotTuneID = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).ScanSpotTuneID;
                            end
                            if(isfield(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}),'RangeShifterSettingsSequence'))
                                rsFieldNames = fieldnames(myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).RangeShifterSettingsSequence);
                                for rs = 1:length(rsFieldNames)
                                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).RangeShifterSetting = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).RangeShifterSetting;
                                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).ReferencedRangeShifterNumber = myRefInfo.IonControlPointSequence.(rlayerFieldNames{rlayer}).RangeShifterSettingsSequence.(rsFieldNames{rs}).ReferencedRangeShifterNumber;
                                end
                            end
                            break
                        end
                    end
                end
            end
        end

        % Dicom information copied from the reference plan
        if(isfield(ref_info,'SOPInstanceUID'))
            info.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID = ref_info.SOPInstanceUID;
        end
        if(isfield(ref_info,'FractionGroupSequence'))
            info.NumberOfFractionsPlanned = ref_info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
        end

        info.TreatmentDate = myDeliveryData{1}.spots(1).date;
        info.TreatmentTime = timestr_us(myDeliveryData{1}.spots(1).time(1));

end

% Aggregate multiple paintings into single spot map
if(aggregate_paintings)
    myBeamData = aggregate_PBS_paintings(myBeamData);
end

% Get meta information
myInfo.PatientID = info.PatientID;
if (isfield(info,'FrameOfReferenceUID'))
    myInfo.FrameOfReferenceUID = info.FrameOfReferenceUID;
else
    myInfo.FrameOfReferenceUID = 'UNKNOWN.UNKNOWN'; % The 'FrameOfReferenceUID' has been removed during the anonymisation process
end
myInfo.SOPInstanceUID = info.SOPInstanceUID;
myInfo.SeriesInstanceUID = info.SeriesInstanceUID;
myInfo.SOPClassUID = info.SOPClassUID;
myInfo.StudyInstanceUID = info.StudyInstanceUID;
if(isfield(info,'NumberOfFractionsPlanned'))
    myInfo.NumberOfFractions = info.NumberOfFractionsPlanned;
end
myInfo.OriginalHeader = info;
