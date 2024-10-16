%% newcolor
% Create a new meta ('*.mha') color data structure 
%
%% Syntax
% |color = newcolor()|
%
% |color = newcolor(modality)|
%
%
%% Description
% |color = newcolor()| Create a new color data structure for default modality
%
% |color = newcolor(modality)| Create a new color data structure for specified modality
%
%
%% Input arguments
% |modality| - _STRING_ - [OPTIONAL. Default : 'OT'] specify the modality: 'OT', 'NM', 'PT'
%
%
%% Output arguments
%
% |color| - _STRUCTURE_ - color data structure 
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


function color = newcolor(modality);


% check arg
if nargin<1, modality = 'OT'; end;

% default value (for OT,NM,PT)
color = struct(...
    'name','Default color scale',...
    'map_clim',[0,1],...
    'map_name','jet',...
    'map_indx',1,...
    'map__inv',0,...
    'plc_char','k',...
    'plc_indx',1,...
    'plc__rgb',[0,0,0],...
    'rng_disp',1,...
    'rng_type',1,...
    'rng_rlim',[-1000,+2000],...
    'nbr_cntr',4);

