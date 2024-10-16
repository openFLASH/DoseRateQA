%% load_JSON_Plan
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [myBeamData,myInfo] = load_JSON_Plan(plan_filename, ask_details)

if(nargin<2)
    ask_details = 0;
end

myInfo.Type = 'pbs_plan';
[~,beam_name] = fileparts(plan_filename);

temp = loadjson(plan_filename);

% If parameter "ask_details" is set at 0, default values (all 0) will be used
if(~ask_details)
    table_angle = 0;
    isocenter = [0;0;0];
else
    ask_table_angle = 1;
    while ask_table_angle
        answer=inputdlg('Enter table angle in degrees','Table angle',1,{'0'});
        try
            eval(['table_angle = ',answer{1},';'])
            if(table_angle>=0 && table_angle<360)
                ask_table_angle = 0;
            else
                disp('Table angle must be between 0 and 360');
            end
        catch
        end
    end
    ask_isocenter = 1;
    while ask_isocenter
        answer=inputdlg('Enter isocenter in cm','Isocenter',1,{'0;0;0'});
        try
            eval(['isocenter = [',answer{1},'];'])
            if(length(isocenter)==3)
                ask_isocenter = 0;
            else
                disp('Isocenter must have 3 values (x,y,z)');
            end
        catch
        end
    end
    answer=inputdlg('Enter beam name','Beam name',1,{beam_name});
    beam_name = answer{1};
end

myBeamData{1}.name = beam_name;
myBeamData{1}.isocenter = isocenter*10;
myBeamData{1}.gantry_angle = temp.gantryAngle;
myBeamData{1}.table_angle = table_angle;
myBeamData{1}.final_weight = 0;

for j=1:length(temp.beam.layers)
    myBeamData{1}.spots(j).energy = temp.beam.layers{j}.nominalBeamEnergy;
    myBeamData{1}.spots(j).nb_paintings = temp.beam.layers{j}.numberOfPaintings;
    if(isfield(temp.beam.layers{j},'minGantryAngle') && isfield(temp.beam.layers{j},'maxGantryAngle'))
        myBeamData{1}.spots(j).gantry_angle = [temp.beam.layers{j}.minGantryAngle;temp.beam.layers{j}.maxGantryAngle];
    end
    for s = 1:length(temp.beam.layers{j}.spots)
        myBeamData{1}.spots(j).xy(s,1) = temp.beam.layers{j}.spots{s}.positionX;
        myBeamData{1}.spots(j).xy(s,2) = temp.beam.layers{j}.spots{s}.positionY;
        myBeamData{1}.spots(j).weight(s,1) = temp.beam.layers{j}.spots{s}.metersetWeight;
        myBeamData{1}.final_weight = myBeamData{1}.final_weight + temp.beam.layers{j}.spots{s}.metersetWeight;
    end
end


