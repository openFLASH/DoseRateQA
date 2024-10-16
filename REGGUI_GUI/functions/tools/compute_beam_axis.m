%% compute_beam_axis
% Compute the component of the 3 unit vectors defining the proton rays bundle expressed in the DICOM patient cooridnate system
% The Z axis of the proton bundle CS is pointing from the proton source towards the isocentre.
% The origin of the proton bundle CS is at the isocentre.
% The coordinate system of the ray bundle is an inverted IEC gantry CS: the Z-axis is pointing from the source towards the isocentre.
% This is a left handed CS.
%
%% Syntax
% |[beam_z,beam_x,beam_y] = compute_beam_axis(gantry_angle,table_angle)|
%
%% Description
% |[beam_z,beam_x,beam_y] = compute_beam_axis(gantry_angle,table_angle)| Components of the 3 axes of the IEC gantry CS expressed in the DICOM patient CS
%
%% Input arguments
% |gantry_angle| - _SCALAR_ - Gantry angle (deg) in the IEC 61217 standard
%
% |table_angle| - _SCALAR_ - Table yaw (deg) in the IEC 61217 standard
%
%% Output arguments
%
% |beam_z| - _SCALAR VECTOR_ - [x,y,z] components (expressed in the DICOM patient CS) of the unit vector defining the X axis of the proton ray bundle
%
% |beam_x| - _SCALAR VECTOR_ - [x,y,z] components (expressed in the DICOM patient CS)  of the unit vector defining the X axis  of the proton ray bundle
%
% |beam_y| - _SCALAR VECTOR_ - [x,y,z] components (expressed in the DICOM patient CS)  of the unit vector defining the X axis  of the proton ray bundle
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [beam_z,beam_x,beam_y] = compute_beam_axis(gantry_angle,table_angle)

gantry_angle = mod(gantry_angle,360);

% Compute beam axis in room coordinate system
beam_x = spin_calc('EVtoDCM',[0 0 1 table_angle],0,0)*spin_calc('EVtoDCM',[0 1 0 360-gantry_angle],0,0)*[1;0;0];
beam_y = spin_calc('EVtoDCM',[0 0 1 table_angle],0,0)*spin_calc('EVtoDCM',[0 1 0 360-gantry_angle],0,0)*[0;1;0];
beam_z = spin_calc('EVtoDCM',[0 0 1 table_angle],0,0)*spin_calc('EVtoDCM',[0 1 0 360-gantry_angle],0,0)*[0;0;1];

% Compute beam axis in dicom coordinate system
beam_x = [beam_x(1);-beam_x(3);beam_x(2)];
beam_y = [beam_y(1);-beam_y(3);beam_y(2)];
beam_z = [-beam_z(1);beam_z(3);-beam_z(2)];

% Normalize
beam_x = beam_x/norm(beam_x); % x-vector in orthogonal plane
beam_y = beam_y/norm(beam_y); % y-vector in orthogonal plane
beam_z = beam_z/norm(beam_z); % beam axis
