%% read_reggui_material_file
% Read the text file with the elemental composition of the tissues and their Hounsfield unit. The data is used for the creation of the HU to stopping power conversion.
%
%% Syntax
% |model = read_reggui_material_file(filename)|
%
%
%% Description
% |model = read_reggui_material_file(filename)| Read the tissue model composition
%
%
%% Input arguments
% |filename| _STRING_ - File name of the file containing the HU to SPR calibration curve.  The file name must contain the path to the file or be located in a directory contained in 'path'.
%
%
%% Output arguments
%
% |model| _STRUCTURE_ - Description of the tissue composition and HU

% * |model.Material| - _CELL MATRIX_ - Definition of the tissue and Hounsfield unit
% * ------|Material{i,1}| - _SCALAR_ - Minimum Hounsfield unit for the tissue |i|. The tissue has HU between Material{i,1}< HU <=Material{i+1,1}
% * ------|Material{i,2}| - _STRING_ - Name of the tissue |i|
% * |model.Composition| - _SCALAR MATRIX_ - Elemental composition of the tissue
% * ------|Composition(i,1)| - _SCALAR_ - Minimum Hounsfield unit for the tissue |i|. The tissue has HU between Material{i,1}< HU <=Material{i+1,1}
% * ------|Composition(i,j)| - _SCALAR_ - (with 2<=j<=7) Mass fraction of the element j for the tissue i. The column are in the order H,C,N,O,P,Ca
% * |model.Density| - _SCALAR MATRIX_ - Definition of the mass density of the tissues
% * ------|Density(i,1)| - _SCALAR_ - Minimum Hounsfield unit for the tissue |i|. The tissue has HU between Material{i,1}< HU <=Material{i+1,1}
% * ------|Density(i,2)| - _SCALAR_ - Mass density of the tissue |i|.
% *|model.Stopping_Power(HU,WE)| _SCALAR MATRIX_ Tabulated definition of the calibration curve HU to WE (Water equivalent pathlength, in mm)
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function model = read_reggui_material_file(filename)

% Authors : G.Janssens

fid = fopen(filename,'r');

if(fid==-1)
    error(['Cannot open file ',filename]);
end

tline = fgetl(fid);
txt = [];
while ischar(tline)
    txt = [txt,';',tline];
    tline = fgetl(fid);    
end
txt = strrep(txt,'\t',' ');% removes tab
for i=1:30
    txt = strrep(txt,'  ',' ');% removes multiple spaces
end
txt = strrep(txt,'#HU_to_Material;','M_C = {');
txt = strrep(txt,';#HU_to_Density;','};D = [');
txt = strrep(txt,';#HU_to_Stopping_Power;','];S = [');
txt = [txt,'];'];
fclose(fid);

eval(txt);

if ~isempty(M_C)
    M = M_C(:,1:2);
    C = cell2mat(M_C(:,[1,3:end]));
else
    M = [] ;
    C = [] ;
end

model.Material = M;
model.Composition = C;
model.Density = D;
model.Stopping_Power = S;
