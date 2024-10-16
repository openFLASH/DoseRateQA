%% newcolors
% Create an array with 1 new meta ('*.mha') color data structure 
%
%% Syntax
% |color = newcolors()|
%
% |color = newcolors(modality)|
%
%
%% Description
% |color = newcolor()| Create a new color data structure for default modality
%
% |color = newcolor(modality)| Create a new color data structure for specified modality
%
%
%% Input arguments
% |modality| - _STRING_ - [OPTIONAL. Default : 'OT'] specify the modality: 'pt', 'ct', 'rd', 'mr'
%
%
%% Output arguments
%
% |color| - _STRUCTURE_ - Array with 1 color data structure 
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function colors = newcolors(modality);
% Create a new colors data structure

% check arg
if nargin<1, modality = 'OT'; end;

% new color structure
color = newcolor(modality);

% change default settings according to modality (CT and MR)
switch lower(modality),
    case 'pt',
        % multiple color scales
        carr = [color];
    case 'ct',
        % color definitions
        [fstr,lstr,lchr,lrgb] = defcolors;
        
        % find 'gray' colormap
        for i = 1:length(fstr),
            if strcmp('gray',lower(fstr{i})), color.map_indx = i; end;
        end;
        color.map_name = lower(fstr{color.map_indx});
        
        % set line color to red
        color.plc_char = 'r';
        color.plc_indx = 3;
        color.plc__rgb = [1,0,0];
        
        % range
        color.rng_type = 3; % specified min./max.
        color.rng_disp = 4; % display in [-1000,+2000]
        color.rng_rlim = [-1000,+2000]; % Hounsfield range
        
        % multiple color scales
        carr = [color,color];
        carr(1).name = 'Full window';
        carr(2).map_clim(1) = 0.30;
        carr(2).map_clim(2) = 0.38;
        carr(2).name = 'Tissue window';
    case 'rd',
        % color definitions
        [fstr,lstr,lchr,lrgb] = defcolors;
        
        % find 'gray' colormap
        for i = 1:length(fstr),
            if strcmp('spectral',lower(fstr{i})), color.map_indx = i; end;
        end;
        color.map_name = lower(fstr{color.map_indx});
        
        % set line color to white
        color.plc_char = 'w';
        color.plc_indx = 2;
        color.plc__rgb = [1,1,1];
        
        % multiple color scales
        carr = [color];
    case 'mr',
        % color definitions
        [fstr,lstr,lchr,lrgb] = defcolors;
        
        % find 'gray' colormap
        for i = 1:length(fstr),
            if strcmp('gray',lower(fstr{i})), color.map_indx = i; end;
        end;
        color.map_name = lower(fstr{color.map_indx});
        
        % set line color to red
        color.plc_char = 'r';
        color.plc_indx = 3;
        color.plc__rgb = [1,0,0];
        
        % multiple color scales
        carr = [color,color];
    otherwise,
        % color definitions
        [fstr,lstr,lchr,lrgb] = defcolors;
        
        % find 'gray' colormap
        for i = 1:length(fstr),
            if strcmp('gray',lower(fstr{i})), color.map_indx = i; end;
        end;
        color.map_name = lower(fstr{color.map_indx});
        
        % set line color to red
        color.plc_char = 'r';
        color.plc_indx = 3;
        color.plc__rgb = [1,0,0];
        
        % range
        color.rng_type = 3; % specified min./max.
        color.rng_disp = 4; % display in [-1000,+2000]
        color.rng_rlim = [-1000,+2000]; % Hounsfield range
        
        % multiple color scales
        carr = [color,color,color];
        carr(1).name = 'CT full window';
        carr(2).map_clim(1) = 0.30;
        carr(2).map_clim(2) = 0.38;
        carr(2).name = 'CT tissue window';
        carr(3).rng_rlim = [-3000,+3000];
        carr(3).rng_disp = 3;
        carr(3).name = 'CT symmetric window';
        carr(3).map_clim(1) = 0.45;
        carr(3).map_clim(2) = 0.55;
        
        % add default color scale
        carr = [newcolor(modality),carr];
end;

% build structure
colors = struct(...
    'index',1,...
    'array',carr);

