%% get_beam_info_from_log_beamfile
% Load and parse the file 'beam_config_*.txt' from the BMS data recorder
%
%% Syntax
% |[mBeamId , mGantryAngle , beaminfo] = get_beam_info_from_log_beamfile(fileName)|
%
%
%% Description
% |[mBeamId , mGantryAngle , beaminfo] = get_beam_info_from_log_beamfile(fileName)| Description
%
%
%% Input arguments
% |fileName| - _STRING_ - Path and file name of the 'beam_config_*.txt' contained in the irradiation log of the BMS data recorder
%
%
%% Output arguments
%
% |mBeamId| - _STRING_ -  Beam ID contained in the configuration file
%
% |mGantryAngle| - _SCALAR_ - Gantry angle (deg) contained in the configuration file
%
% |beaminfo| - _STRUCTURE_ - Structure with the beam info contained in the configuration file
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com), R. Labarbe

function [mBeamId , mGantryAngle , beaminfo] = get_beam_info_from_log_beamfile(fileName)

mBeamId = '';
mGantryAngle = [];
beaminfo = struct;

ref_string_id = 'mBeamId';
ref_string_id2 = ' beamId';
ref_string_angle='mGantryAngle';

ref_string_list = {'mPatientId' , 'mPlanId' ,  'mBeamId' , 'mFractionId' , 'mBeamDeliveryPointId', 'mBeamSupplyPointId' , 'mTreatmentMode' , 'mGantryAngle' , 'mCycloBeamCurrent'};

% Read file
fid = fopen(fileName,'r');
while 1
      tline = fgetl(fid);
    if ~ischar(tline), break, end
    index = strfind(tline,ref_string_id);
    if(not(isempty(index)))
        eval(strrep(strrep(strrep(strrep(tline,':',''';%'),'/',''';%'),'<',''),'>','='''))
    end
    index = strfind(tline,ref_string_id2);
    if(not(isempty(index)))
        eval(strrep(strrep(tline(index:end),':',''';%'),'=','='''));
        mBeamId = beamId;
    end
    index = strfind(tline,ref_string_angle);
    if(not(isempty(index)))
        eval(strrep(strrep(strrep(tline,'/',''';%'),'<',''),'>','='''))
    end

    for idx = 1: numel(ref_string_list)
      index = strfind(tline,ref_string_list{idx});
      if(not(isempty(index)))
        beaminfo = extractValue(tline , ref_string_list{idx} , beaminfo);
      end
    end

end
fclose(fid);
end


%--------------------------------
function beaminfo = extractValue(tline , ref_string , beaminfo)
   index = strfind(tline,ref_string);
   indexClBr = strfind(tline,'>');
   indexOpBr = strfind(tline,'<');

   value = tline(indexClBr(1)+1:indexOpBr(2)-1);
   numValue = str2num(value);
   if ~isempty(numValue)
     beaminfo = setfield(beaminfo,ref_string,numValue);
   else
     beaminfo = setfield(beaminfo,ref_string,value);
   end

end
