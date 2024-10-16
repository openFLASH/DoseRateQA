%% convert_Plan_PBS
% Convert a Matlab structure describing the spot map of a Pencil Beam Scanning (PBS) treatment plan in to cell vector of text strings that can sent to the "scanalgo" gateway (see function |pbs_convert_ScanAlgo|).
%
%% Syntax
% |Plan_text = convert_Plan_PBS(plan,format)|
%
% |Plan_text = convert_Plan_PBS(plan,format,nb_paintings)|
%
% |Plan_text = convert_Plan_PBS(plan,format,nb_paintings,room_id)|
%
% |Plan_text = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id)|
%
% |Plan_text = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id)|
%
%
%% Description
% |Plan_text = convert_Plan_PBS(plan,format)| Convert the plan using default room, spot and snout IDs and the number of repainting defined in |plan|
%
% |Plan_text = convert_Plan_PBS(plan,format,nb_paintings)| Convert the plan using default room, spot and snout IDs and fixed number of repainting
%
% |Plan_text = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id)| Convert the plan using fixed number of repainting and specified room, spot and snout IDs
%
%
%% Input arguments
% |plan| - _STRUCTURE_ - Description of the treatment plan
%
% * |plan{f}.gantry_angle|  - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
% * |plan{f}.table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
% * |plan{f}.isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
% * |plan{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).nb_paintings| - _INTEGER_ - Number of painting for the j-th energy layer
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer. The coordinate system is IEC-GANTRY.
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer

%
% |format| - _STRING_ - Define the format of the text in the structure |Plan_text| describing the PBS spots. The options are :'json', 'gate, 'pld''. Note: support for 'xml' is not implemented.
%
% |nb_paintings| - _INTEGER_ - [OPTIONAL] Number of paintings to apply to all layers. If empty (or missing), the number of painting is read from plan{f}.spots(j).nb_paintings
%
% |room_id| - _STRING_ -  [OPTIONAL. default = 'GTR1'] Name of the treatment room in which the plan will be delivered
%
% |spot_tune_id| - _STRING_ -  [OPTIONAL. default = 'Spot1'] Spot ID
%
% |snout_id| - _STRING_ - [OPTIONAL. Default  = ''] Name of the snout to use to deliver the plan
%
%
%% Output arguments
%
% |Plan_text| - _CELL VECTOR of STRING_ - |Plan_text{f}|  f-th text strings describing the PBS plan to be sent to scanlago. The format of the text line is specified in |format|.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [Plan_text,plan] = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id,sort_spots)

endl = java.lang.System.getProperty('line.separator').char;

% default parameters
if(nargin<3)
    nb_paintings = [];
end
if(nargin<4)
    room_id = '';
end
if(isempty(room_id))
    room_id = 'GTR1';
end
if(nargin<5)
    spot_tune_id = '';
end
if(isempty(spot_tune_id))
    spot_tune_id = 'Spot1';
end
if(nargin<6)
    snout_id = '';
end
if(isempty(snout_id))
    snout_id = '';
end
if(nargin<7)
    sort_spots = 'true';
end
if(isempty(sorting_type))
    sorting_type = '';
end
if(nargin<7)
    sortSpot = 'true';
end

% get number of fields and layers
nb_fields = length(plan);
for f=1:nb_fields
    nb_layers(f) = length(plan{f}.spots);
end

% get number of layer paintings
paintings = cell(nb_fields,1);
for f=1:nb_fields
    for j=1:nb_layers(f)
        if(isempty(nb_paintings))
            if(isfield(plan{f}.spots(j),'nb_paintings'))
                paintings{f}(j) = plan{f}.spots(j).nb_paintings;
            else
                paintings{f}(j) = 1;
            end
        else
            paintings{f}(j) = nb_paintings;
        end
    end
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

switch format

    case 'json'

        Plan_text = cell(nb_fields,1);

        for f=1:nb_fields
            % create output text line
            Plan_text{f} = '{';
            Plan_text{f} = [Plan_text{f},'"beamSupplyPointId": "',room_id,'",',endl];
            Plan_text{f} = [Plan_text{f},'"actualtemperature": "293.15",',endl];
            Plan_text{f} = [Plan_text{f},'"referencetemperature": "293.15",',endl];
            Plan_text{f} = [Plan_text{f},'"actualpressure": "1030",',endl];
            Plan_text{f} = [Plan_text{f},'"referencepressure": "1030",',endl];
            Plan_text{f} = [Plan_text{f},'"mud": "0",',endl];
            Plan_text{f} = [Plan_text{f},'"dosecorrectionfactor": "1",',endl];
            Plan_text{f} = [Plan_text{f},'"rangeshifterid": "",',endl];
            Plan_text{f} = [Plan_text{f},'"ridgefilterid": "",',endl];
            Plan_text{f} = [Plan_text{f},'"rangecompensatorid": "",',endl];
            Plan_text{f} = [Plan_text{f},'"blockid": "",',endl];
            Plan_text{f} = [Plan_text{f},'"snoutid": "',snout_id,'",',endl];
            Plan_text{f} = [Plan_text{f},'"sort": "',sort_spots,'",',endl];
            Plan_text{f} = [Plan_text{f},'"snoutextension": "430",',endl];
            Plan_text{f} = [Plan_text{f},'"ic23offsetx": "0",',endl];
            Plan_text{f} = [Plan_text{f},'"ic23offsety": "0",',endl];
            Plan_text{f} = [Plan_text{f},'"smoffsetx": "0",',endl];
            Plan_text{f} = [Plan_text{f},'"smoffsety": "0",',endl];
            Plan_text{f} = [Plan_text{f},'"ic1positionx": "0",',endl];
            Plan_text{f} = [Plan_text{f},'"ic1positiony": "0",',endl];
            Plan_text{f} = [Plan_text{f},'"gantryAngle": "',num2str(plan{f}.gantry_angle),'",',endl];
            Plan_text{f} = [Plan_text{f},'"beamGatingRequired": "false",',endl];
            if(isfield(plan{f}.spots(1),'gantry_angle')) % Arc case (one layer per angular window)
                Plan_text{f} = [Plan_text{f},'"beamType": "DYNAMIC",',endl];
            else % IMPT case
                Plan_text{f} = [Plan_text{f},'"beamType": "STATIC",',endl];
            end
            Plan_text{f} = [Plan_text{f},'"beam":',endl];
            Plan_text{f} = [Plan_text{f},'{',endl];
            Plan_text{f} = [Plan_text{f},'"meterset": ',num2str(sum(meterset{f})),',',endl];
            if(not(sum(paintings{f}>1)))
                Plan_text{f} = [Plan_text{f},'"repaintingType": "None",',endl];
            else
                Plan_text{f} = [Plan_text{f},'"repaintingType": "InLayer",',endl];
            end
            Plan_text{f} = [Plan_text{f},'"layers":',endl];
            Plan_text{f} = [Plan_text{f},'[',endl];
            for j=1:nb_layers(f)
                Plan_text{f} = [Plan_text{f},'{',endl];
                Plan_text{f} = [Plan_text{f},'"spotTuneId": "',spot_tune_id,'",',endl];
                Plan_text{f} = [Plan_text{f},'"nominalBeamEnergy": ',num2str(plan{f}.spots(j).energy),',',endl];
                Plan_text{f} = [Plan_text{f},'"numberOfPaintings": ',num2str(paintings{f}(j)),',',endl];
                if(isfield(plan{f}.spots(1),'gantry_angle')) % Arc case (one layer per angular window)
                    Plan_text{f} = [Plan_text{f},'"minGantryAngle": ',num2str(plan{f}.spots(j).gantry_angle(1)),',',endl];
                    Plan_text{f} = [Plan_text{f},'"maxGantryAngle": ',num2str(plan{f}.spots(j).gantry_angle(end)),',',endl];
                end
                Plan_text{f} = [Plan_text{f},'"spots":',endl];
                Plan_text{f} = [Plan_text{f},'[',endl];
                for s = 1:length(plan{f}.spots(j).weight)
                    Plan_text{f} = [Plan_text{f},'{',endl];
                    Plan_text{f} = [Plan_text{f},'"positionX": ',num2str(plan{f}.spots(j).xy(s,1)),',',endl];
                    Plan_text{f} = [Plan_text{f},'"positionY": ',num2str(plan{f}.spots(j).xy(s,2)),',',endl];
                    Plan_text{f} = [Plan_text{f},'"metersetWeight": ',num2str(plan{f}.spots(j).weight(s)),'',endl];
                    Plan_text{f} = [Plan_text{f},'}',endl];
                    if(s<length(plan{f}.spots(j).weight))
                        Plan_text{f} = [Plan_text{f},',',endl];
                    end
                end % loop on spots
                Plan_text{f} = [Plan_text{f},']',endl];
                Plan_text{f} = [Plan_text{f},'}',endl];
                if(j<nb_layers(f))
                    Plan_text{f} = [Plan_text{f},',',endl];
                end
            end % loop on layers
            Plan_text{f} = [Plan_text{f},']',endl];
            Plan_text{f} = [Plan_text{f},'}}',endl];
        end % loop on fields

    case 'json-1'

        Plan_text = cell(nb_fields,1);

        for f=1:nb_fields
            % create output text line
            Plan_text{f} = '{';
            Plan_text{f} = [Plan_text{f},'"beamSupplyPointId": "',room_id,'",',endl];
            Plan_text{f} = [Plan_text{f},'"sortSpots": ',sort_spots,',',endl];
            Plan_text{f} = [Plan_text{f},'"mud": 0,',endl];
            Plan_text{f} = [Plan_text{f},'"snoutExtension": 430,',endl];
            Plan_text{f} = [Plan_text{f},'"gantryAngle": ',num2str(plan{f}.gantry_angle),',',endl];
            Plan_text{f} = [Plan_text{f},'"beamGatingRequired": false,',endl];
            Plan_text{f} = [Plan_text{f},'"rangeShifterId": "",',endl];
            Plan_text{f} = [Plan_text{f},'"ridgeFilterId": "",',endl];
            Plan_text{f} = [Plan_text{f},'"rangeCompensatorId": "",',endl];
            Plan_text{f} = [Plan_text{f},'"blockId": "",',endl];
            Plan_text{f} = [Plan_text{f},'"snoutId": "',snout_id,'",',endl];
            Plan_text{f} = [Plan_text{f},'"actualTemperature": 20.0,',endl];
            Plan_text{f} = [Plan_text{f},'"referenceTemperature": 20.0,',endl];
            Plan_text{f} = [Plan_text{f},'"actualPressure": 101.325,',endl];
            Plan_text{f} = [Plan_text{f},'"referencePressure": 101.325,',endl];
            Plan_text{f} = [Plan_text{f},'"doseCorrectionFactor": 1,',endl];
            Plan_text{f} = [Plan_text{f},'"icOffsetX": 0,',endl];
            Plan_text{f} = [Plan_text{f},'"icOffsetY": 0,',endl];
            Plan_text{f} = [Plan_text{f},'"smOffsetX": 0,',endl];
            Plan_text{f} = [Plan_text{f},'"smOffsetY": 0,',endl];
            Plan_text{f} = [Plan_text{f},'"ic1PositionX": 0,',endl];
            Plan_text{f} = [Plan_text{f},'"ic1PositionY": 0,',endl];
            if(isfield(plan{f}.spots(1),'gantry_angle')) % Arc case (one layer per angular window)
                Plan_text{f} = [Plan_text{f},'"beamType": "dynamic",',endl];
            else % IMPT case
                Plan_text{f} = [Plan_text{f},'"beamType": "static",',endl];
            end
            Plan_text{f} = [Plan_text{f},'"beam":',endl];
            Plan_text{f} = [Plan_text{f},'{',endl];
            Plan_text{f} = [Plan_text{f},'"meterset": ',num2str(sum(meterset{f})),',',endl];
            if(not(sum(paintings{f}>1)))
                Plan_text{f} = [Plan_text{f},'"repaintingType": "None",',endl];
            else
                Plan_text{f} = [Plan_text{f},'"repaintingType": "InLayer",',endl];
            end
            Plan_text{f} = [Plan_text{f},'"layers":',endl];
            Plan_text{f} = [Plan_text{f},'[',endl];
            for j=1:nb_layers(f)
                Plan_text{f} = [Plan_text{f},'{',endl];
                Plan_text{f} = [Plan_text{f},'"spotTuneId": "',spot_tune_id,'",',endl];
                Plan_text{f} = [Plan_text{f},'"nominalBeamEnergy": ',num2str(plan{f}.spots(j).energy),',',endl];
                Plan_text{f} = [Plan_text{f},'"numberOfPaintings": ',num2str(paintings{f}(j)),',',endl];
                if(isfield(plan{f}.spots(1),'gantry_angle')) % Arc case (one layer per angular window)
                    Plan_text{f} = [Plan_text{f},'"minGantryAngle": ',num2str(plan{f}.spots(j).gantry_angle(1)),',',endl];
                    Plan_text{f} = [Plan_text{f},'"maxGantryAngle": ',num2str(plan{f}.spots(j).gantry_angle(end)),',',endl];
                end
                Plan_text{f} = [Plan_text{f},'"spots":',endl];
                Plan_text{f} = [Plan_text{f},'[',endl];
                for s = 1:length(plan{f}.spots(j).weight)
                    Plan_text{f} = [Plan_text{f},'{',endl];
                    Plan_text{f} = [Plan_text{f},'"positionX": ',num2str(plan{f}.spots(j).xy(s,1)),',',endl];
                    Plan_text{f} = [Plan_text{f},'"positionY": ',num2str(plan{f}.spots(j).xy(s,2)),',',endl];
                    Plan_text{f} = [Plan_text{f},'"metersetWeight": ',num2str(plan{f}.spots(j).weight(s)),'',endl];
                    Plan_text{f} = [Plan_text{f},'}',endl];
                    if(s<length(plan{f}.spots(j).weight))
                        Plan_text{f} = [Plan_text{f},',',endl];
                    end
                end % loop on spots
                Plan_text{f} = [Plan_text{f},']',endl];
                Plan_text{f} = [Plan_text{f},'}',endl];
                if(j<nb_layers(f))
                    Plan_text{f} = [Plan_text{f},',',endl];
                end
            end % loop on layers
            Plan_text{f} = [Plan_text{f},']',endl];
            Plan_text{f} = [Plan_text{f},'}}',endl];
        end % loop on fields

    case 'json-2'

        Plan_text = cell(nb_fields,1);

        for f=1:nb_fields
            % create output text line
            Plan_text{f} = '{';
            Plan_text{f} = [Plan_text{f},'"bsp": "',room_id,'",'];
            Plan_text{f} = [Plan_text{f},'"sort": "',sort_spots,'",'];
            Plan_text{f} = [Plan_text{f},'"mud": "0",'];
            Plan_text{f} = [Plan_text{f},'"snoutextension": "430",'];
            Plan_text{f} = [Plan_text{f},'"gantryangle": "0",'];
            Plan_text{f} = [Plan_text{f},'"rangeshifterid": "",'];
            Plan_text{f} = [Plan_text{f},'"ridgefilterid": "",'];
            Plan_text{f} = [Plan_text{f},'"rangecompensatorid": "",'];
            Plan_text{f} = [Plan_text{f},'"blockid": "",'];
            Plan_text{f} = [Plan_text{f},'"snoutid": "',snout_id,'",'];
            Plan_text{f} = [Plan_text{f},'"actualtemperature": "293.15",'];
            Plan_text{f} = [Plan_text{f},'"referencetemperature": "293.15",'];
            Plan_text{f} = [Plan_text{f},'"actualpressure": "1030",'];
            Plan_text{f} = [Plan_text{f},'"referencepressure": "1030",'];
            Plan_text{f} = [Plan_text{f},'"dosecorrectionfactor": "1",'];
            Plan_text{f} = [Plan_text{f},'"ic23offsetx": "0",'];
            Plan_text{f} = [Plan_text{f},'"ic23offsety": "0",'];
            Plan_text{f} = [Plan_text{f},'"smoffsetx": "0",'];
            Plan_text{f} = [Plan_text{f},'"smoffsety": "0",'];
            Plan_text{f} = [Plan_text{f},'"ic1positionx": "0",'];
            Plan_text{f} = [Plan_text{f},'"ic1positiony": "0",'];
            Plan_text{f} = [Plan_text{f},'"beam":'];
            Plan_text{f} = [Plan_text{f},'{'];
            Plan_text{f} = [Plan_text{f},'"mu": "',num2str(sum(meterset{f})),'",'];
            if(not(sum(paintings{f}>1)))
                Plan_text{f} = [Plan_text{f},'"repaintingtype": "None",'];
            else
                Plan_text{f} = [Plan_text{f},'"repaintingtype": "InLayer",'];
            end
            Plan_text{f} = [Plan_text{f},'"layer":'];
            Plan_text{f} = [Plan_text{f},'['];
            for j=1:nb_layers(f)
                Plan_text{f} = [Plan_text{f},'{'];
                Plan_text{f} = [Plan_text{f},'"spottuneid": "',spot_tune_id,'",'];
                Plan_text{f} = [Plan_text{f},'"energy": "',num2str(plan{f}.spots(j).energy),'",'];
                Plan_text{f} = [Plan_text{f},'"paintings": "',num2str(paintings{f}(j)),'",'];
                Plan_text{f} = [Plan_text{f},'"spot":'];
                Plan_text{f} = [Plan_text{f},'['];
                for s = 1:length(plan{f}.spots(j).weight)
                    Plan_text{f} = [Plan_text{f},'{'];
                    Plan_text{f} = [Plan_text{f},'"x": "',num2str(plan{f}.spots(j).xy(s,1)),'",'];
                    Plan_text{f} = [Plan_text{f},'"y": "',num2str(plan{f}.spots(j).xy(s,2)),'",'];
                    Plan_text{f} = [Plan_text{f},'"metersetweight": "',num2str(plan{f}.spots(j).weight(s)),'"'];
                    Plan_text{f} = [Plan_text{f},'}'];
                    if(s<length(plan{f}.spots(j).weight))
                        Plan_text{f} = [Plan_text{f},','];
                    end
                end % loop on spots
                Plan_text{f} = [Plan_text{f},']'];
                Plan_text{f} = [Plan_text{f},'}'];
                if(j<nb_layers(f))
                    Plan_text{f} = [Plan_text{f},','];
                end
            end % loop on layers
            Plan_text{f} = [Plan_text{f},']'];
            Plan_text{f} = [Plan_text{f},'}}'];
        end % loop on fields

    case 'json-3'
        Plan_text = cell(nb_fields,1);

        for f=1:nb_fields
            % create output text line
            Plan_text{f} = '{';
            Plan_text{f} = [Plan_text{f},'"bsp": "',room_id,'",'];
            Plan_text{f} = [Plan_text{f},'"sort": "',sort_spots,'",'];
            Plan_text{f} = [Plan_text{f},'"mud": "0",'];
            Plan_text{f} = [Plan_text{f},'"snoutextension": "430",'];
            Plan_text{f} = [Plan_text{f},'"gantryangle": "0",'];
            Plan_text{f} = [Plan_text{f},'"rangeshifterid": "",'];
            Plan_text{f} = [Plan_text{f},'"ridgefilterid": "",'];
            Plan_text{f} = [Plan_text{f},'"rangecompensatorid": "",'];
            Plan_text{f} = [Plan_text{f},'"blockid": "",'];
            Plan_text{f} = [Plan_text{f},'"snoutid": "',snout_id,'",'];
            Plan_text{f} = [Plan_text{f},'"actualtemperature": "293.15",'];
            Plan_text{f} = [Plan_text{f},'"referencetemperature": "293.15",'];
            Plan_text{f} = [Plan_text{f},'"actualpressure": "1030",'];
            Plan_text{f} = [Plan_text{f},'"referencepressure": "1030",'];
            Plan_text{f} = [Plan_text{f},'"dosecorrectionfactor": "1",'];
            Plan_text{f} = [Plan_text{f},'"ic23offsetx": "0",'];
            Plan_text{f} = [Plan_text{f},'"ic23offsety": "0",'];
            Plan_text{f} = [Plan_text{f},'"smoffsetx": "0",'];
            Plan_text{f} = [Plan_text{f},'"smoffsety": "0",'];
            Plan_text{f} = [Plan_text{f},'"ic1positionx": "0",'];
            Plan_text{f} = [Plan_text{f},'"ic1positiony": "0",'];
            Plan_text{f} = [Plan_text{f},'"beam":'];
            Plan_text{f} = [Plan_text{f},'{'];
            Plan_text{f} = [Plan_text{f},'"mu": "',num2str(sum(meterset{f})),'",'];
            if(not(sum(paintings{f}>1)))
                Plan_text{f} = [Plan_text{f},'"repaintingtype": "None",'];
            else
                Plan_text{f} = [Plan_text{f},'"repaintingtype": "InLayer",'];
            end
            for j=1:nb_layers(f)
                Plan_text{f} = [Plan_text{f},'"layer":'];
                Plan_text{f} = [Plan_text{f},'{'];
                Plan_text{f} = [Plan_text{f},'"spottuneid": "',spot_tune_id,'",'];
                Plan_text{f} = [Plan_text{f},'"energy": "',num2str(plan{f}.spots(j).energy),'",'];
                Plan_text{f} = [Plan_text{f},'"paintings": "',num2str(paintings{f}(j)),'",'];
                Plan_text{f} = [Plan_text{f},'"spot":'];
                Plan_text{f} = [Plan_text{f},'['];
                for s = 1:length(plan{f}.spots(j).weight)
                    Plan_text{f} = [Plan_text{f},'{'];
                    Plan_text{f} = [Plan_text{f},'"x": "',num2str(plan{f}.spots(j).xy(s,1)),'",'];
                    Plan_text{f} = [Plan_text{f},'"y": "',num2str(plan{f}.spots(j).xy(s,2)),'",'];
                    Plan_text{f} = [Plan_text{f},'"metersetweight": "',num2str(plan{f}.spots(j).weight(s)),'"'];
                    Plan_text{f} = [Plan_text{f},'}'];
                    if(s<length(plan{f}.spots(j).weight))
                        Plan_text{f} = [Plan_text{f},','];
                    end
                end % loop on spots
                Plan_text{f} = [Plan_text{f},']'];
                Plan_text{f} = [Plan_text{f},'}'];
                if(j<nb_layers(f))
                    Plan_text{f} = [Plan_text{f},','];
                end
            end % loop on layers
            Plan_text{f} = [Plan_text{f},'}}'];
        end % loop on fields

    case 'xml'

        disp('Conversion in XML not yet implemented. Abort')
        return

    case 'gate'

        % create output text lines
        Plan_text = cell(0);
        Plan_text{end+1} = '#TREATMENT-PLAN-DESCRIPTION';
        Plan_text{end+1} = '#PlanName';
        Plan_text{end+1} = 'plan';
        Plan_text{end+1} = '#NumberOfFractions';
        Plan_text{end+1} = '1';
        Plan_text{end+1} = '##FractionID';
        Plan_text{end+1} = '1';
        Plan_text{end+1} = '##NumberOfFields';
        Plan_text{end+1} = num2str(nb_fields);
        for f=1:nb_fields
            Plan_text{end+1} = '###FieldsID';
            Plan_text{end+1} = num2str(f);
        end
        Plan_text{end+1} = '#TotalMetersetWeightOfAllFields';
        Plan_text{end+1} = num2str(tot_meterset);
        Plan_text{end+1} = ' ';

        for f=1:nb_fields

            Plan_text{end+1} = '#FIELD-DESCRIPTION';
            Plan_text{end+1} = '###FieldID';
            Plan_text{end+1} = num2str(f);
            Plan_text{end+1} = '###FinalCumulativeMeterSetWeight';
            Plan_text{end+1} = num2str(sum(meterset{f}));
            Plan_text{end+1} = '###GantryAngle';
            Plan_text{end+1} = num2str(plan{f}.gantry_angle);
            Plan_text{end+1} = '###PatientSupportAngle';
            Plan_text{end+1} = num2str(plan{f}.table_angle);
            Plan_text{end+1} = '###IsocenterPosition';
            Plan_text{end+1} = num2str(plan{f}.isocenter');
            Plan_text{end+1} = '###NumberOfControlPoints';
            Plan_text{end+1} = num2str(nb_layers(f));
            Plan_text{end+1} = ' ';

            for j=1:nb_layers(f)
                nb_spots = length(plan{f}.spots(j).weight);
                Plan_text{end+1} = '#SPOTS-DESCRIPTION';
                Plan_text{end+1} = '####ControlPointIndex';
                Plan_text{end+1} = num2str(j);
                Plan_text{end+1} = '####SpotTunnedID';
                Plan_text{end+1} = '1';
                Plan_text{end+1} = '####CumulativeMetersetWeight';
                Plan_text{end+1} = num2str(cumulative_meterset{f}(j));
                Plan_text{end+1} = '####Energy (MeV)';
                Plan_text{end+1} = num2str(plan{f}.spots(j).energy);
                Plan_text{end+1} = '####NbOfScannedSpots';
                Plan_text{end+1} = num2str(nb_spots);
                Plan_text{end+1} = '####X Y Weight';
                for s=1:nb_spots
                    Plan_text{end+1} = [num2str(plan{f}.spots(j).xy(s,1)),' ',num2str(plan{f}.spots(j).xy(s,2)),' ',num2str(plan{f}.spots(j).weight(s))];
                end
            end
        end


    case 'gate_with_times'

        % create output text lines
        Plan_text = cell(0);
        Plan_text{end+1} = '#TREATMENT-PLAN-DESCRIPTION';
        Plan_text{end+1} = '#PlanName';
        Plan_text{end+1} = 'PlanPencil';
        Plan_text{end+1} = '#NumberOfFractions';
        Plan_text{end+1} = '1';
        Plan_text{end+1} = '##FractionID';
        Plan_text{end+1} = '1';
        Plan_text{end+1} = '##NumberOfFields';
        Plan_text{end+1} = num2str(nb_fields);
        for f=1:nb_fields
            Plan_text{end+1} = '###FieldsID';
            Plan_text{end+1} = num2str(f);
        end
        Plan_text{end+1} = '#TotalMetersetWeightOfAllFields';
        Plan_text{end+1} = num2str(tot_meterset);
        Plan_text{end+1} = ' ';

        for f=1:nb_fields

            Plan_text{end+1} = '#FIELD-DESCRIPTION';
            Plan_text{end+1} = '###FieldID';
            Plan_text{end+1} = num2str(f);
            Plan_text{end+1} = '###FinalCumulativeMeterSetWeight';
            Plan_text{end+1} = num2str(sum(meterset{f}));
            Plan_text{end+1} = '###GantryAngle';
            Plan_text{end+1} = num2str(plan{f}.gantry_angle);
            Plan_text{end+1} = '###PatientSupportAngle';
            Plan_text{end+1} = num2str(plan{f}.table_angle);
            Plan_text{end+1} = '###IsocenterPosition';
            Plan_text{end+1} = num2str(plan{f}.isocenter');

            if isfield(plan{f},'RangeShifterID')
                Plan_text{end+1} = '###RangeShifterID';
                Plan_text{end+1} = plan{f}.RangeShifterID;
            end
            if isfield(plan{f},'RangeShifterType')
                Plan_text{end+1} = '###RangeShifterType';
                Plan_text{end+1} = plan{f}.RangeShifterType;
            end

            Plan_text{end+1} = '###NumberOfControlPoints';
            Plan_text{end+1} = num2str(nb_layers(f));
            Plan_text{end+1} = ' ';

            for j=1:nb_layers(f)
                nb_spots = length(plan{f}.spots(j).weight);
                Plan_text{end+1} = '#SPOTS-DESCRIPTION';
                Plan_text{end+1} = '####ControlPointIndex';
                Plan_text{end+1} = num2str(j);
                Plan_text{end+1} = '####SpotTunnedID';
                Plan_text{end+1} = '1';
                Plan_text{end+1} = '####CumulativeMetersetWeight';
                Plan_text{end+1} = num2str(cumulative_meterset{f}(j));
                Plan_text{end+1} = '####Energy (MeV)';
                Plan_text{end+1} = num2str(plan{f}.spots(j).energy);

                if isfield(plan{f}.spots(j),'RangeShifterSetting')
                    Plan_text{end+1} = '####RangeShifterSetting';
                    Plan_text{end+1} = plan{f}.spots(j).RangeShifterSetting;
                end
                if isfield(plan{f}.spots(j),'IsocenterToRangeShifterDistance')
                    Plan_text{end+1} = '####IsocenterToRangeShifterDistance';
                    Plan_text{end+1} = num2str(plan{f}.spots(j).IsocenterToRangeShifterDistance);
                end
                if isfield(plan{f}.spots(j),'RangeShifterWaterEquivalentThickness')
                    Plan_text{end+1} = '####RangeShifterWaterEquivalentThickness';
                    Plan_text{end+1} = num2str(plan{f}.spots(j).RangeShifterWaterEquivalentThickness);
                end

                Plan_text{end+1} = '####NbOfScannedSpots';
                Plan_text{end+1} = num2str(nb_spots);
                if isfield(plan{f}.spots(j),'time')
                    Plan_text{end+1} = '####X Y Weight Time';
                    for s=1:nb_spots
                        Plan_text{end+1} = [num2str(plan{f}.spots(j).xy(s,1)),' ',num2str(plan{f}.spots(j).xy(s,2)),' ',num2str(plan{f}.spots(j).weight(s)), ' ', num2str(plan{f}.spots(j).time(s))];
                    end
                else
                    Plan_text{end+1} = '####X Y Weight';
                    for s=1:nb_spots
                        Plan_text{end+1} = [num2str(plan{f}.spots(j).xy(s,1)),' ',num2str(plan{f}.spots(j).xy(s,2)),' ',num2str(plan{f}.spots(j).weight(s))];
                    end
                end
            end
        end

    case 'pld'

        % Create text
        for f=1:length(plan)
            Beam_text = {};
            if(0)%isfield(plan{f}.spots(1),'gantry_angle')) % OLD arc case for zip archive export (one layer per angular window)
                b = 0;
                for j=1:nb_layers(f)
                    b = b+1;
                    Beam_text{b}{1} = ['Beam,patientId,patientName,patientInitial,patientFirstname,planId,',plan{f}.name,',',num2str(sum(meterset{f}(j))),',',num2str(sum(meterset{f}(j))),',1,',num2str(plan{f}.spots(j).gantry_angle(1)),',',num2str(plan{f}.spots(j).gantry_angle(end))];
                    nb_spots = length(plan{f}.spots(j).weight);
                    Beam_text{b}{end+1} = ['Layer,',spot_tune_id,',',num2str(plan{f}.spots(j).energy),',',num2str(meterset{f}(j)),',',num2str(2*nb_spots)];
                    for s=1:nb_spots
                        Beam_text{b}{end+1} = ['Element,',num2str(plan{f}.spots(j).xy(s,1)),',',num2str(plan{f}.spots(j).xy(s,2)),',0.0,0.0'];
                        Beam_text{b}{end+1} = ['Element,',num2str(plan{f}.spots(j).xy(s,1)),',',num2str(plan{f}.spots(j).xy(s,2)),',',num2str(plan{f}.spots(j).weight(s)),',0.0'];
                    end
                end
            else
                Beam_text{1}{1} = ['Beam,patientId,patientName,patientInitial,patientFirstname,planId,',plan{f}.name,',',num2str(sum(meterset{f})),',',num2str(sum(meterset{f})),',',num2str(nb_layers(f))];
                if(isfield(plan{f}.spots(1),'gantry_angle')) % Arc case (one layer per angular window)
                    Beam_text{1}{end+1} = '#extra,type,DYNAMIC';
                end
                for j=1:nb_layers(f)
                    nb_spots = length(plan{f}.spots(j).weight);
                    Beam_text{1}{end+1} = ['Layer,',spot_tune_id,',',num2str(plan{f}.spots(j).energy),',',num2str(meterset{f}(j)),',',num2str(2*nb_spots)];
                    if(isfield(plan{f}.spots(1),'gantry_angle')) % Arc case (one layer per angular window)
                        Beam_text{1}{end+1} = ['#extra,angleMin,',num2str(plan{f}.spots(j).gantry_angle(1)),',angleMax,',num2str(plan{f}.spots(j).gantry_angle(end))];
                    end
                    for s=1:nb_spots
                        Beam_text{1}{end+1} = ['Element,',num2str(plan{f}.spots(j).xy(s,1)),',',num2str(plan{f}.spots(j).xy(s,2)),',0.0,0.0'];
                        Beam_text{1}{end+1} = ['Element,',num2str(plan{f}.spots(j).xy(s,1)),',',num2str(plan{f}.spots(j).xy(s,2)),',',num2str(plan{f}.spots(j).weight(s)),',0.0'];
                    end
                end
            end

            Plan_text{f} = Beam_text;

        end

    case 'json_python'

        Plan_text = cell(nb_fields,1);

        for f=1:nb_fields
            % create output text line
            Plan_text{f} = '{';
            Plan_text{f} = [Plan_text{f},'"gantryAngle": ', num2str(plan{f}.gantry_angle),','];
            Plan_text{f} = [Plan_text{f},'"tableAngle": ', num2str(plan{f}.table_angle),','];
            Plan_text{f} = [Plan_text{f},'"beamGatingRequired": false,'];
            Plan_text{f} = [Plan_text{f},'"isocenter": ','[',num2str(plan{f}.isocenter(1)),',',num2str(plan{f}.isocenter(2)),',',num2str(plan{f}.isocenter(3)),'],'];%,num2str(plan{f}.isocenter'),','];
            Plan_text{f} = [Plan_text{f},'"beam":'];
            Plan_text{f} = [Plan_text{f},'{'];
            Plan_text{f} = [Plan_text{f},'"meterset": ',num2str(sum(meterset{f})),','];
            if(not(sum(paintings{f}>1)))
                Plan_text{f} = [Plan_text{f},'"repaintingType": "None",'];
            else
                Plan_text{f} = [Plan_text{f},'"repaintingType": "InLayer",'];
            end
            Plan_text{f} = [Plan_text{f},'"layers":'];
            Plan_text{f} = [Plan_text{f},'['];
            for j=1:nb_layers(f)
                Plan_text{f} = [Plan_text{f},'{'];
                Plan_text{f} = [Plan_text{f},'"spotTuneId": "',spot_tune_id,'",'];
                Plan_text{f} = [Plan_text{f},'"nominalBeamEnergy": ',num2str(plan{f}.spots(j).energy),','];
                Plan_text{f} = [Plan_text{f},'"numberOfPaintings": ',num2str(paintings{f}(j)),','];
                Plan_text{f} = [Plan_text{f},'"spots":'];
                Plan_text{f} = [Plan_text{f},'['];
                for s = 1:length(plan{f}.spots(j).weight)
                    Plan_text{f} = [Plan_text{f},'{'];
                    Plan_text{f} = [Plan_text{f},'"positionX": ',num2str(plan{f}.spots(j).xy(s,1)),','];
                    Plan_text{f} = [Plan_text{f},'"positionY": ',num2str(plan{f}.spots(j).xy(s,2)),','];
                    Plan_text{f} = [Plan_text{f},'"metersetWeight": ',num2str(plan{f}.spots(j).weight(s)),''];
                    Plan_text{f} = [Plan_text{f},'"time": ',num2str(plan{f}.spots(j).time(s)),''];
                    % Add timining here
                    Plan_text{f} = [Plan_text{f},'}'];
                    if(s<length(plan{f}.spots(j).weight))
                        Plan_text{f} = [Plan_text{f},','];
                    end
                end % loop on spots
                Plan_text{f} = [Plan_text{f},']'];
                Plan_text{f} = [Plan_text{f},'}'];
                if(j<nb_layers(f))
                    Plan_text{f} = [Plan_text{f},','];
                end
            end % loop on layers
            Plan_text{f} = [Plan_text{f},']'];
            Plan_text{f} = [Plan_text{f},'}}'];
        end % loop on fields

    otherwise

        disp('Unknow format')

end
