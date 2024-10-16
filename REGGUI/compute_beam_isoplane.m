%% compute_beam_isoplane
% Compute the coordinates (expressed in the DICOM patient CS) of 2 points for each rays belonging to a bundle of rays.
% The rays of the bundle are parallel. They start from a plane containing the proton source and the reach a plane containing the isocentre.
% The position of each ray (in a plane perpendicular to the proton beam axis) is given as input in the IEC gantry coordinate system.
%
%% Syntax
% |[pts_3D,pt_source] = compute_beam_isoplane(pts_2D,beam,sad)|
%
%
%% Description
% |[pts_3D,pt_source] = compute_beam_isoplane(pts_2D,beam,sad)| Compute the coordinate of 2 points of each ray in the DICOM Patient CS
%
%
%% Input arguments
% |pts_2D| - _SCALAR MATRIX_ - Coordinate of 1 point of each ray in the IEC gantry CS. |pts_2D(:,i)=[x,y]| is the coordinate (mm) of one point of the i-th ray.
%
% |beam| - _STRUCTURE or CELL_ -  Description of the proton beam geometry. See parameter |beam| or |data| or |geom| of function |get_beam_params| for more information.
%
% |sad| - _SCALAR_ - Proton source to isocentre distance (in mm)
%
%
%% Output arguments
%
% |pts_3D| - _SCALAR MATRIX_ - |pts_3D(:,i)=[x,y,z]| is the coordinate (in mm) in the DICOM patient CS of the ith point of the ray bundle. The point is located in a plane containing the isocentre.
%
% |pt_source| - _SCALAR MATRIX_ - |pts_3D(:,i)=[x,y,z]| is the coordinate (in mm) in the DICOM patient CS of the ith point of the ray bundle. The point is located in a plane containing the proton source.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [pts_3D,pt_source] = compute_beam_isoplane(pts_2D,beam,sad)

% Authors : G.Janssens (open.reggui@gmail.com)

% pts_2D: 2 rows for dimensions, as many columns as input points

[gantry_angle,table_angle,isocenter] = get_beam_params(beam);
if(size(isocenter,2)>1)
    isocenter = isocenter';
end

% compute beam vectors
[beam_z,beam_x,beam_y] = compute_beam_axis(gantry_angle,table_angle); %Components of the 3 axes of the IEC gantry CS expressed in the DICOM patient CS

% Compute source point
pt_source = isocenter - beam_z*sad; %Coordinate of the source in the DICOM patient CS

% Compute 3D isoplane points
pts_3D = repmat(isocenter,[1,size(pts_2D,2)]) + repmat(pts_2D(1,:),[3,1]).*repmat(beam_x,[1,size(pts_2D,2)]) + repmat(pts_2D(2,:),[3,1]).*repmat(beam_y,[1,size(pts_2D,2)]);
