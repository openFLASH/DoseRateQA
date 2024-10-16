%% accumulator_compositive_with_certainty
% Performing Accumulation with damping (damping the accumulated field using the certainty map) of the deformation fields.
% The composite accumulation is described in section "3.3.3 Accumulation with damping" of reference [1]
%
%% Syntax
% |[out_field, out_cert] = accumulator_compositive_with_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)|
%
%
%% Description
% |[out_field, out_cert] = accumulator_compositive_with_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)| returns the accumulated defomration field and the accumulated certainty about the value of the voxel intensity
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

function [out_field, out_cert] = accumulator_compositive_with_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)

disp('Performing compositive accumulation (using certainty)...')

% Sum of certainties
cert_sum = acc_cert + est_cert;

for n = 1:length(est_field)
est_field{n} = est_field{n}.*est_cert./cert_sum;
end

% Compute new displacement field
for n = 1:length(acc_field)
%     [out_field{n} est_cert] = linear_deformation(out_field{n}, '', est_field.* est_cert./(cert_sum+eps), est_cert);
    out_field{n} = linear_deformation(acc_field{n}, '', est_field, []);
    out_field{n} = est_field{n}+out_field{n};
end

% Update the accumulated certainty
out_cert = (acc_cert.^2 + est_cert.^2)./(cert_sum+eps);
% out_cert = est_cert+linear_deformation(acc_cert, '', est_field, est_cert);
