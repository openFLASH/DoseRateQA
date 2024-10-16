%% Difference
% Compute the difference |im1 - im2| for images stored either in |handles.mydata| or |handles.images| or deformation fields in |handles.fields| 
%
%% Syntax
% |handles = Difference(im1,im2,im_dest,handles)|
%
%
%% Description
% |handles = Difference(im1,im2,im_dest,handles)| computes the difference |im1 - im2|
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the first image in |handles.images|, |handles.fileds| or |handles.mydata| 
%
% |im2| - _STRING_ -  Name of the second image in |handles.images|, |handles.fileds| or |handles.mydata| 
%
% |im_dest| - _STRING_ -  Name of the difference image in |handles.images|, |handles.fileds| or |handles.mydata|, depending on location of input data
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images', 'fields' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images', 'fields' or "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the resulting image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| resulting intensity at voxel (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Created with Create_default_info.m
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [handles,mean_SSD] = Difference(im1,im2,im_dest,handles)

% Authors : G.Janssens

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm1 = handles.mydata.data{i};
        myType1 = 4;
        myTrueType1 = handles.mydata.info{i}.Type;
        myInfo = handles.mydata.info{i};
    end
    if(strcmp(handles.mydata.name{i},im2))
        myIm2 = handles.mydata.data{i};
        myType2 = 4;
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},im1))
        myIm1 = handles.fields.data{i};
        myType1 = 2;
        myInfo = handles.fields.info{i};
    end
    if(strcmp(handles.fields.name{i},im2))
        myIm2 = handles.fields.data{i};
        myType2 = 2;
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm1 = handles.images.data{i};
        myType1 = 1;
        myInfo = handles.images.info{i};
    end
    if(strcmp(handles.images.name{i},im2))
        myIm2 = handles.images.data{i};
        myType2 = 1;
    end
end
try
    imDiff = myIm1 - myIm2;
    mean_SSD = mean(imDiff(:).^2);
catch
    error('Error : data not found or uncorrect sizes!')
end
disp(['mean SSD = ' num2str(mean_SSD)]);
if(myType1==1 && myType2==1)
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = single(imDiff);
    handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles,myInfo);
    handles.minscale = min(min(min(min(imDiff))));
    handles.maxscale = max(max(max(max(imDiff))));
elseif(myType1==2 && myType2==2)
    im_dest = check_existing_names(im_dest,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = im_dest;
    handles.fields.data{length(handles.fields.data)+1} = imDiff;
    handles.fields.info{length(handles.fields.info)+1} = Create_default_info('deformation_field',handles,myInfo);
elseif(myType1==4 && myType2==4)
    im_dest = check_existing_names(im_dest,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = im_dest;
    handles.mydata.data{length(handles.mydata.data)+1} = imDiff;
    handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info(myTrueType1,handles,myInfo);
end
