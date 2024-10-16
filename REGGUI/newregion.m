%% newregion
% Create a new meta ('*.mha') region data structure
%
%% Syntax
% |region = newregion|
%
%
%% Description
% |region = newregion| reate a new meta ('*.mha') region data structure
%
%
%% Input arguments
% None
%
%
%% Output arguments
%
% |region|- _STRUCTURE_ - 'Meta' region data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function region = newregion;


region = struct(...
            'name','New region',...
            'rkey',0,...
            'aval',0,...
            'cval',[0,0,0],...
            'conly',false);
