%% reg_resampling
% Creates a resampling structure containing all necessary information to perform resampling. This includes the scales to process and number of iterations per scale. For interactive use, it is also possible to define the out_scale what defines what scale the output should be computed for.
%
%% Syntax
% |res_struct = reg_resampling(resampling_name, min_scale, max_scale, out_scale)|
%
%% Description
% |res_struct = reg_resampling(resampling_name, min_scale, max_scale, out_scale)| Structure to describe the resampling method when rescaling an image
%
%% Input arguments
% |resampling_name| - _STRING_ - Algorithm to use to resample the image. The following strings are possible: 'default'
%
% |min_scale| - _INTEGER_ -  Minimum scale of the resampling process
%
% |max_scale| - _INTEGER_ -  Maximum scale of the resampling process
%
% |out_scale| - _INTEGER_ -  Define the scale of the data to be outputed for interactive use. The definition of the scale is given in the resampler function "standard_resampler".
%
%% Output arguments
%
% |res_struct| - _STRUCTURE_ - Structure describing the resampling function to resample an image
%
% * res_struct.function - _STRING_ String of the name of the '*.m' file containing the implementation of the resampling function. (Default: 'standard_resampler')
%
% * res_struct.name - _STRING_ - Algorithm to use to resample the image (|resampling_name|). 
%
% * res_struct.min_scale - _INTEGER_ -  Minimum scale of the resampling process
%
% * res_struct.max_scale - _INTEGER_ -  Maximum scale of the resampling process
%
% * res_struct.out_scale - _INTEGER_ -  Define the scale of the data to be outputed for interactive use
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res_struct = reg_resampling(resampling_name, min_scale, max_scale, out_scale);

res_struct = struct;
res_struct.name = resampling_name;
res_struct.min_scale = min_scale;
res_struct.max_scale = max_scale;
res_struct.out_scale = out_scale;

% Determine the method function
switch lower(resampling_name)
    case 'default'
        % Set the resampler function name
        res_struct.function = 'standard_resampler';
    otherwise
        error(['--- reg_resampling: Unknown resampling method: ', resampling_name]);
end
