%% regularisation_normgauss
% Performs normalised gaussian smoothing of the deformation/displacement field. The image is multiplied by the certainty map before the convolution with the gaussian kernel. The convolved image is then normalised by the certainty map smoothed by the gaussian kernel:
% |out_cert = conv(in_field .* in_cert , gauss) ./ conv(in_cert , gauss)
%
%% Syntax
% |[out_field, out_cert] = regularisation_normgauss(proc, in_field, in_cert, scale, data=VECTOR)|
%
% |[out_field, out_cert] = regularisation_normgauss(proc, in_field, in_cert, scale, data=SCALAR)|
%
%
%% Description
% |[out_field, out_cert] = regularisation_normgauss(proc, in_field, in_cert, scale, data)| perform regularization of the deformation field and update the certainty map
%
%
%% Input arguments
% |proc| - Not used
%
% |in_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the previous deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}.
%
% |in_cert|  - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |scale| - _INTEGER_ -  Scale of the current deformable registration process. The definition of the scale is given in the resampler function "standard_resampler".
%
% |data| - _VECTOR of SCALAR_ - |data(s)| Standard deviation (inpixels) of the gaussian kernel for scale s. If |data|=SCALAR, then the same sigma is used for all scales.
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

function [out_field, out_cert] = regularisation_normgauss(proc, in_field, in_cert, scale, data)


out_field = in_field;

if(size(data,2)>1)
    sigma_mod = data(1,scale+1);
else
    sigma_mod = data(1);
end

for n = 1:ndims(in_field{1})
    out_field{n} = normgauss_smoothing(in_field{n}, in_cert, sigma_mod);
end
out_cert = normgauss_smoothing(in_cert, in_cert, sigma_mod);
