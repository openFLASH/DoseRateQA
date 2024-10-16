%% Export_field
% Save to disk a deformation field stored in |handles.mydata| or |handles.fields|. An additional rigid transformation |rigidPreDef5x3| can be applied after the deformation field. It will be stored as a "FrameOfReferenceTransformationMatrix". If |name| and |outname| are cell vector, several files will be created on disk, one for each specified field.
% The format of the file can be specified.
%
%% Syntax
% |handles = Export_field(name,outname,format,handles)|
%
% |handles = Export_field(name,outname,format,handles,dicom_tags)|
%
% |handles = Export_field(name,outname,format,handles,dicom_tags,rigidPreDef_name)|
%
%
%% Description
% |handles = Export_field(name,outname,format,handles)| Save the deformation field on disk at the specified format.
%
% |handles = Export_field(name,outname,format,handles,dicom_tags)| Save the deformation field with additional DICOM tags on disk at the specified format.
%
% |handles = Export_field(name,outname,format,handles,dicom_tags,rigidPreDef_name)| Save the deformation field with additional DICOM tags on disk at the specified format and save the 4x4 matrix descrbing a post-rigid transform.
%
%
%% Input arguments
% |name| - _CELL VECTOR of STRING_ -  |name{i}| Name of the i-th deformation field contained in |handles.mydata| or |handles.fields| to be saved on disk
%
% |outname| - _CELL VECTOR of STRING_ - |outname{i}| Name of the file in which the i-th field should be saved
%
% |format| - _STRING or INTEGER_ -   Format to use to save the file. The options are: 
%
% * 1 or 'dcm' : DICOM file
% * 2 or  'mat' : Matlab binary file
% * 3 or 'mhd' : ITK text format [https://itk.org/Wiki/ITK/File_Formats]
% * 4 or 'txt': text file
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "mydata" or "fields"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith field
% * |handles.XXX.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI
% * |handles.path| - _STRING_ - Define the path where to save the log file
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
%
% |dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the file 
%
% * |dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |dicom_tags{i,2}| - _ANY_ Value of the tag 
%
% |rigidPreDef_name| - _STRING_ - [OPTIONAL] Name of the additional rigid translation / rotation stored in |handles.fields| that will be stored as a 4x4 matrix in the file.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure. No change to the input.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Export_field(name,outname,format,handles,dicom_tags,rigidPreDef_name)

if(ischar(name))
    name = {name}; % convert input string in cell
end
if(ischar(outname))
    outname = {outname}; % convert output string in cell
end

% export fields
for n=1:length(name)
    dataNumber = 0;
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},name{n}))
            outdata = handles.mydata.data{i};
            info = handles.mydata.info{i};
            dataNumber = i;
        end
    end
    fieldNumber = 0;
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},name{n}))
            outdata = handles.fields.data{i};
            info = handles.fields.info{i};
            fieldNumber = i;
        end
    end
    if(isempty(outdata))
        error(['Error : ''',name{n},''' not found in the list.'])
    end
    rigidPreDef5x3 = [];
    if(nargin>5)
        for i=1:length(handles.fields.name)
            if(strcmp(handles.fields.name{i},rigidPreDef_name) && strcmp(handles.fields.info{i}.Type,'rigid_transform'))
                rigidPreDef5x3 = handles.fields.data{i};
            end
        end
    end
    % Replace patient-specific info by workspace info:
    if(fieldNumber>0)
        info.Spacing = handles.spacing;
        info.ImagePositionPatient = handles.origin;
    end
    if(strcmp(info.Type,'deformation_field'))
        try
            if(not(isempty(format)))
                % convert numeric input format into string
                if(isnumeric(format))
                    switch format
                        case 1
                            format = 'dcm';
                        case 2
                            format = 'mat';
                        case 3
                            format = 'mhd';
                        case 4
                            format = 'txt';
                        otherwise
                            error('Invalid type number.')
                    end
                end
                % export field
                try
                    if(nargin>5)
                        info = save_Field(outdata,info,outname{n},format,rigidPreDef5x3,dicom_tags);
                    elseif(nargin>4)
                        info = save_Field(outdata,info,outname{n},format,'',dicom_tags);
                    else
                        info = save_Field(outdata,info,outname{n},format);
                    end
                catch ME
                    cd(handles.path);
                    reggui_logger.info(['Error : impossible to export field. ',ME.message],handles.log_filename);
                    rethrow(ME);
                end
            else
                choice_list = ['In which format do you want to export this field ?';...
                    '  1 : Dicom File                                  ';...
                    '  2 : Matlab File                                 ';...
                    '  3 : META File                                   ';...
                    '  4 : Text File                                   '];
                format = str2double(char(inputdlg(choice_list)));
                % convert numeric input format into string
                if(isnumeric(format))
                    switch format
                        case 1
                            format = 'dcm';
                        case 2
                            format = 'mat';
                        case 3
                            format = 'mhd';
                        case 4
                            format = 'txt';
                        otherwise
                            error('Invalid type number.')
                    end
                end
                % export field
                try
                    if(nargin>4)
                        info = save_Field(outdata,info,outname{n},format,'',dicom_tags);
                    else
                        info = save_Field(outdata,info,outname{n},format);
                    end
                catch ME
                    cd(handles.path);
                    reggui_logger.info(['Error : impossible to export field. ',ME.message],handles.log_filename);
                    rethrow(ME);
                end
            end
        catch ME
            cd(handles.path);
            reggui_logger.info(['Error : impossible to export field. ',ME.message],handles.log_filename);
            rethrow(ME);
        end
    else
        if(isempty(format))
            choice_list = [ 'In which format do you want to export this transform ?';...
                '  1 : Dicom File                                      ';...
                '  2 : Matlab File                                     ';...
                '  3 : Text File                                       '];
            format = str2double(char(inputdlg(choice_list)));
        end
        % convert numeric input format into string
        if(isnumeric(format))
            switch format
                case 1
                    format = 'dcm';
                case 2
                    format = 'mat';
                case 3
                    format = 'txt';
                otherwise
                    error('Invalid type number.')
            end
        end
        % export transform
        try
            info = save_Transform(outdata,info,outname{n},format);
        catch ME
            cd(handles.path);
            reggui_logger.info(['Error : impossible to export transform. ',ME.message],handles.log_filename);
            rethrow(ME);
        end
    end
    % update field meta-info if needed
    if(nargout>0)
        if(fieldNumber>0)
            handles.fields.info{fieldNumber} = info;
        elseif(dataNumber>0)
            handles.mydata.info{dataNumber} = info;
        end
    end
end
