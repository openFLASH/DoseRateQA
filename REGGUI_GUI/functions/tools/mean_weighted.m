%% mean_weighted
% Compute the weighted average of the elements of the vector |a|:
% |res = sum (a.*w)| / sum(w)
%
%% Syntax
% |res = mean_weighted(a,w)|
%
%
%% Description
% |res = mean_weighted(a,w)| Perform the weighted average
%
%
%% Input arguments
% |a| - _SCALAR VECTOR_ -  Vector of values to be averaged
%
% |w| - _SCALAR VECTOR_ -  Vector of weights. Must be the same length as |a|
%
%
%% Output arguments
%
% |res| - _SCALAR_ - The weighted average of the vector |a|

%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = mean_weighted(a,w)

res = sum(a(not(isnan(a)|isnan(w))).*w(not(isnan(a)|isnan(w))))/sum(w(not(isnan(a)|isnan(w))));
