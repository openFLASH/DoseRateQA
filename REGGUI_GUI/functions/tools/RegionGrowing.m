%% RegionGrowing
% Apply the region growing segmentation to a 3D image contained in |handles.images|. The region growth from the seed points. the boundary is defined by the voxel with an intensity deviating by more than the |tolerance| from the intensity of the seed point. 
%
%% Syntax
% |handles = RegionGrowing(image,params,im_dest,handles)|
%
%
%% Description
% |handles = RegionGrowing(image,params,im_dest,handles)| Apply the region growing segmentation on the image
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed
%
% |params| - _SCALAR or SCALAR VECTOR_ -  Parameters for Fast March Segmentation. There are two syntax:
%
% * |params = S| - _SCALAR_ Stoppping time. The seed point is given by |handles.view_point|
% 
% * |params| - _SCALAR VECTOR_ :
% * ----|params(1:3)| - _SCALAR VECTOR_ Coordinate (in pixel) of the seed point
% * ----|params(4)| - _SCALAR_ Tolerance. The voxels belongs to the object if their intensity deviate from the seed point intensity by a value smaller than the tolerance.
%
% |image_dest| - _STRING_ -  Name of the new image created in |handles.images|
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
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| 1 = The voxel at coordinate (x,y,z) belongs to the object. 0, otherwise
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.images.info| or original image
%
%% References
%
% [1] http://matitk.cs.sfu.ca/usageguide
% [2] https://www.cs.sfu.ca/~hamarneh/ecopy/spiemi2006a.pdf
% [3] http://www.vincentchu.com/projects/MATITKUsageAndExample.pdf
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = RegionGrowing(image,params,im_dest,handles)


myImage = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
end
if(ndims(myImage)==2)
    error('Not implemented for 2D images')
else
    im_res = zeros(size(myImage),'single');
    test = [params(1);params(2);params(3)];
    tolerance = params(4);
    mean = myImage(params(1),params(2),params(3));
    nmb_seg_voxels = 1;
    while length(test)~=0
        x = test(1,1);
        y = test(2,1);
        z = test(3,1);
        test = test(:,2:size(test,2));
        for i=-1:1
            for j=-1:1
                for k=-1:1
                    if( (i||j||k) && (x+i<size(myImage,1)+1) && (y+j<size(myImage,2)+1) && (z+k<size(myImage,3)+1) && (x+i>0) && (y+j>0) && (z+k>0))
                        if (abs(myImage(x+i,y+j,z+k)-mean)<=tolerance && im_res(x+i,y+j,z+k)==0)
                            im_res(x+i,y+j,z+k) = 1;
                            mean = (mean*nmb_seg_voxels+myImage(x+i,y+j,z+k))/(nmb_seg_voxels+1);
                            nmb_seg_voxels = nmb_seg_voxels +1;
                            test = [test [x+i;y+j;z+k]];
                        end
                    end
                end
            end
        end
    end
    
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = single(im_res);
    info = Create_default_info('image',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.images.info{length(handles.images.info)+1} = info;
end
