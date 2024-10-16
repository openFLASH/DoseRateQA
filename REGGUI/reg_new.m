%% reg_new
% Creates a new and empty registration data structure with some default settings. This data structure will be used for non-rigid registration (see function reg_animate.m).
%
%% Syntax
% |reg = reg_new()|
%
%% Description
% |reg = reg_new()| Creates a new and empty registration data structure with some default settings.
%
%% Input arguments
% None
%
%% Output arguments
%
% |reg| - _STRUCTURE_ - Data structure for the non-rigid registration. See 'reg_animate.m' for details. The following elements are updated by reg_new':
%
% * |reg.deformation| - _STRUCTURE_ - Default = 'linear'. See 'reg_deformation.m' for details
%
% * |reg.accumulation| - _STRUCTURE_ - Default = 'default'. See 'regg_accumulation.m' for details
%
% * |reg.resampling| - _STRUCTURE_ - Default = 3. See 'regg_resampling.m' for details
%
% * |reg.regularisation| - _STRUCTURE_ - Default = 'default'. See 'reg_regularization.m' for details.
%
% * |reg.process| - _STRUCTURE_ - Structure describing the registration process.
%
% * |reg.dims|  _INTEGER_ - Number of dimensions of the input image (Default = 3)
%
% * |reg.sz| - _VECTOR of SCALAR_ Dimension (x,y,z) (in pixels) of the fixed image (Default = [1 1 1])
%
% * |reg.nb_process| _INTEGER_ Number of simulateneous registration processes to include in the average deformation field. (Default = 1)
%
% * |reg.iters| _VECTOR of INTEGER_ Number of iteration in the registration per resolution level. (Default = 1)
%
% * |reg.spacing| - _VECTOR of SCALAR_ - Size (x=1,y=1,z=1) (in |mm|) of the pixels in the images.
%
% * |reg.visual| - _INTEGER_ - Set to |reg.visual = 0|, No visualisation function will be called after each iteration of the non-rigid registration process.
%
% * |reg.report| - _SCALAR_ - |reg.report=0|: no report will be created in a file.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function reg = reg_new()

reg = struct;

% Set default deformation type (bi/trilinear interpolation)
reg.deformation = reg_deformation('linear', []);

% Set default accumulated field update rule (Knutsson/Andersson)
reg.accumulation = reg_accumulation('default');

% Set default resampling scheme
reg.resampling = reg_resampling('default', 3, 3, 3);

% Set default resampling scheme (4 iterations on halfscale 3, bi/trilinear
% upsampling, standard filters for downsampling
reg.regularisation = reg_regularisation('default',[]);

% Set default resampling scheme (4 iterations on halfscale 3, bi/trilinear
% upsampling, standard filters for downsampling
reg.process = struct;

%Set other default parameters
reg.dims = 3;
reg.sz = [1 1 1];
reg.nb_process = 1;
reg.iters = 1;
reg.spacing = [1 1 1];
reg.visual = 0;
reg.report = 0;
