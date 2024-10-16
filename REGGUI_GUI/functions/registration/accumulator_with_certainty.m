%% accumulator_diffeomorphic_with_certainty_and_mask
% Performing Accumulation with damping (damping the accumulated field using the certainty map) of the deformation fields.
% The accumulation is described in reference [1].
% The accumulation is done by adding a fraction of the current measurement to the accumulated field that is determined from the quotient
% between the temporary certainty and the sum of current and accumulated certainty. 
%
%% Syntax
% |[out_field, out_cert] = accumulator_with_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)|
%
%
%% Description
% |[out_field, out_cert] = accumulator_with_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)| returns the accumulated defomration field and the accumulated certainty about the value of the voxel intensity
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
% [1] H. Knutsson and M. Andersson, “Morphons: Paint on priors and elastic canvas for segmentation and registration” presented at the 14th Scandinavian Conference, SCIA 2005, Joensuu, Finland, June 19–22, 2005. Lecture Notes in Computer Science Volume 3540 of the series Lecture Notes in Computer Science pp 292-301, Springer, Berlin/Heidelberg, 2005. [http://link.springer.com/chapter/10.1007%2F11499145_31]
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [out_field, out_cert] = accumulator_with_certainty(acc_field, acc_cert, est_field, est_cert, acc_data)

disp('Performing additive accumulation (using certainty)...')

% Sum of certainties
cert_sum = acc_cert + est_cert;
%csz = find(cert_sum == 0);

% Compute new displacement field

for n = 1:length(acc_field)
    out_field{n} = est_field{n} .* est_cert./(cert_sum+eps) + acc_field{n};
end
out_cert = (acc_cert.^2 + est_cert.^2)./(cert_sum+eps);

