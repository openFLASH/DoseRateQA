%% Data2Image
% *Copy* and *resample* an image from the |handles.mydata| into the |handles.images| structure.
%
% All the images stored in |handles.images| have the same pixel spacing (defined in |handles.spacing|) while the images stored in |handles.mydata| can each have their own spacing defined in |handles.mydata.info|. The function |Image2data| takes care of the resampling when copying an image from one structure to the other. The purpose of the data in |handles.images| is for display in the main GUI. The purpose of the data in |handles.mydata| is for computation.
%%

%% Syntax
% |handles = Data2image(mydata_name,image_dest,handles)|

%% Description
% |handles = Data2image(mydata_name,image_dest,handles)|  resample and copy the image from |handles.mydata| to the |handles.images| structure.

%% Input arguments
% |mydata_name| - _STRING_ -  Name of the image contained in |handles.mydata| to be copied
%
%
% |image_dest| - _STRING_ -  Name of the new image created in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the ith image
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) of the ith image
% * |handles.mydata.info{i}.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the ith images in |mydata|
% * |handles.mydata.info{i}.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (x,y,z) (in mm) of the voxel (1,1,1) of the ith image ( in |mydata|) in the DICOM coordinate system
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI

%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info|
% * |handles.minscale| - _SCALAR_ - Adapt the minimum of the display to the minimum of the copied image
% * |handles.maxscale| - _SCALAR_ - Adapt the maximum of the display to the maximum of the copied image
% * |handles.images.info{i}.OriginalHeader| Original information from DICOM file. Copied from |handles.images.info| if existing
% * |handles.images.info{i}.PatientID - _STRING_ - DICOM unique identifier of the patient. Copied from |handles.images.info| if present
% * |handles.images.info{i}.PatientName| - _STRING_ - Name of the patient. Copied from |handles.images.info| if present
% * |handles.images.info{i}.StudyInstanceUID| - _STRING_ - Unique DICOM identifier for the study instance UID. Copied from |handles.images.info| if present

%% Notes
% * The |handles.mydata| image is resampled to create the |handles.images|. A round filter with a sigma = 2*old spacing / new spacing is convolved with the image (conv2 or, if Z spacing is not 1mm: conv3 ). Then the new image is interpolated from the convolved image with the required voxel spacing.
%
% * If no images are defined in the main GUI, the function defines the values for the display properties (size, origin and spacing) using the parameters of the image in |handles.mydata|

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com), J.Orban

function handles = Data2image(mydata_name,image_dest,handles,delete_after_transfer)

if(nargin<4)
    delete_after_transfer = 0;
end

Image_load = 1;
myData = [];
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},mydata_name))
        myData = single(handles.mydata.data{i});
        myInfo = handles.mydata.info{i};
    end
end
if(isempty(myData))
    error('Data not found !')
end
if(~strcmp(myInfo.Type,'image'))
    error('Impossible to convert this data because it is not of type ''image''');
end
if(handles.spatialpropsettled)
    for i=1:3
        if(round(myInfo.Spacing(i)*1e3)==round(handles.spacing(i)*1e3))
            myInfo.Spacing(i) = handles.spacing(i);
        end
    end
    orig = (- myInfo.ImagePositionPatient + handles.origin)./myInfo.Spacing +1;
    
    if(handles.spacing(1)>myInfo.Spacing(1))
        downfactor = handles.spacing(1)./myInfo.Spacing(1);
        sigma = downfactor*.4;
        fsz = round(sigma * 5);
        fsz = fsz + (1-mod(fsz,2));
        filterx = gaussian_kernel(fsz, sigma);
        filterx = filterx/sum(filterx);
        myData = padarray(myData, [length(filterx) 0 0], 'replicate');
        myData = conv3f(myData, single(filterx));
        myData = myData(length(filterx)+1:end-length(filterx), :, :);
    end
    if(handles.spacing(2)>myInfo.Spacing(2))
        downfactor = handles.spacing(2)./myInfo.Spacing(2);
        sigma = downfactor*.4;
        fsz = round(sigma * 5);
        fsz = fsz + (1-mod(fsz,2));
        filtery = gaussian_kernel(fsz, sigma);
        filtery = filtery'/sum(filtery);
        myData = padarray(myData, [0 length(filtery) 0], 'replicate');
        myData = conv3f(myData, single(filtery));
        myData = myData(:,length(filtery)+1:end-length(filtery), :);
    end
    if(handles.spacing(3)>myInfo.Spacing(3))
        downfactor = handles.spacing(3)./myInfo.Spacing(3);
        sigma = downfactor*.4;
        fsz = round(sigma * 5);
        fsz = fsz + (1-mod(fsz,2));
        filterz = gaussian_kernel(fsz, sigma);
        filterz = filterz/sum(filterz);
        myData = padarray(myData, [0 0 length(filterz)], 'replicate');
        myData = conv3f(myData, single(permute(filterz, [3 2 1])));
        myData = myData(:,:,length(filterz)+1:end-length(filterz));
    end
    lastpt = orig + (handles.size-1).*handles.spacing./myInfo.Spacing;
    %         [X Y Z] = meshgrid(linspace(orig(2),lastpt(2),handles.size(2)),linspace(orig(1),lastpt(1),handles.size(1)),linspace(orig(3),lastpt(3),handles.size(3)));
    %         X = single(X);
    %         Y = single(Y);
    %         Z = single(Z);
    %         image = interp3(myData,X,Y,Z);
    image = resampler3(myData,linspace(orig(1),lastpt(1),handles.size(1)),linspace(orig(2),lastpt(2),handles.size(2)),linspace(orig(3),lastpt(3),handles.size(3)));
    image(isnan(image))=0;
    
    input_tags = cell(0);
    if(isfield(myInfo,'PatientName'))
        input_tags(size(input_tags,1)+1,:) = {'PatientName',myInfo.PatientName};
    end
    if(isfield(myInfo,'PatientID'))
        input_tags(size(input_tags,1)+1,:) = {'PatientID',myInfo.PatientID};
    end
    if(isfield(myInfo,'StudyInstanceUID'))
        input_tags(size(input_tags,1)+1,:) = {'StudyInstanceUID',myInfo.StudyInstanceUID};
    end
    info = Create_default_info('image',handles,[],input_tags,myInfo);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
else
    if(~handles.auto_mode)
        Choice = questdlg('This operation will set workspace properties', ...
            'Choose', ...
            'Continue','Cancel','Cancel');
        if(strcmp(Choice,'Cancel'))
            Image_load = 0;
        end
    end
    if(Image_load)
        image = myData;
        info = myInfo;
        disp('Setting spatial properties for this project !')
        handles.size(1) = size(image,1);
        handles.size(2) = size(image,2);
        handles.size(3) = size(image,3);
        handles.spacing = myInfo.Spacing;
        handles.origin = myInfo.ImagePositionPatient;
        handles.spatialpropsettled = 1;
    end
end
if(Image_load)
    image_dest = check_existing_names(image_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = image_dest;
    handles.images.data{length(handles.images.data)+1} = image;
    handles.images.info{length(handles.images.info)+1} = info;
    if(delete_after_transfer)
        handles = Remove_data(mydata_name,handles);
    end
end
