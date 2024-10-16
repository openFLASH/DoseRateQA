%% reg_deformation
%
% Creates a deformation structure to be used for image registration. The structure describes the method used for deforming the prototype image *given* an accumulated deformation field. This should not be confused with the prototype deformation model that is used for the registration (see 'reg_displacement_estimation.m' instead). 
%
%% Syntax
% |def_struct = reg_deformation(def_name, def_boundary)|
%
%% Description
% |def_struct = reg_deformation(def_name, def_boundary)| Structure describing the method for deforming the image.
%
%% Input arguments
% |def_name| - _STRING_ -  Name of the deformation algorithm. the options are :
%
% * 'default' : use the function 'linear_deformation'
% * 'linear' : use the function 'linear_deformation'
%
% |def_boundary| - _TYPE_ - Boundary data given to the |def_struct.function|. See help of the specific function for description of the meaning of the data
%
%% Output arguments
%
% |def_struct| - _STRUCTURE_ - Deformation structure describing the method used for deforming the prototype image
%
% * def_struct.name - _STRING_ - Name of the deformation algorithm (|def_name|)
% * def_struct.function - _STRING_ String of the name of the '*.m' file containing the implementation of the deformation function.
% * def_struct.boundary - _TYPE_ - Boundary data given to the |def_struct.function|. See help of the specific function for description of the meaning of the data
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function def_struct = reg_deformation(def_name, def_boundary)

def_struct = struct;
def_struct.name = def_name;
def_struct.boundary = def_boundary;

% Set deformation function according to functino name. Not much else to do,
% really...
switch lower(def_name)
    case {'default', 'linear'}
        def_struct.function = 'linear_deformation';
    otherwise
        error(['--- reg_deformation: Unknown deformation method: ', def_name]);
end

