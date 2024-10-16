%% get_sad
% Return the source to axis distance (SAD) of the nozzle defined in the beam data model.
% If the SAD is different for the X and Y scanning direction, the average SAD is computed.
%
%% Syntax
% |sad = get_sad(BDL_file)|
%
%
%% Description
% |sad = get_sad(BDL_file)| Return the SAD for the specified beam data model
%
%
%% Input arguments
% |BDL_file| - _STRING_ -  File name of the file containing the beam data model.  The file name must contain the path to the file or be located in a directory contained in 'path'.
%
%% Output arguments
%
% |sad| - _SCALAR_ - Source to axis distance in mm
%
% |sad_X| - _SCALAR_ - Source to axis distance in mm for the X IEC gantry axis
%
% |sad_Y| - _SCALAR_ - Source to axis distance in mm for the Y IEC gantry axis
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [sad , sadX , sadY] = get_sad(BDL_file)

% Authors : G.Janssens

fid = fopen(BDL_file);

while 1
    tline = fgets(fid);
    if ~ischar(tline), break, end
    if(not(isempty(strfind(tline,'SMX to Isocenter distance'))))
        tline = fgetl(fid);
        eval(['sad_X = ',tline,';']);
    elseif(not(isempty(strfind(tline,'SMY to Isocenter distance'))))
        tline = fgetl(fid);
        eval(['sad_Y = ',tline,';']);
    end
end

sad = (sad_X + sad_Y)/2;
sadX = sad_X;
sadY = sad_Y;

fclose (fid);

end
