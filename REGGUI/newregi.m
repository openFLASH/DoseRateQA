%% newregi
% Create a new meta ('*.mha') registration data structure

%
%% Syntax
% |regi = newregi(datasize)|
%
%
%% Description
% |regi = newregi(datasize)| Create the registration data structure
%
%
%% Input arguments
% |datasize| - _SCALAR VECTOR_ - Size of each dimension of the image 
%
%
%% Output arguments
%
% |regi| - _STRUCTURE_ - 'Meta' box data structure
%
% |regi.name| - _STRING_ - registation name = 'Identity',...
% |regi.tran| - _SCALAR VECTOR_ - (x,y,z) Translation vector = [0;0;0]
% |regi.rota| - _SCALAR VECTOR_ Rotation angles = [0;0;0]
% |regi.fspa| - _SCLAR VECTOR_ ',[1;1;1],...
% |regi.ddim| - _SCALAR VECTOR_ - |ddim(x,y,z,t)| Size of each dimension
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function regi = newregi(datasize);

regi = struct(...
    'name','Identity',...
    'tran',[0;0;0],...
    'rota',[0;0;0],...
    'fspa',[1;1;1],...
    'ddim',[datasize(1);datasize(2);datasize(3)]);
