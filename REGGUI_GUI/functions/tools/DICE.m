%% DICE
% Compute the DICE coefficient between two images [1].
%
%% Syntax
% |res = DICE(im1,im2,handles)|
%
%
%% Description
% |res = DICE(im1,im2,handles)| Compute the DICE coefficient
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the first image in |handles.images|, |handles.fileds| or |handles.mydata| or |handles.fields| 
%
% |im2| - _STRING_ -  Name of the second image in |handles.images|, |handles.fileds| or |handles.mydata|  or |handles.fields|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images', 'fields' or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - The results:
%
% * |res(1)| = the DICE coefficient between the 2 images
% * |res(2)| = the concordance index between the 2 images
%
%% References
%
% [1] https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = DICE(im1,im2,handles)

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm1 = handles.mydata.data{i};
    end
    if(strcmp(handles.mydata.name{i},im2))
        myIm2 = handles.mydata.data{i};
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},im1))
        myIm1 = handles.fields.data{i};
    end
    if(strcmp(handles.fields.name{i},im2))
        myIm2 = handles.fields.data{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm1 = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},im2))
        myIm2 = handles.images.data{i};
    end
end
try
    myIm1 = double(myIm1 >= max(max(max(myIm1)))/2);
    myIm2 = double(myIm2 >= max(max(max(myIm2)))/2);
    dice_coef = sum(sum(sum(2*double(myIm1 & myIm2)))) / sum(sum(sum(myIm1+myIm2)));
    concordance_index = sum(sum(sum(double(myIm1 & myIm2)))) / sum(sum(sum(double(myIm1 | myIm2))));
    if(isnan(dice_coef))
        disp('These masks are empty...')
    else
        res = [dice_coef concordance_index];
        disp(['DICE coefficient between images ', im1, ' and ', im2, '  =  ', num2str(dice_coef)]);
        disp(['Concordance Index between images ', im1, ' and ', im2, '  =  ', num2str(concordance_index)]);
    end
catch
    disp('Error : images not found or uncorrect size!')
end
