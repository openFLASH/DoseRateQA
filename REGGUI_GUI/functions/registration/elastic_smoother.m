%% elastic_smoother
% The deformation field is regularized by convolution with an eleastic convolution filter. See section "4.2.3 Iterative elastic filtering" of reference [1] for more information. The image is divided in regions with different Poisson ratio.
%
% Then, anisotropy is added to the displacement field in order to reduce the effect of smoothing where the registration is supposed to behave correctly (i.e. in heterogeneous regions). The anisotropy correction |Di_ref| is proportional to the deformation field gradiant |G=diff(reff)| so that |Di_ref = G*K/(mean(G)).^anisotrop|. To compute the regularised field |v_reg|, the deformation |v_update| introduced by the elastic convolution is corrected by the anysotrpy correction according to:  |v_reg = v_reg.*(Di_ref+1)./(Di_ref+2) + v_update./(Di_ref+2)|.
% See section "4.2.3 Iterative elastic filtering", sub section "b) Anisotropy" of reference [1] for more information.
%
% In case of  inhomogeneous spatial influence, a segmentation mask is defined for the image. See section "4.4 Sliding surfaces" of reference [1] for more information.
%
%% Syntax
% |[v_reg,Di_ref] = elastic_smoother(v,it,K,anisotrop,ref,seg,dims,spacing)|
%
%% Description
% |[v_reg,Di_ref] = elastic_smoother(v,it,K,anisotrop,ref,seg,dims,spacing)| describes the function
%
%% Input arguments
% |v| - _MATRIX of SCALAR_ |v(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |v(2,x,y,z)| and |v(3,x,y,z)|.
%
% |it| - _INTEGER VECTOR_ -  Number of iterations of convolutions applied iteratively to make the displacement field converge to the linear elastic solution
%
% |K| - _SCALAR_ -  Anisotropy parameter. Coefficient of the anisotropy coefficient.
%
% |anisotrop| - _SCALAR_ -  Anisotropy parameter. Exponent of the anisotropy coefficient.
%
% |ref|  - _STRUCTURE_ - Structure describing the RESCALED fixed image. |ref(x,y,z)| is the intensity of the rescaled image at voxel (x,y,z). This is used to compute the gradients |G=diff(reff)|
%
% |seg| - _MATRIX of SCALAR_ - |seg(x,y,z)| is the Poisson ratio (nu) of the voxel (x,y,z). Poisson’s ratio. Poisson’s ratio |nu| takes a value in the interval ]− 1; 0.5[ (0.5 corresponds to incompressible materials, 0 to completely compressible materials and negative values correspond to auxetic materials)
%
% |dims| - _INTEGER_ - Number of dimensions of the image
%
% |spacing| - _VECTOR of SCALAR_ - Size (x,y,z) (in |mm|) of the pixels in the images.
%
%
%% Output arguments
%
% |v_reg| - _MATRIX of SCALAR_ |v_reg(1,x,y,z)| is X component of the REGULARIZED deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |v_reg(2,x,y,z)| and |v_reg(3,x,y,z)|
%
% |Di_ref| - _MATRIX of SCALAR_ |v_reg(1,x,y,z)| is X component of the anisotropy correction at the voxel (x,y,z). The Y and Z components are defined in matrix components |v_reg(2,x,y,z)| and |v_reg(3,x,y,z)|
%
%% Reference
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
% [2] G. Janssens, J. O. de Xivry, H. J. W. Aerts, G. Bosmans, A. L. A. Dekker and B. Macq. Improving physical behavior in image registration. In Proc. 15th IEEE International Conference on Image Processing ICIP 2008, pp. 2952–2955, 12–15 Oct. 2008.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [v_reg,Di_ref] = elastic_smoother(v,it,K,anisotrop,ref,seg,dims,spacing)

v_reg = v;

if(dims==2)

    if( (ndims(v)-1 )~=dims || ndims(ref)~=dims )
        disp('Inputs are not 2D !!')
        disp('Size of input field : ')
        disp(size(v))
        disp('Size of reference image : ')
        disp(size(ref))
    end

    disp('Warning : 2D elastic smoothing implemented for homogeneous material images only');

    Di_ref = zeros([0,size(ref)],'single');

    for i=1:it

        v_update = v_reg;

        for(j=2:size(v,2)-1)
            for pix=2:size(v,3)-1

                if (size(ref,1)==size(v,2) & size(ref,2)==size(v,3))
                    Di_f_ref_x = (ref(j+1,pix)-ref(j,pix));
                    Di_b_ref_x = (ref(j,pix)-ref(j-1,pix));
                    Di_f_ref_y = (ref(j,pix+1)-ref(j,pix));
                    Di_b_ref_y = (ref(j,pix)-ref(j,pix-1));
                    Di_ref(1,j,pix) = max(abs(Di_f_ref_x),abs(Di_b_ref_x));
                    Di_ref(2,j,pix) = max(abs(Di_f_ref_y),abs(Di_b_ref_y));
                else
                    disp('Error : reference image do not have the good size !!')
                end

                if(size(seg)==size(ref))
                    nu = seg(j,pix);
                else
                    nu = seg;
                end
                v_update(:,j,pix) = Solver_const([v_reg(1,j+1,pix+1),v_reg(1,j,pix+1),v_reg(1,j-1,pix+1),v_reg(1,j-1,pix),v_reg(1,j-1,pix-1),v_reg(1,j,pix-1),v_reg(1,j+1,pix-1),v_reg(1,j+1,pix),v_reg(1,j,pix),...
                    v_reg(2,j+1,pix+1),v_reg(2,j,pix+1),v_reg(2,j-1,pix+1),v_reg(2,j-1,pix),v_reg(2,j-1,pix-1),v_reg(2,j,pix-1),v_reg(2,j+1,pix-1),v_reg(2,j+1,pix),v_reg(2,j,pix)]',nu);
            end
        end

        Di_ref = abs(Di_ref*K/(mean(mean(mean(([Di_ref])))))).^anisotrop;

        v_reg = v_reg.*(Di_ref+1)./(Di_ref+2) + v_update./(Di_ref+2);

    end

end

if(dims==3)

    if( (ndims(v)-1)~=dims | ndims(ref)~=dims )
        disp('Inputs are not 3D !!')
        disp('Size of input field : ')
        disp(size(v))
        disp('Size of reference image : ')
        disp(size(ref))
    end

    Gx = zeros(size(ref),'single');
    Gx(2:end,:,:) = abs(diff(ref,1,1));
    Gx(1:end-1,:,:) = max(Gx(1:end-1,:,:),abs(diff(ref,1,1)));

    Gy = zeros(size(ref),'single');
    Gy(:,2:end,:) = abs(diff(ref,1,2));
    Gy(:,1:end-1,:) = max(Gy(:,1:end-1,:),abs(diff(ref,1,2)));

    Gz = zeros(size(ref),'single');
    Gz(:,:,2:end) = abs(diff(ref,1,3));
    Gz(:,:,1:end-1) = max(Gz(:,:,1:end-1),abs(diff(ref,1,3)));

    % For anisotropism as a function of the gradient direction
    Di_ref(1,:,:,:) = abs(Gx*K/(mean(mean(mean([Gx Gy Gz]))))).^anisotrop;
    Di_ref(2,:,:,:) = abs(Gy*K/(mean(mean(mean([Gx Gy Gz]))))).^anisotrop;
    Di_ref(3,:,:,:) = abs(Gz*K/(mean(mean(mean([Gx Gy Gz]))))).^anisotrop;
    %     % If anisotropism independent from gradient direction
    %     Di_ref(1,:,:,:) = abs(sqrt(Gx.^2+Gy.^2+Gz.^2)*K/(mean(mean(mean([Gx Gy Gz]))))).^anisotrop;
    %     Di_ref(2,:,:,:) = Di_ref(1,:,:,:);
    %     Di_ref(3,:,:,:) = Di_ref(1,:,:,:);

    if(length(seg)>1) %%%%%%%%%%%%%%%%%%%%% Multi-regions %%%%%%%%%%%%%%%%%%%%%%%

        mask = zeros([1,3,size(seg)],'single');
        nb_seg = 0;
        v_reg = v_reg*0;

        while(min(min(min(seg)))<1)
            nb_seg = nb_seg+1;
            minseg(nb_seg) = min(min(min(seg)));
            mask(nb_seg,1,:,:,:) = ones(size(seg),'single').*(seg==minseg(nb_seg));
            mask(nb_seg,2,:,:,:) = ones(size(seg),'single').*(seg==minseg(nb_seg));
            mask(nb_seg,3,:,:,:) = ones(size(seg),'single').*(seg==minseg(nb_seg));
            seg(seg==minseg(nb_seg))=1;
        end

        %         if((size(ref,1)*size(ref,2)*size(ref,3))>75000)
        %             h = waitbar(0,'Smoothing...');
        %         end

        if(nb_seg>10)
            error('Too many regions. Maximum 10 regions.')
        end

        for it_seg = 1:nb_seg;

            nu = minseg(it_seg)

            if(nu)

                Wxyz = fem_3D_local(nu,spacing);

                Wx = single(Wxyz(:,:,:,:,1));
                Wy = single(Wxyz(:,:,:,:,2));
                Wz = single(Wxyz(:,:,:,:,3));

                v_temp = zeros(size(v,1),size(v,2)+2,size(v,3)+2,size(v,4)+2,'single');
                v_reg_temp = v;

                for i=1:it

                    v_temp(:,:,2:end-1,2:end-1) = [v_reg_temp(:,1,:,:),v_reg_temp,v_reg_temp(:,end,:,:)];
                    v_temp(:,:,1,2:end-1) = v_temp(:,:,2,2:end-1);
                    v_temp(:,:,end,2:end-1) = v_temp(:,:,end-1,2:end-1);
                    v_temp(:,:,:,1) = v_temp(:,:,:,2);
                    v_temp(:,:,:,end) = v_temp(:,:,:,end-1);

                    v_update = [];

                    v_update(1,:,:,:) = conv3f(squeeze(v_temp(1,:,:,:)), Wx(:,:,:,1)) + conv3f(squeeze(v_temp(2,:,:,:)), Wx(:,:,:,2)) + conv3f(squeeze(v_temp(3,:,:,:)), Wx(:,:,:,3));
                    v_update(2,:,:,:) = conv3f(squeeze(v_temp(1,:,:,:)), Wy(:,:,:,1)) + conv3f(squeeze(v_temp(2,:,:,:)), Wy(:,:,:,2)) + conv3f(squeeze(v_temp(3,:,:,:)), Wy(:,:,:,3));
                    v_update(3,:,:,:) = conv3f(squeeze(v_temp(1,:,:,:)), Wz(:,:,:,1)) + conv3f(squeeze(v_temp(2,:,:,:)), Wz(:,:,:,2)) + conv3f(squeeze(v_temp(3,:,:,:)), Wz(:,:,:,3));
                    v_update = v_update(:,2:end-1,2:end-1,2:end-1);

                    disp(['Filter iteration ',num2str(i),' on ',num2str(it),': Mean update = ',num2str(sqrt(mean(mean(mean(v_reg_temp(1,:,:,:)-v_update(1,:,:,:)))).^2+mean(mean(mean(v_reg_temp(2,:,:,:)-v_update(2,:,:,:)))).^2+mean(mean(mean(v_reg_temp(3,:,:,:)-v_update(3,:,:,:)))).^2))]);
                    %                     disp(['Min-max Di : ' num2str(min(min(min(Di_ref(1,:,:,:))))) '  ' num2str(max(max(max(Di_ref(1,:,:,:)))))])

                    v_reg_temp(1,:,:,:) = v_reg_temp(1,:,:,:).*((Di_ref(1,:,:,:)+1)./(Di_ref(1,:,:,:)+2)) + v_update(1,:,:,:)./(Di_ref(1,:,:,:)+2);
                    v_reg_temp(2,:,:,:) = v_reg_temp(2,:,:,:).*((Di_ref(2,:,:,:)+1)./(Di_ref(2,:,:,:)+2)) + v_update(2,:,:,:)./(Di_ref(2,:,:,:)+2);
                    v_reg_temp(3,:,:,:) = v_reg_temp(3,:,:,:).*((Di_ref(3,:,:,:)+1)./(Di_ref(3,:,:,:)+2)) + v_update(3,:,:,:)./(Di_ref(3,:,:,:)+2);

                    %                     if((size(ref,1)*size(ref,2)*size(ref,3))>75000)
                    %                         waitbar(i/it/nb_seg+(it_seg-1)/nb_seg,h)
                    %                     end

                    %                     v_reg_temp = v_reg_temp.*squeeze(mask(it_seg,:,:,:,:))+v.*squeeze(not(mask(it_seg,:,:,:,:)));

                end

                v_reg = v_reg + v_reg_temp.*squeeze(mask(it_seg,:,:,:,:));

            else

                v_reg = v_reg + v.*squeeze(mask(it_seg,:,:,:,:));

            end

        end

        %         if((size(ref,1)*size(ref,2)*size(ref,3))>75000)
        %             close(h);
        %         end

    else %%%%%%%%%%%%%%%%%%%%% Unique region %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if(isempty(seg))
            nu = 0.45;
        else
            nu = seg;
        end

        Wxyz = single(fem_3D_local(nu,spacing));

        Wx = Wxyz(:,:,:,:,1);
        Wy = Wxyz(:,:,:,:,2);
        Wz = Wxyz(:,:,:,:,3);

        v_temp = zeros(size(v,1),size(v,2)+2,size(v,3)+2,size(v,4)+2,'single');

        if((size(ref,1)*size(ref,2)*size(ref,3))>75000)
            h = waitbar(0,'Smoothing...');
        end

        for i=1:it

            v_temp(:,:,2:end-1,2:end-1) = [v_reg(:,1,:,:),v_reg,v_reg(:,end,:,:)];
            v_temp(:,:,1,2:end-1) = v_temp(:,:,2,2:end-1);
            v_temp(:,:,end,2:end-1) = v_temp(:,:,end-1,2:end-1);
            v_temp(:,:,:,1) = v_temp(:,:,:,2);
            v_temp(:,:,:,end) = v_temp(:,:,:,end-1);

            v_update(1,:,:,:) = conv3f(squeeze(v_temp(1,:,:,:)), Wx(end:-1:1,end:-1:1,end:-1:1,1)) + conv3f(squeeze(v_temp(2,:,:,:)), Wx(end:-1:1,end:-1:1,end:-1:1,2)) + conv3f(squeeze(v_temp(3,:,:,:)), Wx(end:-1:1,end:-1:1,end:-1:1,3));
            v_update(2,:,:,:) = conv3f(squeeze(v_temp(1,:,:,:)), Wy(end:-1:1,end:-1:1,end:-1:1,1)) + conv3f(squeeze(v_temp(2,:,:,:)), Wy(end:-1:1,end:-1:1,end:-1:1,2)) + conv3f(squeeze(v_temp(3,:,:,:)), Wy(end:-1:1,end:-1:1,end:-1:1,3));
            v_update(3,:,:,:) = conv3f(squeeze(v_temp(1,:,:,:)), Wz(end:-1:1,end:-1:1,end:-1:1,1)) + conv3f(squeeze(v_temp(2,:,:,:)), Wz(end:-1:1,end:-1:1,end:-1:1,2) ) + conv3f(squeeze(v_temp(3,:,:,:)), Wz(end:-1:1,end:-1:1,end:-1:1,3));

            v_reg(1,:,:,:) = v_reg(1,:,:,:).*(Di_ref(1,:,:,:)+1)./(Di_ref(1,:,:,:)+2) + v_update(1,2:end-1,2:end-1,2:end-1)./(Di_ref(1,:,:,:)+2);
            v_reg(2,:,:,:) = v_reg(2,:,:,:).*(Di_ref(2,:,:,:)+1)./(Di_ref(2,:,:,:)+2) + v_update(2,2:end-1,2:end-1,2:end-1)./(Di_ref(2,:,:,:)+2);
            v_reg(3,:,:,:) = v_reg(3,:,:,:).*(Di_ref(3,:,:,:)+1)./(Di_ref(3,:,:,:)+2) + v_update(3,2:end-1,2:end-1,2:end-1)./(Di_ref(3,:,:,:)+2);

            if((size(ref,1)*size(ref,2)*size(ref,3))>75000)
                waitbar(i/it,h)
            end

        end

        if((size(ref,1)*size(ref,2)*size(ref,3))>75000)
            close(h);
        end

    end

end

end


function U_center = Solver_const(Value,nu)
E = 1e7;
mu = E/(1+nu)/2;
lambda = E*nu/(1+nu)/(1-2*nu);
Ux = 1/(16*mu+16*lambda)*[2*mu+2*lambda,2*lambda-4*mu,2*mu+2*lambda,8*mu+2*lambda,2*mu+2*lambda,2*lambda-4*mu,2*mu+2*lambda,8*mu+2*lambda,0,3/2*(2*mu+lambda),0,-3/2*(2*mu+lambda),0,3/2*(2*mu+lambda),0,-3/2*(2*mu+lambda),0,0]*Value;
Uy = 1/(16*mu+16*lambda)*[-3/2*(2*mu+lambda),0,3/2*(2*mu+lambda),0,-3/2*(2*mu+lambda),0,3/2*(2*mu+lambda),0,0,2*mu+2*lambda,8*mu+2*lambda,2*mu+2*lambda,2*lambda-4*mu,2*mu+2*lambda,8*mu+2*lambda,2*mu+2*lambda,2*lambda-4*mu,0]*Value;
U_center = [Ux Uy];
end
