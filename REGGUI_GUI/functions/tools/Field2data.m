%% Field2data
% *Copy* and *resample* a displacement field from |handles.fields| into 
% |handles.mydata| internal structure.
%
% All fields stored in |handles.fields| have the same pixel spacing 
% (defined in |handles.spacing|) while the fields stored in |handles.mydata| 
% can each have their own spacing defined in |handles.mydata.info|. 
% The function |Field2data| takes care of the resampling when copying an 
% image from one structure to the other. 
% The purpose of the data in |handles.fields| is for display in the main GUI. 
% The purpose of the data in |handles.mydata| is for computation.
%%

%% Syntax
% |handles = Field2data(field_name,orig,imsize,spacing,data_dest,handles)|

%% Description
% |handles = Field2data(field_name,orig,imsize,spacing,data_dest,handles)| 
% resample and copy the deformation field from |handles.fields| to the 
% |handles.mydata| structure.

%% Input arguments
% |field_name| - _STRING_ -  Name of the field  to be copied, contained in
% |handles.fields.name|.
%
% |orig| - _VECTOR of INTEGER_ - (If empty, defaul = [1;1;1]) Coordinate 
% (x,y,z) (in |pixels| of the original |handles.fields| coordinates) of the
% first voxel (first apex) of the sub-volume to be copied.
%
% |imsize| - _VECTOR of DOUBLE_ - Dimensions (dx,dy,dz) of the edges of the
% paralellipiped to be copied |pixels| of the resulting |handles.mydata| 
% coordinates. If empty, the paralellipied extend to the laxt voxel of 
% |handles.fields|.
%
% |spacing| - _VECTOR of DOUBLE_ - Size of the voxels of |handles.mydata| 
% in |mm|. If empty, then it is the size |handles.spacing| of the input image
%
% |data_dest| - _STRING_ - Name of the new image created in |handles.mydata| 
% with the sub-volume
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI

%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. 
% The following information is updated in the destimation image |i|:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.mydata.info{i}.Spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the image = |spacing|
% * |handles.mydata.info.ImagePositionPatient| : Coordinates (in |mm|) of the
% first pixel of the subvolume in the patient coordinate system
% * |handles.mydata.info{i}.OriginalHeader| : copied from |handles.fields.info| if present
% * |handles.mydata.info{i}.PatientID| : copied from |handles.fields.info| if present
% * |handles.mydata.info{i}.FrameOfReferenceUID| : copied from |handles.fields.info| if present
% * |handles.mydata.info{i}.SOPInstanceUID| : copied from |handles.fields.info| if present
% * |handles.mydata.info{i}.SeriesInstanceUID| : copied from |handles.fields.info| if present
% * |handles.mydata.info{i}.SOPClassUID| : copied from |handles.fields.info| if present
% * |handles.mydata.info{i}.StudyInstanceUID| : copied from |handles.fields.info| if present
%
%% Notes
% * The |handles.fields| image is resampled to create the |handles.mydata|. 
% A round filter with a sigma = 2*old spacing / new spacing is convolved 
% with the image (conv2 or, if Z spacing is not 1mm: conv3 ). Then the new 
% field is interpolated from the convolved field with the required voxel 
% spacing.

%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com), Jonathan Orban.

function handles = Field2data(field_name,orig,imsize,spacing,data_dest,handles)

field = [];
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},field_name))
        field = handles.fields.data{i};
        field_info = handles.fields.info{i};
    end
end
if(isempty(field))
   error('Field not found !')
end
if(isempty(orig))
    orig = [1;1;1];
end
if(isempty(imsize))
    imsize = [size(field,2);size(field,3);size(field,4)];
end
if(isempty(spacing))
    spacing = handles.spacing;
end
if(strcmp(field_info.Type,'deformation_field'))
    % same_spacing = 0;
    % for i=1:3
    %     if(round(spacing(i)*1e3)==round(handles.spacing(i)*1e3))
    %         spacing(i) = handles.spacing(i);
    %         same_spacing = same_spacing+1;
    %     end
    % end
    info = Create_default_info('deformation_field',handles,field_info);
    if(isfield(field_info,'OriginalHeader'))
        info.OriginalHeader = field_info.OriginalHeader;
    end
    info.Spacing = spacing;
    try
        info.ImagePositionPatient = field_info.ImagePositionPatient + (orig-1).*handles.spacing;
    catch
        error('Error: Image info not found !')
    end
    data_tot = [];
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
            %         if(same_spacing==3)
            %             data = image(orig(1):orig(1)+imsize(1)-1,orig(2):orig(2)+imsize(2)-1);
            %         else
            lastpt = orig + (imsize-1).*spacing./handles.spacing;
            [X Y] = meshgrid(linspace(orig(2)+1,lastpt(2),imsize(2)),linspace(orig(1)+1,lastpt(1),imsize(1)));
            X = single(X);
            Y = single(Y);
            data = interp2(image,X,Y);
            %         end
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
            %         if(same_spacing==3)
            %             data = image(orig(1):orig(1)+imsize(1)-1,orig(2):orig(2)+imsize(2)-1,orig(3):orig(3)+imsize(3)-1);
            %         else
            lastpt = orig + (imsize-1).*spacing./handles.spacing;
            %         [X Y Z] = meshgrid(linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(3)+1,lastpt(3),imsize(3)));
            %                 X = single(X);
            %         Y = single(Y);
            %         Z = single(Z);
            %         data = interp3(image,X,Y,Z);
            data = resampler3(image,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)));
            %         end
        end
        if(n==1)
            data_tot = zeros([1 size(data)],'single');
        end
        data_tot(n,:,:,:) = data/spacing(n)*handles.spacing(n);
    end
    data_dest = check_existing_names(data_dest,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
    handles.mydata.data{length(handles.mydata.data)+1} = data_tot;
    handles.mydata.info{length(handles.mydata.info)+1} = info;

elseif(strcmp(field_info.Type,'rigid_transform'))
    data_tot = field;
    info = Create_default_info('rigid_transform',handles);
    if(isfield(field_info,'OriginalHeader'))
        info.OriginalHeader = field_info.OriginalHeader;
    end
    for j=1:3
        data_tot(1,j) = data_tot(1,j)*info.Spacing(j)/spacing(j);
    end
    info.Spacing = spacing;
    info.Spacing = spacing;
    try
        info.ImagePositionPatient = field_info.ImagePositionPatient + (orig-1).*handles.spacing;
    catch
        error('Error: Image info not found !')
    end
    data_dest = check_existing_names(data_dest,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
    handles.mydata.data{length(handles.mydata.data)+1} = data_tot;
    handles.mydata.info{length(handles.mydata.info)+1} = info;
else
    error('Impossible to resample this data because it is not of type ''deformation_field''');
end
