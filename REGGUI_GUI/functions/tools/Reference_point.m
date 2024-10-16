%% Reference_point
% Compute the coordinate (in pixels) of reference points in one (or several) images (or deformation fileds) and interpolate the value of the image (or deformation filed) at those points. The results are saved in |handles| as tow new data objects: with 'point' and 'interpolated_values' data types.
%
%% Syntax
% |[handles,values,point,point_realspace] = Reference_point(data_dest,input,handles)|
%
% |[handles,values,point,point_realspace] = Reference_point(data_dest,input,handles,coord)|
%
% |[handles,values,point,point_realspace] = Reference_point(data_dest,input,handles,coord,data_dest_values)|
%
%
%% Description
% |[handles,values,point,point_realspace] = Reference_point(data_dest,input,handles)| The reference points are selected in a GUI. The point coordinates are saved in |handles.mydata|.
%
% |[handles,values,point,point_realspace] = Reference_point(data_dest,input,handles,coord)| The coordinates (in mm) of the reference points are provided as input. The point coordinates are saved in |handles.mydata|.
%
% |[handles,values,point,point_realspace] = Reference_point(data_dest,input,handles,coord,data_dest_values)|  The coordinates (in mm) of the reference points are provided as input. The point coordinates and the interpolated values are saved in |handles.mydata|.
%
%
%
%% Input arguments
% |data_dest| - _STRING_ -  Name of the new object created in |handles.mydata| with the coordinates of the reference points
%
% |input| - _CELL VECTOR of STRING_ -  |input{i}| Name of the i-th image contained in |handles.XXX.name| to be processed
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images', 'mydata' or 'fields'):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.XXX.info{i}.Spacing| - _VECTOR of DOUBLE_ -  Size of the voxels in |mm|.
% * |handles.XXX.info{i}.ImagePositionPatient| - _SCALAR VECTOR_ Coordinate  (x,y,z) (in mm) of the first pixel of the image in the *patient* C.S.
% * |handles.view_point| - _INTEGER VECTOR_ Coordinate (in pixel, origin at 1st voxel) of the isocentre in the image
%
% |coord| - _SCALAR MATRIX_ - |coord(pt,:)=[x,y,z]| Coordinates (in mm) of the pt-th reference point.
%
% |data_dest_values| - _STRING_ -  Name of the new image created in |handles.mydata| with the coordinates of the interpolated values
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - The data object |data_dest| is: |data{i}(pt,:)| Coordinates (x,y,z) (in pixels) of the pt-th reference point.
% * |handles.mydata.data{i}{im,pt}| - _CELL MATRIX_ - The data object |data_dest_values| is: |data{i}{im,pt}| Interpolated intensity in the im-th image of the voxel located at the pt-th reference point.
% * |handles.mydata.info{i}.OriginalHeader| : copied from |handles.XXX.info| if present
%
% |values| - _CELL MATRIX_ - |data{i}{im,pt}| Interpolated intensity in the im-th image of the voxel located at the pt-th reference point.
%
% |point| - _SCALAR MATRIX_ -  |point(pt,:)| Coordinates (x,y,z) (in pixels) of the pt-th reference point.
%
% |point_realspace| - _SCALAR MATRIX_ -  |point(pt,:)| Coordinates (x,y,z) (in mm) of the pt-th reference point.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [handles,values,point,point_realspace] = Reference_point(data_dest,input,handles,coord,data_dest_values)


type = 1;
values = cell(0);
if(nargin>3)
    if(size(coord,1)==1 && size(coord,2)==3)
        coord = coord';
    end
end
if(not(iscell(input)))
    image{1} = input;
else
    image = input;
end
for im=1:length(image)

    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},image{im}))
            myImage = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
            type=1;
        end
    end
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},image{im}))
            myImage = handles.fields.data{i};
            myInfo = handles.fields.info{i};
            type=2;
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},image{im}))
            myImage = handles.images.data{i};
            myInfo = handles.images.info{i};
            if(strcmp(myInfo.Type,'deformation_field'))
                type=2;
            else
                type=1;
            end
        end
    end

    if(nargin>3)
        for pt=1:size(coord,1)
            point(pt,:) = (coord(pt,:)-myInfo.ImagePositionPatient')./myInfo.Spacing' +1;
        end
    else
        if(im==1)
            point = str2num(image_viewer(myImage,myInfo,'point',handles.view_point'));
        end
    end
    if(nargout>1 || nargin>4)
        for pt=1:size(point,2)
            if(type==2)
                values{im,pt}(1) = interp3(squeeze(myImage(1,:,:,:)),point(2,pt),point(1,pt),point(3,pt))*myInfo.Spacing(1);
                values{im,pt}(2) = interp3(squeeze(myImage(2,:,:,:)),point(2,pt),point(1,pt),point(3,pt))*myInfo.Spacing(2);
                values{im,pt}(3) = interp3(squeeze(myImage(3,:,:,:)),point(2,pt),point(1,pt),point(3,pt))*myInfo.Spacing(3);
            else
                values{im,pt} = interp3(myImage,point(2,pt),point(1,pt),point(3,pt));
            end
        end
    end
end
point_realspace = (point-1).*myInfo.Spacing' + myInfo.ImagePositionPatient';
if(length(image)==1)
disp(['Reference point : ',num2str(point),' [pixels]  =  ',num2str(point_realspace),' [mm].'])
end
data_dest = check_existing_names(data_dest,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
handles.mydata.data{length(handles.mydata.data)+1} = round(point);
handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info('point',handles,myInfo);
if(nargin>4)
data_dest_values = check_existing_names(data_dest_values,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest_values;
handles.mydata.data{length(handles.mydata.data)+1} = values;
handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info('interpolated_values',handles);
end
