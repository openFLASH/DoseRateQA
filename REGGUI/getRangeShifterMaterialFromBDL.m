%% getRangeShifterMaterialFromBDL
% Read the name of the range shifter material from the MCsquare beam data library
% and update the |Plan| structure with the material
%
%% Syntax
% |res = help_header(im1,im2)|
%
%
%% Description
% |res = help_header(im1,im2)| Description
%
%
%% Input arguments
%
% |Plan| - _struct_ - MIROpt structure where all the plan parameters are stored.
%
%
%% Output arguments
%
% |Plan| - _struct_ - MIROpt structure where all the plan parameters are stored.The following parameter is updated
%   * |Plan.Beams(:).RSinfo.RangeShifterMaterial| -_STRING_- Name of the mateiral in  'list.dat' of the MCsqaure materials
%
%
%% Contributors
% Authors : L. Hotoiu, R. Labarbe (open.reggui@gmail.com)

function Plan = getRangeShifterMaterialFromBDL(Plan)

  [~ , ~ , ~ , MaterialsDirectory] = get_MCsquare_folders(); %folder with the definition of the materials
  BDLFileText = fileread( Plan.BDL);
  numericMaterialID = string(regexp(BDLFileText, '(?<=RS_material[^0-9]*)[0-9]*\.?[0-9]+', 'match'));
  materialListFileText = fileread(fullfile(MaterialsDirectory, 'list.dat'));
  wordMaterialID = string(regexp(materialListFileText, strcat('(?s)(?<=', numericMaterialID, ').*?(\t|\n)'), 'match', 'once'));

  for rr = 1:length(Plan.Beams)
      Plan.Beams(rr).RSinfo.RangeShifterMaterial = strtrim(strrep(wordMaterialID, ' ', ''));
  end

end
