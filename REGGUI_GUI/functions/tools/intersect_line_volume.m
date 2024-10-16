%% intersect_line_volume
% Find the coordinate of the 2 intersection points of the line joining points |pt1| and |pt2| with the borders of the image. The image is a paraelipipedic volume defined by parameters |im_size,im_origin,im_spacing|. The line will intersect 2 of 6 surfaces of the paralepiped.
%
%% Syntax
% |[pt_in,pt_out] = intersect_line_volume(im_size,im_origin,im_spacing,pt1,pt2)|
%
%
%% Description
% |[pt_in,pt_out] = intersect_line_volume(im_size,im_origin,im_spacing,pt1,pt2)| Compute the intersection points of the lane with image borders
%
%
%% Input arguments
% |im_size| - _SCALAR VECTOR_ -  Dimensions (x,y,z) of the image (in mm) 
%
% |im_origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
% |im_spacing| - _SCALAR VECTOR_ - Pixel size (|mm|)
%
% |pt1| - _SCALAR VECTOR_ - Coordinate (x,y,z) (mm) of the first point on the line
%
% |pt2| - _SCALAR VECTOR_ - Coordinate (x,y,z) (mm) of the second point on the line
%
%
%% Output arguments
%
% |pt_in| - _SCALAR VECTOR_ - Coordinates (x,y,z) (mm) of the entrance point of the line (i.e. between pt1 and pt2)
%
% |pt_out| - _SCALAR VECTOR - Coordinates (x,y,z) (mm) of the exit point of the line (i.e. beyond pt2)
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [pt_in,pt_out] = intersect_line_volume(im_size,im_origin,im_spacing,pt1,pt2)


if(not(size(pt1,1)==3 && size(pt2,1)==3))
    disp('Input points must be 3D (i.e. 3 rows)')
    return;
end

% find intersection with image planes

crossing_pts = cell(0);

x_min = im_origin - im_spacing/2;
x_max = im_origin + (im_size-1).*im_spacing + im_spacing/2;

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

for rounding = 9:-1:2    
    xtreme_pts = cell(0);
    for i=1:6
        in_x_range = roundsd(crossing_pts{i}(1),rounding,'ceil')>=roundsd(x_min(1),rounding,'floor') && roundsd(crossing_pts{i}(1),rounding,'floor')<=roundsd(x_max(1),rounding,'ceil');
        in_y_range = roundsd(crossing_pts{i}(2),rounding,'ceil')>=roundsd(x_min(2),rounding,'floor') && roundsd(crossing_pts{i}(2),rounding,'floor')<=roundsd(x_max(2),rounding,'ceil');
        in_z_range = roundsd(crossing_pts{i}(3),rounding,'ceil')>=roundsd(x_min(3),rounding,'floor') && roundsd(crossing_pts{i}(3),rounding,'floor')<=roundsd(x_max(3),rounding,'ceil');
        if(in_x_range && in_y_range && in_z_range)
            xtreme_pts{end+1} = crossing_pts{i};
        end
    end
    if(length(xtreme_pts)==2)
        break
    end
end

while(length(xtreme_pts)>2) % if several times the same point (rounding issue)
    D = NaN(length(xtreme_pts),length(xtreme_pts));
       for i=1:length(xtreme_pts)
           for j=i+1:length(xtreme_pts)
               D(i,j) = norm(xtreme_pts{i}-xtreme_pts{j});
           end
       end
    [~,index] = min(D(:));
    index_to_remove = mod(index,length(xtreme_pts));
    xtreme_pts = xtreme_pts([1:index_to_remove-1,index_to_remove+1:end]);
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
    pt_in = [];
    pt_out = [];
    disp('volume extrema:')
    disp([x_min,x_max])
    disp('trajectory points:')
    disp([pt1,pt2])
end  
