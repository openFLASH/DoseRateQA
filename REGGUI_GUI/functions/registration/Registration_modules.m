%% Registration_modules
% Perform a multi-scale non-rigid registration of a moving image onto a fixed image.
% The deformable registration takes place in *several processes* occuring simulatneously. Each process describes a registration of one pair of images (fixed & moving) for a specified number of iterations. For example, when registering two PET-CT datasets, one process describes the CT-CT registration, while a second process describes the PET - PET registration. The resulting deformation field is the *weighted sum* of the defromation fields computed by each process.
%
%% Syntax
% |[handles iterations_per_scale] = Registration_modules(num_of_processes,fixedname,movingname,maskname,nlevel,iterations,regis,preregul,pre_var,merging,fluidregul,fluid_var,accumulation,solidregul,solid_var,def_image_name,def_field_name,report_name,visual,handles,logdomain)|
%
% |[handles iterations_per_scale] = Registration_modules(num_of_processes,fixedname,movingname,maskname,nlevel,iterations,regis,preregul,pre_var,merging,fluidregul,fluid_var,accumulation,solidregul,solid_var,def_image_name,def_field_name,report_name,visual,handles)|
%
%
%% Description
% |[handles iterations_per_scale] = Registration_modules(num_of_processes,fixedname,movingname,maskname,nlevel,iterations,regis,preregul,pre_var,merging,fluidregul,fluid_var,accumulation,solidregul,solid_var,def_image_name,def_field_name,report_name,visual,handles,logdomain)| Perform a multi-scale non-rigid registration
%
% |[handles iterations_per_scale] = Registration_modules(num_of_processes,fixedname,movingname,maskname,nlevel,iterations,regis,preregul,pre_var,merging,fluidregul,fluid_var,accumulation,solidregul,solid_var,def_image_name,def_field_name,report_name,visual,handles) | Perform a multi-scale non-rigid registration. Calls with default value for |logdmain|
%
%
%% Input arguments
% |num_of_processes| _INTEGER_ Number of registration processes used to compute the average deformation field. Each registration process requires a fixed and a moving image.
%
% |fixedname| - _CELL VECTOR of STRING_ -  Names of the fixed image contained in |handles.images| for each one of the defined registration processes. The number of elements in the cell vector must be equal to |num_of_processes|.
%
% |movingname| - _CELL VECTOR of STRING_ -  Names of the moving image contained in |handles.images| for each one of the defined registration processes. The number of elements in the cell vector must be equal to |num_of_processes|.
%
% |maskname| - _STRING_ -  Name of the image in |handles.images| that is used as discontinuity mask. Empty [] if no discountinuity mask is used.
%
% |nlevel| - _INTEGER_ -  Number of resolution levels to use for the multi-scale non-rigid registration. |nlevel| <= 2*ln2(S)+1, where S is the smallest size of fixed image and ln2 is the logarithm in base 2.
%
% |iterations| _VECTOR of INTEGER_ Number of iteration per resolution level. Number of elements must be equal to |nlevel|
%
% |regis| - _CELL VECTOR of INTEGER_ -  Define the non rigid registration algorithm for each process (1='block_matching_ssd', 2='demons', 3='block_matching_MI',4='morphons',5='demons_dm'). The number of elements in the cell vector must be equal to |num_of_processes|.
%
% |preregul| - _CELL VECTOR of INTEGER_ - Regularisation algorithm for each registration process. The number of elements in the cell vector must be equal to |num_of_processes|. The following algorithms are possible:
%
% * |preregul=1| : No regularisation
% * |preregul=2| : Gauss regularisation. If a discontinuity mask is defined (|maskname|), then use a discountinuous Gauss regularization.
% * |preregul=3| : Normalised Gauss regularisation. If a discontinuity mask is defined (|maskname|), then use a discountinuous normalized Gauss regularization.
%

% |pre_var| - _CELL of VECTORS_ -  Variance parameters of the regularization algorithms defined in |preregul| for each process. The number of elements in the cell vector must be equal to |num_of_processes|. The number of elements in each |pre_var{}| scalar vector must be larger or equal to the number of resolution levels |nlevel|.
%
% |merging| - _CELL VECTOR of SCALAR_ - Weights of each deformation field computed by each registration process in the final computation of the deformation field.
%
% |fluidregul| - _INTEGER_ - Fluid Regularisation algorithm. The following algorithms are possible:
%
% * |preregul=1| : No regularisation
% * |preregul=2| : Gauss regularisation. If a discontinuity mask is defined (|maskname|), then use a discountinuous Gauss regularization.
% * |preregul=3| : Normalised Gauss regularisation. If a discontinuity mask is defined (|maskname|), then use a discountinuous normalized Gauss regularization.
%
% |fluid_var| -_VECTOR of SCALAR_ - Variance parameters of the fluid regularization. The number of elements in the vector must be equal to the number of multi-scale levels |nlevel|
%
% |accumulation| - _INTEGER_ Algorithm for accumulation of the deformation field.  The following algorithms are possible:
%
% * |accumulation=1| : Sum
% * |accumulation=2| : Weighted Sum
% * |accumulation=3| : composite
% * |accumulation=4| : Composite certainty
% * |accumulation=5| : Diffeomorphic
% * |accumulation=6| : diffeomorphic certainty
%
% |solidregul| - _INTEGER_ - Solid Regularisation algorithm. The following algorithms are possible:
%
% * |solidregul=1| : No regularisation
% * |solidregul=2| : Gauss regularisation. If a discontinuity mask is defined (|maskname|), then use a discountinuous Gauss regularization.
% * |solidregul=3| : Normalised Gauss regularisation. If a discontinuity mask is defined (|maskname|), then use a discountinuous normalized Gauss regularization.
%
% |solid_var| -_VECTOR of SCALAR_ - Variance parameters of the solid regularization. The number of elements in the vector must be equal to the number of multi-scale levels |nlevel|
%
%
% |def_image_name| - _STRING_ -  Name of the image in |handles.images| that will receive the deformed image
%
% |def_field_name| - _STRING_ -  Name of the field in |handles.fields| that will receive the deformation field
%
% |report_name| - _STRING_ -  Name of the file where the report is saved. Empty [] if no report is created
%
% |visual| - _INTEGER_ - If |visual = 1|, a visualisation function will be called after each iteration of the non-rigid registration process.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images| - _STRUCTURE_ - The fixed and mobile images
% * |handles.roi_mode| _SCALAR_ - |handles.roi_mode=1| The region of interest mode is activated in REGGUI.|handles.roi_mode=0| The region of interest mode is desactivated in REGGUI
% * |handles.current_roi{1}| - Index of the image in |handles.images.name| that should be used as the ROI
% * |handles.current_roi{2}| - Name of the image in  |handles.images.name| that should be used as the ROI
% * |handles.spacing| - _VECTOR of SCALAR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |logdomain| - _INTEGRER_ -  (Default: |logdomain=0|) |logdomain=1|: Use the logarithmic diffeomorphic domain to combine the transform. |logdomain=1| can be used ONLY when using diffeomorphic |accumulation|. |logdomain=0| Directly add the transform.
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data is updated:
% * |handles.images|- _STRUCTURE_ - The deformed image with name |def_image_name|
% * |handles.fields|- _STRUCTURE_ - The deformation field with name |def_field_name|
% * |handles.fields|- _STRUCTURE_ - The logarithm of the deformation field with name '|def_field_name|_log' (if |logdomain=1|)
%
% |iterations_per_scale| - _VECTOR of INTEGER_ - Actual number of iterations in the registration for each resolution level.
%
%% NOTES
%
% * If the moving and fixed images are 3D, the reg_animate script is called to carry out the non rigid registration. If the fixed and moving images are 2D, the script reg_animate2D is called, which is still an experimental development.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

%TODO Remove global reg; Why do we need a global variable ????

%%%%%%%%reg_create ==> global reg ==> reg_animate


function [handles iterations_per_scale] = Registration_modules(num_of_processes,fixedname,movingname,maskname,nlevel,iterations,regis,preregul,pre_var,merging,fluidregul,fluid_var,accumulation,solidregul,solid_var,def_image_name,def_field_name,report_name,visual,handles,logdomain)

if(nargin<21)
    logdomain = 0;
end

m = struct;
m.nb_process = num_of_processes;
m.prototype_density = 1;

m.outputimage = def_image_name;
m.outputfield = def_field_name;

% If region of interest defined in REGGUI
use_roi_mode = 0;
if(handles.roi_mode == 1)
    try
        if(strcmp(handles.images.name{handles.current_roi{2}},handles.current_roi{1}))
            use_roi_mode = handles.current_roi{2};
        else
            handles.roi_mode = 0;
            handles.current_roi = cell(0);
        end
    catch
        handles.roi_mode = 0;
        handles.current_roi = cell(0);
    end
end


% Set discontinuity mask
m.maskname = maskname;
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},maskname))
        m.input_mask{1} = handles.images.data{i};
    end
end


for p=1:m.nb_process
    
    %Set names
    m.fixedname{p} = fixedname{p};
    m.movingname{p} = movingname{p};
    
    %Set images
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},fixedname{p}))
            m.input_data{p} = handles.images.data{i};
        end
        if(strcmp(handles.images.name{i},movingname{p}))
            m.prototype_data{p} = handles.images.data{i};
            myInfo = handles.images.info{i};
        end
        if(use_roi_mode)
            m.input_cert{p} = single(handles.images.data{use_roi_mode});
            m.input_cert{p} = m.input_cert{p}/max(max(max(m.input_cert{p})));
        else
            m.input_cert{p} = 1;
        end
    end
    
    if(isempty(m.input_data{p}))
        error(['Error : impossible to perform registration (process number ',num2str(p),') without fixed image !'])
    end
    if(isempty(m.prototype_data{p}))
        error(['Error : impossible to perform registration (process number ',num2str(p),') without moving image !'])
    end
    
    switch regis{p}
        case 1
            m.displacement_method{p} = 'block_matching_ssd';
        case 2
            m.displacement_method{p} = 'demons';
        case 3
            m.displacement_method{p} = 'block_matching_MI';
        case 4
            m.displacement_method{p} = 'morphons';
        case 5
            m.displacement_method{p} = 'demons_dm';
        otherwise
            error('Invalid registration method number')
    end
    
    switch preregul{p}
        case 1
            m.pre_regularisation{p} = 'none';
            m.pre_regularisation_data{p} = [];
        case 2
            if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
                m.pre_regularisation{p} = 'gauss_discontinuous';
            else
                m.pre_regularisation{p} = 'gauss';
            end
            m.pre_regularisation_data{p} = pre_var{p};
        case 3
            if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
                m.pre_regularisation{p} = 'normgauss_discontinuous';
            else
                m.pre_regularisation{p} = 'normgauss';
            end
            m.pre_regularisation_data{p} = pre_var{p};
        otherwise
            error('Invalid pre-regularization method number')
    end
    
    if(length(pre_var{p})>=nlevel)
        m.pre_regularisation_data{p} = [pre_var{p}(1:nlevel)./m.prototype_density];
    elseif(length(pre_var{p})>1)
        error('Error : length of variance parameters vector must be equal to number of resolution levels !')
    end
    
    m.weight_field{p} = merging{p};
    m.weight_cert{p} = merging{p};
    
end


switch fluidregul
    case 1
        m.fluid_regularisation = 'none';
        m.fluid_regularisation_data = [];
    case 2
        if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
            m.fluid_regularisation = 'gauss_discontinuous';
        else
            m.fluid_regularisation = 'gauss';
        end
        m.fluid_regularisation_data = fluid_var;
    case 3
        if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
            m.fluid_regularisation = 'normgauss_discontinuous';
        else
            m.fluid_regularisation = 'normgauss';
        end
        m.fluid_regularisation_data = fluid_var;
    otherwise
        error('Invalid fluid regularization method number')
end


switch accumulation
    case 1
        m.accumulation_method = 'sum';
        m.accumulation_data = [];
    case 2
        m.accumulation_method = 'weighted_sum';
        m.accumulation_data = [];
    case 3
        m.accumulation_method = 'compositive';
        m.accumulation_data = [];
    case 4
        m.accumulation_method = 'compositive_certainty';
        m.accumulation_data = [];
    case 5
        if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
            m.accumulation_method = 'diffeomorphic_and_mask';
        else
            m.accumulation_method = 'diffeomorphic';
        end
        m.accumulation_data = [];
    case 6
        if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
            m.accumulation_method = 'diffeomorphic_certainty_and_mask';
        else
            m.accumulation_method = 'diffeomorphic_certainty';
        end
        m.accumulation_data = [];
    otherwise
        error('Invalid pre-regularization method number')
end


switch solidregul
    case 1
        m.solid_regularisation = 'none';
        m.solid_regularisation_data = [];
    case 2
        if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
            m.solid_regularisation = 'gauss_discontinuous';
        else
            m.solid_regularisation = 'gauss';
        end
        m.solid_regularisation_data = solid_var;
    case 3
        if(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
            m.solid_regularisation = 'normgauss_discontinuous';
        else
            m.solid_regularisation = 'normgauss';
        end
        m.solid_regularisation_data = solid_var;
    otherwise
        error('Invalid solid regularization method number')
end


if(isempty(m.input_mask{1}))
    m.input_mask{1} = 1;
elseif(strcmp(m.accumulation_method,'diffeomorphic'))  %%% ADD CASES !!!!!
    m.accumulation_method = 'diffeomorphic_and_mask';
elseif(strcmp(m.accumulation_method,'diffeomorphic_certainty'))
    m.accumulation_method = 'diffeomorphic_certainty_and_mask';
end


% Default parameters for registration
m.regul = 'NoRegul';
m.prototype_density = 1;
m.resampling_method = 'default';
m.resampling_data = [];
m.resampling_cert = [];
m.displacement_data = [];
m.deformation_method = 'default';
m.deformation_boundary = 'neuman';
if(isempty(report_name))
    m.report = 0;
else
    m.report = report_name;
end
m.visual = visual;
if(logdomain)
    if(not(isempty(strfind(m.accumulation_method,'diffeomorphic'))))
        m.logdomain = logdomain;
    else
        disp('Warning : Not possible to perform non-diffeomorphic registration in the log-domain !!')
        m.logdomain = 0;
        logdomain = 0;
    end
else
    m.logdomain = 0;
end
m.spacing = handles.spacing;

% Setting remaining parameters
while(round(2^(-(nlevel-1)/2)*min(size(m.input_data{1})))==1)
    nlevel = nlevel-1;
    disp(['Number of level too large for image size : nlevel reduced from ' num2str(nlevel+1) ' to ' num2str(nlevel)]);
end

m.min_scale = 0;
m.max_scale = nlevel-1;
m.out_scale = 0;
if(length(iterations)>=nlevel)
    m.iterations = iterations(1:nlevel);
else
    error('Error : length of iterations parameters vector must be equal to number of resolution levels !')
end
if(length(fluid_var)>=nlevel)
    m.fluid_regularisation_data = [fluid_var(1:nlevel)./m.prototype_density];
elseif(length(fluid_var)>1)
    error('Error : length of variance parameters vector must be equal to number of resolution levels !')
end

if(length(solid_var)>=nlevel)
    m.solid_regularisation_data = [solid_var(1:nlevel)./m.prototype_density];
elseif(length(solid_var)>1)
    error('Error : length of variance parameters vector must be equal to number of resolution levels !')
end

% Added by J.A.Lee
global reg; %TODO Avoid using global variables

% Create the reg
reg = reg_create(m);
clear('m')

% Initiate the reg with no deformation
reg = reg_init(reg);

% Run the predefined scheme
if (sum(reg.sz~=1)==2)
    disp('Warning: images are 2D. An experimental version of 2D registration will be performed with no warranty on the result');
    reg_animate2D;
else
    iterations_per_scale = reg_animate;
end

dims = reg.dims;

field = field_convert(reg.live.accumulated_deformation_field,dims);

% Exporting deformed image
def_image_name = check_existing_names(def_image_name,handles.images.name);
handles.images.name{length(handles.images.name)+1} = def_image_name;
handles.images.data{length(handles.images.data)+1} = reg.process(1,1).deformed_prototype.data;
info = Create_default_info('image',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;

% Exporting deformation field
def_field_name = check_existing_names(def_field_name,handles.fields.name);

if(logdomain)
    log_field = field;
    field = field_exponentiation(log_field);
    handles.fields.name{length(handles.fields.name)+1} = [def_field_name '_log'];
    handles.fields.data{length(handles.fields.data)+1} = log_field;
    handles.fields.info{length(handles.fields.info)+1} = Create_default_info('deformation_field',handles,info);
end

handles.fields.name{length(handles.fields.name)+1} = def_field_name;
handles.fields.data{length(handles.fields.data)+1} = field;
handles.fields.info{length(handles.fields.info)+1} = Create_default_info('deformation_field',handles,info);

% Added by J.A.Lee
clear global;



