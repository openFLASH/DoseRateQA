%% Export_image
% Save to disk an image stored in |handles.mydata| or |handles.images|. If |name| and |outname| are cell vectors, several files will be created on disk, one for each specified image.
% The format of the file can be specified.
%
%% Syntax
% |handles = Export_image(name,outname,format,handles)|
%
% |handles = Export_image(name,outname,[],handles)|
%
% |handles = Export_image(name,outname,format,handles,dicom_tags)|
%
%
%% Description
% |handles = Export_image(name,outname,format,handles)|  Save the image on disk at the specified format
%
% |handles = Export_image(name,outname,[],handles)|  Save the image with additional DICOM tags on disk after manually selecting the format
%
% |handles = Export_image(name,outname,format,handles,dicom_tags)|  Save the image with additional DICOM tags on disk at the specified format
%
%
%% Input arguments
% |name| - _CELL VECTOR of STRING_ -  |name{i}| Name of the i-th image contained in |handles.mydata| or |handles.images| to be saved on disk
%
% |outname| - _CELL VECTOR of STRING_ - |outname{i}| Name of the file in which the i-th image should be saved
%
% |format| - _STRING or INTEGER_ -   Format to use to save the file. If empty, a dialog box is display to manually select the format. The options are:
%
% * 1 or 'dcm' : DICOM File
% * 2 or 'mat' : Matlab File
% * 3 or 'mhd' : META File
% * 4 or 'img' : Raw binary file (tomo format)
% * 5 or 'png' : PNG File (only 2D images)
% * 6 or 'txt' : TXT File
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "mydata" or "images"):
%
% * |handles.images.name{i}| - _STRING_ - Name of the ith field
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.auto_mode| - _INTEGER_ - 0 = auto mode is not active. 1 = auto mode is active
% * |handles.path| - _STRING_ - Define the path where to save the log file
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
%
% |dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the file
%
% * |dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |dicom_tags{i,2}| - _ANY_ Value of the tag
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure. Some information is updated
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Export_image(name,outname,format,handles,dicom_tags)

if(ischar(name))
    name = {name}; % convert input string in cell
end
if(ischar(outname))
    outname = {outname}; % convert output string in cell
end

% select format
if(isempty(format))
    choice_list = ['In which format do you want to export ?';...
        '  0 : Export to PACS                   ';...
        '  1 : DICOM File                       ';...
        '  2 : Matlab File                      ';...
        '  3 : META File                        ';...
        '  4 : Raw binary file (tomo format)    ';...
        '  5 : PNG File (only 2D images)        ';...
        '  6 : TXT File                         '];
    format = str2double(char(inputdlg(choice_list,'Select output type',1,{'1'})));
end
% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 0
            format = 'pacs';
        case 1
            format = 'dcm';
        case 2
            format = 'mat';
        case 3
            format = 'mhd';
        case 4
            format = 'img';
        case 5
            format = 'png';
        case 6
            format = 'txt';
        otherwise
            error('Invalid type number.')
    end
end

% check if 4D export is needed and possible
if(strcmp(format,'mhd') && length(name)>1 && length(outname)==1)
    disp('Exporting 4D image...')
    % export 4D image
    [outdata,info{1}] = Get_reggui_data(handles,name{1});
    for n=2:length(name)
        [outdata(:,:,:,n),info{n}] = Get_reggui_data(handles,name{n});
    end
    save_4D(outdata,info,outname{1},format);
else
    % export images
    for n=1:length(name)
        dataNumber = 0;
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},name{n}))
                outdata = handles.mydata.data{i};
                info = handles.mydata.info{i};
                dataNumber = i;
            end
        end
        imageNumber = 0;
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},name{n}))
                outdata = handles.images.data{i};
                info = handles.images.info{i};
                imageNumber = i;
            end
        end
        if(isempty(outdata))
            error(['Error : ''',name{n},''' not found in the list.'])
        end
        % replace patient-specific info by workspace info:
        if(imageNumber>0) % >0 if image is stored in workspace
            info.Spacing = handles.spacing;
            info.ImagePositionPatient = handles.origin;
        end
        % export image
        if(size(outdata,3)>1)
            disp('Exporting 3D image...')
        else
            disp('Exporting 2D image...')
        end

        try
            if(nargin>4)
                info = save_Image(outdata,info,outname{n},format,handles.auto_mode,dicom_tags);
            else
                info = save_Image(outdata,info,outname{n},format,handles.auto_mode);
            end
        catch ME
            cd(handles.path);
            reggui_logger.info(['Error : impossible to export image. ',ME.message],handles.log_filename);
            rethrow(ME);
        end
        % update image meta-info if needed
        if(nargout>0)
            if(imageNumber>0)
                handles.images.info{imageNumber} = info;
            elseif(dataNumber>0)
                handles.mydata.info{dataNumber} = info;
            end
        end
    end
end
