%% Import_reg
% Load from file a registration data structure and store it in |handles.registrations|
%
%% Syntax
% |handles = Import_reg(myDataDir,myDataFilename,myDataName,handles)|
%
%
%% Description
% |handles = Import_reg(myDataDir,myDataFilename,myDataName,handles)| Load from file a registration data structure 
%
%
%% Input arguments
% |myDataDir| - _STRING_ - Name of the folder where the data is located
%
% |myDataFilename| - _STRING_ - File name of the data to be loaded
%
% |myDataName| - _STRING_ - Name of the data structure inside |handles|. 
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be processed.
%
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log  
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the loaded plan:
%
% * |handles.registrations.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th registration data structure
% * |handles.registrations.data{i}| - _STRUCTURE_ Structure describing the i-th registration data structure
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Import_reg(myDataDir,myDataFilename,myDataName,handles)
myData = [];
reg_load = 1;
try
    myData = load(fullfile(myDataDir,myDataFilename));
    firstdata = whos('-file',fullfile(myDataDir,myDataFilename));
    eval(['myData = myData.',firstdata.name,';']);
catch ME
    reggui_logger.info(['Error : not a valid registration file. ',ME.message],handles.log_filename);
    rethrow(ME);
end
if(reg_load)
    handles.registrations.name{length(handles.registrations.name)+1} = myDataName;
    handles.registrations.data{length(handles.registrations.data)+1} = myData;
end
