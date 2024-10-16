%% Mask2DistMap
% Compute the distance map. The distance map d(X) gives for every voxel X its distance to the closest point belonging to a structure S. The distance map is signed, where values are negative inside the structure and positive outside the structure.
% See section "2.1.5 Distance maps" of reference [1] for more information
%
%% Syntax
% |handles = Mask2DistMap(image,dm_dest,normalize,handles)|
%
%
%% Description
% |handles = Mask2DistMap(image,dm_dest,normalize,handles)| Description
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image in |handles.images| to be tresholded
%
% |dm_dest| - _STRING_ - Name of the resulting image in |handles.images|
%
% |normalize| - _SCALAR_ - 0 = Do not renormalise. 1 = renormalise distances from -128 to +127. 2 = non-linear rescaling of distances (atan)
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info|
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Mask2DistMap(image,dm_dest,normalize,handles)

for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        input = handles.images.data{i};
    end
end
try
    distmap = compute_distmap(input);

    if(normalize==1)% piece-wise linear (positive and negative separately) from -128 to +127
        distmap(distmap>0) = distmap(distmap>0)/max(max(distmap(distmap>0)))*128;
        distmap(distmap<0) = distmap(distmap<0)/max(max(abs(distmap(distmap<0))))*127;
        distmap = distmap+128;
    elseif(normalize==2)% non-linear distance
        dist_to_border = mean([size(distmap,1),size(distmap,2),size(distmap,3)])/4;
        distmap = atan(distmap/dist_to_border)*atan(dist_to_border);
    end

    dm_dest = check_existing_names(dm_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = dm_dest;
    handles.images.data{length(handles.images.data)+1} = single(distmap);
    handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles);
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
