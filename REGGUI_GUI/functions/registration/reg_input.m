%% reg_input
% Creates a data structure describing the FIXED image of a registration process
%
%% Syntax
% |in_struct = reg_input(input_data)|
%
% |in_struct = reg_input(input_data, input_cert)|
%
% |in_struct = reg_input(input_data, input_cert, input_mask)|
%
%
%% Description
% |in_struct = reg_input(input_data)| Creates the image data structure with the |input_data| image
%
% |in_struct = reg_input(input_data, input_cert)| Creates the image data structure with the |input_data| image and includes the certainty data
%
% |in_struct = reg_input(input_data, input_cert, input_mask)| Creates the image data structure with the |input_data| image and includes the certainty data. If inhomogenoues spatial influence is desired, also includes the segmentation mask.
%
%
%% Input arguments
% |input_data| - _MATRIX of SCALAR_ -  |input_data(x,y,z)| represents the intensity of the image at voxel (x,y,z)
%
% |input_cert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |input_mask| - _MATRIX_ -  Segmentation mask if inhomogeneous spatial influence is desired.
%
%
%% Output arguments
%
% |in_struct| - _STRUCTURE_ - Empty data structure for the registration process
%
% * |in_struct.messages| - _STRING_ - String describing the data type of the structure
% * |in_struct.data| - _MATRIX of SCALAR_ -  |data(x,y,z)| represents the intensity of the voxel (x,y,z)
% * |in_struct.data_min| - _SCALAR_ - Minimum value of the image
% * |in_struct.data_max| - _SCALAR_ - Minimum value of the image
% * |in_struct.data_mean| - _SCALAR_ - Mean value of the image
% * |in_struct.dims| - _SCALAR_ - Number of dimensions of the image
% * |in_struct.cert| - _MATRICE_ [OPTIONAL] - The certainty about the value of the intensity at voxel (x,y,z)
% * |in_struct.cert_min| - _SCALAR_ - [OPTIONAL] Minimum of the certainty field
% * |in_struct.cert_max| - __ - [OPTIONAL] Maximum of the certainty field
% * |in_struct.cert_dims| - __ - [OPTIONAL] Number of dimensions of the certainty field
% * |in_struct.mask - _MATRICE_ [OPTIONAL] - The segmentation mask of the image for inhomogeneous spatial influence
% * |in_struct.mask_min| - _SCALAR_ - [OPTIONAL]  Minimum of the mask
% * |in_struct.mask_max| - _SCALAR_ - [OPTIONAL]  Maximum of the mask
% * |in_struct.mask_dims| - _SCALAR_ - [OPTIONAL] Number of dimensions of the mask
% * |in_struct.rescaled_data| - _EMPTY_ - Rescaled image
% * |in_struct.rescaled_cert| - _EMPTY_ - Rescaled certainty field
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function in_struct = reg_input(input_data, input_cert, input_mask)
% function in_struct = reg_input(input_data, input_cert)
% Loads input of a variety of data types

in_struct = struct;
in_struct.messages = {'reg input data structure'};

in_struct.data = input_data;
in_struct.data_min = min(in_struct.data(:));
in_struct.data_max = max(in_struct.data(:));
in_struct.data_mean = mean(in_struct.data(:));
in_struct.dims = length(size(in_struct.data));

% Load the input certainty values (used by the normalised convolution)
if(~exist('input_cert', 'var'))
    input_cert = 1;
end
in_struct.cert = input_cert;
in_struct.cert_min = min(in_struct.cert(:));
in_struct.cert_max = max(in_struct.cert(:));
in_struct.cert_dims = length(size(in_struct.cert));

% Load the input mask image/volume
if(ndims(input_mask)==ndims(input_data)) % If inhomogenoues spatial influence is desired
    in_struct.mask = input_mask;
    in_struct.mask_min = min(in_struct.mask(:));
    in_struct.mask_max = max(in_struct.mask(:));
    in_struct.mask_dims = length(size(in_struct.mask));
else
    in_struct.mask = 1;
    in_struct.mask_min = 1;
    in_struct.mask_max = 1;
    in_struct.mask_dims = 1;
end

in_struct.rescaled_data = [];
in_struct.rescaled_cert = [];
