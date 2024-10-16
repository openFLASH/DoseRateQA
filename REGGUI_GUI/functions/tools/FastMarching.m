%% FastMarching
% Apply the Fast March Segmentation of MATITK [1] to a 3D image contained in |handles.images|.
%
%% Syntax
% |handles = FastMarching(image,params,im_dest,handles)|
%
%
%% Description
% |handles = FastMarching(image,params,im_dest,handles)| Apply the Fast March Segmentation on the image
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
% * ----|params(4)| - _SCALAR_ Stoppping time
%
% |image_dest| - _STRING_ -  Name of the new image created in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.view_point| - _INTEGER VECTOR_ Coordinate (in pixel, origin at 1st voxel) of the isocentre in the image
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

function handles = FastMarching(image,params,im_dest,handles)

% Authors : G.Janssens

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
    if(length(params)>4)
        params(4)=params(1);
        params(1:3) = handles.view_point';
    end
    myImage = matitk('FGM',[],myImage);
    myImage = 1-(myImage-min(myImage(:)))/(max(myImage(:))-min(myImage(:))+eps);
    myImage = (myImage.^1e2);
    stopping_time = params(4);
    im_res = matitk('SFM',stopping_time,single(myImage),single([]),round(params(1:3)),[handles.spacing']/1e3);
    im_res = im_res - min(min(min(im_res)));
    if(max(max(max(im_res)))>1)
        im_res = 1 - round(im_res/max(max(max(im_res))));
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
