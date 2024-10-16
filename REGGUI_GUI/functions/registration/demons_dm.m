%% demons_dm
% The algorithm used for the non-rigid registration of the mobile image onto the fixed image is the demons. The method is adapted to 2 binary masks (RT contours). The algorithm computes a distance map ('DM' stands for "distance map") and then apply the demons on the distance map. See sections "3.1.1 Demons" and "4.3 Surface matching" of reference [1] for more details.
%
%
%% Syntax
% |[out_field, out_cert] = demons_dm(p, iter)|
%
%
%% Description
% |[out_field, out_cert] = demons_dm(p, iter)| makes a non-rigid registration of the mobile image onto the fixed image
%
%
%% Input arguments
% |global reg| - _STRUCTURE_ - The structure containing the data for the registration. The structure is created by "reg_create.m" and the data to run the live registration is initialised by calling "reg_init.m". The data is inputed into the function "reg_animate.m" via a *global variable* |reg|
% * |reg.process| - _VECTOR STRUCTURE_ - Structure describing each registration process. Length equals to |reg.nb_process|. Each element of the structure describes one of the registration process included in the weighted sum leading to the final deformation field. The structure contains the following fields:
% * ----|reg.process(p).input| - _STRUCTURE_ - Structure describing the fixed image for process |p|. See description in 'reg_input.m'. 
% * ---------|reg.process(p).input.dims| - _SCALAR_ - Number of dimensions of the image
% * ---------|reg.process(p).input.rescaled_data| - _SCALAR MATRIX_ - |rescaled_data(x,y,z)| Intensity at voxel (x,y,z) of the fixed image, resampled to the current scale
% * ---------|reg.process(p).input.rescaled_cert| - _MATRICE_ - The certainty map at voxel (x,y,z) (resampled for the current scale) about the value of the intensity at voxel (x,y,z) of the field
% * ---------|reg.process(p).input.rescaled_mask| - _MATRIX_ - |rescaled_mask(x,y,z)| defines whether the voxel (x,y,z) belongs (1) or not (0) to the region. 
% * ---------|reg.process(p).input.mask_dims|
% * ----|reg.process(p).deformed_prototype| - _STRUCTURE_ - Structure describing the deformed mobile image for process |p|. See description in 'reg_prototype.m'.
%
% |p| - _INTEGER_ -  Number of the process for which the registration is computed.
%
% |iter| - Not used
%
%
%% Output arguments
%
% |out_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
% |out_cert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the field |out_field|.
%
%% NOTE
%
% * The function receives all its input parameters via a global variable |reg|. The structure is created by "reg_create.m" and the data to run the live registration is initialised by calling "reg_init.m".
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO Do not use the GLOBAL varial reg. Give this variable as input parameter

function [out_field, out_cert] = demons_dm(p, iter)

global reg;

dims = reg.process(p).input.dims;
%d = reg.process(p).deformed_prototype.data;
d = single(compute_distmap(reg.process(p).deformed_prototype.data)); %inputs must be masks !
f = single(compute_distmap(reg.process(p).input.rescaled_data)); %inputs must be masks !

if(0)% non-linear distance using atan
    dist_to_border = mean([size(d,1),size(d,2),size(d,3)])/4;
    f = atan(f/dist_to_border)*atan(dist_to_border);
    d = atan(d/dist_to_border)*atan(dist_to_border);
end

if dims==2

    out_cert = (f/max(max(f))).^4;    
    if(reg.process(p).input.mask_dims > 1)
        out_cert = out_cert.*reg.process(p).input.rescaled_mask;
    end      
    
    [Dfx Dfy] = gradient(f);
    [Ddx Ddy] = gradient(d);

    fmd = f - d;    
    den = ((Dfx+Ddx).^2 + (Dfy+Ddy).^2 + eps(class(f))) + fmd.^2;
    fmd = 2*fmd;
    out_field{1} = out_cert.*fmd.*(Dfx+Ddx)./den;
    out_field{2} = out_cert.*fmd.*(Dfy+Ddy)./den;
    % No iter factor here as in 3D?

else

%     out_cert = (f/max(max(max(f)))).^4; 
%     out_cert = single(f>=(max(max(max(f)))/2));
    out_cert = (max(max(max(abs(f))))/abs(f));
    out_cert = out_cert/max(max(max(out_cert)));
    out_cert(f>=0) = 1;
    
    %[Dfx Dfy Dfz] = gradient(f);
    %[Ddx Ddy Ddz] = gradient(d);
    sz = size(f);
    Dy = 0.5*( (f([2:sz(1),sz(1)],:,:) - f([1,1:sz(1)-1],:,:)) + (d([2:sz(1),sz(1)],:,:) - d([1,1:sz(1)-1],:,:)) );
    Dx = 0.5*( (f(:,[2:sz(2),sz(2)],:) - f(:,[1,1:sz(2)-1],:)) + (d(:,[2:sz(2),sz(2)],:) - d(:,[1,1:sz(2)-1],:)) );
    Dz = 0.5*( (f(:,:,[2:sz(3),sz(3)]) - f(:,:,[1,1:sz(3)-1])) + (d(:,:,[2:sz(3),sz(3)]) - d(:,:,[1,1:sz(3)-1])) );
    % not exactly the same as gradient, specifically at borders
    
%     if(length(size(reg.process(p).input.rescaled_cert))==length(sz))
%         if(sum( size(reg.process(p).input.rescaled_cert)==sz )==length(sz))
%             Dx = Dx.*reg.process(p).input.rescaled_cert;
%             Dy = Dy.*reg.process(p).input.rescaled_cert;
%             Dz = Dz.*reg.process(p).input.rescaled_cert;
%         end
%     end

    %den = ((Dfx+Ddx).^2 + (Dfy+Ddy).^2 + (Dfz+Ddz).^2 + eps(class(f))) +
    fmd = f - d;
%     den = (Dx.^2 + Dy.^2 + Dz.^2 + eps(class(f))) + fmd.^2;
    fmd = 2*fmd;
    %out_field{1} = iter*out_cert.*fmd.*(Dfx+Ddx)./den;
    %out_field{1} = iter*out_cert.*fmd.*(Dfy+Ddy)./den;
    %out_field{1} = iter*out_cert.*fmd.*(Dfz+Ddz)./den;
%     out_field{1} = iter*out_cert.*fmd.*Dx./den;
%     out_field{2} = iter*out_cert.*fmd.*Dy./den;
%     out_field{3} = iter*out_cert.*fmd.*Dz./den;

    out_field{1} = out_cert.*fmd/2.*Dx;
    out_field{2} = out_cert.*fmd/2.*Dy;
    out_field{3} = out_cert.*fmd/2.*Dz;
    
    if(reg.process(p).input.cert_dims > 1)
        out_cert = out_cert.*reg.process(p).input.rescaled_cert;
    end  
    
    if(reg.process(p).input.mask_dims > 1)
        out_cert = out_cert.*reg.process(p).input.rescaled_mask;
    end  

end

