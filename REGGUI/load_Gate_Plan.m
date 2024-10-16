%% load_Gate_Plan
% Load a treatment plan from file at the GATE format.
%
%% Syntax
% |[myBeamData,myInfo] = load_Gate_Plan(plan_filename)|
%
%
%% Description
% |[myBeamData,myInfo] = load_Gate_Plan(plan_filename)| Load a treatment plan from file
%
%
%% Input arguments
% |plan_filename| - _STRING_ - File name (including path) of the data to be loaded
%
%
%% Output arguments
%
% |myBeamData| - _CELL VECTOR of STRUCTURE_ -  |myBeamData{i}| Description of the the geometry of the i-th proton beam
%
% * |beam{i}.gantry_angle| - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
% * |beam{i}.table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
% * |beam{i}.isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
% * |beam{i}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer 
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer 
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file.
%
% * |myInfo.Type| - _STRING_ - Type of treatment plan: 'pbs_plan'
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [myBeamData,myInfo] = load_Gate_Plan(plan_filename)

% Authors : G.Janssens (open.reggui@gmail.com)

Current_dir = pwd;

myBeamData = [];
myInfo.Type = 'pbs_plan';

layer = 0;
spot = 0;
beam = 0;

fid = fopen(plan_filename,'r');
tline = fgetl(fid);
while ischar(tline)
    if(not(isempty(strfind(tline,'FIELD-DESCRIPTION'))))
	beam = beam + 1;
	layer = 0;
	spot = 0;
    elseif(not(isempty(strfind(tline,'NumberOfFractions'))))
	tline = fgetl(fid);
        myInfo.NumberOfFractions = str2double(tline);
    elseif(not(isempty(strfind(tline,'GantryAngle'))))
        tline = fgetl(fid);
        myBeamData{beam}.gantry_angle = str2double(tline);
    elseif(not(isempty(strfind(tline,'PatientSupportAngle'))))
        tline = fgetl(fid);
        myBeamData{beam}.table_angle = str2double(tline);
    elseif(not(isempty(strfind(tline,'IsocenterPosition'))))
        tline = fgetl(fid);
        eval(['iso = [',tline,'];']);
        myBeamData{beam}.isocenter = [iso(1);iso(2);iso(3)];
    elseif(not(isempty(strfind(tline,'RangeShifterID'))))
        tline = fgetl(fid);
        myBeamData{beam}.RangeShifterID = tline;
    elseif(not(isempty(strfind(tline,'RangeShifterType'))))
        tline = fgetl(fid);
        myBeamData{beam}.RangeShifterType = tline;
    elseif(not(isempty(strfind(tline,'Energy'))))
        layer = layer+1;
        tline = fgetl(fid);
        myBeamData{beam}.spots(layer).energy = str2double(tline);
        myBeamData{beam}.spots(layer).nb_paintings = 1;
        spot = 0;
    elseif(not(isempty(strfind(tline,'RangeShifterSetting'))))
        tline = fgetl(fid);
        myBeamData{beam}.spots(layer).RangeShifterSetting = tline;
    elseif(not(isempty(strfind(tline,'IsocenterToRangeShifterDistance'))))
        tline = fgetl(fid);
        myBeamData{beam}.spots(layer).IsocenterToRangeShifterDistance = str2double(tline);
    elseif(not(isempty(strfind(tline,'RangeShifterWaterEquivalentThickness'))))
        tline = fgetl(fid);
        myBeamData{beam}.spots(layer).RangeShifterWaterEquivalentThickness = str2double(tline);
    elseif(not(isempty(strfind(tline,'X Y Weight'))))
        read_spots = 1;
        while read_spots
            tline = fgetl(fid);
            if(ischar(tline) && isempty(strfind(tline,'#')))
                eval(['spot_info = [',tline,'];']);
		if(numel(spot_info) < 3)
		  break
		end
                if(spot_info(3)>0) % do not import spots with weight=0
                    spot = spot+1;
                    myBeamData{beam}.spots(layer).xy(spot,:) = [spot_info(1),spot_info(2)];
                    myBeamData{beam}.spots(layer).weight(spot,1) = spot_info(3);
                end
            else
                read_spots = 0;
            end
        end
	continue
    end
    tline = fgetl(fid);
end

fclose(fid);
cd(Current_dir);
