%% reg_create
% Creates a new registration data structure with the settings given as input. The data required for a live registration will be initialised by acalling "reg_init.m". The |reg| data structure will be used for non-rigid registration (see function reg_animate.m).
%
%% Syntax
% |reg = reg_create(m)|
%
%% Description
% |reg = reg_create(m)| describes the function
%
%% Input arguments
% |m| - _STRUCTURE_ -  Parameters defining the whole registration process
%
% * |m.nb_process| - _INTEGER_ - Number of registration processes used to compute the average deformation field. Each registration process requires a fixed and a moving image.
%
% * |m.fixedname{p}| - _CELL VECTOR of STRING_ - Names of the *fixed* image contained in |m.input_data| for the registration processes |p|. The number of elements in the cell vector must be equal to |m.nb_process|
%
% * |m.movingname{p}| - _CELL VECTOR of STRING_ -  Names of the *moving* image contained in |m.prototype_data| for the registration processes |p|. The number of elements in the cell vector must be equal to |m.nb_process|
%
% * |m.input_data{p}| - _CELL of MATRIX of SCALAR_ - 3D Matrix (x.y.z) defining the fixed image for the registration process |p|. The number of elements in the cell vector must be equal to |reg.nb_process|.
% 
% * |m.input_cert{p}| - _CELL of MATRIX of SCALAR_ - 3D Matrix (x.y.z) defining the region of interest wether to apply the non-rigid deformation process |p|. The number of elements in the cell vector must be equal to |reg.nb_process|.
%
% * |m.input_mask{p}| - _CELL of MATRIX of SCALAR_ - 3D matrix (x.y.z) defining the discontinuity mask for the registration processes |p|. The number of elements is equal to |m.nb_process|
%
% * |m.prototype_data{p}| - _CELL of MATRIX of SCALAR_ - 3D Matrix (x.y.z) defining the moving image for the registration processes |p|. The number of elements is equal to |m.nb_process|.
%
% * |m.displacement_method{p}| - _CELL VECTOR of STRING_ -  Define the non rigid registration algorithm for each process. See description in reg_displacement_estimation. The number of elements in the cell vector must be equal to |m.nb_process|
%
% * |m.pre_regularisation{p}| - _CELL VECTOR of INTEGER_ - Regularisation algorithm for each registration process (See 'Registration_modules' for list). The number of elements is equal to |m.nb_process|
%
% * |m.pre_regularisation_data{p}| - _CELL VECTOR of INTEGER_ - Regularisation algorithm for each registration process (See 'Registration_modules' for list). The number of elements is equal to |m.nb_process|
%
% * |m.weight_field{p}| - _CELL VECTOR of SCALAR_ - Weight of the deformation field computed by this registration process to use when accumulating the field in the final deformation field.
%
% * |m.weight_cert{p}|  - _SCALAR_ - Weight of the certainty map computed by this registration process in the final computation of the ceratinty map.
%
%
% * |m.deformation_method| - _STRING_ -Name of the function that deforms the prototype (=mobile) image using the accumulated deformation field. It is NOT used to compute the non-deformable image registration. It is used to apply the computed deformation field on the image. See 'reg_deformation.m' for details
%
% * |m.deformation_boundary| - _TYPE_ - Boundary data given to the |m.deformation_method|. See help of the specific function for description of the meaning of the data
%
% * |m.accumulation_method| - _INTEGER_ Algorithm for accumulation of the deformation field (See 'Registration_modules' for list).
%
% * |m.resampling_method| - _STRING_ - Algorithm to use to resample the image at each scaling stage. See 'reg_resampling.m' for list
%
% * |m.fluid_regularisation| - _INTEGER_ - Fluid Regularisation algorithm (See 'Registration_modules' for list). There exist several mechanical models that describe the behavior of a body undergoing deformation, depending on the nature of the material. These materials can be solid or fluid, and their behavior can be approximated using some of the models used for modeling soft tissues. See reference [1], section 2.3.3 Biomechanical behaviour.
%
% * |m.fluid_regularisation_data| - _VECTOR of SCALAR_ - Variance parameters of the fluid regularization. The number of elements in the vector must be equal to the number of multi-scale levels.
%
% * |m.solid_regularisation| - _INTEGER_ - Solid Regularisation algorithm (See 'Registration_modules' for list). There exist several mechanical models that describe the behavior of a body undergoing deformation, depending on the nature of the material. These materials can be solid or fluid, and their behavior can be approximated using some of the models used for modeling soft tissues. See reference [1], section 2.3.3 Biomechanical behaviour.
%
% * |m.solid_regularisation_data| -_VECTOR of SCALAR_ - Variance parameters of the solid regularization. The number of elements in the vector must be equal to the number of multi-scale levels.
%
% * |m.regularisation_model| - _STRUCTURE_ - [OPTIONAL] If provided, over-ride |m.solid_regularisation| and is used instead to define the solid regularization function.
%
% * |m.elastic_regularisation_data| [OPTIONAL: required if elastic regularrization is required]
%
% * |m.segname| - _STRING_ - Name of the image containing the Poisson ratio. This is used for elastic filtering.
%
% * |m.seg| - _MATRIX of SCALAR_ - |m.seg(x,y,z)| is the Poisson ratio (nu) of the voxel (x,y,z). Poisson’s ratio. Poisson’s ratio |nu| takes a value in the interval ]− 1; 0.5[ (0.5 corresponds to incompressible materials, 0 to completely compressible materials and negative values correspond to auxetic materials).  This is used for elastic filtering.
%
% * |m.logdomain| - _INTEGRER_ -   |logdomain=1|: Use the logarithmic diffeomorphic when computing the weighted sum of the transforms. |logdomain=0| Directly add the transform.
%
% * |m.iterations| _VECTOR of INTEGER_ Number of iteration per resolution level. Number of elements of the vector defines the number of resolution levels |nlevel| to use in the computation with |nlevel| <= 2*ln2(S)+1, where S is the smallest size of fixed image and ln2 is the logarithm in base 2. 
%
% * |m.min_scale|  - _INTEGER_ -  Minimum scale of the resampling process. 
%
% * |m.max_scale| - _INTEGER_ -  Maximum scale of the resampling process
%
% * |m.out_scale| - _INTEGER_ -  Define the scale of the data to be outputed for interactive use. The definition of the scale is given in the resampler function "standard_resampler".
%
% * |m.spacing| - _VECTOR of SCALAR_ - Size (x,y,z) (in |mm|) of the pixels in the images.
%
% * |m.outputimage| - _STRING_ Name of the output deformed image
%
% * |m.outputfield| - _STRING_ Name of the output deformation field
%
% * |m.visual| - _INTEGER_ - If |reg.visual = 1|, a visualisation function will be called after each iteration of the non-rigid registration process.
%
% * |m.report| - _SCALAR or STRING_ - |reg.report=0|: no report will be created in a file. |reg = _STRING_| File name of the report
%
%% Output arguments
%
% |reg| - _STRUCTURE_ - Data structure describing the non-rigid registration. See 'reg_animate.m' for details.  The following elements are updated 'reg_create':
%
% * |reg.iters| _VECTOR of INTEGER_
%
% * |reg.nb_process| _INTEGER_ 
%
% * |reg.process| - _VECTOR STRUCTURE_ 
% * ----|reg.process(p).input| - _STRUCTURE_ 
% * ----|reg.process(p).prototype| - _STRUCTURE_ 
% * ----|reg.process(p).displacement_estimation| - _STRUCTURE_ 
% * ----|reg.process(p).pre_regularisation| - _STRUCTURE_ 
% * ----|reg.process(p).weight_field| - _SCALAR_ 
% * ----|reg.process(p).weight_cert| - _SCALAR_ 
% * ----|reg.process(p).q_in| - EMPTY
%
% * |reg.elastic| - _STRUCTURE_ - [OPTIONAL: required if elastic regularrization is required] Data structure to use for the optional additional elastic regularization. See 'regularisation_elastic.m' for details
%
% * |reg.deformation| - _STRUCTURE_  
%
% * |reg.accumulation| - _STRUCTURE_ 
%
% * |reg.resampling| - _STRUCTURE_ 
%
% * |reg.fluid_regularisation| - _STRUCTURE_ 
%
% * |reg.solid_regularisation| - _STRUCTURE_ 
%
% * |reg.logdomain| - _INTEGRER_  
%
% * |reg.dims| _INTEGER_ 
%
% * |reg.sz|  _VECTOR of SCALAR_ 
%
% * |reg.spacing| - _VECTOR of SCALAR_ - Default (x=1,y=1,z=1) (in |mm|).
%
% * |reg.fixedname| - _STRING_ - This is the name of the fixed image for the first process.
%
% * |reg.movingname| - _STRING_ - This is the name of the moving image for the first process.
%
% * |reg.outputimagename| - _STRING_ 
%
% * |reg.outputfieldname| - _STRING_ 
%
% * |reg.visual| - _INTEGER_ - 
%
% * |reg.report| - _SCALAR or STRING_ - 
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function reg = reg_create(m)

% An empty reg is created by calling the new reg function
reg = reg_new;

% Set global parameters

% Set deformation method
reg.deformation = reg_deformation(m.deformation_method, m.deformation_boundary);

% Set the accumulation method
if(isfield(m,'logdomain'))
    reg.accumulation = reg_accumulation(m.accumulation_method,m.logdomain);
else
    reg.accumulation = reg_accumulation(m.accumulation_method);
end

% Set resampling method
reg.resampling = reg_resampling(m.resampling_method,...
    m.min_scale, m.max_scale, m.out_scale);

%This is for retro-compatibility...
if(not(isfield(m,'solid_regularisation')))
    m.solid_regularisation = m.regularisation_model;
end

reg.fluid_regularisation = reg_regularisation(m.fluid_regularisation,m.fluid_regularisation_data);    
reg.solid_regularisation = reg_regularisation(m.solid_regularisation,m.solid_regularisation_data);

% Set other parameters
reg.dims = ndims(m.input_data{1});
reg.sz = size(m.input_data{1});
reg.nb_process = m.nb_process;
reg.iters = m.iterations;
reg.spacing = m.spacing;
reg.visual = m.visual;
if(isfield(m,'logdomain'))
    reg.logdomain = m.logdomain;
else
    reg.logdomain = 0; 
end
reg.report = m.report;
reg.fixedname = m.fixedname{1};
reg.movingname = m.movingname{1};
if(isfield(m,'segname'))
    reg.segname = m.segname;
end
reg.outputimagename = m.outputimage;
reg.outputfieldname = m.outputfield;


%% For each registration process, set parameters and initial data

for p=1:reg.nb_process
    
% Load input data
if(p==1)
    reg.process(p).input = reg_input(m.input_data{p}, m.input_cert{p}, m.input_mask{p});
else
    reg.process(p).input = reg_input(m.input_data{p}, m.input_cert{p}, []); 
end
    
% Load prototype data
reg.process(p).prototype = reg_prototype(m.prototype_data{p});

% Set displacement estimation method
reg.process(p).displacement_estimation = reg_displacement_estimation(m.displacement_method{p});

reg.process(p).pre_regularisation = reg_regularisation(m.pre_regularisation{p},m.pre_regularisation_data{p});

reg.process(p).weight_field = m.weight_field{p};
reg.process(p).weight_cert = m.weight_cert{p};

reg.process(p).q_in = [];

end


% If elastic regul

if(isfield(m,'elastic_regularisation_data') && isfield(m,'seg'))
    reg.elastic = struct;
    reg.elastic.data = m.elastic_regularisation_data;
    if(ndims(m.seg)==reg.dims) % If inhomogenoues spatial properties are desired
        reg.elastic.seg = m.seg;
        reg.elastic.seg_min = min(reg.elastic.seg(:));
        reg.elastic.seg_max = max(reg.elastic.seg(:));
        reg.elastic.seg_dims = length(size(reg.elastic.seg));
    else
        reg.elastic.seg = m.seg(1,1,1);
        reg.elastic.seg_min = m.seg(1,1,1);
        reg.elastic.seg_max = m.seg(1,1,1);
        reg.elastic.seg_dims = 1;
    end
    if(max(max(max(reg.elastic.seg))) > 0.475)
        disp('Rescaling poisson ratio (elastic behavior) to avoid numerical instabilities... ');
        reg.elastic.seg = 0.475*reg.elastic.seg/(max(max(max(reg.elastic.seg))));
    end
    reg.elastic.rescaled_seg = [];
end


% Initialisation done
