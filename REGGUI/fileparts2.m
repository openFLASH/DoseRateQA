function [p,f] = fileparts2(fullfilename)

[p,name,ext] = fileparts(fullfilename);
f = [name,ext];