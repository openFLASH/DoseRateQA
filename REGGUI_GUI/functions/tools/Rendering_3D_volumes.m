%% Rendering_3D_volumes
% Make a 3D rendering of volumes (= anatomical contours = RT structures) using the function |isosurface|. 
% Display a dialog box to choose the contours in |handles.images| to be overlaid.
%
%% Syntax
% |res = Rendering_3D_volumes(handles)|
%
% |res = Rendering_3D_volumes(handles,subsampling)|
%
% |res = Rendering_3D_volumes(handles,subsampling,myAlpha)|
%
% |res = Rendering_3D_volumes(handles,subsampling,myAlpha,myColor)|
%
%
%% Description
% |res = Rendering_3D_volumes(handles)| Render all the selected contours using the default transparency and random colour and no sub-sampling.
%
% |res = Rendering_3D_volumes(handles,subsampling)| Render all the selected contours with defined sub-sampling using the default transparency  and random colour.
%
% |res = Rendering_3D_volumes(handles,subsampling,myAlpha)| Render all the selected contours with defined sub-sampling using the defined transparency  and random colour.
%
% |res = Rendering_3D_volumes(handles,subsampling,myAlpha,myColor)| Render all the selected contours with defined sub-sampling using the defined transparency and colour.
%
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |subsampling| - _INTEGER_ - Step size (in pixel) to use for the sub-sampling of the structure. |subsampling = 2| means that the surface will be displayed using every other point defining the structure.
%
% |myAlpha| - _SCALAR VECTOR_ - [OPTIONAL. Default = 0.3] Transparency of the image to overlay (see function |alpha| for more informaiton). If a single value is provided, the same transparency is used for all images. If a vector is provided, the transparency of the i-th image will be |myAlpha(i)|.
%
% |myColor| - _SCALAR VECTOR_ - [OPTIONAL. default = random] |myColor| = [R,G,B] RGB components of the coulour to display the surface
%
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  Description
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Rendering_3D_volumes(handles,subsampling,myAlpha,myColor)

res = handles;

try

    Image_list = handles.images.name;
    [selection, OK] = listdlg('PromptString','Which mask(s) do you want to visualize (multiple choice accepted)', 'SelectionMode', 'multiple', 'ListString',Image_list);
    if (~OK)
        return;
    end
    names_list = '';
    for i=1:length(selection)-1
        names_list = [names_list '''' handles.images.name{selection(i)} ''','];
    end
    names_list = [names_list '''' handles.images.name{selection(end)} ''''];
    eval(['contours_names = {' names_list '};']);

    selection = [];
    for n=1:length(contours_names)
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},contours_names(n)) && ~isempty(handles.images.data{i}))
                selection = [selection,i];
            end
        end
    end

    myCurrentAlpha = 0;
    figure(1)
    for i=selection
        myDat = (handles.images.data{i});
        if(nargin>1 && not(isempty(subsampling)))
            myDat = myDat(1:subsampling:end,1:subsampling:end,1:subsampling:end);
        end
        myDat = single(myDat>=max(max(max(max(myDat))))/2);
        if(nargin<4)
            myColor = rand(1,3);
        end        
        if(isempty(myColor))
            myColor = rand(1,3);
        end 
        p = patch(isosurface(myDat, 0.5), 'FaceColor', myColor, 'EdgeColor', 'none');
        if(nargin>2 && not(isempty(myAlpha)))
            if(length(myAlpha)==1)
            alpha(myAlpha)
            else
                myCurrentAlpha = myCurrentAlpha+1;
                alpha(myAlpha(myCurrentAlpha));
            end
        else
            alpha(0.3)
        end
        current_graph = isonormals(myDat,p);
        camlight(40, 40);
        camlight(-20,-10);
        view(-35,-15);
        daspect([1/handles.spacing(1) 1/handles.spacing(2) 1/handles.spacing(3)])
        camva(9);
        box on
        lighting gouraud
        hold on
    end

    hold off

catch
end
