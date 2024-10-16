%% plot_reggui_fusion
% Create a new plot with an overlay of a fusion image (color) on top of a background image (black and white). Optionally, a color bar with the color scale of the fusion image can be displayed.
%
%% Syntax
% |curr_im = plot_reggui_fusion(background_image,fusion_image)|
%
% |curr_im = plot_reggui_fusion(background_image,fusion_image,alphaF)|
%
% |curr_im = plot_reggui_fusion(background_image,fusion_image,alphaF,background_image_interval)|
%
% |curr_im = plot_reggui_fusion(background_image,fusion_image,alphaF,background_image_interval,fusion_image_interval)|
%
% |curr_im = plot_reggui_fusion(background_image,fusion_image,alphaF,background_image_interval,fusion_image_interval,background_image_colormap)|
%
% |curr_im = plot_reggui_fusion(background_image,fusion_image,alphaF,background_image_interval,fusion_image_interval,background_image_colormap,fusion_image_colormap)|
%
% |curr_im = plot_reggui_fusion(background_image,fusion_image,alphaF,background_image_interval,fusion_image_interval,background_image_colormap,fusion_image_colormap,color_title)|
%
%% Description
% |curr_im = plot_reggui_fusion(background_image,fusion_image,alphaF,background_image_interval,fusion_image_interval,background_image_colormap,fusion_image_colormap,color_title)| Load a treatment indicators from file
%
%% Input arguments
% |background_image| - _SCALAR MATRIX_ - |background_image(i,j)| defines the intensity of the black and white image at pixel (i,j)
%
% |fusion_image| - _SCALAR MATRIX_ - |fusion_image(i,j)| defines the intensity of the black and white image at pixel (i,j)
%
% |alphaF| - _SCALAR_ - [OPTIONAL. Default = 0.3] Alpha blending factor of the fusion image onto the background image. alphaF=1 means that only the color image is visible
%
% |background_image_interval| - _SCALAR VECTOR_ - [OPTIONAL. Default = []: compute min and max of image] [min , max] Range of intensities to display in the background image
%
% |fusion_image_interval| - _SCALAR VECTOR_ - [OPTIONAL. Default = []: compute min and max of image] [min , max] Range of intensities to display in the fusion image
%
% |background_image_colormap| - _STRING or SCALAR MATRIX_ - [OPTIONAL. Default = 'gray'] Color map to use for the background image. See Matlab function |colormap| for description of parameter
%
% |fusion_image_colormap| - _STRING or SCALAR MATRIX_ - [OPTIONAL. Default: Jet with 0 as lowest value] Color map to use for the fusion image. See Matlab function |colormap| for description of parameter
%
% |color_title| - _STRING_ - [OPTIONAL. Default: [] = No color bar title] If present, add a color bar to the graph and use this string as a title to the color bar
%
% |axial| - _SCALAR_ - [OPTIONAL. Default = 0] If axial = 1, rotate the figure so that they are plotted in the conventional DICOM orientation for axial view of CT slice in HFS orientation (= couch towards bottom of image)
%
%
%% Output arguments
%
% |curr_im| - _IMAGE HANDLE_ -  The handle to the image created by imshow
%
% |clb| - _handle_ - Handle to the color bar. empty if no color bar is displayed
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [curr_im, clb] = plot_reggui_fusion(background_image,fusion_image,alphaF,background_image_interval,fusion_image_interval,background_image_colormap,fusion_image_colormap,color_title,axial,use_figure)

if(nargin<3)
    alphaF = 0.3;
end

if(nargin<4)
    background_image_interval = [min(background_image(:)),max(background_image(:))];
elseif isempty(background_image_interval)
    background_image_interval = [min(background_image(:)),max(background_image(:))];
end

if(nargin<5)
    fusion_image_interval = [min(fusion_image(:)),max(fusion_image(:))];
elseif(isempty(fusion_image_interval))
    fusion_image_interval = [min(fusion_image(:)),max(fusion_image(:))];
end

if(nargin<6)
    background_image_colormap = gray;
elseif isempty(background_image_colormap)
    background_image_colormap = gray;
end

if(nargin<7)
    fusion_image_colormap = [0,0,0;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;...
        0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;...
        0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;...
        0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,0.9375;0.125,1,0.875;0.1875,1,0.8125;...
        0.25,1,0.75;0.3125,1,0.6875;0.375,1,0.625;0.4375,1,0.5625;0.5,1,0.5;...
        0.5625,1,0.4375;0.625,1,0.375;0.6875,1,0.3125;0.75,1,0.25;0.8125,1,0.1875;...
        0.8750,1,0.125;0.9375,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;...
        1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;...
        1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;...
        0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0;0.5,0,0];% jet with 0 as lowest value
elseif isempty(fusion_image_colormap)
    fusion_image_colormap = [0,0,0;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;...
        0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;...
        0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;...
        0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,0.9375;0.125,1,0.875;0.1875,1,0.8125;...
        0.25,1,0.75;0.3125,1,0.6875;0.375,1,0.625;0.4375,1,0.5625;0.5,1,0.5;...
        0.5625,1,0.4375;0.625,1,0.375;0.6875,1,0.3125;0.75,1,0.25;0.8125,1,0.1875;...
        0.8750,1,0.125;0.9375,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;...
        1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;...
        1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;...
        0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0;0.5,0,0];% jet with 0 as lowest value
end

if(nargin<8)
    color_title = '';
end

if(nargin<9)
    axial = 0;
elseif isempty(axial)
    axial = 0;
end

if(nargin<10)
    use_figure = 1;
elseif(isempty(use_figure))
    use_figure = 1;
end

if(~isempty(color_title))
    display_borders = 1;
else
    display_borders = 0;
end

% get number of colors
nb_colorsF = size(fusion_image_colormap,1);
nb_colors = size(background_image_colormap,1);

% rotate image if axial
if(axial)
    %When displaying an image in axial plane, rotate it
    background_image = background_image(1:size(background_image,1),(size(background_image,2)):-1:1)';
    fusion_image = fusion_image(1:size(fusion_image,1),(size(fusion_image,2)):-1:1)';
end

% set colors for both images
background_image  = safe_label2rgb(background_image,background_image_colormap,background_image_interval,nb_colors);
fusion_image  = safe_label2rgb(fusion_image,fusion_image_colormap,fusion_image_interval,nb_colorsF);

% apply transparence only for non-zero values of the second image
index = sum(fusion_image==0,3)<3;
index(:,:,2) = index(:,:,1);
index(:,:,3) = index(:,:,1);
background_image(index) = background_image(index)*(1-alphaF)+fusion_image(index)*alphaF;

if(use_figure)
    if(display_borders)
        curr_im = imshow(background_image,'Border','tight','InitialMagnification','fit'); % Set the image size to fit thecurrent figure. Set tight border to fit the image.
        axis xy; % Set the image origin in the bottom left corner to get the same image orientation as in REGGUI GUI
        ax = gca;
        colormap(ax,fusion_image_colormap);
        clb=colorbar(ax,'location','eastoutside','Color','w');
        caxis(fusion_image_interval);
        set(get(clb,'title'),'string',color_title);
        drawnow
    else
        curr_im = imshow(background_image,'Border','tight');% Remove borders in the display.
        axis xy; % Set the image origin in the bottom left corner to get the same image orientation as in REGGUI GUI
        clb = [];
        caxis(fusion_image_interval);
    end
else
    curr_im = uint8(background_image*255);   
    clb = [];
end
