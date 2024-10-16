%% pbs_spot_sorting_standalone
% Divide the Pencil Beam Scanning (PBS) spots contained in the treatment plan |dicom_filename| (stored in a DICOM file) into several partial treatment plans, each one of those are associated to one breathing phase of a 4D-CT scan. Only the spots delivered during that breating phase are stored in the corresponding partial treatment plan. The new plans are saved in DICOM files in the directory |output_pathname| with names |['partial_plan_',num2str(Phase)] '.dcm'| where |Phase| is the breathing phase number in the 4D-CT.
% The timing of the PBS spot is computed using the function |pbs_convert_ScanAlgo| by using the scanalgo gateway.
% The timing of the breathing is determined from a Varian RPM vxp files.
%
%% Syntax
% |[header_copies, delivery] = pbs_spot_sorting_standalone()|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename)|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname)|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id)|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id)|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP)|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP,nb_phases,breathing)|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP,nb_phases,breathing,initialPhase)|
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP,nb_phases,breathing,initialPhase,energy_switching_time)|
%
%
%% Description
% |[header_copies, delivery] = pbs_spot_sorting_standalone()|  Divide PBS spots according to breathing phase (sinusoid with default period) with default initial phase, the number of repainting defined in |plan| and default snout ID and default switching energy. Display dialog boxes to select the DICOM file. The partiel plan are save in default directory.
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename)| Divide PBS spots according to breathing phase (sinusoid with default period) with default initial phase, the number of repainting defined in |plan| and default snout ID and default switching energy. The partiel plan are save in default directory.
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname)| Divide PBS spots according to breathing phase (sinusoid with default period) with default initial phase, the number of repainting defined in |plan| and default snout ID and default switching energy. The partiel plan are save in specified directory.
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP)| Divide PBS spots according to breathing phase (sinusoid with default period) with default initial phase, the number of repainting defined in |plan| and specified room, spot at snout IDs, specified gateway IP address and default switching energy. The partiel plan are save in specified directory.
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP,nb_phases,breathing)| Divide PBS spots according to breathing phase with default initial phase, the number of repainting defined in |plan| and specified room, spot at snout IDs, specified gateway IP address and default switching energy. The partiel plan are save in specified directory.
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP,nb_phases,breathing,initialPhase)| Divide PBS spots according to breathing phase with specified initial phase, the number of repainting defined in |plan| and specified room, spot at snout IDs, specified gateway IP address and default switching energy. The partiel plan are save in specified directory.
%
% |[header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP,nb_phases,breathing,initialPhase,energy_switching_time)| Divide PBS spots according to breathing phase with specified initial phase, the number of repainting defined in |plan| and specified room, spot at snout IDs, specified gateway IP address and specified switching energy. The partiel plan are save in specified directory.
%
%
%% Input arguments
% |dicom_filename| _STRING_ - [OPTIONAL] Name of the DICOM file (including path) of the original PBS treatment plan. If absent, a dialog box is displayed to select the DICOM file.
%
% |output_pathname| - _STRING_ - [OPTIONAL] Name ofthe folder in which the new plan will be saved in DICOM files. If absent, the partial plans are saved in the same directory as the inital plan.
%
% |room_id| - _STRING_ - [OPTIONAL. Default = 'GTR1'] Name of the treatment room in which the plan will be delivered
%
% |spot_tune_id| - _STRING_ - [OPTIONAL. Default  = ''] Name of the spot ID to use to deliver the plan
%
% |snout_id| - _STRING_ - [OPTIONAL. Default  = 'US Snout'] Name of the snout to use to deliver the plan
%
% |gateway_IP| - _STRING_ - [OPTIONAL. Default  = '127.0.0.1:8080'] IP address where to connect to the scanalgo gateway
%
% |nb_phases| - _INTEGER_ - [OPTIONAL. Default =10] Number of breathing phases present in the 4D-CT scan
%
% |breathing| - - [OPTIONAL. Default = 4] Breathing signal. It can be
%
% * |breathing| - _STRING_ - File name (including path) of the Varian RPM vxp files containing the breathing signal
% * |breathing| - _SCALAR_ - Period (s) of a simulated sinusoidal breathing signal
%
% |initialPhase| - - [OPTIONAL. Default = 1] Specify the breathing phase at the start of spot delivery. Can be either an integer (index of the starting phase), either a non-integer number between 0+eps and 1-eps (relative starting time within the first breathing cycle). |initialPhase| can be:
%
% * |initialPhase| - _SCALAR VECTOR_ - |initialPhase(b)| Define the initial breathing phase for the b-th beam in the plan
% * |initialPhase| - _SCALAR_ - The same initial breathing phase is applied to all beams in the plan
%
% |energy_switching_time| - _SCALAR_ - [OPTIONAL. Default = 2] Time (s) to switch between energy layers
%
%
%% Output arguments
%
% |header_copies| - _STRUCTURE_ - |header_copies(b)| DICOM structure of the partial treatment plan associated with the b-th breathing phase
%
% |delivery| - _STRUCTURE_ Description of the timing of the PBS spot delivery.
%
% * |delivery{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy_current(s,:)| - _SCALAR VECTOR_ - Setpoint (x,y) (in mm) of the s-th spot in the j-th energy layer
% * ----|spots(j).time(s)| - _SCALAR_ - Time stamp (s) of the start  of the s-th spot in the j-th energy layer
% * ----|spots(j).duration(s)| - _SCALAR_ - Duration (s)  of the s-th spot in the j-th energy layer
% * ----|spots(j).charge(s)| - _SCALAR_ - Electric charge of the s-th spot in the j-th energy layer
% * ----|spots(j).xy_position(s,:) - _SCALAR VECTOR_ - Coordinates (x,y), as defined in the treatment plan, of the s-th spot in the j-th energy layer. The coordinate system is IEC-GANTRY.
%
%
%% Contributors
% Authors: Guillaume Janssens, Chuan Zeng (2013) & Kevin Souris (2015) (open.reggui@gmail.com)

function [header_copies, delivery] = pbs_spot_sorting_standalone(dicom_filename,output_pathname,room_id,spot_tune_id,snout_id,gateway_IP,nb_phases,breathing,initialPhase,energy_switching_time,nb_paintings,angle_switching_time)


% ------------------------------
% Import DICOM header
% ------------------------------

if(nargin<1)
    [filename, pathname] = uigetfile( ...
        {'*.dcm','DICOM-files (*.dcm)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select RT plan', ...
        'MultiSelect', 'off');
    dicom_filename = fullfile(pathname,filename);
else
    [pathname,filename] = fileparts(dicom_filename);
end

header = dicominfo(dicom_filename);
if(not(isfield(header,'IonBeamSequence')))
    error('Error: unvalid DICOM file (no IonBeamSequence found). Abort spot sorting.')
end


% ------------------------------
% Parameters
% ------------------------------

beamFieldNames = fieldnames(header.IonBeamSequence); % Field names for the treatment beams.
nFields = length(beamFieldNames);

% default values
if(nargin<2)
    output_pathname = pathname;
end
if(nargin<3)
    room_id = 'GTR1';
end
if(nargin<4)
    spot_tune_id = 'Spot1';
end
if(nargin<5)
    snout_id = 'US_Snout';
end
if(nargin<6)
    gateway_IP = '';
end
if(nargin<7)
    nb_phases = 10;
end
if(nargin<8)
    breathing = 4;
end
if(nargin<9) % initialPhase from [1:nb_phases]
    initialPhase = zeros(nFields,1)+1;
end
if(nargin<10)
    energy_switching_time = [];
end
if(nargin<11)
    nb_paintings = [];
end
if(nargin<12)
    angle_switching_time = [];
end

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
    t = linspace(0,breathing*1000,round(breathing*1000/(100/3))+1);
    phase = floor([1:length(t)]*nb_phases/(length(t)));
    t = t(1:end-1);
    phase = phase(1:end-1);
end

% Compute initial time relative to breathing phase
for f=1:length(initialPhase)
    if(round(initialPhase(f))==initialPhase(f)) % use index of starting phase
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
            t0(f) = c0 + (breathing*1e3)*initialPhase(f);
        end
    end
end


% --------------------------------
% Plan copies
% --------------------------------

plan = load_DICOM_RT_Plan(dicom_filename);
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


% --------------------------------
% PBS timing simulation (ScanAlgo)
% --------------------------------

TestScanAlgo = test_ScanAlgo({'gateway_IP',gateway_IP,'room_id',room_id,'spot_tune_id',spot_tune_id});

if(~TestScanAlgo) % use pre-processed CSV files (records or scanalgo outputs)
    disp('Error: cannot connect to ScanAlgo gateway. Abort');
    return
    %     if(specif) % scanalgo standalone results
    %         % TBD
    %     else % pbs records
    %         % TBD
    %     end
else
    % call scanalgo gateway
    delivery = pbs_convert_ScanAlgo(plan,{'nb_paintings',nb_paintings,'gateway_IP',gateway_IP,'room_id',room_id,'spot_tune_id',spot_tune_id,'snout_id',snout_id,'energy_switching_time',energy_switching_time,'dicom_filename',dicom_filename});
end


% ------------
% Spot sorting
% ------------
referencedBeamFieldName=fieldnames(header.FractionGroupSequence.(fractionGroupFieldName{1}).ReferencedBeamSequence);
for f=1:nFields
    realFractionationNo(f)=header.FractionGroupSequence.Item_1.ReferencedBeamSequence.(referencedBeamFieldName{f}).ReferencedBeamNumber;
end

for f=1:nFields
    
    time_summary{f} = [];
    
    if(length(t0)<f)
        if((time_summary{f-1}(end,3))>(time_summary{f-1}(1,2)+angle_switching_time*1e3))
            disp(['Warning: angle switching time was shorter than the delivery of beam ',num2str(f-1)]);
        end
        t0(f) = max(time_summary{f-1}(end,3),time_summary{f-1}(1,2)+angle_switching_time*1e3);
    end
    
    layerFieldName = fieldnames(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence);
    nLayer = length(layerFieldName)/2;
    
    delivery_index = 0;
    
    for iLayer=1:nLayer
        
        fprintf('%s, Layer %d (%g MeV)\n',...
            header.IonBeamSequence.(beamFieldNames{f}).BeamName,...
            iLayer,...
            header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).NominalBeamEnergy...
            )
        
        % Check header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer}):
        try
            if any(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer}).ScanSpotMetersetWeights~=0)
                fprintf('Non-zero ScanSpotMetersetWeights found in header.IonBeamSequence.%s.IonControlPointSequence.%s!\n',beamFieldNames{f},layerFieldName{2*iLayer});
            end
        catch
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
        
        % Initialize spot weights to zero
        for iPhase=0:nb_phases-1
            plan_copies{iPhase+1}{f}.spots(iLayer).weight = plan_copies{iPhase+1}{f}.spots(iLayer).weight*0;
            header_copies(iPhase+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights=header_copies(iPhase+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights*0;
        end
        
        % Spot data
        delivery_index = delivery_index +1;
        Energy = delivery{f}.spots(delivery_index).energy;
        Charge = delivery{f}.spots(delivery_index).charge;
        StartTime = delivery{f}.spots(delivery_index).time;
        if(isfield(delivery{f}.spots(delivery_index),'xy'))
            XY_Current = delivery{f}.spots(delivery_index).xy;
        else
            XY_Current = delivery{f}.spots(delivery_index).xy_current;
        end
        
        % In case of splitted layers
        if(length(delivery{f}.spots)>delivery_index && iLayer<nLayer)
            look_for_splitted_layer = 1;
            while(look_for_splitted_layer && Energy==delivery{f}.spots(delivery_index+1).energy)
                disp(['Splitted layer ',num2str(iLayer+1),' (',num2str(size(XY_Position,1)),' expected but only ',num2str(max(Current_index)),' delivered during first part)'])
                delivery_index = delivery_index +1;
                Charge = [Charge;delivery{f}.spots(delivery_index).charge];
                StartTime = [StartTime;delivery{f}.spots(delivery_index).time];
                if(isfield(delivery{f}.spots(delivery_index),'xy'))
                    XY_Current = [XY_Current;delivery{f}.spots(delivery_index).xy];
                else
                    XY_Current = [XY_Current;delivery{f}.spots(delivery_index).xy_current];
                end
                if(not(length(delivery{f}.spots)>delivery_index))
                    look_for_splitted_layer = 0;
                end
            end
        end
        
        % Find the correspondance between YX from ScanAlgo and XY position from Dicom plan
        All_Currents = roundsd(XY_Current(:,2),5) + 1e4*roundsd(XY_Current(:,1),5);
        Currents = unique(All_Currents, 'stable');
        [~, Current_index] = sort(Currents);
        [~, Current_index] = sort(Current_index);
        XY_Position = reshape(header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotPositionMap, 2, header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).NumberOfScanSpotPositions)';
        Positions = roundsd(XY_Position(:,1),5) + 1e4*roundsd(XY_Position(:,2),5);
        [~, Position_index] = sort(Positions);
        
        if(not(max(Current_index)==length(Position_index)))
            disp(['Mismatch in number of spots for layer ',num2str(iLayer),' (',num2str(length(Position_index)),' expected, ',num2str(max(Current_index)),' delivered)'])
        end
        
        Position_index = Position_index(Current_index);
        [~, All_Currents_index] = ismember(All_Currents, Currents);
        All_Position_index = Position_index(All_Currents_index);
        
        % Compute weights
        TotalCharge = zeros(size(XY_Position,1),1);
        for iSpot=1:size(Charge, 1)
            TotalCharge(All_Position_index(iSpot)) = TotalCharge(All_Position_index(iSpot)) + Charge(iSpot);
        end
        Weight = Charge ./ TotalCharge(All_Position_index);
        
        % Assign phase to spots
        SpotPhase = interp1(t,phase,mod(StartTime+t0(f),t(end)),'nearest');
        time_summary{f}(end+1,:) = [Energy,StartTime(1)+t0(f),StartTime(end)+t0(f),SpotPhase(1),SpotPhase(end)];
        
        % Generate partial plans
        for iSpot=1:size(Charge, 1)
            plan_copies{SpotPhase(iSpot)+1}{f}.spots(iLayer).weight(All_Position_index(iSpot)) = plan_copies{SpotPhase(iSpot)+1}{f}.spots(iLayer).weight(All_Position_index(iSpot)) + Weight(iSpot) * plan{f}.spots(iLayer).weight(All_Position_index(iSpot));
            header_copies(SpotPhase(iSpot)+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights(All_Position_index(iSpot)) = header_copies(SpotPhase(iSpot)+1).IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights(All_Position_index(iSpot)) + Weight(iSpot) * header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights(All_Position_index(iSpot)) * plan{f}.final_weight / plan{f}.BeamMeterset;
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
        
        idx_inconsistent=find(abs(header_reproduced.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights./header.IonBeamSequence.(beamFieldNames{f}).IonControlPointSequence.(layerFieldName{2*iLayer-1}).ScanSpotMetersetWeights-1)>.01);
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
visu = 0;
if(visu)
    figure
    hold on
    for f=1:nFields
        for i=1:size(time_summary{f},1)
            plot(time_summary{f}(i,2:3)/1e3,time_summary{f}(i,4:5));
        end
    end
    title('Timing summary')
    xlabel('Absolute time [s]')
    ylabel('Breathing phase')
end


% ------------
% Print timing
% ------------

disp(' ')
for f=1:nFields
    total_time(f) = (delivery{1,f}.spots(end).time(end)-delivery{1,f}.spots(1).time(1))/1e3;
    disp(['Irradiation time for beam ',num2str(f),' = ',num2str(total_time(f)),' s (',num2str(length(delivery{1,f}.spots)),' layers)'])
end
total_time = max((time_summary{end}(end,3)-time_summary{1}(1,2))/1e3,sum(total_time)/1e3);
disp(['Total irradiation time = ',num2str(total_time),' s '])


% -----------------
% Update Metersets
% -----------------

for iPhase=1:nb_phases
    for f=1:nFields
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
        end
    end
    header_copies(iPhase).IonBeamSequence = corrected_IonBeamSequence;
    header_copies(iPhase).FractionGroupSequence.Item_1.NumberOfBeams = length(fieldnames(header_copies(iPhase).IonBeamSequence));
    header_copies(iPhase).FractionGroupSequence.Item_1.ReferencedBeamSequence = corrected_ReferencedBeamSequence;
end


% --------------------
% Export partial plans
% --------------------

if(not(isempty(output_pathname)))
    for iPhase=1:nb_phases
        iRNfile=fullfile(output_pathname,['partial_plan_',num2str(iPhase),'.dcm']);
        dicomwrite([],iRNfile,header_copies(iPhase),'CreateMode','copy');
    end
end

end


% ----------------------------------------------------------------------
function [t,d,c,x,y] = import_specif(filename)
delimiter = ',';
startRow = 6;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
ELEMENT_ID = dataArray{:, 1};
SPOT_ID = dataArray{:, 2};
MAX_DURATION = dataArray{:, 6};
TARGET_CHARGE = dataArray{:, 7};
X_POS_HIGH = dataArray{:, 48};
Y_POS_HIGH = dataArray{:, 50};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
t = MAX_DURATION;
d = MAX_DURATION/1.5;
c = TARGET_CHARGE;
x = X_POS_HIGH;
x(abs(x)>=250) = NaN;
y = Y_POS_HIGH;
y(abs(y)>=250) = NaN;
t(not(isnan(x))) = t(not(isnan(x)))/1.5; % MAX_DURATION for spots is 1.5 times the expected duration (to be confirmed)
t = cumsum(t);
t = t-t(1);
% keep spots only
t = t(not(isnan(y)));
d = d(not(isnan(y)));
c = c(not(isnan(y)));
x = x(not(isnan(y)));
y = y(not(isnan(y)));
end

% ----------------------------------------------------------------------
function [t,d,c,x,y] = import_record(filename)
delimiter = ',';
startRow = 14;
formatSpec = '%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
TIME = dataArray{:, 2};
X_POSITIONmm = dataArray{:, 5};
Y_POSITIONmm = dataArray{:, 6};
BEAMCURRENTV = dataArray{:, 31};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
t = zeros(1,length(TIME));
c = BEAMCURRENTV;
x = X_POSITIONmm;x(x==-10000)=NaN;
y = Y_POSITIONmm;y(y==-10000)=NaN;
for i=1:length(t)
    s = TIME{i};
    j = strfind(s,' ');
    s = strrep(s(j(1)+1:j(2)),':','');
    t(i) = str2num(s);
end
t = t-t(1);
end
