%% Lung_segmentation
% Create a mask image defining the lung RT-structure in the CT scan. The lung are defined as the low density tissues with Hounsfield units -950 < HU < |param|
%
%% Syntax
% |handles = Lung_segmentation(image,body,{},im_dest,handles)|
%
% |handles = Lung_segmentation(image,body,params,im_dest,handles)|
%
%
%% Description
% |handles = Lung_segmentation(image,body,{},im_dest,handles)| Segment the lung structure out of the CT scan using the default maximum HU value
%
% |handles = Lung_segmentation(image,body,params,im_dest,handles)| Segment the lung structure out of the CT scan
%
%
%% Input arguments
% |image|- _STRING_ -  Name of the image contained in |handles.images.name| to be segmented. Must be a 3D image
%
% |body|- _STRING_ -  Name of the image contained in |handles.images.name| containing the RT-struct defining the body contour
%
% |params| - _CELL_ -  |params{1}| Defines the maximum Hounsfield unit of the lung tissue. If |params| is empty, the default value is HU = -350
%
% |im_dest|- _STRING_ -  Name of the image contained in |handles.images.name| where to save the RT-struct of the lung contours
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
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.image.info|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Lung_segmentation(image,body,params,im_dest,handles)

% Authors : G.Janssens

myImage = [];
type = 1;
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},body))
        myBody = handles.images.data{i};
    end
end

if(isempty(myImage) || isempty(myBody))
    error('Error : input image not found in the current list !')
end
if(ndims(myImage)==2)
    error('Not implemented for 2D images')
else
    % detect low-density tissues
    if(isempty(params))
        params = {-350};
    end
    im_res = myImage<params{1} & myImage>-950;
    
    % remove out-of-body
    k = [4 4 4];
    myStrel = Compute_strel(k,handles);
    myBody = imdilate(myBody,myStrel);
    im_res = im_res.*myBody;
    
    % remove small parts
    k = [3 3 4];
    myStrel = Compute_strel(k,handles);
    im_res = imerode(single(im_res),myStrel);
    im_res(isinf(im_res)) = 0;
    im_res = imdilate(single(im_res),myStrel);
    im_res(isinf(im_res)) = 0;
    myStrel = Compute_strel(k,handles);
    im_res = imdilate(single(im_res),myStrel);
    im_res(isinf(im_res)) = 0;
    im_res = imerode(single(im_res),myStrel);
    im_res(isinf(im_res)) = 0;
    
    % keep only the two largest regions
    CC1 = bwconncomp(im_res);
    numPixels = cellfun(@numel,CC1.PixelIdxList);
    [biggest1,idx1] = max(numPixels);
    temp = im_res;
    temp(CC1.PixelIdxList{idx1}) = 0;
    CC2 = bwconncomp(temp);
    numPixels = cellfun(@numel,CC2.PixelIdxList);
    [biggest2,idx2] = max(numPixels);
    
    im_res = im_res*0;
    im_res(CC1.PixelIdxList{idx1}) = 1;
    if(biggest2>biggest1/3) % do not keep if too different (i.e. lungs are connected)
        im_res(CC2.PixelIdxList{idx2}) = 1;
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
