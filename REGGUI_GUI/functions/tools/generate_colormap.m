function cm = generate_colormap(basic_colors,output_length)

if(nargin<2)
    f = 8;
else
    f = round(output_length/size(basic_colors,1));
end

cm = [interp1(linspace(0,1,size(basic_colors,1))',basic_colors(:,1),linspace(0,1,(size(basic_colors,1)-1)*f+1)'),interp1(linspace(0,1,size(basic_colors,1))',basic_colors(:,2),linspace(0,1,(size(basic_colors,1)-1)*f+1)'),interp1(linspace(0,1,size(basic_colors,1))',basic_colors(:,3),linspace(0,1,(size(basic_colors,1)-1)*f+1)')];
