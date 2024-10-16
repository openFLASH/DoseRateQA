%% Import_tomo_matrix
% Load from one or several files images at binary format. Each file contains a stack of 2D images. The function will reformat the loaded images to match the (x,y) dimensions of the images in |handles.size| by adapting the number of slices in the stack. The function will try to load the image at the 'single' and 'uint16' format.
%
%% Syntax
% |res = Import_tomo_matrix(imagename,handles)|
%
% |res = Import_tomo_matrix(imagename,handles,filename)|
%
%
%% Description
% |res = Import_tomo_matrix(imagename,handles)| display a dialog box to select the files to load. then load the images in |handles.images|
%
% |res = Import_tomo_matrix(imagename,handles,filename)| Load the specified images in |handles.images|
%
%
%% Input arguments
% |imagename| - _CELL VECTOR of STRING_ -  |name{i}| Name of the i-th new image in |handles.images| where to load the data
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be processed.
%
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
% * |handles.path| - _STRING_ - Define the path where to save the log file
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data
% * |handles.auto_mode| - _INTEGER_ - 0 = auto mode is not active. 1 = auto mode is active
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI
%
% |filename| - _CELL VECTOR of STRING_ - [OPTIONAL] |name{i}| Name of the i-th file to load. Must be same length as |imagename|. If not provided, a dialog box is displayed to select the file names.
%
%
%% Output arguments
%
% |res=handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Import_tomo_matrix(imagename,handles,filename)

res = handles;

if(iscell(imagename))
    imagenames = imagename;
    if(nargin>2)
        if(not(iscell(filename)&&length(filename)==length(imagenames)))
            error('Error: number of input files different from number of output images.')
        end
    end
else
    imagenames = {imagename};
end

for m=1:length(imagenames)
    
    imagename = imagenames{m};
    
    
    
    if(nargin<3)
        if(handles.auto_mode)
            error('No input filename provided. Please try in non-automatic mode.')
        else
            try
                if(m==1)
                    [input_filename, input_pathname] = uigetfile({'*.img';'*.*'},['Select tomo matrix file (',num2str(m),')'], [handles.dataPath '/Untitled']);
                else
                    [input_filename, input_pathname] = uigetfile({'*.img';'*.*'},['Select tomo matrix file (',num2str(m),')'], fullfile(input_pathname,strrep(input_filename,num2str(m-1),num2str(m))));
                end
                filename = fullfile(input_pathname,input_filename);
            catch ME
                reggui_logger.info(['Error while selecting file. Abort. ',ME.message],handles.log_filename);
                cd(handles.path)
                rethrow(ME);
            end
        end
    end
    
    % fill data with values from binary file
    fid=fopen(filename,'rb','b');
    data=fread(fid,inf,'single');
    try
        data=single(reshape(data,handles.size(1),handles.size(2),[]));
    catch
        try
            fclose(fid);
            fid=fopen(filename,'rb','b');
            data=fread(fid,inf,'uint16');
            data=single(reshape(data,handles.size(1),handles.size(2),[]));
        catch ME
            reggui_logger.info(['Error: Matrix size does not correspond to workspace. ',ME.message],handles.log_filename);
            cd(handles.path)
            rethrow(ME);
        end
    end
    data = data(:,:,end:-1:1);
    fclose(fid);
    
    imagename = check_existing_names(imagename,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = imagename;
    handles.images.data{length(handles.images.data)+1} = data;
    handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles);
    
end

res = handles;
