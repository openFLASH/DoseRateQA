%% defcolors
% Return the description of the color maps and of the color for lines. The values returned by |lstr{j}|, |lchr(j)| and |lrgb(j,:)| describe the same j-th color.
%
%% Syntax
% |[fstr,lstr,lchr,lrgb] = defcolors|
%
%
%% Description
% |[fstr,lstr,lchr,lrgb] = defcolors| Return the description of the color maps and of the color for lines.
%
%
%% Input arguments
% None
%
%
%% Output arguments
%
% |fstr| - _CELL VECTOR of STRING_ -  |fstr{u}| Fill color strings (= color map names) for the u-th color map 
%
% |lstr| - _CELL VECTOR of STRING_ -  |lstr{j}| Line color strings for the j-th color (line color names) 
%
% |lchr| - _CHARACTER VECTOR_ -  |lchr(j)| Line color characters for the j-th color (for plot) 
%
% |lrgb| - _INTEGER MATRIX_ -  |lrgb(j,:)=[r,g,b]| Line color RBG values  for the j-th color
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [fstr,lstr,lchr,lrgb] = defcolors

% fill color strings (color map names)
fstr = {'Jet';'Spectral';'HSV';'Spring';'Summer';'Autumn';'Winter';'Pink';'Cool';'Hot';'Hotmetal';'Bone';'Gray';'Yarg'};

% line color strings (line color names)
lstr = {'Black';'White';'Red';'Yellow';'Green';'Blue'};

% line color characters (for plot)
lchr = ['k';'w';'r';'y';'g';'b'];

% line color RBG values
lrgb = [0,0,0;1,1,1;1,0,0;1,1,0;0,1,0;0,0,1];
