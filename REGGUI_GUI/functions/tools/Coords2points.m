%% Coords2points
% convert coordinates from physics space into pixel index coordinates.
%
%% Syntax
% |points = Coords2points(coord,handles)|
%
% |points = Coords2points(coord,handles,data)|
%
%
%% Description
% |points = Coords2points(coord,handles)| Convert to pixel index coordinat using the information from |handles|
%
% |points = Coords2points(coord,handles,data)| Convert to pixel index coordinat using the information from |handles.mydata.info|
%
%
%% Input arguments
% |coord| - _SCALAR MATRIX_ |pts(i,;)=[x,y,z]| Coordinates (in physics space) (unit: mm) of the i-th point
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the ith image
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) of the ith image
% * |handles.mydata.info{i}.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the ith images in |mydata|
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |data| - _STRING_ - [OPTIONAL. If absent, uses |handles.spacing| and |handles.origin|] Name of the image in |handles.mydata| containing the |info.spacing| and |info.origin| information.
%
%
%% Output arguments
%
% |points| - _SCALAR MATRIX_ - |pts(i,;)=[x,y,z]| Coordinates (in pixel index) of the i-th point
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function points = Coords2points(coord,handles,data)

myInfo = struct;

if(nargin>2)    
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},data)) % RLA: changes 'pts' into 'data'. I don't think the function would work otherwise.
            myInfo = handles.mydata.info{i};
        end
    end    
else
    myInfo.Spacing = handles.spacing;
    myInfo.ImagePositionPatient = handles.origin;
end

points = zeros(size(coord));

for pt=1:size(coord,1)
      points(pt,:) = round((coord(pt,:)-myInfo.ImagePositionPatient')./myInfo.Spacing' +1);
end
