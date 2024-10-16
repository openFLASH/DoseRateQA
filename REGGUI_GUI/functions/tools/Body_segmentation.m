%% Body_segmentation
% Create an image defining the mask of the contour of the patient body in a CT scan. The function remove the air, the couch and external objects.
%
%% Syntax
% |handles = Body_segmentation(image,im_dest,handles)|
%
%
%% Description
% |handles = Body_segmentation(image,im_dest,handles)| Create a mask defining the body contour
%
%
%% Input arguments
% |image_name| - _STRING_ -  Name of the image contained in |handles.mydata.name| or in |handles.images.name| to be processed
%
% |image_dest| - _STRING_ -  Name of the new image created in |handles.mydata.name| or in |handles.images.name| (depending on location of input)
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images' or "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the resulting image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| =1 if the voxel (x,y,z) belongs to the body. 0, otherwise
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Created with Create_default_info.m
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Body_segmentation(image,im_dest,handles)

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
    % Air detection
    % -------------
    
    im_res = myImage>-750;%matitk('SOT',128,myImage);
    im_res = im_res - min(im_res(:));
    if(max(im_res(:))>1)
        im_res = round(im_res/max(im_res(:)));
    end
    
    % Table detection
    % ---------------
    
    % Opening in the y direction (AP)
    k = [1 30 1];
    myStrel = Compute_strel(k,handles);
    temp = imerode(single(im_res),myStrel);
    temp(isinf(temp)) = 0;
    temp = imdilate(single(temp),myStrel);
    temp(isinf(temp)) = 0;
    temp = im_res - temp;
    % Opening in the xz directions (LR,SI)
    k = [3 1 3];
    myStrel = Compute_strel(k,handles);
    temp = imerode(single(temp),myStrel);
    temp(isinf(temp)) = 0;
    temp = imdilate(single(temp),myStrel);
    temp(isinf(temp)) = 0;
    proj = sum(sum(temp,3),1);
    [~,table_index]=max(proj);
    im_res(:,table_index:end,:)=0;
    
    % Body definition
    % ---------------
    
    k = [5 5 5];
    myStrel = Compute_strel(k,handles);
    temp = imerode(single(im_res),myStrel);
    temp(isinf(temp)) = 0;
    k = [10 10 10];
    myStrel = Compute_strel(k,handles);
    temp = imdilate(single(temp),myStrel);
    temp(isinf(temp)) = 0;
    temp = imerode(single(temp),myStrel);
    temp(isinf(temp)) = 0;
    im_res = (1-im_res).*(1-temp);
    
    % Out-of-patient region detection
    CC = bwconncomp(im_res,6);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = max(numPixels);
    im_res = im_res*0 + 1;
    im_res(CC.PixelIdxList{idx}) = 0;
    
    % Remove remaining couch parts
    k = [3 5 1];
    myStrel = Compute_strel(k,handles);
    im_res = imerode(single(im_res),myStrel);
    im_res(isinf(im_res)) = 0;
    im_res = imdilate(single(im_res),myStrel);
    im_res(isinf(im_res)) = 0;
    
    % Remove other objects
    CC = bwconncomp(im_res,6);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    if(not(isempty(idx)))
        im_res = im_res*0;
        im_res(CC.PixelIdxList{idx}) = 1;
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
end
