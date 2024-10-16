%% Contour_path
% Translated a structure in an image. The voxels of the contour are shifted in the image by the direction defined by the translation vector.
%
%% Syntax
% |res = Contour_path(contour,translation, handles)|
%
%
%% Description
% |res = Contour_path(contour,translation, handles)| Translated a structure in an image
%
%
%% Input arguments
% |contour| - _SCALAR MATRIX_ -  |contour(x,y,z)=1| if the pixel at position (x,y,z) belongs to the structure. 0, otherwise 
%
% |translation| - _SCALAR VECTOR_ -  |translation= [x,y,z]| The components (in mm) of the rigid translation vector
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |res| - _SCALAR MATRIX_ -  |contour(x,y,z)=1| if the pixel at position (x,y,z) belongs to the translated structure. 0, otherwise 
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)



function res = Contour_path(contour,translation, handles)

    res = contour;
    tmp = contour;

    Length = norm(translation);
    direction = translation / Length;
    voxelSize = handles.spacing;
    CurrentLength = 0;
    
    ID = [0 0 0];
    Previous_ID = [0 0 0];
    Coord = ID .* voxelSize';
    
    while(CurrentLength < Length)
        Dist = ((ID - sign(direction)) .* voxelSize' - Coord) ./ direction;
        [step,index] = min(abs(Dist));
        CurrentLength = CurrentLength + step;
        Coord = Coord + step*direction;
        ID = round(Coord ./ voxelSize');
        tmp = circshift(tmp, ID - Previous_ID);
        res = res + tmp;
        Previous_ID = ID;
    end

    res = single(res > 0);
    
end

