%% Volume_computation
% Compute the volume (in mm^3) of the structure in image |im| contained in |handles.mydata| or |handles.images|. The structure is defined by all the voxels with an intensity larger than 50% of the maximum intensity in the image.
%
%% Syntax
% |res = Volume_computation(im,handles)|
%
%
%% Description
% |res = Volume_computation(im,handles)| describes the function
%
%
%% Input arguments
% |im| - _STRING_ -  Name of the image contained in |handles.mydata| for which the volume is computed
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the ith image
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) of the ith image
% * |handles.mydata.info{i}.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the ith images in |mydata|
%
%
%% Output arguments
%
% |res| - _SCALAR_ - Volume in (mm^3) of the structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Volume_computation(im,handles)

res = 0;

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im))
        myIm = handles.mydata.data{i};
        myInfo = handles.mydata.info{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im))
        myIm = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
try
    myIm = double(myIm >= max(max(max(myIm)))/2);
    res = sum(sum(sum(myIm)));
    disp(['Number of voxels in ',im,' = ',num2str(round(res))])
    if(not(ndims(myIm)==length(myInfo.Spacing)))
        error('Dimension does not match with spacing...')
    end
    for i=1:ndims(myIm)
       res = res.*myInfo.Spacing(i);
    end
    if(length(myInfo.Spacing)==2)
        disp(['Surface of ', im, '  =  ', num2str(round(res)) ,' [mm^2]']);
    else
        disp(['Volume of ', im, '  =  ', num2str(round(res)) ,' [mm^3]']);
    end
catch ME
    reggui_logger.info(['Error : images not found or uncorrect size. ',ME.message],handles.log_filename);
    rethrow(ME);
end
