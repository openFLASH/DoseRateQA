%% Manual_translation
% Create a rigid transform (translation only) from a vector (defined by 2 points |pt1| and |pt2|).
% The function applies the transform on an input image and returns the image deformed by this transform and a field representing the rigid transform.
%
%% Syntax
% |handles = Manual_translation(image,pt1,pt2,def_image_name,transform_name,type,handles,pixel_space)|
%
%
%% Description
% |handles = Manual_translation(image,pt1,pt2,def_image_name,transform_name,type,handles,pixel_space)| describes the function
%
%
%% Input arguments
% |image| - _STRING_ - Name of the image in |handles.XXX| to be translated (where XXX is either 'images' of "mydata", depending on |type|)
%
% |pt1| - _SCALAR VECTOR_ -  Coordinate of the initial position of the reference point before translation. See |pixel_space| for units.
%
% |pt2| - _SCALAR VECTOR_ -  Coordinate of the finbal position of the same reference point before translation.  See |pixel_space| for units.
%
% |def_image_name| - _STRING_ - Name of the translated image in |handles.XXX.images| (where XXX is either 'images' of "mydata")
%
% |transform_name| - _STRING_ - Name of the rigid transformation in |handles.fields|
%
% |type| - _INTEGER_ - Define where the input data is stored.
%
% * |type=1| : Input data is stored in |handles.images|
% * Otherwise : Input data is stored in |handles.mydata|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |pixel_space| - _BOOLEAN_ -  Define the coordinate system of the |pt2 - pt1| translation vector:
%
% * |pixel_space = true| : |pt2 - pt1| is the (x,y,z) translation vector (in pixels) of the origin of the *patient* C.S. 
% * |pixel_space = false|  : |pt2 - pt1| is the (x,y,z) translation vector (in mm) of the *image* C.S.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the resulting data. The following data is updated in the structure (where XXX is either 'images' of "mydata" depending on input data):
%
% * |handles.XXX.name{i}| - _STRING_ - The deformed image name = |def_image_name| 
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image. Copied from input data
% * |handles.fields.name{i}| - _STRING_ - Name of the output rigid deformation field = |transform_name|
% * |handles.fields.data{i}| _SCALAR MATRIX_ - Matrix representing the translation - rotation transform:
% * ---- |handles.fields.data(1,:)| - _SCALAR VECTOR_ - Translation vector (x,y,z) (in pixels) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * -----|handles.fields.data(2,:)| - _SCALAR VECTOR_ - Translation vector (x,y,z) (in mm) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * -----|handles.fields.data(3-5,:)| - _SCALAR MATRIX_ - Rotation matrix (3x3 matrix). The rotation matrix is NULL (to be provided to |rigid_deformation| function)
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the field. Field type is *rigid_transform*
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Manual_translation(image,pt1,pt2,def_image_name,transform_name,type,handles,pixel_space)

if(type==1)
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},image))
            myImage = handles.images.data{i};
            myInfo = handles.images.info{i};
        end
    end
else
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},image))
            myImage = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
        end
    end
end
try
    if(nargin<8)
        pixel_space = 0;
    end
    deformed = zeros(handles.size(1),handles.size(2),handles.size(3));
    if(pixel_space)% old version...
        x = round(pt1 - pt2);
        total_translation = x.*handles.spacing' + (handles.origin - myInfo.ImagePositionPatient)';
        deformed(1+max(0,x(1)):min(size(deformed,1),size(myImage,1)+x(1)),1+max(0,x(2)):min(size(deformed,2),size(myImage,2)+x(2)),1+max(0,x(3)):min(size(deformed,3),size(myImage,3)+x(3)))=...
            myImage(1+max(0,-x(1)):min(size(myImage,1),size(deformed,1)-x(1)),1+max(0,-x(2)):min(size(myImage,2),size(deformed,2)-x(2)),1+max(0,-x(3)):min(size(myImage,3),size(deformed,3)-x(3)));
    else
        total_translation = pt2 - pt1 ;
        x = round(( total_translation - (handles.origin - myInfo.ImagePositionPatient)')./ handles.spacing');
        deformed = rigid_deformation(myImage,[x;total_translation;eye(3)],myInfo.Spacing,myInfo.ImagePositionPatient);
    end
    disp(['Global translation : ',num2str(total_translation)]);
catch ME
    reggui_logger.info(['Error: image not found or invalid reference points. ',ME.message],handles.log_filename);
    rethrow(ME);
end
if(type==1)
    def_image_name = check_existing_names(def_image_name,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = def_image_name;
    handles.images.data{length(handles.images.data)+1} = single(deformed);
    info = Create_default_info('image',handles,myInfo);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.images.info{length(handles.images.info)+1} = info;
elseif(type==3)
    def_image_name = check_existing_names(def_image_name,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = def_image_name;
    handles.mydata.data{length(handles.mydata.data)+1} = single(deformed);
    info = Create_default_info('image',handles,myInfo);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.mydata.info{length(handles.mydata.info)+1} = info;
end
transform_name = check_existing_names(transform_name,handles.fields.name);
handles.fields.name{length(handles.fields.name)+1} = transform_name;
handles.fields.data{length(handles.fields.data)+1} = [x;total_translation;zeros(3,3)]; 
% No rotation is required, one should provide either an identity matrix. The identity matrix respects the mathematical formalism for "no rotation". However, the output of the |Manual_translation| is typically given to the function |rigid_deformation|. When |rigid_deformation| receives a null matrix, it will ignore it and will simply apply a translation. The result is the same as the identity matrix (if mathematically less formal) but the results are computed faster.

handles.fields.info{length(handles.fields.info)+1} = Create_default_info('rigid_transform',handles);
