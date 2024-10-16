%% roundd
% Rounds with fixed number of decimals
%
%% Syntax
% |x=roundd(x,n)|
%
%
%% Description
% |x=roundd(x,n)| Rounds with fixed number of decimals
%
%
%% Input arguments
% |x| - _SCALAR_ - Scalar to round
%
% |n| - _INTEGER_ - Number of decimals 
%
%
%% Output arguments
%
% |x| - _INTEGER_ - Rounded scalar
%
%
%% Contributors
% Authors : 

function x=roundd(x,n)

x = round(x*(10^n))/(10^n);
