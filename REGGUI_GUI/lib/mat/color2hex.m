function hexcolor = color2hex(color)
if(not(max(color)>1))
    color = 255*color;
end
color(color<0) = 0;
if(not(isempty(color)))
    hexcolor = [dec2hex(round(color(1)),2),dec2hex(round(color(2)),2),dec2hex(round(color(3)),2)];
else
    hexcolor = [dec2hex(0),dec2hex(0),dec2hex(0)];
end