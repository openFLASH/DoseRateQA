%% image_rendering
% Save a stack of images (at the frame format) on disk at png format. The file name is "|outname|_T.png" where T is the image index in the stack
%
%% Syntax
% |image_rendering(images,outname)|
%
% |image_rendering(images,outname,frame_size)|
%
%
%% Description
% |image_rendering(images,outname)| Save the frame data in PNG files on disk with no resizing
%
% |image_rendering(images,outname,frame_size)| Save the frame data in PNG files on disk with specified resizing
%
%
%% Input arguments
% |images| - _INTEGER MATRIX_ - |images|(x,y,J,t) Frame data. Defines the color of pixel at position (x,y) in the frame at time step t. |J=1,2,3|  is the RGB triplet value defining the colour.
%
% |outname| - _STRING_ -  Name of the file (including path) to be saved on disk. The png extension will be automatically added to the file name 
%
% |frame_size| - _SCALAR VECTOR_ -  [OPTIONAL. Default = no resizing]  |frame_size= [row,column]| size of the resied image using function |imresize|) that will be saved on disk.
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function image_rendering(images,outname,frame_size)

if(isempty(images))
    disp('No image to render !!')
    return
end

if(nargin<3)
    frame_size = [];
end
if(sum(frame_size))
    temp = [];
    for i=1:size(images,4)
        temp(:,:,:,i) = imresize(images(:,:,:,i),frame_size);
    end
    images = temp;
    clear temp
end

if(isempty(images))
    disp('No image to render !!')
else
    % Rendering images
    disp('Start image rendering...');
    for i=1:size(images,4)
        imwrite(images(:,:,:,i),[outname,'_',num2str(i),'.png'],'png');
    end
    disp('Rendering completed.');
end
