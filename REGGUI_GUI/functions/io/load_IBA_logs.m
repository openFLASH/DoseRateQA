%% load_IBA_logs
% Read the PBS irradiation logs recorded by the IBA scanning data recorder
%
% Note that in the irradiation logs, the (X,Y) coordinate system is the PHYSICS coordinate system. The PHYSICS coordinate system is derived from the IEC-GATNRY CS by exchange of the X<->Y axes. The |load_IBA_logs| parse the logs and convert the spot coordinates to bring them back to the IEC gantry CS before outputing the result.
%
%% Syntax
% |records = load_IBA_logs(logFilename)|
%
% |records = load_IBA_logs(logFilename, outputDir)|
%
% |records = load_IBA_logs(logFilename, outputDir, xdr_converter)|
%
%% Description
% |records = load_IBA_logs(logFilename)| Read the PBS log using the default JAVA log converter and output text log files in current directory
%
% |records = load_IBA_logs(logFilename, outputDir)| Read the PBS log using the default JAVA log converter and output text log files in the specified directory
%
% |records = load_IBA_logs(logFilename, outputDir, xdr_converter)| Read the PBS logs using the specified JAVA log converter
%
%% Input arguments
% |logFilename| - _STRING_ - File name (including directory) of the file containing the data recorder PBS irradiation logs (in XDR format)
%
% |outputDir| - _STRING_ - [OPTIONAL. Default: current working directory] Directory in which the the text version of the PBS irradiation logs are saved
%
% |xdr_converter| - _STRING_ - [OPTIONAL] File name (including path) of the JAVA executable used to convert the irradiation logs from XDR format to text format. If absent, uses the default convertion program which should be stored in the folder 'externals' (which must be present in the Matlab path). Depending on the format of the log file (which defined by version number X.Y indicated at the end of the log file name), the function load_IBA_logs will search a file called 'data-recorder-proc-XXX-deploy.jar' where 'XXX' is a version number. The log file name must have the following format: YYYYMMDD_HHMMSS_NNN.PBS.X.Y.zip where YYYY is the year, MM the month, DD the day, HH the hour, MM the minutes, SS the seconds, NNN a serail number and X.Y the file format. If no JAVA executable is available, the function load_IBA_logs will not be able to read XDR file. It will only be able to process CSV files.
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
% * |records{1}.spots(l).xy(s,:)| - _SCALAR VECTOR_ - Average spot position (x,y) at isocenter over the delivery of the s-th spot of the l-th energy layer. The coordinate system is IEC-GANTRY.
% * |records{1}.spots(l).weight(s)| - _SCALAR_ - MU of the s-th spot of the l-th energy layer
%
%
%% Contributors
% Authors : S.Puydupin, R.Labarbe, J.Petzhold, G.Janssens (open.reggui@gmail.com)

function [records,outputDir,sum_MU] = load_IBA_logs(logFilename, outputDir, xdr_converter, merge_tuning, remove_negative_spots)

% Default parameters
if(nargin<2)
    outputDir = '';
end
if(nargin<3)
    xdr_converter = '';
end
if(nargin<4)
    merge_tuning = 1;
end
if(nargin<5)
    remove_negative_spots = 1;
end

% Init records
records = cell(0);
records{1}.spots = [];
mGantryAngle = NaN;


% -----------------------------------------------------------------------
% Convert XDR files (only if output directory is still empty)
% -----------------------------------------------------------------------

[version,outputDir] = convert_logs_xdr(logFilename,outputDir,xdr_converter);
logFiles = dir(outputDir);


% -----------------------------------------------------------------------
% Identify machine type (C230 or S2C2) and first layer index
% -----------------------------------------------------------------------

record_type = '';
first_layer_id = Inf;
for i=1:1:size(logFiles,1)
    if contains(logFiles(i).name,'map_record') % C230
        record_type = 'map_record';
        break
    elseif contains(logFiles(i).name,'burst_record') % S2C2
        record_type = 'burst_record';
        break
    end
end
if(isempty(record_type))
    error(['Could not determine machine type from logs. Possibly no logs found in ',outputDir])
end

for i=1:1:size(logFiles,1)
    if contains(logFiles(i).name,'specif')
        specif_filename = fullfile(outputDir,logFiles(i).name);
        [~,layer_id] = readRangeFromSpecif(specif_filename);
        first_layer_id = min(first_layer_id,layer_id);
    end
end
if(isinf(first_layer_id))
    first_layer_id = 0;
end


% -----------------------------------------------------------------------
% Directory browsing and beam config reading
% -----------------------------------------------------------------------

brf_filename = '';
for i=1:1:size(logFiles,1)
    if(contains(logFiles(i).name,'bmsResults') && contains(logFiles(i).name,'.xml'))
        brf_filename = fullfile(outputDir,logFiles(i).name);
        break
    end
    if contains(logFiles(i).name,'beam_config.') || contains(logFiles(i).name,'idt_config.')
        config_filename = fullfile(outputDir,logFiles(i).name);
        disp(['Processing beam config file: ' config_filename]);
        IC_gain = get_IC_gain(config_filename);
        DistICtoISO = readDistICtoISO(config_filename);
        chargePerMUIC2 = readchargePerMUIC2(config_filename);
        roomType=readRoomType(config_filename);
        if strcmp(record_type,'map_record')
            SAD = readSAD(config_filename);
        end
    end
    if ~(isempty(strfind(logFiles(i).name,'beam.')))
        beam_filename = fullfile(outputDir,logFiles(i).name);
        disp(['Processing beam file: ' beam_filename]);
        CorrectionFactor = calculate_CorrectionFactor(beam_filename);
        [mBeamId,mGantryAngle] = get_beam_info_from_log_beamfile(beam_filename);
        records{1}.BeamName = mBeamId;
        mGantryAngle = str2double(mGantryAngle);
    end
end
records{1}.GantryAngle = mGantryAngle;


% -----------------------------------------------------------------------
% Parse BRF if available
% -----------------------------------------------------------------------

% If brf file available, parse it and return
if(not(isempty(brf_filename)))

    [records,sum_MU] = load_BRF(brf_filename);
    records{1}.GantryAngle = mGantryAngle;

    % order spots according to time
    nb_layers = length(records{1}.spots);
    for layerIndex=1:nb_layers
        [~,spot_order] = sort(records{1}.spots(layerIndex).timeStart);
        records{1}.spots(layerIndex) = reorder_spots(records{1}.spots(layerIndex),spot_order);
    end

    % merge tuning spots into delivered spots
    if(merge_tuning)
        records = merge_tuning_spots(records);
    end

    disp(['Total MUs delivered = ',num2str(sum_MU),' in ',num2str(records{1}.spots(end).timeStop(end)/1e6),'s']);
    return
end


% -----------------------------------------------------------------------
% Read tuning and records
% -----------------------------------------------------------------------

for i=1:1:size(logFiles,1)
    if contains(logFiles(i).name,record_type) && contains(logFiles(i).name,'tuning') && not(contains(logFiles(i).name,'events')) && not(strcmp(logFiles(i).name(1),'.'))
        record_filename = fullfile(outputDir,logFiles(i).name);
        records = appendLog(records,record_type,version,record_filename,first_layer_id,IC_gain,double(contains(logFiles(i).name,'tuning')));
    end
end
for i=1:1:size(logFiles,1)
    if contains(logFiles(i).name,record_type) && not(contains(logFiles(i).name,'tuning')) && not(contains(logFiles(i).name,'events')) && not(strcmp(logFiles(i).name(1),'.'))
        record_filename = fullfile(outputDir,logFiles(i).name);
        records = appendLog(records,record_type,version,record_filename,first_layer_id,IC_gain,double(contains(logFiles(i).name,'tuning')));
    end
end


% -----------------------------------------------------------------------
% Remove empty layers
% -----------------------------------------------------------------------

i=0;
iEnd=size(records{1}.spots,2) ;
while 1
    i=i+1;
    if isempty(records{1}.spots(i).layer)
        records{1}.spots(i)=[];
        iEnd=iEnd-1;
        i=i-1;
    elseif not(isfield(records{1}.spots(i),'charge'))
        records{1}.spots(i)=[];
        iEnd=iEnd-1;
        i=i-1;
    end
    if i==iEnd
        break
    end
end

if(length(records{1}.spots)<1)
    disp('WARNING: no spot found in logs.')
    sum_MU = 0;
    return
end


% -----------------------------------------------------------------------
% Convert raw data from logs
% -----------------------------------------------------------------------

sum_MU = 0;

switch record_type

    case 'map_record'

        % Convert raw data
        nb_layers = length(records{1}.spots);
        for layerIndex=1:nb_layers
            % apply offset on tuning spot
            i=1;
            while i<length(records{1}.spots(layerIndex).tuning) && records{1}.spots(layerIndex).tuning(i)>0
                records{1}.spots(layerIndex).SM_Offset(i,:) = records{1}.spots(layerIndex).SM_Offset(end,:);
                records{1}.spots(layerIndex).xyIC(i,:) = records{1}.spots(layerIndex).xyIC(i,:) + records{1}.spots(layerIndex).IC_Offset(i,:) - records{1}.spots(layerIndex).IC_Offset(end,:);
                records{1}.spots(layerIndex).IC_Offset(i,:) = records{1}.spots(layerIndex).IC_Offset(end,:);
                i = i+1;
            end

            % charge from logs
            if(sum(records{1}.spots(layerIndex).charge<0))
                disp(['Warning: ',num2str(sum(records{1}.spots(layerIndex).charge<0)),' spots (out of ',num2str(length(records{1}.spots(layerIndex).charge)),') with negative charge in layer ',num2str(records{1}.spots(layerIndex).layer)])
            end
            if(remove_negative_spots)
                records{1}.spots(layerIndex) = reorder_spots(records{1}.spots(layerIndex),records{1}.spots(layerIndex).charge>0);
            else
                records{1}.spots(layerIndex).charge(records{1}.spots(layerIndex).charge<0)=0;
            end

            % Remove impossible positions for low-weighted spots
            records{1}.spots(layerIndex).xyIC(records{1}.spots(layerIndex).charge<0.01 & abs(records{1}.spots(layerIndex).xyIC(:,1))>200,1) = NaN;
            records{1}.spots(layerIndex).xyIC(records{1}.spots(layerIndex).charge<0.01 & abs(records{1}.spots(layerIndex).xyIC(:,2))>200,2) = NaN;

            % Project on isocenter plane
            if strcmp(roomType,'GTR')
                records{1}.spots(layerIndex).xy(:,1) =  records{1}.spots(layerIndex).xyIC(:,1).*(SAD(1)/(SAD(1) - DistICtoISO(1))); %already inverted SAD and DistIC
                records{1}.spots(layerIndex).xy(:,2) =  records{1}.spots(layerIndex).xyIC(:,2).*(SAD(2)/(SAD(2) - DistICtoISO(2)));
            else %% shreveport case
                records{1}.spots(layerIndex).xy(:,1) =  -records{1}.spots(layerIndex).SM_Offset(:,1) + records{1}.spots(layerIndex).xyIC(:,1).*(SAD(1)/(SAD(1) - DistICtoISO(1))); %already inverted SAD and DistIC
                records{1}.spots(layerIndex).xy(:,2) =  -records{1}.spots(layerIndex).SM_Offset(:,2) + records{1}.spots(layerIndex).xyIC(:,2).*(SAD(2)/(SAD(2) - DistICtoISO(2)));
            end

            % Convert charge to MUs
            records{1}.spots(layerIndex).weight = records{1}.spots(layerIndex).charge ./ (chargePerMUIC2*CorrectionFactor);
            records{1}.spots(layerIndex).metersetRate = records{1}.spots(layerIndex).weight ./ (records{1}.spots(layerIndex).effectiveDuration/1e6); % in [MU/s]
            sum_MU = sum_MU + sum(records{1}.spots(layerIndex).weight);

        end %layer loop

    case 'burst_record'

        % Convert raw data
        nb_layers = length(records{1}.spots);
        for layerIndex=1:nb_layers

            % Remove negatively charged spots
            if(sum(records{1}.spots(layerIndex).charge<0))
                disp(['Warning: ',num2str(sum(records{1}.spots(layerIndex).charge<0)),' spots (out of ',num2str(length(records{1}.spots(layerIndex).charge)),') with negative charge in layer ',num2str(records{1}.spots(layerIndex).layer),' (burst ',num2str(layerIndex),').'])
            end
            if(remove_negative_spots)
                records{1}.spots(layerIndex) = reorder_spots(records{1}.spots(layerIndex),records{1}.spots(layerIndex).charge>0);
            else
                records{1}.spots(layerIndex).charge(records{1}.spots(layerIndex).charge<0) = 0;
            end

            % Remove impossible positions for low-weighted spots
            records{1}.spots(layerIndex).xyIC(records{1}.spots(layerIndex).charge<0.01 & abs(records{1}.spots(layerIndex).xyIC(:,1))>200,1) = NaN;
            records{1}.spots(layerIndex).xyIC(records{1}.spots(layerIndex).charge<0.01 & abs(records{1}.spots(layerIndex).xyIC(:,2))>200,2) = NaN;

            % Project on isocenter plane using formula: -SMOffset + (Position_IC ? ICOffset)*SAD_IC/(SAD_IC - distanceFromICtoIso)
            SAD = readSAD_S2C2(config_filename,records{1}.spots(layerIndex).xyIC(:,1),records{1}.spots(layerIndex).xyIC(:,2));
            records{1}.spots(layerIndex).xy(:,1) = -records{1}.spots(layerIndex).SM_Offset(:,1) + records{1}.spots(layerIndex).xyIC(:,1).*(SAD(:,1)./(SAD(:,1) - DistICtoISO(1))); %already inverted SAD and DistIC
            records{1}.spots(layerIndex).xy(:,2) = -records{1}.spots(layerIndex).SM_Offset(:,2) + records{1}.spots(layerIndex).xyIC(:,2).*(SAD(:,2)./(SAD(:,2) - DistICtoISO(2)));
            if(max(abs(records{1}.spots(layerIndex).xy(:)))>125)
                disp(['Warning: unexpected spot position (',num2str(max(abs(records{1}.spots(layerIndex).xy(:)))),' mm) in layer ',num2str(records{1}.spots(layerIndex).layer),' (burst ',num2str(layerIndex),')']);
            end

            % Convert charge to MUs
            records{1}.spots(layerIndex).weight = records{1}.spots(layerIndex).charge ./ (chargePerMUIC2*CorrectionFactor);
            records{1}.spots(layerIndex).metersetRate = records{1}.spots(layerIndex).weight ./ (records{1}.spots(layerIndex).effectiveDuration/1e6); % in [MU/s]
            sum_MU = sum_MU + sum(records{1}.spots(layerIndex).weight);

        end %layer loop

end


% -----------------------------------------------------------------------
% Reorder spots according to time
% -----------------------------------------------------------------------

nb_layers = length(records{1}.spots);
for layerIndex=1:nb_layers
    [~,spot_order] = sort(records{1}.spots(layerIndex).timeStart);
    records{1}.spots(layerIndex) = reorder_spots(records{1}.spots(layerIndex),spot_order);
end

% -----------------------------------------------------------------------
% Merge tuning spots into delivered spots (if required)
% -----------------------------------------------------------------------

if(merge_tuning)
    records = merge_tuning_spots(records);
end

disp(['Total MUs delivered = ',num2str(sum_MU),' in ',num2str((records{1}.spots(end).timeStop(end)-records{1}.spots(1).timeStart(1))/1e6),'s']);
return

end


% ----------------------------------------------------------------------
function spots = reorder_spots(spots,order)

fields = {'painting',...
    'spot_id',...
    'xyIC',...
    'SM_Offset',...
    'IC_Offset',...
    'nb_protons',...
    'tuning',...
    'timeStart',...
    'timeStop',...
    'time',...
    'duration',...
    'effectiveDuration',...
    'metersetRate',...
    'charge',...
    'gantry_angle',...
    'gantry_speed',...
    'MU'};

for i=1:length(fields)
    if(isfield(spots,fields{i}))
        if(not(isempty(spots.(fields{i}))))
            spots.(fields{i}) = spots.(fields{i})(order,:);
        end
    end
end

end


% ----------------------------------------------------------------------
function records = appendLog(records,record_type,version,record_filename,first_layer_id,IC_gain,tuning)

specif_filename = strrep(strrep(record_filename,'map_record_','map_specif_'),'burst_record_','burst_specif_');
if(not(exist(specif_filename,'file')) && contains(record_filename,'recover'))
    [logdir,logfile] = fileparts(specif_filename);
    logFiles = dir(logdir);
    recover_filename_split = strsplit(specif_filename,'recover');
    for i=1:length(logFiles)
        j = 1;
        while strcmp(logfile(1:j),logFiles(i).name(1:j))
            j = j+1;
        end
        specif_filename = fullfile(logdir,[logfile(1:j-1),recover_filename_split{end}]);
        if(exist(specif_filename,'file'))
            break
        end
    end
end
if(exist(specif_filename,'file'))
    disp(['Processing Specif file: ' specif_filename]);
    [range,layer_id] = readRangeFromSpecif(specif_filename);
    layerIndex = layer_id - first_layer_id + 1;
    [IC_Offset,SM_Offset] = readOffsetFromSpecif(specif_filename);
    records{1}.spots(layerIndex).layer = layer_id;
    records{1}.spots(layerIndex).range = range;
    records{1}.spots(layerIndex).energy = range2energy_IBA(range);
else
    error([specif_filename,' not found.'])
end

delimiter = ',';
startRow = 1;
layer_time = 0;
layer_date = '';
colTime = 0;
colXPos = 0;
colYPos = 0;
colCharge = 0;
colAngle = 0;
colSpeed = 0;

try
    spotIndex = 1+size(records{1}.spots(layerIndex).charge,1);
catch
    spotIndex = 1;
end
paintingIndex = 1;
if(not(tuning))
    try
        if(not(records{1}.spots(layerIndex).tuning(end)))
            paintingIndex = records{1}.spots(layerIndex).painting(end) + 1;
        end
    catch
    end
end

switch record_type

    case 'map_record' % C230

        duty_cycle = 1; % duty cycle for continuous beam = 100%
        scanning_controller_type = 'pyramid';
        fid = fopen(record_filename,'r');
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
                break
            end
            if(contains(tline,'FPGA_COUNT'))
                scanning_controller_type = 'dekimo';
                break
            end
        end
        fclose(fid);

        switch scanning_controller_type

            case 'dekimo'

                % Get columns and start time
                disp(['Processing Record file: ' record_filename]);
                fid = fopen(record_filename,'r');
                while 1
                    startRow = startRow + 1;
                    tline = fgetl(fid);
                    if ~ischar(tline)
                        break
                    elseif(contains(tline,'START_IRRADIATION'))
                        colStart = find_csv_column(tline,'START_IRRADIATION');
                        tline = fgetl(fid);
                        [layer_time,layer_date] = timeConverter(get_csv_data(tline,colStart),scanning_controller_type);
                    elseif(contains(tline,'#ELEMENT_ID'))
                        numCols = length(strfind(tline,delimiter))+1;
                        colElementID = find_csv_column(tline,'#ELEMENT_ID');
                        colID = find_csv_column(tline,'SPOT_ID');
                        colTime = find_csv_column(tline,'FPGA_COUNT');
                        colXPos = find_csv_column(tline,'PRIM_IC_X_POSITION');
                        colYPos = find_csv_column(tline,'PRIM_IC_Y_POSITION');
                        colCharge = find_csv_column(tline,'PRIM_IC_CHARGE');
                        colAngle = find_csv_colum(tline,'GTRIO_GANTRY_POS');
                        colSpeed = find_csv_colum(tline,'GTRIO_GANTRY_SPEED');

                        % Prepare format spec
                        formatSpec = '';
                        for i=1:numCols
                            formatSpec = [formatSpec,'%f'];
                        end
                        formatSpec = [formatSpec,'%[^\n\r]'];

                        break
                    elseif contains(tline,'SUBMAP_NUMBER')
                        numCols = length(strfind(tline,delimiter))+1;
                        colElementID = find_csv_column(tline,'DEKIMO_ELEMENT_ID');
                        colID = find_csv_column(tline,'SPOT_ID');
                        colTime = find_csv_column(tline,'FPGA_COUNT');
                        colXPos = find_csv_column(tline,'X_POSITION(mm)');
                        colYPos = find_csv_column(tline,'Y_POSITION(mm)');
                        colCharge = find_csv_column(tline,'DOSE_PRIM(C)');

                        % Prepare format spec
                        formatSpec = '';
                        for i=1:numCols
                            formatSpec = [formatSpec,'%f'];
                        end
                        formatSpec = [formatSpec,'%[^\n\r]'];

                        break
                    end
                end
                fclose(fid);

                % Read file
                fid = fopen(record_filename,'r');
                log = textscan(fid,formatSpec,'Delimiter',delimiter,'EmptyValue',NaN,'HeaderLines',startRow,'ReturnOnError',true);
                fclose(fid);

                % Get log info
                log{colID}(log{colElementID}<=0) = NaN; % remove non-spot IDs
                IDs = unique(log{colID}(log{colID}>0));
                if(not(isempty(IDs)))
                    sampling_time = NaN;
                    if(length(log{colTime})>1)
                        sampling_time = diff(log{colTime}(:));
                        sampling_time = round(mean(sampling_time(sampling_time>0))); % sampling time in [us]
                    end
                    if(isnan(sampling_time))
                        sampling_time = 200; % default value for C230 dekimo in [us]
                    end
                else
                    return
                end

            case 'pyramid'

                % get list of spot submap numbers from specif file
                IDs = readSubmapNumbersFromSpecif(specif_filename);

                % Get columns and start time
                disp(['Processing Record file: ' record_filename]);
                numCols = [];
                fid = fopen(record_filename,'r');
                while 1
                    startRow = startRow + 1;
                    tline = fgetl(fid);
                    if ~ischar(tline)
                        break
                    elseif(contains(tline,'SUBMAP_NUMBER'))
                        numCols = length(strfind(tline,delimiter))+1;
                        colID = find_csv_column(tline,'SUBMAP_NUMBER');
                        colTime = find_csv_column(tline,'TIME');
                        colXPos = find_csv_column(tline,'X_POSITION(mm)');
                        colYPos = find_csv_column(tline,'Y_POSITION(mm)');
                        colCharge = find_csv_column(tline,'DOSE_PRIM(C)');
                        break
                    end
                end
                fclose(fid);
                if(isempty(numCols))
                    return
                end

                % Prepare format spec
                formatSpec = '%f%s';
                for i=1:numCols-2
                    formatSpec = [formatSpec,'%f'];
                end
                formatSpec = [formatSpec,'%[^\n\r]'];

                % Read file
                fid = fopen(record_filename,'r');
                log = textscan(fid,formatSpec,'Delimiter',delimiter,'EmptyValue',NaN,'HeaderLines',startRow-1,'ReturnOnError',true);
                fclose(fid);

                % Get log info
                if(not(isempty(IDs)))
                    sampling_time = 250; % sampling for C230 pyramid system in [us]
                    [layer_time,layer_date] = timeConverter(log{colTime}{1},version);
                    records{1}.spots(layerIndex).date = layer_date;
                    if(spotIndex==1)
                        records{1}.spots(layerIndex).layerTime = layer_time;
                    end
                else
                    return
                end

                % remove additional incomplete lines
                nb_lines = length(log{end});
                for i=1:length(log)
                    log{i} = log{i}(1:nb_lines);
                end

        end

        % Get log values
        log{colTime} = (0:length(log{colTime})-1)'*sampling_time;
        records{1}.spots(layerIndex).date = layer_date;
        if(spotIndex==1)
            records{1}.spots(layerIndex).layerTime = layer_time;
        end
        for i=1:length(IDs)
            current_charge = log{colCharge}(log{colID}==IDs(i));
            if (isempty(current_charge))
                continue
            end
            current_time = log{colTime}(log{colID}==IDs(i));
            current_x = log{colXPos}(log{colID}==IDs(i));
            current_y = log{colYPos}(log{colID}==IDs(i));
            current_x = current_x(current_x>-1000); % remove -10000 values
            current_y = current_y(current_y>-1000); % remove -10000 values
            if(isempty(current_x))
                current_x = NaN;
            end
            if (isempty(current_y))
                current_y = NaN;
            end
            average_charge_per_sample = mean(current_charge); % average over all samples of the spot
            average_charge_per_sample = mean(current_charge(current_charge>=average_charge_per_sample/2)); % remove contribution from low-current samples (lower than half the average)
            % store data in record structure
            records{1}.spots(layerIndex).painting(spotIndex,1) = paintingIndex;
            records{1}.spots(layerIndex).spot_id(spotIndex,1) = IDs(i);
            records{1}.spots(layerIndex).charge(spotIndex,1) = sum(current_charge);
            records{1}.spots(layerIndex).xyIC(spotIndex,:) = [current_y(end),current_x(end)] - IC_Offset; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
            records{1}.spots(layerIndex).SM_Offset(spotIndex,:) = SM_Offset;
            records{1}.spots(layerIndex).IC_Offset(spotIndex,:) = IC_Offset;
            records{1}.spots(layerIndex).nb_protons(spotIndex,1) = charge2protons(records{1}.spots(layerIndex).charge(end,1),IC_gain,range);
            records{1}.spots(layerIndex).tuning(spotIndex,1) = tuning;
            records{1}.spots(layerIndex).duration(spotIndex,1) = numel(current_charge)*sampling_time; % full duration in [us]
            records{1}.spots(layerIndex).effectiveDuration(spotIndex,1) = records{1}.spots(layerIndex).charge(spotIndex,1)/average_charge_per_sample*sampling_time; % effective spot duration in [us]
            records{1}.spots(layerIndex).timeStart(spotIndex,1) = layer_time + current_time(1);
            records{1}.spots(layerIndex).timeStop(spotIndex,1) = layer_time + current_time(end) + sampling_time*duty_cycle;
            records{1}.spots(layerIndex).time(spotIndex,1) = layer_time + sum(current_time.*current_charge)/sum(current_charge) + sampling_time*duty_cycle/2;% dose-averaged spot time
            if(records{1}.spots(layerIndex).time(spotIndex,1)<records{1}.spots(layerIndex).timeStart(spotIndex,1) || records{1}.spots(layerIndex).time(spotIndex,1)>records{1}.spots(layerIndex).timeStop(spotIndex,1))
                records{1}.spots(layerIndex).time(spotIndex,1) = (records{1}.spots(layerIndex).timeStart(spotIndex,1)+records{1}.spots(layerIndex).timeStop(spotIndex,1))/2;
            end
            if (colAngle>0)
                records{1}.spots(layerIndex).gantry_angle(spotIndex,1) = mean(log{colAngle}(log{colID}==IDs(i)));
            end
            if (colSpeed>0)
                records{1}.spots(layerIndex).gantry_speed(spotIndex,1) = mean(log{colSpeed}(log{colID}==IDs(i)));
            end


  % figure(1)
  % clf
  %
  % indices = find(log{colID}==IDs(i));
  % indices = min(indices)-5:max(indices)+5;
  % extended_Charge = log{colCharge}(indices);
  % extended_time = layer_time + log{colTime}(indices) + sampling_time/2; %Place he dot in the CENTER of the 250us time slice
  % records{1}.spots(layerIndex).time(spotIndex,1);
  %
  % semilogy(records{1}.spots(layerIndex).time(spotIndex,1) , average_charge_per_sample,'*r') %Dose weighted time
  % hold on
  %
  % Ts = records{1}.spots(layerIndex).time(spotIndex,1) - records{1}.spots(layerIndex).effectiveDuration(spotIndex,1)./2;
  % Te = records{1}.spots(layerIndex).time(spotIndex,1) + records{1}.spots(layerIndex).effectiveDuration(spotIndex,1)./2;
  % semilogy([Ts,Te] , [average_charge_per_sample , average_charge_per_sample],'-r') %Last record in spot
  %
  % semilogy(extended_time , extended_Charge,'.k') %Charge counts in spot
  % semilogy(layer_time + current_time + sampling_time/2 , current_charge,'.-b') %Charge counts in spot %Place he dot in the CENTER of the 250us time slice
  %
  %
  % xlabel('Time (\mus)')
  % ylabel('Charge (Cb)')
  % title(['Spot Nb ' num2str(i)])
  % xlim([min(extended_time)- sampling_time/2 , max(extended_time) + sampling_time/2])
  % xticks(min(extended_time)- sampling_time/2 :sampling_time: max(extended_time) + sampling_time/2)
  % grid on
  % hold off

  %pause

        spotIndex = spotIndex + 1;
        end

        % Create spot ID for pyramid (instead of submap number)
        if(strcmp(scanning_controller_type,'pyramid'))
            indices = 1:length(records{1}.spots(layerIndex).spot_id);
            records{1}.spots(layerIndex).spot_id(:,1) = -1e6 + round(records{1}.spots(layerIndex).xyIC(:,2))*1e4 + round(records{1}.spots(layerIndex).xyIC(:,1)); % set spot ID as a function of its position (with a 1 mm rounding)
            records{1}.spots(layerIndex).spot_id(isnan(records{1}.spots(layerIndex).spot_id)) = indices(isnan(records{1}.spots(layerIndex).spot_id));
        end


    case 'burst_record' % S2C2

        duty_cycle = 0.02; % duty cycle for pulsed beam
        scanning_controller_type = 'dekimo';

        % Get columns and start time
        disp(['Processing Record file: ' record_filename]);
        fid = fopen(record_filename,'r');
        while 1
            startRow = startRow + 1;
            tline = fgetl(fid);
            if ~ischar(tline)
                break
            elseif(contains(tline,'START_IRRADIATION'))
                colStart = find_csv_column(tline,'START_IRRADIATION');
                tline = fgetl(fid);
                [layer_time,layer_date] = timeConverter(get_csv_data(tline,colStart),scanning_controller_type);
            elseif(contains(tline,'#ELEMENT_ID'))
                numCols = length(strfind(tline,delimiter))+1;
                colElementID = find_csv_column(tline,'#ELEMENT_ID');
                colID = find_csv_column(tline,'SPOT_ID');
                colTime = find_csv_column(tline,'FPGA_COUNT');
                colXPos = find_csv_column(tline,'PRIM_IC_X_POSITION');
                colYPos = find_csv_column(tline,'PRIM_IC_Y_POSITION');
                colCharge = find_csv_column(tline,'PRIM_IC_CHARGE');
                colAngle = find_csv_column(tline,'GTRIO_GANTRY_POS');
                colSpeed = find_csv_column(tline,'GTRIO_GANTRY_SPEED');

                % Prepare format spec
                formatSpec = '';
                for i=1:numCols
                    formatSpec = [formatSpec,'%f'];
                end
                formatSpec = [formatSpec,'%[^\n\r]'];

                break
            elseif contains(tline,'SUBMAP_NUMBER')
                numCols = length(strfind(tline,delimiter))+1;
                colElementID = find_csv_column(tline,'DEKIMO_ELEMENT_ID');
                colID = find_csv_column(tline,'SPOT_ID');
                colTime = find_csv_column(tline,'FPGA_COUNT');
                colXPos = find_csv_column(tline,'X_POSITION(mm)');
                colYPos = find_csv_column(tline,'Y_POSITION(mm)');
                colCharge = find_csv_column(tline,'DOSE_PRIM(C)');

                %Prepare format spec
                formatSpec = '';
                for i=1:numCols
                    formatSpec = [formatSpec,'%f'];
                end
                formatSpec = [formatSpec,'%[^\n\r]'];

                break
            end
        end
        fclose(fid);

        % Read file
        fid = fopen(record_filename,'r');
        log = textscan(fid,formatSpec,'Delimiter',delimiter,'EmptyValue',NaN,'HeaderLines',startRow,'ReturnOnError',true);
        fclose(fid);

        % Get log info
        log{colID}(log{colElementID}<=0) = NaN; % remove non-spot IDs
        IDs = unique(log{colID}(log{colID}>0));
        if(not(isempty(IDs)))
            sampling_time = NaN;
            if(length(log{colTime})>1)
                sampling_time = diff(log{colTime}(:));
                sampling_time = round(mean(sampling_time(sampling_time>0))); % sampling time in [us]
            end
            if(isnan(sampling_time))
                sampling_time = 1e3; % default value for C230 dekimo in [us]
            end
        else
            return
        end

        log{colTime} = (0:length(log{colTime})-1)'*sampling_time;
        records{1}.spots(layerIndex).date = layer_date;
        if(spotIndex==1)
            records{1}.spots(layerIndex).layerTime = layer_time;
        end
        for i=1:length(IDs)
            current_charge = log{colCharge}(log{colID}==IDs(i));
            if(isempty(current_charge))
                continue
            end
            current_time = log{colTime}(log{colID}==IDs(i));
            current_x = log{colXPos}(log{colID}==IDs(i));
            current_y = log{colYPos}(log{colID}==IDs(i));
            records{1}.spots(layerIndex).painting(spotIndex,1) = paintingIndex;
            records{1}.spots(layerIndex).spot_id(spotIndex,1) = IDs(i);
            records{1}.spots(layerIndex).charge(spotIndex,1) = sum(current_charge);
            records{1}.spots(layerIndex).xyIC(spotIndex,:) = [current_y(end),current_x(end)] - IC_Offset; % invert x and y (Convert from PHYSICS CS to IEC Gantry CS)
            records{1}.spots(layerIndex).SM_Offset(spotIndex,:) = SM_Offset;
            records{1}.spots(layerIndex).IC_Offset(spotIndex,:) = IC_Offset;
            records{1}.spots(layerIndex).nb_protons(spotIndex,1) = charge2protons(records{1}.spots(layerIndex).charge(spotIndex,1),IC_gain,records{1}.spots(layerIndex).range);
            records{1}.spots(layerIndex).tuning(spotIndex,1) = tuning;
            records{1}.spots(layerIndex).duration(spotIndex,1) = numel(current_charge)*sampling_time; % full duration in [us]
            records{1}.spots(layerIndex).effectiveDuration(spotIndex,1) = (numel(current_charge)-1)*sampling_time + sampling_time*duty_cycle;
            records{1}.spots(layerIndex).timeStart(spotIndex,1) = layer_time + current_time(1);
            records{1}.spots(layerIndex).timeStop(spotIndex,1) = layer_time + current_time(end) + sampling_time*duty_cycle;
            records{1}.spots(layerIndex).time(spotIndex,1) = layer_time + sum(current_time.*current_charge)/sum(current_charge) + sampling_time*duty_cycle/2;% dose-averaged spot time
            if(colAngle>0)
                records{1}.spots(layerIndex).gantry_angle(spotIndex,1) = mean(log{colAngle}(log{colID}==IDs(i)));
            end
            if(colSpeed>0)
                records{1}.spots(layerIndex).gantry_speed(spotIndex,1) = mean(log{colSpeed}(log{colID}==IDs(i)));
            end
            spotIndex = spotIndex + 1;
        end

end

%check that records contain delivery information
if ~isfield(records{1}.spots(layerIndex),'charge')
    disp('Could not find charge in logs. Abort')
    return
end

end


% ----------------------------------------------------------------------
function submap_list = readSubmapNumbersFromSpecif(fileName)

% parameters of log file format
delimiter = ',';
startRow = 1;
numCols = [];
fid = fopen(fileName,'r');

while 1
    startRow = startRow + 1;
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    elseif(contains(tline,'#ELEMENT_ID'))
        numCols = length(strfind(tline,delimiter))+1;
        colID = find_csv_column(tline,'#ELEMENT_ID');
        colType = find_csv_column(tline,'ELEMENT_TYPE');
        break
    end
end
fclose(fid);
if(isempty(numCols))
    disp('Could not find element IDs in specifs. Abort')
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
specif = textscan(fid,formatSpec,'Delimiter',delimiter,'EmptyValue',NaN,'HeaderLines',startRow-1,'ReturnOnError',true);
fclose(fid);

% Get specif info
submap_list = unique(specif{colID}(specif{colType}>0));

end


% ----------------------------------------------------------------------
function [range,layer_id] = readRangeFromSpecif(fileName)

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
        if(not(strcmp(tline(1),'#')))
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
    elseif(contains(tline,ref_string_2{1})) % shreveport get SAD X
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
    elseif(contains(tline,ref_string_2{2})) % shreveprot get SAD Y
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
            SADstring = strsplit(SADstringY{end}, ';');
            SADcoefs = strsplit(SADstringY{end}, ',');
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
function records = merge_tuning_spots(records)
for layerIndex=1:length(records{1}.spots)
    if length(records{1}.spots(layerIndex).weight)>1
        tuning_time = (records{1}.spots(layerIndex).timeStart(2) - records{1}.spots(layerIndex).timeStart(1))*1e-3;% in ms
        while(records{1}.spots(layerIndex).tuning(1)==1)
            index = find(records{1}.spots(layerIndex).spot_id(2:end) == records{1}.spots(layerIndex).spot_id(1),1) + 1;
            if(not(isempty(index))) % Add tuning to spot of same ID
                records{1}.spots(layerIndex).tuning(index,1) = (records{1}.spots(layerIndex).weight(1,1) + records{1}.spots(layerIndex).tuning(index,1)*records{1}.spots(layerIndex).weight(index,1)) / (records{1}.spots(layerIndex).weight(1,1) + records{1}.spots(layerIndex).weight(index,1)) ; % compute ratio of MU used for tuning
                if(isfield(records{1}.spots(layerIndex),'charge'))
                    records{1}.spots(layerIndex).charge(index,1) = records{1}.spots(layerIndex).charge(index,1) + records{1}.spots(layerIndex).charge(1,1); % add tuning charge to corresponding spot
                end
                records{1}.spots(layerIndex).weight(index,1) = records{1}.spots(layerIndex).weight(index,1) + records{1}.spots(layerIndex).weight(1,1); % add tuning MU to corresponding spot
                records{1}.spots(layerIndex).timeTuning = tuning_time;
                % remove tuning
                records{1}.spots(layerIndex) = remove_spot_from_layer(records{1}.spots(layerIndex),1);
                % check if another tuning follows
                if(length(records{1}.spots(layerIndex).timeStart)>1)
                    tuning_time = tuning_time + (records{1}.spots(layerIndex).timeStart(2) - records{1}.spots(layerIndex).timeStart(1))*1e-3;% in ms
                end
            elseif(length(records{1}.spots(layerIndex).spot_id)>1) % Add tuning charge to closest spot
                A = records{1}.spots(layerIndex).xy(2:end,:);
                B = records{1}.spots(layerIndex).xy(1,:);
                D = sqrt(sum(A.^2,2)*ones(1,size(B,1)) + ones(size(A,1),1)*sum(B.^2,2)'-2.*A*B');
                [distance_to_spot,index] = min(D);
                index = index(1)+1;
                if(distance_to_spot<5)
                    records{1}.spots(layerIndex).tuning(index,1) = (records{1}.spots(layerIndex).weight(1,1) + records{1}.spots(layerIndex).tuning(index,1)*records{1}.spots(layerIndex).weight(index,1)) / (records{1}.spots(layerIndex).weight(1,1) + records{1}.spots(layerIndex).weight(index,1)) ; % compute ratio of MU used for tuning
                    if(isfield(records{1}.spots(layerIndex),'charge'))
                        records{1}.spots(layerIndex).charge(index,1) = records{1}.spots(layerIndex).charge(index,1) + records{1}.spots(layerIndex).charge(1,1); % add tuning charge to corresponding spot
                    end
                    records{1}.spots(layerIndex).weight(index,1) = records{1}.spots(layerIndex).weight(index,1) + records{1}.spots(layerIndex).weight(1,1); % add tuning MU to corresponding spot
                    records{1}.spots(layerIndex).timeTuning = tuning_time;
                    % remove tuning
                    records{1}.spots(layerIndex) = remove_spot_from_layer(records{1}.spots(layerIndex),1);
                    % check if another tuning follows
                    if(length(records{1}.spots(layerIndex).timeStart)>1)
                        tuning_time = tuning_time + (records{1}.spots(layerIndex).timeStart(2) - records{1}.spots(layerIndex).timeStart(1))*1e-3;% in ms
                    end
                else % spot fully delivered in tuning
                    records{1}.spots(layerIndex).timeTuning = tuning_time;
                    records{1}.spots(layerIndex).tuning(1) = 1;
                    break
                end
            else
                break
            end
        end
    end
end
end


% ----------------------------------------------------------------------
function layer = remove_spot_from_layer(layer,spotIndex)
global_fields = {'layer','range','date'};
spotNb = length(layer.spot_id);
layer_fields = fieldnames(layer);
for i=1:length(layer_fields)
    if(length(layer.(layer_fields{i})) == spotNb && not(sum(strcmp(layer_fields{i},global_fields))))
        layer.(layer_fields{i}) = layer.(layer_fields{i})([1:spotIndex-1,spotIndex+1:end],:);
    end
end
end


% ----------------------------------------------------------------------
function records = convert_to_relative_time(records)
nb_layers = length(records{1}.spots);
    start_time = records{1}.spots(1).timeStart(1,1);
    for layerIndex=1:nb_layers
        records{1}.spots(layerIndex).timeStart = records{1}.spots(layerIndex).timeStart - start_time;
        records{1}.spots(layerIndex).timeStop = records{1}.spots(layerIndex).timeStop - start_time;
        records{1}.spots(layerIndex).time = records{1}.spots(layerIndex).time - start_time;
        [~,spot_order] = sort(records{1}.spots(layerIndex).timeStart);
        records{1}.spots(layerIndex) = reorder_spots(records{1}.spots(layerIndex),spot_order);
    end
end
