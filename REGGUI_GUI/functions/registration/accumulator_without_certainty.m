%% accumulator_without_certainty
% Performing Accumulation with damping (damping the accumulated field using the certainty map) of the deformation fields.
% The accumulation is described in section "3.3.1 Additive accumulation" of reference [1]
%
%% Syntax
% |[out_field, out_cert] = accumulator_without_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)|
%
%
%% Description
% |[out_field, out_cert] = accumulator_without_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)| returns the accumulated defomration field and the accumulated certainty about the value of the voxel intensity
%
%
%% Input arguments
% |acc_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the previous deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
% |acc_cert|  - _MATRICE_ - Previously accumulated map of the certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |est_field| - _CELL VECTOR of MATRICES_ |est_field{1}(x,y,z)| is X component of the addiitonal deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}.
%
% |est_cert|  - _MATRICE_ - Certainty map about the value of the intensity at voxel (x,y,z) of the additional field |est_field|. 
%
% |acc_data|  - Not used.
%
% |mask|  - _MATRICE_ - 3D matrix (x.y.z) defining the discontinuity mask for the registration.
%
%% Output arguments
%
% |out_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the accumulated deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
% |out_cert|  - _MATRICE_ - Certainty map of the two accumulated field. 
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [out_field, out_cert] = accumulator_without_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)

disp('Performing additive accumulation (without certainty)...')

for n = 1:length(acc_field)
    out_field{n} = est_field{n} + acc_field{n};    
end

out_cert = acc_cert + est_cert;
