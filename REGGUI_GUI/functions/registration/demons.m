%% demons
% The algorithm used for the non-rigid registration of the mobile image onto the fixed image is the demons. See section "3.1.1 Demons" of reference [1] for more details.
%
%
%% Syntax
% |[out_field, out_cert] = demons(p, iter)|
%
%
%% Description
% |[out_field, out_cert] = demons(p, iter)| makes a non-rigid registration of the mobile image onto the fixed image
%
%
%% Input arguments
% |global reg| - _STRUCTURE_ - The structure containing the data for the registration. The structure is created by "reg_create.m" and the data to run the live registration is initialised by calling "reg_init.m". The data is inputed into the function "reg_animate.m" via a *global variable* |reg|
% * |reg.process| - _VECTOR STRUCTURE_ - Structure describing each registration process. Length equals to |reg.nb_process|. Each element of the structure describes one of the registration process included in the weighted sum leading to the final deformation field. The structure contains the following fields:
% * ----|reg.process(p).input| - _STRUCTURE_ - Structure describing the fixed image for process |p|. See description in 'reg_input.m'. 
% * ---------|reg.process(p).input.dims| - _SCALAR_ - Number of dimensions of the image
% * ---------|reg.process(p).input.rescaled_data| - _SCALAR MATRIX_ - |rescaled_data(x,y,z)| Intensity at voxel (x,y,z) of the fixed image, resampled to the current scale
% * ---------|reg.process(p).input.rescaled_cert| - _MATRICE_ - The certainty map at voxel (x,y,z) (resampled for the current scale) about the value of the intensity at voxel (x,y,z) of the field
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

function [out_field, out_cert] = demons(p, iter)

global reg;

dims = reg.process(p).input.dims;
d = reg.process(p).deformed_prototype.data;
f = reg.process(p).input.rescaled_data;

if(dims == 2)

    [Dfx Dfy] = gradient(f);
    [Ddx Ddy] = gradient(d);

    fmd = f - d;    
    den = ((Dfx+Ddx).^2 + (Dfy+Ddy).^2 + eps(class(f))) + fmd.^2;
    fmd = 2*fmd;
    out_field{1} = fmd.*(Dfx+Ddx)./den;
    out_field{2} = fmd.*(Dfy+Ddy)./den;

    out_cert = ones(size(d),'single');  
    
else

    %[Dfx Dfy Dfz] = gradient(f);
    %[Ddx Ddy Ddz] = gradient(d);
    sz = size(f);
    Dy = 0.5*( (f([2:sz(1),sz(1)],:,:) - f([1,1:sz(1)-1],:,:)) + (d([2:sz(1),sz(1)],:,:) - d([1,1:sz(1)-1],:,:)) );
    Dx = 0.5*( (f(:,[2:sz(2),sz(2)],:) - f(:,[1,1:sz(2)-1],:)) + (d(:,[2:sz(2),sz(2)],:) - d(:,[1,1:sz(2)-1],:)) );
    Dz = 0.5*( (f(:,:,[2:sz(3),sz(3)]) - f(:,:,[1,1:sz(3)-1])) + (d(:,:,[2:sz(3),sz(3)]) - d(:,:,[1,1:sz(3)-1])) );
    % not exactly the same as gradient, specifically at borders
    
%     if(sum(size(reg.process(p).input.rescaled_cert)==sz)==length(sz))
%         Dx = Dx.*reg.process(p).input.rescaled_cert;
%         Dy = Dy.*reg.process(p).input.rescaled_cert;
%         Dz = Dz.*reg.process(p).input.rescaled_cert;
%     end

    if(length(size(reg.process(p).input.rescaled_cert))==length(sz))
        if(sum( size(reg.process(p).input.rescaled_cert)==sz )==length(sz))
            Dx = Dx.*reg.process(p).input.rescaled_cert;
            Dy = Dy.*reg.process(p).input.rescaled_cert;
            Dz = Dz.*reg.process(p).input.rescaled_cert;
        end
    end
    
    %den = ((Dfx+Ddx).^2 + (Dfy+Ddy).^2 + (Dfz+Ddz).^2 + eps(class(f))) +
    fmd = f - d;
    den = (Dx.^2 + Dy.^2 + Dz.^2 + eps(class(f))) + fmd.^2;
    fmd = 2*fmd;
    %out_field{1} = fmd.*(Dfx+Ddx)./den;
    %out_field{1} = fmd.*(Dfy+Ddy)./den;
    %out_field{1} = fmd.*(Dfz+Ddz)./den;
    out_field{1} = fmd.*Dx./den;
    out_field{2} = fmd.*Dy./den;
    out_field{3} = fmd.*Dz./den;

    out_cert = sqrt(Dx.^2 + Dy.^2 + Dz.^2);%ones(size(d),'single');
    
    if(reg.process(p).input.cert_dims > 1)
        out_cert = out_cert.*reg.process(p).input.rescaled_cert;
    end  
    
end

