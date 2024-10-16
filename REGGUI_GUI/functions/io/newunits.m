%% newunits
% Create a meta ('*.mha') new units data structure
%
%% Syntax
% |units = newunits|
%
%
%% Description
% |units = newunits| Create a meta ('*.mha') new units data structure
%
%
%% Input arguments
% None
%
%
%% Output arguments
%
% |units| - _STRUCTURE_ - meta ('*.mha') new units data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function units = newunits;


units = struct(...
    'index',1,...
    'array',struct('name','none','fact',1,'offs',0));

