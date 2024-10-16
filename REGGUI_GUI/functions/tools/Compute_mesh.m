%% Compute_mesh
% Returns the faces and vertices composing the external surface delimiting a binary |mask| (e.g. RT structure).
% Dilation, filling (interactive GUI) and erosion are applied to the mask before the meshes are computed on the surface.
%
%% Syntax
% |[faces_original, vertices_original] = Compute_mesh(mask, handles)|
%
%
%% Description
% |[faces_original, vertices_original] = Compute_mesh(mask, handles)| Compute the mesh representing the surface of a binary mask.
%
%
%% Input arguments
% |mask| - _STRING_ - Name of the mask in |handles.images| from which the surface mesh is extracted.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is 'images' or 'mydata'):
%
% * |handles.XXX.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image 
%
%
%% Output arguments
%
% |faces_original| - _SCALAR MATRIX_ -  Faces of the external surface of the binary mask. See "Faces" section of |patch function for more information|.
%
% |vertices_origina| - _SCALAR MATRIX_ -  Vertices of the external surface of the binary mask. See "Vertex" section of |patch function for more information|.
%
%
%% Contributors
% Author : Luiza Bondar, Guillaume Janssens (open.reggui@gmail.com)

function [faces_original, vertices_original] = Compute_mesh(mask, handles, morph_kernel_size) %, origImage, X, Y, Z, dx, dy, dz

if(nargin<3)
    morph_kernel_size = 5;
end

for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},mask))
        binary_mask = handles.images.data{i};
    end
end

% Get workspace properties
nx = handles.size(1);
ny = handles.size(2);
nz = handles.size(3);
ox = handles.origin(1);
oy = handles.origin(2);
oz = handles.origin(3);
dx = handles.spacing(1);
dy = handles.spacing(2);
dz = handles.spacing(3);

% Apply morphological operations
if(morph_kernel_size>0)
    structuringElement = strel('disk', morph_kernel_size); %Structuring element for imdilate and imerode
    for i =1:nz
        binary_mask(:, :, i) = imdilate(binary_mask(:,:,i), structuringElement);
        binary_mask(:, :, i) = imfill(binary_mask(:, :, i));
        binary_mask(:, :, i) = imerode(binary_mask(:, :, i), structuringElement);
    end
else
    for i =1:nz
        binary_mask(:, :, i) = imfill(binary_mask(:, :, i));
    end
end

if(morph_kernel_size>0)
    [x,y,z] = ndgrid(-morph_kernel_size:morph_kernel_size);
    structuringElement3D = strel(sqrt(x.^2 + y.^2 + z.^2) <=morph_kernel_size);
    binary_mask = imdilate(binary_mask, structuringElement3D);
    binary_mask = imerode(binary_mask, structuringElement3D);
end

X = ox + (dx*(0:(nx-1))');
Y = oy + (dy*(0:(ny-1))');
Z = oz + (dz*(0:(nz-1))');
[X,Y,Z] = meshgrid(Y,X,Z);

[faces_original,vertices_original]=isosurface(X,Y,Z,binary_mask,0);
