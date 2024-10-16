%% accumulator_diffeomorphic_with_certainty_and_mask
% Performing Accumulation with damping (damping the accumulated field using the certainty map) of the deformation fields.
% The accumulation is described in section "4.4 Sliding surfaces" of reference [1]
%
%% Syntax
% |[out_field, out_cert] = accumulator_diffeomorphic_with_certainty_and_mask(acc_field, acc_cert, est_field, est_cert, mask)|
%
%
%% Description
% |[out_field, out_cert] = accumulator_diffeomorphic_with_certainty_and_mask(acc_field, acc_cert, est_field, est_cert, mask)| returns the accumulated defomration field and the accumulated certainty about the value of the voxel intensity
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
% |acc_data|  - _MATRICE_ - Certainty map about the value of the intensity at voxel (x,y,z) of the accumulated fields |acc_cert| and |est_field|.
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

function [out_field, out_cert] = accumulator_diffeomorphic_with_certainty_and_mask(acc_field, acc_cert, est_field, est_cert, mask)

disp('Performing diffeomorphic accumulation (using certainty and dicontinuities)...')

est_field_sqr = est_field{1}.^2;
for n=2:length(acc_field)
    est_field_sqr = est_field_sqr+est_field{n}.^2;
end

N = ceil(2 + log2(max(max(max(sqrt(est_field_sqr)))))/2) +1;

update_field = est_field;
for n = 1:length(acc_field)
    update_field{n} = est_field{n}*2^(-N);
end
est_cert_1 = est_cert*2^(-N);
est_cert_1(find(mask))=NaN;
est_cert_2 = est_cert*2^(-N);
est_cert_2(find(not(mask)))=NaN;

new_field = update_field;

for r=1:N
    est_cert_1 = est_cert_1+linear_deformation(est_cert_1, '', update_field, est_cert_1);
    est_cert_2 = est_cert_2+linear_deformation(est_cert_2, '', update_field, est_cert_2);
    for n = 1:length(acc_field)
        new_field{n} = linear_deformation(update_field{n}, '', update_field, est_cert);
        new_field{n} = new_field{n}+update_field{n};
    end
    update_field = new_field;
end

for n = 1:length(acc_field)
    est_field{n}(find(not(isnan(est_cert_1)))) = update_field{n}(find(not(isnan(est_cert_1))));
    est_field{n}(find(not(isnan(est_cert_2)))) = update_field{n}(find(not(isnan(est_cert_2))));
end
est_cert(find(not(isnan(est_cert_1)))) = est_cert_1(find(not(isnan(est_cert_1))));
est_cert(find(not(isnan(est_cert_2)))) = est_cert_2(find(not(isnan(est_cert_2))));

% Update the accumulated certainty
est_cert_1 = acc_cert;
est_cert_1(find(mask))=NaN;
est_cert_2 = acc_cert;
est_cert_2(find(not(mask)))=NaN;
est_cert_1 = abs(est_cert)+abs(linear_deformation(est_cert_1, '', est_field, est_cert_1));
est_cert_2 = abs(est_cert)+abs(linear_deformation(est_cert_2, '', est_field, est_cert_2));
out_cert = abs(est_cert)+abs(acc_cert);
out_cert(find(not(isnan(est_cert_1)))) = est_cert_1(find(not(isnan(est_cert_1))));
out_cert(find(not(isnan(est_cert_2)))) = est_cert_2(find(not(isnan(est_cert_2))));

out_field = acc_field;

% Compute new displacement field
for n = 1:length(acc_field)
    out_field{n} = linear_deformation(acc_field{n}, '', est_field, est_cert);
    mask = find(isnan(est_cert_1)|isnan(est_cert_2));
    out_field{n}(mask) = acc_field{n}(mask);
    out_field{n} = out_field{n}+est_field{n};
end

