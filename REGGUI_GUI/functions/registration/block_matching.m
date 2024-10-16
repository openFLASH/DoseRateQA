%% block_matching
% The algorithm used for the non-rigid registration of the mobile image onto the fixed image is block matching with sum of square difference (SSD). See section "3.1.3 Block matching" of reference [1] for more details.
%
%
%% Syntax
% |[out_field, out_cert] = block_matching(p, iter)|
%
%
%% Description
% |[out_field, out_cert] = block_matching(p, iter)| makes a non-rigid registration of the mobile image onto the fixed image
%
%
%% Input arguments
% |global reg| - _STRUCTURE_ - The structure containing the data for the registration. The structure is created by "reg_create.m" and the data to run the live registration is initialised by calling "reg_init.m". The data is inputed into the function "reg_animate.m" via a *global variable* |reg|
% * |reg.process| - _VECTOR STRUCTURE_ - Structure describing each registration process. Length equals to |reg.nb_process|. Each element of the structure describes one of the registration process included in the weighted sum leading to the final deformation field. The structure contains the following fields:
% * ----|reg.process(p).input| - _STRUCTURE_ - Structure describing the fixed image for process |p|. See description in 'reg_input.m'. 
% * ---------|reg.process(p).input.dims| - _SCALAR_ - Number of dimensions of the image
% * ---------|reg.process(p).input.rescaled_data| - _SCALAR MATRIX_ - |rescaled_data(x,y,z)| Intensity at voxel (x,y,z) of the fixed image, resampled to the current scale
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

function [out_field, out_cert] = block_matching(p, iter)

global reg;

dims = reg.process(p).input.dims;
m = reg.process(p).deformed_prototype.data;
f = reg.process(p).input.rescaled_data;

mval = sqrt(mean(mean(mean([f m].*[f m]))));

if(dims == 2)

    new_field(1,:,:) = zeros(size(m),'single');
    new_field(2,:,:) = zeros(size(m),'single');
    new_cert = ones(size(f)+2,'single');

    f_large = zeros(size(f)+2,'single');
    f_large(2:end-1,2:end-1) = f;
    ssd_max = zeros(size(f)+2,'single');
    ssd_max(2:end-1,2:end-1) = (f-m).^2;
    ssd_min = ssd_max;
    new_disp = ones(size(f)+2,'single')*5;
    
    positions = [2 2 2 1 3 1 1 3 3;2 1 3 2 2 1 3 1 3];
    for pos=positions
            m_disp = zeros(size(m)+2,'single');
            m_disp(pos(1):end-3+pos(1),pos(2):end-3+pos(2)) = m;
            ssd = filter2(ones(3,3,'single'),(f_large - m_disp).^2,'same')/9;
            ssd(1:2,:)=Inf;ssd(end-1:end,:)=Inf;ssd(:,1:2)=Inf;ssd(:,end-1:end)=Inf;
            new_disp(find(ssd_min>ssd))=(pos(1)-1)*3+pos(2);  
            % Compute certainty... experimental !!!
            new_cert(find(ssd_min>ssd))= 1 + (sqrt(ssd_max(find(ssd_min>ssd))) + sqrt(ssd_min(find(ssd_min>ssd))) - 2*sqrt(ssd(find(ssd_min>ssd))) )/mval;
            ssd_min = min(ssd_min,ssd);
    end

    new_field_1 = -ones(size(m)+2,'single');
    new_field_2 = -ones(size(m)+2,'single');
    new_field_1(find(new_disp==1 | new_disp==4 | new_disp == 7)) = 1;
    new_field_1(find(new_disp==2 | new_disp==5 | new_disp == 8)) = 0;
    new_field_2(find(new_disp<4)) = 1;
    new_field_2(find(new_disp>3 & new_disp<7)) = 0;

    out_field{1} = new_field_1(2:end-1,2:end-1);
    out_field{2} = new_field_2(2:end-1,2:end-1);    
    out_cert = new_cert(2:end-1,2:end-1);

else
    
    
    new_field(1,:,:,:) = zeros(size(m),'single');
    new_field(2,:,:,:) = zeros(size(m),'single');
    new_field(3,:,:,:) = zeros(size(m),'single');
    new_cert = ones(size(m)+2,'single');

    f_large = zeros(size(f)+2,'single');
    f_large(2:end-1,2:end-1,2:end-1) = f;
    ssd_max = zeros(size(f)+2,'single');
    ssd_max(2:end-1,2:end-1,2:end-1) = (f-m).^2;
    ssd_min = ssd_max;
    new_disp = ones(size(f)+2,'single')*14;
    
    positions = [2,2,2,2,2,1,3,2,2,2,2,1,1,3,3,1,1,3,3,1,1,1,1,3,3,3,3;2,2,2,1,3,2,2,1,1,3,3,2,2,2,2,1,3,1,3,1,1,3,3,1,1,3,3;2,1,3,2,2,2,2,1,3,1,3,1,3,1,3,2,2,2,2,1,3,1,3,1,3,1,3];
    for pos=positions
                m_disp = zeros(size(m)+2,'single');
                m_disp(pos(1):end-3+pos(1),pos(2):end-3+pos(2),pos(3):end-3+pos(3)) = m;
                ssd = conv3f((f_large - m_disp).^2,ones(3,3,3,'single'))/27;
                ssd(1:2,:,:)=Inf;ssd(end-1:end,:,:)=Inf;ssd(:,1:2,:)=Inf;ssd(:,end-1:end,:)=Inf;ssd(:,:,1:2)=Inf;ssd(:,:,end-1:end)=Inf;
                new_disp(find(ssd_min>ssd))=(pos(3)-1)*9+(pos(2)-1)*3+pos(1);
                % Compute certainty... experimental !!!
                new_cert(find(ssd_min>ssd))= 1 + (sqrt(ssd_max(find(ssd_min>ssd))) + sqrt(ssd_min(find(ssd_min>ssd))) - 2*sqrt(ssd(find(ssd_min>ssd))) ) / mval;
                ssd_min = min(ssd_min,ssd);
    end

    new_field_1 = -ones(size(m)+2,'single');
    new_field_2 = -ones(size(m)+2,'single');
    new_field_3 = -ones(size(m)+2,'single');
    
    new_field_1(find(new_disp==1 | new_disp==4 | new_disp == 7 | new_disp==10 | new_disp==13 | new_disp == 16 | new_disp==19 | new_disp==22 | new_disp == 25)) = 1;
    new_field_1(find(new_disp==2 | new_disp==5 | new_disp == 8 | new_disp==11 | new_disp==14 | new_disp == 17 | new_disp==20 | new_disp==23 | new_disp == 26)) = 0; 
    new_field_2(find(new_disp<4 | (new_disp>9 & new_disp<13) | (new_disp>18 & new_disp<22))) = 1;
    new_field_2(find((new_disp>3 & new_disp<7) | (new_disp>12 & new_disp<16) | (new_disp>21 & new_disp<25))) = 0;
    new_field_3(find(new_disp<10)) = 1;
    new_field_3(find(new_disp>9 & new_disp<19)) = 0;

    out_field{1} = new_field_2(2:end-1,2:end-1,2:end-1);
    out_field{2} = new_field_1(2:end-1,2:end-1,2:end-1);
    out_field{3} = new_field_3(2:end-1,2:end-1,2:end-1);    
    out_cert = new_cert(2:end-1,2:end-1,2:end-1);
    
end

