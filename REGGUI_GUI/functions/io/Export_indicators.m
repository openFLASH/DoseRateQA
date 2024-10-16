%% Export_indicators
% Save to disk a treatment indicators stored in |handles.indicators|. If |name| and |outname| are cell vectors, several files will be created on disk, one for each specified image.
% The format of the file can be specified.
%
%% Syntax
% |Export_indicators(name,outname,[],handles)|
%
% |Export_indicators(name,outname,format,handles)|
%
%% Description
% |Export_indicators(name,outname,[],handles)| Save the treatmetn indicators after displaying a dialog box to select the format
%
% |Export_indicators(name,outname,format,handles)| Save the treatment indicators at the specified format
%
%
%% Input arguments
% |name| - _CELL VECTOR of STRING_ -  |name{i}| Name of the i-th indicators contained in |handles.indicators| to be saved on disk
%
% |outname| - _CELL VECTOR of STRING_ - |outname{i}| Name of the file in which the i-th indicators should be saved
%
% |format| - _STRING or INTEGER_ -   Format to use to save the file. If empty, a dialog box is display to manually select the format. The options are:
%
% * 1 or 'json' : JSON  File
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.indicators.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th treatment indicators
% * |handles.indicators.data{i}| - _STRUCTURE_ Structure describing the i-th treatment indicators
% * |handles.indicators.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Export_indicators(name,outname,format,handles)

if(ischar(name))
    name = {name}; % convert input string in cell
end
if(ischar(outname))
    outname = {outname}; % convert output string in cell
end

% export fields
for n=1:length(name)
    % find indicators in the list
    for i=1:length(handles.indicators.name)
        if(strcmp(handles.indicators.name{i},name{n}))
            outdata = handles.indicators.data{i};
            info = handles.indicators.info{i};
        end
    end
    if(isempty(outdata))
        error(['Error : ''',name{n},''' not found in the list.'])
    end
    % select format
    if(isempty(format))
        choice_list = ['In which format do you want to export ?';...
            '  1 : JSON  File                       '];
        format = str2double(char(inputdlg(choice_list,'Select output type',1,{'1'})));
    end
    % convert format in string
    if(isnumeric(format))
        switch format
            case 1
                format = 'json';
            otherwise
                format = '';
        end
    end
    try
        save_Indicators(outdata,outname{n},format);
    catch ME
        cd(handles.path);
        reggui_logger.info(['Error : impossible to export indicators. ',ME.message],handles.log_filename);
        rethrow(ME);
    end
end

