%% Resample_all
% Resamples (=interpolate) the pixel spacing, changes the origin and the size of all the images in |handles.images| and all the fields in |handles.fields| (i.e. redefines what is displayed in the main GUI) according to some defined resampling specifications. The resampling specifications can be defined either (a) to match the size and spacing of an image stored in |handles.mydata| or (b) the size of a mask stored in |handles.images| or (c) the input parameters given to the function.
%
% All the images stored in |handles.images| have the same pixel spacing (defined in |handles.spacing|) while the images stored in |handles.mydata| can each have their own spacing defined in |handles.mydata.info|. The function |Image2data| takes care of the resampling when copying an image from one structure to the other. The purpose of the data in |handles.images| is for display in the main GUI. The purpose of the data in |handles.mydata| is for computation.
%
%% Syntax
% |handles = Resample_all(handles,orig)|
%
% |handles = Resample_all(handles,orig,imsize,spacing)|
%
% |handles = Resample_all(handles,orig,imsize,spacing,resample_type)|
%
% |handles = Resample_all(handles,orig,imsize,spacing,resample_type,padding_value)|
%
%
%% Description
% |handles = Resample_all(handles,orig=_STRING_)| Resample *all* the images in |handles.images| and *all* the fields in |handles.fields| based on one image stored in |handles.mydata| to match the spacing |handles.myInfo.Spacing| (implicit: |resample_type = 'from_image'|, case (a))
%
% |handles = Resample_all(handles,orig,imsize,spacing)| Resample the image using the input parameters ( Implicit: |resample_type = 'from_params'|, case (c))
%
% |handles = Resample_all(handles,orig,imsize,spacing,resample_type = 'from_mask')| (b) resample *all* the images in |handles.images| and *all* the fields in |handles.fields| based on the mask stored in |handles.images| using |spacing| and the image size |imsize|. The mask is defined by the voxels set = 1 in the image. The other voxels are set =0. The images are resized and recentered so that the resampled image extends by a distance +/- imsize beyond the extreme voxels = 1.
%
% % |handles = Resample_all(handles,orig,imsize,spacing,resample_type = 'from_params')| (c) resample the image using the specified resampling type and the default padding value
%
% |handles = Resample_all(handles,orig,imsize,spacing,resample_type,padding_value)| (a,b,c) resample the image using the specified resampling type and the specified padding value
%
%
%% Input arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.view_point| - _INTEGER VECTOR_ Coordinate (in pixel, origin at 1st voxel) of the isocentre in the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.origin|  - _SCALAR VECTOR_ -  Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.size| - _SCALAR VECTOR_ - |handles.size= [x,y,z]| size (in voxels) of the images stored in |handles.images|
%
% |orig| - Definition depends on the resampling method
% * (a) Case |resample_type = 'from_image'| :  _STRING_ -  Name of the image in |handles.mydata| used as template for resampling
% * (b) Case |resample_type = 'from_mask'|  :  _STRING_ -  Name of the mask image in |handles.images| used as template for cropping
% * (c) Case |resample_type = 'from_params'| : _VECTOR of INTEGERS_ Defines the cropping mask. Position (x,y,z) (in voxel) of the first voxel of the original image to be copied to the resampled image.
%
% |imsize| - _VECTOR of DOUBLE_ -   Dimensions (x,y,z) (in |mm|) of the resampled image.
%                                   If empty, it is computed from |origin| and |spacing|
%                                   Definition depends on the resampling method:
%
% * (a) Case |resample_type = 'from_image'| : the parameter is ignored and the size of the image in |handles.mydata| used as template for resampling.
% * (b) Case |resample_type = 'from_mask'| : the resampled image size extends by +x and -x (resp. y,z) beyond the extreme pixels of the mask.
% * (c) Case |resample_type = 'from_params'| : Defines the croping mask. Size (dx,dy,dz) (in pixels) of the edges of the zone of the original image to be copied to the resampled image.
%
% |spacing| - _VECTOR of DOUBLE_ - Size (x,y,z)(in |mm|) of the voxels in the resampled image. If a single scalar S is given, then |spacing = [s,s,s]|. If empty (|spacing|=[]), then the function uses |handles.spacing|. If one element of the vector is equal to 0, then the function uses the value of this element from |handles.spacing|. In the case of (a) |resample_type = 'from_image'|, the parameter is ignored and the spacing is set equal to |handles.mydata.info|, i.e. the spacing of the image defined in |handles.mydata|.
%
% |resample_type| - _STRING_ -  Define the resampling method: (a) |resample_type = 'from_image'|, (b) |resample_type = 'from_mask'|, (c) |resample_type = 'from_params'|
%
% |padding_value| - _SCALAR_ -  (Default = 0). The padding value is subtracted from all the pixels of the image before interpolation and then added again after interpolation.
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. All the images in |handles.images| and all the fields in |handles.fields| have been resampled
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com), J.Orban

function handles = Resample_all(handles,orig,imsize,spacing,resample_type,padding_value)

if(nargin==2)
    resample_type = 'from_image';
elseif(nargin<5)
    resample_type = 'from_params';
end
if(nargin<6)
    padding_value = 0;
end

view_point = handles.view_point.*handles.spacing + handles.origin;

if(strcmp(resample_type,'from_image')) % Resample according to data image properties
    mydata_name = orig;
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},mydata_name))
            myData = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
            if(not(strcmp(myInfo.Type,'image')))
                error('Error: unvalid type for reference data (must be an image)!');
            end
        end
    end
    orig = (myInfo.ImagePositionPatient - handles.origin)./handles.spacing +1;
    imsize = size(myData)';
    spacing = myInfo.Spacing;
    new_origin = myInfo.ImagePositionPatient;
elseif(strcmp(resample_type,'from_mask')) % Crop according to mask
    if(isempty(spacing))
        spacing = handles.spacing;
    end
    for i=1:3
        if(spacing(i)==0)
            spacing(i) = handles.spacing(i);
        end
    end
    mask_name = orig;
    borders = imsize; % if crop_from_mask, imsize gives the border around the mask
    imsize = [];
    if(isempty(borders))
        borders = [0,0;0,0;0,0];
    elseif(length(borders)==1)
        borders = [borders,borders;borders,borders;borders,borders];
    elseif(size(borders,1)==1 && size(borders,2)==3)
        borders = [borders',borders'];
    elseif(size(borders,1)==2 && size(borders,2)==3)
        borders = borders';
    elseif(size(borders,1)==3 && size(borders,2)==1)
        borders = [borders,borders];
    end
    bb = [round(borders(:,1)./handles.spacing),round(borders(:,2)./handles.spacing)];% borders in [mm], bb in voxels.
    myImage = [];
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},mask_name))
            myImage = handles.images.data{i};
        end
    end
    if(isempty(myImage) || not(sum(myImage(:))))
        error('Error : empty mask or mask not found in the image list !')
    end
    [i,j,~] = find(myImage);
    [j,k] = ind2sub([handles.size(2) handles.size(3)],j);
    orig = [max(1,min(i)-bb(1,1));max(1,min(j)-bb(2,1));max(1,min(k)-bb(3,1))];
    maximum = [min(handles.size(1),max(i)+bb(1,2));min(handles.size(2),max(j)+bb(2,2));min(handles.size(3),max(k)+bb(3,2))];
    imsize_default = round((maximum-orig+1).*handles.spacing./spacing);
    if(isempty(imsize))
        imsize = imsize_default;
    end
    imsize(imsize==0) = imsize_default(imsize==0);
    new_origin = handles.origin + (orig-1).*handles.spacing;
else % Resample according to input spatial parameters
    if(isempty(spacing))
        spacing = handles.spacing;
    end
    for i=1:3
        if(spacing(i)==0)
            spacing(i) = handles.spacing(i);
        end
    end
    if(isempty(orig))
        orig = [1;1;1];
    end
    imsize_default = round((handles.size-orig+1).*handles.spacing./spacing);
    if(isempty(imsize))
        imsize = imsize_default;
    end
    imsize(imsize==0) = imsize_default(imsize==0);
    new_origin = handles.origin + (orig-1).*handles.spacing;
end

same_spacing = 0;
for i=1:3
    if(round(spacing(i)*1e3)==round(handles.spacing(i)*1e3))
        spacing(i) = handles.spacing(i);
        same_spacing = same_spacing+1;
    end
end
for i=2:length(handles.images.name)
    image = handles.images.data{i} - padding_value;
    image_info = handles.images.info{i};
    info = image_info;
    if(not(image_info.Spacing(3)==spacing(3) && imsize(3)==size(image,3)) && isfield(info,'SOPInstanceUID'))
        try
            info = rmfield(info,'SOPInstanceUID');
        catch
        end
    end
    info.Spacing = spacing;
    try
        info.ImagePositionPatient = new_origin;
    catch
        error('Error: Image info not found or invalid parameters!')
    end
    if(handles.size(3) == 1)
        if(spacing(1)>handles.spacing(1))
            downfactor = spacing(1)./handles.spacing(1);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filterx = gaussian_kernel(fsz, sigma);
            filterx = filterx/sum(filterx);
            image = conv2(image, filterx);
        end
        if(spacing(2)>handles.spacing(2))
            downfactor = spacing(2)./handles.spacing(2);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filtery = gaussian_kernel(fsz, sigma);
            filtery = filtery'/sum(filtery);
            image = conv2(image, filtery);
        end
        if(same_spacing==3 && sum(orig==round(orig))==2)
            data = image(orig(1):orig(1)+imsize(1)-1,orig(2):orig(2)+imsize(2)-1);
        else
            lastpt = orig + (imsize-1).*spacing./handles.spacing;
            [X Y] = meshgrid(linspace(orig(2)+1,lastpt(2),imsize(2)),linspace(orig(1)+1,lastpt(1),imsize(1)));
            X = single(X);
            Y = single(Y);
            data = interp2(image,X,Y);
        end
    else
        if(spacing(1)>handles.spacing(1))
            downfactor = spacing(1)./handles.spacing(1);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filterx = gaussian_kernel(fsz, sigma);
            filterx = filterx/sum(filterx);
            image = padarray(image, [length(filterx) 0 0], 'replicate');
            image = conv3f(image, single(filterx));
            image = image(length(filterx)+1:end-length(filterx), :, :);
        end
        if(spacing(2)>handles.spacing(2))
            downfactor = spacing(2)./handles.spacing(2);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filtery = gaussian_kernel(fsz, sigma);
            filtery = filtery'/sum(filtery);
            image = padarray(image, [0 length(filtery) 0], 'replicate');
            image = conv3f(image, single(filtery));
            image = image(:,length(filtery)+1:end-length(filtery), :);
        end
        if(spacing(3)>handles.spacing(3))
            downfactor = spacing(3)./handles.spacing(3);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filterz = gaussian_kernel(fsz, sigma);
            filterz = filterz/sum(filterz);
            image = padarray(image, [0 0 length(filterz)], 'replicate');
            image = conv3f(image, single(permute(filterz, [3 2 1])));
            image = image(:,:,length(filterz)+1:end-length(filterz));
        end
        if(same_spacing==3 && sum(orig==round(orig))==3)
            data = zeros(imsize(1),imsize(2),imsize(3))+min(image(:));
            data( max(1,(1-orig(1))+1):min(imsize(1),(1-orig(1))+size(image,1)), ...
                max(1,(1-orig(2))+1):min(imsize(2),(1-orig(2))+size(image,2)), ...
                max(1,(1-orig(3))+1):min(imsize(3),(1-orig(3))+size(image,3))) = image( max(1,orig(1)):min(size(image,1),orig(1)+imsize(1)-1),...
                max(1,orig(2)):min(size(image,2),orig(2)+imsize(2)-1),...
                max(1,orig(3)):min(size(image,3),orig(3)+imsize(3)-1));
        else
            lastpt = orig + (imsize-1).*spacing./handles.spacing;
            data = resampler3(image,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)));
        end
    end
    handles.images.data{i} = data + padding_value;
    handles.images.info{i} = info;
end


for i=2:length(handles.fields.name)
    field = handles.fields.data{i};
    field_info = handles.fields.info{i};
    info = field_info;
    data_tot = [];
    if(strcmp(field_info.Type,'deformation_field'))
        info.Spacing = spacing;
        try
            info.ImagePositionPatient = new_origin;
        catch
            error('Error: Image info not found !')
        end
        for n=1:size(field,1)
            image = squeeze(field(n,:,:,:));
            if(handles.size(3) == 1)
                if(spacing(1)>handles.spacing(1))
                    downfactor = spacing(1)./handles.spacing(1);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filterx = gaussian_kernel(fsz, sigma);
                    filterx = filterx/sum(filterx);
                    image = conv2(image, filterx);
                end
                if(spacing(2)>handles.spacing(2))
                    downfactor = spacing(2)./handles.spacing(2);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filtery = gaussian_kernel(fsz, sigma);
                    filtery = filtery'/sum(filtery);
                    image = conv2(image, filtery);
                end
                if(same_spacing==3 && sum(orig==round(orig))==2)
                    data = image(orig(1):orig(1)+imsize(1)-1,orig(2):orig(2)+imsize(2)-1);
                else
                    lastpt = orig + (imsize-1).*spacing./handles.spacing;
                    [X Y] = meshgrid(linspace(orig(2)+1,lastpt(2),imsize(2)),linspace(orig(1)+1,lastpt(1),imsize(1)));
                    X = single(X);
                    Y = single(Y);
                    data = interp2(image,X,Y);
                end
            else
                if(spacing(1)>handles.spacing(1))
                    downfactor = spacing(1)./handles.spacing(1);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filterx = gaussian_kernel(fsz, sigma);
                    filterx = filterx/sum(filterx);
                    image = padarray(image, [length(filterx) 0 0], 'replicate');
                    image = conv3f(image, single(filterx));
                    image = image(length(filterx)+1:end-length(filterx), :, :);
                end
                if(spacing(2)>handles.spacing(2))
                    downfactor = spacing(2)./handles.spacing(2);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filtery = gaussian_kernel(fsz, sigma);
                    filtery = filtery'/sum(filtery);
                    image = padarray(image, [0 length(filtery) 0], 'replicate');
                    image = conv3f(image, single(filtery));
                    image = image(:,length(filtery)+1:end-length(filtery), :);
                end
                if(spacing(3)>handles.spacing(3))
                    downfactor = spacing(3)./handles.spacing(3);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filterz = gaussian_kernel(fsz, sigma);
                    filterz = filterz/sum(filterz);
                    image = padarray(image, [0 0 length(filterz)], 'replicate');
                    image = conv3f(image, single(permute(filterz, [3 2 1])));
                    image = image(:,:,length(filterz)+1:end-length(filterz));
                end
                if(same_spacing==3 && sum(orig==round(orig))==3)
                    data = zeros(imsize(1),imsize(2),imsize(3));
                    data( max(1,(1-orig(1))+1):min(imsize(1),(1-orig(1))+size(image,1)), ...
                        max(1,(1-orig(2))+1):min(imsize(2),(1-orig(2))+size(image,2)), ...
                        max(1,(1-orig(3))+1):min(imsize(3),(1-orig(3))+size(image,3))) = image( max(1,orig(1)):min(size(image,1),orig(1)+imsize(1)-1),...
                        max(1,orig(2)):min(size(image,2),orig(2)+imsize(2)-1),...
                        max(1,orig(3)):min(size(image,3),orig(3)+imsize(3)-1));
                else
                    lastpt = orig + (imsize-1).*spacing./handles.spacing;
                    data = resampler3(image,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)),0);
                end
            end
            if(n==1)
                data_tot = zeros([1 size(data)],'single');
            end
            data_tot(n,:,:,:) = data/spacing(n)*handles.spacing(n);
        end
    elseif(strcmp(field_info.Type,'rigid_transform'))
        data_tot = field;
        for j=1:3
            data_tot(1,j) = round(data_tot(1,j)*info.Spacing(j)/spacing(j));
        end
        info.Spacing = spacing;
        try
            info.ImagePositionPatient = new_origin;
        catch
            error('Error: Image info not found !')
        end
    else
        data_tot = field;
        disp('Impossible to resample this data because it has not a valid type');
    end
    handles.fields.data{i} = data_tot;
    handles.fields.info{i} = info;
end
handles.size(1) = imsize(1);
handles.size(2) = imsize(2);
handles.size(3) = imsize(3);
handles.spacing = spacing;
handles.origin = new_origin;
handles.view_point = round((view_point - handles.origin)./handles.spacing);
