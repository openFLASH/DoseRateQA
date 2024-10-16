%% Registration_nonrigid
% Perform a multi-scale non-rigid registration of a moving image onto a fixed image.
% There is a single registration process.
%
%% Syntax
% |handles = Registration_nonrigid(fixedname,movingname,segname,maskname,method,nlevel,iterations,variances,elastic_iterations,elastic_anisotropism,def_image_name,def_field_name,report_name,visual,handles)|
%
%
%% Description
% |handles = Registration_nonrigid(fixedname,movingname,segname,maskname,method,nlevel,iterations,variances,elastic_iterations,elastic_anisotropism,def_image_name,def_field_name,report_name,visual,handles)| Perform a multi-scale non-rigid registration
%
%
%% Input arguments
% |fixedname| - _STRING_ -  Name of the fixed image contained in |handles.images|.
%
% |movingname| - _STRING_ -  Name of the moving image contained in |handles.images|.
%
% |segname| - _STRING_ - Name of the image in |handles.images| containing the Poisson ratio to be used for elastic filtering.
%
% |maskname| - _STRING_ -  [OPTIONAL : Required only when using masks] Name of the image in |handles.images| that is used as discontinuity mask. Empty [] if no discountinuity mask is used.
%
% |method| - _STRING_ -  Define the methods for registration, accumulation and solid regularisation: 
%
% |method =  'morphons'| : registration = 'default', accumulation = 'default', solid_regularisation = 'default'
% |method =  'demons'| : registration = 'demons', accumulation = 'none', solid_regularisation = 'gauss'
% |method =  'demons_dm'| : registration = 'demons_dm', accumulation = 'default', solid_regularisation = 'default'
% |method =  'block matching'| : registration = 'block_matching', accumulation_method = 'default', solid_regularisation = 'default';
% |method =  'block matching mi'| : registration = 'block_matching_mi', accumulation_method = 'default', solid_regularisation = 'default'
% |method =  'single resolution demons (Matitk)'| : Use the Matitk library to perform the registration [http://matitk.cs.sfu.ca/search]. Matitk demons registration does not allow elastic regularisation, multi-resolution nor multi-processing, and return deformed image only (not the field).
%
% |nlevel| - _INTEGER_ -  Number of resolution levels to use for the multi-scale non-rigid registration. |nlevel| <= 2*ln2(S)+1, where S is the smallest size of fixed image and ln2 is the logarithm in base 2.
%
% |iterations| _VECTOR of INTEGER_ Number of iteration per resolution level. Number of elements must be equal to |nlevel|
%
% |variances| -_VECTOR of SCALAR_ - Variance parameters of the solid regularization. The number of elements in the vector must be equal to the number of multi-scale levels |nlevel|
%
% |elastic_iterations| - _VECTOR of INTEGER_ - [OPTIONAL: required only when using elastic regularization] |elastic_iterations(s)| Number of iterations of elastic regularization to run at the scale |s| (see regularisation_elastic.m)
%
% |elastic_anisotropism| - _VECTOR of SCALR_ - Coefficient K*255/max(handles.images.data) of the anisotropy coefficient for the scale |s| for elastic regularization.  (see regularisation_elastic.m)
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
% * |handles.spacing| - _VECTOR of SCALAR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |handles| - _TYPE_ - description for 1st syntax
%
% * |handles.images|- _STRUCTURE_ - The deformed image with name |def_image_name|
% * |handles.fields|- _STRUCTURE_ - The deformation field with name |def_field_name|
% * |handles.fields|- _STRUCTURE_ - The logarithm of the deformation field with name '|def_field_name|_log' (if |logdomain=1|)
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Registration_nonrigid(fixedname,movingname,segname,maskname,method,nlevel,iterations,variances,elastic_iterations,elastic_anisotropism,def_image_name,def_field_name,report_name,visual,handles)

m = struct;
m.nb_process = 1;

%Set names
m.fixedname{1} = fixedname;
m.movingname{1} = movingname;
m.maskname{1} = maskname;

m.outputimage = def_image_name;
m.outputfield = def_field_name;

%Set regularisation
m.regul = 'NoRegul';
if(~isempty(elastic_iterations))
    m.regul = 'Regul';
    m.segname = segname;
end

%Set method
m.method{1} = method;
m.pre_regularisation{1} = 'none';
m.pre_regularisation_data{1} = [];
m.fluid_regularisation = 'none';
m.fluid_regularisation_data = [];
m.weight_field{1} = 1;
m.weight_cert{1} = 1;

%Set images
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},fixedname))
        m.input_data{1} = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},movingname))
        m.prototype_data{1} = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
    if(strcmp(handles.images.name{i},maskname))
        m.input_mask{1} = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},segname))
        m.seg = handles.images.data{i};
        if(max(max(max(m.seg)))>1)
            disp('Rescaling segmentation image...')
            m.seg = m.seg/100; % If segmentation image describe the poisson coeff multiplied by 100...
        end
    end
    m.input_cert{1} = 1;
end

if(isempty(m.input_data{1}))
    error('Error : impossible to perform registration without fixed image !')
end
if(isempty(m.prototype_data{1}))
    error('Error : impossible to perform registration without moving image !')
end

switch m.method{1}
    case 'morphons'
        m.displacement_method{1} = 'default';
        m.accumulation_method = 'default';
        m.accumulation_data = [];
        m.solid_regularisation = 'default';
    case 'demons'
        m.displacement_method{1} = 'demons';
        m.accumulation_method = 'none';
        m.accumulation_data = [];
        m.solid_regularisation = 'gauss';
    case 'demons_dm'
        m.displacement_method{1} = 'demons_dm';
        m.accumulation_method = 'default';
        m.accumulation_data = [];
        m.solid_regularisation = 'default';
    case 'block matching'
        m.displacement_method{1} = 'block_matching';
        m.accumulation_method = 'default';
        m.accumulation_data = [];
        m.solid_regularisation = 'default';
    case 'block matching mi'
        m.displacement_method{1} = 'block_matching_mi';
        m.accumulation_method = 'default';
        m.accumulation_data = [];
        m.solid_regularisation = 'default';
    case 'single resolution demons (Matitk)'
        try
            disp('Warning : Matitk demons registration does not allow elastic regularisation, multi-resolution nor multi-processing, and return deformed image only (not the field).')
            deformed_image = matitk('rd',[1024 7 iterations(1) variances(1)],m.input_data{1},m.prototype_data{2});
            handles.images.name{length(handles.images.name)+1} = def_image_name;
            handles.images.data{length(handles.images.data)+1} = deformed_image;
        catch ME
            reggui_logger.info(['Error : failed to execute matitk ! Please make sure you have matitk installed. ',ME.message],handles.log_filename);
            rethrow(ME);
        end
        return
    case 'diffeomorphic morphons'
        m.displacement_method{1} = 'default';
        m.accumulation_method = 'diffeomorphic_certainty';
        m.accumulation_data = [];
        m.solid_regularisation = 'default';
    case 'diffeomorphic demons'
        m.displacement_method{1} = 'demons';
        m.accumulation_method = 'diffeomorphic';
        m.accumulation_data = [];
        m.solid_regularisation = 'gauss';
    case 'diffeomorphic block matching'
        m.displacement_method{1} = 'block_matching';
        m.accumulation_method = 'diffeomorphic_certainty';
        m.accumulation_data = [];
        m.solid_regularisation = 'default';
    otherwise
        error('Invalid registration method : maybe not yet implemented...')
end

if(isempty(m.input_mask{1}))
    m.input_mask{1} = 1;
elseif(strcmp(m.accumulation_method,'diffeomorphic_certainty'))
    m.accumulation_method = 'diffeomorphic_certainty_and_mask';
end
if(isempty(m.input_cert{1}))
    m.input_cert{1} = 1;
end

% Default parameters for registration
m.prototype_density = 1;
if(strcmp(m.regul,'Regul'))
    m.solid_regularisation = 'elastic';
elseif(sum(size(m.input_mask{1}))==sum(size(m.input_data{1})))
    if(strcmp(m.solid_regularisation,'gauss'))
        m.solid_regularisation = 'gauss_discontinuous';
    else
        m.solid_regularisation = 'normgauss_discontinuous';
    end
end
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

if(length(variances)>=nlevel)
    m.solid_regularisation_data = [variances(1:nlevel)./m.prototype_density];
    if(strcmp(m.regul,'Regul'))
        try
            m.elastic_regularisation_data = [elastic_iterations(1:nlevel) ;...
                elastic_anisotropism(1:nlevel)*(max(max(max(m.input_data{1}))))/255 ;...
                2*ones(size(elastic_anisotropism(1:nlevel)))];
        catch
            disp('Error : length of elastic post-regularisation parameters vector must be equal to number of resolution levels !')
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
else
    error('Error : length of variance parameters vector must be equal to number of resolution levels !')
end

% Added by J.A.Lee
global reg;

% Create the reg
reg = reg_create(m);
clear('m')

% Initiate the reg with no deformation
reg = reg_init(reg);

% Run the predefined scheme
% Run the predefined scheme
if (sum(reg.sz~=1)==2)
    disp('Warning: images are 2D. An experimental version of 2D registration will be performed with no warranty on the result');
    reg_animate2D;
else
    iterations_per_scale = reg_animate;
end

dims = reg.dims;

field = field_convert(reg.live.accumulated_deformation_field,dims);

def_image_name = check_existing_names(def_image_name,handles.images.name);
handles.images.name{length(handles.images.name)+1} = def_image_name;
handles.images.data{length(handles.images.data)+1} = reg.process(1,1).deformed_prototype.data;
info = Create_default_info('image',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;

def_field_name = check_existing_names(def_field_name,handles.fields.name);
handles.fields.name{length(handles.fields.name)+1} = def_field_name;
handles.fields.data{length(handles.fields.data)+1} = field;
handles.fields.info{length(handles.fields.info)+1} = Create_default_info('deformation_field',handles,info);

% Added by J.A.Lee
clear global;



