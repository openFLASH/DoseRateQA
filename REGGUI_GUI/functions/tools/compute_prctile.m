%% compute_prctile
% Compute the lower percentile of a sample drawn from a random variable
%
%% Syntax
% |res = compute_prctile(v,p)|
%
%
%% Description
% |res = compute_prctile(v,p)| Compute the lower percentile
%
%
%% Input arguments
% |v| - _SCALAR VECTOR_ - Sample of the variable. |v(i)| is the value of the i-th draw of the variable
%
% |p| - _STRING_ - Lower percentile (in %) of the sample
%
%
%% Output arguments
%
% |res| - _SCALAR_ - Value of percentile of the sample
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = compute_prctile(v,p)

v_sorted = sort(v(not(isnan(v))));

if(isempty(v_sorted))
    res = 0;
else    
    index = max(floor((p/100)*length(v_sorted)),1);
    res = v_sorted(index);
end
