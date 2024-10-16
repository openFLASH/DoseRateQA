%% Compute_strel
% Create a spherical kernel mask (structuring element) that can then be used to filter an image.
%
%% Syntax
% |myStrel = Compute_strel(k,handles)|
%
%
%% Description
% |myStrel = Compute_strel(k,handles)| describes the function
%
%
%% Input arguments
% |k| - _SCALAR VECTOR_ -  Size of the kernel mask. [x,y,z]| : Three elements. Radius (in mm) of the 3D structuring element. 
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.spacing| - _VECTOR of SCALAR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |res| - _TYPE_ - description for 1st syntax
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function myStrel = Compute_strel(k,handles)
for n=1:3
    k(n) = k(n)/handles.spacing(n) +eps;
end
myStrel = zeros(2*ceil(k(1))+1,2*ceil(k(2))+1,2*ceil(k(3))+1);
center = ([size(myStrel,1) size(myStrel,2) size(myStrel,3)]+1)/2;
[Y,X,Z] = meshgrid(1:size(myStrel,2),1:size(myStrel,1),1:size(myStrel,3));
myStrel = (X-center(1)).^2/k(1).^2+(Y-center(2)).^2/k(2).^2+(Z-center(3)).^2/k(3).^2<=1;
end
