%% Points2coords
% Convert the coordinate from pixel index into coordinate of the physics space.
%
%% Syntax
% |coord = Points2coords(pts=SCALAR MATRIX,handles)|
%
% |coord = Points2coords(pts=STRING,handles)|
%
%
%% Description
% |coord = Points2coords(pts=SCALAR MATRIX,handles)| Return the coordinate in physics space of points defined by the coordinates |pts|
%
% |coord = Points2coords(pts=STRING,handles)| Return the coordinates in physics space of the point specified in |handles.mydata|
%
%
%% Input arguments
% |pts| - _STRING_ -  Coordinates (in pixel index) of the points to be converted. There are two formats:
%
% *  |pts| - _SCALAR MATRIX_ |pts(i,;)=[x,y,z]| Coordinates (in pixel index) of the i-th point
% *  |pts| - _STRING_ Name of the data stored in |handles.mydata| containing the pixel coordinates. It should have the same format as described above.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * If using the syntax 1:
% * ----|handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * ----|handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
% * If using the syntax 2:
% * ----|handles.mydata.name{i}| - _STRING_ - Name of the ith image
% * ----|handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) of the ith image
% * ----|handles.mydata.info{i}.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the ith images in |mydata|
% * ----|handles.mydata.info{i}.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (x,y,z) (in mm) of the voxel (1,1,1) of the ith image ( in |mydata|) in the DICOM coordinate system
%
%
%% Output arguments
%
% |coord| - _SCALAR MATRIX_ |pts(i,;)=[x,y,z]| Coordinates (in physics space) (unit: mm) of the i-th point
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function coord = Points2coords(pts,handles)

% Authors : G.Janssens

myInfo = struct;

if(ischar(pts))    
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},pts))
            points = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
        end
    end    
else
    points = pts;
    myInfo.Spacing = handles.spacing;
    myInfo.ImagePositionPatient = handles.origin;
end

coord = zeros(size(points));

for pt=1:size(pts,1)
     coord(pt,:) = (points(pt,:)-1).*myInfo.Spacing' + myInfo.ImagePositionPatient';
end
