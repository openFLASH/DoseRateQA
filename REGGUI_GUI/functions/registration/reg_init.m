%% reg_init
% Initiates the non-rigid registration by creating a live structure containing all temporary registration data such as deformation fields and certainties. Initially the scale and deformation is set to zero. The input data |reg| is created using 'reg_create.m'. The actual registration is then carried out by the function "reg_animate.m".
%
%% Syntax
% |reg = reg_init(reg)|
%
%% Description
% |reg = reg_init(reg)| create the initial registration data structure
%
%% Input arguments
% |reg| - _STRUCTURE_ -  Data for the non-rigid registration algorithm:
%
% * |reg.dims|  _INTEGER_ - Number of dimensions of the input image
%
% * |reg.sz| - _VECTOR of SCALAR_ Dimension (x,y,z) (in pixel) of the fixed image
%
% * |reg.nb_process| _INTEGER_ Number of simulateneous registration processes to include in the average deformation field. Each registration process requires a fixed and a moving image.
% 
% * |reg.process(p).prototype|  -  _STRUCTURE_ - Structure describing the mobile image for process |p|. See description in 'reg_prototype.m'
%
%% Output arguments
%
% |reg| - _STRUCTURE_ -  Updated Data for the non-rigid registration algorith. The data contained in the input |reg| is still present in the output |reg|. See 'reg_animate.m' for details.  The following elements are updated 'reg_init':
%
% * |reg.live| - _STRUCTURE_ Data defining the current state of the live registration process.
% 
% * ----- |reg.live.current_scale|  (Default = -1). In the multi-scale registration, defines scale of the current deformable registration process (Default: -1 = there was no previous iteration). The definition of the scale is given in the resampler function "standard_resampler".
% * ----- |reg.live.old_scale|  (Default = 0 = full scale). In the multi-scale registration, defines the scale of the previous deformable registration process. 
% * ----- |reg.live.accumulated_deformation_field| - _CELL VECTOR of MATRICES_ 
% * ----- |reg.live.accumulated_deformation_certainty| _MATRICE_
%
% * |reg.process(p).deformed_prototype| :  - _STRUCTURE_ - 
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


function reg = reg_init(reg)

reg.live = struct;

% Set scale and old (previous) scale to full size (=0)
reg.live.current_scale = -1;
reg.live.old_scale = 0;

% Set initial (accumulated) deformation field to zero
for n = 1:reg.dims
    reg.live.accumulated_deformation_field{n} = zeros(reg.sz,'single');    
end
reg.live.accumulated_deformation_certainty = zeros(reg.sz,'single');

% Set initial deformed prototype to nondeformed prototype
for p=1:reg.nb_process
reg.process(p).deformed_prototype = reg.process(p).prototype;
end

