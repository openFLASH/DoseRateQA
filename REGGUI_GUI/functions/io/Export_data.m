%% Export_data
% Save to disk the the specified data structure in |handles.mydata| into binary file at the Matlab '.mat' format. The data is saved in the '.mat file' as |outStruct.data| and |outStruct.info|.
%
%% Syntax
% |Export_data(name,outname,handles)|
%
%
%% Description
% |Export_data(name,outname,handles)| Save to disk the the specified data structure 
%
%
%% Input arguments
% |name| - _CELL VECTOR of STRING_ -  |name{i}| Name of the i-th image contained in |handles.mydata| to be saved on disk
%
% |outname| - _CELL VECTOR of STRING_ - |outname{i}| Name of the file in which the i-th image should be saved 
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info|
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Export_data(name,outname,handles)

if(ischar(name))
    name = {name}; % convert input string in cell
end
if(ischar(outname))
    outname = {outname}; % convert output string in cell
end

% export data
for n=1:length(name)
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},name{n}))
            outdata = handles.mydata.data{i};
            info = handles.mydata.info{i};
        end
    end
    try
        outStruct = struct;
        outStruct.data = outdata;
        outStruct.info = info;
        save(outname{n},'outStruct');
    catch ME
        reggui_logger.info(['Error : impossible to export data. ',ME.message],handles.log_filename);
        rethrow(ME);
    end
end

