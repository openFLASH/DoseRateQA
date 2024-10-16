%% Conformity_index
% Compute the Conformity index between two volumes (binary images).
%
%% Syntax
% |res = Conformity_index(im1,im2,handles)|
%
%
%% Description
% |res = Conformity_index(im1,im2,handles)| Compute the Conformity_index coefficient
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the first image in |handles.images|, |handles.fileds| or |handles.mydata|
%
% |im2| - _STRING_ -  Name of the second image in |handles.images|, |handles.fileds| or |handles.mydata|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images', 'fields' or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - The results:
%
% * |res(1)| = the Conformity_index coefficient between the 2 images
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Conformity_index(im1,im2,handles)

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm1 = handles.mydata.data{i};
    end
    if(strcmp(handles.mydata.name{i},im2))
        myIm2 = handles.mydata.data{i};
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
    myIm1 = double(myIm1 >= max(myIm1(:))/2);
    myIm2 = double(myIm2 >= max(myIm2(:))/2);
    CI = sum(sum(sum(myIm1))) / sum(sum(sum(myIm2)));
    if(isnan(CI))
        disp('These masks are empty...')
    else
        res = CI;
        disp(['Conformity_index between volumes ', im1, ' and ', im2, '  =  ', num2str(CI)]);
    end
catch
    disp('Error : images not found or uncorrect size!')
end
