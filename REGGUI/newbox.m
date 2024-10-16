%% newbox
% Create a new meta ('*.mha') box data structure
%
%% Syntax
% |box = newbox(datasize)|
%
%
%% Description
% |box = newbox(datasize)| % Create a new box data structure
%
%
%% Input arguments
% |datasize| - _INTEGER VECTOR_ - dimension (x,y,z) of the box
%
%
%% Output arguments
%
% |box| - _STRUCTURE_ - Box data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function box = newbox(datasize);


box = struct(...
    'name','Entire volume',...
    'show',true,...
    'crn1',ones(3,1),...
    'crn2',[datasize(1);datasize(2);datasize(3)],...
    'aval',1,...
    'cval',[0,0,0],...
    'conly',true);
