%% regularisation_affine
% Performs normalised gaussian smoothing of the deformation/displacement field.
% Form ore details, see section "3.3 Normalized Regularization of the Displacement Field" of reference [1].
%
%% Syntax
% |[out_field, out_cert] = regularisation_affine(proc, in_field, in_cert, scale, data)|
%
%% Description
% |[out_field, out_cert] = regularisation_affine(proc, in_field, in_cert, scale, data)| perform regularization of the deformation field and update the certainty map
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
% |out_field|| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the regularized deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
% |out_cert|  - _MATRICE_ - Certainty map of the field. It is equal to |in_cert|
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [out_field, out_cert] = regularisation_affine(proc, in_field, in_cert, scale, data)

    dims = ndims(in_field{1});
    if(dims == 3)
  
        current_size = size(in_field{1});
        [X,Y,Z] = meshgrid(1:current_size(2), 1:current_size(1), 1:current_size(3));
        
        % create base for affine transformations on current scale
        affine_base = zeros(current_size(2)*current_size(1)* ...
            current_size(3)*3, 12);
        affine_base(1:3:end,1) = 1;
        affine_base(2:3:end,2) = 1;
        affine_base(3:3:end,3) = 1;
        affine_base(1:3:end,4) = X(:);
        affine_base(1:3:end,5) = Y(:);
        affine_base(1:3:end,6) = Z(:);
        affine_base(2:3:end,7) = X(:);
        affine_base(2:3:end,8) = Y(:);
        affine_base(2:3:end,9) = Z(:);
        affine_base(3:3:end,10) = X(:);
        affine_base(3:3:end,11) = Y(:);
        affine_base(3:3:end,12) = Z(:);
        param = zeros(size(affine_base,2),1);

        acc_displacement_affine = ...
            zeros(current_size(2)*current_size(1)*current_size(3)*3,1);
        acc_displacement_affine(1:3:end) = in_field{1}(:);
        acc_displacement_affine(2:3:end) = in_field{2}(:);
        acc_displacement_affine(3:3:end) = in_field{3}(:);
        param = inv(affine_base'*affine_base)*affine_base'*...
            acc_displacement_affine;
        out_field{1} = ones(current_size)*param(1) + X*param(4) + Y*param(5) + Z*param(6);
        out_field{2} = ones(current_size)*param(2) + X*param(7) + Y*param(8) + Z*param(9);
        out_field{3} = ones(current_size)*param(3) + X*param(10) + Y*param(11) + Z*param(12);

    elseif(dims == 2)
        
        current_size = size(in_field{1});
        [X,Y] = meshgrid(1:current_size(2), 1:current_size(1));        
        
        % create base for affine transformations on current scale
        affine_base = zeros(current_size(2)*current_size(1)*2, 6);
        affine_base(1:2:end,1) = 1;
        affine_base(2:2:end,2) = 1;
        affine_base(1:2:end,3) = X(:);
        affine_base(1:2:end,4) = Y(:);
        affine_base(2:2:end,5) = X(:);
        affine_base(2:2:end,6) = Y(:);
        param = zeros(size(affine_base,2),1);

        acc_displacement_affine = zeros(current_size(2)*current_size(1)*2,1);
        acc_displacement_affine(1:2:end) = in_field{1}(:);
        acc_displacement_affine(2:2:end) = in_field{2}(:);
        param = inv(affine_base'*affine_base)*affine_base'*...
            acc_displacement_affine;
        out_field{1} = ones(current_size)*param(1) + X*param(3) + Y*param(4);
        out_field{2} = ones(current_size)*param(2) + X*param(5) + Y*param(6);
              
    end
    
%    keyboard;  
    out_cert = in_cert;

