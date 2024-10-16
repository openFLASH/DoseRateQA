%% Image2data
% *Copy* and *resample* a paralellipipedic *sub-volume* of an image from |handles.images| into the |handles.mydata| structure.
%
% All the images stored in |handles.images| have the same pixel spacing (defined in |handles.spacing|) while the images stored in |handles.mydata| can each have their own spacing defined in |handles.mydata.info|. The function |Image2data| takes care of the resampling when copying an image from one structure to the other. The purpose of the data in |handles.images| is for display in the main GUI. The purpose of the data in |handles.mydata| is for computation.
%%

%% Syntax
% |handles = Image2data(image_name,orig,imsize,spacing,data_dest,handles)|
%
%% Description
% |handles = Image2data(image_name,orig,imsize,spacing,data_dest,handles)|  resample and copy the image from |handles.images| to the |handles.mydata| structure.
%
%% Input arguments
% |image_name| - _STRING_ -  Name of the image contained in |handles.images.name| to be copied
%
% |orig| - _VECTOR of INTEGER_ -  (If empty, defaul = [1;1;1]) Coordinate (x,y,z) (in |pixels| of the original |handles.images| coordinates) of the first voxel (first apex) of the sub-volume to be copied
%
% |imsize| - _VECTOR of DOUBLE_ -  Dimensions (dx,dy,dz) of the edges of the paralellipiped to be copied |pixels| of the resulting |handles.mydata| coordinates. If empty, the paralellipied extend to the last voxel of |handles.images|.
%
% |spacing| - _VECTOR of DOUBLE_ -  Size of the voxels of |handles.mydata| in |mm|. If empty, then it is the size |handles.spacing| of the input image
%
% |data_dest| - _STRING_ -  Name of the new image created in |handles.mydata| with the sub-volume
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) = the resampled sub-volume of the image
% * |handles.mydata.info{i}.Spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the image = |spacing|
% * |handles.mydata.info{i}.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (x,y,z) (in mm) of the voxel (1,1,1) of the image ( in |mydata|) in the DICOM coordinate system
% * |handles.mydata.info{i}.OriginalHeader| Original information from DICOM file. Copied from |handles.images.info| if existing
% * |handles.mydata.info{i}.PatientID| - _STRING_ - DICOM unique identifier of the patient. Copied from |handles.images.info| if present
% * |handles.mydata.info{i}.FrameOfReferenceUID| - _STRING_ - Unique DICOM identifier of the coordinate system. Copied from |handles.images.info| if present
% * |handles.mydata.info{i}.SOPInstanceUID| - _STRING_ - copied from |handles.images.info| if present
% * |handles.mydata.info{i}.SeriesInstanceUID| - _STRING_ - Unique DICOM identifier for the study instance UID. Copied from |handles.images.info| if present
% * |handles.mydata.info{i}.SOPClassUID| - _STRING_ - DICOM identifier for the SOP class. Copied from |handles.images.info| if present
% * |handles.mydata.info{i}.StudyInstanceUID| - _STRING_ - Unique DICOM identifier for the study instance UID. Copied from |handles.images.info| if present
%
%% Notes
% * The |handles.images| image is resampled to create the |handles.mydata|. A round filter with a sigma = 2*old spacing / new spacing is convolved with the image (conv2 or, if Z spacing is not 1mm: conv3 ). Then the new image is interpolated from the convolved image with the required voxel spacing.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com), J.Orban

function handles = Image2data(image_name,orig,imsize,spacing,data_dest,handles)

image = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image_name))
        image = handles.images.data{i};
        image_info = handles.images.info{i};
    end
end
if(isempty(image))
    error('Image not found !')
end
if(isempty(orig))
    orig = [1;1;1];
end
if(isempty(spacing))
    spacing = handles.spacing;
end
if(isempty(imsize))
    size_image = size(image)';
    size_image = [size_image;ones(3,1)];
    size_image = size_image(1:3);
    imsize = floor((size_image-orig+1).*image_info.Spacing./spacing);
end
for n=1:3
    if(not(imsize(n)))
        imsize(n) = floor((size(image,n)-orig(n)+1).*image_info.Spacing(n)/spacing(n));
    end
end
% same_spacing = 0;
% for i=1:3
%     if(round(spacing(i)*1e3)==round(handles.spacing(i)*1e3))
%         spacing(i) = handles.spacing(i);
%         same_spacing = same_spacing+1;
%     end
% end
info = Create_default_info('image',handles,image_info);
info.Spacing = spacing;
try
    info.ImagePositionPatient = image_info.ImagePositionPatient + (orig-1).*handles.spacing;
catch
    error('Error: Image info not found or invalid parameters!')
end
if(isfield(image_info,'OriginalHeader'))
    info.OriginalHeader = image_info.OriginalHeader;
end
if(isfield(image_info,'PatientID'))
    info.PatientID = image_info.PatientID;
end
if(isfield(image_info,'FrameOfReferenceUID'))
    info.FrameOfReferenceUID = image_info.FrameOfReferenceUID;
end
if(isfield(image_info,'SOPInstanceUID') && image_info.Spacing(3)==spacing(3) && imsize(3)==size(image,3))
    info.SOPInstanceUID = image_info.SOPInstanceUID;
end
if(isfield(image_info,'SeriesInstanceUID'))
    info.SeriesInstanceUID = image_info.SeriesInstanceUID;
end
if(isfield(image_info,'SOPClassUID'))
    info.SOPClassUID = image_info.SOPClassUID;
end
if(isfield(image_info,'StudyInstanceUID'))
    info.StudyInstanceUID = image_info.StudyInstanceUID;
end

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
lastpt = orig + (imsize-1).*spacing./handles.spacing;
%         [X Y Z] = meshgrid(linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(3),lastpt(3),imsize(3)));
%         X = single(X);
%         Y = single(Y);
%         Z = single(Z);
%         data = interp3(image,X,Y,Z);
data = resampler3(image,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)));

data_dest = check_existing_names(data_dest,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
handles.mydata.data{length(handles.mydata.data)+1} = data;
handles.mydata.info{length(handles.mydata.info)+1} = info;
