%% convert_PBS_timing
% Convert the text structure returned by scanalgo into a Matlab structure. The timing of the spot map of a Pencil Beam Scanning (PBS) treatment plan has been computed by scanalgo (see function |pbs_convert_ScanAlgo|).
%
%% Syntax
% |plan = convert_PBS_timing(input,format)|
%
%
%% Description
% |plan = convert_PBS_timing(input,format)| Read the PBS spot map
%
%
%% Input arguments
% |input| - _CELL VECTOR of STRING_ - |input{f}| Text string of the f-th line of text returned by scanalgo gateway.
%
% |format| - _STRING_ - Define the format of the text in the structure |input| describing the PBS spots. The options is :'json'. Note: support for 'xml' is not implemented.
%
%
%% Output arguments
%
% |plan| - _STRUCTURE_ Description of the timing of the PBS spot delivery.
%
% * |plan{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy_current(s,:)| - _SCALAR VECTOR_ -  Magnet Setpoint (x,y) (in mm) of the s-th spot in the j-th energy layer. The magnets labels are defined in the PHYSICS CS. The PHYSICS CS is derived from the Y-IEC GANTRY by exchanging X<->Y axes. So the X-magnet scans along the Y-IEC-GANTRY axis and vice-versa.
% * ----|spots(j).time(s)| - _SCALAR_ - Time stamp (s) of the start  of the s-th spot in the j-th energy layer
% * ----|spots(j).duration(s)| - _SCALAR_ - Duration (s)  of the s-th spot in the j-th energy layer
% * ----|spots(j).charge(s)| - _SCALAR_ - Electric charge of the s-th spot in the j-th energy layer
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


% TODO What is the unit of charge ? Coulomb or nb of proton ? To be completed in the help header

function [plan,myInfo] = convert_PBS_timing(input,format)

myInfo.Type = 'pbs_plan';

switch format
    
    case 'json'
        
        plan = cell(1,length(input));
        
        for f=1:length(input)
            
            temp = loadjson(input{f});
            start_time = 0;
            for j=1:length(temp.layers)
                plan{1,f}.spots(j).energy = temp.layers{j}.energy;
                start_time = start_time + temp.layers{j}.switchingTime;
                layer_time = 0;
                if(isfield(temp.layers{j},'bursts'))       
                    nb_spots_previous_bursts = 0;
                    for b = 1:length(temp.layers{j}.bursts)                        
                        for s = 1:length(temp.layers{j}.bursts{b}.spots)
                            spot_index = s + nb_spots_previous_bursts;
                            plan{1,f}.spots(j).xy_current(spot_index,1) = temp.layers{j}.bursts{b}.spots{s}.currentSetpointX;
                            plan{1,f}.spots(j).xy_current(spot_index,2) = temp.layers{j}.bursts{b}.spots{s}.currentSetpointY;
                            plan{1,f}.spots(j).xy(spot_index,1) = temp.layers{j}.bursts{b}.spots{s}.clinicalX;
                            plan{1,f}.spots(j).xy(spot_index,2) = temp.layers{j}.bursts{b}.spots{s}.clinicalY;
                            plan{1,f}.spots(j).time(spot_index,1) = temp.layers{j}.bursts{b}.spots{s}.startTime + start_time + layer_time;
                            plan{1,f}.spots(j).duration(spot_index,1) = temp.layers{j}.bursts{b}.spots{s}.duration;
                            plan{1,f}.spots(j).charge(spot_index,1) = temp.layers{j}.bursts{b}.spots{s}.targetCharge;
                            plan{1,f}.spots(j).element_id(spot_index,1) = temp.layers{j}.bursts{b}.spots{s}.elementId;
                            plan{1,f}.spots(j).spot_id(spot_index,1) = temp.layers{j}.bursts{b}.spots{s}.spotId;
                            plan{1,f}.spots(j).energy = temp.layers{j}.energy;
                        end
                        burst_time = temp.layers{j}.bursts{b}.spots{s}.startTime + temp.layers{j}.bursts{b}.spots{s}.duration;
                        layer_time = layer_time + burst_time;
                        nb_spots_previous_bursts = nb_spots_previous_bursts + length(temp.layers{j}.bursts{b}.spots);
                    end                    
                else
                    for s = 1:length(temp.layers{j}.spots)
                        plan{1,f}.spots(j).xy_current(s,1) = temp.layers{j}.spots{s}.currentSetpointX;
                        plan{1,f}.spots(j).xy_current(s,2) = temp.layers{j}.spots{s}.currentSetpointY;
                        plan{1,f}.spots(j).xy(s,1) = temp.layers{j}.spots{s}.clinicalX;
                        plan{1,f}.spots(j).xy(s,2) = temp.layers{j}.spots{s}.clinicalY;
                        plan{1,f}.spots(j).time(s,1) = temp.layers{j}.spots{s}.startTime + start_time;
                        plan{1,f}.spots(j).duration(s,1) = temp.layers{j}.spots{s}.duration;
                        plan{1,f}.spots(j).charge(s,1) = temp.layers{j}.spots{s}.targetCharge;
                        plan{1,f}.spots(j).element_id(s,1) = temp.layers{j}.spots{s}.elementId;
                        plan{1,f}.spots(j).spot_id(s,1) = temp.layers{j}.spots{s}.spotId;
                    end
                    layer_time = layer_time + burstemp.layers{j}.spots{s}.startTime + temp.layers{j}.spots{s}.duration;
                end
                if(layer_time>temp.layers{j}.duration)
                    disp('Warning: sum of burst duration exceeds layer duration');
                end
                start_time = start_time + temp.layers{j}.duration;
            end
            
        end
        
    case 'json-1'
        
        plan = cell(1,length(input));
        
        for f=1:length(input)
            
            temp = loadjson(input{f});
            for j=1:length(temp.layer)
                plan{1,f}.spots(j).energy = temp.layer{j}.energy;
                for s = 1:length(temp.layer{j}.spot)
                    plan{1,f}.spots(j).xy_current(s,1) = temp.layer{j}.spot{s}.setpointx;
                    plan{1,f}.spots(j).xy_current(s,2) = temp.layer{j}.spot{s}.setpointy;
                    plan{1,f}.spots(j).xy(s,1) = temp.layer{j}.spot{s}.clinicalx;
                    plan{1,f}.spots(j).xy(s,2) = temp.layer{j}.spot{s}.clinicaly;
                    plan{1,f}.spots(j).time(s,1) = temp.layer{j}.spot{s}.start;
                    plan{1,f}.spots(j).duration(s,1) = temp.layer{j}.spot{s}.duration;
                    plan{1,f}.spots(j).charge(s,1) = temp.layer{j}.spot{s}.charge;
                    plan{1,f}.spots(j).element_id(s,1) = temp.layer{j}.spot{s}.elementid;
                    plan{1,f}.spots(j).spot_id(s,1) = temp.layer{j}.spot{s}.spotid;
                end
            end
            
        end
        
    case 'json-2'
        
        plan = cell(1,length(input));
        
        for f=1:length(input)
            
            temp = convert_json_into_instruction(input{f},'old');
            spots = struct;
            j = 0; %energy layer number
            s = 0; %spot number
            try
                eval(temp);
            catch ME
                disp(temp)
                rethrow(ME)
            end
            plan{1,f}.spots = spots;
            
        end
        
    case 'xml'
        
        disp('Conversion in XML not yet implemented. Abort')
        spots = [];
        return
        
    otherwise
        
        disp('Unknow format')
        
end
end

function input = convert_json_into_instruction(input,format)

if(nargin<2)
    format = '';
end

endl = java.lang.System.getProperty('line.separator').char;

% Convert scanalgo outputs into executable line
switch format
    case 'old'
        input = strrep(input,endl,'');
        input = strrep(input,'\t','');
        input = strrep(input,' ','');
        input = strrep(input,'"','');
        input = strrep(input,'{','');
        input = strrep(input,'}','');
        input = strrep(input,'layer:','');
        input = strrep(input,'spot:','');
        input = strrep(input,']','');
        input = strrep(input,'setpointx','s=s+1;setpointx');
        input = strrep(input,'[','');
        input = strrep(input,':','=');
        input = strrep(input,',',';');
        input = strrep(input,'energy',';j=j+1; s=0;spots(j).energy');
        input = strrep(input,'setpointx','spots(j).xy_current(s,1)');
        input = strrep(input,'setpointy','spots(j).xy_current(s,2)');
        input = strrep(input,'start','spots(j).time(s,1)');
        input = strrep(input,'duration','spots(j).duration(s,1)');
        input = strrep(input,'charge','spots(j).charge(s,1)');
        input = [input,';'];
    otherwise
        %         input = strrep(input,endl,'');
        %         input = strrep(input,char(10),'');
        %         input = strrep(input,'\r','');
        %         input = strrep(input,'\t','');
        %         input = strrep(input,' ','');
        %         input = strrep(input,'"','');
        %         input = strrep(input,'{','');
        %         input = strrep(input,'}','');
        %         input = strrep(input,'layer:',' j=j+1; s=0;');
        %         input = strrep(input,'spot:','s=s+1;');
        %         input = strrep(input,']','');
        %         input = strrep(input,'[','');
        %         input = strrep(input,':','=');
        %         input = strrep(input,',',';');
        %         input = strrep(input,'range','; spots(j).range');
        %         input = strrep(input,'energy','spots(j).energy');
        %         input = strrep(input,'start','spots(j).time(s,1)');
        %         input = strrep(input,'duration','spots(j).duration(s,1)');
        %         input = strrep(input,'clinicalx','spots(j).xy(s,1)');
        %         input = strrep(input,'clinicaly','spots(j).xy(s,2)');
        %         input = strrep(input,'setpointx','spots(j).xy_current(s,1)');
        %         input = strrep(input,'setpointy','spots(j).xy_current(s,2)');
        %         input = strrep(input,'charge','spots(j).charge(s,1)');
        %         input = strrep(input,'elementid','spots(j).element_id(s,1)');
        %         input = strrep(input,'spotid','spots(j).spot_id(s,1)');
        %         input = [input,';'];
        %         input = strrep(input,' ','');
        %         input = strrep(input,' ','');
        %         input = strrep(input,' ','');
        %         input = strrep(input,' ','');
        %         input = strrep(input,' ','');
end
end
