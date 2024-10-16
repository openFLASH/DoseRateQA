%% load_PLD_folder
% Load a treatment plan from folder at the PLD format.
%
%% Syntax
% |[myBeamData,myInfo] = load_PLD(plan_dirname)|
%
% |[myBeamData,myInfo] = load_PLD(plan_dirname, ask_details)|
%
%
%% Description
% |[myBeamData,myInfo] = load_PLD(plan_dirname, ask_details)| Load a treatment plan from PLD files
%
%
%% Input arguments
% |plan_dirname| - _STRING_ - Directory name (including path) of the data to be loaded
%
% |ask_details| - _INTEGER_ - [OPTIONAL. Default =1] 1 = display a dilog box to allow user to enter gantry, isocenter and table yaw. If set to 0, default values (all 0) will be used for isocenter, gantry & table angle.
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
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer. The coordinate system is IEC-GANTRY.
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file.
%
% * |myInfo.Type| - _STRING_ - Type of treatment plan: 'pbs_plan'
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [myBeamData,myInfo] = load_PLD_folder(plan_dirname, ask_details)

% Authors : G.Janssens (open.reggui@gmail.com)

Current_dir = pwd;

% Unzip archive if needed
if(not(exist(plan_dirname,'dir')))    
    unzip(plan_dirname,strrep(plan_dirname,'.zip',''));
    plan_dirname = strrep(plan_dirname,'.zip','');
end

myBeamData = [];
myInfo.Type = 'pbs_plan';
[~,beam_name] = fileparts(plan_dirname);

if(nargin<2)
    ask_details = 0;
end

% If parameter "ask_details" is set at 0, default values will be used.
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

folders = dir_without_hidden(plan_dirname);
folders = folders([folders.isdir]); 

if(isempty(folders))
    folders{1} = plan_dirname;
end

for f=1:length(folders)
    
    if(length(folders)==1)
        myBeamData{f}.name = beam_name;
    else
        myBeamData{f}.name = [beam_name,'_',num2str(f)];
    end
    myBeamData{f}.isocenter = isocenter*10;
    myBeamData{f}.table_angle = table_angle;
    myBeamData{f}.final_weight = 0;
    
    files = dir_without_hidden(folders{f});
    layer = 0;
    myBeamData{f}.spots = [];
    
    for i=1:length(files)

        % read spots
        current_file = fullfile(files(i).folder,files(i).name);
        fid = fopen(current_file,'r');
        headline = fgetl(fid);
        eval(['header_info = {''',strrep(headline,',',''','''),'''};']);
        
        spot = 0;
        
        while 1
            tline = fgetl(fid);
            if ~ischar(tline), break, end
            if(not(isempty(strfind(tline,'Layer'))))
                layer = layer+1;
                eval(['layer_info = {''',strrep(tline,',',''','''),'''};']);
                myBeamData{f}.spots(layer).energy = str2double(layer_info{3});
                try
                    myBeamData{f}.spots(layer).nb_paintings = str2double(layer_info{6});
                catch
                end
                try
                    myBeamData{f}.spots(layer).gantry_angle = [str2double(header_info{11});str2double(header_info{12})];
                catch
                    disp('No gantry angles found in pld header.')
                end
                spot = 0;
            elseif(not(isempty(strfind(tline,'Element'))))
                eval(['spot_info = {''',strrep(tline,',',''','''),'''};']);
                if(str2double(spot_info{4})>0) % do not import spots with weight=0
                    spot = spot+1;
                    myBeamData{f}.spots(layer).xy(spot,:) = [str2double(spot_info{2}),str2double(spot_info{3})];
                    myBeamData{f}.spots(layer).weight(spot,1) = str2double(spot_info{4});
                    myBeamData{f}.final_weight = myBeamData{f}.final_weight + myBeamData{f}.spots(layer).weight(spot,1);
                end
            end
        end
        fclose(fid);
        
    end
    
    myBeamData{f}.gantry_angle = myBeamData{f}.spots(1).gantry_angle(1);
    
end

cd(Current_dir);

