function image_value = safe_label2rgb(image_value,image_colormap,interval,nb_colors)

image_value = (image_value-interval(1))/(interval(2)-interval(1)+eps)*(nb_colors-1); %Rescale the image to the color map dynamic range

%Remove non sensical values from image
image_value(find(image_value<0)) = 0;
image_value(find(image_value>nb_colors)) = nb_colors;
image_value(find(isnan(image_value))) = 0;

%Convert scalar matrix into a RGB matrix. The zero color is nearly black [0.1 0.1 0.1]
image_value = ind2rgb(uint8(round(image_value)),image_colormap);

