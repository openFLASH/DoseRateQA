%% newregis
% Create a new array with 1 meta ('*.mha') registration data structure

%
%% Syntax
% |regis = newregis(datasize)|
%
%
%% Description
% |regis = newregis(datasize)| Create an array with 1 registration data structure
%
%
%% Input arguments
% |datasize| - _SCALAR VECTOR_ - Size of each dimension of the image 
%
%
%% Output arguments
%
% |regis| - _STRUCTURE_ - Array with 1 'Meta' box data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function regis = newregis(datasize);
% Create a new regis data structure

regis = struct(...
    'index',1,...
    'array',newregi(datasize),...
    'rflag',false,...
    'odval',[],...
    'odspa',[],...
    'oddim',[datasize(1);datasize(2);datasize(3)]);
