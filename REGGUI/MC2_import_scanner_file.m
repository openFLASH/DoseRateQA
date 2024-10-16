%% MC2_import_scanner_file
% Description
%
% Read the content of the file "plugins\openMCsquare\lib\Scanners\default\HU_Material_Conversion.txt".
% This file links the Hounsfield unit to a material ID.
% The material ID are defined in the file "plugins\openMCsquare\lib\Materials\list.dat"
% The physical descritpion of each material are described in the files in the folders "plugins\openMCsquare\lib\Materials"
%
%
%% Syntax
% |[HU, materialID , descr] = MC2_import_scanner_file(FileName)|
%
%
%% Description
% |[HU, materialID , descr] = MC2_import_scanner_file(FileName)| Description
%
%
%% Input arguments
% |FileName| - _STRING_ - Full file name of the scanner file "HU_Material_Conversion.txt"
%
%
%% Output arguments
%
% |HU| - _SCALAR VECTOR_ - HU(i) is the Hounsfield unit
%
% |materialID| - _SCALAR VECTOR_ - materialID(i) ID of the material represented by the Hounsfield unit |HU(i)|
%
% |descr| -_CELL VECTOR_- |descr{i}| String describing the material associated with the i-th HU
%
%% Contributors
% Authors : K. Souris (open.reggui@gmail.com)

function [HU, materialID , descr] = MC2_import_scanner_file(FileName)

fid=fopen(FileName,'r');
if(fid < 0)
    error(['Unable to open file ' FileName])
end

HU = [];
materialID = [];
descr = {};

while(~feof(fid))
    Read_Data = fgetl(fid);
    [Read_Data , label] = strtok(Read_Data, '#');
    Read_Data = strsplit(Read_Data, {' ', '\t'});
    if(numel(Read_Data) >= 2)
        tmp1 = str2double(Read_Data(1));
        tmp2 = str2double(Read_Data(2));
        if(isnan(tmp1)==0 && isnan(tmp2)==0)
          HU = [HU tmp1];
          materialID = [materialID tmp2];
          descr{end+1} = strtrim(extractAfter(label,'#'));
        end
    end
end

fclose(fid);

end
