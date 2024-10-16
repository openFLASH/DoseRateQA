%% hu_to_density
% Convert from Hounsfield units to mass densities. The function interpolates to find the mass densities |D| associated to the Hounsfield units |H| according to the piecewise linear function described in |model|.
%
% For |H| outside the domain found in model, densities are extrapolated for |H| greater than the the maximum value found in the model and set to the minimum value found in the model for |H| less than the minimum value.
%
%% Syntax
% |D = hu_to_density(H,model=STRUCTURE)|
%
% |D = hu_to_density(H,model=STRING)|
%
%
%% Description
% |D = hu_to_density(H,model=STRUCTURE)|  Convert HU of a CT scan into mass density using a clibration curve defined in the structure
%
% |D = hu_to_density(H,model=STRING)|  Convert HU of a CT scan into mass density using the claibration curve defined in a text file
%
%
%% Input arguments
% |H| - _SCALAR MATRIX_ - |H(x,y,z)| CT scan image (unit: HU) to use to compute the density
%
%
% |model| There are 2 syntaxes:
%
% * _STRUCTURE_ - model.Stopping_Power(HU,WE) = _MATRIX of DOUBLE_ Tabulated definition of the calibration curve HU to WE (Water equivalent pathlength)
% * _STRING_ - File name of the file containing the HU to SPR calibration curve.  The file name must contain the path to the file or be located in a directory contained in 'path'. See read_reggui_material_file.m for details.
%
%
%% Output arguments
%
% |D| - _SCALAR MATRIX_ - |D(x,y,z)| mass density of the voxel at position (x,y,z)
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function D = hu_to_density(H,model)

if(ischar(model)) % reggui parameter file
    if(exist(model,'dir')==7)
        [HU,D] = Compute_SPR_data(model);
        model = struct;
        model.Stopping_Power = [HU',D'];
    elseif(exist(model,'file')==2)
        model = read_reggui_material_file(model);
    else
        disp('Conversion model not found.')
        return
    end
end

if(isstruct(model)) % structure with material parameters
    model = model.Density;
end

HU_ref = model(:, 1) ;
d_ref = model(:, 2) ;
D = interp1(HU_ref, d_ref, H, 'linear','extrap') ;
D(D<min(d_ref)) = min(d_ref) ;
