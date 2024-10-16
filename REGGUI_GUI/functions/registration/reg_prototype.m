%% reg_prototype
% Creates a data structure describing the MOVING image of a registration process
%
%% Syntax
% |prot_struct = reg_prototype(prototype_data)|
%
%
%% Description
% |prot_struct = reg_prototype(prototype_data)| Creates the image data structure with the |input_data| image
%
%
%% Input arguments
% |prototype_data| - _MATRIX of SCALAR_ -  |input_data(x,y,z)| represents the intensity of the image at voxel (x,y,z)
%
%
%% Output arguments
%
% |prot_struct| - _STRUCTURE_ - Empty data structure for the registration process
%
% * |prot_struct.messages| - _STRING_ - String describing the data type of the structure
% * |prot_struct.data| - _MATRIX of SCALAR_ -  |data(x,y,z)| represents the intensity of the voxel (x,y,z)
% * |prot_struct.data_min| - _SCALAR_ - Minimum value of the image
% * |prot_struct.data_max| - _SCALAR_ - Minimum value of the image
% * |prot_struct.data_mean| - _SCALAR_ - Mean value of the image
% * |prot_struct.rescaled| - _EMPTY STRUCTURE_ - Rescaled image
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function prot_struct = reg_prototype(prototype_data)

prot_struct = struct;
prot_struct.messages = {'reg prototype'};

prot_struct.data = prototype_data;
prot_struct.data_min = min(prot_struct.data(:));
prot_struct.data_max = max(prot_struct.data(:));
prot_struct.data_mean = mean(prot_struct.data(:));

prot_struct.rescaled = struct;



