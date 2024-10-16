%% reg_displacement_estimation
% Creates a deformation structure to be used for image registration. This is the algorithm used for the non-rigid registration of the mobile image onto the fixed image.
%
%% Syntax
% |de_struct = reg_displacement_estimation(disp_name)|
%
%% Description
% |de_struct = reg_displacement_estimation(disp_name)| returns a structure describing the registration algorithm
%
%% Input arguments
%
% |def_name| - _STRING_ -  Name of the non rigid registration algorithm for each process:
%
% * 'default','morphons' : function is 'quadphase_lsq_normconv'
% * 'demons': function is 'demons'
% * 'demons_dm': function is 'demons_dm'
% * 'block_matching','block_matching_ssd': function is 'block_matching'
% * 'block_matching_mi': function is 'block_matching_MI'
%
%% Output arguments
%
% |de_struct|- _STRUCTURE_ - Deformation structure describing the method used for the registration of the prototype image to the fixed image
%
% * de_struct.name - _STRING_ - Name of the deformation algorithm (|disp_name|)
% * de_struct.function - _STRING_ String of the name of the '*.m' file containing the implementation of the deformation function.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function de_struct = reg_displacement_estimation(disp_name)

de_struct = struct;
de_struct.name = disp_name;

switch lower(disp_name)
    case {'default','morphons'}
        %de_struct.function = 'quadphase_lsq';        
        de_struct.function = 'quadphase_lsq_normconv';
        load('quadphase_lsq.mat');
        de_struct.data = quadphase_lsq_data;
    case 'demons'
        de_struct.function = 'demons';
    case 'demons_dm'
        de_struct.function = 'demons_dm';
    case {'block_matching','block_matching_ssd'}
        de_struct.function = 'block_matching';
    case {'block_matching_mi'}
        de_struct.function = 'block_matching_MI';            
    otherwise
        error(['--- reg_displacement: Unknown displacement method: ', disp_name]);
end
