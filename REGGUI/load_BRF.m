function [records, sum_MU] = load_BRF(logFilename)

fid = fopen(logFilename,'r');

records = {};
records{1}.spots = [];
new_layer = 0;
new_spot = 0;
layer_start_time = NaN;

while 1
    
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    else
        temp = strsplit(tline,{'<','>'});
    end
    if(length(temp)<2)
        continue
    end
    item = temp{2};
    if(length(temp)>2)
        value = temp{3};
    else
        value = [];
    end
    switch item
        case 'mBeamId'
            records{1}.BeamName = value;
        case 'com.iba.pts.bms.datatypes.impl.pbs.PbsLayerResultImpl'
            records{1}.spots(end+1).layer_id = NaN;
            records{1}.spots(end).range = NaN;
            records{1}.spots(end).energy = NaN;
            records{1}.spots(end).date = NaN;
            records{1}.spots(end).spot_id = [];
            records{1}.spots(end).xyConverted = [];
            records{1}.spots(end).MU = [];
            records{1}.spots(end).timeStart = [];
            records{1}.spots(end).timeStop = [];
            records{1}.spots(end).gantry_angle = [];
            new_layer = 1;
            new_spot = 0;
        case 'com.iba.pts.bms.datatypes.impl.pbs.PbsLayerResultImpl'
            new_layer = 0;
        case 'mBeginTime'
            if(new_layer)
                layer_start_time = timeConverter(value,'dekimo');% in us
                records{1}.spots(end).date = strrep(value(1:10),'-','');
            end
        case 'mEnergy'
            records{1}.spots(end).energy = str2double(value);
        case 'mDistalDistance'
            records{1}.spots(end).range = str2double(value);
        case 'com.iba.pts.bms.datatypes.impl.pbs.PbsElementResultImpl'
            records{1}.spots(end).spot_id(end+1,1) = NaN;
            records{1}.spots(end).xyConverted(end+1,1:2) = [NaN,NaN];
            records{1}.spots(end).MU(end+1,1) = NaN;
            records{1}.spots(end).timeStart(end+1,1) = NaN;
            records{1}.spots(end).timeStop(end+1,1) = NaN;
            records{1}.spots(end).gantry_angle(end+1,1) = NaN;
            new_layer = 0;
            new_spot = 1;
        case '/com.iba.pts.bms.datatypes.impl.pbs.PbsElementResultImpl'
            new_spot = 0;
        case 'mId'
            if(new_spot)
                records{1}.spots(end).spot_id(end) = str2double(value);
            else
                records{1}.spots(end).layer_id = str2double(value);
            end
        case 'mStart'
            records{1}.spots(end).timeStart(end) = layer_start_time + str2double(value)*1e3;% ms to us
        case 'mDuration'
            records{1}.spots(end).timeStop(end) = records{1}.spots(end).timeStart(end) + str2double(value)*1e3;% ms to us
        case 'mXPosition'
            records{1}.spots(end).xyConverted(end,1) = str2double(value);
        case 'mYPosition'
            records{1}.spots(end).xyConverted(end,2) = str2double(value);
        case 'mDose'
            records{1}.spots(end).MU(end) = str2double(value);
        case 'mGantryPosition'
            records{1}.spots(end).gantry_angle(end) = str2double(value);
    end

end
fclose(fid);

% Remove erroneous spots
for layerIndex=1:length(records{1}.spots)
    % remove data from zero-weight entries
    records{1}.spots(layerIndex).spot_id = records{1}.spots(layerIndex).spot_id(records{1}.spots(layerIndex).MU>1e-3);
    records{1}.spots(layerIndex).xyConverted = records{1}.spots(layerIndex).xyConverted(records{1}.spots(layerIndex).MU>1e-3,:);
    records{1}.spots(layerIndex).timeStart = records{1}.spots(layerIndex).timeStart(records{1}.spots(layerIndex).MU>1e-3);
    records{1}.spots(layerIndex).timeStop = records{1}.spots(layerIndex).timeStop(records{1}.spots(layerIndex).MU>1e-3);
    records{1}.spots(layerIndex).gantry_angle = records{1}.spots(layerIndex).gantry_angle(records{1}.spots(layerIndex).MU>1e-3);
    % remove zero-weight entries
    records{1}.spots(layerIndex).MU = records{1}.spots(layerIndex).MU(records{1}.spots(layerIndex).MU>1e-3);    
end

% Convert to relative timing
start_time = records{1}.spots(1).timeStart(1);
for layerIndex=1:length(records{1}.spots)
    records{1}.spots(layerIndex).timeStart = records{1}.spots(layerIndex).timeStart - start_time;
    records{1}.spots(layerIndex).timeStop = records{1}.spots(layerIndex).timeStop - start_time;    
end

% Identify tuning spots
for layerIndex=1:length(records{1}.spots)
    records{1}.spots(layerIndex).tuning = records{1}.spots(layerIndex).MU * 0;
    if length(records{1}.spots(layerIndex).timeStart)>1
        for i=1:length(records{1}.spots(layerIndex).timeStart)-1
            tuning_time = (records{1}.spots(layerIndex).timeStart(i+1) - records{1}.spots(layerIndex).timeStop(i))*1e-3;% in ms
            if(records{1}.spots(layerIndex).MU(1)<0.1 && tuning_time>100)
                records{1}.spots(layerIndex).tuning(i) = 1;
            else
                break
            end
        end
    elseif(records{1}.spots(layerIndex).MU<0.1) % only tuning
        records{1}.spots(layerIndex).tuning = 1;
    end
end

% Compute sum of MUs
sum_MU = 0;
for layer=1:length(records{1}.spots)
    sum_MU = sum_MU + sum(records{1}.spots(layer).MU);
end
