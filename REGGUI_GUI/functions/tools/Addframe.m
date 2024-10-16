%% Addframe
% Add a movie frame (a 2D image, see frame2im for details) in the cell element |{rd_nb}| of the data |handles.rendering_frames{rd_nb}|. The function is used to take a "snapshot" of the data.
% The movie frame is contructed by overlaying selected data (CT scan, contour, deformation field,...) from |handles|.
%
%% Syntax
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles)|
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name)|
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name,fusion_name)|
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name,fusion_name,field_name)|
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name,fusion_name,field_name,options)|
%
%
%% Description
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles)| Create a frame containing the image. Use option parameters from |handles|.
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name)| Create a frame containing the image and anatomical contours. Use option parameters from |handles|.
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name,fusion_name)| Create a frame containing the image, anatomical contours, second image overlay. Use option parameters from |handles|.
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name,fusion_name,field_name)| Create a frame containing the image, anatomical contours, second image overlay and the vectors of a deformation field. Use option parameters from |handles|.
%
% |handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name,fusion_name,field_name,options)| Create a frame containing the image, anatomical contours, second image overlay and the vectors of a deformation field. Use the parametres in |options| to control the display.
%
%
%% Input arguments
% |rd_nb| - _INTEGER_ - Index of the new frame to be crated in the cell vector |handles.rendering_frames{rd_nb}|.
%
% |rd_view| - _STRING_ -  Select the orientation of the slicing 2D plane into a 3D image. The slicing plane are named according tothe DICOM axes name:
%
% * 'ZY' : Sagital plane
% * 'ZX' : coronal plane
% * 'YX' : Axial plane
%
% |rd_index| - _INTEGER_ -  Index (in pixel) defining the position of the slicing plane in the 3D image. The selected index depends on |rd_view|. For example, if |rd_view='ZY'|, then the slicing plane is |image_name(rd_index,:,:)|
%
% |image_name| - _STRING_ -  Name of the image contained in |handles.images.name| to be displayed in the frame. This is typically thre CT scan. 
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
% * |handles.minscale| - _SCALAR_ - [Required only if |option| absent] Minimum grey level scale for the display  of the main image in the GUI
% * |handles.maxscale| - _SCALAR_ -  [Required only if |option| absent]  Maximum grey level scale for the display of the main image in the GUI
% * |handles.colormap| - _STRING_ -  [Required only if |option| absent]   Name of the colour map to use for display of the main image  in the GUI (see colormap function for more info)
% * |handles.minscaleF| - _SCALAR_ - [Required only if |option| absent] Minimum grey level scale for the display of the fusion image in the GUI
% * |handles.maxscaleF| - _SCALAR_ -  [Required only if |option| absent] Maximum grey level scale for the display of the main image in the GUI
% * |handles.second_colormap| - _STRING_ -  [Required only if |option| absent]   Name of the colour map to use for display of the fusion image  in the GUI (see colormap function for more info)
% * |handles.fielddensity| - _SCALAR_ - [Required only if |option| absent] Step size for displaying the vectors field. The |quiver| function will receive data point with |FieldDensity| spacing
% * |handles.field_color| - _STRING_ - [Required only if |option| absent] Colour used to isplay the vector of the deformation field. See |quiver| for available colour codes
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |contour_name| - _CELL VECTOR or STRING_ - Name of the contours in |handles.images.data| to be displayed in the frame. There are two syntaxes:
%
% * |contour_name{j}| - _CELL VECTOR of STRING_ - List of the name of the contours to be displayed on the frame
% * |contour_name| - _STRING_- Name of the single contour to be displayed onthe frame. If no contour is to be displayed |contour_name=''|
%
% |fusion_name| - _STRING_ - Name of a image to be overlaid to the image in the frame. This is could be, for example, a dose map. If no image is to be overlaid then |fusion_name=''|
%
% |field_name| - _STRING_ -  Name of the displacement field in |handles.fields.name| to be displayed on the frame. If no image is to be overlaid then |field_name=''|
%
% |options| - _CELL VECTOR_ -  Definition of the options for the display of the frame: |options = {'name',value,...}| where name can be one of the following:
%
% * |ImageScale| - Value is _SCALAR VECTOR_ |[min, max]| Minimum and maximum value of the grey value scale of |image_name| in the frame
% * |ImageColormap| - Value is _STRING_ Name of the colour map to use for displaying |image_name| in the frame (see colormap function for more info)
% * |ContourColor| - Value is _CELL VECTOR of SCALAR VECTOR_ -  |ContourColor{i} = [R,G,B]| The RGB code defining the colour of the ith contour
% * |FusionScale| - Value is _SCALAR VECTOR_ |[min, max]| Minimum and maximum value of the grey value scale of |fusion_name| in the frame
% * |FusionColormap| Value is - _STRING_ Name of the colour map to use for displaying |fusion_name| in the frame (see colormap function for more info)
% * |FusionAlpha| - Value is _SCALAR_ - [Default = 0.3] Alpha blending parameter when overlaying |fusion_name| onto |image_name|
% * |FieldDensity| - Value is _SCALAR_ - Step size for displaying the vectors field. The |quiver| function will receive data point with |FieldDensity| spacing
% * |FieldColor| - Value is _STRING_ - Colour used to isplay the vector of the deformation field. See |quiver| for available colour codes
% * |ColorBarTitle| - Value is _STRING_ - [OPTIONAL. Default: [] = No color bar title] If present, add a color bar to the graph and use this string as a title to the color bar
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated:
%
% * |handles.rendering_frames{rd_nb}(x,y,J,end)| - _CELL VECTOR of INTEGER MATRIX_ - Frame data. Defines the color of pixel at position (x,y) in the image. |J=1,2,3|  is the RGB triplet value defining the colour. The new frame is added as the last plane |(x,y,J,end)| of the matrix. The matrix contained in the cell element |rendering_frames{rd_nb}| is updated
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Addframe(rd_nb,rd_view,rd_index,image_name,handles,contour_name,fusion_name,field_name,options)


% Create missing arguments
if(nargin<5)
    error('Not enough input arguments.')
end
if(nargin<6)
    contour_name = 'none';
end
if(nargin<7)
    fusion_name = 'none';
end
if(nargin<8)
    field_name = 'none';
end
if(nargin<9)
    options = cell(0);
end

% Find image(s) and field
image = [];
for i=2:length(handles.images.name)
    if(strcmp(handles.images.name{i},image_name))
        image = handles.images.data{i};
    end
end
if(iscell(contour_name))
    contour = cell(0);
    for n=1:min(length(contour_name),6)
        for i=2:length(handles.images.name)
            if(strcmp(handles.images.name{i},contour_name{n}))
                contour{n} = handles.images.data{i};
            end
        end
    end
elseif(ischar(contour_name))
    contour = [];
    for i=2:length(handles.images.name)
        if(strcmp(handles.images.name{i},contour_name))
            contour = handles.images.data{i};
        end
    end
end
fusion = [];
for i=2:length(handles.images.name)
    if(strcmp(handles.images.name{i},fusion_name))
        fusion = handles.images.data{i};
    end
end
field = [];
for i=2:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},field_name))
        field = handles.fields.data{i};
    end
end

% Default options:
ImageScale = [handles.minscale handles.maxscale];
ImageColormap = handles.colormap;
ContourColor = [1 1 0];
FusionScale = [handles.minscaleF handles.maxscaleF];
FusionColormap = handles.second_colormap;
FusionAlpha = 0.3;
FieldDensity = handles.fielddensity;
FieldColor = handles.field_color;

% Input options
ImageScale_index = find(double(strcmp(options,'ImageScale')));
if(ImageScale_index & length(options)>ImageScale_index)
    ImageScale = options{ImageScale_index+1};
end
ImageColormap_index = find(double(strcmp(options,'ImageColormap')));
if(ImageColormap_index & length(options)>ImageColormap_index)
    ImageColormap = options{ImageColormap_index+1};
end
ContourColor_index = find(double(strcmp(options,'ContourColor')));
if(ContourColor_index & length(options)>ContourColor_index)
    ContourColor = options{ContourColor_index+1};
end
FusionScale_index = find(double(strcmp(options,'FusionScale')));
if(FusionScale_index & length(options)>FusionScale_index)
    FusionScale = options{FusionScale_index+1};
end
FusionColormap_index = find(double(strcmp(options,'FusionColormap')));
if(FusionColormap_index & length(options)>FusionColormap_index)
    FusionColormap = options{FusionColormap_index+1};
end
FusionAlpha_index = find(double(strcmp(options,'FusionAlpha')));
if(FusionAlpha_index & length(options)>FusionAlpha_index)
    FusionAlpha = options{FusionAlpha_index+1};
end
FieldDensity_index = find(double(strcmp(options,'FieldDensity')));
if(FieldDensity_index & length(options)>FieldDensity_index)
    FieldDensity = options{FieldDensity_index+1};
end
FieldColor_index = find(double(strcmp(options,'FieldColor')));
if(FieldColor_index & length(options)>FieldColor_index)
    FieldColor = options{FieldColor_index+1};
end

ColorBarTitle_index = find(double(strcmp(options,'ColorBarTitle')));
if(ColorBarTitle_index & length(options)>ColorBarTitle_index)
    ColorBarTitle = options{ColorBarTitle_index+1};
else
    ColorBarTitle = []; %Default: do not display color bar
end

try
    F = get_reggui_frame(rd_view,rd_index,image,contour,fusion,field,handles.spacing,ImageScale,ImageColormap,ContourColor,FusionScale,FusionColormap,FusionAlpha,FieldDensity,FieldColor,ColorBarTitle);
catch ME
    reggui_logger.info(['Error during frame acquisition for rendering. ',ME.message],handles.log_filename);
    rethrow(ME);
end

if(length(handles.rendering_frames)>=rd_nb)    
    try
        handles.rendering_frames{rd_nb}(:,:,:,size(handles.rendering_frames{rd_nb},4)+1) = F;
    catch
        disp(['WARNING: wrong frame size : [',num2str(size(F)),']  (should have been [',num2str(size(handles.rendering_frames{rd_nb}(:,:,:,size(handles.rendering_frames{rd_nb},4)))),'])'])
        F = imresize(F,size(handles.rendering_frames{rd_nb}(:,:,1,size(handles.rendering_frames{rd_nb},4))));
        handles.rendering_frames{rd_nb}(:,:,:,size(handles.rendering_frames{rd_nb},4)+1) = F;
        return
    end
else
    handles.rendering_frames{rd_nb}(:,:,:,1) = F;
end
% handles.rendering_colormaps{rd_nb} = F.colormap;



