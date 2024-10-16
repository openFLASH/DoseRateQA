%% fem_3D_local
% Compute the convolution kernel to apply to the image to account for the finitie element analysis solution of the linear elasticity equations.
% See section "A.1 Convolutive kernel coefficient" of reference [1] for more information.
% In the convolution equation (page 92 of reference 1), the displacement field is regularized by cobnvolving the deformation field |D(J,x,y,z)| with convolution kernels |G(x,y,z,I,J)|:
% Dregul = (G*D)(I,x,y,z) = sum_J [D(J)*G(I,J)]
% where Gij is the convolution kernel describing the relation between the jth component of neighboring displacement vectors and the ith component of the central displacement vector Di.
%
% NB: Young's modulus is set equal to 1.
%
%% Syntax
% |Wxyz = fem_3D_local(nu,dim)|
%
%
%% Description
% |Wxyz = fem_3D_local(nu,dim)| describes the function
%
%
%% Input arguments
% |nu| - _SCALAR_ -  Poisson’s ratio. Poisson’s ratio |nu| takes a value in the interval ]− 1; 0.5[ (0.5 corresponds to incompressible materials, 0 to completely compressible materials and negative values correspond to auxetic materials)
%
% |dim| - _VECTOR of SCALAR_ - Size (x,y,z) (in |mm|) of the pixels in the images.
%
%
%% Output arguments
%
% |Wxyz| - _TYPE_ - |Wxyz(x,y,z,J,I) = G(x,y,z,I,J)| Convolution kernel computing the Ith component of the regularized deformation field (I=1 for X, I=2 for Y, I=3 for Z) and applied to the Jth component of the input deformation field. The kernel is to be applied to the voxel (x,y,z)
%
%% Reference
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
% [2] G. Janssens, J. O. de Xivry, H. J. W. Aerts, G. Bosmans, A. L. A. Dekker and B. Macq. Improving physical behavior in image registration. In Proc. 15th IEEE International Conference on Image Processing ICIP 2008, pp. 2952–2955, 12–15 Oct. 2008.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Wxyz = fem_3D_local(nu,dim)

E = 1; %Young's modulus

mu = E/(1+nu)/2;
lambda = E*nu/(1+nu)/(1-2*nu);

Aij_A = round(fem_Aij(1,0,0,dim)*1000)/1000;
Aij_C = round(fem_Aij(0,1,0,dim)*1000)/1000;
Aij_B2 = round(fem_Aij(0,0,1,dim)*1000)/1000;

Aij_lambda = Aij_A + Aij_C;
Aij_mu = 2*Aij_A + Aij_B2;

Aij = Aij_lambda;
A_lambda = zeros(3,27*3);
for i=0:8:16
    for j=0:8:16
    A_lambda(i/8+1,1+j/8*27:(j/8+1)*27) = [Aij(1+i,7+j) , Aij(2+i,7+j) + Aij(1+i,8+j) , Aij(2+i,8+j) , Aij(3+i,8+j) + Aij(2+i,5+j) , Aij(3+i,5+j) , ... 
                                        Aij(3+i,6+j) + Aij(4+i,5+j), Aij(4+i,6+j) , Aij(1+i,6+j) + Aij(4+i,7+j) , Aij(3+i,7+j) + Aij(4+i,8+j) + Aij(1+i,5+j) + Aij(2+i,6+j) , ...
                                        Aij(5+i,3+j) , Aij(6+i,3+j) + Aij(5+i,4+j) , Aij(6+i,4+j) , Aij(7+i,4+j) + Aij(6+i,1+j) , Aij(7+i,1+j) , ...
                                        Aij(8+i,1+j) + Aij(7+i,2+j) , Aij(8+i,2+j) , Aij(5+i,2+j) + Aij(8+i,3+j), Aij(7+i,3+j) + Aij(8+i,4+j) + Aij(5+i,1+j) + Aij(6+i,2+j) , ...
                                        Aij(1+i,3+j) + Aij(5+i,7+j) , Aij(1+i,4+j) + Aij(2+i,3+j) + Aij(5+i,8+j) + Aij(6+i,7+j) , ...
                                        Aij(2+i,4+j) + Aij(6+i,8+j) , Aij(3+i,4+j) + Aij(2+i,1+j) + Aij(6+i,5+j) + Aij(7+i,8+j) , ...
                                        Aij(3+i,1+j) + Aij(7+i,5+j) , Aij(3+i,2+j) + Aij(4+i,1+j) + Aij(8+i,5+j) + Aij(7+i,6+j) , ...
                                        Aij(4+i,2+j) + Aij(8+i,6+j) , Aij(1+i,2+j) + Aij(4+i,3+j) + Aij(5+i,6+j) + Aij(8+i,7+j) , ...
                                        Aij(1+i,1+j) + Aij(2+i,2+j) + Aij(3+i,3+j) + Aij(4+i,4+j) + Aij(5+i,5+j) + Aij(6+i,6+j) + Aij(7+i,7+j) + Aij(8+i,8+j)];
    end
end

Aij = Aij_mu;
A_mu = zeros(3,27*3);
for i=0:8:16
    for j=0:8:16
    A_mu(i/8+1,1+j/8*27:(j/8+1)*27) = [Aij(1+i,7+j) , Aij(2+i,7+j) + Aij(1+i,8+j) , Aij(2+i,8+j) , Aij(3+i,8+j) + Aij(2+i,5+j) , Aij(3+i,5+j) , ... 
                                        Aij(3+i,6+j) + Aij(4+i,5+j), Aij(4+i,6+j) , Aij(1+i,6+j) + Aij(4+i,7+j) , Aij(3+i,7+j) + Aij(4+i,8+j) + Aij(1+i,5+j) + Aij(2+i,6+j) , ...
                                        Aij(5+i,3+j) , Aij(6+i,3+j) + Aij(5+i,4+j) , Aij(6+i,4+j) , Aij(7+i,4+j) + Aij(6+i,1+j) , Aij(7+i,1+j) , ...
                                        Aij(8+i,1+j) + Aij(7+i,2+j) , Aij(8+i,2+j) , Aij(5+i,2+j) + Aij(8+i,3+j), Aij(7+i,3+j) + Aij(8+i,4+j) + Aij(5+i,1+j) + Aij(6+i,2+j) , ...
                                        Aij(1+i,3+j) + Aij(5+i,7+j) , Aij(1+i,4+j) + Aij(2+i,3+j) + Aij(5+i,8+j) + Aij(6+i,7+j) , ...
                                        Aij(2+i,4+j) + Aij(6+i,8+j) , Aij(3+i,4+j) + Aij(2+i,1+j) + Aij(6+i,5+j) + Aij(7+i,8+j) , ...
                                        Aij(3+i,1+j) + Aij(7+i,5+j) , Aij(3+i,2+j) + Aij(4+i,1+j) + Aij(8+i,5+j) + Aij(7+i,6+j) , ...
                                        Aij(4+i,2+j) + Aij(8+i,6+j) , Aij(1+i,2+j) + Aij(4+i,3+j) + Aij(5+i,6+j) + Aij(8+i,7+j) , ...
                                        Aij(1+i,1+j) + Aij(2+i,2+j) + Aij(3+i,3+j) + Aij(4+i,4+j) + Aij(5+i,5+j) + Aij(6+i,6+j) + Aij(7+i,7+j) + Aij(8+i,8+j)];
    end
end

It = [14,15,16,13,18,17,12,11,10,23,24,25,22,27,26,21,20,19,5,6,7,4,9,8,3,2,1];
It = [It It+27 It+54];

W = zeros(3,81);

for i=1:3
    for j=1:81
        W(i,j) = A_lambda(i,It(j))*lambda + A_mu(i,It(j))*mu ;
    end
    W(i,:) = -W(i,:)/W(i,14+(i-1)*27);
    W(i,14+(i-1)*27) = 0;
end

Wx = reshape(W(1,:),3,3,3,3);
Wy = reshape(W(2,:),3,3,3,3);
Wz = reshape(W(3,:),3,3,3,3);

Wxyz(:,:,:,:,1) = Wx;
Wxyz(:,:,:,:,2) = Wy;
Wxyz(:,:,:,:,3) = Wz;
