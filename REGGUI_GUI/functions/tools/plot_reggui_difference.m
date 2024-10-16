function curr_im = plot_reggui_difference(image1,image2,image_interval,image_colormap)

% plot_reggui_difference(Im,F,[handles.minscale,handles.maxscale],handles.colormap)

if(nargin<3)
    image_interval = [min(image1(:)),max(image1(:))];
end
if(nargin<4)
    image_colormap = gray(64);
end

image1(image1<image_interval(1)) = image_interval(1);
image2(image2<image_interval(1)) = image_interval(1);
image1 = image1 - image2;
curr_im = imshow(image1,[image_interval(1)-image_interval(2) image_interval(2)-image_interval(1)]);

colormap(image_colormap);
axis xy;
