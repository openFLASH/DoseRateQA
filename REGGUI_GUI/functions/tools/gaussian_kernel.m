%% gaussian_kernel
% Create a 1 dimensional gaussian kernel
%
%% Syntax
% |k = gaussian_kernel(k_size,sigma)|
%
%
%% Description
% |k = gaussian_kernel(k_size,sigma)| describes the function
%
%
%% Input arguments
% |k_size| - _INTEGER_ -  Number of elements in the gaussian kernel.
%
% |sigma| - _SCALAR_ -  Standard deviation of the gaussian
%
%
%% Output arguments
%
% |k| - _VECTOR of SCALAR_ - |k(x)| The 1-D Gaussian kernel. The kernel is computed from |-(k_size-1)/2| to |(k_size-1)/2| by step 1
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function k = gaussian_kernel(k_size,sigma,normalize)

if(nargin<3)
    normalize = 0;
end

x = [-(k_size-1)/2:1:(k_size-1)/2]';
sigma2 = 2*sigma.^2;
x2 = x.^2;
k = exp(-x2./sigma2);

if(normalize)
    k = k/sum(k);
end
