%% Import_binary_image
% Load from file an image at binary format. If a reference image is provided, the function will reformat the loaded image to match the dimensions of the reference image. Otherwise it will attempt to reshape it at the dimensions of the images in |handles.images|. The function will try to load the image at the 'single' and 'uint16' format.
% If the new image can be reformated at the same dimensions as the images in |handles.images|, it will be stored in |handles.images|. Otherwise, it will be stored in |handles.mydata|.
%
%% Syntax
% |handles = Import_binary_image(myImageDir,myImageFilename,endian)| Load the image and reshape it to the dimensions of the images in |handles.images|.
%
% |handles = Import_binary_image(myImageDir,myImageFilename,endian,myImageName,handles,myRefImageDir,myRefImageFilename,format)| Load the image and reshape it to the dimensions of the provided reference image.
%
%
%% Description
% |handles = Import_binary_image(myImageDir,myImageFilename,endian)| Load from file an image at binary format and format it at the dimensions of the images in |handles.images|
%
% |handles = Import_binary_image(myImageDir,myImageFilename,endian,myImageName,handles,myRefImageDir,myRefImageFilename,format)| Load from file an image at binary format and reformat it to match the dimensions of the reference image.
%
%
%% Input arguments
% |myImageDir| - _STRING_ - the directory on disk holding the binary image.
%
% |myImageFilename| - _STRING_ - File name of the image to be loaded
%
% |endian| - _STRING_ - Order for reading or writing bytes or bits in the file, specified as one of the following strings. See function |fopen| for more information. If empty, then use the default value for function |fopen|. 
%
% |myImageName| - _STRING_ - name of the imported data structure stored inside |handles.images| or |handles.mydata|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be processed.
%
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log 
% * |handles.spatialpropsettled| - _INTEGER_ - 1 = The dimensions for workspace are defined (e.g. image scale is defined). 0 otherwise
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.scale_prctile| - _SCALAR_ - Percentile at which the histogram is cut (0 <= prctile < 100). If prctile = 0, then the minimum and maximum intensity for the whole image list are returned
%
% |myRefImageDir| - _STRING_ - the directory on disk holding the reference image defining the new image size 
%
% |myRefImageFilename| - _STRING_ - File name of the reference image defining the new image size 
%
% |format| - _INTEGER_ - defines the type of import that will be perfomed for the reference image. See function |Import_image| for more information.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the loaded data (whre XXX is |images| or |mydata|):
%
% * |handles.XXX.name|
% * |handles.XXX.data|
% * |handles.XXX.info|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Import_binary_image(myImageDir,myImageFilename,endian,myImageName,handles,myRefImageDir,myRefImageFilename,format)
Image_load = 1;
Data_load = 0;
try
    if(not(isempty(endian)))
        fid=fopen(fullfile(myImageDir,myImageFilename),'r',endian);
    else
        fid=fopen(fullfile(myImageDir,myImageFilename),'r');
    end
catch ME
    reggui_logger.info(['Error : cannot open this file. ',ME.message],handles.log_filename);
    rethrow(ME);
end
% Import reference image
if(nargin>=8)
    try
        [myRefImage,myRefInfo] = load_Image(myRefImageDir,myRefImageFilename,format);
    catch ME
        reggui_logger.info(['This file is not a valid image. ',ME.message],handles.log_filename);
        fclose(fid);
        rethrow(ME);
    end
    % Setting or checking image properties
    if(~isfield(myRefInfo,'Spacing') || ~isfield(myRefInfo,'ImagePositionPatient') || ~isfield(myRefInfo,'PatientID') || ...
            ~isfield(myRefInfo,'FrameOfReferenceUID') || ~isfield(myRefInfo,'SOPInstanceUID') || ~isfield(myRefInfo,'SeriesInstanceUID') || ...
            ~isfield(myRefInfo,'SOPClassUID') || ~isfield(myRefInfo,'StudyInstanceUID') || ~isfield(myRefInfo,'PatientOrientation') || isempty(myRefImage) )        
        disp(myRefInfo)
        fclose(fid);
        error('Error : unable to import images because of empty data or unknown properties.')
    end
    if(~handles.spatialpropsettled)
        disp('Setting spatial properties for this project !')
        handles.size(1) = size(myRefImage,1);
        handles.size(2) = size(myRefImage,2);
        handles.size(3) = size(myRefImage,3);
        handles.spacing = myRefInfo.Spacing;
        handles.origin = myRefInfo.ImagePositionPatient;
        handles.spatialpropsettled = 1;
    else
        Not_in_workspace = sum(~(round(handles.origin*1e3) == round(myRefInfo.ImagePositionPatient*1e3))) || sum(~(round(handles.spacing*1e3) == round(myRefInfo.Spacing*1e3))) || ~(handles.size(1) == size(myRefImage,1) && handles.size(2) == size(myRefImage,2) && handles.size(3) == size(myRefImage,3));
        if(Not_in_workspace)
            Image_load = 0;
            disp('Warning : this image has not the same spatial properties (origin, size or spacing) as previous images !')
            Data_load = 1;
        end
    end
    if(Image_load)
        disp('Adding image to the list...')
        myImageName = check_existing_names(myImageName,handles.images.name);
        handles.images.name{length(handles.images.name)+1} = myImageName;
        handles.images.data{length(handles.images.data)+1} = single(myRefImage);
        handles.images.info{length(handles.images.info)+1} = myRefInfo;
        %[handles.minscale,handles.maxscale] = get_image_scale({myRefImage},handles.scale_prctile);
    elseif(Data_load)
        disp('Adding data to the list...')
        myImageName = check_existing_names(myImageName,handles.mydata.name);
        myImageName = check_existing_names(myImageName,handles.images.name);
        handles.mydata.name{length(handles.mydata.name)+1} = myImageName;
        handles.mydata.data{length(handles.mydata.data)+1} = single(myRefImage);
        handles.mydata.info{length(handles.mydata.info)+1} = myRefInfo;
    end
else
    handles = Empty_image(myImageName,handles);
end
% Try to reshape according to number of slices
try
    data=fread(fid,inf,'single');
    if(Data_load)
        data=single(reshape(data,256,256,size(handles.mydata.data{end},3)));
    else
        data=single(reshape(data,256,256,size(handles.images.data{end},3)));
    end
    disp('Loading image in single format')
catch
    try
        fclose(fid);
        if(not(isempty(endian)))
            fid=fopen(fullfile(myImageDir,myImageFilename),'r',endian);
        else
            fid=fopen(fullfile(myImageDir,myImageFilename),'r');
        end
        data=fread(fid,inf,'uint16');
        if(Data_load)
            data=single(reshape(data,256,256,size(handles.mydata.data{end},3)))-1024;
        else
            data=single(reshape(data,256,256,size(handles.images.data{end},3)))-1024;
        end
        disp('Loading image in uint16 format')
    catch ME
        reggui_logger.info(['Error : raw image size does not correspond to workspace. ',ME.message],handles.log_filename);
        fclose(fid);
        rethrow(ME);
    end
end
% Resample to reference image resolution
data=data(:,:,end:-1:1);
if(Data_load)
    imsize = size(handles.mydata.data{end});
    handles.mydata.data{end} = resampler3(data,linspace(2/3,256,imsize(1)),linspace(2/3,256,imsize(2)),1:imsize(3));
else
    imsize = size(handles.images.data{end});
    handles.images.data{end} = resampler3(data,linspace(2/3,256,imsize(1)),linspace(2/3,256,imsize(2)),1:imsize(3));
    %[handles.minscale,handles.maxscale] = get_image_scale(handles.images.data(end),handles.scale_prctile); 
end
fclose(fid);
