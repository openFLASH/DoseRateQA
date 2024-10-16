%% compute_field_in_mask
% Compute the TANGENT component of the deformation field |field| to the sliding surface defined by the mast |myMask|. The displacement |field| D is separated over the whole volume in its normal Dn and tangent Dt components. The function returns the tangent component Dt.
% For more information, see section "4.4 Sliding surfaces" of reference [1]
%
%% Syntax
% |field = compute_field_in_mask(field,myMask)|
%
%
%% Description
% |field = compute_field_in_mask(field,myMask)| Description
%
%
%% Input arguments
% |field| _MATRIX of SCALAR_ |field(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |field(2,x,y,z)| and |field(3,x,y,z)|.
%
% |myMask| - _SCALAR MATRIX_ - Mask defining the volume where a discountinuty in sliding occurs. |myMask(x,y,z)| Mask value at the voxel at coordinate (x,y,z). 1 = voxel belongs to the mask. 0 = voxel does not belong tothe mask
%
%
%% Output arguments
%
% |field| _MATRIX of SCALAR_  Component of the deformation field that is tangent to the sliding surface. |field(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |field(2,x,y,z)| and |field(3,x,y,z)|.
%
%% References
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function field = compute_field_in_mask(field,myMask)

myMask = compute_distmap(myMask);
[gx gy gz] = gradient(myMask);
g(2,:,:,:) = gx./(sqrt(gx.^2+gy.^2+gz.^2)+eps);
g(1,:,:,:) = gy./(sqrt(gx.^2+gy.^2+gz.^2)+eps);
g(3,:,:,:) = gz./(sqrt(gx.^2+gy.^2+gz.^2)+eps);
clear gx gy gz;
fn = field;
scalar_prod = 0;
for n = 1:3
    scalar_prod = scalar_prod + squeeze(field(n,:,:,:)).*squeeze(g(n,:,:,:));
end
for n = 1:3
    fn(n,:,:,:) = squeeze(g(n,:,:,:)).*scalar_prod;
end
field = field - fn;
