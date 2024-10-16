%% Export_contour_to_mesh
% Save to disk (in a file at the VTK format, see |save_to_vtk|) the faces and vertices composing the external surface delimiting a binary |mask| (see |Compute_mesh|).
%
%% Syntax
% |handles = Export_contour_to_mesh(binary_mask,ref_image,outname,handles)|
%
%
%% Description
% |handles = Export_contour_to_mesh(binary_mask,ref_image,outname,handles)| Save to disk the faces and vertices of the binary mask
%
%
%% Input arguments
% |binary_mask| - _STRING_ - Name of the mask in |handles.images| from which the surface mesh is extracted.
%
% |ref_image| - _STRING_ -  Name of the reference image contained in 'images' or 'mydata'. This image is only used to recover the following information |handles.XXX.info.ImagePositionPatient|, |handles.XXX.info.Spacing| and size.
%
% |outname| - _STRING_ -  Name of the file in which the matrix is saved. The extension '.vtk' will be appended
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
% |handles| - _STRUCTURE_ -  REGGUI data structure. No change to the input.
%
%
%% Contributors
% Author : Luiza Bondar (open.reggui@gmail.com)

function handles = Export_contour_to_mesh(binary_mask,ref_image,outname,handles)

save_to_vtk(Compute_mesh(ref_image, binary_mask, handles), [outname '.vtk']);
