%% Image_histeq
% Apply histogram equalization to an image in |handles.images|
%
%% Syntax
% |handles = Image_histeq(im1,im_dest,type='CT',factor,handles)|
%
% |handles = Image_histeq(im1,im_dest,type,factor,handles,im2)|
%
%
%% Description
% |handles = Image_histeq(im1,im_dest,type,factor,handles)| Apply histogram equalization
%
% |handles = Image_histeq(im1,im_dest,type,factor,handles,im2)| Apply histogram equalization to |im1| using the histogram of |im2|
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the image contained in |handles.images.name| to be equalized
%
% |im_dest| - _TYPE_ -  description
%
% |type| - _STRING_ -  Defines the type of |im1|. The only available option is 'ct'. If |im2| is provided, this parameter is ignored.
%
% |factor| - _TYPE_ -  description
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |im2| - _STRING_ -  [OPTIONAL] Name of the image contained in |handles.images.name| providing the reference histogram for equalization
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
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Image_histeq(im1,im_dest,type,factor,handles,im2)

for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm = handles.images.data{i};
        minim = min(myIm(:));
        myIm = myIm - minim;
    end
end
if(nargin>5)
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},im2))
            myIm2 = handles.images.data{i};
            myIm2 = myIm2 - min(myIm2(:));
        end
    end
    myIm2D = double(squeeze(reshape(myIm,[size(myIm,1) size(myIm,2)*size(myIm,3) 1])));
    myImbis2D = double(squeeze(reshape(myIm2,[size(myIm2,1) size(myIm2,2)*size(myIm2,3) 1])));
    maxim = ceil(max(max(abs(myIm2D))));
    myIm2D = myIm2D/maxim;
    myImbis2D = myImbis2D/maxim;
    histRes = imhist(myImbis2D,round(maxim/32));
    imRes = histeq(myIm2D,histRes);
    imRes = reshape(imRes,size(myIm))*maxim;
else
    switch type
        case 'ct'
            myIm2D = double(squeeze(reshape(myIm,[size(myIm,1) size(myIm,2)*size(myIm,3) 1])));
            maxim = ceil(max(max(abs(myIm2D))));
            myIm2D = myIm2D/maxim;
            histRes = imhist(myIm2D,maxim);
            if(length(histRes)<=200)
                error('This is not a CT image (maximum value is too low !')
            end
            equalizator = sum(histRes(201:end))/(length(histRes)-200);
            if(factor<0 || factor>100)
                error('Unvalid contrast enhancement factor (out of range [0 100])')
            end
            histRes(201:end) = ((100-factor)*histRes(201:end) + factor*equalizator)/100;
            imRes = histeq(myIm2D,histRes);
            imRes = reshape(imRes,size(myIm))*maxim;
    end
end
im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(imRes + minim);
handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles);
