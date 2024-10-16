%% getMachineFromBDL
% Read the name and the type of the treatment machine from the MCsquare beam data library
% and update the |Plan| structure
%
%% Syntax
% |[MachineType , MachineName] = getMachineFromBDL(BDL)|
%
%
%% Description
% |[MachineType , MachineName] = getMachineFromBDL(BDL)| Description
%
%
%% Input arguments
%
% |BDL| -_STRING_- Name and full path to Beam data library
%
%
%% Output arguments
%
% |MachineName| - _STRING_ - Name of the treatment machine
%
% |MachineType| - _STRING_ - Description of the treatment machine (PROTEUSone , PROTEUSplus)
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function [MachineType , MachineName] = getMachineFromBDL(BDL)

  fid = fopen(BDL);

  MachineName = []; %Default value in case the tag is missing in an older BDL
  MachineType = [];

  while 1
      tline = fgets(fid);
      if ~ischar(tline)
          break;
      end
      if (not(isempty(strfind(tline,'Machine_Name'))))
          idx = strfind(tline,'=');
          MachineName = strtrim(tline(idx+1:end-1)); %remove trailing space and the ending \n
      end
      if (not(isempty(strfind(tline,'Machine_Type'))))
          idx = strfind(tline,'=');
          MachineType = strtrim(tline(idx+1:end-1)); %remove trailing space and the ending \n
      end
  end


  fclose (fid);

end
