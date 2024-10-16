%% Export_reg
% Save to disk a registration sturcture stored in |handles.registrations|. If |name| and |outname| are cell vectors, several files will be created on disk, one for each specified image. The file is at the binary Matlab format.
%
%% Syntax
% |Export_reg(name,outname,handles)|
%
%
%% Description
% |Export_reg(name,outname,handles)| Save the registration structure in file
%
%
%% Input arguments
% |name| - _CELL VECTOR of STRING_ -  |name{i}| Name of the i-th registration structure contained in |handles.registrations| to be saved on disk
%
% |outname| - _CELL VECTOR of STRING_ - |outname{i}| Name of the file in which the i-th registration structure should be saved
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.registrations.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th registration structure
% * |handles.registrations.data{i}| - _STRUCTURE_ Structure describing the i-th registration structure
% * |handles.path| - _STRING_ - Define the path where to save the log file
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Export_reg(name,outname,handles)

if(ischar(name))
    name = {name}; % convert input string in cell
end
if(ischar(outname))
    outname = {outname}; % convert output string in cell
end

% export images
for n=1:length(name)
    for i=1:length(handles.registrations.name)
        if(strcmp(handles.registrations.name{i},name{n}))
            outdata = handles.registrations.data{i};
        end
    end
    if(isempty(outdata))
        error(['Error : ''',name{n},''' not found in the list.'])
    end
    try
        save(outname{n},'outdata');
    catch ME
        cd(handles.path);
        reggui_logger.info(['Error : impossible to export registration. ',ME.message],handles.log_filename);
        rethrow(ME);
    end
end
