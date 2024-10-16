%% matDICOM2BEV
% Compute the 4x4 matrix M to convert coordinate from the DICOM CS to the IEC Gantry CS.
% If |isocentre| coordinate (in DICOM CS) are provided, the rotation takes place around the isocentre.
% Otherwise they take place around the origin of the DICOM CS
% gantry = M * dicom
%
%% Syntax
% |M = matDICOM2IECgantry(gantry_angle,table_angle)|
%
% |M = matDICOM2IECgantry(gantry_angle,table_angle , isocenter)|
%
%
%% Description
% |M = matDICOM2IECgantry(gantry_angle,table_angle)| Rotation around origin of DICOM CS
%
% |M = matDICOM2IECgantry(gantry_angle,table_angle , isocenter)| Rotation around isocentre
%
%% Input arguments
% |gantry_angle| - _SCALAR_ -  Gantry angle |degree|
%
% |table_angle| - _SCALAR_ -  Yaw angle of the PPS table |degree|
%
% |isocenter| -_SCALAR VECTOR_- [OTPIONAL] |isocenter(x,y,z)| Coordinate (mm) of the isocentre in the DICOM CS. The rotation takes place around the isocentre
%
%% Output arguments
%
% |M| - _MATRIX_ -  4 x 4 matrix: mother = IEC gantry. Daughter = DICOM
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function M = matDICOM2IECgantry(gantry_angle , table_angle , isocenter)

  if nargin < 3
    %Rotation around the origin of the DICOM CS
    % IEC gantry                  -> FRS                       -> TTCS                -> DICOM
    M = roll(-gantry_angle , [0,0,0]) * rot(table_angle , [0,0,0]) * pitch(-90,[0,0,0]);
  else
    %Rotation around the isocentre
    % IEC gantry                  -> FRS                       -> TTCS                -> DICOM     --> origin of DICOM
    M = roll(-gantry_angle , [0,0,0]) * rot(table_angle , [0,0,0]) * pitch(-90,[0,0,0]) * trans(-isocenter(1),-isocenter(2),-isocenter(3));
  end

end
