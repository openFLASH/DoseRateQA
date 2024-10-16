%% Random_image
% Creates a random 3D image, of default or user specified dimension,
% into REGGUI's data-structure, to set the workspace properties.
%%

%% Syntax
% |handles = Random_image(im_dest,handles,randomness_scale)|
%
% |handles = Random_image(im_dest,handles,randomness_scale,im_size)|

%% Description
% |handles = Random_image(im_dest,handles,randomness_scale)| creates a random 3D image inside
% |handles.images| having as default dimension |64x64x64| pixels, with a given pattern scale (i.e. resolution)
%
% |handles = Random_image(im_dest,handles,randomness_scale,im_size)| creates a void 3D
% image inside |handles.images|, with a given pattern scale (i.e. resolution) and given size (used only if no image in workspace).

%% Input arguments
% |im_dest| - _STRING_ - name of the Random image to be created inside
% |handles.images|
%
% |handles| - _STRUCTURE_ - REGGUI data structure to add the Random image to
%
% |randomness_scale| - _INTEGER_ - scale of the random patterns in the image
%
% |im_size| - _VECTOR_OF_INTEGERS_ - dimension of the newly created image (only used if no image in workspace)

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the
% newly created Random image.

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Random_image(im_dest,handles,randomness_scale,im_size)

if(nargin<3)
    randomness_scale = 1;
end

if(not(handles.size(1) && handles.size(2) && handles.size(3)))
    try
        if(nargin>3)
            new_dims = im_size;
        else
            new_dims = inputdlg('Set dimensions for workspace','Workspace dimensions',1,{'[64 64 64]'});
        end
        handles.spatialpropsettled = 1;
        eval(['new_dims = ',new_dims{1},';']);
        handles.size(1) = new_dims(1);
        handles.size(2) = new_dims(2);
        handles.size(3) = new_dims(3);
    catch
        disp('Error while trying to set workspace properties by creating random image.')
    end
end

if(handles.size(1)==1 || handles.size(2)==1 || handles.size(3)==1)
    error('Not yet implemented in 2D.')
end

erf_parameter = 1e-3;
myInfo = Create_default_info('image',handles);
mySize = round([handles.size(1)/(2^(randomness_scale/2));handles.size(2)/(2^(randomness_scale/2));handles.size(3)/(2^(randomness_scale/2))]);
mySize(find(mySize<1))=1;
myInfo.Spacing = handles.spacing.*handles.size./mySize;
myDataName = check_existing_names(im_dest,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = myDataName;
handles.mydata.data{length(handles.mydata.data)+1} = rand(mySize');
handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
handles = Data2image(myDataName,im_dest,handles);
handles = Remove_data(myDataName, handles);
% smoothing
params = [((2^(randomness_scale/2))*0.2) ((2^(randomness_scale/2))*0.2)*5];
params(2) = max(params(2),5);
handles.images.data{length(handles.images.data)} = matitk('FGA',params,handles.images.data{length(handles.images.data)});
handles.images.data{length(handles.images.data)} = (sign(handles.images.data{length(handles.images.data)}-0.5).*erf(abs((handles.images.data{length(handles.images.data)}-0.5).*2).*(erf_parameter*exp(1))))/2+0.5;
handles.images.data{length(handles.images.data)} = (handles.images.data{length(handles.images.data)}-min(min(min(handles.images.data{length(handles.images.data)}))))/(max(max(max(handles.images.data{length(handles.images.data)})))-min(min(min(handles.images.data{length(handles.images.data)}))));
