%% reg_animate
%
% This is the function carrying out the actual computation of the multi-scale non-rigid deformation for 3D images. See reference [1] for more information on the registration process.
% 
% An animation is a set of registration iterations on a set of scales.The input is a registration structure |reg| (created with 'reg_create.m' and initialised with 'reg_init.m') containing a description of the registration process. The |reg| struct is created by providing data on input image (fixed) and prototype image (moving). The |reg| structure also defines the current scale, deformation field and deformed prototype on the current scale during the process of non-rigid registration. 
%
% The deformable registration takes place in *several processes* occuring simulatneously. Each process describes a registration of one pair of images (fixed & moving) for a specified number of iterations. For example, when registering two PET-CT datasets, one process describes the CT-CT registration, while a second process describes the PET - PET registration. The resulting deformation field is the *weighted sum* of the defromation fields computed by each process.
%
% The deformable registration is *multi-scale*. The registration starts at the larger scale. For each scale, all the registration processes are carried out for the specified number of iterations. Then the weighted sum of the deofrmation fields is computed, for that scale. The while computation is repeated again for the next scale down, using the deformation field of the previous scale as the starting field for the next scale down.
% 
% To animate the registration, the sequence of operations is: 
%
% # Start at the larger scale 
% # Rescale the deformation fields (from the previous scale level) and the certainty maps  to the new scale level
% # For each registration process: rescale the images (fixed & moving) of this process to the new scale level
% # Find estimates of the deformation field by using |reg.process(p).displacement_estimation|
% # Regularise: Several regularisations are applied sequentially to the deformed field: |reg.process(p).pre_regularisation| is applied on the field computed by each registration process, then the |reg.fluid_regularisation| is applied to the weighted sum field. Then |reg.solid_regularisation| is applied on the resulting deformation filed. There are several mechanical models describing the behavior of a body undergoing deformation, depending on the nature of the material. These materials can be solid or fluid, and their behavior can be approximated using some of the models used for modeling soft tissues. For more informations, see reference [1], section 2.3.3 Biomechanical behaviour. Eventually, an optional elastic regularization can be applied (see 'regularization_elastic.m' for details).
% # Accumulate the deformation field from all the processes using |reg.accumulation|
% # Deform the prototype (mobile) image by applying |reg.deformation| using the currently computed |reg.live.accumulated_deformation_field|
% # Repeat at step 3 for the next registration process
% # Repeat at step 1 for the next scale down  while the scale is larger than the minimum scale
%
%
%% Syntax
% |iterations_per_scale = reg_animate()|
%
%% Description
% |iterations_per_scale = reg_animate()| run the multiscale deformable registration and store the results in the global variable |reg|.
%
%% Input arguments
% |global reg| - _STRUCTURE_ - The structure containing the data for the registration. The structure is created by "reg_create.m" and the data to run the live registration is initialised by calling "reg_init.m". The data is inputed into the function "reg_animate.m" via a *global variable* |reg|
%
% * |reg.iters| - _VECTOR of INTEGER_ - |reg.iters(i)| is the number of iterations for each registration at the resolution level |i|. The number of elements of the vector defines the number of resolution levels |nlevel| to use with |nlevel| <= 2*ln2(S)+1, where S is the smallest size of fixed image and ln2 is the logarithm in base 2.
%
% * |reg.nb_process| - _INTEGER_ - Number of simulateneous registration processes to include in the average deformation field. Each registration process requires a fixed and a moving image.
%
% * |reg.process| - _VECTOR STRUCTURE_ - Structure describing each registration process. Length equals to |reg.nb_process|. Each element of the structure describes one of the registration process included in the weighted sum leading to the final deformation field. The structure contains the following fields:
% * ----|reg.process(p).input| - _STRUCTURE_ - Structure describing the fixed 3D image for process |p|. See description in 'reg_input.m'. 
% * ----|reg.process(p).input.cert| - _MATRICE_ - Certainty about the value of the intensity at voxel (x,y,z) of the input data. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
% * ----|reg.process(p).prototype| - _STRUCTURE_ - Structure describing the mobile 3D image for process |p|. See description in 'reg_prototype.m'
% * ----|reg.process(p).deformed_prototype| :  - _STRUCTURE_ - Structure describing the deformed mobile image for process |p|. See description in 'reg_prototype.m'. The initial data structure of the un-deformed image and it is updated at each iteration.
% * ----|reg.process(p).displacement_estimation| - _STRUCTURE_ - Structure describing the non rigid registration algorithm to use for the registration process |p|.  See description in reg_displacement_estimation.
% * ----|reg.process(p).pre_regularisation| - _STRUCTURE_ - Structure describing the regularisation to apply to process |p|. See description in 'reg_regularisation.m'
% * ----|reg.process(p).weight_field| - _SCALAR_ - Weight of the deformation field computed by this registration process to use when accumulating the field in the final deformation .
% * ----|reg.process(p).weight_cert| - _SCALAR_ - Weight of the certainty map |reg.process(p).input.cert| for this registration process in the final ceratinty map.
% * ----|reg.process(p).q_in{n}| - _SCALAR MATRIX_ reg.process(p).q_in{n}(x,y,z) Intensity of the voxel (x,y,z) of the rescaled input image |input.rescaled_data| convolved with the quadrature filter kernel |n| for process |p|
%
% * |reg.elastic| - _STRUCTURE_ - [OPTIONAL: required only when using elastic regularization] Data structure describing the optional additional elastic regularization. See 'regularisation_elastic.m' for details
%
% * |reg.accumulation| - _STRUCTURE_ - Structure describing the accumulation function combining the deformation fields of each process and of each scale. See 'reg_accumulation.m' for details
%
% * |reg.resampling| - _STRUCTURE_ - Structure describing the resampling function used to resample the fields and images between the different scales. See 'reg_resampling.m' for details
%
%
% * |reg.fluid_regularisation| - _STRUCTURE_ - Structure describing the regularisation for "fluid" material. See description in 'reg_regularisation.m'. 
%
% * |reg.solid_regularisation| - _STRUCTURE_ - Structure describing the regularisation for "solid" material. See description in 'reg_regularisation.m'
%
% * |reg.deformation| - _STRUCTURE_ - Deformation structure describing the transformation of the prototype image. This function deforms the prototype (=mobile) image using the accumulated deformation field. It is NOT used to compute the non-deformable image registration (this is done by |reg.process(p).displacement_estimation|). It is used to apply the computed deformation field on the image. See 'reg_deformation.m' for details
%
% * |reg.logdomain| - _INTEGRER_ -  |logdomain=1|: Use the logarithmic diffeomorphic when accumulating the transforms. |logdomain=0| Directly accumulate the transform (i.e. in the exponential domain).
%
% * |reg.dims| - _INTEGER_ - Number of dimensions of the input image
%
% * |reg.sz| - _VECTOR of SCALAR_ Dimension (x,y,z) (in pixels) of the fixed image. Length is equal to |reg.dims|.
%
% * |reg.spacing| - _VECTOR of SCALAR_ - Size (x,y,z) (in |mm|) of the pixels in the images.
%
% * |reg.fixedname| - _STRING_ - Name of the first fixed image contained in |reg.process(p).input|. 
%
% * |reg.movingname| - _STRING_ - Name of the first moving image contained in |reg.process(p).prototype|. 
%
% * |reg.outputimagename| - _STRING_ Name of the outputed deformed image
%
% * |reg.outputfieldname| - _STRING_ Name of the outputed deformation field. If |reg.report~=0|, then the deformation field will also be saved on disk.
%
% * |reg.visual| - _INTEGER_ - If |reg.visual = 0|: no visualisation function will be called after each iteration of the non-rigid registration process.
%
% * |reg.report| - _SCALAR or STRING_ - If |reg.report=0|: no report will be created in a file. If |reg.report = _STRING_|: A report is saved in file and |reg.report| defined the file name.
%
% * |reg.live| - _STRUCTURE_ - Data defining the current state of the live registration process.
% * ----- |reg.live.current_scale| In the multi-scale registration, defines scale of the current deformable registration process (Default: -1 = there was no previous iteration). The definition of the scale is given in the resampler function "standard_resampler".
% * ----- |reg.live.old_scale| In the multi-scale registration, defines the scale of the previous deformable registration process. (Default: 0 = full scale) 
% * ----- |reg.live.accumulated_deformation_field| - _CELL VECTOR of MATRICES_ |accumulated_deformation_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. The number of cell  elements is equal to |reg.dims|.
% * ----- |reg.live.accumulated_deformation_certainty| _MATRICE_ Certainty about the value of the deformation field at voxel (x,y,z) for the current iteration. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
%% Output arguments
%
% |global reg| - _STRUCTURE_ - The structure containing the results of the registration. The variable is outputed from the function via a *global variable*
%
% * |reg.live| - _STRUCTURE_ Data defining the current state of the live registration process.
% * ----- |reg.live.accumulated_deformation_field| - _CELL VECTOR of MATRICES_ - |accumulated_deformation_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. The number of cell  elements is equal to |reg.dims|.
% * ----- |reg.live.accumulated_deformation_certainty| - _MATRICE_ - Certainty about the value of the deformation field at voxel (x,y,z) for the current iteration. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |iterations_per_scale| - _VECTOR of INTEGER_ - Actual number of iterations in the registration for each resolution level. 
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
%
%TODO Do not use global variable. Give |reg| as a input parameter to the function



function iterations_per_scale = reg_animate()

% Added by J.A.Lee
global reg;

% Open report
if(reg.report)
    try
        fid = fopen(reg.report,'w');
        fprintf(fid,'Starting registration\n');
        fprintf(fid,[' OutputDeformationField : ',reg.outputfieldname,'\n']);
        fprintf(fid,' \n');
    catch
        error(['Error : cannot create report.txt at location : ',reg.report,' ... Please check your test file']);
    end
end

% Initiate animation scale counter
iterations_per_scale = [];
scale = reg.resampling.max_scale;
metric_SSD_tot = [];
metric_CC_tot = [];
metric_MNorm_tot = [];
use_cc_metric = 0;
use_mnorm_metric = 0;%perthousand
orig_size = reg.sz;

% Set memory limit according to OS 32/64 bits
memory_limit = 64^3;
c = computer;
if(strcmp(c(end-1:end),'64'))
    memory_limit = 256^3;
end

% Diplay properties and parameters
disp('  --> Registration parameters :');
disp(['      - Number of processes : ' num2str(reg.nb_process)]);
disp(['      - Number of scales : ' num2str(scale+1)]);
disp(['      - Number of iterations : ' num2str(reg.iters)]);
for p=1:reg.nb_process
    disp(['      - Process ' num2str(p) ' : ' reg.process(p).displacement_estimation.function ', ' reg.process(p).pre_regularisation.function ' (' num2str(reg.process(p).pre_regularisation.data) '), ' reg.fluid_regularisation.function ' (' num2str(reg.fluid_regularisation.data) '), ' reg.accumulation.function ', and ' reg.solid_regularisation.function ' (' num2str(reg.solid_regularisation.data) ').']);
end
if(reg.logdomain)
    disp('      - velocity field computed in the log-domain');
end
disp(['  --> Starting time : ' datestr(clock)]);

tic

% Do the following while the scale is larger than or equal to min_scale.
while(scale >= reg.resampling.min_scale)
    
    disp(['Scale: ', num2str(scale), ' (min scale:', num2str(reg.resampling.min_scale),')']);
    if(reg.report)
        fprintf(fid,'*******\n');
    end
    
    % Resample the accumulated deformation field and certainty to current scale
    eval(['reg.live.accumulated_deformation_field = ', ...
        reg.resampling.function, '(reg.live.accumulated_deformation_field, ''linear'', ',...
        'reg.live.current_scale, scale, 1, orig_size);']);
    
    eval(['reg.live.accumulated_deformation_certainty = ', ...
        reg.resampling.function, '(reg.live.accumulated_deformation_certainty, ''linear'', ',...
        'reg.live.current_scale, scale, 0, orig_size);']);
    
    % Verify the integrity of the deformation field (remove nan)
    z = [];
    for n = 1:length(reg.live.accumulated_deformation_field)
        tz = find(isnan(reg.live.accumulated_deformation_field{n}));
        z = [z;tz(:)];
    end
    for n = 1:length(reg.live.accumulated_deformation_field)
        reg.live.accumulated_deformation_field{n}(z) = 0;
    end
    reg.live.accumulated_deformation_certainty(z) = 0;
    
    
    for p=1:reg.nb_process
        
        % Resample indata to scale
        eval(['reg.process(p).input.rescaled_data = ', reg.resampling.function, ...
            '(reg.process(p).input.data, ''linear'', 0, scale, 0, orig_size);']);
        
        % If the indata has a certainty map, resample this too
        if(length(reg.process(p).input.cert)>1)
            eval(['reg.process(p).input.rescaled_cert = ', reg.resampling.function, ...
                '(reg.process(p).input.cert, ''linear'', 0, scale, 0, orig_size);']);
        else
            reg.process(p).input.rescaled_cert = reg.process(p).input.cert;
        end        
        
        % Deform the prototype on the current scale
        eval(['reg.process(p).prototype.rescaled.data = ', reg.resampling.function, ...
            '(reg.process(p).prototype.data, ''linear'', 0, scale, 0, orig_size);']);
        
        if(reg.logdomain)
            eval(['reg.process(p).deformed_prototype.data = ', reg.deformation.function, ...
                '(reg.process(p).prototype.rescaled.data, reg.deformation.boundary, ',...
                'reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty,''linear'',1);']);
        else
            eval(['reg.process(p).deformed_prototype.data = ', reg.deformation.function, ...
                '(reg.process(p).prototype.rescaled.data, reg.deformation.boundary, ',...
                'reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty,''linear'');']);
        end
        
        % If the indata (first process only) has a mask, resample this too
        if(ndims(reg.process(1).input.mask)==3  && ndims(reg.process(p).input.data)==3)
            eval(['reg.process(p).input.rescaled_mask = ', reg.resampling.function, ...
                '(reg.process(1).input.mask, ''nearest'', 0, scale, 0, orig_size);']);
            try
                reg.process(p).input.rescaled_dm = single(compute_distmap(reg.process(p).input.rescaled_mask));
            catch
                if(sum(sum(sum(reg.process(p).input.rescaled_mask)))>0)
                    disp('Warning: impossible to compute distance map at this level of resolution. Replace by mask itself.');
                    reg.process(p).input.rescaled_dm = single(reg.process(p).input.rescaled_mask);
                else
                    disp('Warning: mask is empty at this level of resolution (segmented structure is probably too small).');
                    reg.process(p).input.rescaled_dm = single(reg.process(p).input.rescaled_mask);
                end
            end
            if(sum(sum(sum(reg.process(p).input.rescaled_dm))))
                [gx gy gz] = gradient(reg.process(p).input.rescaled_dm);
                reg.process(p).input.rescaled_grad{1} = gx./(sqrt(gx.^2+gy.^2+gz.^2)+eps);
                reg.process(p).input.rescaled_grad{2} = gy./(sqrt(gx.^2+gy.^2+gz.^2)+eps);
                reg.process(p).input.rescaled_grad{3} = gz./(sqrt(gx.^2+gy.^2+gz.^2)+eps);
                clear gx gy gz;
            else
                disp('Mask not valid!');
            end
        else
            reg.process(p).input.rescaled_mask = reg.process(1).input.mask;
        end
        
    end
    
    % Set current_scale and old_scale
    reg.live.old_scale = reg.live.current_scale;
    reg.live.current_scale = scale;
    
    % Compute weight
    processing = ones(1,reg.nb_process);
    weight_field_tot = 0;
    weight_cert_tot = 0;
    for p=1:reg.nb_process
        if(length(reg.process(p).weight_field)>1)
            weight_field_tot = weight_field_tot + reg.process(p).weight_field(scale+1);
            processing(p) = reg.process(p).weight_field(scale+1)>0;
        else
            weight_field_tot = weight_field_tot + reg.process(p).weight_field;
            processing(p) = reg.process(p).weight_field>0;
        end
        if(length(reg.process(p).weight_cert)>1)
            weight_cert_tot = weight_cert_tot + reg.process(p).weight_cert(scale+1);
        else
            weight_cert_tot = weight_cert_tot + reg.process(p).weight_cert;
        end
    end
    
    % Iterate the given number of times on this scale
    if(length(reg.iters)>1)
        iters = reg.iters(scale - reg.resampling.min_scale + 1);
    else
        iters = reg.iters(reg.resampling.max_scale - reg.resampling.min_scale + 1);
    end
    
    
    for iter = 1:iters % 2*iters
        
        % Estimate displacement fields
        %disp('Estimating displacement field')
        
        % Smart swap added by J.A.Lee
        f_sz = size(reg.live.accumulated_deformation_field{1});
        c_sz = size(reg.live.accumulated_deformation_certainty);
        file = (prod(f_sz)>memory_limit);
        
        if file
            %             memory
            accumulated_deformation_field = reg.live.accumulated_deformation_field;
            reg.live.accumulated_deformation_field = {};
            accumulated_deformation_certainty = reg.live.accumulated_deformation_certainty;
            reg.live.accumulated_deformation_certainty = [];
            save tmp1 accumulated_deformation_field accumulated_deformation_certainty;
            clear accumulated_deformation_field accumulated_deformation_certainty;
        end
        
        for n=1:reg.dims
            displacement_estimate_tot{n} = zeros(f_sz,'single');
        end
        displacement_certainty_tot = zeros(c_sz,'single');
        
        for p=1:reg.nb_process
            % Smart swap added by J.A.Lee
            if file
                save tmp2 displacement_estimate_tot displacement_certainty_tot;
                clear displacement_estimate_tot displacement_certainty_tot;
                % memory
            end
            
            if(processing(p))
                
                eval(['[displacement_estimate, displacement_certainty] = ',...
                    reg.process(p).displacement_estimation.function, '(p, iter);']);
                
                displacement_certainty = displacement_certainty.*(reg.process(p).input.rescaled_cert+eps);
                
                % Pre-Regularise field
                %disp('Pre-regularising field')
                eval(['[displacement_estimate, displacement_certainty] = ',...
                    reg.process(p).pre_regularisation.function, ...
                    '(reg.process(p), displacement_estimate, displacement_certainty, scale, reg.process(p).pre_regularisation.data);']);
                
                % Smart swap added by J.A.Lee
                if file
                    load tmp2;
                    delete tmp2.mat;
                end
                
                for n=1:reg.dims
                    if(length(reg.process(p).weight_field)>1)
                        displacement_estimate_tot{n} = displacement_estimate_tot{n} + displacement_estimate{n}*reg.process(p).weight_field(scale+1)/weight_field_tot;
                    else
                        displacement_estimate_tot{n} = displacement_estimate_tot{n} + displacement_estimate{n}*reg.process(p).weight_field/weight_field_tot;
                    end
                end
                % Pick here a slice to display?
                clear displacement_estimate;
                if(length(reg.process(p).weight_cert)>1)
                    if(p>1)
                        displacement_certainty_tot = displacement_certainty_tot + displacement_certainty*(mean(mean(mean(displacement_certainty_tot)))+1)/(p-1)/(mean(mean(mean(displacement_certainty)))+1)*reg.process(p).weight_cert(scale+1)/weight_cert_tot;
                    else
                        displacement_certainty_tot = displacement_certainty_tot + displacement_certainty*reg.process(p).weight_cert(scale+1)/weight_cert_tot;
                    end
                else
                    if(p>1)
                        displacement_certainty_tot = displacement_certainty_tot + displacement_certainty*(mean(mean(mean(displacement_certainty_tot)))+1)/(p-1)/(mean(mean(mean(displacement_certainty)))+1)*reg.process(p).weight_cert/weight_cert_tot;
                    else
                        displacement_certainty_tot = displacement_certainty_tot + displacement_certainty*reg.process(p).weight_cert/weight_cert_tot;
                    end
                end
                % Pick here a slice to display?
                clear displacement_certainty;
                
            end
            
        end
        
        % Smart swap added by J.A.Lee
        if file
            load tmp1;
            reg.live.accumulated_deformation_field = accumulated_deformation_field;
            reg.live.accumulated_deformation_certainty = accumulated_deformation_certainty;
            clear accumulated_deformation_field accumulated_deformation_certainty;
            delete tmp1.mat;
        end
        
        % Fluid regularization of the field
        eval(['[displacement_estimate_tot, displacement_certainty_tot] = ',...
            reg.fluid_regularisation.function, ...
            '(reg, displacement_estimate_tot, displacement_certainty_tot, scale, reg.fluid_regularisation.data);']);
        
        if(use_mnorm_metric)
            accumulated_deformation_field = reg.live.accumulated_deformation_field;
        end
        
        % Accumulate Field
        if(ndims(reg.process(1).input.rescaled_mask)==3)
            eval(['[reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty] = ', ...
                reg.accumulation.function, '(reg.live.accumulated_deformation_field, ',...
                'reg.live.accumulated_deformation_certainty, displacement_estimate_tot, ',...
                'displacement_certainty_tot,reg.process(1).input.rescaled_mask);']);
        else
            eval(['[reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty] = ', ...
                reg.accumulation.function, '(reg.live.accumulated_deformation_field, ',...
                'reg.live.accumulated_deformation_certainty, displacement_estimate_tot, ',...
                'displacement_certainty_tot);']);
        end
        
        % Solid regularization of the field
        eval(['[reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty] = ',...
            reg.solid_regularisation.function, ...
            '(reg, reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty, scale, reg.solid_regularisation.data);']);
        
        %Field metric
        if(use_mnorm_metric)
            %                metric_MNorm = sum(sum(sum( sqrt(squeeze(sum( (field_convert(accumulated_deformation_field)-field_convert(reg.live.accumulated_deformation_field)).^2,1))) ))) /size(reg.process(1).input.rescaled_data,1)/size(reg.process(1).input.rescaled_data,2)/size(reg.process(1).input.rescaled_data,3);
            metric_MNorm = sum(sum(sum( sqrt(squeeze(sum( (field_convert(accumulated_deformation_field)-field_convert(reg.live.accumulated_deformation_field)).^2,1))) ))) / sum(sum(sum( sqrt(squeeze(sum( (field_convert(accumulated_deformation_field)).^2,1))) )));
            clear accumulated_deformation_field;
        else
            metric_MNorm = 0;
        end
        
        for p=1:reg.nb_process
            % Deform prototype
            if(reg.logdomain)
                eval(['reg.process(p).deformed_prototype.data = ', reg.deformation.function, ...
                    '(reg.process(p).prototype.rescaled.data, reg.deformation.boundary, ',...
                    'reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty,''linear'',1);'])
            else
                eval(['reg.process(p).deformed_prototype.data = ', reg.deformation.function, ...
                    '(reg.process(p).prototype.rescaled.data, reg.deformation.boundary, ',...
                    'reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty,''linear'');']);
            end
        end
        
        % RESULTS
        % -------
        
        % Image metric
        if(length(reg.process(1).input.cert)>1)
            metric_SSD = sum(sum(sum( (reg.process(1).deformed_prototype.data - reg.process(1).input.rescaled_data).^2 .*(reg.process(p).input.rescaled_cert))))/size(reg.process(1).input.rescaled_data,1)/size(reg.process(1).input.rescaled_data,2)/size(reg.process(1).input.rescaled_data,3);
        else
            metric_SSD = sum(sum(sum( (reg.process(1).deformed_prototype.data - reg.process(1).input.rescaled_data).^2 )))/size(reg.process(1).input.rescaled_data,1)/size(reg.process(1).input.rescaled_data,2)/size(reg.process(1).input.rescaled_data,3);
        end
        if(use_cc_metric)
            if(length(reg.process(1).input.cert)>1)
                metric_CC = 1 - sum(sum(sum( (reg.process(1).deformed_prototype.data.*reg.process(1).input.rescaled_data).*(reg.process(p).input.rescaled_cert) )))/sqrt( sum(sum(sum((reg.process(1).deformed_prototype.data.^2).*(reg.process(p).input.rescaled_cert))))*sum(sum(sum((reg.process(1).input.rescaled_data.^2).*(reg.process(p).input.rescaled_cert)))) );
            else
                metric_CC = 1 - sum(sum(sum( reg.process(1).deformed_prototype.data.*reg.process(1).input.rescaled_data )))/sqrt( sum(sum(sum(reg.process(1).deformed_prototype.data.^2)))*sum(sum(sum(reg.process(1).input.rescaled_data.^2))) );
            end
        else
            metric_CC = 0;
        end
        
        if(metric_SSD>1)
            metric_SSD = round(metric_SSD*100)/100;
        end
        if(reg.report)
            fprintf(fid,[num2str(metric_SSD) '\n']);
        end
        
        if iter==1
            if(scale==reg.resampling.max_scale)
                metric_SSD_nrm = metric_SSD + eps;
                metric_CC_nrm = metric_CC + eps;
            else
                metric_SSD_nrm = metric_SSD/(metric_SSD_tot(end)+eps);
                metric_CC_nrm = metric_CC/(metric_CC_tot(end)+eps);
            end
        end
        
        if(isinf(metric_MNorm))
            metric_MNorm = 1;
        end
        
        if(use_mnorm_metric)
            disp(['Iteration ', num2str(iter), ' of ', num2str(iters), '  ------------------------->   SSD : ', num2str(metric_SSD),'   and   field MNorm : ', num2str(floor(metric_MNorm*1000))])
        elseif(use_cc_metric)
            disp(['Iteration ', num2str(iter), ' of ', num2str(iters), '  ------------------------->   SSD : ', num2str(metric_SSD),'   and   CC : ', num2str(metric_CC)])
        else
            disp(['Iteration ', num2str(iter), ' of ', num2str(iters), '  ------------------------->   SSD : ', num2str(metric_SSD)])
        end
        
        metric_SSD_tot = [metric_SSD_tot metric_SSD/(metric_SSD_nrm+eps)];
        metric_CC_tot = [metric_CC_tot metric_CC/(metric_CC_nrm+eps)];
        metric_MNorm_tot = [metric_MNorm_tot metric_MNorm];
        
        if reg.visual
            if(use_cc_metric)
                animate_plot(reg,metric_SSD_tot,metric_CC_tot); % GRAPHS
            else
                animate_plot(reg,metric_SSD_tot,metric_MNorm_tot); % GRAPHS
            end
        end
        
        if(use_mnorm_metric)
            if(iter>iters/10)
                if(metric_MNorm<use_mnorm_metric/1000)
                    %if(metric_MNorm_tot(end)<mean(metric_MNorm_tot(end-iter+1:end-iter+ceil(iters/2)+1))*use_mnorm_metric/100)
                    break
                end
            end
        else
            if(iter>iters)
                if(metric_SSD_tot(end)>metric_SSD_tot(end-1))
                    break
                end
            end
        end
        if(iters<=1)
            break
        end
        
    end % End Iterations
    
    if(exist('tmp_quadphase_lsq_normconv','dir')==7)
        rmdir('tmp_quadphase_lsq_normconv','s')
    end
    
    % ELASTIC REGULARISATION
    if(isfield(reg.solid_regularisation,'elastic'))
        disp('Elastic smoothing...')
        % Rescaling seg image
        if(length(reg.elastic.seg)>1)
            eval(['reg.elastic.rescaled_seg = ', reg.resampling.function, ...
                '(reg.elastic.seg,''none'',0,scale,0,orig_size);']);
        else
            reg.elastic.rescaled_seg = reg.elastic.seg;
        end
        % Second regularisation of the field
        [reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty] = regularisation_elastic(reg, reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty, scale);
        for p=1:reg.nb_process
            % Deform prototype
            if(reg.logdomain)
                eval(['reg.process(p).deformed_prototype.data = ', reg.deformation.function, ...
                    '(reg.process(p).prototype.rescaled.data, reg.deformation.boundary, ',...
                    'reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty,''linear'',1);']);
            else
                eval(['reg.process(p).deformed_prototype.data = ', reg.deformation.function, ...
                    '(reg.process(p).prototype.rescaled.data, reg.deformation.boundary, ',...
                    'reg.live.accumulated_deformation_field, reg.live.accumulated_deformation_certainty,''linear'');']);
            end
        end
        % Metric
        if(length(reg.process(p).input.cert)>1)
            metric_SSD = round(sum(sum(sum( (reg.process(1).deformed_prototype.data - reg.process(1).input.rescaled_data).^2 .*(reg.process(p).input.rescaled_cert))))/size(reg.process(1).input.rescaled_data,1)/size(reg.process(1).input.rescaled_data,2)/size(reg.process(1).input.rescaled_data,3)*100)/100;
        else
            metric_SSD = round(sum(sum(sum( (reg.process(1).deformed_prototype.data - reg.process(1).input.rescaled_data).^2 )))/size(reg.process(1).input.rescaled_data,1)/size(reg.process(1).input.rescaled_data,2)/size(reg.process(1).input.rescaled_data,3)*100)/100;
        end
        if(use_cc_metric)
            if(length(reg.process(p).input.cert)>1)
                metric_CC = 1 - sum(sum(sum( (reg.process(1).deformed_prototype.data.*reg.process(1).input.rescaled_data).*(reg.process(p).input.rescaled_cert) )))/sqrt( sum(sum(sum((reg.process(1).deformed_prototype.data.^2).*(reg.process(p).input.rescaled_cert))))*sum(sum(sum((reg.process(1).input.rescaled_data.^2).*(reg.process(p).input.rescaled_cert)))) );
            else
                metric_CC = 1 - sum(sum(sum( reg.process(1).deformed_prototype.data.*reg.process(1).input.rescaled_data )))/sqrt( sum(sum(sum(reg.process(1).deformed_prototype.data.^2)))*sum(sum(sum(reg.process(1).input.rescaled_data.^2))) );
            end
        else
            metric_CC = 0;
        end
        
        if(reg.report)
            fprintf(fid,[num2str(metric_SSD) '\n']);
        end
        if(use_cc_metric)
            disp(['After elastic regularisation  ------------------------->   SSD : ', num2str(metric_SSD),'   and   CC : ', num2str(metric_CC)])
        else
            disp(['After elastic regularisation  ------------------------->   SSD : ', num2str(metric_SSD)])
        end
        metric_SSD_tot = [metric_SSD_tot metric_SSD/(metric_SSD_nrm+eps)];
        metric_CC_tot = [metric_CC_tot metric_CC/(metric_CC_nrm+eps)];
    end
    
    disp( '  ' );
    if(reg.report)
        fprintf(fid,'*******\n \n');
    end
    scale = scale - 1;
    iterations_per_scale = [iterations_per_scale iter];
    
end % End Scales

t = toc;
n = size(reg.process(1).input.data,1)*size(reg.process(1).input.data,2)*size(reg.process(1).input.data,3);
disp(['Processing time was ',num2str(round(t)),' seconds (for registering ',num2str(round(n/1e4)/1e2),' Mega-Voxels images)']);

if(reg.report)
    fprintf(fid,'*****************');
    fclose(fid);
end

end

function animate_plot(reg,metric_SSD_tot,metric_CC_tot)

figure(1),clf;

slc = round(size(reg.process(1).input.rescaled_data, 1)/2);
subplot(2,2,1)
a = squeeze(reg.process(1).input.rescaled_data(slc,:,:));
b = squeeze(reg.process(1).deformed_prototype.data(slc,:,:));
c = squeeze(reg.process(1).prototype.rescaled.data(slc,:,:));
im = [(a-c),c,a;(a-b),b,a];
imagesc(im'), colormap gray
title('Before deformation     -     After deformation')
axis image
axis xy
axis off

subplot(2,2,2)
imagesc(b'), colormap gray
hold on
subsample = zeros(size(a));
subsample([1:ceil(size(a,1)/15):size(a,1)],[1:ceil(size(a,2)/15):size(a,2)])=1;
quiver((squeeze(reg.live.accumulated_deformation_field{1}(slc,:,:)).*subsample)', (squeeze(reg.live.accumulated_deformation_field{3}(slc,:,:)).*subsample)',0,'r');
%quiver((squeeze(displacement_estimate{2}(slc,:,:)).*subsample)', (squeeze(displacement_estimate{3}(slc,:,:)).*subsample)',0,'g');
axis image
axis xy
axis off

if(reg.nb_process>1)
    subplot(2,2,3)
    a = squeeze(reg.process(2).input.rescaled_data(slc,:,:));
    b = squeeze(reg.process(2).deformed_prototype.data(slc,:,:));
    c = squeeze(reg.process(2).prototype.rescaled.data(slc,:,:));
    im = [(a-c),c,a;(a-b),b,a];
    imagesc(im'), colormap gray
    title('Before deformation     -     After deformation')
    axis image
    axis xy
    axis off
    drawnow;
    
    subplot(2,2,4)
    imagesc(b'), colormap gray
    hold on
    subsample = zeros(size(a));
    subsample([1:ceil(size(a,1)/15):size(a,1)],[1:ceil(size(a,2)/15):size(a,2)])=1;
    quiver((squeeze(reg.live.accumulated_deformation_field{1}(slc,:,:)).*subsample)', (squeeze(reg.live.accumulated_deformation_field{3}(slc,:,:)).*subsample)',0,'r');
    %quiver((squeeze(displacement_estimate{2}(slc,:,:)).*subsample)', (squeeze(displacement_estimate{3}(slc,:,:)).*subsample)',0,'g');
    axis image
    axis xy
    axis off
else
    subplot(2,2,3)
    plot(metric_SSD_tot);
    title('SSD (indicator)')
    subplot(2,2,4)
    if(sum(isnan(metric_CC_tot)))
        metric_CC_tot(find(isnan(metric_CC_tot))) = 0;
    end
    if(metric_CC_tot)
        plot(metric_CC_tot);
        title('CC (indicator)')
    else
        imagesc(squeeze(reg.live.accumulated_deformation_certainty(slc,:,:))'), colormap gray
        title('Certainty')
        axis image
        axis xy
        axis off
    end
    
end

drawnow

end
