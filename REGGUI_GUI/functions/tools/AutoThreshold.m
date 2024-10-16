%% AutoThreshold
% Threshold an image. Use the SOT function (=Otsu Threshold Segmentation [2]) from the matik tool box [1].
%
%% Syntax
% |handles = AutoThreshold(image,params,im_dest,handles)|
%
%
%% Description
% |handles = AutoThreshold(image,params,im_dest,handles)| describes the function
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image in |handles.images| or |handles.mydata| (if absent in |handles.images|) which must be thresholded
%
% |params| - _SCALAR_ -  Number of histogram bin used by the Otsu Threshold algorithm
%
% |im_dest| - _STRING_ -  Name of the new image in |handles.images| or |handles.mydata| (same location as input data) where the couch mask will be stored
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images' or "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the couch mask = |couch_name|
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| 1 if the voxel at coordinate (x,y,z) belongs to the couch. 0 otherwise.
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.images.OriginalHeader| or |handles.mydata.OriginalHeader|
%
%
%% References
% [1] http://matitk.cs.sfu.ca/
% [2] http://designest.de/2009/11/matitk-additional-documentation/

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = AutoThreshold(image,params,im_dest,handles)

% Authors : G.Janssens

myImage = [];
type = 1;
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},image))
        myImage = handles.mydata.data{i};
        myInfo = handles.mydata.info{i};
        type = 3;
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
        type = 1;
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
end
if(ndims(myImage)==2)
    error('Not implemented for 2D images')
else
    im_res = matitk('SOT',params,myImage);
    im_res = im_res - min(im_res(:));
    if(max(im_res(:))>1)
        im_res = round(im_res/max(im_res(:)));
    end
    if(type==3)
        if(ndims(im_res)==3)
            im_dest = check_existing_names(im_dest,handles.mydata.name);
            handles.mydata.name{length(handles.mydata.name)+1} = im_dest;
            handles.mydata.data{length(handles.mydata.data)+1} = single(im_res);
            handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
        else
            error('Error: this data is not an image !!')
        end
    else
        im_dest = check_existing_names(im_dest,handles.images.name);
        handles.images.name{length(handles.images.name)+1} = im_dest;
        handles.images.data{length(handles.images.data)+1} = single(im_res);
        info = Create_default_info('image',handles);
        if(isfield(myInfo,'OriginalHeader'))
            info.OriginalHeader = myInfo.OriginalHeader;
        end
        handles.images.info{length(handles.images.info)+1} = info;
    end
end
