%% newmasks
% Create an array with 1 new meta ('*.mha') mask data structure
%
%% Syntax
% |mask = newmasks(datasize)|
%
%
%% Description
% |mask = newmasks(datasize)| Create an array with 1 new meta ('*.mha') mask data structure
%
%
%% Input arguments
% |datasize| - _SCALAR VECTOR_ - Size of each dimension of the mask
%
%
%% Output arguments
%
% |mask| - _STRUCTURE_ - Array with 1 New meta ('*.mha') mask data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function masks = newmasks(datasize);

masks = struct(...
    'index',1,...
    'array',newmask(datasize));
