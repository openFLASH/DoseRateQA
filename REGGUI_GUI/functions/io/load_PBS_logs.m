%% load_PBS_logs
% Read the PBS irradiation logs recorded by the data recorder
%
% Note that in the irradiation logs, the (X,Y) coordinate system is the PHYSICS coordinate system. The PHYSICS coordinate system is derived from the IEC-GATNRY CS by exchange of the X<->Y axes. The |load_PBS_logs| parse the logs and convert the spot coordinates to bring them back to the IEC gantry CS before outputing the result.
%
%% Syntax
% |records = load_PBS_logs(logFilename)|
%
% |records = load_PBS_logs(logFilename, outputDir)|
%
% |records = load_PBS_logs(logFilename, outputDir, xdr_converter)|
%
%% Description
% |records = load_PBS_logs(logFilename)| Read the PBS log using the default JAVA log converter and output text log files in current directory
%
% |records = load_PBS_logs(logFilename, outputDir)| Read the PBS log using the default JAVA log converter and output text log files in the specified directory
%
% |records = load_PBS_logs(logFilename, outputDir, xdr_converter)| Read the PBS logs using the specified JAVA log converter
%
%% Input arguments
% |logFilename| - _STRING_ - File name (including directory) of the file containing the data recorder PBS irradiation logs (in XDR format)
%
% |outputDir| - _STRING_ - [OPTIONAL. Default: current working directory] Directory in which the the text version of the PBS irradiation logs are saved
%
% |xdr_converter| - _STRING_ - [OPTIONAL] File name (including path) of the JAVA executable used to convert the irradiation logs from XDR format to text format. If absent, uses the default convertion program which should be stored in the folder 'externals' (which must be present in the Matlab path). Depending on the format of the log file (which defined by version number X.Y indicated at the end of the log file name), the function load_PBS_logs will search a file called 'data-recorder-proc-XXX-deploy.jar' where 'XXX' is a version number. The log file name must have the following format: YYYYMMDD_HHMMSS_NNN.PBS.X.Y.zip where YYYY is the year, MM the month, DD the day, HH the hour, MM the minutes, SS the seconds, NNN a serail number and X.Y the file format. If no JAVA executable is available, the function load_PBS_logs will not be able to read XDR file. It will only be able to process CSV files.
%
%% Output arguments
%
% |records| - _STRUCTURE_ - Record of the PBS spot measurements
%
% * |records{1}.spots(l).charge(s)| - _SCALAR_ - Measured electrical charge of the s-th spot of the l-th energy layer
% * |records{1}.spots(l).timeStart(s)| - _SCALAR_ - Time (in [us]) at the begining of the delivery of the s-th spot of the l-th energy layer
% * |records{1}.spots(l).timeStop(s)| - _SCALAR_ - Time (in [us]) at the end of the delivery of the s-th spot of the l-th energy layer
% * |records{1}.spots(l).xyIC(s,:)| - _SCALAR VECTOR_ - Average spot position (x,y) on the IC over the delivery of the s-th spot of the l-th energy layer. The coordinate system is IEC-GANTRY. The IC_Offset has already been corrected.
% * |records{1}.spots(l).nb_protons(s)| - _SCALAR_ - Number of proton in the s-th spot of the l-th energy layer
% * |records{1}.spots(l).IC_Offset(s,:)| - _SCALAR VECTOR_ - Offset (mm) of the IC coordinate system with respect to IECgantry for the s-th spot of the l-th energy layer
% * |records{1}.spots(l).SM_Offset(s,:)| - _SCALAR VECTOR_ - Offset (mm) of the SM coordinate system with respect to IECgantry for the s-th spot of the l-th energy layer
% * |records{1}.spots(l).xyConverted(s,:)| - _SCALAR VECTOR_ - Average spot position (x,y) at isocenter over the delivery of the s-th spot of the l-th energy layer. The coordinate system is IEC-GANTRY.
% * |records{1}.spots(l).MU(s)| - _SCALAR_ - MU of the s-th spot of the l-th energy layer
%
%
%% Contributors
% Authors : S.Puydupin, R.Labarbe, J.Petzhold, G.Janssens (open.reggui@gmail.com)

function [records,outputDir,sum_MU,events] = load_PBS_logs(logFilename, outputDir, xdr_converter, events_only)

warning('load_PBS_logs is deprecated. You should use load_IBA_logs instead.')

oneday = 8.6400e+10;
mGantryAngle = NaN;

% Default parameters
if(nargin<4)
    events_only = 0;
end
if(nargin<2)
    outputDir = '';
end
if(nargin<3)
    xdr_converter = '';
end

% Init records
records = cell(0);
records{1}.spots = [];
mGantryAngle = [];


% ------------------------------------
% Convert XDR files (only if output directory is still empty)
% ------------------------------------

[version,outputDir] = convert_logs_xdr(logFilename,outputDir,xdr_converter);


% ------------------------------------------
% Directory browsing and beam config reading
% ------------------------------------------

f = dir(outputDir);
brf_filename = '';
for i=1:1:size(f,1)
    if contains(f(i).name,'beam_config.') || contains(f(i).name,'idt_config.')
        config_filename = fullfile(outputDir,f(i).name);
        IC_gain = get_IC_gain(config_filename);
        IC_Offset_Beam = [0,0];%readICOffsetBeam(config_filename);
    end
    if ~(isempty(strfind(f(i).name,'beam.')))
        beam_filename = fullfile(outputDir,f(i).name);
        [mBeamId,mGantryAngle] = get_beam_info_from_log_beamfile(beam_filename);
        mGantryAngle = str2double(mGantryAngle); 
        records{1}.BeamName = mBeamId;
        records{1}.GantryAngle = mGantryAngle;
    end
    if(contains(f(i).name,'events') && contains(f(i).name,'.csv'))
        event_filename = fullfile(outputDir,f(i).name);
    end
    if(contains(f(i).name,'bmsResults') && contains(f(i).name,'.xml'))
        brf_filename = fullfile(outputDir,f(i).name);
    end
end


% ------------------------------------
% Read events
% ------------------------------------

if(nargout>3)
    try
        events = load_PBS_events(event_filename);
    catch
        disp('Warning: could not parse event file.');
        events.type = 'impt';
    end
    if(events_only)
        outputDir = [];
        sum_MU = [];
        return
    end
end


% ------------------------------------
% Read records
% ------------------------------------

% If brf file available, parse it and return
if(not(isempty(brf_filename)))
    [records,sum_MU] = load_BRF(brf_filename);
    records{1}.GantryAngle = mGantryAngle;
    
    % remove erroneous spots
    for layerIndex=1:length(records{1}.spots)
        records{1}.spots(layerIndex).spot_id = records{1}.spots(layerIndex).spot_id(records{1}.spots(layerIndex).MU>1e-3);
        records{1}.spots(layerIndex).xyConverted = records{1}.spots(layerIndex).xyConverted(records{1}.spots(layerIndex).MU>1e-3,:);
        records{1}.spots(layerIndex).timeStart = records{1}.spots(layerIndex).timeStart(records{1}.spots(layerIndex).MU>1e-3);
        records{1}.spots(layerIndex).timeStop = records{1}.spots(layerIndex).timeStop(records{1}.spots(layerIndex).MU>1e-3);
        records{1}.spots(layerIndex).MU = records{1}.spots(layerIndex).MU(records{1}.spots(layerIndex).MU>1e-3);
    end
    % merge tuning spots into delivered spots
    for layerIndex=1:length(records{1}.spots)
        records{1}.spots(layerIndex).tuning = records{1}.spots(layerIndex).MU * 0;
        if length(records{1}.spots(layerIndex).MU)>1
            tuning_time = (records{1}.spots(layerIndex).timeStart(2) - records{1}.spots(layerIndex).timeStart(1))*1e-3;% in ms
            while(records{1}.spots(layerIndex).MU(1)<0.1 && tuning_time>100)
                % Add tuning charge to closest spot
                A = records{1}.spots(layerIndex).xyConverted(2:end,:);
                B = records{1}.spots(layerIndex).xyConverted(1,:);
                D = sqrt(sum(A.^2,2)*ones(1,size(B,1)) + ones(size(A,1),1)*sum(B.^2,2)'-2.*A*B');
                [distance_to_spot,index] = min(D);
                index = index+1;
                if(distance_to_spot<2)
                    records{1}.spots(layerIndex).tuning(index,1) = (records{1}.spots(layerIndex).MU(1,1) + records{1}.spots(layerIndex).tuning(index,1)*records{1}.spots(layerIndex).MU(index,1)) / (records{1}.spots(layerIndex).MU(1,1) + records{1}.spots(layerIndex).MU(index,1)) ; % compute ratio of MU used for tuning
                    records{1}.spots(layerIndex).MU(index,1) = records{1}.spots(layerIndex).MU(index,1) + records{1}.spots(layerIndex).MU(1,1); % add tuning MU to corresponding spot
                    records{1}.spots(layerIndex).timeTuning = tuning_time;
                    % remove tuning
                    records{1}.spots(layerIndex).spot_id = records{1}.spots(layerIndex).spot_id(2:end);
                    records{1}.spots(layerIndex).xyConverted = records{1}.spots(layerIndex).xyConverted(2:end,:);
                    records{1}.spots(layerIndex).MU = records{1}.spots(layerIndex).MU(2:end);
                    records{1}.spots(layerIndex).timeStart = records{1}.spots(layerIndex).timeStart(2:end);
                    records{1}.spots(layerIndex).timeStop = records{1}.spots(layerIndex).timeStop(2:end);
                    % check if another tuning follows
                    tuning_time = (records{1}.spots(layerIndex).timeStart(2) - records{1}.spots(layerIndex).timeStart(2))*1e-3;% in ms
                else % spot fully delivered in tuning
                    records{1}.spots(layerIndex).timeTuning = tuning_time;
                    records{1}.spots(layerIndex).tuning(1) = 1;
                    break
                end
            end
        elseif(records{1}.spots(layerIndex).MU<0.1) % only tuning
            records{1}.spots(layerIndex).tuning = 1;
        end
    end
    
    disp(['Total MUs delivered = ',num2str(sum_MU)]);
    return
end



machine = '';
lastSpecifFilename = [];
lastLayerNb = -1;
firstlayerNb = -1;

for i=1:1:size(f,1)
    
    if ~(isempty(strfind(f(i).name,'map_record'))) && (isempty(strfind(f(i).name,'tuning')) && isempty(strfind(f(i).name,'events')) && not(strcmp(f(i).name(1),'.'))) % C230
        machine = 'C230';
        fileNameType = isstrprop(f(i).name,'alpha');
        tokens = strsplit(f(i).name,'_');
        if fileNameType(1) % old filename format: map_record_000_part_01.20180101_121530_000
            tokenItem = 3;
        else
            tokenItem = 5; % new filename format: 20180101_121530_000.map_record_001_part_01
        end
        layerNb = strsplit(tokens{1,tokenItem},'.');
        layerNb = str2double(layerNb{1,1});
        if(firstlayerNb==-1)
            firstlayerNb = layerNb;
        end
        layerNb = layerNb - firstlayerNb +1;
        if (layerNb == lastLayerNb)
            specif_filename = lastSpecifFilename;
            disp(['Detected splitted layer (' num2str(layerNb) '). Will be merged in output struture']);
        else
            specif_filename = fullfile(outputDir,strrep(f(i).name,'map_record_','map_specif_'));
            lastSpecifFilename = specif_filename;
        end
        lastLayerNb = layerNb;
        
        disp(['Processing Specif file: ' specif_filename]);
        [range,layer_id] = readRangeSpecif(specif_filename);
        [IC_Offset,SM_Offset] = readOffsetFromSpecif(specif_filename);
        IC_Offset = IC_Offset - IC_Offset_Beam;
        % added 21/06/2018 by Johannes Petzoldt: checks that the spots in the spot IDs in the specif file are incrementing by 1, i.e. that no spot was left out. The variable is used as input in the readRecord function (see below)
        AllSpotsExisting = 1;
        index = strfind(specif_filename,'map_specif_');
        specif_prefix = specif_filename(index:index+13);
        tuning_specif_filename = '';
        for j=1:1:size(f,1)
            if ~(isempty(strfind(f(j).name,specif_prefix))) && contains(f(j).name,'tuning')
                tuning_specif_filename = fullfile(outputDir,f(j).name);
            end
        end
        if(not(isempty(tuning_specif_filename)))
            AllSpotsExisting = CheckSpotIDs(specif_filename,tuning_specif_filename);
        end
        
        record_filename = fullfile(outputDir,f(i).name);
        disp(['Processing Record file: ' record_filename]);
        
        records = readRecord(version,record_filename,records,layerNb,IC_gain,layer_id,range,SM_Offset,IC_Offset,AllSpotsExisting);
        
    elseif ~(isempty(strfind(f(i).name,'burst_record'))) && (isempty(strfind(f(i).name,'tuning')) && isempty(strfind(f(i).name,'events'))  && not(strcmp(f(i).name(1),'.'))) % S2C2
        machine = 'S2C2';
        f_name = f(i).name;
        f_name = f_name(strfind(f_name,'burst_record')+13:end);
        tokens = strsplit(f_name,'_');
        layerNb = 0;
        for j=1:length(tokens)
            temp = strsplit(tokens{j},'.');
            temp = str2double(temp{1,1});
            if(not(isnan(temp)))
                layerNb = layerNb+temp*10^(-3*(j-1));
            else
                break
            end
        end
        if(firstlayerNb==-1)
            firstlayerNb = layerNb;
        end
        layerNb = layerNb - firstlayerNb +1;
        lastLayerNb = layerNb;
        
        specif_filename = fullfile(outputDir,strrep(f(i).name,'burst_record_','burst_specif_'));
        disp(['Processing Specif file: ' specif_filename]);
        [range,layer_id] = readRangeSpecif(specif_filename);
        [IC_Offset,SM_Offset] = readOffsetFromSpecifS2C2(specif_filename);
        IC_Offset = IC_Offset - IC_Offset_Beam;
        
        record_filename = fullfile(outputDir,f(i).name);
        disp(['Processing Record file: ' record_filename]);
        
        records = readRecordS2C2(version,record_filename,records,layerNb,IC_gain,layer_id,range,SM_Offset,IC_Offset);
        
    end
end


% ------------------------------------
% Read tuning spot
% ------------------------------------

for i=1:1:size(f,1)
    % Update list of layers
    for j=1:length(records{1}.spots)
        layer_list(j) = records{1}.spots(j).layer;
    end
    % Read tuning file
    if ~(isempty(strfind(f(i).name,'map_record'))) && ~(isempty(strfind(f(i).name,'tuning')) && not(strcmp(f(i).name(1),'.')))
        
        tuning_filename = fullfile(outputDir,f(i).name);
        fileNameType = isstrprop(f(i).name,'alpha');
        tokens = strsplit(f(i).name,'_');
        if fileNameType(1) % old filename format: map_record_000_part_01.20181210_145428_068
            tokenItem=3;
        else
            tokenItem=5;   % new filename format: 20181210_142547_315.map_record_001_part_01
        end
        layerNb = strsplit(tokens{1,tokenItem},'.');
        layerNb = str2double(layerNb{1,1});
        layerNb = layerNb - firstlayerNb +1;
        layerIndex = find(layer_list==layerNb,1);
        
        if(isempty(layerIndex)) % case where layer is only tuning
            layerIndex = find(layer_list==layerNb+1,1);
            layerRefIndex = layerIndex+1;
            if(isempty(layerIndex))
                if(layerNb>max(layer_list))
                    layerIndex = length(layer_list)+1;
                    layerRefIndex = layerIndex-1;
                else
                    layerIndex = 1;
                end
            end
            specif_filename = strrep(tuning_filename,'map_record_','map_specif_');
            disp(['Processing Specif file: ' specif_filename]);
            [IC_Offset,SM_Offset] = readOffsetFromSpecif(specif_filename);
            IC_Offset = IC_Offset - IC_Offset_Beam;
            records{1}.spots(layerIndex+1:end+1) = records{1}.spots(layerIndex:end);
            records{1}.spots(layerIndex).layer = layerNb;
            [range,layer_id] = readRangeSpecif(specif_filename);
            records{1}.spots(layerIndex).layer_id = layer_id+1;
            records{1}.spots(layerIndex).range = range;
            records{1}.spots(layerIndex).date = records{1}.spots(layerRefIndex).date;
            records{1}.spots(layerIndex).spot_id = NaN;
            records{1}.spots(layerIndex).charge = NaN;
            records{1}.spots(layerIndex).timeStart = NaN;
            records{1}.spots(layerIndex).timeStop = NaN;
            records{1}.spots(layerIndex).xyIC = [NaN,NaN];
            records{1}.spots(layerIndex).SM_Offset = SM_Offset;
            records{1}.spots(layerIndex).IC_Offset = IC_Offset;
            records{1}.spots(layerIndex).nb_protons = NaN;
            records{1}.spots(layerIndex).tuning = 1;
        end
        
        tuning = readRecord(version,tuning_filename,[],1,IC_gain,records{1}.spots(layerIndex).layer_id(1),records{1}.spots(layerIndex).range(1),SM_Offset,IC_Offset,1);
        
        if(isempty(tuning))
            continue
        end
        
    elseif ~(isempty(strfind(f(i).name,'burst_record'))) && ~(isempty(strfind(f(i).name,'tuning')) && not(strcmp(f(i).name(1),'.')))
        
        tuning_filename = fullfile(outputDir,f(i).name);
        f_name = f(i).name;
        f_name = f_name(strfind(f_name,'burst_record')+13:end);
        tokens = strsplit(f_name,'_');
        layerNb = 0;
        for j=1:length(tokens)
            temp = strsplit(tokens{j},'.');
            temp = str2double(temp{1,1});
            if(not(isnan(temp)))
                layerNb = layerNb+temp*10^(-3*(j-1));
            else
                break
            end
        end
        if(firstlayerNb==-1)
            firstlayerNb = layerNb;
        end
        layerNb = layerNb - firstlayerNb +1;
        lastLayerNb = layerNb;
        layerIndex = find(layer_list==layerNb,1);
        
        if(isempty(layerIndex)) % case where layer is only tuning
            layerIndex = find(layer_list==layerNb+1,1);
            if(isempty(layerIndex))
                layerIndex = 1;
            end
            specif_filename = strrep(tuning_filename,'burst_record_','burst_specif_');
            disp(['Processing Specif file: ' specif_filename]);
            [IC_Offset,SM_Offset] = readOffsetFromSpecif(specif_filename);
            IC_Offset = IC_Offset - IC_Offset_Beam;
            records{1}.spots(layerIndex+1:end+1) = records{1}.spots(layerIndex:end);
            records{1}.spots(layerIndex).layer = layerNb;
            [range,layer_id] = readRangeSpecif(specif_filename);
            records{1}.spots(layerIndex).layer_id = layer_id;
            records{1}.spots(layerIndex).range = range;
            records{1}.spots(layerIndex).date = records{1}.spots(layerIndex+1).date;
            records{1}.spots(layerIndex).spot_id = NaN;
            records{1}.spots(layerIndex).charge = NaN;
            records{1}.spots(layerIndex).timeStart = NaN;
            records{1}.spots(layerIndex).timeStop = NaN;
            records{1}.spots(layerIndex).xyIC = [NaN,NaN];
            records{1}.spots(layerIndex).SM_Offset = SM_Offset;
            records{1}.spots(layerIndex).IC_Offset = IC_Offset;
            records{1}.spots(layerIndex).nb_protons = NaN;
            records{1}.spots(layerIndex).tuning = 1;
        end
        
        tuning = readRecordS2C2(version,tuning_filename,[],1,IC_gain,records{1}.spots(layerIndex).layer_id(1),records{1}.spots(layerIndex).range(1),SM_Offset,IC_Offset);
        
        if(isempty(tuning))
            continue
        end
        
    else
        
        continue
        
    end
    
    %find, in the next layer, the closest spot to the tuning spot
    if(not(isempty(layerIndex))) % Checks that # of tuning layers is <= record layers (for the case of layer with 1 spot that is already delivered as tuning spot)
        % checks if first charge entry is NaN -> this would be the case if spot is not in records but already delivered in tuning (checked with CheckSpotIDs)
        % If == NaN -> overwrite first line in records with tuning information
        if(isnan(records{1}.spots(layerIndex).charge(1,1)))
            records{1}.spots(layerIndex).layer_id = tuning{1}.spots(1).layer_id;
            records{1}.spots(layerIndex).range = tuning{1}.spots(1).range;
            records{1}.spots(layerIndex).charge(1,1) = tuning{1}.spots(1).charge(end,1);
            records{1}.spots(layerIndex).timeStart(1,1) = tuning{1}.spots(1).timeStart(end,1);
            records{1}.spots(layerIndex).timeStop(1,1) = tuning{1}.spots(1).timeStop(end,1);
            records{1}.spots(layerIndex).xyIC(1,:) = tuning{1}.spots(1).xyIC(end,:);
            records{1}.spots(layerIndex).IC_Offset(1,:) = tuning{1}.spots(1).IC_Offset(end,:);
            records{1}.spots(layerIndex).nb_protons(1,1) = tuning{1}.spots(1).nb_protons(end,1);
            records{1}.spots(layerIndex).tuning(1,1) = 1;
            if(length(records{1}.spots(layerIndex).spot_id)>1)
                records{1}.spots(layerIndex).timeTuning = mod(records{1}.spots(layerIndex).timeStart(2) - records{1}.spots(layerIndex).timeStart(1),oneday);
            else
                records{1}.spots(layerIndex).timeTuning = 0;
            end
        else
            A = records{1}.spots(layerIndex).xyIC;
            try
                B = tuning{1}.spots(1).xyIC(end,:);
                D = sum(A.^2,2)*ones(1,size(B,1)) + ones(size(A,1),1)*sum(B.^2,2)'-2.*A*B';
                [~,index] = min(D);
                records{1}.spots(layerIndex).tuning(index,1) = (tuning{1}.spots(1).charge(end,1) + records{1}.spots(layerIndex).tuning(index,1)*records{1}.spots(layerIndex).charge(index,1)) / (tuning{1}.spots(1).charge(end,1) + records{1}.spots(layerIndex).charge(index,1)) ; % compute ratio of charge used for tuning
                records{1}.spots(layerIndex).charge(index,1) = records{1}.spots(layerIndex).charge(index,1) + tuning{1}.spots(1).charge(end,1); % add tuning charge to records
                time_temp = mod(records{1}.spots(layerIndex).timeStart(1) - tuning{1}.spots(1).timeStart(1),oneday);
                if(time_temp>oneday/2)
                    time_temp = 0;
                end
                if(isfield(records{1}.spots(layerIndex),'timeTuning'))
                    if(not(records{1}.spots(layerIndex).timeTuning>time_temp))
                        records{1}.spots(layerIndex).timeTuning = time_temp;
                    elseif(isempty(records{1}.spots(layerIndex).timeTuning))
                        records{1}.spots(layerIndex).timeTuning = time_temp;
                    end
                end
            catch % xy was not retrieved from tuning (not enough signal to be seen on ICs)
                disp('WARNING: Not enough signal from tuning. Ignore tuning spot.')
                records{1}.spots(layerIndex).timeTuning = 0;
            end
        end
    elseif(layerNb > lastLayerNb) % Case of layer with 1 spot that is delivered as tuning -> as no record file is available, tuning is written in record file
        records{1}.spots(layerIndex) = tuning{1}.spots(1);
        records{1}.spots(layerIndex).tuning = 1;
        records{1}.spots(layerIndex).timeTuning = 0;
    end
    
end


% ------------------------------------
% Convert raw data from logs
% ------------------------------------

% Beam reading
f = dir(outputDir);
for i=1:1:size(f,1)
    if ~(isempty(strfind(f(i).name,'beam'))) && isempty(strfind(f(i).name,'beam_config')) && isempty(strfind(f(i).name,'idt_config')) && (isempty(strfind(f(i).name,'beam_settings')))
        beam_filename = fullfile(outputDir,f(i).name);
        CorrectionFactor = calculate_CorrectionFactor(beam_filename);
    end
end

sum_MU = 0;

switch machine
    
    case 'C230'
        
        % Beam_config reading
        f = dir(outputDir);
        for i=1:1:size(f,1)
            if ~(isempty(strfind(f(i).name,'beam_config'))) || ~(isempty(strfind(f(i).name,'idt_config')))
                config_filename = fullfile(outputDir,f(i).name);
                DistICtoISO = readDistICtoISO(config_filename);
                SAD = readSAD(config_filename);
                chargePerMUIC2 = readchargePerMUIC2(config_filename);
                roomType=readRoomType(config_filename);
            end
        end
        
        % Convert raw data
        nb_layers = length(records{1}.spots);
        for layer=1:nb_layers
            % nb_spots = length(records{1}.spots(layer).charge);
            % using log and beam config info
            if strcmp(roomType,'GTR')
                records{1}.spots(layer).xyConverted(:,1) =  records{1}.spots(layer).xyIC(:,1).*(SAD(1)/(SAD(1) - DistICtoISO(1))); %already inverted SAD and DistIC
                records{1}.spots(layer).xyConverted(:,2) =  records{1}.spots(layer).xyIC(:,2).*(SAD(2)/(SAD(2) - DistICtoISO(2)));
                
            else  %% shreveport case
                records{1}.spots(layer).xyConverted(:,1) =  -records{1}.spots(layer).SM_Offset(:,1) + records{1}.spots(layer).xyIC(:,1).*(SAD(1)/(SAD(1) - DistICtoISO(1))); %already inverted SAD and DistIC
                records{1}.spots(layer).xyConverted(:,2) =  -records{1}.spots(layer).SM_Offset(:,2) + records{1}.spots(layer).xyIC(:,2).*(SAD(2)/(SAD(2) - DistICtoISO(2)));
            end
            % charge from logs
            if(sum(records{1}.spots(layer).charge<0))
                disp(['Warning: ',num2str(sum(records{1}.spots(layer).charge<0)),' spots (out of ',num2str(length(records{1}.spots(layer).charge)),') with negative charge in layer ',num2str(records{1}.spots(layer).layer)])
            end
            records{1}.spots(layer).charge(records{1}.spots(layer).charge<0)=0;
            records{1}.spots(layer).MU = records{1}.spots(layer).charge/(chargePerMUIC2*CorrectionFactor);
            sum_MU = sum_MU + sum(records{1}.spots(layer).MU);
            
        end %layer loop
        
    case 'S2C2'
        
        % Beam_config reading
        f = dir(outputDir);
        for i=1:1:size(f,1)
            if ~(isempty(strfind(f(i).name,'beam_config'))) || ~(isempty(strfind(f(i).name,'idt_config')))
                config_filename = fullfile(outputDir,f(i).name);
                DistICtoISO = readDistICtoISO(config_filename);
                chargePerMUIC2 = readchargePerMUIC2(config_filename);
            end
        end
        
        % Convert raw data
        nb_layers = length(records{1}.spots);
        for layer=1:nb_layers
            
            % Remove negatively charged spots
            if(sum(records{1}.spots(layer).charge<0))
                disp(['Warning: ',num2str(sum(records{1}.spots(layer).charge<0)),' spots (out of ',num2str(length(records{1}.spots(layer).charge)),') with negative charge in layer ',num2str(records{1}.spots(layer).layer),' (burst ',num2str(layer),'). Remove.'])
            end
            records{1}.spots(layer).spot_id = records{1}.spots(layer).spot_id(records{1}.spots(layer).charge>0);
            records{1}.spots(layer).xyIC = records{1}.spots(layer).xyIC(records{1}.spots(layer).charge>0,:);
            records{1}.spots(layer).SM_Offset = records{1}.spots(layer).SM_Offset(records{1}.spots(layer).charge>0,:);
            records{1}.spots(layer).IC_Offset = records{1}.spots(layer).IC_Offset(records{1}.spots(layer).charge>0,:);
            records{1}.spots(layer).nb_protons = records{1}.spots(layer).nb_protons(records{1}.spots(layer).charge>0);
            records{1}.spots(layer).tuning = records{1}.spots(layer).tuning(records{1}.spots(layer).charge>0);
            records{1}.spots(layer).timeStart = records{1}.spots(layer).timeStart(records{1}.spots(layer).charge>0);
            records{1}.spots(layer).timeStop = records{1}.spots(layer).timeStop(records{1}.spots(layer).charge>0);
            records{1}.spots(layer).charge = records{1}.spots(layer).charge(records{1}.spots(layer).charge>0);
            
            % Project on isocenter plane using formula: -SMOffset + (Position_IC ? ICOffset)*SAD_IC/(SAD_IC ? distanceFromICtoIso)
            SAD = readSAD_S2C2(config_filename,records{1}.spots(layer).xyIC(:,1),records{1}.spots(layer).xyIC(:,2));
            records{1}.spots(layer).xyConverted(:,1) = -records{1}.spots(layer).SM_Offset(:,1) + records{1}.spots(layer).xyIC(:,1).*(SAD(:,1)./(SAD(:,1) - DistICtoISO(1))); %already inverted SAD and DistIC
            records{1}.spots(layer).xyConverted(:,2) = -records{1}.spots(layer).SM_Offset(:,2) + records{1}.spots(layer).xyIC(:,2).*(SAD(:,2)./(SAD(:,2) - DistICtoISO(2)));
            if(max(abs(records{1}.spots(layer).xyConverted(:)))>125)
                disp(['Warning: unexpected spot position (',num2str(max(abs(records{1}.spots(layer).xyConverted(:)))),' mm) in layer ',num2str(records{1}.spots(layer).layer),' (burst ',num2str(layer),')']);
            end
            
            % Convert charge to MUs
            records{1}.spots(layer).MU = records{1}.spots(layer).charge/(chargePerMUIC2*CorrectionFactor);
            sum_MU = sum_MU + sum(records{1}.spots(layer).MU);
            
        end %layer loop
        
end

disp(['Total MUs delivered = ',num2str(sum_MU)]);

% correct layer numbering
layerNb = 0;
current_layerNb = 0;
for i=1:length(records{1}.spots)
    if(not(records{1}.spots(i).layer == current_layerNb))
        layerNb = layerNb+1;
    end
    current_layerNb = records{1}.spots(i).layer;
    records{1}.spots(i).layer = layerNb;
end


end %function


% ----------------------------------------------------------------------
function [range,layer_id] = readRangeSpecif(fileName)

% Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,',RANGE,'))
        params = fgetl(fid);
        eval(['params = [',params,'];']);
        layer_id = params(1);
        range = params(2);
        break
    end
end
fclose(fid);

end

% ----------------------------------------------------------------------
function [IC_Offset,SM_Offset] = readOffsetFromSpecif(fileName)

IC_Offset=[0,0];
SM_Offset=[0,0];

% Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,',[ICX_OFFSET],'))
        params = fgetl(fid);
        eval(['params = [',params,'];'])
        % Extract IC offset
        IC_OffsetX = params(3);
        IC_OffsetY = params(4);
        IC_Offset = [IC_OffsetY,IC_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        % Extract SM offset
        SM_OffsetX = params(1);
        SM_OffsetY = params(2);
        SM_Offset = [SM_OffsetY,SM_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        break
    elseif(contains(tline,',ICX_OFFSET,'))
        txt = fgetl(fid);
        % Extract IC offset
        colx = find_csv_column(tline,'ICX_OFFSET');
        coly = find_csv_column(tline,'ICY_OFFSET');
        IC_OffsetX = get_csv_data(txt,colx);
        IC_OffsetY = get_csv_data(txt,coly);
        IC_Offset = [IC_OffsetY,IC_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        % Extract SM offset
        colx = find_csv_column(tline,'SMX_OFFSET');
        coly = find_csv_column(tline,'SMY_OFFSET');
        SM_OffsetX = get_csv_data(txt,colx);
        SM_OffsetY = get_csv_data(txt,coly);
        SM_Offset = [SM_OffsetY,SM_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        break
        
    elseif(contains(tline,',IC2X_OFFSET,'))
        txt = fgetl(fid);
        % Extract IC offset
        colx = find_csv_column(tline,'IC2X_OFFSET');
        coly = find_csv_column(tline,'IC2Y_OFFSET');
        IC_OffsetX = get_csv_data(txt,colx);
        IC_OffsetY = get_csv_data(txt,coly);
        IC_Offset = [IC_OffsetY,IC_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        % Extract SM offset
        colx = find_csv_column(tline,'SMX_OFFSET');
        coly = find_csv_column(tline,'SMY_OFFSET');
        SM_OffsetX = get_csv_data(txt,colx);
        SM_OffsetY = get_csv_data(txt,coly);
        SM_Offset = [SM_OffsetY,SM_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        break
        
        
    end
end
fclose(fid);

end


% ----------------------------------------------------------------------
function [IC_Offset,SM_Offset] = readOffsetFromSpecifS2C2(fileName)

% Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,',ICX_OFFSET,'))
        txt = fgetl(fid);
        % Extract IC offset
        colx = find_csv_column(tline,'ICX_OFFSET');
        coly = find_csv_column(tline,'ICY_OFFSET');
        IC_OffsetX = get_csv_data(txt,colx);
        IC_OffsetY = get_csv_data(txt,coly);
        IC_Offset = [IC_OffsetY,IC_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        % Extract SM offset
        colx = find_csv_column(tline,'SMX_OFFSET');
        coly = find_csv_column(tline,'SMY_OFFSET');
        SM_OffsetX = get_csv_data(txt,colx);
        SM_OffsetY = get_csv_data(txt,coly);
        SM_Offset = [SM_OffsetY,SM_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        break
    elseif(contains(tline,',IC2X_OFFSET,'))
        txt = fgetl(fid);
        % Extract IC offset
        colx = find_csv_column(tline,'IC2X_OFFSET');
        coly = find_csv_column(tline,'IC2Y_OFFSET');
        IC_OffsetX = get_csv_data(txt,colx);
        IC_OffsetY = get_csv_data(txt,coly);
        IC_Offset = [IC_OffsetY,IC_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        % Extract SM offset
        colx = find_csv_column(tline,'SMX_OFFSET');
        coly = find_csv_column(tline,'SMY_OFFSET');
        SM_OffsetX = get_csv_data(txt,colx);
        SM_OffsetY = get_csv_data(txt,coly);
        SM_Offset = [SM_OffsetY,SM_OffsetX]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        break
    end
end
fclose(fid);

end


% ----------------------------------------------------------------------
function records = readRecord(version,fileName,records,layerNb,IC_gain,layer_id,range,SM_Offset,IC_Offset,includeTuning,fpga_bits)

charge_thr = 2e-12;
if(nargin<11)
    fpga_bits = 23;
end
if(isempty(records))
    records = cell(0);
    records{1}.spots = [];
end

use_old_format = 1;
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    end
    if(contains(tline,'FPGA_COUNT'))
        use_old_format = 0;
        break
    end    
end
fclose(fid);

if(not(use_old_format))
    
    % Parameters of log file format
    delimiter = ',';
    startRow = 1;
    start_irradiation = 0;
    date_irradiation = '';
    fid = fopen(fileName,'r');
    while 1
        startRow = startRow + 1;
        tline = fgetl(fid);
        if ~ischar(tline)
            break
        elseif(contains(tline,'START_IRRADIATION'))
            colStart = find_csv_column(tline,'START_IRRADIATION');
            tline = fgetl(fid);
            [start_irradiation,date_irradiation] = timeConverter(get_csv_data(tline,colStart),'dekimo');
        elseif(contains(tline,'#ELEMENT_ID'))
            numCols = length(strfind(tline,delimiter))+1;
            colElementID = find_csv_column(tline,'#ELEMENT_ID');
            colID = find_csv_column(tline,'SPOT_ID');
            colTime = find_csv_column(tline,'FPGA_COUNT');
            colXPos = find_csv_column(tline,'PRIM_IC_X_POSITION');
            colYPos = find_csv_column(tline,'PRIM_IC_Y_POSITION');
            colCharge = find_csv_column(tline,'PRIM_IC_CHARGE');
            
            % Prepare format spec
            formatSpec = '%f%s';
            for i=1:numCols-2
                formatSpec = [formatSpec,'%f'];
            end
            formatSpec = [formatSpec,'%[^\n\r]'];
            
            break
        elseif contains(tline,'SUBMAP_NUMBER')
            numCols = length(strfind(tline,delimiter))+1;
            %not sure about correspondace btw element id and dekimoe elemnt ID
            colElementID = find_csv_column(tline,'DEKIMO_ELEMENT_ID');
            colID = find_csv_column(tline,'SPOT_ID');
            colTime = find_csv_column(tline,'FPGA_COUNT');
            colXPos = find_csv_column(tline,'X_POSITION(mm)');
            colYPos = find_csv_column(tline,'Y_POSITION(mm)');
            colCharge = find_csv_column(tline,'DOSE_PRIM(C)');
            
            %Prepare format spec
            formatSpec = '%f%f%f%s';
            for i=1:numCols-4
                formatSpec = [formatSpec,'%f'];
            end
            formatSpec = [formatSpec,'%[^\n\r]'];
            
            break
        end
    end
    fclose(fid);
    
    % Read file
    fid = fopen(fileName,'r');
    log = textscan(fid,formatSpec,'Delimiter',delimiter,'EmptyValue',NaN,'HeaderLines',startRow,'ReturnOnError',true);
    fclose(fid);
    
    IDs = unique(log{colID}(log{colID}>0));
    
    if(not(isempty(IDs)))
        records{1}.spots(end+1).layer = layerNb;
        records{1}.spots(end).layer_id = layer_id+1;
        records{1}.spots(end).range = range;
        records{1}.spots(end).date = date_irradiation;
        
        for i=1:length(IDs)
            current_charge = log{colCharge}(log{colID}==IDs(i) & log{colElementID}>0);
            current_fpga_time = log{colTime}(log{colID}==IDs(i) & log{colElementID}>0);
            current_x = log{colXPos}(log{colID}==IDs(i) & log{colElementID}>0);
            current_y = log{colYPos}(log{colID}==IDs(i) & log{colElementID}>0);
            records{1}.spots(end).spot_id(i,1) = IDs(i);
            records{1}.spots(end).charge(i,1) = sum(current_charge);
            records{1}.spots(end).xyIC(i,:) = [current_y(end),current_x(end)] - IC_Offset; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
            records{1}.spots(end).SM_Offset(i,:) = SM_Offset;
            records{1}.spots(end).IC_Offset(i,:) = IC_Offset;
            records{1}.spots(end).nb_protons(i,1) = charge2protons(records{1}.spots(end).charge(i,1),IC_gain,range);
            records{1}.spots(end).tuning(i,1) = 0;
            % compute time
            if(iscell(current_fpga_time))
                current_start_time = str2double(current_fpga_time{1});
                current_end_time = str2double(current_fpga_time{end});
            else
                current_start_time = current_fpga_time(1);
                current_end_time = current_fpga_time(end);
            end
            if(i==1)
                if(length(records{1}.spots)>1)
                    if(records{1}.spots(end-1).timeStart(end,1) > start_irradiation)% next FPGA counter cycle
                        start_irradiation = start_irradiation +2^fpga_bits;
                    end
                    if(records{1}.spots(end-1).timeStart(end,1) > start_irradiation)% next day
                        start_irradiation = start_irradiation -2^fpga_bits+8.64e+10;
                    end
                end
                records{1}.spots(end).timeStart(i,1) = start_irradiation; % in [us]
                records{1}.spots(end).timeStop(i,1) = start_irradiation + (current_end_time - current_start_time); % in [us]
            else
                if(current_start_time > previous_end_time)
                    records{1}.spots(end).timeStart(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_start_time - previous_end_time); % in [us]
                else % next FPGA counter cycle
                    records{1}.spots(end).timeStart(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_start_time - previous_end_time + 2^fpga_bits); % in [us]
                end
                if(current_end_time > previous_end_time)
                    records{1}.spots(end).timeStop(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_end_time - previous_end_time); % in [us]
                else
                    records{1}.spots(end).timeStop(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_end_time - previous_end_time + 2^fpga_bits); % in [us]
                end
            end
            previous_end_time = current_end_time;
        end
    end
    
else
    
    % parameters of log file format
    delimiter = ',';
    startRow = 1;
    start_irradiation = 0;
    date_irradiation = '';
    numCols = [];
    fid = fopen(fileName,'r');
    while 1
        startRow = startRow + 1;
        tline = fgetl(fid);
        if ~ischar(tline)
            break
        elseif(contains(tline,'SUBMAP_NUMBER'))
            numCols = length(strfind(tline,delimiter))+1;
            colTime = find_csv_column(tline,'TIME');
            colXPos = find_csv_column(tline,'X_POSITION(mm)');
            colYPos = find_csv_column(tline,'Y_POSITION(mm)');
            colXPos1 = find_csv_column(tline,'X_POSITION_IC1(mm)');
            colYPos1 = find_csv_column(tline,'Y_POSITION_IC1(mm)');
            colCharge = find_csv_column(tline,'DOSE_PRIM(C)');
            break
        end
    end
    fclose(fid);
    if(isempty(numCols))
        disp('Could not find submap in logs. Abort')
        return
    end
    
    % Prepare format spec
    formatSpec = '%f%s';
    for i=1:numCols-2
        formatSpec = [formatSpec,'%f'];
    end
    formatSpec = [formatSpec,'%[^\n\r]'];
    
    % Read file
    fid = fopen(fileName,'r');
    log = textscan(fid,formatSpec,'Delimiter',delimiter,'EmptyValue',NaN,'HeaderLines',startRow-1,'ReturnOnError',true);
    fclose(fid);
    
    % Get log info
    nb_samples_per_ms = 4; % sampling for C230 system
    records{1}.spots(layerNb).layer = layerNb;
    records{1}.spots(layerNb).layer_id = layer_id+1;
    records{1}.spots(layerNb).range = range;
    [~,records{1}.spots(layerNb).date] = timeConverter(log{colTime}{1},version);
    if~(includeTuning) % If tuning spot equals full delivery of one spot -> one line in records is skipped and charge is set to NaN
        records{1}.spots(layerNb).charge(1,1) = NaN;
    end
    try
        spotCnt = 1+size(records{1}.spots(layerNb).charge,1);
    catch
        spotCnt = 1;
    end
    i=1;
    while i<=size(log{colXPos},1)
        if log{colCharge}(i)>charge_thr && ( (log{colXPos}(i)>-1000 && log{colYPos}(i)>-1000) || (log{colXPos1}(i)>-1000 && log{colYPos1}(i)>-1000) )
            records{1}.spots(end).spot_id(spotCnt,1) = spotCnt;
            xy = [log{colYPos}(i),log{colXPos}(i)]; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
            if(i>2)
                records{1}.spots(layerNb).charge(spotCnt,1) = log{colCharge}(i-1)+log{colCharge}(i-2); % take previous two charges into account
            else
                records{1}.spots(layerNb).charge(spotCnt,1) = 0;
            end
            records{1}.spots(layerNb).timeStart(spotCnt,1) = timeConverter(log{colTime}{i},version);
            adjust_start = 0;    
            duration = 0;
            while i<=size(log{colXPos},1) && log{colCharge}(i)>0 && ( (log{colXPos}(i)>-1000 && log{colYPos}(i)>-1000) || (log{colXPos1}(i)>-1000 && log{colYPos1}(i)>-1000) )
                xy(end+1,:) = [log{colYPos}(i),log{colXPos}(i)];
                records{1}.spots(layerNb).charge(spotCnt,1) = records{1}.spots(layerNb).charge(spotCnt) + log{colCharge}(i);
                duration = duration + 1;
                if(adjust_start>=0)
                    if(timeConverter(log{colTime}{i},version) == timeConverter(log{colTime}{i-1},version)) % when no difference in time compared to previous sample, adjust starting time
                        adjust_start = adjust_start +1;
                    else
                        records{1}.spots(layerNb).timeStart(spotCnt,1) = records{1}.spots(layerNb).timeStart(spotCnt,1) + 1000*mod(nb_samples_per_ms - adjust_start,nb_samples_per_ms)/nb_samples_per_ms;
                        adjust_start = -1;
                    end
                end
                i=i+1;                
            end            
            records{1}.spots(layerNb).timeStop(spotCnt,1) = records{1}.spots(layerNb).timeStart(spotCnt,1) + duration*(1000/nb_samples_per_ms);
            xy = xy(sum(xy,2)>-2000,:); % remove -10000 values
            if(isempty(xy))
                xy = [NaN,NaN];
            end
            records{1}.spots(layerNb).xyIC(spotCnt,:) = xy(end,:); %  spot position of the spot delivery as latest line recorded (most accurate, as per ODW)
            records{1}.spots(layerNb).SM_Offset(spotCnt,:) = SM_Offset;
            records{1}.spots(layerNb).IC_Offset(spotCnt,:) = IC_Offset;
            records{1}.spots(layerNb).xyIC(spotCnt,:) = records{1}.spots(layerNb).xyIC(spotCnt,:) - IC_Offset; %Convert from IC coordinates to IEC gantry coordinates
            records{1}.spots(layerNb).nb_protons(spotCnt,1) = charge2protons(records{1}.spots(layerNb).charge(spotCnt,1),IC_gain,range);
            records{1}.spots(layerNb).tuning(spotCnt,1) = 0;
            spotCnt = spotCnt + 1;
        end
        i=i+1;
    end
    
end

%check that records contain delivery information
if ~isfield(records{1}.spots(1),'charge')
    disp('Could not find charge in logs. Abort')
    return
end

%remove empty lines from record
i=0;
iEnd=size(records{1}.spots,2) ;
while 1
    i=i+1;
    if isempty(records{1}.spots(i).layer)
        records{1}.spots(i)=[];
        iEnd=iEnd-1;
        i=i-1;
    end
    if i==iEnd
        break
    end
end

end

% ----------------------------------------------------------------------
function records = readRecordS2C2(version,fileName,records,layerNb,IC_gain,layer_id,range,SM_Offset,IC_Offset,fpga_bits)

if(nargin<10)
    fpga_bits = 23;
end
if(isempty(records))
    records = cell(0);
    records{1}.spots = [];
end

% Parameters of log file format
delimiter = ',';
startRow = 1;
start_irradiation = 0;
date_irradiation = '';
fid = fopen(fileName,'r');
while 1
    startRow = startRow + 1;
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,'START_IRRADIATION'))
        colStart = find_csv_column(tline,'START_IRRADIATION');
        tline = fgetl(fid);
        [start_irradiation,date_irradiation] = timeConverter(get_csv_data(tline,colStart),'dekimo');
    elseif(contains(tline,'#ELEMENT_ID'))
        numCols = length(strfind(tline,delimiter))+1;
        colElementID = find_csv_column(tline,'#ELEMENT_ID');
        colID = find_csv_column(tline,'SPOT_ID');
        colTime = find_csv_column(tline,'FPGA_COUNT');
        colXPos = find_csv_column(tline,'PRIM_IC_X_POSITION');
        colYPos = find_csv_column(tline,'PRIM_IC_Y_POSITION');
        colCharge = find_csv_column(tline,'PRIM_IC_CHARGE');
        
        % Prepare format spec
        formatSpec = '%f%s';
        for i=1:numCols-2
            formatSpec = [formatSpec,'%f'];
        end
        formatSpec = [formatSpec,'%[^\n\r]'];
        
        break
    elseif contains(tline,'SUBMAP_NUMBER')
        numCols = length(strfind(tline,delimiter))+1;
        %not sure about correspondace btw element id and dekimoe elemnt ID
        colElementID = find_csv_column(tline,'DEKIMO_ELEMENT_ID');
        colID = find_csv_column(tline,'SPOT_ID');
        colTime = find_csv_column(tline,'FPGA_COUNT');
        colXPos = find_csv_column(tline,'X_POSITION(mm)');
        colYPos = find_csv_column(tline,'Y_POSITION(mm)');
        colCharge = find_csv_column(tline,'DOSE_PRIM(C)');
        
        %Prepare format spec
        formatSpec = '%f%f%f%s';
        for i=1:numCols-4
            formatSpec = [formatSpec,'%f'];
        end
        formatSpec = [formatSpec,'%[^\n\r]'];
        
        break
    end
end
fclose(fid);

% Read file
fid = fopen(fileName,'r');
log = textscan(fid,formatSpec,'Delimiter',delimiter,'EmptyValue',NaN,'HeaderLines',startRow,'ReturnOnError',true);
fclose(fid);

IDs = unique(log{colID}(log{colID}>0 & log{colElementID}>0));

if(not(isempty(IDs)))
    records{1}.spots(end+1).layer = layerNb;
    records{1}.spots(end).layer_id = layer_id;
    records{1}.spots(end).range = range;
    records{1}.spots(end).date = date_irradiation;
    
    for i=1:length(IDs)
        current_charge = log{colCharge}(log{colID}==IDs(i) & log{colElementID}>0);
        current_fpga_time = log{colTime}(log{colID}==IDs(i) & log{colElementID}>0);
        current_x = log{colXPos}(log{colID}==IDs(i) & log{colElementID}>0);
        current_y = log{colYPos}(log{colID}==IDs(i) & log{colElementID}>0);
        if(isempty(current_x) || isempty(current_y))
            continue
        end
        records{1}.spots(end).spot_id(i,1) = IDs(i);
        records{1}.spots(end).charge(i,1) = sum(current_charge);
        records{1}.spots(end).xyIC(i,:) = [current_y(end),current_x(end)] - IC_Offset; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
        records{1}.spots(end).SM_Offset(i,:) = SM_Offset;
        records{1}.spots(end).IC_Offset(i,:) = IC_Offset;
        records{1}.spots(end).nb_protons(i,1) = charge2protons(records{1}.spots(end).charge(i,1),IC_gain,range);
        records{1}.spots(end).tuning(i,1) = 0;
        % compute time
        if(iscell(current_fpga_time))
            current_start_time = str2double(current_fpga_time{1});
            current_end_time = str2double(current_fpga_time{end}) + 1e3;
        else
            current_start_time = current_fpga_time(1);
            current_end_time = current_fpga_time(end) + 1e3;
        end
        if(i==1)
            if(length(records{1}.spots)>1)
                if(records{1}.spots(end-1).timeStart(end,1) > start_irradiation)% next FPGA counter cycle
                    start_irradiation = start_irradiation +2^fpga_bits;
                end
                if(records{1}.spots(end-1).timeStart(end,1) > start_irradiation)% next day
                    start_irradiation = start_irradiation -2^fpga_bits+8.64e+10;
                end
            end
            records{1}.spots(end).timeStart(i,1) = start_irradiation; % in [us]
            records{1}.spots(end).timeStop(i,1) = start_irradiation + (current_end_time - current_start_time); % in [us]
        else
            if(current_start_time > previous_end_time - 1e3)
                records{1}.spots(end).timeStart(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_start_time - previous_end_time); % in [us]
            else % next FPGA counter cycle
                records{1}.spots(end).timeStart(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_start_time - previous_end_time + 2^fpga_bits); % in [us]
            end
            if(current_end_time > previous_end_time)
                records{1}.spots(end).timeStop(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_end_time - previous_end_time); % in [us]
            else
                records{1}.spots(end).timeStop(i,1) = records{1}.spots(end).timeStop(i-1,1) + (current_end_time - previous_end_time + 2^fpga_bits); % in [us]
            end
        end
        previous_end_time = current_end_time;
    end
end

end


% ----------------------------------------------------------------------
function nb_protons = charge2protons(charge,IC_gain,range)

chargeProton = 1.60217653e-19;
a = 1.684756748152e-03;
b = - 4.900892e-03 ;
c = 5.61372013e-01 ;
d = 3.464048389;
logRange = log(range);
energy= exp(a*logRange^3 + b*logRange^2 + c*logRange + d);
stoppingPower = 9.6139e-09*energy^4 - 7.0508e-06*energy^3 + 2.0028e-03*energy^2 - 2.7615e-01*energy + 2.0082e01;
gain = stoppingPower*IC_gain;
nb_protons = charge/(gain*chargeProton);

end


% ----------------------------------------------------------------------
function IC_gain = get_IC_gain(fileName)

IC_gain = NaN;
ref_string = 'IC3 chamber gain parameter;';
ref_string_2 = 'Primary chamber gain parameter;';
ref_S2C2_string = 'IC2 chamber gain parameter;';
ref_S2C2_string_2 = 'Primary chamber gain parameter (IC2);';

% Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    index = strfind(tline,ref_string);
    if(not(isempty(index)))
        IC_gain = str2double(tline(index+length(ref_string):end));
        if(not(isnan(IC_gain)))
            break
        end
    end
    index = strfind(tline,ref_string_2);
    if(not(isempty(index)))
        IC_gain = str2double(tline(index+length(ref_string_2):end));
        if(not(isnan(IC_gain)))
            break
        end
    end
    index = strfind(tline,ref_S2C2_string);
    if(not(isempty(index)))
        IC_gain = str2double(tline(index+length(ref_S2C2_string):end));
        if(not(isnan(IC_gain)))
            break
        end
    end
    index = strfind(tline,ref_S2C2_string_2);
    if(not(isempty(index)))
        IC_gain = str2double(tline(index+length(ref_S2C2_string_2):end));
        if(not(isnan(IC_gain)))
            break
        end
    end
end
fclose(fid);

end


% ----------------------------------------------------------------------
function IC_Offset_Beam = readICOffsetBeam(fileName)

IC_Offset_Beam = NaN;
ref_string = 'IC23AlignmentOffset;';
%
% % Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,ref_string))
        IC_Offset_Beamstring = strsplit(tline, ';');
        IC_Offset_Beamstring = strsplit(IC_Offset_Beamstring{1,end},',');
        IC_Offset_BeamX = str2double(IC_Offset_Beamstring{1,1});
        IC_Offset_BeamY = str2double(IC_Offset_Beamstring{1,2});
        IC_Offset_Beam = [IC_Offset_BeamY,IC_Offset_BeamX]; % invert x and y (-> plan coordinate system)
        if(not(isnan(IC_Offset_BeamY)) && not(isnan(IC_Offset_BeamX)))
            break
        end
    end
end
fclose(fid);

end


% ----------------------------------------------------------------------
function chargePerMUIC2 = readchargePerMUIC2(fileName)

chargePerMUIC2 = NaN;
ref_strings = {'Charge per MU on IC2;','Charge per MU on the primary IC;','Charge per MU on primary IC;'};

% Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    for i=1:length(ref_strings)
        index = strfind(tline,ref_strings{i});
        if(not(isempty(index)))
            chargePerMUIC2 = str2double(tline(index+length(ref_strings{i}):end));
            if(not(isnan(chargePerMUIC2)))
                break
            end
        end
    end
end
fclose(fid);

end


% ----------------------------------------------------------------------
function DistICtoISO = readDistICtoISO(fileName)

DistICtoISO = NaN;
ref_string = 'distanceFromIcToIsocenter';
%
% % Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,ref_string))
        DistICtoISOstring = strsplit(tline, ';');
        DistICtoISOstring = strsplit(DistICtoISOstring{1,end},',');
        DistICtoISOX = str2double(DistICtoISOstring{1,1});
        DistICtoISOY = str2double(DistICtoISOstring{1,2});
        DistICtoISO = [DistICtoISOY,DistICtoISOX]; % invert x and y (-> plan coordinate system)
        if(not(isnan(DistICtoISOY)) && not(isnan(DistICtoISOX)))
            break
        end
    end
end
fclose(fid);

end

% ----------------------------------------------------------------------
function roomType = readRoomType(fileName)
roomType='GTR';
ref_string='CGTR';

fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,ref_string))
        roomType=ref_string;
    end
end
fclose(fid);

end
% ----------------------------------------------------------------------
function SAD = readSAD(fileName)

SAD = NaN;
SADX = NaN;
SADY = NaN;
if(nargin<2)
    deflX = 0;
    deflY = 0;
else
    deflX = deflection(2);% invert x and y (-> nozzle coordinate system)
    deflY = deflection(1);
end
ref_string = 'SAD';

ref_string_2{1} = 'SAD_IC_X';
ref_string_2{2} = 'SAD_IC_Y';
% % Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
        % shreveport get SAX
    elseif(contains(tline,ref_string_2{1}))
        SADstringX = strsplit(tline(1:end),':');
        SADparamsX = strsplit(SADstringX{1},';');
        temp = SADparamsX{3}(strfind(SADparamsX{3},'parameter')+10:strfind(SADparamsX{3},' according')-1);
        if(isempty(temp))
            eval(['SADX = ',SADparamsX{end},';']);
        else
            SADparamsX = strsplit(temp,',');
            SADstringX = strsplit(SADstringX{end}, ';');
            SADcoefs = strsplit(SADstringX{end}, ',');
            for coef_index=1:length(SADparamsX)
                eval([SADparamsX{coef_index},' = ',SADcoefs{coef_index},';']);
            end
            eval(['SADX = ',SADstringX{1},';']);
        end
        %shreveprot get SAD y
    elseif(contains(tline,ref_string_2{2}))
        SADstringY = strsplit(tline(1:end),':');
        SADparamsY = strsplit(SADstringY{1},';');
        temp = SADparamsY{3}(strfind(SADparamsY{3},'parameter')+10:strfind(SADparamsY{3},' according')-1);
        
        if(isempty(temp))
            if(not(isnan(str2double(SADparamsY{end}))))
                eval(['SADY = ',SADparamsY{end},';']);
            else
                SADparamsY = SADparamsX;
                SADstringY = strsplit(SADstringY{end}, ';');
                SADcoefs = strsplit(SADstringY{end}, ',');
                for coef_index=1:length(SADparamsY)
                    eval([SADparamsY{coef_index},' = ',SADcoefs{coef_index},';']);
                end
                eval(['SADY = ',SADstringX{1},';']);
            end
        else
            SADparamsY = strsplit(temp,',');
            SADstring = strsplit(SADstring{end}, ';');
            SADcoefs = strsplit(SADstring{end}, ',');
            for coef_index=1:length(SADparamsY)
                eval([SADparamsY{coef_index},' = ',SADcoefs{coef_index},';']);
            end
            eval(['SADY = ',SADstring{1},';']);
        end
        break
        % standard SAD finding
    elseif(contains(tline,ref_string))
        SADstring = strsplit(tline, ';');
        SADstring = strsplit(SADstring{1,end}, ',');
        if size(SADstring,2)>=2
            SADX = str2double(SADstring{1,1});
            SADY = str2double(SADstring{1,2});
            if(not(isnan(SADX)) && not(isnan(SADY)))
                break
            end
        end
    end
end
fclose(fid);
SAD = [SADY,SADX]; % invert x and y (-> plan coordinate system)
end


% ----------------------------------------------------------------------
function SAD = readSAD_S2C2(fileName,x,y)

if(nargin<3)
    x = 0;
    y = 0;
end

SADX = NaN;
SADY = NaN;
ref_string{1} = 'SAD_IC_X';
ref_string{2} = 'SAD_IC_Y';

% Read X SAD
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,ref_string{1}) && contains(tline,'according scanalgo'))
        for spot=1:length(x)
            deflX = y(spot);% invert x and y (-> nozzle coordinate system)
            deflY = x(spot);% invert x and y (-> nozzle coordinate system)
            SADstringX = strsplit(tline(1:end),':');
            SADparamsX = strsplit(SADstringX{1},';');
            if(length(SADstringX)==1)
                SADX(spot) = str2double(SADparamsX{end});
            else
                temp = SADparamsX{3}(strfind(SADparamsX{3},'parameter')+10:strfind(SADparamsX{3},' according')-1);
                SADstringX = strsplit(SADstringX{end}, ';');
                SADstringX{1} = strrep(strrep(strrep(SADstringX{1},'²','^2'),'3','^3'),'^^','^');
                SADcoefs = strsplit(SADstringX{end}, ',');
                SADcoefs(strcmp('',SADcoefs)) = [];
                if(isempty(temp))
                    SADparamsX = {};
                    for coef_index=1:length(SADcoefs)
                        SADparamsX{coef_index} = char('a'-1+coef_index);
                    end
                else
                    SADparamsX = strsplit(temp,',');
                end
                for coef_index=1:length(SADcoefs)
                    eval([SADparamsX{coef_index},' = ',SADcoefs{coef_index},';']);
                end
                eval(['SADX(spot) = ',SADstringX{1},';']);
            end
        end
        break
    end
end
fclose(fid);

% Read Y SAD
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,ref_string{2}) && contains(tline,'according scanalgo'))
        for spot=1:length(x)
            deflX = y(spot);% invert x and y (-> nozzle coordinate system)
            deflY = x(spot);% invert x and y (-> nozzle coordinate system)
            SADstringY = strsplit(tline(1:end),':');
            SADparamsY = strsplit(SADstringY{1},';');
            if(length(SADstringY)==1)
                SADY(spot) = str2double(SADparamsY{end});
            else
                temp = SADparamsY{3}(strfind(SADparamsY{3},'parameter')+10:strfind(SADparamsY{3},' according')-1);
                SADstringY = strsplit(SADstringY{end}, ';');
                SADstringY{1} = strrep(strrep(strrep(SADstringY{1},'²','^2'),'3','^3'),'^^','^');
                SADcoefs = strsplit(SADstringY{end}, ',');
                SADcoefs(strcmp('',SADcoefs)) = [];
                if(isempty(temp))
                    SADparamsY = {};
                    for coef_index=1:length(SADcoefs)
                        SADparamsY{coef_index} = char('a'-1+coef_index);
                    end
                else
                    SADparamsY = strsplit(temp,',');
                end
                for coef_index=1:length(SADcoefs)
                    eval([SADparamsY{coef_index},' = ',SADcoefs{coef_index},';']);
                end
                eval(['SADY(spot) = ',SADstringY{1},';']);
            end
        end
        break
    end
end
fclose(fid);

SAD = [SADY',SADX']; % invert x and y (-> plan coordinate system)

end


% ----------------------------------------------------------------------
function CorrectionFactor = calculate_CorrectionFactor(fileName)

T = NaN;
refT = NaN;
P = NaN;
refP = NaN;
doseCF = NaN;

ref_string_T = 'temperature,K,';
ref_string_refT = 'referenceTemperature,K,';
ref_string_P = 'pressure,hPa,';
ref_string_refP = 'referencePressure,hPa,';
ref_string_doseCF = 'doseCorrectionFactor,,';

% Read file
fid = fopen(fileName,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    index = strfind(tline,ref_string_T);
    if(not(isempty(index)))
        T = str2double(tline(index+length(ref_string_T):end));
    end
    clear index
    index = strfind(tline,ref_string_refT);
    if(not(isempty(index)))
        refT = str2double(tline(index+length(ref_string_refT):end));
    end
    clear index
    index = strfind(tline,ref_string_P);
    if(not(isempty(index)))
        P = str2double(tline(index+length(ref_string_P):end));
    end
    clear index
    index = strfind(tline,ref_string_refP);
    if(not(isempty(index)))
        refP = str2double(tline(index+length(ref_string_refP):end));
    end
    clear index
    index = strfind(tline,ref_string_doseCF);
    if(not(isempty(index)))
        doseCF = str2double(tline(index+length(ref_string_doseCF):end));
    end
end
fclose(fid);

if(isnan(T) && isnan(P)) % try other format
    
    ref_string_T = 'temperature,Celsius degrees,';
    ref_string_refT = 'referenceTemperature,Celsius degrees,';
    ref_string_P = 'pressure,kPa,';
    ref_string_refP = 'referencePressure,kPa,';
    ref_string_doseCF = 'doseCorrectionFactor,,';
    
    fid = fopen(fileName,'r');
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        index = strfind(tline,ref_string_T);
        if(not(isempty(index)))
            T = str2double(tline(index+length(ref_string_T):end)) + 273.15;
        end
        clear index
        index = strfind(tline,ref_string_refT);
        if(not(isempty(index)))
            refT = str2double(tline(index+length(ref_string_refT):end)) + 273.15;
        end
        clear index
        index = strfind(tline,ref_string_P);
        if(not(isempty(index)))
            P = str2double(tline(index+length(ref_string_P):end));
        end
        clear index
        index = strfind(tline,ref_string_refP);
        if(not(isempty(index)))
            refP = str2double(tline(index+length(ref_string_refP):end));
        end
        clear index
        index = strfind(tline,ref_string_doseCF);
        if(not(isempty(index)))
            doseCF = str2double(tline(index+length(ref_string_doseCF):end));
        end
    end
    fclose(fid);
end

if(isnan(T) && isnan(P)) % try old format
    
    ref_string_T = 'temperature';
    ref_string_refT = 'referenceTemperature';
    ref_string_P = 'pressure';
    ref_string_refP = 'referencePressure';
    ref_string_doseCF = 'doseCorrectionFactor';
    
    fid = fopen(fileName,'r');
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        separators = sort([strfind(tline,','),strfind(tline,')'),strfind(tline,'=')]);
        index = strfind(tline,ref_string_T);
        if(not(isempty(index)))
            sep = separators(separators>index+length(ref_string_T));
            if(length(sep)>1)
                T = str2double(tline(sep(1)+1:sep(2)-1));
            else
                
            end
        end
        clear index
        index = strfind(tline,ref_string_refT);
        if(not(isempty(index)))
            sep = separators(separators>index+length(ref_string_refT));
            if(length(sep)>1)
                refT = str2double(tline(sep(1)+1:sep(2)-1));
            else
                refT = str2double(tline(sep(1)+1:end));
            end
        end
        clear index
        index = strfind(tline,ref_string_P);
        if(not(isempty(index)))
            sep = separators(separators>index+length(ref_string_P));
            if(length(sep)>1)
                P = str2double(tline(sep(1)+1:sep(2)-1));
            else
                P = str2double(tline(sep(1)+1:end));
            end
        end
        clear index
        index = strfind(tline,ref_string_refP);
        if(not(isempty(index)))
            sep = separators(separators>index+length(ref_string_refP));
            if(length(sep)>1)
                refP = str2double(tline(sep(1)+1:sep(2)-1));
            else
                refP = str2double(tline(sep(1)+1:end));
            end
        end
        clear index
        index = strfind(tline,ref_string_doseCF);
        if(not(isempty(index)))
            sep = separators(separators>index+length(ref_string_doseCF));
            if(length(sep)>1)
                doseCF = str2double(tline(sep(1)+1:sep(2)-1));
            else
                doseCF = str2double(tline(sep(1)+1:end));
            end
        end
    end
    fclose(fid);
end

PTP = 1/((T*refP)/(P*refT)); %same as K factor in specif files
CorrectionFactor = PTP*doseCF; %usually 1, dose correction factor between IC 2 and 3

end


% ----------------------------------------------------------------------
% Function checks that all spots are delivered with incrementing ID according to specif file -> sometimes low MU spots are already delivered
% as tuning and are not present in the record anymore
function All_Spots = CheckSpotIDs(fileName1,fileName2)
% Read specif delivery file
fid = fopen(fileName1,'r');
SPOT_ID_1 = [];
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,',[SPOT_ID],'))
        while 1
            params = fgetl(fid);
            if ~ischar(params)
                break
            elseif(not(isempty(params)))
                eval(['params = [',params,'];'])
                if(params(2)>0)
                    SPOT_ID_1(end+1) = params(2);
                end
            end
        end
    end
end
fclose(fid);
% Read specif tuning file
fid = fopen(fileName2,'r');
SPOT_ID_2 = [];
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,',[SPOT_ID],'))
        while 1
            params = fgetl(fid);
            if ~ischar(params)
                break
            elseif(not(isempty(params)))
                eval(['params = [',params,'];'])
                if(params(2)>0)
                    SPOT_ID_2(end+1) = params(2);
                end
            end
        end
    end
end
fclose(fid);
All_Spots = 1;
for i=1:length(SPOT_ID_2)
    if(sum(SPOT_ID_1==SPOT_ID_2(i))==0)
        All_Spots = 0;
    end
end
end


% ----------------------------------------------------------------------
function events = load_PBS_events(fileName)

events = struct;
events.type = 'impt';
events.txt = {};
events.time = {};
events.angle = {};
events.angle_target = {};

fid = fopen(fileName,'r');

wait_for_start = 1;

while 1
    
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,'recordEvent'))
        
        if(wait_for_start && contains(tline,'START_ARC_ANGLE_IRRADIATION'))
            
            events.type = 'arc';
            
            % text
            events.txt{end+1,1} = tline;
            
            % time
            index = strfind(tline,' ');
            timeString = tline(index(1)+1:index(1)+12);
            events.time{end+1,1} = timeConverter(timeString,'event');
            if(size(events.time,1)>1)
                if(events.time{end,1}<events.time{end-1,1})
                    events.time{end,1} = events.time{end,1}+8.64e+10; % next day
                end
            end
            
            % target and actual angles
            index_t = strfind(tline,'Target=');
            index_a = strfind(tline,'Actual=');
            
            if(not(isempty(index_t)) && not(isempty(index_a)))
                events.angle_target{end+1,1} = str2double(tline(index_t+7:index_a-1));
                events.angle{end+1,1} = str2double(tline(index_a+7:end));
            end
            
            wait_for_start = 0;
            
        elseif(not(wait_for_start) && contains(tline,'END_ARC_ANGLE_IRRADIATION'))
            
            events.type = 'arc';
            
            % text
            events.txt{end+1,1} = tline;
            
            % time
            index = strfind(tline,' ');
            timeString = tline(index(1)+1:index(1)+12);
            events.time{end,2} = timeConverter(timeString,'event');
            if(events.time{end,2}<events.time{end,1})
                events.time{end,2} = events.time{end,2}+8.64e+10; % next day
            end
            
            % target and actual angles
            index_t = strfind(tline,'Target=');
            index_a = strfind(tline,'Actual=');
            
            if(not(isempty(index_t)) && not(isempty(index_a)))
                events.angle_target{end,2} = str2double(tline(index_t+7:index_a-1));
                events.angle{end,2} = str2double(tline(index_a+7:end));
            end
            
            wait_for_start = 1;
            
        end
        
    end
end

fclose(fid);

end
