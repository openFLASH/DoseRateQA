%----------------------------------------
% Convert the material file exported from the Raystation into
% the format required by MCsquare
%----------------------------------------

clear
close all

% INPUTS
RSMaterialFile = 'c:\iba\flash\REGGUI_Doserate_QA\RS2MC2conversion\material.txt' %File from Rasytation with the material composition
HU2densityconversion = 'c:\iba\flash\REGGUI_Doserate_QA\RS2MC2conversion\HU_Density_Conversion_initial.txt' %HU to density table as defiend in the Raystation.

% OUTPUTS
materialsPath = 'c:\iba\flash\REGGUI_Doserate_QA\RS2MC2conversion\Ouput_materials\' %Output folder where to save the material files
scannerPath = 'c:\iba\flash\REGGUI_Doserate_QA\RS2MC2conversion\Output_scanner\' %Output folder where to save the scanner calibration files


RS_param = read_RS_param(RSMaterialFile) %REad the material composition stored in the Raystation
modelHU2rho = readRS_HU2rho(HU2densityconversion) %REad the table HU to density

%Create the MAterial files and the scanner calibration file
%from the Raystation export
exportRSConversion2MC2(modelHU2rho, RS_param, materialsPath, scannerPath)
