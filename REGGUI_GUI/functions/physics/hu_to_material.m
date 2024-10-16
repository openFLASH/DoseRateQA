%% hu_to_material
% Convert from Hounsfield units to material type / elemental composition.
%
%% Syntax
% |[M,M_legend,C] = hu_to_material(H,model=STRUCTURE)|
%
% |[M,M_legend,C] = hu_to_material(H,model=STRING)|
%
%
%% Description
% |[M,M_legend,C] = hu_to_material(H,model=STRUCTURE)|   Convert HU of a CT scan into elemental composition using a clibration curve defined in the structure
%
% |[M,M_legend,C] = hu_to_material(H,model=STRING)| Convert HU of a CT scan into elemental composition using the claibration curve defined in a text file
%
%
%% Input arguments
% |H| - _SCALAR MATRIX_ - |H(x,y,z)| CT scan image (unit: HU) to use to compute the density
%
%
% |model| There are 2 syntaxes:
%
% * Syntax 1: _STRUCTURE_ - |model.Density| - _CELL MATRIX_ - Definition of the mass density of the tissues
% * --|model.Material| - _CELL MATRIX_ - Definition of the tissue and Hounsfield unit
% * ------|Material{i,1}| - _SCALAR_ - Minimum Hounsfield unit for the tissue |i|. The tissue has HU between Material{i,1}< HU <=Material{i+1,1}
% * ------|Material{i,2}| - _STRING_ - Name of the tissue |i|
% * --|model.Composition| - _SCALAR MATRIX_ - Elemental composition of the tissue
% * ------|Composition(i,1)| - _SCALAR_ - Minimum Hounsfield unit for the tissue |i|. The tissue has HU between Material{i,1}< HU <=Material{i+1,1}
% * ------|Composition(i,j)| - _SCALAR_ - (with 2<=j<=7) Fraction massique of the element j for the tissue i. The column are in the order H,C,N,O,P,Ca
% * Syntax 2: _STRING_ - File name of the file containing the HU to SPR calibration curve.  The file name must contain the path to the file or be located in a directory contained in 'path'. See read_reggui_material_file.m for details.
%
%
%% Output arguments
%
% |M| - _SCALAR MATRIX_ - |D(x,y,z)=i| The voxel at position (x,y,z) contains a material of type |i|
%
% |M_legend| - _CELL VECTOR of STRINGS_ - |M_legend{i}| String describing the material of type |i|
%
% |C| - _CELL VECTOR of SCALAR matrix_ - |C{n}(x,y,z)| Mass fraction of the element |n| in voxel located at (x,y,z). |n| scansthe elements in the order H,C,N,O,P,Ca
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [M,M_legend,C] = hu_to_material(H,model)

% Authors : G.Janssens

M = H*0;% material index in [-]
M_legend = cell(0);
C = cell(0);
for n=1:6
    C{n} = M;
end

if(ischar(model)) % reggui parameter file
    if(exist(model,'dir')==7)
        disp('Conversion not compatible.')
    elseif(exist(model,'file')==2)
        model = read_reggui_material_file(model);
    else
        disp('Conversion model not found.')
        return
    end
end
model.Material{1,1} = -Inf;

for i=1:size(model.Material,1)
    M_legend{length(M_legend)+1} = model.Material{i,2};
    M(H>=model.Material{i,1}) = i;
    for n=1:6
        C{n}(M==i) = model.Composition(i,n+1);
    end
end


