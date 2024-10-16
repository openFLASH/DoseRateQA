%% newmask
% Create a new meta ('*.mha') mask data structure
%
%% Syntax
% |mask = newmask(datasize)|
%
%
%% Description
% |mask = newmask(datasize)| Create a new meta ('*.mha') mask data structure
%
%
%% Input arguments
% |datasize| - _SCALAR VECTOR_ - Size of each dimension of the mask
%
%
%% Output arguments
%
% |mask| - _STRUCTURE_ - New meta ('*.mha') mask data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function mask = newmask(datasize);

mask = struct(...
    'name','New mask',...
    'show',true,...
    'value',repmat(uint8(0),[datasize(1),datasize(2),datasize(3)]),...
    'index',1,...
    'array',newregion);
    
