%% Empty_image
% Creates a void 3D image, of default or user specified dimension, 
% into REGGUI's data-structure, to set the workspace properties.
%%

%% Syntax
% |handles = Empty_image(im_dest,handles)|
%
% |handles = Empty_image(im_dest,handles,reference_image)|
%
% |handles = Empty_image(im_dest,handles,reference_image,im_size)|

%% Description
% |handles = Empty_image(im_dest,handles)| creates a void 3D image inside 
% |handles.images| having as default dimension |64x64x64| pixels. 
%
% |handles = Empty_image(im_dest,handles,reference_image)| creates a void 3D 
% image inside |handles.images| with the same meta information as in reference_image.
%
% |handles = Empty_image(im_dest,handles,reference_image,im_size)| creates a void 3D 
% image inside |handles.images| with the same meta information as in reference_image and given size (used only if no image in workspace).

%% Input arguments
% |im_dest| - _STRING_ - name of the empty image to be created inside 
% |handles.images|
%
% |handles| - _STRUCTURE_ - REGGUI data structure to add the empty image to
%
% |reference_image| - _STRING_ - name of the reference image from which the meta information is copied
%
% |im_size| - _VECTOR_OF_INTEGERS_ - dimension of the newly created image (only used if no image in workspace)

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the
% newly created empty image.

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Empty_image(im_dest,handles,reference_image,im_size,im_spacing,im_orig)
if(not(handles.size(1) && handles.size(2) && handles.size(3)))
    try
        if(nargin>3)
            new_dims = im_size;
        else
            new_dims = inputdlg('Set dimensions for workspace','Workspace dimensions',1,{'[64 64 64]'});
            eval(['new_dims = ',new_dims{1},';']);
        end
        handles.size = [new_dims(1);new_dims(2);new_dims(3)];
        if(nargin>4)
            handles.spacing = [im_spacing(1);im_spacing(2);im_spacing(3)];
        end
        if(nargin>5)
            handles.origin = [im_orig(1);im_orig(2);im_orig(3)];
        end
        handles.spatialpropsettled = 1;        
    catch
        disp('Error while trying to set workspace properties by creating empty image.')
    end
end
if(nargin<3)
    reference_image = '';
end

if(not(isempty(reference_image))) % using reference_image
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},reference_image))
            myImage = handles.images.data{i};
            myInfo = handles.images.info{i};
        end
    end
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = zeros(size(myImage));
    handles.images.info{length(handles.images.info)+1} = myInfo;
else
    imEmpty = zeros(handles.size(1),handles.size(2),handles.size(3),'single');
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = imEmpty;
    handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles);
end


