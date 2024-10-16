%% intersect_beam_volume
% Find the coordinate of the 2 intersection points of the line joining the isocentre to the radiation source with the borders of the image. The image is a paraelipipedic volume defined by parameters |im_size,im_origin,im_spacing|. The line will intersect 2 of 6 surfaces of the paralepiped.
%
%% Syntax
% |[pt_in,pt_out] = intersect_beam_volume(im_size,im_origin,im_spacing,beam)|
%
% |[pt_in,pt_out] = intersect_beam_volume(im_size,im_origin,im_spacing,beam,sad)|
%
%
%% Description
% |[pt_in,pt_out] = intersect_beam_volume(im_size,im_origin,im_spacing,beam)| Compute intersection points assuming SAD = 2m
%
% |[pt_in,pt_out] = intersect_beam_volume(im_size,im_origin,im_spacing,beam,sad)| Compute intersection points using provided SAD
%
%
%% Input arguments
% |im_size| - _SCALAR VECTOR_ -  Dimensions (x,y,z) of the image (in mm) 
%
% |im_origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
% |im_spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) 
%
% |beam| - _STRUCTURE or CELL_ -  Description of the proton beam geometry. See parameter |beam| or |data| or |geom| of function |get_beam_params| for more information.
%
% |sad| - _SCALAR_ -  Source to axis distance (mm) 
%
%
%% Output arguments
%
% |pt_in| - _SCALAR VECTOR_ - Coordinates (x,y,z) (mm) of the entrance point of the line (i.e. between source and isocentre)
%
% |pt_out| - _SCALAR VECTOR - Coordinates (x,y,z) (mm) of the exit point of the line (i.e. beyond the isocentre)
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO Call function intersect_line_volume to compute the intersection points instead of rewriting the same code

function [pt_in,pt_out] = intersect_beam_volume(im_size,im_origin,im_spacing,beam,sad)


%Set treatment plan
[gantry_angle,table_angle,isocenter] = get_beam_params(beam);

if(nargin<5)
    sad = 2e3;
end

% find source
beam_axis = compute_beam_axis(gantry_angle,table_angle);
if(not(isinf(sad)))
    pt1 = isocenter - sad*beam_axis;
end

% find target
pt2 = isocenter;

% find intersection with image planes

crossing_pts = cell(0);

x_min = im_origin;
x_max = im_origin + im_size.*im_spacing;

t_a = (x_min(1)-pt1(1))/(pt2(1)-pt1(1));
crossing_pts{1} = [x_min(1);pt1(2)+t_a*(pt2(2)-pt1(2));pt1(3)+t_a*(pt2(3)-pt1(3))];
t_b = (x_max(1)-pt1(1))/(pt2(1)-pt1(1));
crossing_pts{2} = [x_max(1);pt1(2)+t_b*(pt2(2)-pt1(2));pt1(3)+t_b*(pt2(3)-pt1(3))];
t_c = (x_min(2)-pt1(2))/(pt2(2)-pt1(2));
crossing_pts{3} = [pt1(1)+t_c*(pt2(1)-pt1(1));x_min(2);pt1(3)+t_c*(pt2(3)-pt1(3))];
t_d = (x_max(2)-pt1(2))/(pt2(2)-pt1(2));
crossing_pts{4} = [pt1(1)+t_d*(pt2(1)-pt1(1));x_max(2);pt1(3)+t_d*(pt2(3)-pt1(3))];
t_e = (x_min(3)-pt1(3))/(pt2(3)-pt1(3));
crossing_pts{5} = [pt1(1)+t_e*(pt2(1)-pt1(1));pt1(2)+t_e*(pt2(2)-pt1(2));x_min(3)];
t_f = (x_max(3)-pt1(3))/(pt2(3)-pt1(3));
crossing_pts{6} = [pt1(1)+t_f*(pt2(1)-pt1(1));pt1(2)+t_f*(pt2(2)-pt1(2));x_max(3)];

% keep intersection with image borders

xtreme_pts = cell(0);

for i=1:6
    in_x_range = crossing_pts{i}(1)>=x_min(1) && crossing_pts{i}(1)<=x_max(1);
    in_y_range = crossing_pts{i}(2)>=x_min(2) && crossing_pts{i}(2)<=x_max(2);
    in_z_range = crossing_pts{i}(3)>=x_min(3) && crossing_pts{i}(3)<=x_max(3);
    if(in_x_range && in_y_range && in_z_range)
        xtreme_pts{end+1} = crossing_pts{i};
    end
end

if(length(xtreme_pts)==2)
    if(norm(xtreme_pts{1}-pt1)>norm(xtreme_pts{2}-pt1))
        pt_in = xtreme_pts{2};
        pt_out = xtreme_pts{1};
    else
        pt_in = xtreme_pts{1};
        pt_out = xtreme_pts{2};
    end
else
    disp('error: could not find 2 intersection points')
end


    
