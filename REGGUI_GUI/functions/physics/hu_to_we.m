%% hu_to_we
% Convert HU of a CT scan into Water equivalent pathlength (WEPL) using a calibration curve
%
%% Syntax
% |WE = hu_to_we(H,model=STRUCTURE)|
%
% |WE = hu_to_we(H,model=STRING)|
%
%% Description
% |WE = hu_to_we(H,model=_STRUCTURE_)| Convert HU of a CT scan into Water equivalent pathlength (WEPL) using a calibration curve defined in the structure
%
% |WE = hu_to_we(H,model=_STRING_)| Convert HU of a CT scan into Water equivalent pathlength (WEPL) using the calibration curve defined in a text file
%
%% Input arguments
% |H| - _SCALAR MATRIX_ - |H(x,y,z)| CT scan image (unit: HU) to use to compute WEPL
%
% |model| There are 2 syntaxes:
%
% * _STRUCTURE_ - model.Stopping_Power(HU,WE) = _MATRIX of DOUBLE_ Tabulated definition of the calibration curve HU to WE (Water equivalent pathlength)
% * _STRING_ - File name of the file containing the HU to SPR calibration curve. The file name must contain the path to the file or be located in a directory contained in 'path'. See read_reggui_material_file.m for details.
%
%% Output arguments
% |WE| - _SCALAR MATRIX_ Image |WE(x,y,z)| of the same size as |H|. Water equivalent path length of the voxel (x,y,z) in mm.
%
%% NOTE
% The function makes the simplification that the stopping power ratio is computed using the same energy E0 for all points.
%
%% Contributors
% Authors : G.Janssens

function WE = hu_to_we(H,model)

if(ischar(model)) % reggui parameter file
    if(exist(model,'dir')==7)
        [HU,~,SPR] = Compute_SPR_data(model);
        model = struct;
        model.Stopping_Power = [HU',SPR'];
    elseif(exist(model,'file')==2)
        model = read_reggui_material_file(model);
    else
        disp('Conversion model not found.')
        return
    end
end

if(isstruct(model)) % structure with material parameters
    model = model.Stopping_Power;
end

WE = H.*0;
for i=1:length(model)-1
    WE(H>model(i,1) & H<=model(i+1,1)) = ((abs(H(H>model(i,1) & H<=model(i+1,1))-model(i+1,1)))*model(i,2) + (abs(H(H>model(i,1) & H<=model(i+1,1))-model(i,1)))*model(i+1,2))/abs(model(i+1,1)-model(i,1));
end
WE(H>model(i+1,1)) = model(i+1,2);
