%% Compute_beam_align_transform
% Compute the transform from the IEC Gantry coordinate system to a DICOM coordinate system rotated by the table yaw (z corresponds to the beam axis after transformation). The result is stored in |handles.fields|
%
%% Syntax
% |handles = Compute_beam_align_transform(beam,transform_name,handles)|
%
%
%% Description
% |handles = Compute_beam_align_transform(beam,transform_name,handles)| Compute the transform between beam coordinate and DICOM coordinates
%
%
%% Input arguments
% |beam| - _STRUCTURE or CELL_ -  Description of the proton beam geometry. See parameter |beam| or |data| or |geom| of function |get_beam_params| for more information.
%
% |field_name| - _STRING_ -  Name of the field  to be created in |handles.fields|
%
% |handles| - _STRUCTURE_ - REGGUI data structure. The new field is added to this structured
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data.
% 
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Compute_beam_align_transform(beam,transform_name,handles)


[gantry_angle,table_angle,isocenter] = get_beam_params(beam);

% check angles
while gantry_angle<0
    gantry_angle = 360+gantry_angle;
end
while table_angle<0
    table_angle = 360+table_angle;
end

% Compute translation
t = isocenter;

% Compute rotation
beam_axis = compute_beam_axis(gantry_angle,table_angle);

a = [0;0;1];
b = beam_axis/norm(beam_axis);
c = cross(a,b);
c = c/norm(c);
d = 360-acos(dot(a,b))/pi*180;
r = spin_calc('EVtoDCM',[c(:)' d],eps,0);

% get transform
rigid_transform = zeros(1,3);
rigid_transform(2,:) = t;
rigid_transform(3:5,:) = r;

transform_name = check_existing_names(transform_name,handles.fields.name);
handles.fields.name{length(handles.fields.name)+1} = transform_name;
handles.fields.data{length(handles.fields.data)+1} = rigid_transform;
handles.fields.info{length(handles.fields.info)+1} = Create_default_info('rigid_transform',handles);
