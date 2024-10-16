%% PBS_spot_sorting
% Divide the Pencil Beam Scanning (PBS) spots contained in the treatment plan |plan_name| (stored in |handles.plans|) into several treatment plans, each one of those are associated to one breathing phase of a 4D-CT scan. Only the spots delivered during that breating phase are stored in the corresponding partial treatment plan. The new plans are saved in |handles.plans| with names |[outname,'_',num2str(Phase+1)]| where |Phase| is the breathing phase number in the 4D-CT.
% The timing of the PBS spot is computed using the function |pbs_convert_ScanAlgo| by using the scanalgo gateway.
% The timing of the breathing is determined from a Varian RPM vxp files.
%
%% Syntax
% |[handles, delivery] = PBS_spot_sorting(handles,plan_name,outname,varargin)|
%
%% Description
% |[handles, delivery] = PBS_spot_sorting(handles,plan_name,outname,nb_phases,breathing)|  Divide PBS spots according to breathing phase with default initial phase, the number of repainting defined in |plan| and default room, spot and snout IDs
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.plans.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th treatment plan
% * |handles.plans.data{i}| - _STRUCTURE_ Structure describing the i-th treatment plan
% * |handles.plans.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
%
% |plan_name| _STRING_ - Name of the plan contained in |handles.plans|
%
% |outname| - _STRING_ - Name of the new plan created in |handles.plans|
%
% varargin: List of optional parameters (name of the parameter, followed by the value of the parameter). Such as:
%
%   * |delivery_name| - _STRING_ - Name of irradiation tx record plan in handles
%
%   * |output_pathname| - _STRING_ - Path to export partial plans
%
%   * |nb_phases| - _INTEGER_ - Number of breathing phases present in the 4D-CT scan
%
%   * |breathing| - _STRING_ - File name (including path) of the Varian RPM vxp files containing the breathing signal
%
%   * |initialPhase| - - [OPTIONAL. Default = 1] Specify the breathing phase at the start of spot delivery. Can be either an integer (index of the starting phase), either a non-integer number between 0+eps and 1-eps (relative starting time within the first breathing cycle). |initialPhase| can be:
%
%       * |initialPhase| - _SCALAR VECTOR_ - |initialPhase(b)| Define the initial breathing phase for the b-th beam in the plan
%       * |initialPhase| - _SCALAR_ - The same initial breathing phase is applied to all beams in the plan
%
%   * |nb_paintings| - _INTEGER_ - [OPTIONAL] Number of paintings to apply to all layers. If empty (or missing), the number of painting is read from plan{f}.spots(j).nb_paintings
%
%   * |gateway_IP| - _STRING_ - [OPTIONAL. Default  = ''] IP address where to connect to the scanalgo gateway
%
%   * |room_id| - _STRING_ - [OPTIONAL. Default  = ''] Name of the treatment room in which the plan will be delivered
%
%   * |spot_tune_id| - _STRING_ - [OPTIONAL. Default  = ''] Name of the spot ID to use to deliver the plan
%
%   * |snout_id| - _STRING_ - [OPTIONAL. Default  = ''] Name of the snout to use to deliver the plan
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure. There are |nb_phases| new plans in |handles.plans| with names |[outname,'_',num2str(Phase+1)]|
%
%
% |delivery| - _STRUCTURE_ Description of the timing of the PBS spot delivery.
%
% * |delivery{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy_current(s,:)| - _SCALAR VECTOR_ - Magnet Setpoint (x,y) (in mm) of the s-th spot in the j-th energy layer. The magnets labels are defined in the PHYSICS CS. X-PHYSICS is derived from the Y-IEC GANTRY by exchaging X<->Y axes. So the X-magnet scans along the Y-IEC-GANTRY axis.
% * ----|spots(j).time(s)| - _SCALAR_ - Time stamp (s) of the start  of the s-th spot in the j-th energy layer
% * ----|spots(j).duration(s)| - _SCALAR_ - Duration (s)  of the s-th spot in the j-th energy layer
% * ----|spots(j).weight(s)| - _SCALAR_ - Weight of the s-th spot in the j-th energy layer
% * ----|spots(j).xy_position(s,:)| - _SCALAR VECTOR_ - Coordinates (x,y), as defined in the treatment plan, of the s-th spot in the j-th energy layer. The coordinate system is IEC-GANTRY.
%
%
%% Contributors
% Authors: Guillaume Janssens, Chuan Zeng (2013) & Kevin Souris (2015) (open.reggui@gmail.com)

function [handles, delivery] = PBS_spot_sorting(handles,plan_name,outname,varargin)


% ------------------------------
% Retrieve plan from reggui list
% ------------------------------

[plan,info] = Get_reggui_data(handles,plan_name,'plans');
try
    header = info.OriginalHeader;
catch ME
    reggui_logger.info(['Could not find dicom header for this plan. ',ME.message],handles.log_filename);
    rethrow(ME);
end


% ------------------------------
% Parameters
% ------------------------------

beamFieldNames = fieldnames(header.IonBeamSequence);	% Field names for the treatment beams.
nFields = length(beamFieldNames);

% Default parameters
consistency_tolerance = 0.01;
nb_phases = 10;
breathing = 5;
initialPhase = zeros(nFields,1)+1;
nb_paintings = 1;
use_delay = 0;
config_file = '';
gateway_IP = '';
room_id = '';
spot_tune_id = '';
snout_id = '';
energy_switching_time = [];
angle_switching_time = [];
output_pathname = '';
delivery_name = [];
visu = 0;

% Input parameters
if(nargin>3)
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

% Correct parameters
if(not(isempty(angle_switching_time)))
    initialPhase = initialPhase(1); % if angle_switching_time is specified, only first beam needs an initial breathing phase
elseif(length(initialPhase)<nFields)
    initialPhase = zeros(nFields,1)+initialPhase(1); % unless otherwise specified, all beams start at the same breathing phase (except if angle_switching_time is not emtpy)
end


% --------------------------------
% Breathing signal
% --------------------------------

if(ischar(breathing)) % vxp file
    % Read signal from file
    try
        X = read_vxp(breathing);
    catch ME
        reggui_logger.info(['Failed to open vxp file. ',ME.message],handles.log_filename);
        rethrow(ME);
    end
    % Crop a quasi-periodic (multi-cycles) segment of phase vs. timestamp from X:
    t = X.timestamp;
    phase = X.phase;
    if phase(end)<phase(1)
        w = find(X.mark==-1);
        t = t(1:(w(end)-1));
        phase = phase(1:(w(end)-1));
    end
    w = find(phase<=phase(1));	% Allow ``=" to accommodate mod and interp1 later.
    t = t(1:w(end))-t(1);	% Now t(1) = 0.
    phase = phase(1:w(end));
    phase = mod(floor(phase*4/pi-3.5),nb_phases);	% Now phases are integers of 0, 1, ... 7.
    % Delete signal
    clear X
else % regular breathing
    t = linspace(0,breathing,max(nb_phases,round(breathing*1e3/(100/3)))+1);% in [s]
    phase = floor([1:length(t)]*nb_phases/(length(t)));
    t = t(1:end-1);
    phase = phase(1:end-1);
end

% Compute initial time relative to breathing phase
for f=1:length(initialPhase)
    if(round(initialPhase(f))==initialPhase(f) && sum(mod(initialPhase(f)-1,nb_phases-1)==phase)) % use index of starting phase
        initialPhase(f) = mod(initialPhase(f)-1,nb_phases-1);
        t0(f) = t(find(phase==initialPhase(f),1,'first')); % starting time
    else % relative starting time within breathing cycle
        phase0 = min(phase);
        temp = phase;
        f0 = find(temp==phase0,1,'first');
        c0 = t(f0);
        if(ischar(breathing))
            while temp(f0+1)==temp(f0)
                f0 = f0+1;
            end
            temp(1:f0) = NaN;
            f1 = find(temp==phase0,1,'first');
            if(isempty(f1))
                error('Error: at least a full breathing cycle is required. Abort spot sorting.');
            end
            c1 = t(f1);
            t0(f) = c0 + (c1-c0)*initialPhase(f);
            clear temp
        else
            t0(f) = c0 + breathing*initialPhase(f);
        end
    end
end


% --------------------------------
% Plan copies
% --------------------------------

fractionGroupFieldName = fieldnames(header.FractionGroupSequence);
if length(fractionGroupFieldName)~=1
    error('RNsplit:unexpected_number_of_fraction_groups','Unexpected number of fraction groups');
end
clear header_copies
for iPhase = 0:nb_phases-1
    plan_copies{iPhase+1} = plan;
    header_copies(iPhase+1) = header;
    header_copies(iPhase+1).RTPlanLabel = [header_copies(iPhase+1).RTPlanLabel,'_',num2str(iPhase)];
    if(isfield(header_copies(iPhase+1),'RTPlanName'))
        header_copies(iPhase+1).RTPlanName = [header_copies(iPhase+1).RTPlanName,'_',num2str(iPhase)];
    end
end


% ----------------------------------------
% PBS timing simulation (ScanAlgo) or logs
% ----------------------------------------

if(not(isempty(delivery_name)))
    
    consistency_tolerance = 0.05;
    delivery = Get_reggui_data(handles,delivery_name,'plans');
    
else        
    scanalgo_options = {'nb_paintings',nb_paintings};
    if(exist('config_file','var'))
        if(not(isempty(config_file)))
            scanalgo_options = [scanalgo_options,'config_file',config_file];
        end
    else
        config_file = [];
    end
    if(exist('gateway_IP','var'))
        if(not(isempty(gateway_IP)))
            scanalgo_options = [scanalgo_options,'gateway_IP',gateway_IP];
        end
    end
    if(exist('room_id','var'))
        if(not(isempty(room_id)))
            scanalgo_options = [scanalgo_options,'room_id',room_id];
        end
    end
    if(exist('spot_tune_id','var'))
        if(not(isempty(spot_tune_id)))
            scanalgo_options = [scanalgo_options,'spot_tune_id',spot_tune_id];
        end
    end
    TestScanAlgo = test_ScanAlgo(scanalgo_options);
    if(~TestScanAlgo) % use pre-processed CSV files (records or scanalgo outputs)
        disp('Error: cannot connect to ScanAlgo gateway. Abort');
        return
    else
        % call scanalgo gateway
        delivery = load_DICOM_RT_Records(config_file,'iba_specif',plan,info,'nb_paintings',nb_paintings,'energy_switching_time',energy_switching_time,'gateway_IP',gateway_IP,'room_id',room_id,'spot_tune_id',spot_tune_id,'snout_id',snout_id);
    end
    
end


% ------------
% Spot sorting
% ------------
referencedBeamFieldName=fieldnames(header.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence);
for f=1:nFields
    realFractionationNo(f)=header.FractionGroupSequence.Item_1.ReferencedBeamSequence.(referencedBeamFieldName{f}).ReferencedBeamNumber;
end

for f=1:nFields
    
    if(strcmp(header.IonBeamSequence.(beamFieldNames{f}).TreatmentDeliveryType,'SETUP'))
        disp('Skipping setup beam')
        continue
    end
    
    added_time = 0;
    time_summary{f} = [];
    
    if(length(t0)<f)
        if((time_summary{f-1}(end,3))>(time_summary{f-1}(1,2)+angle_switching_time))
            disp(['Warning: angle switching time was shorter than the delivery of beam ',num2str(f-1)]);
        end
        t0(f) = max(time_summary{f-1}(end,3),time_summary{f-1}(1,2)+angle_switching_time);
    end
    
    layerFieldName = fieldnames(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence);
    nLayer = length(layerFieldName)/2;
    
    % Find corresponding beamset in delivery
    fD = f;
    for j=1:length(delivery)
        if(not(isempty(strfind(plan{f}.name,delivery{j}.name))))
            fD = j;
            break
        end
    end
    
    delivery_index = 0;
    
    for iLayer=1:nLayer
        
        MU_plan = plan{f}.spots(iLayer).weight;
        
        fprintf('%s, Layer %d (%g MeV)\n',...
            header.IonBeamSequence.(beamFieldNames{f}).BeamName,...
            iLayer,...
            header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).NominalBeamEnergy...
            )
        
        %Check header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer}):
        if any(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer}).ScanSpotMetersetWeights~=0)
            fprintf('Non-zero ScanSpotMetersetWeights found in header.IonBeamSequence.%s.IonControlPointSequence.%s!\n',beamFieldNames{f},layerFieldName{2*iLayer});
        end
        if header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer}).NumberOfScanSpotPositions~=header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).NumberOfScanSpotPositions
            fprintf('header.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions does not match header.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions!\n',...
                beamFieldNames{f},...
                layerFieldName{2*iLayer},...
                beamFieldNames{f},...
                layerFieldName{2*iLayer-1}...
                );
        end
        if any(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer}).ScanSpotPositionMap~=header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotPositionMap)
            fprintf('header.IonBeamSequence.%s.IonControlPointSequence.%s.ScanSpotPositionMap does not match header.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions!\n',...
                beamFieldNames{f},...
                layerFieldName{2*iLayer},...
                beamFieldNames{f},...
                layerFieldName{2*iLayer-1}...
                );
        end
        
        % Initialize spot list (with weights put to zero)
        for iPhase=0:nb_phases-1
            if(isfield(plan_copies{iPhase+1}{f}.spots(iLayer),'spot_tune_id'))
                plan_copies{iPhase+1}{f}.spots(iLayer).spot_tune_id = plan_copies{iPhase+1}{f}.spots(iLayer).spot_tune_id;
            end
            plan_copies{iPhase+1}{f}.spots(iLayer).weight = plan_copies{iPhase+1}{f}.spots(iLayer).weight*0;
            header_copies(iPhase+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights=header_copies(iPhase+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights*0;
        end
        
        % Spot data
        delivery_index = delivery_index +1;
        Energy = delivery{fD}.spots(delivery_index).energy;
        T_delivery = delivery{fD}.spots(delivery_index).time + added_time;
        MU_delivery = delivery{fD}.spots(delivery_index).weight;
        if(isfield(delivery{fD}.spots(delivery_index),'xy'))
            XY_delivery = delivery{fD}.spots(delivery_index).xy;
        else
            XY_delivery = delivery{fD}.spots(delivery_index).xy_current(:,[2,1]);
        end
        
        % In case of splitted layers
        splits = 1;
        if(length(delivery{fD}.spots)>delivery_index && iLayer<nLayer)
            look_for_splitted_layer = 1;
            while(look_for_splitted_layer && Energy==delivery{fD}.spots(delivery_index+1).energy)
                disp(['Splitted layer ',num2str(iLayer+1),' (',num2str(size(plan{f}.spots(iLayer).xy,1)),' planned; ',num2str(size(XY_delivery,1)),' delivered during first part)'])
                delivery_index = delivery_index +1;
                splits(end+1) = length(T_delivery)+1;
                T_delivery = [T_delivery;delivery{fD}.spots(delivery_index).time] + added_time;
                MU_delivery = [MU_delivery;delivery{fD}.spots(delivery_index).weight];
                if(isfield(delivery{fD}.spots(delivery_index),'xy'))
                    XY_delivery = [XY_delivery;delivery{fD}.spots(delivery_index).xy];
                else
                    XY_delivery = [XY_delivery;delivery{fD}.spots(delivery_index).xy_current(:,[2,1])];
                end
                if(not(length(delivery{fD}.spots)>delivery_index))
                    look_for_splitted_layer = 0;
                end
            end
        end
        splits(end+1) = length(T_delivery)+1;
        
        % Correct xy delivery positions
        xy_proxy = XY_delivery;
        %         x_ratio = max(plan{f}.spots(iLayer).xy(:,1))/max(unique(roundsd(xy_proxy(:,1),4)));
        %         y_ratio = max(plan{f}.spots(iLayer).xy(:,2))/max(unique(roundsd(xy_proxy(:,2),4)));
        %         xy_proxy(:,1) = xy_proxy(:,1)*x_ratio;
        %         xy_proxy(:,2) = xy_proxy(:,2)*y_ratio;
        D = sum(xy_proxy.^2,2)*ones(1,size(plan{f}.spots(iLayer).xy,1)) + ones(size(xy_proxy,1),1)*sum(plan{f}.spots(iLayer).xy.^2,2)'-2.*xy_proxy*plan{f}.spots(iLayer).xy';
        for j=1:size(xy_proxy,1)
            [~,index] = min(D(j,:));
            XY_delivery(j,:) = plan{f}.spots(iLayer).xy(index,:);
        end
        
        % Normalize weights to match plan
        MU_delivery = MU_delivery*sum(MU_plan)/sum(MU_delivery);
        
        % Compute and add delay if necessary
        if(use_delay)
            for seq=1:length(splits)-1
                T_seq = T_delivery(splits(seq):splits(seq+1)-1);
                X_seq = XY_delivery(splits(seq):splits(seq+1)-1,:);
                % identify paintings
                repetitions = zeros(length(T_seq),length(T_seq));
                for s=1:length(T_seq)
                    repetitions(s,:) = (X_seq(:,1)==X_seq(s,1) & X_seq(:,2)==X_seq(s,2));
                end
                repetitions = sum(repetitions,2);
                n = max(repetitions);
                repetitions = repetitions==n;
                index = find(repetitions>0);
                index = find(X_seq(:,1)==X_seq(index(1),1) & X_seq(:,2)==X_seq(index(1),2));
                t_start = T_seq(1);
                for j=2:length(index)
                    t_start(j) = T_seq(index(j));
                end
                Tdel = T_seq(end)-T_seq(1);
                Nbc = ceil(Tdel/breathing);
                delay = (Nbc*breathing-Tdel)/n;
                for j=2:length(index)
                    T_seq(index(j):end) = T_seq(index(j):end)+delay;
                    added_time = added_time + delay;
                end
                T_delivery(splits(seq+1):end) = T_delivery(splits(seq+1):end) + (length(index)-1)*delay;
                T_delivery(splits(seq):splits(seq+1)-1) = T_seq;
            end
        end
        
        % Assign phase to spots
        SpotPhase = interp1(t,phase,mod(T_delivery+t0(f),t(end)),'nearest');
        time_summary{f}(end+1:end+length(T_delivery),:) = [Energy*ones(size(T_delivery)),T_delivery,SpotPhase+1];
        
        % find correspondance between YX from ScanAlgo and XY position from Dicom plan
        D = sum(XY_delivery.^2,2)*ones(1,size(plan{f}.spots(iLayer).xy,1)) + ones(size(XY_delivery,1),1)*sum(plan{f}.spots(iLayer).xy.^2,2)'-2.*XY_delivery*plan{f}.spots(iLayer).xy';
        for iSpot=1:size(MU_delivery,1)
            [~,index] = min(D(iSpot,:));
            plan_copies{SpotPhase(iSpot)+1}{f}.spots(iLayer).weight(index) = plan_copies{SpotPhase(iSpot)+1}{f}.spots(iLayer).weight(index) + MU_delivery(iSpot);
            header_copies(SpotPhase(iSpot)+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights(index) = header_copies(SpotPhase(iSpot)+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights(index) + MU_delivery(iSpot) * plan{f}.final_weight / plan{f}.BeamMeterset;
        end
        
    end	%for iLayer=1:nLayer
    
    
    % ------------------------
    % Beam meterset correction
    % ------------------------
    
    totalWeight=0;
    totalWeight_copies=zeros(nb_phases,1);
    
    %Find the total weight for each phase:
    for iLayer=1:nLayer
        totalWeight=totalWeight+sum(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights);
    end
    for iLayer=1:nLayer
        for iPhase=0:nb_phases-1
            totalWeight_copies(iPhase+1)=totalWeight_copies(iPhase+1)+...
                sum(header_copies(iPhase+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights);
        end
    end
    referencedBeamFieldName=fieldnames(header.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence);
    for iPhase=0:nb_phases-1
        % update header
        FractionSequenceBeamID = find(realFractionationNo==header.IonBeamSequence.(beamFieldNames{f}).BeamNumber); % The beam order may be different in IonBeamSequence and FractionGroupSequence
        header_copies(iPhase+1).FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence.(referencedBeamFieldName{FractionSequenceBeamID}).BeamMeterset = header.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence.(referencedBeamFieldName{f}).BeamMeterset...
            *totalWeight_copies(iPhase+1)/totalWeight;
        header_copies(iPhase+1).IonBeamSequence.(beamFieldNames{f}).FinalCumulativeMetersetWeight = totalWeight_copies(iPhase+1);
        plan_copies{iPhase+1}{f}.BeamMeterset = header.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence.(referencedBeamFieldName{FractionSequenceBeamID}).BeamMeterset * totalWeight_copies(iPhase+1) / totalWeight;
        plan_copies{iPhase+1}{f}.final_weight = totalWeight_copies(iPhase+1);
    end
    
    
    % -----------------
    % Consistency check
    % -----------------
    
    header_reproduced=header;
    for iLayer=1:nLayer
        
        header_reproduced.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights=header_reproduced.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights*0;
        for iPhase=0:nb_phases-1
            header_reproduced.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights=header_reproduced.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights+...
                header_copies(iPhase+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights;
        end
        
        idx_inconsistent=find(abs(header_reproduced.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights./header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights-1)>consistency_tolerance);
        nInconsistent=length(idx_inconsistent);
        if nInconsistent>0
            fprintf('Consistency check  -  ')
            fprintf('%s, Layer %d (%g MeV) ...',...
                header.IonBeamSequence.(beamFieldNames{f}).BeamName,...
                iLayer,...
                header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).NominalBeamEnergy...
                )
            fprintf('%d inconsistent spot(s) out of %d.\n',...
                nInconsistent,...
                header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).NumberOfScanSpotPositions...
                );
            for iInconsistent=1:nInconsistent
                fprintf('Original weight: %g\nReproduced weight: %g\n',...
                    header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights(idx_inconsistent(iInconsistent)),...
                    header_reproduced.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights(idx_inconsistent(iInconsistent))...
                    );
            end
        end
        
    end	% for iLayer=1:nLayer
    
end % for f=1:nFields


% --------------
% Display timing
% --------------
if(visu)
    figure
    for f=1:nFields
        if(strcmp(header.IonBeamSequence.(beamFieldNames{f}).TreatmentDeliveryType,'SETUP'))
            continue
        end
        subplot(nFields,1,f);
        if(f==1)
            if(use_delay)
                title(['Spot delivery with delay  ',strrep(strrep(output_pathname,'\','\\'),'_','\_')])
            else
                title(['Spot delivery (without delay)  ',strrep(strrep(output_pathname,'\','\\'),'_','\_')])
            end
        end
        hold on
        Es = time_summary{f}(:,1);
        E = unique(Es);
        for j=1:length(E)
            plot(time_summary{f}(Es==E(j),2),time_summary{f}(Es==E(j),3),'.');
        end
        ylabel('Breathing phase')
    end
    xlabel('Absolute time [s]')
    figure
    for f=1:nFields
        if(strcmp(header.IonBeamSequence.(beamFieldNames{f}).TreatmentDeliveryType,'SETUP'))
            continue
        end
        subplot(nFields,1,f);
        if(f==1)
            if(use_delay)
                title(['Spot delivery with delay  ',strrep(strrep(output_pathname,'\','\\'),'_','\_')])
            else
                title(['Spot delivery (without delay)  ',strrep(strrep(output_pathname,'\','\\'),'_','\_')])
            end
        end
        hold on
        Es = time_summary{f}(:,1);
        E = unique(Es);
        indic = [];
        for j=1:length(E)
            p = time_summary{f}(Es==E(j),3);
            scatter(time_summary{f}(Es==E(j),1),p,100,'filled','s');
            p = unique(p);
            indic(j) = 100*length(p)/nb_phases;%/max(diff(sort([p;p+nb_phases])));
        end
        ylabel('Breathing phase')
        axis([min(time_summary{f}(:,1))-5 max(time_summary{f}(:,1))+5 min(time_summary{f}(:,3))-1 max(time_summary{f}(:,3))+1])
        disp(mean(indic))
    end
    xlabel('Energy [MeV]')
end


% ------------
% Print timing
% ------------

disp(' ')
for f=1:nFields
    if(strcmp(header.IonBeamSequence.(beamFieldNames{f}).TreatmentDeliveryType,'SETUP'))
        continue
    end
    total_time(f) = (delivery{1,f}.spots(end).time(end)-delivery{1,f}.spots(1).time(1));
    disp(['Irradiation time for beam ',num2str(f),' = ',num2str(total_time(f)),' s (',num2str(length(delivery{1,f}.spots)),' layers)'])
end
disp(['Total irradiation time = ',num2str(sum(total_time)/60),' min '])


% -----------------
% Update Metersets
% -----------------

for iPhase=1:nb_phases
    for f=1:nFields
        if(strcmp(header.IonBeamSequence.(beamFieldNames{f}).TreatmentDeliveryType,'SETUP'))
            continue
        end
        layerFieldName = fieldnames(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence);
        cum_meterset = 0;
        for i=1:length(layerFieldName)
            header_copies(iPhase).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{i}).CumulativeMetersetWeight = cum_meterset;
            cum_meterset = cum_meterset + sum(header_copies(iPhase).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{i}).ScanSpotMetersetWeights);
        end
        header_copies(iPhase).IonBeamSequence.(beamFieldNames{f}).FinalCumulativeMetersetWeight = cum_meterset;
    end
end


% ------------------
% Remove empty beams
% ------------------

for iPhase=1:nb_phases
    corrected_IonBeamSequence = struct;
    corrected_ReferencedBeamSequence = struct;
    for f=1:nFields
        if(strcmp(header.IonBeamSequence.(beamFieldNames{f}).TreatmentDeliveryType,'SETUP'))
            continue
        end
        if(header_copies(iPhase).IonBeamSequence.(beamFieldNames{f}).FinalCumulativeMetersetWeight>0 || (f==nFields && isempty(fieldnames(corrected_IonBeamSequence))) )
            item = length(fieldnames(corrected_IonBeamSequence))+1;
            corrected_IonBeamSequence.(['Item_',num2str(item)]) = header_copies(iPhase).IonBeamSequence.(beamFieldNames{f});
            corrected_IonBeamSequence.(['Item_',num2str(item)]).BeamNumber = length(fieldnames(corrected_IonBeamSequence));
            corrected_ReferencedBeamSequence.(['Item_',num2str(item)]) = header_copies(iPhase).FractionGroupSequence.Item_1.ReferencedBeamSequence.(beamFieldNames{f});
            corrected_ReferencedBeamSequence.(['Item_',num2str(item)]).ReferencedBeamNumber = length(fieldnames(corrected_ReferencedBeamSequence));
            if(header_copies(iPhase).IonBeamSequence.(beamFieldNames{f}).FinalCumulativeMetersetWeight==0) % if no beam with non-zero MUs
                corrected_IonBeamSequence.(['Item_',num2str(item)]).IonControlPointSequence.Item_1.ScanSpotMetersetWeights(1) = 1e-3;
                corrected_IonBeamSequence.(['Item_',num2str(item)]).FinalCumulativeMetersetWeight = 1e-3;
                corrected_ReferencedBeamSequence.(['Item_',num2str(item)]).BeamMeterset = 1e-3;
                layerFieldName = fieldnames(corrected_IonBeamSequence.(['Item_',num2str(item)]).IonControlPointSequence);
                for i=2:length(layerFieldName)
                    corrected_IonBeamSequence.(['Item_',num2str(item)]).IonControlPointSequence.(layerFieldName{i}).CumulativeMetersetWeight = 1e-3;
                end
            end
        else
            disp(['Beam ',num2str(f),' is empty for phase ',num2str(iPhase),'. Remove beam.'])
            plan_copies{iPhase} = plan_copies{iPhase}([1:f-1,f+1:end]);
        end
    end
    header_copies(iPhase).IonBeamSequence = corrected_IonBeamSequence;
    header_copies(iPhase).FractionGroupSequence.Item_1.NumberOfBeams = length(fieldnames(header_copies(iPhase).IonBeamSequence));
    header_copies(iPhase).FractionGroupSequence.Item_1.ReferencedBeamSequence = corrected_ReferencedBeamSequence;
end


% ----------------------------
% Add result to reggui handles
% ----------------------------

disp('Adding plans to the list...')
for i=1:nb_phases
    plan_copies{i} = remove_low_MU_spots(plan_copies{i},0.001);
    myPlanName{i} = check_existing_names([outname,'_',num2str(i)],handles.plans.name);
    handles.plans.name{length(handles.plans.name)+1} = myPlanName{i};
    handles.plans.data{length(handles.plans.data)+1} = plan_copies{i};
    info.OriginalHeader = header_copies(i);
    info.OriginalHeader.ApprovalStatus = 'UNAPPROVED';
    handles.plans.info{length(handles.plans.info)+1} = info;
end


% --------------------
% Export partial plans
% --------------------

if(not(isempty(output_pathname)))
    if(not(isfolder(output_pathname)))
       mkdir(output_pathname); 
    end
    if(not(isfolder(fullfile(output_pathname,'remvove_zero_weights'))))
        mkdir(fullfile(output_pathname,'remvove_zero_weights'));
    end
    for i=1:nb_phases
        iRNfile=fullfile(output_pathname,['partial_plan_',num2str(i),'.dcm']);
        dicomwrite([],iRNfile,header_copies(i),'CreateMode','copy');  
        iRNfile=fullfile(output_pathname,'remvove_zero_weights',['partial_plan_',num2str(i),'.dcm']);
        output_info.OriginalHeader = header_copies(i);
        save_Plan_PBS(plan_copies{i},iRNfile,'dcm',output_info,[],{'ApprovalStatus','UNAPPROVED'});
    end
end

end
