%% Watersheds
% Segment the image by water sheding. The method uses the function SWS from the MATITK library [1].
% A sinlge object is extracted out of the image. This object is identified by defining the coordinate of one voxel belonging to the object in the input image. the watershed is spread around, starting from this voxel coordinate.
% The output image is a mask with voxels belonging to  the object set = 1.
%
%% Syntax
% |handles = Watersheds(image,params,im_dest,handles)|
%
%
%% Description
% |handles = Watersheds(image,params,im_dest,handles)| Segment the image by water sheding
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed
%
% |params| - _SCALAR VECTOR_ -  Watersheding parameters
%
% *  |params(1)| : watershed depth
% *  |params(2)| : lower thresholding of the input
% *  |params(3:4)| : (x,y,z) coordinates (in pixel) of one voxel belonging to the object to be extracted out of the image
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
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Watersheds(image,params,im_dest,handles)

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
    myImage = single(matitk('SWS',params(1:2),myImage));
    %myImage = watershed(myImage,18);
    if(length(params)>4)
        im_res = zeros(size(myImage),'single');
        test = [params(3);params(4);params(5)];
        tolerance = round(max(max(max(myImage)))/256);
        mean = myImage(params(3),params(4),params(5));
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
    else
        im_res = myImage;
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
