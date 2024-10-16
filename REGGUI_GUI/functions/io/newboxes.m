%% newboxes
% Create an array with 1 new meta ('*.mha') box data structure
%
%% Syntax
% |boxes = newboxes(datasize)|
%
%
%% Description
% |boxes = newboxes(datasize) % Create a new box data structure
%
%
%% Input arguments
% |datasize| - _INTEGER VECTOR_ - dimension (x,y,z) of the box
%
%
%% Output arguments
%
% |box| - _STRUCTURE_ - Array of 1 box data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function boxes = newboxes(datasize);
% Create a new boxes data structure

boxes = struct(...
    'index',1,...
    'array',newbox(datasize));
