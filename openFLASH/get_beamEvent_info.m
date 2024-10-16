%% get_beamEvent_info
% Load the 'events.*.csv' file from the machine logs
% Read some information from the logs
%
%
%% Syntax
% |beaminfo = get_beamEvent_info(fileName)|
%
%
%% Description
% |beaminfo = get_beamEvent_info(fileName)| Description
%
%
%% Input arguments
% |fileName| -_STRING_- Path and file name of the log file to process
%
%
%% Output arguments
%
% |beaminfo| -_STRUCT_- Information about the beam
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function beaminfo = get_beamEvent_info(fileName)

  ref_string_list = {'START_BEAM_IRRADIATION' , 'END_BEAM_IRRADIATION'};
  beaminfo = struct;

  % Read file
  fid = fopen(fileName,'r');

  while 1

        tline = fgetl(fid);
        if ~ischar(tline)
           break;
        end

        for idx = 1: numel(ref_string_list)

          index = strfind(tline,ref_string_list{idx});

          if (~isempty(index))
            Wcomma = strfind(tline,','); %Find the position of the comma
            if ~isempty(Wcomma)
              beaminfo = setfield(beaminfo , ref_string_list{idx} , tline(1:Wcomma-1));
            end

          end
      end
  end

  fclose(fid);

end
