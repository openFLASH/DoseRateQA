%% normalize_vcts
% Normalise a list of vector. The vector can be in a 1 to 4-dimensional space
%
%% Syntax
% |v = normalize_vcts(v,dim)|
%
%
%% Description
% ||v = normalize_vcts(v,dim)| describes the function
%
%
%% Input arguments
% |v| - _SCALAR MATRIX_ - |v(:,i)| components of the ith vector
%
% |dim| - _INTEGER_ -  Number of dimension of the vector space with |1 <= dim <= 4|
%
%
%% Output arguments
%
% |v| - _SCALAR MATRIX_ - |v(:,i)| components of the ith normalised vector
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function v = normalize_vcts(v,dim)

% Authors : G.Janssens (open.reggui@gmail.com)

if(nargin<2)
    dim = 1;
end

v_norm = sqrt(sum(v.^2,dim));

switch dim
    case 1
        v = v./repmat(v_norm,[size(v,1),1]);
    case 2
        v = v./repmat(v_norm,[1,size(v,2)]);
    case 3
        v = v./repmat(v_norm,[1,1,size(v,3)]);
    case 4
        v = v./repmat(v_norm,[1,1,1,size(v,4)]);
    otherwise
        disp('Not implemented for dimensions greater than 4')
        v = [];
        return
end

v(isinf(v))=0;
