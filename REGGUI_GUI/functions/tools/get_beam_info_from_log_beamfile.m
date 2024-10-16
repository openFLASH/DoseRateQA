function [mBeamId,mGantryAngle] = get_beam_info_from_log_beamfile(fileName)

mBeamId = '';
mGantryAngle = [];

ref_string_id = 'mBeamId';
ref_string_id2 = ' beamId';
ref_string_angle='mGantryAngle';

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
end
fclose(fid);
