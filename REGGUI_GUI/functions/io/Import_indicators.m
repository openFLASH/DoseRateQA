%% Import_indicators
% Load a treatment indicators from disk and store it in |handles.indicators|
%
%% Syntax
% |handles = Import_indicators(myIndicDir, myIndicFilename, format, myIndicName, handles)|
%
%
%% Description
% |handles = Import_indicators(myIndicDir, myIndicFilename, format, myIndicName, handles)| Load a treatment indicators from disk
%
%
%% Input arguments
% |myIndicDir| - _STRING_ - Name of the folder where the data is located
%
% |myIndicFilename| - _STRING_ - File name of the data to be loaded
%
% |format| - _STRING or INTEGER_ -   Format of the file. The options are: 
%
% * 1 or 'json' : JSON File 
%
% |myIndicName| - _STRING_ - Name of the data structure inside |handles|. 
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be processed.
%
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log 
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the loaded indicators:
%
% * |handles.indicators.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th treatment indicators
% * |handles.indicators.data{i}| - _STRUCTURE_ Structure describing the i-th treatment indicators 
% * |handles.indicators.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Import_indicators(myIndicDir, myIndicFilename, format, myIndicName, handles)
% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 1
            format = 'json';
        otherwise
            error('Invalid type number.')
    end
end
% import indicators
Indic_load = 1;
try
    [myIndic,myInfo] = load_Indicators(fullfile(myIndicDir,myIndicFilename),format);
catch ME
    reggui_logger.info(['This file is not a valid indicators file. ',ME.message],handles.log_filename);
    rethrow(ME);
end
if(Indic_load)
    disp('Adding indicators to the list...')
    myIndicName = check_existing_names(myIndicName,handles.indicators.name);
    handles.indicators.name{length(handles.indicators.name)+1} = myIndicName;
    handles.indicators.data{length(handles.indicators.data)+1} = myIndic;
    handles.indicators.info{length(handles.indicators.info)+1} = myInfo;
end
