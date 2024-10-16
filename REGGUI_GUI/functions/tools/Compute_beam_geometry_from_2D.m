%% Compute_beam_geometry_from_2D
% Compute the beam geometry (gantry angle, table yaw and isocentre position) using a line (defined by 2 points) drawn in one of the 3 orthogonal view of a CT scan.
%
%% Syntax
% |[gantry_angle,table_angle,isocenter] = Compute_beam_geometry_from_2D(pt1,pt2,current_view,slice,handles)|
%
%
%% Description
% |[gantry_angle,table_angle,isocenter] = Compute_beam_geometry_from_2D(pt1,pt2,current_view,slice,handles)| Description
%
%
%% Input arguments
% |pt1| - _SCALAR VECTOR_ -  |pt1= [x,y]| Coordinates of the first point defining the beam line in the plane of the orthogonal view
%
% |pt2| - _SCALAR VECTOR_ -  |pt1= [x,y]| Coordinates of the second point defining the beam line in the plane of the orthogonal view
%
% |current_view| - _INTEGER_ -  Defines the orthogonal view in which the beam line is drawn. 1= sagittal, 2= coronal, 3 = axial
%
% |slice| - _SCALAR_ - Position (pixel) of the orthognal slice cut in the CT scan
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.origin| : Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |gantry_angle| - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
%
% |table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
%
% |isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [gantry_angle,table_angle,isocenter] = Compute_beam_geometry_from_2D(pt1,pt2,current_view,slice,handles)

% Authors : G.Janssens (open.reggui@gmail.com)

pt1 = [pt1(1);pt1(2)];
pt2 = [pt2(1);pt2(2)];
v1 = [1;0];
v2 = [0;-1];

switch current_view
    case 1 % sagittal
        v = [pt2-pt1].*handles.spacing([2;3]);
        v = v./norm(v);
        gantry_angle = sign(v(2)+eps)*180/pi*(acos(dot(v,v1)));
        table_angle = 90;
        if(gantry_angle<0)
            gantry_angle = 360 + gantry_angle;
        end
        isocenter = [slice;pt2].*handles.spacing + handles.origin;
    case 2 % coronal
        v = [pt2-pt1].*handles.spacing([1;3]);
        v = v./norm(v);
        gantry_angle = -sign(v(1)+eps)*90;
        if(gantry_angle<0)
            gantry_angle = 360 + gantry_angle;
            table_angle = -180/pi*(sign(v(2))*acos(dot(v,v1)));
        else
            table_angle = 180/pi*(sign(v(2))*acos(dot(-v,v1)));
        end
        if(table_angle<0)
            table_angle = 360 + table_angle;
        end
        isocenter = [pt2(1);slice;pt2(2)].*handles.spacing + handles.origin;
    case 3 % axial
        v = [pt2-pt1].*handles.spacing([1;2]);
        v = v./norm(v);
        gantry_angle = -sign(v(1)+eps)*180/pi*(acos(dot(v,v2)));
        if(gantry_angle<0)
            gantry_angle = 360 + gantry_angle;
        end
        table_angle = 0;        
        isocenter = ([pt2(1);handles.size(2)-pt2(2);slice]).*handles.spacing + handles.origin;
end
