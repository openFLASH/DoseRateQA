%% Motion_interpolation_2D
% Perform a multi-scale non-rigid registration of a moving image onto a fixed image by calling the |Registration_modules| function. The registration can be 2 process with the second process is the deformation of a moving mask onto a fixed mask. The resulting deformation field is the *weighted sum* of the defromation fields computed for the moving image and for the moving mask.
% The deformation is then represented in a 'movie' by creating intermediate frames interpolating the deformation between the fixed and moving images. The number of interpolating frames is defined by |nb_frames|. The result is stored at the end of the cell vector |handles.rendering_frames|
%
%% Syntax
% |res = Motion_interpolation_2D(handles,nb_frames)|
%
% |res = Motion_interpolation_2D(handles,nb_frames,moving)|
%
% |res = Motion_interpolation_2D(handles,nb_frames,moving,fixed)|
%
% |res = Motion_interpolation_2D(handles,nb_frames,moving,fixed,moving_mask,fixed_mask)|
%
% |res = Motion_interpolation_2D(handles,nb_frames,moving,fixed,moving_mask,fixed_mask,background)|
%
% |res = Motion_interpolation_2D(handles,nb_frames,moving,fixed,moving_mask,fixed_mask,background,options)|
%
%
%% Description
% |res = Motion_interpolation_2D(handles,nb_frames)| Perform a multi-scale non-rigid registration after manually selecting all the images using a dialog box
%
% |res = Motion_interpolation_2D(handles,nb_frames,moving,...)| Perform a multi-scale non-rigid registration after selecting some of the images using a dialog box
%
% |res = Motion_interpolation_2D(handles,nb_frames,moving,fixed,moving_mask,fixed_mask,background,options)| Perform a multi-scale non-rigid registration using the provided images
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. 
%
% |nb_frames| - _INTEGER_ - Number of interpolating frames to create to represent the deformable registration
%
% |moving| - _STRING_ -  Names of the moving image contained in |handles.images|.
%
% |fixed| - _STRING_ -  Names of the fixed image contained in |handles.images|.
%
% |moving_mask| - _STRING_ - [OPTIONAL] Name of the mask associated with the |moving| image and contained in |handles.images|.
%
% |fixed_mask| - _STRING_ - [OPTIONAL] Name of the mask associated with the |fixed| image and contained in |handles.images|.
%
% |background| - _SCALAR MATRIX_ - The |background(x,y,t)| image is added to the t-th deformed frame in the result |handles.rendering_frames{end}(x,y,J,t)|
%
% |options| - _CELL VECTOR of STRING_ - [OPTIONAL] List of option for the registration. |options{i*2}| is a _STRING_ describing a parameter and |options{i*2+1}| is the value of the corresponding parameter. The following parameters can be defined:
% -----|options{i*2}='Registration'| Type of registration algorithms. See parameter |regis| in function |Registration_modules| for the options. [Default = 4]
%
%
%% Output arguments
%
% |res= handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated:
%
% * |handles.rendering_frames{end}(x,y,J,t)| - _CELL VECTOR of INTEGER MATRIX_ - The movie frames representing the deformation. The new movie is added at the end of the cell vectors. The value of the pixels defines the color of pixel at position (x,y) in the image. |J=1,2,3|  is the RGB triplet value defining the colour (in this case, the image is grey level, so the 3 color planes have the same value). The each |rendering_frames{end}(:,:,:,t)| represents the t-th step of the deformation, with |t<=nb_frames|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO image3 and image4 are not used in the function. This has only an impacct on the line "if(nargin<10)"

function res = Motion_interpolation_2D(handles,nb_frames,moving,fixed,moving_mask,fixed_mask,background,options,image3,image4)

res = handles;

try
    
    if(nargin<3)
        [moving type1] = Image_list(handles,'Select first image',1);
        if(type1~=1)
            error('Error: Input must be an image!')
        end
    end
    if(nargin<4)
        [fixed type2] = Image_list(handles,'Select second image',1);
        if(type2~=1)
            error('Error: Input must be an image!')
        end
    end
    if(nargin<6)
        if(handles.auto_mode)
            moving_mask = 'none';
            fixed_mask = 'none';
        else
            [moving_mask type1] = Image_list(handles,'Select first mask',1);
            if(type1~=1)
                error('Error: Input must be an image!')
            end
            [fixed_mask type2] = Image_list(handles,'Select second mask',1);
            if(type2~=1)
                error('Error: Input must be an image!')
            end
        end
    end
    if(nargin<7)
        if(handles.auto_mode)
            background = 'none';
        else
            [background typeb] = Image_list(handles,'Select background',1);
        end
    end
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},background))
            background = handles.mydata.data{i};
            break
        end
    end
    try
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},background))
                background = handles.images.data{i};
                break
            end
        end
    catch
    end
    if(nargin<10)
        first_image = moving;
        second_image = fixed;
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},first_image) && ~isempty(handles.images.data{i}))
            first_image = handles.images.data{i};
            break
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},second_image) && ~isempty(handles.images.data{i}))
            second_image = handles.images.data{i};
            break
        end
    end
    
    % Default options:
    if(nargin<8)
        options = cell(0);
    end
    myReg = 4;% Demons=2; Morphons=4;
    
    % Input options
    myReg_index = find(double(strcmp(options,'Registration')));
    if(myReg_index & length(options)>myReg_index)
        myReg = options{myReg_index+1};
    end
    
    % Mask for field computation
    if(not(strcmp(fixed_mask,'none')))
        handles.roi_mode = 1;
        handles.current_roi{1} = fixed_mask;
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},fixed_mask) && ~isempty(handles.images.data{i}))
                break
            end
        end
        handles.current_roi{2} = i;
    end
    
    handles = Mask2DistMap(fixed_mask,'temp_fixed_dm',1,handles);
    handles = Mask2DistMap(moving_mask,'temp_moving_dm',1,handles);
    
    % set region of interest
    handles = Dilation(fixed_mask,[6 6],'temp_fixed_ROI',handles);
    handles.roi_mode = 1;
    handles.current_roi{1} = 'temp_fixed_ROI';
    if(strcmp(handles.images.name{length(handles.images.name)},'temp_fixed_ROI'))
        handles.current_roi{2} = length(handles.images.name);
    else
        disp('Error in ROI')
        disp(handles.images.name{length(handles.images.name)});
    end
    
    %handles = Registration_modules(1,{'temp_fixed_dm'},{'temp_moving_dm'},'none',10,ones(1,10)*10,{2},{1},{[]},{1},1,[],6,3,ones(1,10)*1.2,'deformed','def_field','',1,handles,1);
    if(myReg==2)
        handles = Registration_modules(2,{fixed,'temp_fixed_dm'},{moving,'temp_moving_dm'},'none',13,[2 2 10 10 10 10 10 10 10 10 10 10 10],{myReg,2},{1,1},{[],[]},{[1 1 1 1 1 1 1 1 1 1 0 0 0],[0 0 0 0 0 0 0 0.5 0.5 0.5 1 1 1]},1,[],5,2,ones(1,13)*0.8,'deformed','def_field','',1,handles,1);
    else
        handles = Registration_modules(2,{fixed,'temp_fixed_dm'},{moving,'temp_moving_dm'},'none',13,[2 2 10 10 10 10 10 10 10 10 10 10 10],{myReg,2},{1,1},{[],[]},{[1 1 1 1 1 1 1 1 1 1 0 0 0],[0 0 0 0 0 0 0 0.5 0.5 0.5 1 1 1]},1,[],6,3,ones(1,13)*0.8,'deformed','def_field','',1,handles,1);
    end
    
    new_image_name = cell(0);
    new_image_data = cell(0);
    new_image_info = cell(0);
    for i=1:length(handles.images.name)-4
        new_image_name{i} = handles.images.name{i};
        new_image_data{i} = handles.images.data{i};
        new_image_info{i} = handles.images.info{i};
    end
    handles.images.name = new_image_name;
    handles.images.data = new_image_data;
    handles.images.info = new_image_info;
    handles.roi_mode = 0;
    
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},fixed_mask))
            fixed_mask = handles.mydata.data{i};
            break
        end
    end
    try
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},fixed_mask))
                fixed_mask = handles.images.data{i};
                break
            end
        end
    catch
    end
    fixed_mask = fixed_mask - min(min(fixed_mask)); fixed_mask = fixed_mask/(max(max(fixed_mask))+eps);
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},moving_mask))
            moving_mask = handles.mydata.data{i};
            break
        end
    end
    try
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},moving_mask))
                moving_mask = handles.images.data{i};
                break
            end
        end
    catch
    end
    moving_mask = moving_mask - min(min(moving_mask)); moving_mask = moving_mask/(max(max(moving_mask))+eps);
    
    field_log = handles.fields.data{length(handles.fields.data)-1};
    
    rd_nb = length(handles.rendering_frames)+1;
    
    if(isempty(background)) % Without background
        F = first_image;
        handles.rendering_frames{rd_nb}(:,:,:,1) = F';
        for f=2:nb_frames-1
            ratio1 = (nb_frames-f)/(nb_frames-1);
            ratio2 = (f-1)/(nb_frames-1);
            for d=1:size(first_image,3)
                F(:,:,d) = linear_deformation(first_image(:,:,d),'same',field_convert(field_log.*ratio2,2),[],'linear',1)*ratio1 + linear_deformation(second_image(:,:,d),'same',field_convert(-field_log.*ratio1,2),[],'linear',1)*ratio2;
            end
            handles.rendering_frames{rd_nb}(:,:,:,f) = F';
        end
        handles.rendering_frames{rd_nb}(:,:,:,nb_frames) = second_image';
    else % With background
        if(sum(size(background)~=size(first_image)))
            background = imresize(background,[size(first_image,1) size(first_image,2)]);
        end
        M = moving_mask;
        F = first_image;
        for d=1:size(first_image,3)
            F = F(:,:,d).*M + background(:,:,d).*(1-M);
        end
        handles.rendering_frames{rd_nb}(:,:,:,1) = F';
        for f=2:nb_frames-1
            ratio1 = (nb_frames-f)/(nb_frames-1);
            ratio2 = (f-1)/(nb_frames-1);
            M(:,:) = linear_deformation(moving_mask(:,:),'same',field_convert(field_log.*ratio2,2),[],'linear',1)*ratio1 + linear_deformation(fixed_mask(:,:),'same',field_convert(-field_log.*ratio1,2),[],'linear',1)*ratio2;
            for d=1:size(first_image,3)
                F(:,:,d) = linear_deformation(first_image(:,:,d),'same',field_convert(field_log.*ratio2,2),[],'linear',1)*ratio1 + linear_deformation(second_image(:,:,d),'same',field_convert(-field_log.*ratio1,2),[],'linear',1)*ratio2;
                F(:,:,d) = F(:,:,d).*M + background(:,:,d).*(1-M);
            end
            handles.rendering_frames{rd_nb}(:,:,:,f) = F';
        end
        M = fixed_mask;
        F = second_image;
        for d=1:size(second_image,3)
            F = F(:,:,d).*M + background(:,:,d).*(1-M);
        end
        handles.rendering_frames{rd_nb}(:,:,:,nb_frames) = F';
    end
    
    if(size(first_image,3)==1)
        handles.rendering_frames{rd_nb}(:,:,2,:) = handles.rendering_frames{rd_nb}(:,:,1,:);
        handles.rendering_frames{rd_nb}(:,:,3,:) = handles.rendering_frames{rd_nb}(:,:,1,:);
    end
    
    handles.fields.name = handles.fields.name(1:end-2);
    handles.fields.data = handles.fields.data(1:end-2);
    handles.fields.info = handles.fields.info(1:end-2);
    
catch
    fprintf(2,'    ERROR during motion interpolation:');
    err = lasterror;
    disp([' ',err.message]);
    disp(err.stack(1));
end

res = handles;
