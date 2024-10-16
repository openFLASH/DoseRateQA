function pt = intersect_line_plane(pt_plane,v_normal,pt1,pt2)

v_line = pt2-pt1;
v_line = v_line/norm(v_line);

num = dot((pt_plane - pt1),v_normal);
den = dot(v_line,v_normal);

if(num==0)
    warning('No intersection found (the line is contained in the plane).')
    pt = [];
elseif(den==0)
    warning('No intersection found (the line is parallel to the plane).')
    pt = [];
else
    pt = pt1 + (num/den) * v_line;
end