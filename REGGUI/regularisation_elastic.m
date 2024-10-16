%% regularisation_elastic
% Apply an elastic regularisation to the deformation field.
%
% For each voxel of the image, the value of the displacement field is updated by adding to its initial value an increment corresponding to the elastic regularization. This increment is computed as the difference between the field which minimizes the internal forces taking the direct neighbors as border conditions and the field previously computed. For more information, see [1], section 4.2 Improving physical behaviour, section a) Convolutive elastic filtering
%
% Then, anisotropy is added to the displacement field in order to reduce the effect of smoothing where the registration is supposed to behave correctly (i.e. in heterogeneous regions). The anisotropy coefficient is proportional to the deformation field gradiant |G=diff(reff)| so that |Gx*K/(mean(G)).^A|. The same equation is applied to Gy and Gz (the component of the deformation field gradient in x,y,z).
% See section "4.2.3 Iterative elastic filtering", sub section "b) Anisotropy" of reference [1] for more information.
%
% In case of  inhomogeneous spatial influence, a segmentation mask is defined for the image. See section "4.4 Sliding surfaces" of reference [1] for more information.
%
%% Syntax
% |[out_field, out_cert] = regularisation_elastic(reg, in_field, in_cert, scale, data)|
%
%
%% Description
% |[out_field, out_cert] = regularisation_elastic(reg, in_field, in_cert, scale, data)| describes the function
%
%% Input arguments
%
% |reg|  - _STRUCTURE_ - The structure containing the data for the registration. The structure is created by "reg_create.m" and the data to run the live registration.
%
% * |reg.process(1).input.rescaled_data| - _MATRIX_ - The RESCALED fixed image for process |p|. |rescaled_data(x,y,z)| is the intensity of the rescaled image at voxel (x,y,z)
%
% * |reg.dims| - _INTEGER_ - Number of dimensions of the input image
%
% * |reg.spacing| - _VECTOR of SCALAR_ - Size (x,y,z) (in |mm|) of the pixels in the images.
%
% * |reg.live| - _STRUCTURE_ Data defining the current state of the live registration process.
% * ----- |reg.live.accumulated_deformation_field| - _CELL VECTOR of MATRICES_ accumulated_deformation_field{1}(x,y,z) is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. The number ofcell  elements is equal to |reg.dims|.
%
% * |reg.elastic| - _STRUCTURE_ Data structure to use for the elastic regularization. Used only if elastic regularizations are performed
% * ----|reg.elastic.data| - _MATRIX_ - with the following definition:
% * ------|reg.elastic.data|(1,s) - _VECTOR of INTEGER_ - Number of iterations of regularization to run at the scale |s|
% * ------|reg.elastic.data|(2,s) - _VECTOR of SCALR_ - Coefficient K of the anisotropy coefficient for the scale |s|
% * ------|reg.elastic.data|(3,s) - _VECTOR of SCALR_ - Exponent A of the anisotropy coefficient for scale |s|
% * ----|reg.elastic.rescaled_seg| - _MATRIX of SCALAR_ - rescaled segmentation mask for inhomogeneous spatial fluence. |seg(x,y,z) = j| (with j< 1) indicates that the voxel (x,y,z) of the image belongs to structure number j. 
%
% |in_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}.
%
% |in_cert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |scale| - _INTEGER_ -  Scale of the current deformable registration process. With |scale <= length(reg.elastic.data(1,:))|. The definition of the scale is given in the resampler function "standard_resampler".
%
% |data| - Not used
%
%% Output arguments
%
% |out_field|  - _CELL VECTOR of MATRICES_ accumulated_deformation_field{1}(x,y,z) is X component of the *regularised* deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}.
%
% |out_cert| - _MATRICE_ Certainty about the value of the *regularised* deformation field at voxel (x,y,z) for the current iteration. 
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
% [2] G. Janssens, J. O. de Xivry, H. J. W. Aerts, G. Bosmans, A. L. A. Dekker and B. Macq. Improving physical behavior in image registration. In Proc. 15th IEEE International Conference on Image Processing ICIP 2008, pp. 2952–2955, 12–15 Oct. 2008.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [out_field, out_cert] = regularisation_elastic(reg, in_field, in_cert, scale, data)

dims = reg.dims;

if(dims==2) %% 2D %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if(size(reg.elastic.data,2)>1 & size(reg.elastic.data,1)>2)
            it = reg.elastic.data(1,scale+1);
            K = reg.elastic.data(2,scale+1);
            anisotrop = reg.elastic.data(3,scale+1);
        else
            disp('Warning : number of iterations and K fixed !')
            it = 1;
            K = 100;
            anisotrop = 1;
        end

        ref = reg.process(1).input.rescaled_data;
        seg = reg.elastic.rescaled_seg;
        old_field = zeros([2,size(reg.live.accumulated_deformation_field{1})],'single');
        new_field = zeros([2,size(reg.live.accumulated_deformation_field{1})],'single');

        old_field(1,:,:) = in_field{2};
        old_field(2,:,:) = in_field{1};

        [new_field,Di_ref] = elastic_smoother(old_field,it,K,anisotrop,ref,seg,dims,reg.spacing);

        out_field{1} = squeeze(new_field(2,:,:));
        out_field{2} = squeeze(new_field(1,:,:));

        out_cert = mean(mean(in_cert)) * ( ( ones(size(in_cert))/2 + (1 - squeeze(Di_ref(2,:,:))/max(max(squeeze(Di_ref(2,:,:)))))/2 )/2 + ( ones(size(in_cert))/2 + (1 - squeeze(Di_ref(1,:,:))/max(max(squeeze(Di_ref(1,:,:)))))/2 )/2);


else %% 3D %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
        if(size(reg.elastic.data,2)>1 & size(reg.elastic.data,1)>2)
            it = reg.elastic.data(1,scale+1);
            K = reg.elastic.data(2,scale+1);
            anisotrop = reg.elastic.data(3,scale+1);
        else
            disp('Warning : number of iterations and K fixed !')
            it = 1;
            K = 100;
            anisotrop = 1;
        end
        
        if(it)

        ref = reg.process(1).input.rescaled_data;
        seg = reg.elastic.rescaled_seg;
        
        field = zeros([3,size(reg.live.accumulated_deformation_field{1})],'single');

        field(1,:,:,:) = in_field{2};
        field(2,:,:,:) = in_field{1};
        field(3,:,:,:) = in_field{3};

        [field,Di_ref] = Elastic_smoother(field,it,K,anisotrop,ref,seg,dims,reg.spacing);

        out_field{1} = squeeze(field(2,:,:,:));
        out_field{2} = squeeze(field(1,:,:,:));
        out_field{3} = squeeze(field(3,:,:,:));

        out_cert = (mean(mean(mean(in_cert)))+max(max(max(in_cert))))/2 * single(seg~=0).*( ( ones(size(in_cert))/2 + (1 - squeeze(Di_ref(2,:,:,:))/max(max(max(squeeze(Di_ref(2,:,:,:))))))/2 )/3 + ( ones(size(in_cert))/2 + (1 - squeeze(Di_ref(1,:,:,:))/max(max(max(squeeze(Di_ref(1,:,:,:))))))/2 )/3 + ( ones(size(in_cert))/2 + (1 - squeeze(Di_ref(3,:,:,:))/max(max(max(squeeze(Di_ref(3,:,:,:))))))/2 )/3);
        out_cert(find(seg==0))=(mean(mean(mean(in_cert)))+min(min(min(in_cert))))/2;
        
        else
           
            out_field = in_field;
            out_cert = in_cert;
            
        end
        
end
