%% gradient_displacement
% % Estimates displacement between the deformed prototype and the input image/volume using the image gradient difference
%
%
%% Syntax
% |[out_field, out_cert, live_out] = gradient_displacement(proc, scale, iter)|
%
%
%% Description
% |[out_field, out_cert, live_out] = gradient_displacement(proc, scale, iter)| makes a non-rigid registration of the mobile image onto the fixed image
%
%
%% Input arguments
%
% |proc| - _STRUCTURE_ Data defining the current state of the live registration process.
%
% * ----|proc.live.input_data| - _SCALAR MATRIX_ - |input_data(x,y,z)| Intensity at voxel (x,y,z) of the fixed image.
% * ----|proc.live.deformed_prototype.data| - _SCALAR MATRIX_ - |prototype.data(x,y,z)| Intensity at voxel (x,y,z) of the moving image.
%
% |scale| - _INTEGER_ -  Scale of the current deformable registration process. With |scale <= length(reg.elastic.data(1,:))|. The definition of the scale is given in the resampler function "standard_resampler". 
%
% |iter| - _INTEGER_ - the current iteration step. This parameter is used only for displaying text. It is not used in computation.
%
%
%% Output arguments
%
% |out_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
% |out_cert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the field |out_field|.
%
% |live_out| - _STRUCTURE_ - |live_out = proc.live| Return part of the inputed data regarding the current live registration process
%
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO |scale| parameter is only used for displaying text. It is not used for any computation purpose. could it be removed ?

function [out_field, out_cert, live_out] = gradient_displacement(proc, scale, iter)

live_out = proc.live;

disp(['Estimating displacement on scale ', num2str(scale), ', iter ', num2str(iter)]);

dims = proc.input.dims;
if(dims == 2)
    eta = 3;
    
    cor = abs(proc.live.deformed_prototype.data - proc.live.input_data);
    proc.live.deformed_prototype.data = circshift(proc.live.deformed_prototype.data, [1 0 0]);
    corpx = abs(proc.live.deformed_prototype.data - proc.live.input_data);
    proc.live.deformed_prototype.data = circshift(proc.live.deformed_prototype.data, [-2 0 0]);
    cormx = abs(proc.live.deformed_prototype.data - proc.live.input_data);
    proc.live.deformed_prototype.data = circshift(proc.live.deformed_prototype.data, [1 1 0]);
    corpy = abs(proc.live.deformed_prototype.data - proc.live.input_data);
    proc.live.deformed_prototype.data = circshift(proc.live.deformed_prototype.data, [0 -2 0]);
    cormy = abs(proc.live.deformed_prototype.data - proc.live.input_data);
    
    cx = zeros(size(cor));
    cx(corpx < cor) = 1;
    cx(cormx < corpx) = -1;
    cy = zeros(size(cor));
    cy(corpy < cor) = 1;
    cy(cormy < corpy) = -1;

    out_field{1} = eta*cx;
    out_field{2} = eta*cy;
    out_cert = 1./(cor + eps);
        
    if(length(proc.prototype.mask_sz > 1))
        out_cert = out_cert.*proc.live.deformed_prototype.mask;
    end

elseif(dims == 3)
    
else
    error ('--- quadphase_lsq: Currently, only 2D and 3D data is sopproted')
end
