%% newlines
% Create an array with 1 new meta ('*.mha') line data structure (polyline, polygon or "contour")
%
%% Syntax
% |line = newlines(datasize)|
%
%
%% Description
% |line = newlines(datasize)| Create a new line data structure
%
%
%% Input arguments
% |datasize| - _SCALAR VECTOR_ - Size of each dimension of the image
%
%
%% Output arguments
%
% |line| - _STRUCTURE_ - Array with 1 Line data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function lines = newlines(datasize);

lines = struct(...
    'index',1,...
    'array',new_line(datasize));
