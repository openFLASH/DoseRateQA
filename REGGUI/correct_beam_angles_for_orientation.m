function [gantry_angle,table_angle] = correct_beam_angles_for_orientation(gantry_angle,table_angle,orientation)

if(nargin<3)
    orientation = 'HFS';
end
gantry_angle = mod(gantry_angle,360);
table_angle = mod(table_angle,360);

switch orientation
    case 'HFP'
        gantry_angle = mod(180+gantry_angle,360);
        table_angle = mod(-table_angle,360);
    case 'FFS'
        table_angle = mod(180+table_angle,360);
    case 'FFP'
        gantry_angle = mod(180+gantry_angle,360);
        table_angle = mod(180-table_angle,360);
end
