%% regularisation_none
% The function do not apply any regularization. It simply returns the inputed deformation field and certainty map.
%
%% Syntax
% |[out_field, out_cert] = regularisation_none(proc, in_field, in_cert, scale, data)|
%
%
%% Description
% |[out_field, out_cert] = regularisation_none(proc, in_field, in_cert, scale, data)| perform regularization of the deformation field and update the certainty map
%
%
%% Input arguments
% |proc| - Not used
%
% |in_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the previous deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}.
%
% |in_cert|  - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |scale| - Not used
%
% |data| - Not used
%
%% Output arguments
%
% |out_field|| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the regularized deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. It is equal to |in_field|
%
% |out_cert|  - _MATRICE_ - Certainty map of the field. It is equal to |in_cert|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [out_field, out_cert] = regularisation_none(proc, in_field, in_cert, scale, data)

    out_field = in_field;
    out_cert = in_cert;
