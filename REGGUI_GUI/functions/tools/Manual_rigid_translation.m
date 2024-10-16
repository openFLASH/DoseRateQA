%% Manual_rigid_translation
% Display an image viewer to perform a manual rigid registration. The same point is clicked in 2 images. A rigid deformation field is then computed from the vector joining the 2 points nad the result is stored in |handles|
%
%% Syntax
% |handles = Manual_rigid_translation(image1,type1,image2,type2,myImageName,myFieldName,handles)|
%
%
%% Description
% |handles = Manual_rigid_translation(image1,type1,image2,type2,myImageName,myFieldName,handles)| Compute the rigid transform
%
%
%% Input arguments
% |image1| - _STRING_ -  Name of the first image in |handles.images| or |handles.mydata| 
%
% |type1| - _SCALAR_ -  1 = the first image is in |handles.images|. 2 = the image is in |handles.mydata|  
%
% |image2| - _STRING_ -  Name of the second image in |handles.images| or |handles.mydata|
%
% |type2| - _SCALAR_ -  1 = the second image is in |handles.images|. 2 = the image is in |handles.mydata|
%
% |myImageName| - _STRING_ - Name of the translated image in |handles.XXX.images| (where XXX is either 'images' of "mydata")
%
% |myFieldName| - _STRING_ - Name of the rigid transformation in |handles.fields|
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
% |handles| - _STRUCTURE_ -  REGGUI data structure with the resulting data. The following data is updated in the structure (where XXX is either 'images' or "mydata" depending on the second image):
%
% * |handles.XXX.name{i}| - _STRING_ - The deformed image name = |def_image_name| 
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image. Copied from input data
% * |handles.fields.name{i}| - _STRING_ - Name of the output rigid deformation field = |transform_name|
% * |handles.fields.data{i}| - _SCALAR MATRIX_ - Matrix representing the translation - rotation transform:
% * ---- |handles.fields.data(1,:)| - _SCALAR VECTOR_ - Translation vector (x,y,z) (in pixels) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * -----|handles.fields.data(2,:)| - _SCALAR VECTOR_ - Translation vector (x,y,z) (in mm) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * -----|handles.fields.data(3-5,:)| - _SCALAR MATRIX_ - Rotation matrix (3x3 matrix). The rotation matrix is NULL (to be provided to |rigid_deformation| function)
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the field. Field type is *rigid_transform*
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Manual_rigid_translation(image1,type1,image2,type2,myImageName,myFieldName,handles)

if(type1==1)
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},image1))
            myImage = handles.images.data{i};
            myInfo = handles.images.info{i};
        end
    end
else
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},image1))
            myImage = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
        end
    end
end
pt1 = image_viewer(myImage,myInfo);
if(type2==1)
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},image2))
            myImage = handles.images.data{i};
            myInfo = handles.images.info{i};
        end
    end
else
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},image2))
            myImage = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
        end
    end
end
pt2 = image_viewer(myImage,myInfo);
eval(['handles = Manual_translation(''' image2 ''',' pt1 ',' pt2 ',''' myImageName ''',''' myFieldName ''',' num2str(type2) ',handles);']);
