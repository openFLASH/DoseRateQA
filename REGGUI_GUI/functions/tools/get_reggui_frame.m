%% get_reggui_frame
% Create a movie frame (a 2D image, see frame2im for details). The function is used to take a "snapshot" of the data.
% The movie frame is contructed by overlaying inputed data (CT scan, contour, deformation field,...).
%
%% Syntax
% |reggui_frame = get_reggui_frame(rd_view,rd_index,background_image,contour,fusion,field,ImageSpacing,ImageScale,ImageColormap,ContourColor,FusionScale,FusionColormap,FusionAlpha,FieldDensity,FieldColor)|
%
% |reggui_frame = get_reggui_frame(rd_view,rd_index,background_image,contour,fusion,field,ImageSpacing,ImageScale,ImageColormap,ContourColor,FusionScale,FusionColormap,FusionAlpha,FieldDensity,FieldColor,ColorBarTitle)|
%
%
%% Description
% |reggui_frame = get_reggui_frame(rd_view,rd_index,background_image,contour,fusion,field,ImageSpacing,ImageScale,ImageColormap,ContourColor,FusionScale,FusionColormap,FusionAlpha,FieldDensity,FieldColor)| Create a movie frame
%
% |reggui_frame = get_reggui_frame(rd_view,rd_index,background_image,contour,fusion,field,ImageSpacing,ImageScale,ImageColormap,ContourColor,FusionScale,FusionColormap,FusionAlpha,FieldDensity,FieldColor,ColorBarTitle)| Create a movie frame and display color bar forthe fusion image
%
%% Input arguments
% |rd_view| - _STRING_ -  Select the orientation of the slicing 2D plane into a 3D image. The slicing plane are named according tothe DICOM axes name:
%
% * 'ZY' : Sagital plane
% * 'ZX' : coronal plane
% * 'YX' : Axial plane
%
% |rd_index| - _TYPE_ -  Index (in pixel) defining the position of the slicing plane in the 3D image. The selected index depends on |rd_view|. For example, if |rd_view='ZY'|, then the slicing plane is |background_image(rd_index,:,:)|
%
% |background_image| - _SCALAR MATRIX_ - Image to be displayed in the frame. |background_image(x,y,z)| Intensity of the pixel at position (x,y,z).  If empty [], nothing is displayed.
%
% |contour| -  Anatomical contour(s) to be displayed in the frame.   If empty [], nothing is displayed. There are two syntaxes:
%
% *  |contour{n}| - _SCALAR MATRIX_ - |contour{n}=im(x,y,z)| The pixel at position (x,y,z) belongs to the nth structure if set to 1. Otherwise, set to zero.
% *  |contour| - _SCALAR MATRIX_ - |im(x,y,z)| 3D image from which the ray trace are extracted
%
% |fusion| - _SCALAR MATRIX_ - Image to be overlaid onto |background_image| in the frame. |fusion(x,y,z)| Intensity of the pixel at position (x,y,z). If empty [], nothing is displayed.
%
% |field| _MATRIX of SCALAR_ [OPTIONAL. Default = []]  If not empty, |field(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |field(2,x,y,z)| and |field(3,x,y,z)|. If empty [], nothing is displayed.
%
% |ImageSpacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the |background_image|.
%
% |ImageScale| - _SCALAR VECTOR_ |[min, max]| Minimum and maximum value of the grey value scale of |background_image| in the frame
%
% |ImageColormap| - _STRING or SCALAR MATRIX_ - [OPTIONAL. Default = 'gray'] Color map to use for the background image. See Matlab function |colormap| for description of parameter
%
% |ContourColor| - _CELL VECTOR of SCALAR VECTOR_ -  |ContourColor{i} = [R,G,B]| The RGB code defining the colour of the ith contour. 0 <= R,G,B <= 1
%
% |FusionScale| - _SCALAR VECTOR_ - [OPTIONAL. Default: compute min and max of image] [min , max] Range of intensities to display in the fusion image
%
% |FusionColormap| - _STRING or SCALAR MATRIX_ - [OPTIONAL. Default: Jet with 0 as lowest value] Color map to use for the fusion image. See Matlab function |colormap| for description of parameter
%
% |FusionAlpha| - _SCALAR_ - [OPTIONAL. Default = 0.3] Alpha blending factor of the fusion image onto the background image. alphaF=1 means that only the color image is visible
%
% |FieldDensity| - _SCALAR_ - [OPTIONAL. Not used if |field| is not empty]. Step size for displaying the vectors field. The |quiver| function will receive data point with |FieldDensity| spacing
%
% |FieldColor| - _STRING_ - [OPTIONAL. Not used if  |field| is not empty]. Colour used to isplay the vector of the deformation field. See |quiver| for available colour codes
%
% |ColorBarTitle| - _STRING_ - [OPTIONAL. Default: [] = No color bar title] If present, add a color bar to the graph and use this string as a title to the color bar
%
%
%% Output arguments
%
% |reggui_frame| - _INTEGER MATRIX_ - |reggui_frame(x,y,J)| Frame data. Defines the color of pixel at position (x,y) in the image. |J=1,2,3| is the RGB triplet value defining the colour.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


function reggui_frame = get_reggui_frame(rd_view,rd_index,background_image,contour,fusion,field,ImageSpacing,ImageScale,ImageColormap,ContourColor,FusionScale,FusionColormap,FusionAlpha,FieldDensity,FieldColor,ColorBarTitle)

rd_index = round(rd_index);

if nargin < 16
    ColorBarTitle = [];
end

% Display image(s) and field
myFig = figure;
myFig=colordef(myFig,'black'); %Set color scheme
myFig.Color='k'; %Set background color of figure window
myFig.Name = '';
myFig.ToolBar = 'none';
myFig.MenuBar = 'none';
image_size = size(background_image);

switch rd_view
    %---- case 'ZY' SAGITTAL ----
    case 'ZY'
        aspectRatio=[ImageSpacing(3) ImageSpacing(2) 1];
        if(not(isempty(field)))
            Fx = [1:FieldDensity:image_size(2)];
            Fy = [1:FieldDensity:image_size(3)];
            Fu = squeeze(field(2,rd_index,[1:FieldDensity:image_size(2)],[1:FieldDensity:image_size(3)]))';
            Fv = squeeze(field(3,rd_index,[1:FieldDensity:image_size(2)],[1:FieldDensity:image_size(3)]))';
        else
            Fx = [];
            Fy = [];
            Fu = [];
            Fv = [];
        end
        reggui_frame = createDisplay(rd_index,1:image_size(2),1:image_size(3),background_image,ImageScale, fusion, Fx,Fy,Fu,Fv, FusionScale, ImageColormap, FusionColormap, FusionAlpha, ColorBarTitle, aspectRatio, contour, ContourColor, FieldColor, myFig);
        
        %---- case 'ZX' CORONAL ----
    case 'ZX'
        aspectRatio=[ImageSpacing(3) ImageSpacing(1) 1];
        if(not(isempty(field)))
            Fx = [1:FieldDensity:image_size(1)];
            Fy = [1:FieldDensity:image_size(3)];
            Fu = squeeze(field(1,[1:FieldDensity:image_size(1)],rd_index,[1:FieldDensity:image_size(3)]))';
            Fv = squeeze(field(3,[1:FieldDensity:image_size(1)],rd_index,[1:FieldDensity:image_size(3)]))';
        else
            Fx = [];
            Fy = [];
            Fu = [];
            Fv = [];
        end
        reggui_frame = createDisplay(1:image_size(1) , rd_index , 1:image_size(3) , background_image , ImageScale , fusion , Fx , Fy, Fu , Fv , FusionScale, ImageColormap , FusionColormap , FusionAlpha , ColorBarTitle , aspectRatio, contour, ContourColor, FieldColor, myFig);
        
        %---- case 'YX' AXIAL----
    case 'YX'
        aspectRatio=[ImageSpacing(2) ImageSpacing(1) 1];
        if(not(isempty(field)))
            Fx = [1:FieldDensity:image_size(1)];
            Fy = [image_size(2):-FieldDensity:1];
            Fu = squeeze(field(1,[1:FieldDensity:image_size(1)],[1:FieldDensity:image_size(2)],rd_index))';
            Fv = -squeeze(field(2,[1:FieldDensity:image_size(1)],[1:FieldDensity:image_size(2)],rd_index))';
        else
            Fx = [];
            Fy = [];
            Fu = [];
            Fv = [];
        end
        reggui_frame = createDisplay(1:image_size(1),image_size(2):-1:1,rd_index,background_image, ImageScale , fusion , Fx , Fy, Fu , Fv , FusionScale, ImageColormap, FusionColormap, FusionAlpha, ColorBarTitle, aspectRatio, contour, ContourColor, FieldColor, myFig);
        
end

close(myFig);

end


%---------------------
% Create the displayed image + contour + dose map + vector field
%---------------------
function reggui_frame = createDisplay(Xind, Yind, Zind, background_image, ImageScale, fusion, Fx, Fy, Fu, Fv, FusionScale, ImageColormap, FusionColormap, FusionAlpha, ColorBarTitle, aspectRatio, contour, ContourColor, FieldColor, myFig)

if nargin < 15
    ColorBarTitle = [];
end

if(not(isempty(background_image)))
    if(isempty(fusion))
        %Fusion image is empty. Just display background
        figure(myFig)
        imshow(squeeze(background_image(Xind,Yind,Zind))',[ImageScale(1) ImageScale(2)+eps],'Border','tight');
        drawnow
        if isempty(ImageColormap)
            ImageColormap = gray(64);
        end
        colormap(ImageColormap);
        drawnow
    else
        %fusion image is provided. Display it on top of background image
        figure(myFig)
        plot_reggui_fusion(squeeze(background_image(Xind,Yind,Zind))',squeeze(fusion(Xind,Yind,Zind))',FusionAlpha,ImageScale,FusionScale,ImageColormap,FusionColormap,ColorBarTitle);
        drawnow
    end
    
    if(not(isempty(contour)))
        %display anatomical contours
        if(iscell(contour))
            %Several contours to be displayed
            if(not(iscell(ContourColor))||(length(contour)>length(ContourColor)))
                ContourColor = {[1 1 0];[1 0 0];[0 0 1];[0 1 0];[0 1 1];[1 0 1]};
            end
            for c=1:min(length(contour),6)
                F = squeeze(contour{c}(Xind,Yind,Zind)) >= max(max(max(contour{c})))/2;
                boundCell = find_contour(F,1);
                if(~isempty(boundCell))
                    for ireg = 1:length(boundCell)
                        bound = cell2mat(boundCell(ireg,1));
                        figure(myFig)
                        hold on
                        plot(bound(:,1),bound(:,2),'Color',ContourColor{c});
                        hold off
                        drawnow
                    end
                end
            end
        else
            % Single contour to be displayed
            F = squeeze(contour(Xind,Yind,Zind)) >= max(max(max(contour)))/2;
            boundCell = find_contour(F,1);
            if(~isempty(boundCell))
                for ireg = 1:length(boundCell)
                    bound = cell2mat(boundCell(ireg,1));
                    figure(myFig)
                    hold on
                    plot(bound(:,1),bound(:,2),'Color',ContourColor);
                    hold off
                    drawnow
                end
            end
        end
    end
    if(not(isempty(Fx)))
        %Display vector field
        figure(myFig)
        hold on
        quiver(Fx,Fy,Fu,Fv,0,'Color',FieldColor);
        axis([0,size(squeeze(background_image(Xind,Yind,Zind))',1),0,size(squeeze(background_image(Xind,Yind,Zind))',2)])
        hold off
        drawnow
    end
end

%Change the aspect ratio of the image to fit to the ratio of physical size of the pixels
figure(myFig)
drawnow
daspect(aspectRatio);
drawnow

%Adapt figure size if no color bar. Do not do it if there is a color bar
if(isempty(ColorBarTitle))
    d_ratio = aspectRatio(2)/aspectRatio(1);
    figure(myFig)
    figpos = get(gcf, 'Position');
    if(d_ratio>1)
        set(gcf, 'Position', [figpos(1), figpos(2), figpos(3)*d_ratio, figpos(4)]);
    elseif(d_ratio<1)
        set(gcf, 'Position', [figpos(1), figpos(2), figpos(3), figpos(4)/d_ratio]);
    end
end

figure(myFig)
hold off
drawnow
axis xy; % Set the image origin in the bottom left corner to get the same image orientation as in REGGUI main GUI
drawnow

figure(myFig)
if(isempty(ColorBarTitle))
    reggui_frame = frame2im(getframe);
else
    reggui_frame = frame2im(getframe(gcf)); %Use gcf with getframe so as to capture the whole figure (not just the axes) when Matlab is running with the -nodisplay option
end


end
