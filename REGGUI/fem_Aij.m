%% fem_Aij
% Computes the elements of the rigidity matrix for the elastic smoother
% See section "4.2.3 Iterative elastic filtering" of reference [1] for more information.
%
%% Syntax
% |Aij = fem_Aij(A,C,mu,dim)|
%
%
%% Description
% |Aij = fem_Aij(A,C,mu,dim)| describes the function
%
%
%% Input arguments
% |A| - _SCALAR_ -  description
%
% |C| - _SCALAR_ -  description
%
% |mu| - _SCALAR_ -  description
%
% |dim| - _VECTOR of SCALAR_ - Size (x,y,z) (in |mm|) of the pixels in the images.
%
%
%% Output arguments
%
% |Aij| - _SCALAR MATRIX_ - The rigidity matrix  |Aij(i,j)|
%
%% Reference
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Aij = fem_Aij(A,C,mu,dim)

[Integ_points,poids] = gauss_leg_cube(2); 

Aij=zeros(24);

for i=1:size(Integ_points,1)

    dPhix(i,1) = (1+Integ_points(i,3))*(1+Integ_points(i,4))*2/dim(1);
    dPhiy(i,1) = (1+Integ_points(i,2))*(1+Integ_points(i,4))*2/dim(2);
    dPhiz(i,1) = (1+Integ_points(i,2))*(1+Integ_points(i,3))*2/dim(3);

    dPhix(i,2) = -(1+Integ_points(i,3))*(1+Integ_points(i,4))*2/dim(1);
    dPhiy(i,2) = (1-Integ_points(i,2))*(1+Integ_points(i,4))*2/dim(2);
    dPhiz(i,2) = (1-Integ_points(i,2))*(1+Integ_points(i,3))*2/dim(3);

    dPhix(i,3) = -(1-Integ_points(i,3))*(1+Integ_points(i,4))*2/dim(1);
    dPhiy(i,3) = -(1-Integ_points(i,2))*(1+Integ_points(i,4))*2/dim(2);
    dPhiz(i,3) = (1-Integ_points(i,2))*(1-Integ_points(i,3))*2/dim(3);

    dPhix(i,4) = (1-Integ_points(i,3))*(1+Integ_points(i,4))*2/dim(1);
    dPhiy(i,4) = -(1+Integ_points(i,2))*(1+Integ_points(i,4))*2/dim(2);
    dPhiz(i,4) = (1+Integ_points(i,2))*(1-Integ_points(i,3))*2/dim(3);

    dPhix(i,5) = (1+Integ_points(i,3))*(1-Integ_points(i,4))*2/dim(1);
    dPhiy(i,5) = (1+Integ_points(i,2))*(1-Integ_points(i,4))*2/dim(2);
    dPhiz(i,5) = -(1+Integ_points(i,2))*(1+Integ_points(i,3))*2/dim(3);

    dPhix(i,6) = -(1+Integ_points(i,3))*(1-Integ_points(i,4))*2/dim(1);
    dPhiy(i,6) = (1-Integ_points(i,2))*(1-Integ_points(i,4))*2/dim(2);
    dPhiz(i,6) = -(1-Integ_points(i,2))*(1+Integ_points(i,3))*2/dim(3);

    dPhix(i,7) = -(1-Integ_points(i,3))*(1-Integ_points(i,4))*2/dim(1);
    dPhiy(i,7) = -(1-Integ_points(i,2))*(1-Integ_points(i,4))*2/dim(2);
    dPhiz(i,7) = -(1-Integ_points(i,2))*(1-Integ_points(i,3))*2/dim(3);

    dPhix(i,8) = (1-Integ_points(i,3))*(1-Integ_points(i,4))*2/dim(1);
    dPhiy(i,8) = -(1+Integ_points(i,2))*(1-Integ_points(i,4))*2/dim(2);
    dPhiz(i,8) = -(1+Integ_points(i,2))*(1-Integ_points(i,3))*2/dim(3);


    Aij = Aij+[ A*dPhix(i,:)'*dPhix(i,:) + mu*dPhiy(i,:)'*dPhiy(i,:) + mu*dPhiz(i,:)'*dPhiz(i,:) , C*dPhix(i,:)'*dPhiy(i,:) + mu*dPhiy(i,:)'*dPhix(i,:) , C*dPhix(i,:)'*dPhiz(i,:) + mu*dPhiz(i,:)'*dPhix(i,:) ;...
        C*dPhiy(i,:)'*dPhix(i,:) + mu*dPhix(i,:)'*dPhiy(i,:) , mu*dPhix(i,:)'*dPhix(i,:) + A*dPhiy(i,:)'*dPhiy(i,:) + mu*dPhiz(i,:)'*dPhiz(i,:) , C*dPhiy(i,:)'*dPhiz(i,:) + mu*dPhiz(i,:)'*dPhiy(i,:) ; ...
        C*dPhiz(i,:)'*dPhix(i,:) + mu*dPhix(i,:)'*dPhiz(i,:) , C*dPhiz(i,:)'*dPhiy(i,:) + mu*dPhiy(i,:)'*dPhiz(i,:) , mu*dPhix(i,:)'*dPhix(i,:) + mu*dPhiy(i,:)'*dPhiy(i,:) + A*dPhiz(i,:)'*dPhiz(i,:) ]*poids(i)/8;

end


Aij = Aij*9;
