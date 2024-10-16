%% save_Plan_PBS
% Save to disk a treatment plan.
% The format of the file can be specified
%
%% Syntax
% |save_Plan_PBS(plan,outname,format)|
%
% |save_Plan_PBS(plan,outname,format,plan_info)|
%
% |save_Plan_PBS(plan,outname,format,plan_info,input_header)|
%
% |save_Plan_PBS(plan,outname,format,plan_info,input_header,input_tags)|
%
%
%% Description
% |save_Plan_PBS(plan,outname,format)| Save the plan in file at specified format
%
% |save_Plan_PBS(plan,outname,format,plan_info)| Save the plan in file at specified format. If DICOM format, uses the provided DICOM info if OriginalHeader exists in plan_info
%
% |save_Plan_PBS(plan,outname,format,plan_info,input_header)| Save the plan in file at specified format. If DICOM format, uses the provided DICOM patient info from input_header
%
% |save_Plan_PBS(plan,outname,format,plan_info,input_header,input_tags)| Save the plan in file at specified format. If DICOM format, uses the provided DICOM patient info from input_header and add the additional DICOM tags
%
%
%% Input arguments
% |plan| - _STRUCTURE_ - Description of the treatment plan. See |convert_Plan_PBS| for details
%
% |outname| - _STRING_ - Name of the file in which the plan should be saved
%
% |format| - _INTEGER_ -   Format to use to save the file. The options are:
%
% * 'json' : JSON  File
% * 'gate' : GATE  File
% * 'pld' : PLD   File
% * 'dcm' : DICOM RT Plan File
% * 'dcm_record' : DICOM RT Record File
% * 'csv' : CSV File (list of spots)
%
% |input_header| - _STRING_ -  [OPTIONAL] DICOM tags that will be saved in the DICOM file.
%
% |input_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additional DICOM tags to be saved in the file if the format is 'dcm'
%
% * |input_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |input_tags{i,2}| - _ANY_ Value of the tag
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens, K. Souris, R. Labarbe, L. Hotoiu (open.reggui@gmail.com)

function save_Plan_PBS(plan,outname,format,plan_info,input_header,input_tags)

if(nargin < 4)
    plan_info = struct([]);
end

% get number of fields and layers
nb_fields = length(plan);
for f=1:nb_fields
    nb_layers(f) = length(plan{f}.spots);
end

% Compute cumulative metersets
meterset = cell(nb_fields,1);
cumulative_meterset = cell(nb_fields,1);
tot_meterset = 0;
for f=1:nb_fields
    for j=1:nb_layers(f)
        meterset{f}(j) = sum(plan{f}.spots(j).weight);
    end
    cumulative_meterset{f} = cumsum(meterset{f});
    tot_meterset = tot_meterset + sum(meterset{f});
end

endl = java.lang.System.getProperty('line.separator').char;

switch format

    case 'json'
        Plan_text = convert_Plan_PBS(plan,format); % Convert PBS plan in cell of string
        fid = fopen([strrep(outname,'.json',''),'.json'],'w');
        for i=1:length(Plan_text)
            fprintf(fid,[Plan_text{i},endl]);
        end
        fclose(fid);

    case 'gate'
        Plan_text = convert_Plan_PBS(plan,format); % Convert PBS plan in cell of string
        fid = fopen([strrep(outname,'.txt',''),'.txt'],'w');
        for i=1:length(Plan_text)
            fprintf(fid,[Plan_text{i},endl]);
        end
        fclose(fid);

    case 'pld'

        nb_paintings = 1;
        room_id = '';
        spot_tune_id = '';
        snout_id = '';
        if(nargin>5)
            for i=1:size(input_tags,1)
                try
                    eval([input_tags{i,1},' = input_tags{i,2};']);
                catch
                end
            end
        end

        Plan_text = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id); % Convert PBS plan in cell of string
        outdir = outname;
        if(not(exist(outdir,'dir')))
            try
                mkdir(outdir)
            catch
                error('Could not create directory for PLD export. Abort')
            end
        end
        for f=1:length(Plan_text)
            if(length(Plan_text{f})==1)
                fid = fopen(fullfile(outdir,[num2str(f),'.pld']),'w');
                for i=1:length(Plan_text{f}{1})
                    fprintf(fid,[Plan_text{f}{1}{i},endl]);
                end
                fclose(fid);
            else
                arcdir = fullfile(outdir,num2str(f));
                if(not(exist(arcdir,'dir')))
                    try
                        mkdir(arcdir)
                    catch
                        error('Could not create arc directory for PLD export. Abort')
                    end
                end
                for b=1:length(Plan_text{f})
                    fid = fopen(fullfile(arcdir,[sprintf('%03d',b),'.pld']),'w');
                    for i=1:length(Plan_text{f}{b})
                        fprintf(fid,[Plan_text{f}{b}{i},endl]);
                    end
                    fclose(fid);
                end
            end
        end

    case 'pld_list'

        nb_paintings = 1;
        room_id = '';
        spot_tune_id = '';
        snout_id = '';
        if(nargin>5)
            for i=1:size(input_tags,1)
                try
                    eval([input_tags{i,1},' = input_tags{i,2};']);
                catch
                end
            end
        end

        % Remove low-MU spots
        MU_threshold = 0.01;
        plan = remove_low_MU_spots(plan,MU_threshold);

        % Convert PBS plan in cell of string
        Plan_text = convert_Plan_PBS(plan,'pld',nb_paintings,room_id,spot_tune_id,snout_id);

        % Get table angles
        table_angles = [];
        for f=1:length(plan)
            table_angles(end+1) = plan{f}.table_angle;
        end
        table_angles = unique(table_angles);

        % Export data
        outdir = outname;
        if(not(exist(outdir,'dir')))
            try
                mkdir(outdir)
            catch
                error('Could not create directory for PLD export. Abort')
            end
        end
        for t=1:length(table_angles)
            if(not(exist(fullfile(outdir,['table_',num2str(plan{f}.table_angle)]),'dir')))
                try
                    mkdir(fullfile(outdir,['table_',num2str(plan{f}.table_angle)]))
                catch
                    error('Could not create directory for PLD export. Abort')
                end
            end
        end
        for f=1:length(Plan_text)
            % Include angles (+/- 1° angular window)
            Plan_text{f}{1} = [Plan_text{f}{1},',',num2str(plan{f}.gantry_angle-1),',',num2str(plan{f}.gantry_angle+1)];
            % Export files
            fid = fopen(fullfile(outdir,['table_',num2str(plan{f}.table_angle)],[sprintf('%03d',f),'.pld']),'w');
            for i=1:length(Plan_text{f})
                fprintf(fid,[Plan_text{f}{i},endl]);
            end
            fclose(fid);
        end

    case 'pld_folders'

        nb_paintings = 1;
        room_id = '';
        spot_tune_id = '';
        snout_id = '';
        if(nargin>5)
            for i=1:size(input_tags,1)
                try
                    eval([input_tags{i,1},' = input_tags{i,2};']);
                catch
                end
            end
        end

        % Remove low-MU spots
        MU_threshold = 0.01;
        plan = remove_low_MU_spots(plan,MU_threshold);

        % Convert PBS plan in cell of string
        Plan_text = convert_Plan_PBS(plan,'pld',nb_paintings,room_id,spot_tune_id,snout_id);

        % Get table angles
        table_angles = [];
        for f=1:length(plan)
            table_angles(end+1) = plan{f}.table_angle;
        end
        table_angles = unique(table_angles);

        % Export data
        outdir = outname;
        if(not(exist(outdir,'dir')))
            try
                mkdir(outdir)
            catch
                error('Could not create directory for PLD export. Abort')
            end
        end
        for t=1:length(table_angles)
            if(not(exist(fullfile(outdir,num2str(table_angles(t))),'dir')))
                try
                    mkdir(fullfile(outdir,num2str(table_angles(t))))
                catch
                    error('Could not create directory for PLD export. Abort')
                end
            end
        end
        for f=1:length(Plan_text)
            try
                mkdir(fullfile(fullfile(outdir,num2str(plan{f}.table_angle)),num2str(f)))
            catch
                error('Could not create directory for PLD export. Abort')
            end
            fid = fopen(fullfile(fullfile(fullfile(outdir,num2str(plan{f}.table_angle)),num2str(f)),'angle.txt'),'w');
            fprintf(fid,num2str(plan{f}.gantry_angle));%fprintf(fid,num2str((f-1)*3));%
            fclose(fid);
            fid = fopen(fullfile(fullfile(fullfile(outdir,num2str(plan{f}.table_angle)),num2str(f)),'1.pld'),'w');
            for i=1:length(Plan_text{f})
                fprintf(fid,[Plan_text{f}{i},endl]);
            end
            fclose(fid);
        end

    case 'pld_folders_old'

        nb_paintings = 1;
        room_id = '';
        spot_tune_id = '';
        snout_id = '';
        if(nargin>5)
            for i=1:size(input_tags,1)
                try
                    eval([input_tags{i,1},' = input_tags{i,2};']);
                catch
                end
            end
        end

        % Remove low-MU spots
        MU_threshold = 0.01;
        plan = remove_low_MU_spots(plan,MU_threshold);

        % Convert PBS plan in cell of string
        Plan_text = convert_Plan_PBS(plan,'pld',nb_paintings,room_id,spot_tune_id,snout_id);

        % Get table angles
        table_angles = [];
        for f=1:length(plan)
            table_angles(end+1) = plan{f}.table_angle;
        end
        table_angles = unique(table_angles);

        % Export data
        outdir = outname;
        if(not(exist(outdir,'dir')))
            try
                mkdir(outdir)
            catch
                error('Could not create directory for PLD export. Abort')
            end
        end
        for t=1:length(table_angles)
            if(not(exist(fullfile(outdir,num2str(table_angles(t))),'dir')))
                try
                    mkdir(fullfile(outdir,num2str(table_angles(t))))
                catch
                    error('Could not create directory for PLD export. Abort')
                end
            end
        end
        for f=1:length(Plan_text)
            try
                mkdir(fullfile(fullfile(outdir,num2str(plan{f}.table_angle)),num2str(plan{f}.gantry_angle)))
            catch
                error('Could not create directory for PLD export. Abort')
            end
            fid = fopen(fullfile(fullfile(fullfile(outdir,num2str(plan{f}.table_angle)),num2str(plan{f}.gantry_angle)),'1.pld'),'w');
            for i=1:length(Plan_text{f})
                fprintf(fid,[Plan_text{f}{i},endl]);
            end
            fclose(fid);
        end

    case 'dcm'

        % Get original dicom information or create default
        use_original_header = 0;
        if(isfield(plan_info,'OriginalHeader'))
            if(strcmp(plan_info.OriginalHeader.Modality,'RTPLAN'))
                use_original_header = 1;
            end
        end
        if(use_original_header)
            info = plan_info.OriginalHeader;
        else
            info = create_default_dicom_header('RTPLAN',plan_info);
        end

        % Replace patient dicom values from input_header (if any)
        if(nargin>4)
            field_list = {'PatientID','PatientName','PatientSex','PatientBirthDate'};
            for i=1:length(field_list)
                if(isfield(input_header,field_list{i}))
                    info.(field_list{i}) = input_header(field_list{i});
                end
            end
        end

        % Check if beam sequence is similar to the original
        if(use_original_header)
            [Modify_existing_structure, beamFieldNames] = check_plan_header_consistency(plan,info);
        else
            Modify_existing_structure = 0;
        end

        % Look for global patient orientation
        correct_orientation = 'HFS';
        if(isfield(info,'PatientPosition') && isfield(info,'RTPlanGeometry'))
            if(strcmp(info.RTPlanGeometry,'PATIENT'))
                correct_orientation = info.PatientPosition;
            end
        elseif(isfield(info,'PatientSetupSequence'))
            correct_orientation = 'TBD_per_beam';
        end
        for i=1:nb_fields
            % correct for patient orientation
            if(strcmp(correct_orientation,'TBD_per_beam') && use_original_header)
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
                end
            elseif(strcmp(correct_orientation,'TBD_per_beam'))
                correct_orientation = 'HFS';
            else
                current_orientation = correct_orientation;
            end
            [plan{i}.gantry_angle,plan{i}.table_angle] = correct_beam_angles_for_orientation(plan{i}.gantry_angle,plan{i}.table_angle,current_orientation);
        end

        if(Modify_existing_structure) % nominal case (no modification of the number of beams compared to original dicom)

            disp('Modifying/copying original dicom ion control point structure.')

            fractionGroupFieldName=fieldnames(info.FractionGroupSequence);
            referencedBeamFieldNames=fieldnames(info.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence);

            for i=1:nb_fields
                realFractionationNo(i)=info.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence.(referencedBeamFieldNames{i}).ReferencedBeamNumber;
            end

            for i=1:nb_fields

                layerFieldNames = fieldnames(info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence);
                nb_layers = length(layerFieldNames)/2;

                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).IsocenterPosition = plan{i}.isocenter;
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).GantryAngle = plan{i}.gantry_angle;
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).PatientSupportAngle = plan{i}.table_angle;

                FractionSequenceBeamID = find(realFractionationNo==info.IonBeamSequence.(beamFieldNames{i}).BeamNumber); % The beam order may be different in IonBeamSequence and FractionGroupSequence

                Old_IonBeamSequence_FinalWeight = info.IonBeamSequence.(beamFieldNames{i}).FinalCumulativeMetersetWeight;
                Old_FractionGroupSequence_Meterset = info.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence.(referencedBeamFieldNames{FractionSequenceBeamID}).BeamMeterset;

                CumulativeMeterset = 0;
                for j=1:nb_layers
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NominalBeamEnergy = plan{i}.spots(j).energy;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions = length(plan{i}.spots(j).weight);
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotMetersetWeights = plan{i}.spots(j).weight * plan{i}.final_weight / plan{i}.BeamMeterset;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap = reshape(plan{i}.spots(j).xy',size(plan{i}.spots(j).xy,1)*2,1);
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).CumulativeMetersetWeight = CumulativeMeterset;
                    CumulativeMeterset = CumulativeMeterset + sum(plan{i}.spots(j).weight * plan{i}.final_weight / Old_FractionGroupSequence_Meterset);
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).CumulativeMetersetWeight = CumulativeMeterset;
                    if(isfield(plan{i}.spots(j),'gantry_angle'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).GantryAngle = plan{i}.spots(j).gantry_angle(1);
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).GantryAngle = plan{i}.spots(j).gantry_angle(end);
                    end
                    % update second control points for consistency
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).NominalBeamEnergy = info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NominalBeamEnergy;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).NumberOfScanSpotPositions = info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).ScanSpotMetersetWeights = info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotMetersetWeights*0;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).ScanSpotPositionMap = info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap;
                end

                info.IonBeamSequence.(beamFieldNames{i}).FinalCumulativeMetersetWeight = CumulativeMeterset;
                if(CumulativeMeterset == 0.0)
                    info.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence.(referencedBeamFieldNames{FractionSequenceBeamID}).BeamMeterset = 0.0;
                else
                    info.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence.(referencedBeamFieldNames{FractionSequenceBeamID}).BeamMeterset = CumulativeMeterset * Old_FractionGroupSequence_Meterset / Old_IonBeamSequence_FinalWeight;
                end
            end

        else % modification of the number of beams - recreate ion control point sequences from scratch

            disp('Creating ion control point structure from scratch.')

            beamFieldNames = cell(nb_fields,1);
            for i=1:nb_fields
                beamFieldNames{i} = ['Item_',num2str(i)];
            end
            default_ion_beam_sequence = info.IonBeamSequence.Item_1;
            info.IonBeamSequence = struct; % reset structure

            % Create ion beams
            for i=1:nb_fields
                nb_layers = length(plan{i}.spots);
                layerFieldNames = cell(nb_layers,1);
                for j=1:nb_layers
                    layerFieldNames{2*j-1} = ['Item_',num2str(2*j-1)];
                    layerFieldNames{2*j} = ['Item_',num2str(2*j)];
                end
                info.IonBeamSequence.(beamFieldNames{i}) = default_ion_beam_sequence;
                info.IonBeamSequence.(beamFieldNames{i}).BeamNumber = i;
                if(isfield(plan{i},'name'))
                    info.IonBeamSequence.(beamFieldNames{i}).BeamName = plan{i}.name;
                else
                    info.IonBeamSequence.(beamFieldNames{i}).BeamName = num2str(i);
                end
                info.IonBeamSequence.(beamFieldNames{i}).NumberOfControlPoints = nb_layers*2;
                if(isfield(plan{i},'RangeShifters'))
                    info.IonBeamSequence.(beamFieldNames{i}).NumberOfRangeShifters = length(plan{i}.RangeShifters);
                    for j=1:length(plan{i}.RangeShifters)
                        %info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(['Item_',num2str(j)]) = plan{i}.RangeShifters(j);
                        info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(['Item_',num2str(j)]).RangeShifterNumber = plan{i}.RangeShifters(j).RangeShifterNumber;
                        info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(['Item_',num2str(j)]).RangeShifterID = plan{i}.RangeShifters(j).RangeShifterID; %-_STRING_- ID of the range shifter as defined in the beam data library
                        info.IonBeamSequence.(beamFieldNames{i}).RangeShifterSequence.(['Item_',num2str(j)]).RangeShifterType = plan{i}.RangeShifters(j).RangeShifterType;
                    end
                end
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence = struct;
                % Default beam geometry (on first control point)
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).BeamLimitingDeviceAngle = 0;
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).PatientSupportRotationDirection = 'NONE';
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).BeamLimitingDeviceRotationDirection = 'NONE';
                % Beam geometry (on first control point)
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).IsocenterPosition = plan{i}.isocenter;
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).GantryAngle = plan{i}.gantry_angle;
                info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).PatientSupportAngle = plan{i}.table_angle;
                if(isfield(plan{i}.spots(1),'gantry_angle'))
                    gantry_angle_diff = mod(plan{i}.spots(j).gantry_angle(end)-plan{i}.spots(j).gantry_angle(1),360);
                    if(gantry_angle_diff==0)
                        info.IonBeamSequence.(beamFieldNames{i}).BeamType = 'STATIC';
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).GantryRotationDirection = 'NONE';
                    elseif(gantry_angle_diff<180)
                        info.IonBeamSequence.(beamFieldNames{i}).BeamType = 'DYNAMIC';
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).GantryRotationDirection = 'CW';
                    elseif(gantry_angle_diff>=180)
                        info.IonBeamSequence.(beamFieldNames{i}).BeamType = 'DYNAMIC';
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).GantryRotationDirection = 'CC';
                    end
                else
                    info.IonBeamSequence.(beamFieldNames{i}).BeamType = 'STATIC';
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).GantryRotationDirection = 'NONE';
                end
                % SnoutPosition
                if(isfield(plan{i},'snout_position'))
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{1}).SnoutPosition = plan{i}.snout_position;
                end
                % Control point structure
                CumulativeMeterset = 0;
                for j=1:nb_layers
                    % ControlPointIndex
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ControlPointIndex = 2*j-1-1;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).ControlPointIndex = 2*j-1;
                    % NominalBeamEnergy
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NominalBeamEnergy = plan{i}.spots(j).energy;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).NominalBeamEnergy = plan{i}.spots(j).energy;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NominalBeamEnergyUnit = 'MEV';
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).NominalBeamEnergyUnit = 'MEV';
                    % NumberOfScanSpotPositions
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions = length(plan{i}.spots(j).weight);
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).NumberOfScanSpotPositions = length(plan{i}.spots(j).weight);
                    % ScanSpotPositionMap
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap = reshape(plan{i}.spots(j).xy',size(plan{i}.spots(j).xy,1)*2,1);
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).ScanSpotPositionMap = reshape(plan{i}.spots(j).xy',size(plan{i}.spots(j).xy,1)*2,1);
                    % ScanSpotMetersetWeights
                    if(isfield(plan{i},'BeamMeterset'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotMetersetWeights = plan{i}.spots(j).weight * plan{i}.final_weight / plan{i}.BeamMeterset;
                    else
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotMetersetWeights = plan{i}.spots(j).weight;
                    end
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).ScanSpotMetersetWeights = plan{i}.spots(j).weight * 0;
                    % ScanningSpotSize
                    if(isfield(plan{i}.spots(j),'spot_size'))
                        spot_size =  plan{i}.spots(j).spot_size;
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanningSpotSize = spot_size;
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).ScanningSpotSize = spot_size;
                    end
                    % ScanSpotTuneID
                    if(isfield(plan{i}.spots(j),'spot_tune_id'))
                        spot_tune_id =  plan{i}.spots(j).spot_tune_id;
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).ScanSpotTuneID = spot_tune_id;
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).ScanSpotTuneID = spot_tune_id;
                    end
                    % NumberOfPaintings
                    if(isfield(plan{i}.spots(j),'nb_paintings'))
                        nb_paintings =  plan{i}.spots(j).nb_paintings;
                    else
                        nb_paintings = 1;
                    end
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NumberOfPaintings = nb_paintings;
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).NumberOfPaintings = nb_paintings;
                    % Number of paintings
                    if(isfield(plan{i}.spots(j),'nb_paintings'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).NumberOfPaintings = plan{i}.spots(j).nb_paintings;
                    end
                    % CumulativeMetersetWeight
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).CumulativeMetersetWeight = CumulativeMeterset;
                    CumulativeMeterset = CumulativeMeterset + sum(plan{i}.spots(j).weight);
                    info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).CumulativeMetersetWeight = CumulativeMeterset;
                    % RangeShifter
                    if(isfield(plan{i}.spots(j),'RangeShifterSetting'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item1.RangeShifterSetting = plan{i}.spots(j).RangeShifterSetting;
                    end
                    if(isfield(plan{i}.spots(j),'IsocenterToRangeShifterDistance'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item1.IsocenterToRangeShifterDistance = plan{i}.spots(j).IsocenterToRangeShifterDistance;
                    end
                    if(isfield(plan{i}.spots(j),'ReferencedRangeShifterNumber'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item1.ReferencedRangeShifterNumber = plan{i}.spots(j).ReferencedRangeShifterNumber;
                    end
                    if(isfield(plan{i}.spots(j),'RangeShifterWaterEquivalentThickness'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).RangeShifterSettingsSequence.Item1.RangeShifterWaterEquivalentThickness = plan{i}.spots(j).RangeShifterWaterEquivalentThickness;
                    end
                    % Gantry angle
                    if(isfield(plan{i}.spots(j),'gantry_angle'))
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j-1}).GantryAngle = plan{i}.spots(j).gantry_angle(1);
                        info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence.(layerFieldNames{2*j}).GantryAngle = plan{i}.spots(j).gantry_angle(end);
                    end
                end
                info.IonBeamSequence.(beamFieldNames{i}).FinalCumulativeMetersetWeight = CumulativeMeterset;

                % Fill in fraction group sequence
                info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(beamFieldNames{i})=struct;
                info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(beamFieldNames{i}).ReferencedBeamNumber = i;
                info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(beamFieldNames{i}).BeamMeterset = CumulativeMeterset;

            end

        end

        % Additional input dicom tags
        if(nargin>5)
            for i=1:size(input_tags,1)
                try
                    info.(input_tags{i,1}) = input_tags{i,2};
                catch
                end
            end
        end

        dicomwrite([], [strrep(outname,'.dcm',''),'.dcm'], info, 'WritePrivate', true, 'CreateMode', 'copy');

    case 'dcm_record'

        % Get original dicom information or create default
        use_original_header = 0;
        if(isfield(plan_info,'OriginalHeader'))
            if(strcmp(plan_info.OriginalHeader.Modality,'RTRECORD'))
                use_original_header = 1;
                info = plan_info.OriginalHeader;
            else
                info = create_default_dicom_header('RTRECORD',plan_info);
            end
        else
            info = create_default_dicom_header('RTRECORD',plan_info);
        end

        % Replace patient dicom values from input_header (if any)
        if(nargin>4)
            field_list = {'PatientID','PatientName','PatientSex','PatientBirthDate'};
            for i=1:length(field_list)
                if(isfield(input_header,field_list{i}))
                    info.(field_list{i}) = input_header(field_list{i});
                end
            end
        end

        % Check if beam sequence is similar to the original
        if(use_original_header)
            [Modify_existing_structure, beamFieldNames] = check_plan_header_consistency(plan,info);
        else
            Modify_existing_structure = 0;
        end

        % Look for global patient orientation
        correct_orientation = 'HFS';
        if(isfield(info,'PatientPosition') && isfield(info,'RTPlanGeometry'))
            if(strcmp(info.RTPlanGeometry,'PATIENT'))
                correct_orientation = info.PatientPosition;
            end
        elseif(isfield(info,'PatientSetupSequence'))
            correct_orientation = 'TBD_per_beam';
        end
        for i=1:nb_fields
            % correct for patient orientation
            if(strcmp(correct_orientation,'TBD_per_beam') && use_original_header)
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
                end
            elseif(strcmp(correct_orientation,'TBD_per_beam'))
                current_orientation = 'HFS';
            else
                current_orientation = correct_orientation;
            end
            [plan{i}.gantry_angle,plan{i}.table_angle] = correct_beam_angles_for_orientation(plan{i}.gantry_angle,plan{i}.table_angle,current_orientation);
        end

        if(Modify_existing_structure) % nominal case (no modification of the number of beams and layers compared to original dicom)

            disp('Modifying/copying original dicom delivered ion control point structure.')

            for i=1:nb_fields

                layerFieldNames = fieldnames(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence);
                nb_layers = length(layerFieldNames);

                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).IsocenterPosition = plan{i}.isocenter;
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).GantryAngle = plan{i}.gantry_angle;
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).PatientSupportAngle = plan{i}.table_angle;

                for j=1:nb_layers
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).NominalBeamEnergy = plan{i}.spots(j).energy;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).NumberOfScanSpotPositions = length(plan{i}.spots(j).weight);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).ScanSpotMetersetsDelivered = plan{i}.spots(j).weight;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).ScanSpotPositionMap = reshape(plan{i}.spots(j).xy',size(plan{i}.spots(j).xy,1)*2,1);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).DeliveredMeterset = sum(plan{i}.spots(j).weight);
                    if(isfield(plan{i}.spots(j),'time'))
                        if(isfield(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}),'TreatmentControlPointTime'))
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).TreatmentControlPointTime = timestr_us(plan{i}.spots(j).time(1) + timenum_s(info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).TreatmentControlPointTime));
                        else
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).TreatmentControlPointTime = timestr_us(plan{i}.spots(j).time(1));
                        end
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).ScanSpotTimeOffset = (plan{i}.spots(j).time - plan{i}.spots(j).time(1))*1e6;% in [us]
                    end
                    if(isfield(plan{i}.spots(j),'duration'))
                      %Private tag Peak Dose Rate Delivered (300D,0021) is used to record the actual duration of the delivery
                      % This is usefull to record the peak dose rate of the PBS spot delivery
                      % Unit: Meterset/min
                      info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).PeakDoseRateDelivered = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).ScanSpotMetersetsDelivered ./ (plan{i}.spots(j).duration ./ 60); %Delivered dose rate in MU/min
                    end
                    if(isfield(plan{i}.spots(j),'gantry_angle'))
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{j}).GantryAngle = mean(plan{i}.spots(j).gantry_angle);
                    end
                end
            end

        else % modification of the number of beams - recreate ion control point sequences from scratch

            disp('Creating delivered ion control point structure from scratch.')

            % Set referenced plan
            myRefInfo = [];

            if(not(isfield(info.ReferencedRTPlanSequence.Item_1,'ReferencedSOPInstanceUID')))
                use_ref_IDs = 0;
                if(nargin>4)
                    if(isfield(input_header,'SOPInstanceUID') && isfield(input_header,'Modality'))
                        if(strcmp(input_header.Modality,'RTPLAN'))
                            use_ref_IDs = 1;
                            if(isfield(input_header,'IonBeamSequence'))
                                field_list = fieldnames(input_header.IonBeamSequence);
                                for j=1:length(field_list)
                                    if(strcmp(input_header.IonBeamSequence.(field_list{j}).BeamName,beam_delivered.BeamName))
                                        myRefInfo = input_header.IonBeamSequence.(field_list{j});
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                if(use_ref_IDs)
                    disp('Using ReferencedSOPInstanceUID from input_header')
                    info.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID = input_header.SOPInstanceUID;
                else
                    disp('Using random ReferencedSOPInstanceUID')
                    info.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID = dicomuid;
                end
            else
                disp('Keep existing ReferencedSOPInstanceUID')
            end

            beamFieldNames = cell(nb_fields,1);
            for i=1:nb_fields
                beamFieldNames{i} = ['Item_',num2str(i)];
            end
            default_ion_beam_sequence = info.TreatmentSessionIonBeamSequence.Item_1;
            info.TreatmentSessionIonBeamSequence = struct; % reset structure

            % Create ion beams
            for i=1:nb_fields
                nb_layers = length(plan{i}.spots);
                layerFieldNames = cell(nb_layers,1);
                for j=1:nb_layers
                    layerFieldNames{j} = ['Item_',num2str(j)];
                end
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}) = default_ion_beam_sequence;
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).ReferencedBeamNumber = i;
                if(isfield(plan{i},'name'))
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamName = plan{i}.name;
                else
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamName = num2str(i);
                end
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).NumberOfControlPoints = nb_layers;
                if(isfield(plan{i},'RangeShifters'))
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).NumberOfRangeShifters = length(plan{i}.RangeShifters);
                    for j=1:length(plan{i}.RangeShifters)
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RecordedRangeShifterSequence.(['Item_',num2str(j)]).ReferencedRangeShifterNumber = plan{i}.RangeShifters(j).RangeShifterNumber;
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).RecordedRangeShifterSequence.(['Item_',num2str(j)]).RangeShifterID = plan{i}.RangeShifters(j).RangeShifterID;
                    end
                end
                info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence = struct;
                for layer=1:nb_layers
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).NumberOfScanSpotPositions = length(plan{i}.spots(layer).weight);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).TreatmentControlPointDate = date;
                    if(isfield(plan{i}.spots(layer),'time'))
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).TreatmentControlPointTime = timestr_us(plan{i}.spots(layer).time(1));
                    else
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).TreatmentControlPointTime = timestr_us(0);
                    end
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).DeliveredMeterset = sum(plan{i}.spots(layer).weight);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotPositionMap = reshape(plan{i}.spots(layer).xy',size(plan{i}.spots(layer).xy,1)*2,1);
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotMetersetsDelivered = plan{i}.spots(layer).weight;
                    if(isfield(plan{i}.spots(layer),'time'))
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotTimeOffset = (plan{i}.spots(layer).time - plan{i}.spots(layer).time(1))*1e6;% in [us]
                    end
                    if(isfield(plan{i}.spots(layer),'duration'))
                      %Private tag Peak Dose Rate Delivered (300D,0021) is used to record the actual duration of the delivery
                      % This is usefull to record the peak dose rate of the PBS spot delivery
                      % Unit: Meterset/min
                      info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).PeakDoseRateDelivered = info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotMetersetsDelivered ./ (plan{i}.spots(layer).duration  ./ 60); %Delivered dose rate in MU/min
                    end
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).NumberOfPaintings = plan{i}.spots(layer).nb_paintings;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ReferencedControlPointIndex = layer;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).PatientSupportAngle = plan{i}.table_angle;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).NominalBeamEnergy = plan{i}.spots(layer).energy;
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).SpecifiedMeterset = [];
                    if(isfield(plan{i}.spots(1),'gantry_angle'))
                        gantry_angle_diff = mod(plan{i}.spots(j).gantry_angle(end)-plan{i}.spots(j).gantry_angle(1),360);
                        if(gantry_angle_diff==0)
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamType = 'STATIC';
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).GantryRotationDirection = 'NONE';
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).GantryAngle = plan{i}.spots(j).gantry_angle(1);
                        elseif(gantry_angle_diff<180)
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamType = 'DYNAMIC';
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).GantryRotationDirection = 'CW';
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).GantryAngle = mean(plan{i}.spots(j).gantry_angle);
                        elseif(gantry_angle_diff>=180)
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamType = 'DYNAMIC';
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).GantryRotationDirection = 'CC';
                            info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).GantryAngle = mean(plan{i}.spots(j).gantry_angle);
                        end
                    else
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).BeamType = 'STATIC';
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{1}).GantryRotationDirection = 'NONE';
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).GantryAngle = plan{i}.gantry_angle;
                    end
                    % RangeShifter
                    if(isfield(plan{i}.spots(j),'RangeShifterSetting'))
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).RangeShifterSettingsSequence.Item1.RangeShifterSetting = plan{i}.spots(j).RangeShifterSetting;
                    end
                    if(isfield(plan{i}.spots(j),'ReferencedRangeShifterNumber'))
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).RangeShifterSettingsSequence.Item1.ReferencedRangeShifterNumber = plan{i}.spots(j).ReferencedRangeShifterNumber;
                    end
                end
                if(not(isempty(myRefInfo)))
                    info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).ReferencedBeamNumber = myRefInfo.BeamNumber;
                    for layer=1:nb_layers
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ReferencedControlPointIndex = myRefInfo.IonControlPointSequence.(layerFieldNames{layer}).ControlPointIndex;
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).SpecifiedMeterset = sum(myRefInfo.IonControlPointSequence.(layerFieldNames{layer}).ScanSpotMetersetWeights);
                        info.TreatmentSessionIonBeamSequence.(beamFieldNames{i}).IonControlPointDeliverySequence.(layerFieldNames{layer}).ScanSpotTuneID = myRefInfo.IonControlPointSequence.(layerFieldNames{layer}).ScanSpotTuneID;
                    end
                end
            end

        end

        % Add tuning information if available
        if(isfield(plan{1}.spots(1),'tuning'))
            info.Private_3003_0011 = convert_tuning_spot_list(plan);% list tuning spots in json format
        end

        % Add gantry angle information for arc
        if(isfield(plan{i}.spots(1),'gantry_angle'))
            info.Private_3003_0013 = convert_gantry_angle_per_spot_list(plan);% list gantry angles per spot in json format
        end

        % Additional input dicom tags
        if(nargin>5)
            for i=1:size(input_tags,1)
                try
                    info.(input_tags{i,1}) = input_tags{i,2};
                catch
                    disp('error')
                end
            end
        end

        % Write output dicom file
        regguiPath = fileparts(which('reggui'));
        dictionary = fullfile(regguiPath ,'plugins','openMIROpt','functions','io','dicom-dict.txt');
        dicomdict('set',dictionary); %Load the DICOM dictionary with the private tags
        %dicomdict('set',fullfile(fileparts(mfilename('fullpath')),'dicom-dict-reggui.txt'));
        dicomwrite([], [strrep(outname,'.dcm',''),'.dcm'], info, 'WritePrivate', true, 'CreateMode', 'copy');
        dicomdict('factory');

    case 'csv'

        fid = fopen([outname,'.csv'],'w');
        fprintf(fid,['isocenter_x,',...
            'isocenter_y,',...
            'isocenter_z,',...
            'gantry_angle,',...
            'table_angle,',...
            'energy,',...
            'x,',...
            'y,',...
            'mu',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    fprintf(fid,[num2str(plan{f}.isocenter(1)),',',...
                        num2str(plan{f}.isocenter(2)),',',...
                        num2str(plan{f}.isocenter(3)),',',...
                        num2str(plan{f}.gantry_angle),',',...
                        num2str(plan{f}.table_angle),',',...
                        num2str(plan{f}.spots(j).energy),',',...
                        num2str(plan{f}.spots(j).xy(i,1)),',',...
                        num2str(plan{f}.spots(j).xy(i,2)),',',...
                        num2str(plan{f}.spots(j).weight(i)),endl]);
                end
            end
        end
        fclose(fid);

    case 'mcnpx'

        position_list = {};
        direction_list = {};
        energy_list = {''};
        weight_list = {''};
        for f=1:length(plan)
            isocenter = plan{f}.isocenter;
            gantry_angle = plan{f}.gantry_angle;
            table_angle = plan{f}.table_angle;
            for j=1:length(plan{f}.spots)
                nb_spots = length(plan{f}.spots(j).weight);
                pts_2D = plan{f}.spots(j).xy';
                [beam_z,beam_x,beam_y] = compute_beam_axis(gantry_angle,table_angle); % Components of the 3 axes of the IEC gantry CS expressed in the DICOM patient CS
                pt_source = isocenter - beam_z*2000; % Coordinate of the source in the DICOM patient CS
                pts_iso = repmat(isocenter,[1,nb_spots]) + repmat(pts_2D(1,:),[3,1]).*repmat(beam_x,[1,nb_spots]) + repmat(pts_2D(2,:),[3,1]).*repmat(beam_y,[1,nb_spots]);
                spot_dir = pts_iso - repmat(pt_source,[1,nb_spots]);
                spot_dir = spot_dir ./ sqrt( spot_dir(1,:).^2 + spot_dir(2,:).^2 + spot_dir(3,:).^2);
                spot_dir(abs(spot_dir)<1e-9)=0;
                spot_pos = pts_iso - 500*spot_dir;
                if(f==1 && j==1) % first element (no indent)
                    i1 = 2;
                    energy_list{1} = [num2str(plan{f}.spots(j).energy)];
                    weight_list{1} = [num2str(plan{f}.spots(j).weight(1))];
                    position_list{1} = [num2str(spot_pos(1,1)/10),' ',num2str(spot_pos(2,1)/10),' ',num2str(spot_pos(3,1)/10)];% in [cm]
                    direction_list{1} = [num2str(spot_dir(1,1)),' ',num2str(spot_dir(2,1)),' ',num2str(spot_dir(3,1))];
                else
                    i1 = 1;
                end
                for i=i1:nb_spots
                    if(length(energy_list{end})>70)
                        energy_list{end+1} = ['       ',num2str(plan{f}.spots(j).energy)];
                    else
                        energy_list{end} = [energy_list{end},' ',num2str(plan{f}.spots(j).energy)];
                    end
                    if(length(weight_list{end})>70)
                        weight_list{end+1} = ['       ',num2str(plan{f}.spots(j).weight(i))];
                    else
                        weight_list{end} = [weight_list{end},' ',num2str(plan{f}.spots(j).weight(i))];
                    end
                    position_list{end+1} = ['       ',num2str(spot_pos(1,i)/10),' ',num2str(spot_pos(2,i)/10),' ',num2str(spot_pos(3,i)/10)];% in [cm]
                    direction_list{end+1} = ['       ',num2str(spot_dir(1,i)),' ',num2str(spot_dir(2,i)),' ',num2str(spot_dir(3,i))];
                end
            end
        end

        % Export data
        outdir = outname;
        if(not(exist(outdir,'dir')))
            try
                mkdir(outdir)
            catch
                error('Could not create directory for MCNPX export. Abort')
            end
        end
        fid = fopen(fullfile(outdir,'energies.txt'),'w');
        for i=1:length(energy_list)
            fprintf(fid,[energy_list{i},endl]);
        end
        fclose(fid);
        fid = fopen(fullfile(outdir,'weights.txt'),'w');
        for i=1:length(weight_list)
            fprintf(fid,[weight_list{i},endl]);
        end
        fclose(fid);
        fid = fopen(fullfile(outdir,'position.txt'),'w');
        for i=1:length(position_list)
            fprintf(fid,[position_list{i},endl]);
        end
        fclose(fid);
        fid = fopen(fullfile(outdir,'direction.txt'),'w');
        for i=1:length(direction_list)
            fprintf(fid,[direction_list{i},endl]);
        end
        fclose(fid);

    case 'BLAK'

        fid = fopen([outname,'.txt'],'w');
        fprintf(fid,['[Angles]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    fprintf(fid,[num2str(plan{f}.gantry_angle),endl]);
                end
            end
        end
        fprintf(fid,[endl,'[Energies]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    fprintf(fid,[num2str(plan{f}.spots(j).energy),endl]);
                end
            end
        end
        fprintf(fid,[endl,'[MUs]',endl]);
        max_mu_per_spot = 100;
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    plan{f}.spots(j).nb_subspots(i) = ceil(plan{f}.spots(j).weight(i)/max_mu_per_spot);
                    for s=1:plan{f}.spots(j).nb_subspots(i)
                        if(s<plan{f}.spots(j).nb_subspots(i))
                            fprintf(fid,[num2str(plan{f}.spots(j).weight(i)/plan{f}.spots(j).nb_subspots(i)),',']);
                        else
                            fprintf(fid,[num2str(plan{f}.spots(j).weight(i)/plan{f}.spots(j).nb_subspots(i)),endl]);
                        end
                    end
                end
            end
        end
        fprintf(fid,[endl,'[X]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    for s=1:plan{f}.spots(j).nb_subspots(i)
                        if(s<plan{f}.spots(j).nb_subspots(i))
                            fprintf(fid,[num2str(plan{f}.spots(j).xy(i,1)),',']);
                        else
                            fprintf(fid,[num2str(plan{f}.spots(j).xy(i,1)),endl]);
                        end
                    end
                end
            end
        end
        fprintf(fid,[endl,'[Y]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    for s=1:plan{f}.spots(j).nb_subspots(i)
                        if(s<plan{f}.spots(j).nb_subspots(i))
                            fprintf(fid,[num2str(plan{f}.spots(j).xy(i,2)),',']);
                        else
                            fprintf(fid,[num2str(plan{f}.spots(j).xy(i,2)),endl]);
                        end
                    end
                end
            end
        end

        fclose(fid);

    case 'BLAK_MAP'

        fid = fopen([outname,'.txt'],'w');
        fprintf(fid,['[Angles]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                fprintf(fid,[num2str(plan{f}.gantry_angle),endl]);
            end
        end
        fprintf(fid,[endl,'[Energies]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                fprintf(fid,[num2str(plan{f}.spots(j).energy),endl]);
            end
        end
        fprintf(fid,[endl,'[MUs]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    if(i<length(plan{f}.spots(j).weight))
                        fprintf(fid,[num2str(plan{f}.spots(j).weight(i)),',']);
                    else
                        fprintf(fid,[num2str(plan{f}.spots(j).weight(i))]);
                    end
                end
                fprintf(fid,endl);
            end
        end
        fprintf(fid,[endl,'[X]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    if(i<length(plan{f}.spots(j).weight))
                        fprintf(fid,[num2str(plan{f}.spots(j).xy(i,1)),',']);
                    else
                        fprintf(fid,[num2str(plan{f}.spots(j).xy(i,1))]);
                    end
                end
                fprintf(fid,endl);
            end
        end
        fprintf(fid,[endl,'[Y]',endl]);
        for f=1:length(plan)
            for j=1:length(plan{f}.spots)
                for i=1:length(plan{f}.spots(j).weight)
                    if(i<length(plan{f}.spots(j).weight))
                        fprintf(fid,[num2str(plan{f}.spots(j).xy(i,2)),',']);
                    else
                        fprintf(fid,[num2str(plan{f}.spots(j).xy(i,2))]);
                    end
                end
                fprintf(fid,endl);
            end
        end

        fclose(fid);

    case 'dcm_impt2arc'

        % Get original dicom information or create default
        use_original_header = 0;
        if(isfield(plan_info,'OriginalHeader'))
            if(strcmp(plan_info.OriginalHeader.Modality,'RTPLAN'))
                use_original_header = 1;
            end
        end
        if(use_original_header)
            info = plan_info.OriginalHeader;
        else
            info = create_default_dicom_header('RTPLAN',plan_info);
        end

        % Replace patient dicom values from input_header (if any)
        if(nargin>4)
            field_list = {'PatientID','PatientName','PatientSex','PatientBirthDate'};
            for i=1:length(field_list)
                if(isfield(input_header,field_list{i}))
                    info.(field_list{i}) = input_header(field_list{i});
                end
            end
        end

        % Create dicom plan structure
        original_nb_fields = 0;
        if(isfield(info,'IonBeamSequence'))
            beamFieldNames = fieldnames(info.IonBeamSequence);
            for s=1:length(beamFieldNames)
                if(isfield(info.IonBeamSequence.(beamFieldNames{s}),'TreatmentDeliveryType'))
                    if(strcmp(info.IonBeamSequence.(beamFieldNames{s}).TreatmentDeliveryType,'TREATMENT'))
                        original_nb_fields = original_nb_fields+1;
                    end
                end
            end
        else
            beamFieldNames = {};
        end

        % look for global patient orientation
        correct_orientation = 'HFS';
        if(isfield(info,'PatientPosition') && isfield(info,'RTPlanGeometry'))
            if(strcmp(info.RTPlanGeometry,'PATIENT'))
                correct_orientation = info.PatientPosition;
            end
        elseif(isfield(info,'PatientSetupSequence'))
            correct_orientation = 'TBD_per_beam';
        end
        for i=1:nb_fields
            % correct for patient orientation
            if(strcmp(correct_orientation,'TBD_per_beam') && use_original_header)
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
                end
            elseif(strcmp(correct_orientation,'TBD_per_beam'))
                correct_orientation = 'HFS';
            else
                current_orientation = correct_orientation;
            end
            [plan{i}.gantry_angle,plan{i}.table_angle] = correct_beam_angles_for_orientation(plan{i}.gantry_angle,plan{i}.table_angle,current_orientation);
        end

        disp('Creating arc ion control point structure.')

        % Inititalize ion beam structure
        default_ion_beam_sequence = info.IonBeamSequence.Item_1;
        info.IonBeamSequence = struct; % reset structure

        % Compute number of arcs from gantry direction and table angle
        new_arc_indices = 1;
        for f=1:length(plan)
            if(f>2)
                r0 = plan{f}.gantry_angle-plan{f-1}.gantry_angle;
                r1 = plan{f-1}.gantry_angle-plan{f-2}.gantry_angle;
                if(abs(r0)>180)
                    r0 = -r0;
                end
                if(abs(r1)>180)
                    r1 = -r1;
                end
                if(sign(r0)~=sign(r1))
                    new_arc_indices(end+1) = f;
                end
            end
            if(f>1)
                if(plan{f}.table_angle~=plan{f-1}.table_angle)
                    new_arc_indices(end+1) = f;
                end
            end
        end
        new_arc_indices = unique(new_arc_indices);

        % Create Ion beams
        arc_index = 0;
        layer_index = 0;
        for i=1:nb_fields

            nb_layers = length(plan{i}.spots);

            if(sum(i==new_arc_indices))
                arc_index = arc_index+1;
                layer_index = 0;
                CumulativeMeterset = 0;
                arcName = ['Item_',num2str(arc_index)];
                info.IonBeamSequence.(arcName) = default_ion_beam_sequence;
                info.IonBeamSequence.(arcName).BeamNumber = arc_index;
                info.IonBeamSequence.(arcName).BeamName = ['arc',num2str(arc_index)];
                if(isfield(plan{i},'RangeShifters'))
                    info.IonBeamSequence.(arcName).NumberOfRangeShifters = length(plan{i}.RangeShifters);
                    for j=1:length(plan{i}.RangeShifters)
                        info.IonBeamSequence.(arcName).RangeShifterSequence.(['Item_',num2str(j)]) = plan{i}.RangeShifters(j);
                    end
                end
                info.IonBeamSequence.(arcName).IonControlPointSequence = struct;
                % Default beam geometry (on first control point)
                info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.BeamLimitingDeviceAngle = 0;
                info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.PatientSupportRotationDirection = 'NONE';
                info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.BeamLimitingDeviceRotationDirection = 'NONE';
                % Beam geometry (on first control point)
                info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.IsocenterPosition = plan{i}.isocenter;
                info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.PatientSupportAngle = plan{i}.table_angle;
                % SnoutPosition
                if(isfield(plan{i},'snout_position'))
                    info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.SnoutPosition = plan{i}.snout_position;
                end
                % Gantry direction
                if(length(plan)>i)
                    info.IonBeamSequence.(arcName).BeamType = 'DYNAMIC';
                    if(plan{i+1}.gantry_angle>plan{i}.gantry_angle)% CW or CC
                        info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.GantryRotationDirection = 'CW';
                    else
                        info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.GantryRotationDirection = 'CC';
                    end
                else
                    info.IonBeamSequence.(arcName).BeamType = 'STATIC';
                    info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.GantryRotationDirection = 'NONE';
                end
            end

            % Compute angle tolerance from previous and next angle
            if(i>1)
                previous_angle = plan{i-1}.gantry_angle;
            else
                previous_angle = Inf;
            end
            if(i<length(plan))
                next_angle = plan{i+1}.gantry_angle;
            else
                next_angle = Inf;
            end
            angle_tolerance = min(3,min(abs(plan{i}.gantry_angle-previous_angle),abs(plan{i}.gantry_angle-next_angle))/2);
            sub_tolerance = angle_tolerance/nb_layers;

            for j=1:nb_layers
                % Layer indices
                layer_index = layer_index+1;
                layerStartName = ['Item_',num2str(2*layer_index-1)];
                layerStopName = ['Item_',num2str(2*layer_index)];

                disp([num2str(plan{i}.gantry_angle),'°   ',arcName,'   ',layerStartName,' ',layerStopName])

                % ControlPointIndex
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).ControlPointIndex = 2*layer_index-1-1;
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).ControlPointIndex = 2*layer_index-1;
                % Gantry angle
                switch info.IonBeamSequence.(arcName).IonControlPointSequence.Item_1.GantryRotationDirection
                    case 'CW'
                        info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).GantryAngle = plan{i}.gantry_angle - angle_tolerance + (2*j-1)*sub_tolerance - sub_tolerance*2/3;
                        info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).GantryAngle = plan{i}.gantry_angle - angle_tolerance + (2*j-1)*sub_tolerance + sub_tolerance*2/3;
                    case 'CC'
                        info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).GantryAngle = plan{i}.gantry_angle - angle_tolerance + (2*j-1)*sub_tolerance + sub_tolerance*2/3;
                        info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).GantryAngle = plan{i}.gantry_angle - angle_tolerance + (2*j-1)*sub_tolerance - sub_tolerance*2/3;
                    otherwise
                        info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).GantryAngle = plan{i}.gantry_angle;
                        info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).GantryAngle = plan{i}.gantry_angle;
                end
                % NominalBeamEnergy
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).NominalBeamEnergy = plan{i}.spots(j).energy;
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).NominalBeamEnergy = plan{i}.spots(j).energy;
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).NominalBeamEnergyUnit = 'MEV';
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).NominalBeamEnergyUnit = 'MEV';
                % NumberOfScanSpotPositions
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).NumberOfScanSpotPositions = length(plan{i}.spots(j).weight);
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).NumberOfScanSpotPositions = length(plan{i}.spots(j).weight);
                % ScanSpotPositionMap
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).ScanSpotPositionMap = reshape(plan{i}.spots(j).xy',size(plan{i}.spots(j).xy,1)*2,1);
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).ScanSpotPositionMap = reshape(plan{i}.spots(j).xy',size(plan{i}.spots(j).xy,1)*2,1);
                % ScanSpotMetersetWeights
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).ScanSpotMetersetWeights = plan{i}.spots(j).weight * plan{i}.final_weight / plan{i}.BeamMeterset;
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).ScanSpotMetersetWeights = plan{i}.spots(j).weight * 0;
                % ScanningSpotSize
                if(isfield(plan{i}.spots(j),'spot_size'))
                    spot_size =  plan{i}.spots(j).spot_size;
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).ScanningSpotSize = spot_size;
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).ScanningSpotSize = spot_size;
                end
                % ScanSpotTuneID
                if(isfield(plan{i}.spots(j),'spot_tune_id'))
                    spot_tune_id =  plan{i}.spots(j).spot_tune_id;
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).ScanSpotTuneID = spot_tune_id;
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).ScanSpotTuneID = spot_tune_id;
                end
                % NumberOfPaintings
                if(isfield(plan{i}.spots(j),'nb_paintings'))
                    nb_paintings =  plan{i}.spots(j).nb_paintings;
                else
                    nb_paintings = 1;
                end
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).NumberOfPaintings = nb_paintings;
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).NumberOfPaintings = nb_paintings;
                % Number of paintings
                if(isfield(plan{i}.spots(j),'nb_paintings'))
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).NumberOfPaintings = plan{i}.spots(j).nb_paintings;
                end
                % CumulativeMetersetWeight
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).CumulativeMetersetWeight = CumulativeMeterset;
                CumulativeMeterset = CumulativeMeterset + sum(plan{i}.spots(j).weight);
                info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStopName).CumulativeMetersetWeight = CumulativeMeterset;
                % RangeShifter
                if(isfield(plan{i}.spots(j),'RangeShifterSetting'))
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).RangeShifterSettingsSequence.Item1.RangeShifterSetting = plan{i}.spots(j).RangeShifterSetting;
                end
                if(isfield(plan{i}.spots(j),'IsocenterToRangeShifterDistance'))
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).RangeShifterSettingsSequence.Item1.IsocenterToRangeShifterDistance = plan{i}.spots(j).IsocenterToRangeShifterDistance;
                end
                if(isfield(plan{i}.spots(j),'ReferencedRangeShifterNumber'))
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).RangeShifterSettingsSequence.Item1.ReferencedRangeShifterNumber = plan{i}.spots(j).ReferencedRangeShifterNumber;
                end
                if(isfield(plan{i}.spots(j),'RangeShifterWaterEquivalentThickness'))
                    info.IonBeamSequence.(arcName).IonControlPointSequence.(layerStartName).RangeShifterSettingsSequence.Item1.RangeShifterWaterEquivalentThickness = plan{i}.spots(j).RangeShifterWaterEquivalentThickness;
                end

            end

            if( sum((i+1)==new_arc_indices) || i==nb_fields)
                % Control point structure
                info.IonBeamSequence.(arcName).FinalCumulativeMetersetWeight = CumulativeMeterset;
                info.IonBeamSequence.(arcName).NumberOfControlPoints = layer_index*2;
                % Fill in fraction group sequence
                info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(arcName)=struct;
                info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(arcName).ReferencedBeamNumber = arc_index;
                info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(arcName).BeamMeterset = CumulativeMeterset;
            end

        end

        % Additional input dicom tags
        if(nargin>5)
            for i=1:size(input_tags,1)
                try
                    info.(input_tags{i,1}) = input_tags{i,2};
                catch
                end
            end
        end

        dicomwrite([], [strrep(outname,'.dcm',''),'.dcm'], info, 'WritePrivate', true, 'CreateMode', 'copy');

    otherwise
        error('Invalid type. Available output formats are: json, gate, pld and dcm.')

end
