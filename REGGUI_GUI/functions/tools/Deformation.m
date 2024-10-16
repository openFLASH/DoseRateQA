%% Deformation
% The function applies a deformation field on the image container 
% |handles.images| within REGGUI.
%%

%% Syntax
% |[handles imDef] = Deformation(image,field,im_dest,handles)|
%
% |[handles imDef] = Deformation(image,field,im_dest,handles,interpolation)|

%% Description
% |[handles imDef] = Deformation(image,field,im_dest,handles)| applies a
% previosuly computed deformation field to an image, using by default a 
% _linear_ interpolation scheme. 
%
% |[handles imDef] = Deformation(image,field,im_dest,handles,interpolation)|
% applies a previously computed deformation field on an image, using 
%_'nearest'_, _'cubic'_ or _'spline'_ interpolation types.

%% Input arguments
% |image| - _STRING_ - name of the image stored in |handles.mydata.name| on
% which to apply a deformation.
%
% |field| - _STRING_ - name of deformation field in |handles.fields.name| 
% to be applied to the input image.
%
% |im_dest| - _STRING_ - name of the newly deformed image, to be stored in 
% |handles.images|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the newly 
% deformed image
%
% |interpolation| - _STRING_ - accepts _'nearest'_, _'cubic'_ or _'spline'_
% interpolation types.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal structure containing the deformed
% image inside |handles.images|.

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [handles imDef] = Deformation(image,field,im_dest,handles,interpolation)

% Retrieve transformation (rigid or deformable)
myField = [];
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},field))
        myInfo = handles.fields.info{i};
        if(strcmp(myInfo.Type,'deformation_field'))
            myField = cell(0);
            myField{1} = squeeze(handles.fields.data{i}(2,:,:,:));
            myField{2} = squeeze(handles.fields.data{i}(1,:,:,:));
            if(size(handles.fields.data{i},1)==3)
                myField{3} = squeeze(handles.fields.data{i}(3,:,:,:));
            end
        elseif(strcmp(myInfo.Type,'rigid_transform'))
            myField = handles.fields.data{i};
        end
    end
end

% Retrieve data to be deformed (image or vector field)
type = 'image';
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},image))
        myImage = handles.fields.data{i};
        imageInfo = handles.fields.info{i};
        type = 'vector_field';
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        imageInfo = handles.images.info{i};
    end
end
try
    switch type
        case 'image'
            if(strcmp(myInfo.Type,'deformation_field'))
                if(nargin<5)
                    imDef = linear_deformation(myImage, ' ', myField, []);
                else
                    imDef = linear_deformation(myImage, ' ', myField, [], interpolation);
                end
            elseif(strcmp(myInfo.Type,'rigid_transform'))
                if(length(size(myImage))==2)
                    imDef = rigid_deformation2D(myImage,myField,handles.spacing,handles.origin);
                else
                    imDef = rigid_deformation(myImage,myField,handles.spacing,handles.origin);
                end
            else
                error('Not a valid type. Must be ''deformation_field'' or ''rigid_transform''')
            end
            im_dest = check_existing_names(im_dest,handles.images.name);
            handles.images.name{length(handles.images.name)+1} = im_dest;
            handles.images.data{length(handles.images.data)+1} = single(imDef);
            info = Create_default_info('image',handles,imageInfo);
            if(isfield(imageInfo,'OriginalHeader'))
                info.OriginalHeader = imageInfo.OriginalHeader;
            end
            handles.images.info{length(handles.images.info)+1} = info;
        case 'vector_field'
            disp('Vector field deformation not yet implemented.')
    end
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
