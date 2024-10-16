%% quadphase_lsq_normconv
% The algorithm used for the non-rigid registration of the mobile image onto the fixed image is the an LSQ-fittted quadrature phase measure (i.e. MORPHON algorithm). See section "3.1.2 Morphon" of reference [1] for more details.
%
%
%% Syntax
% |[out_field, out_cert] = quadphase_lsq_normconv(p, iter)|
%
%
%% Description
% |[out_field, out_cert] = quadphase_lsq_normconv(p, iter)| makes a non-rigid registration of the mobile image onto the fixed image
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
% * ----|reg.process(p).q_in{n}| - _SCALAR MATRIX_ reg.process(p).q_in{n}(x,y,z) Intensity of the voxel (x,y,z) of the rescaled input image |input.rescaled_data| convolved with the quadrature filter kernel |n| for process |p|
% * ----|reg.process(p).displacement_estimation| - _STRUCTURE_ - Structure describing the non rigid registration algorithm to use for the registration process |p|.
% * ---------|reg.process(p).displacement_estimation.data.D2| - _CELL VECTOR_ |kernels{n}| : the quadrature filter kernel |n| for process |p|
%
% |p| - _INTEGER_ -  Number of the process for which the registration is computed.
%
% |iter| - _INTEGER_ - If iteration =1, then the quadrature filter kernels are computed. Otherwise they are not computed and the value from
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
% TODO Where is r(1) defined ? It is called at line 86 but does not seem to be defined before.

function [out_field, out_cert] = quadphase_lsq_normconv(p, iter)

global reg;
if iter==1
    reg.process(p).q_in = cell(size(reg.process(p).q_in));
end

cutborders = 0;
cutborders_2D = 0;

% Set memory limit according to OS 32/64 bits
memory_limit = 64^3;
c = computer;
if(strcmp(c(end-1:end),'64'))
memory_limit = 256^3;
end

% Find quadrature filter responses
dims = reg.process(p).input.dims;
if dims==2
    quads = reg.process(p).displacement_estimation.data.D2;
    acc = 0;
    for n = 1:quads.nquads
        if iter==1
            %disp(['Input, Filter number ', num2str(n), ' of ', num2str(quads.nquads)]);
            if(length(reg.process(p).input.rescaled_cert) == 1) % standard convolution                
                reg.process(p).q_in{n} = conv2(reg.process(p).input.rescaled_data, quads.kernels{n}, 'same');
            else % convolve using certainty = normalised convolution
                [reg.process(p).q_in{n},outcert_im] = my_normconv(reg.process(p).input.rescaled_data, reg.process(p).input.rescaled_cert, quads.kernels{n});
                reg.process(p).q_in{n} = reg.process(p).q_in{n} .* outcert_im; 
            end                
        end
        
        qq = reg.process(p).q_in{n} .* conj(conv2(reg.process(p).deformed_prototype.data, quads.kernels{n}, 'same'));
        
        if cutborders_2D
            qq(1:r(1),:) = 0;
            qq(end-r(1)+1:end,:) = 0;
            qq(:,1:r(2)) = 0;
            qq(:,end-r(2)+1:end) = 0;
        end
        
        if n==1
            img_size = size(qq);

            % Initiate the equation system
            a11 = zeros(img_size);
            a12 = zeros(img_size);
            a22 = zeros(img_size);
            b1  = zeros(img_size);
            b2  = zeros(img_size);
        end

        % This yields sin(phi_a-phi_b) which increases with the phasedifference
        % until it reaches pi/2 where it decreases. This deals with the phase
        % wrap around problem
        vk = imag(qq)./(abs(qq)+eps);

        % It sets the certainty of this estimate to be proportional to the 
        % square root of the filter magnitude. It also sets it to be 
        % proportional to something which decreases with the phase 
        % difference angle
        ck2 = sqrt(abs(qq)).*cos(angle(qq)/2).^4 + eps;
        acc = acc + ck2;

        % Add contributions to the equation system
        a11 = a11 + ck2.*quads.dir{n}(1).*quads.dir{n}(1); % GUIJ: ck2 must be the squared certainty
        a12 = a12 + ck2.*quads.dir{n}(1).*quads.dir{n}(2);
        a22 = a22 + ck2.*quads.dir{n}(2).*quads.dir{n}(2);
        b1  =  b1 + ck2.*quads.dir{n}(1).*vk;
        b2  =  b2 + ck2.*quads.dir{n}(2).*vk;
    end

    % Use trace as certainty
    out_cert = a11 + a22;

    if cutborders_2D
        out_cert(1:r(1),:) = 0;
        out_cert(end-r(1)+1:end,:) = 0;
        out_cert(:,1:r(2)) = 0;
        out_cert(:,end-r(2)+1:end) = 0;
    end
   
    detA = 1./(a11.*a22 - a12.^2);
    z = (detA == 0);
    out_field{1}(z) = 0;
    out_field{2}(z) = 0;
    out_cert(z) = 0;
    
    % What kinds of compensation are needed?
    % 1. Scale - All grids are normalised between 0 and 1
    % 2. Filter centre frequency or preferable some gradient business...
    % If no compensation is performed the displacement will be 1 pixel at 90
    % degrees phase difference.
    eta = 2;
   
    out_field{1} = eta*detA .* (-a12.*b1 + a11.*b2);
    out_field{2} = eta*detA .* ( a22.*b1 - a12.*b2);

elseif dims==3
    file = (numel(reg.process(p).input.rescaled_data)>memory_limit);
    quads = reg.process(p).displacement_estimation.data.D3;
    for n = 1:quads.nquads
        if iter==1
            if(length(reg.process(p).input.rescaled_cert) == 1) % standard convolution
                % Smart swap added by J.A.Lee
                if file
                    tmp = complex(fftconvn(reg.process(p).input.rescaled_data, flipdim(flipdim(flipdim(single(real(quads.kernels{n})),1),2),3)), fftconvn(reg.process(p).input.rescaled_data, flipdim(flipdim(flipdim(single(imag(quads.kernels{n})),1),2),3)));
                else
                    reg.process(p).q_in{n} = complex(fftconvn(reg.process(p).input.rescaled_data, flipdim(flipdim(flipdim(single(real(quads.kernels{n})),1),2),3)), fftconvn(reg.process(p).input.rescaled_data, flipdim(flipdim(flipdim(single(imag(quads.kernels{n})),1),2),3)));
                end
            else
                % Smart swap added by J.A.Lee
                if file
                    [tmp outcert_im] = my_normconv3(reg.process(p).input.rescaled_data, reg.process(p).input.rescaled_cert, single(quads.kernels{n}));
                    tmp = tmp.*outcert_im;
                else
                    [reg.process(p).q_in{n} outcert_im] = my_normconv3(reg.process(p).input.rescaled_data, reg.process(p).input.rescaled_cert, single(quads.kernels{n}));                
                    reg.process(p).q_in{n} = reg.process(p).q_in{n}.*outcert_im;
                end
            end
            % Smart swap added by J.A.Lee
            if file
                if(not(exist('tmp_quadphase_lsq_normconv','dir')==7))
                    mkdir tmp_quadphase_lsq_normconv
                end
                eval(sprintf('save tmp_quadphase_lsq_normconv/q_in%02i.mat tmp;',n));
                clear tmp;
            end
        end
        
        % Smart swap added by J.A.Lee
        if file
            try
                eval(sprintf('load tmp_quadphase_lsq_normconv/q_in%02i.mat;',n));
            catch
                if(exist('tmp_quadphase_lsq_normconv','dir')==7)
                    pwd
                    cd tmp_quadphase_lsq_normconv
                    eval(sprintf('load q_in%02i.mat;',n));
                    cd ..
                else
                    pwd
                    err = lasterror;
                    disp(['    ',err.message]);
                    disp(err.stack(1));
                end                
            end
            qq = tmp .* complex(fftconvn(reg.process(p).deformed_prototype.data, flipdim(flipdim(flipdim(single(real(quads.kernels{n})),1),2),3)), -fftconvn(reg.process(p).deformed_prototype.data, flipdim(flipdim(flipdim(single(imag(quads.kernels{n})),1),2),3)));
            clear tmp;
        else
            qq = reg.process(p).q_in{n} .* complex(fftconvn(reg.process(p).deformed_prototype.data, flipdim(flipdim(flipdim(single(real(quads.kernels{n})),1),2),3)), -fftconvn(reg.process(p).deformed_prototype.data, flipdim(flipdim(flipdim(single(imag(quads.kernels{n})),1),2),3)));
        end
        
        if cutborders
            qq(1:r(1),:,:) = 0;
            qq(end-r(1)+1:end,:,:) = 0;
            qq(:,1:r(2),:) = 0;
            qq(:,end-r(2)+1:end,:) = 0;
        end
        
        % This yields sin(phi_a-phi_b) which increases with the phasedifference
        % until it reaches pi/2 where it decreases. This deals with the phase
        % wrap around problem
        vk = imag(qq)./(abs(qq)+eps('single'));

        % It sets the certainty of this estimate to be proportional to the 
        % square root of the filter magnitude. It also sets it to be 
        % proportional to something which decreases with the phase 
        % difference angle
        ck2 = sqrt(abs(qq)).*cos(vk/2).^4;

        img_size = size(qq);

        % Clear memory
        clear qq;
        
        % Intermediate result
        vk = vk .* ck2;

        if n==1
            % Initiate the equation system; modified by J.A.Lee October 2008
            % (=>single)
            b1  = zeros(img_size,'single');
            a11 = zeros(img_size,'single');
            a12 = zeros(img_size,'single');
            a13 = zeros(img_size,'single');
            b2  = zeros(img_size,'single');
            a22 = zeros(img_size,'single');
            a23 = zeros(img_size,'single');
            b3  = zeros(img_size,'single');
            a33 = zeros(img_size,'single');
        end

        % Create temp vars of type single (added by J.A.Lee October 2008)
        tmp1 = single(quads.dir{n}(1));
        tmp2 = single(quads.dir{n}(2));
        tmp3 = single(quads.dir{n}(3));
        
        % Add contributions to the equation system
        b1  =  b1 + tmp1*     vk;
        a11 = a11 + tmp1*tmp1*ck2;
        a12 = a12 + tmp1*tmp2*ck2;
        a13 = a13 + tmp1*tmp3*ck2;
        b2  =  b2 + tmp2*     vk;
        a22 = a22 + tmp2*tmp2*ck2;
        a23 = a23 + tmp3*tmp2*ck2;
        b3  =  b3 + tmp3*     vk;
        a33 = a33 + tmp3*tmp3*ck2;
        
    end
    
    % Clear memory
    clear vk ck2;
    
    % Mathematica says:
    out_field{1} = (a13.*a23 - a12.*a33).*b1 + (a11.*a33 - a13.^2).*b2 + (a12.*a13 - a11.*a23).*b3;
    out_field{2} = (a22.*a33 - a23.^2).*b1 + (a13.*a23 - a12.*a33).*b2 + (a12.*a23 - a13.*a22).*b3;
    out_field{3} = (a12.*a23 - a13.*a22).*b1 + (a12.*a13 - a11.*a23).*b2 + (a11.*a22 - a12.^2).*b3;
    clear b1 b2 b3;
    detA = a11.*a22.*a33 + 2*a12.*a13.*a23 - a13.^2.*a22 - a11.*a23.^2 - a12.^2.*a33;
    clear a12 a13 a23;

    % Use trace as certainty
    out_cert = a11 + a22 + a33;
    clear a11 a22 a33;

    if cutborders
        out_cert(1:r(1),:,:) = 0;
        out_cert(end-r(1)+1:end,:,:) = 0;
        out_cert(:,1:r(2),:) = 0;
        out_cert(:,end-r(2)+1:end,:) = 0;
        out_cert(:,:,1:r(3)) = 0;
        out_cert(:,:,end-r(3)+1:end) = 0;
    end

    % modified by J.A.Lee October 2008 (logical indexing)
    z = (detA == 0);
    detA(z) = 1;
    out_field{1}(z) = 0;
    out_field{2}(z) = 0;
    out_field{3}(z) = 0;
    out_cert(z) = 0;

    % What kinds of compensation are needed?
    % 1. Scale - All grids are normalised between 0 and 1
    % 2. Filter centre frequency or preferable some gradient business...
    % If no compensation is performed the displacement will be 1 pixel at 90
    % degrees phase difference.
    eta = -1;
    out_field{1} = eta*out_field{1}./detA;
    out_field{2} = eta*out_field{2}./detA;
    out_field{3} = eta*out_field{3}./detA;
    
else
    error ('in quadphase_lsq_norm: only 2D and 3D data are currently supported.')
end


