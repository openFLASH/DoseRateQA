%% regularisation_normgauss_discontinuous
% Performs normalised discontinuous gaussian smoothing of the deformation/displacement field. The image is multiplied by the certainty map before the convolution with the gaussian kernel. The convolved image is then normalised by the certainty map smoothed by the gaussian kernel:
% |out_cert = conv(in_field .* in_cert , gauss) ./ conv(in_cert , gauss)
%
% The discountinuous smoothing is described in section "4.4 Sliding surfaces" of reference [1]
%
%% Syntax
% |[out_field, out_cert] = regularisation_normgauss_discontinuous(proc, in_field, in_cert, scale, data)|
%
%
%% Description
% |[out_field, out_cert] = regularisation_normgauss_discontinuous(proc, in_field, in_cert, scale, data)| Performs gaussian smoothing of the deformation/displacement field
%
%
%% Input arguments
%
% |proc| - _STRUCTURE_ Structure describing each registration process. The function accepts structure with the format |proc.input| or |proc.process(1).input|. The |input| must then contain the following fields:
% * ----|input.rescaled_mask| - _MATRIX_ - |rescaled_mask(x,y,z)| defines whether the voxel (x,y,z) belongs (1) or not (0) to the smoothed region.
% * ----|input.rescaled_grad{n}| - _CELL VECTOR of MATRICES_ |rescaled_grad{1}(x,y,z)| is the X component of the normalized gradient (rescaled to match the pixel spacing of the current scaling). The Y and Z components are defined in cell components {2} and {3}.
%
% |in_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the previous deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}.
%
% |in_cert|  - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |scale| - _INTEGER_ -  Scale of the current deformable registration process. The definition of the scale is given in the resampler function "standard_resampler".
%
% |data| - _VECTOR of SCALAR_ - |data(s)| Standard deviation (inpixels) of the gaussian kernel for scale s. If |data|=SCALAR, then the same sigma is used for all scales.
%
%
%% Output arguments
%
% |out_field| - _CELL VECTOR of MATRICES_ |acc_field{1}(x,y,z)| is X component of the accumulated deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
% |out_cert|  - _MATRICE_ - Regularized certainty map of the field.
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [out_field, out_cert] = regularisation_normgauss_discontinuous(proc, in_field, in_cert, scale, data)
% function [out_field, out_cert] =
% regularisation_normgauss_discontinuous(proc, in_field, in_cert, scale)

dims = ndims(in_field{1});

if(size(data,2)>1)
    sigma_mod = data(1,scale+1);
else
    sigma_mod = data(1);
end

if(isfield(proc,'input'))
    input = proc.input;
else
    input = proc.process(1).input;
end

if(ndims(input.rescaled_mask) > 1)

    disp('Performing discontinuous smoothing...')

    out_cert = normgauss_smoothing(in_cert, in_cert, sigma_mod);

    fn = in_field;
    ft = in_field;
    scalar_prod = 0;
    for n = 1:dims
        scalar_prod = scalar_prod + in_field{n}.*input.rescaled_grad{n};
    end

    for n = 1:dims
        fn{n} = input.rescaled_grad{n}.*scalar_prod;
        ft{n} = in_field{n} - fn{n};
    end

    for n = 1:dims
        out_field{n} = normgauss_smoothing(fn{n}, in_cert, sigma_mod);
    end

    cert_mask = in_cert.*(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2);
    cert_mask_c = in_cert - cert_mask;

    for n = 1:dims
        out_field{n} = out_field{n} + normgauss_smoothing(ft{n}, cert_mask, sigma_mod).*(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2) + normgauss_smoothing(ft{n}, cert_mask_c, sigma_mod).*not(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2);
    end

    % Removal of the gaps (for 3D images only)

    if(dims==3)

        myStrel = ones(3,3,3);
        myOutsideContour = imdilate(input.rescaled_mask,myStrel)-input.rescaled_mask;
        myInsideContour = input.rescaled_mask-imerode(input.rescaled_mask,myStrel);

        [ini intemp] = find(myInsideContour);
        [inj ink] = ind2sub([size(myInsideContour,2) size(myInsideContour,3)],intemp);
        incont_pts = double(ini + out_field{2}(sub2ind(size(input.rescaled_mask),ini,inj,ink)));
        incont_pts(:,2) = inj + out_field{1}(sub2ind(size(input.rescaled_mask),ini,inj,ink));
        incont_pts(:,3) = ink + out_field{3}(sub2ind(size(input.rescaled_mask),ini,inj,ink));

        [outi outtemp] = find(myOutsideContour);
        [outj outk] = ind2sub([size(myOutsideContour,2) size(myOutsideContour,3)],outtemp);
        outcont_pts = double(outi + out_field{2}(sub2ind(size(input.rescaled_mask),outi,outj,outk)));
        outcont_pts(:,2) = outj + out_field{1}(sub2ind(size(input.rescaled_mask),outi,outj,outk));
        outcont_pts(:,3) = outk + out_field{3}(sub2ind(size(input.rescaled_mask),outi,outj,outk));

        inT = delaunayn(incont_pts);
        outT = delaunayn(outcont_pts);

        [inNP inD] = dsearchn(outcont_pts,outT,incont_pts);
        [outNP outD] = dsearchn(incont_pts,inT,outcont_pts);
        
        min_dist = max(4/(2^(scale/2)),3);        
      
        if(max(inD)>min_dist+1 || max(outD)>min_dist+1)

            disp(['Maximum distances between surfaces (in voxels) : ', num2str(max(inD)), ' and ', num2str(max(outD)) ' -> Enforcing surface matching...']);

            correction_in = ((outcont_pts(inNP,:)+incont_pts)/2-[ini inj ink]);
            correction_in = correction_in(:,[2 1 3]);
            correction_out = ((incont_pts(outNP,:)+outcont_pts)/2-[outi outj outk]);
            correction_out = correction_out(:,[2 1 3]);

            norm_in = sum(out_field{1}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).^2+out_field{2}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).^2+out_field{3}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).^2,2);
            norm_out = sum(out_field{1}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).^2+out_field{2}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).^2+out_field{3}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).^2,2);

            for n = 1:dims
                correction_in(:,n) = correction_in(:,n)+input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),ini,inj,ink));
                out_field{n}(sub2ind(size(input.rescaled_mask),ini,inj,ink)) = (correction_in(:,n).*(inD>min_dist))+(out_field{n}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).*not(inD>min_dist));
                correction_out(:,n) = correction_out(:,n)-input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),outi,outj,outk));
                out_field{n}(sub2ind(size(input.rescaled_mask),outi,outj,outk)) = (correction_out(:,n).*(outD>min_dist))+(out_field{n}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).*not(outD>min_dist));
            end
            
            coef_sliding = 10;

            mask1 = abs(input.rescaled_dm.*input.rescaled_mask)/max(max(max(abs(input.rescaled_dm.*input.rescaled_mask))));
            cert_on_border_in = single(inD).*single(inD).*norm_in.*norm_in;
            mask1(sub2ind(size(input.rescaled_mask),ini,inj,ink)) = cert_on_border_in/max(max(max(cert_on_border_in)))*coef_sliding;
            mask2 = abs(input.rescaled_dm.*not(input.rescaled_mask))/max(max(max(abs(input.rescaled_dm.*not(input.rescaled_mask)))));
            cert_on_border_out = single(outD).*single(outD).*norm_out.*norm_out;
            mask2(sub2ind(size(input.rescaled_mask),outi,outj,outk)) = cert_on_border_out/max(max(max(cert_on_border_out)))*coef_sliding;

            for n = 1:dims
                out_field{n} = normgauss_smoothing(out_field{n}, mask1, sigma_mod).*(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2) + normgauss_smoothing(out_field{n}, mask2, sigma_mod).*not(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2);
            end
            out_cert = out_cert.*mask1+out_cert.*mask2;
        end        
        
    end






% disp('Performing tissue-dependent smoothing...')
% 
%     out_cert = normgauss_smoothing(in_cert, in_cert, sigma_mod);
%     out_cert(input.rescaled_mask>0) = mean(mean(mean(out_cert)));
%     
%     out_field = in_field;
% 
%     for n = 1:dims
%         out_field{n}(input.rescaled_mask>0) = sign(out_field{n}(input.rescaled_mask>0)).*min(abs(out_field{n}(input.rescaled_mask>0)),1.5);
%         out_field{n} = normgauss_smoothing(out_field{n}, in_cert, sigma_mod);
%     end   




    


%                 for n = 1:dims
%             temp(:,:,:,n)=out_field{n};
%         end
%         jacobian = field_jacobian(temp,single([1;1;1]));
%
%         disp(['Minimum jacobian determinant = ', num2str(min(min(min(jacobian))))]);
%
%         (min(min(min(jacobian)))<0)
%
%             disp(['Minimum jacobian determinant = ', num2str(min(min(min(jacobian)))), ' -> Enforcing surface matching...']);
%
%             myStrel = ones(3,3,3);
%
%             jacobian = imdilate(jacobian<0,myStrel);
%
%             myOutsideContour = imdilate(input.rescaled_mask,myStrel)-input.rescaled_mask;
%             myInsideContour = input.rescaled_mask-imerode(input.rescaled_mask,myStrel);
%             myOutsideContour_J = myOutsideContour & jacobian;
%             myInsideContour_J = myInsideContour & jacobian;
%
%             [ini intemp] = find(myInsideContour);
%             [inj ink] = ind2sub([size(myInsideContour,2) size(myInsideContour,3)],intemp);
%             incont_pts = double(ini + out_field{2}(sub2ind(size(input.rescaled_mask),ini,inj,ink)));
%             incont_pts(:,2) = inj + out_field{1}(sub2ind(size(input.rescaled_mask),ini,inj,ink));
%             incont_pts(:,3) = ink + out_field{3}(sub2ind(size(input.rescaled_mask),ini,inj,ink));
%
%             [outi outtemp] = find(myOutsideContour);
%             [outj outk] = ind2sub([size(myOutsideContour,2) size(myOutsideContour,3)],outtemp);
%             outcont_pts = double(outi + out_field{2}(sub2ind(size(input.rescaled_mask),outi,outj,outk)));
%             outcont_pts(:,2) = outj + out_field{1}(sub2ind(size(input.rescaled_mask),outi,outj,outk));
%             outcont_pts(:,3) = outk + out_field{3}(sub2ind(size(input.rescaled_mask),outi,outj,outk));
%
%             [ini_J intemp] = find(myInsideContour_J);
%             [inj_J ink_J] = ind2sub([size(myInsideContour_J,2) size(myInsideContour_J,3)],intemp);
%             incont_pts_J = double(ini_J + out_field{2}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J)));
%             incont_pts_J(:,2) = inj_J + out_field{1}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J));
%             incont_pts_J(:,3) = ink_J + out_field{3}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J));
%
%             [outi_J outtemp] = find(myOutsideContour_J);
%             [outj_J outk_J] = ind2sub([size(myOutsideContour_J,2) size(myOutsideContour_J,3)],outtemp);
%             outcont_pts_J = double(outi_J + out_field{2}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J)));
%             outcont_pts_J(:,2) = outj_J + out_field{1}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J));
%             outcont_pts_J(:,3) = outk_J + out_field{3}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J));
%
%             inT = delaunayn(incont_pts);
%             outT = delaunayn(outcont_pts);
%
%             [inNP inD] = dsearchn(outcont_pts,outT,incont_pts_J);
%             [outNP outD] = dsearchn(incont_pts,inT,outcont_pts_J);
%
%             %             min_dist = 3;
%             %             if(max(inD)>min_dist+1 || max(outD)>min_dist+1)
%             %                 disp(['Maximum distances between surfaces (in voxels) : ', num2str(max(inD)), ' and ', num2str(max(outD)) ' -> Enforcing surface matching...']);
%
%             correction_in = ((outcont_pts(inNP,:)+incont_pts_J)/2-[ini_J inj_J ink_J]);
%             correction_in = correction_in(:,[2 1 3]);
%             correction_out = ((incont_pts(outNP,:)+outcont_pts_J)/2-[outi_J outj_J outk_J]);
%             correction_out = correction_out(:,[2 1 3]);
%
%             norm_in = sum(out_field{1}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J)).^2+out_field{2}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J)).^2+out_field{3}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J)).^2,2);
%             norm_out = sum(out_field{1}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J)).^2+out_field{2}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J)).^2+out_field{3}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J)).^2,2);
%
%             for n = 1:dims
%                 out_field{n}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J)) = correction_in(:,n)+input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J))/2;
%                 out_field{n}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J)) = correction_out(:,n)-input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J))/2;
%             end
%
%             mask1 = abs(input.rescaled_dm.*input.rescaled_mask)/(max(max(max(abs(input.rescaled_dm.*input.rescaled_mask))))+eps);
%             cert_on_border_in = single(inD).*single(inD).*norm_in.*norm_in;
%             mask1(sub2ind(size(input.rescaled_mask),ini_J,inj_J,ink_J)) = cert_on_border_in/(max(max(max(cert_on_border_in)))*100+eps);
%             mask2 = abs(input.rescaled_dm.*not(input.rescaled_mask))/(max(max(max(abs(input.rescaled_dm.*not(input.rescaled_mask)))))+eps);
%             cert_on_border_out = single(outD).*single(outD).*norm_out.*norm_out;
%             mask2(sub2ind(size(input.rescaled_mask),outi_J,outj_J,outk_J)) = cert_on_border_out/(max(max(max(cert_on_border_out)))*100+eps);
%
%             for n = 1:dims
%                 out_field{n} = normgauss_smoothing(out_field{n}, mask1, sigma_mod).*(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2) + normgauss_smoothing(out_field{n}, mask2, sigma_mod).*not(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2);
%             end
%             out_cert = out_cert.*mask1+out_cert.*mask2;
%
%             %             end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     if(0)
%
%         if(dims==2)
%
%             myStrel = strel('square',3);
%             myOutsideContour = imdilate(input.rescaled_mask,myStrel)-input.rescaled_mask;
%             myInsideContour = input.rescaled_mask-imerode(input.rescaled_mask,myStrel);
%
%             [ini inj] = find(myInsideContour);
%             incont_pts(:,1) = ini + out_field{2}(sub2ind(size(input.rescaled_mask),ini,inj))';
%             incont_pts(:,2) = inj + out_field{1}(sub2ind(size(input.rescaled_mask),ini,inj))';
%
%             [outi outj] = find(myOutsideContour);
%             outcont_pts(:,1) = outi + out_field{2}(sub2ind(size(input.rescaled_mask),outi,outj))';
%             outcont_pts(:,2) = outj + out_field{1}(sub2ind(size(input.rescaled_mask),outi,outj))';
%
%             inT = delaunayn(incont_pts);
%             outT = delaunayn(outcont_pts);
%
%             [inNP inD] = dsearchn(outcont_pts,outT,incont_pts);
%             [outNP outD] = dsearchn(incont_pts,inT,outcont_pts);
%
%             correction_in = ((outcont_pts(inNP,:)+incont_pts)/2-[ini inj]);
%             correction_in = correction_in(:,[2 1]);
%             correction_out = ((incont_pts(outNP,:)+outcont_pts)/2-[outi outj]);
%             correction_out = correction_out(:,[2 1]);
%
%             for n = 1:dims
%                 out_field{n}(sub2ind(size(input.rescaled_mask),ini,inj)) = correction_in(:,n)+input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),ini,inj))/2;
%                 out_field{n}(sub2ind(size(input.rescaled_mask),outi,outj)) = correction_out(:,n)-input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),outi,outj))/2;
%             end
%
%             mask1 = abs(distmap.*input.rescaled_mask)/max(max(max(abs(distmap.*input.rescaled_mask))));
%             mask1(sub2ind(size(input.rescaled_mask),ini,inj)) = inD/max(max(max(abs(distmap.*input.rescaled_mask))))*50;
%             mask2 = abs(distmap.*not(input.rescaled_mask))/max(max(max(abs(distmap.*not(input.rescaled_mask)))));
%             mask2(sub2ind(size(input.rescaled_mask),outi,outj)) = outD/max(max(max(abs(distmap.*input.rescaled_mask))))*50;
%
%             for n = 1:dims
%                 out_field{n} = normgauss_smoothing(out_field{n}, mask1, sigma_mod).*(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2) + normgauss_smoothing(out_field{n}, mask2, sigma_mod).*not(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2);
%             end
%
%         elseif(dims==3)
%
%             myStrel = ones(3,3,3);
%             myOutsideContour = imdilate(input.rescaled_mask,myStrel)-input.rescaled_mask;
%             myInsideContour = input.rescaled_mask-imerode(input.rescaled_mask,myStrel);
%
%             [ini intemp] = find(myInsideContour);
%             [inj ink] = ind2sub([size(myInsideContour,2) size(myInsideContour,3)],intemp);
%             incont_pts = double(ini + out_field{2}(sub2ind(size(input.rescaled_mask),ini,inj,ink)));
%             incont_pts(:,2) = inj + out_field{1}(sub2ind(size(input.rescaled_mask),ini,inj,ink));
%             incont_pts(:,3) = ink + out_field{3}(sub2ind(size(input.rescaled_mask),ini,inj,ink));
%
%             [outi outtemp] = find(myOutsideContour);
%             [outj outk] = ind2sub([size(myOutsideContour,2) size(myOutsideContour,3)],outtemp);
%             outcont_pts = double(outi + out_field{2}(sub2ind(size(input.rescaled_mask),outi,outj,outk)));
%             outcont_pts(:,2) = outj + out_field{1}(sub2ind(size(input.rescaled_mask),outi,outj,outk));
%             outcont_pts(:,3) = outk + out_field{3}(sub2ind(size(input.rescaled_mask),outi,outj,outk));
%
%             inT = delaunayn(incont_pts);
%             outT = delaunayn(outcont_pts);
%
%             [inNP inD] = dsearchn(outcont_pts,outT,incont_pts);
%             [outNP outD] = dsearchn(incont_pts,inT,outcont_pts);
%
%             min_dist = 3;
%
%             if(max(inD)>min_dist+1 || max(outD)>min_dist+1)
%
%                 disp(['Maximum distances between surfaces (in voxels) : ', num2str(max(inD)), ' and ', num2str(max(outD)) ' -> Enforcing surface matching...']);
%
%                 correction_in = ((outcont_pts(inNP,:)+incont_pts)/2-[ini inj ink]);
%                 correction_in = correction_in(:,[2 1 3]);
%                 correction_out = ((incont_pts(outNP,:)+outcont_pts)/2-[outi outj outk]);
%                 correction_out = correction_out(:,[2 1 3]);
%
%                 norm_in = sum(out_field{1}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).^2+out_field{2}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).^2+out_field{3}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).^2,2);
%                 norm_out = sum(out_field{1}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).^2+out_field{2}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).^2+out_field{3}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).^2,2);
%
%                 for n = 1:dims
%                     correction_in(:,n) = correction_in(:,n)+input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),ini,inj,ink))/2;
%                     out_field{n}(sub2ind(size(input.rescaled_mask),ini,inj,ink)) = (correction_in(:,n).*(inD>min_dist))+(out_field{n}(sub2ind(size(input.rescaled_mask),ini,inj,ink)).*not(inD>min_dist));
%                     correction_out(:,n) = correction_out(:,n)-input.rescaled_grad{n}(sub2ind(size(input.rescaled_mask),outi,outj,outk))/2;
%                     out_field{n}(sub2ind(size(input.rescaled_mask),outi,outj,outk)) = (correction_out(:,n).*(outD>min_dist))+(out_field{n}(sub2ind(size(input.rescaled_mask),outi,outj,outk)).*not(outD>min_dist));
%                 end
%
%                 mask1 = abs(input.rescaled_dm.*input.rescaled_mask)/max(max(max(abs(input.rescaled_dm.*input.rescaled_mask))));
%                 cert_on_border_in = single(inD).*single(inD).*norm_in.*norm_in;
%                 mask1(sub2ind(size(input.rescaled_mask),ini,inj,ink)) = cert_on_border_in/max(max(max(cert_on_border_in)))*10;
%                 mask2 = abs(input.rescaled_dm.*not(input.rescaled_mask))/max(max(max(abs(input.rescaled_dm.*not(input.rescaled_mask)))));
%                 cert_on_border_out = single(outD).*single(outD).*norm_out.*norm_out;
%                 mask2(sub2ind(size(input.rescaled_mask),outi,outj,outk)) = cert_on_border_out/max(max(max(cert_on_border_out)))*10;
%
%                 for n = 1:dims
%                     out_field{n} = normgauss_smoothing(out_field{n}, mask1, sigma_mod).*(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2) + normgauss_smoothing(out_field{n}, mask2, sigma_mod).*not(input.rescaled_mask>=max(max(max(input.rescaled_mask)))/2);
%                 end
%                 out_cert = out_cert.*mask1+out_cert.*mask2;
%             end
%         end
%     end


else
    disp('Warning : No mask found. Performing conventional gaussian smoothing');
    for n = 1:dims
        out_field{n} = normgauss_smoothing(in_field{n}, in_cert, sigma_mod);
    end
    out_cert = normgauss_smoothing(in_cert, in_cert, sigma_mod);

end

