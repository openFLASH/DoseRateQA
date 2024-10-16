%% Compute_SPR_data
% Retrieve the calibration file of a CT scanner. For each HU, the density, stopping power and RelElecDensity
% are returned from the calibration file.
%
%% Syntax
% |[HU, Densities, SPR, SP, RelElecDensity] = Compute_SPR_data(ScannerDirectory)|
%
%
%% Description
% |[HU, Densities, SPR, SP, RelElecDensity] = Compute_SPR_data(ScannerDirectory)| Description
%
%
%% Input arguments
% |ScannerDirectory| - _STRING_ - Full path to the scanner directory
%
%
%% Output arguments
%
% |HU| -_SCALAR VECTOR_- Hounsfield unit defined in the calibration file of the scanner
%
% |Density(i)| -_SCALAR VECTOR_- Density (g/cm3) of the material defined by |HU(i)|
%
% |SPR(i)| -_SCALAR VECTOR_- Relative stopping power (relative to water) at 100 MeV [SPR(i) = Density(i) * SP(i) / Water_SP] of the material defined by |HU(i)|
%
% |SP(i)| -_SCALAR VECTOR_- Mass stopping powers (MeV cm2/g) at 100 MeV of the material defined by |HU(i)|
%
% |RelElecDensity(i)| -_SCALAR_- Electron density relative to water of the material defined by |HU(i)|
%
%
%% Contributors
% Authors : K. Souris (open.reggui@gmail.com)

function [HU, Densities, SPR, SP, RelElecDensity] = Compute_SPR_data(ScannerDirectory,MaterialsDirectory)

% Authors : K. Souris

HU_Density_File = fullfile(ScannerDirectory, 'HU_Density_Conversion.txt');
HU_Material_File = fullfile(ScannerDirectory, 'HU_Material_Conversion.txt');

if(exist(HU_Density_File, 'file') ~= 2)
    error(['The calibration file "' HU_Density_File '" does not exist!']);
elseif(exist(HU_Material_File, 'file') ~= 2)
    error(['The calibration file "' HU_Material_File '" does not exist!']);
end

% Import scanner calibration data
[HU_Density_Data,Density_Data] = MC2_import_scanner_file(HU_Density_File);
[HU_Material_Data,Material_Data] = MC2_import_scanner_file(HU_Material_File);

% Find the density and material corresponding to each HU
HU = unique([HU_Density_Data HU_Material_Data]);
[Densities, SPR, SP, RelElecDensity] = HU_convert(HU,HU_Density_Data,Density_Data,HU_Material_Data,Material_Data,MaterialsDirectory);
