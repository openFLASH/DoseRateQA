%% new_line
% Create a new meta ('*.mha') line data structure (polyline, polygon or "contour")
%
%% Syntax
% |line = new_line(datasize)|
%
%
%% Description
% |line = new_line(datasize)| Create a new line data structure
%
%
%% Input arguments
% |datasize| - _SCALAR VECTOR_ - Size of each dimension of the image
%
%
%% Output arguments
%
% |line| - _STRUCTURE_ - Line data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function line = new_line(datasize);


line = struct(...
    'name','New contour',...
    'show',true,...
    'index',1,...
    'array',{[]},...
    'aval',1,...
    'cval',[0,0,0],...
    'conly',true);

line(1).array = cell(datasize(3),1);
