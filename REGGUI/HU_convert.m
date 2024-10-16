function [Densities, SPR, SP, RelElecDensity, Water_SP, Water_ElecDensity] = HU_convert(HU,HU_Density_Data,Density_Data,HU_Material_Data,Material_Data,MaterialsDirectory)

% Authors : K. Souris

if(nargin<6)
    [~ , ~ , ~ , MaterialsDirectory] = get_MCsquare_folders(); %folder with the definition of the materials
end
Material_List_File = fullfile(MaterialsDirectory, 'list.dat');
if(exist(Material_List_File, 'file') ~= 2)
    error(['The material dictionary "' Material_List_File '" does not exist!']);
end

Densities = interp1(HU_Density_Data, Density_Data, HU, 'linear', 'extrap');
Materials(1:length(HU)) = Material_Data(1);
for i=1:length(Material_Data)
    Materials(HU >= HU_Material_Data(i)) = Material_Data(i);
end

% Import the list of materials
fid = fopen(Material_List_File);
Material_List_File = textscan(fid, '%d %s', 'delimiter', '\n', 'MultipleDelimsAsOne',1);
fclose(fid);
Material_index = Material_List_File{1};
Material_name = Material_List_File{2};

% Import water electron density and stopping powers (SP) at 100 MeV
Water_SP = MC2_import_SP_data(fullfile(MaterialsDirectory, 'Water', 'G4_Stop_Pow.dat'));
Water_ElecDensity = MC2_import_ElecDensity(fullfile(MaterialsDirectory, 'Water', 'Material_Properties.dat'));

% Compute SPR corresponding to each HU
for i=1:length(HU)
    index = find(Material_index == Materials(i));
    Name = strsplit(Material_name{index}, {' ', '\t', '#'});
    Name = Name{1};
    SP(i) = MC2_import_SP_data(fullfile(MaterialsDirectory, Name, 'G4_Stop_Pow.dat'));
    SPR(i) = Densities(i) * SP(i) / Water_SP;
    ElecDensity = MC2_import_ElecDensity(fullfile(MaterialsDirectory, Name, 'Material_Properties.dat'));
    RelElecDensity(i) = Densities(i) * ElecDensity / Water_ElecDensity;
end
