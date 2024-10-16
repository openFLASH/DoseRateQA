%% roundsdm
% Quantize with given number of n-ary digits and given quantification tolerance.
% See also Matlab's function ROUND.
%
%% Syntax
% |[y,RescaleSlope] = roundsdm(x,n,mult,power_exp)|
%
%% Description
% |[y,RescaleSlope] = roundsdm(x,n,mult,power_exp)| Quantize the vector X with given number of n-ary digits and given quantification tolerance. 
% The RescaleSlope is computed such that the maximum absolute value of Y will be smaller than mult^(power_exp-2), and Y is quantized so that the quatization error is smaller than 10^n.
%
%% Input arguments
% |x| - _SCALAR VECTOR_ - Input vector
%
% |n| - _SCALAR_ - The tolerance of the relative quantification error must be smaller than 10^n
%
% |mult| - _SCALAR_ - Quantization base (example: mult = 2 for binary data)
%
% |power_exp| - _SCALAR_ - Number of digits for the quantization (example: mult = 8 when quantizing on a byte (256 values))
%
%% Output arguments
%
% |y| - _INTEGER_ -  Output vector
%
%% Contributors
% Authors : G.Janssens


function [y,RescaleSlope] = roundsdm(y,n,mult,power_exp)

RescaleSlope = 1;

while(max(max(max(abs(abs(y-round(y))./abs(y+eps)))))>10^(-n) && max(abs(y(:)))<mult^(power_exp-2))
    RescaleSlope = RescaleSlope/mult;
    y = y*mult;    
end

y = round(y)*RescaleSlope;
