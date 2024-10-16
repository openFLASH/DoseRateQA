%% orthanc_import_from_disk
% Sent a file from the local disk to the PACS using the POST method. The function will use the default IP address (URL) of the PACS unless another address has been defined in reggui_pacs_config.txt in the folder /REGGUI_userdata. To interact with the PACS, the function appends the request string to the URL of the PACS (URL/request). For more information on the syntax of |request|, see https://openreggui.org/git/open/REGGUI/wikis/configure-PACS#interacting-with-the-pacs-from-the-scripts
%
%% Syntax
% |orthanc_import_from_disk(request,filenames)|
%
%% Description
% |orthanc_import_from_disk(request,filenames)| Sent a file from the local disk to the PACS
%
%% Input arguments
% |request| - _STRING_ - Text string defining the request to be sent to the PACS. The request is appended to the URL. If |request='instances'|, the function will send the file |dest_name| to be stored on the PACS as a new instance. The PACS will use the DICOM header of the file to determine where to store it.
%
% |dest_name| - _STRING_ - File name (including path) where the file to send to the PACS is stored.
%
%% Output arguments
%
% None
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function orthanc_import_from_disk(request,filenames)
URL = 'http://localhost:8042/'; % default value
[~,reggui_config_dir] = get_reggui_path;
if(exist(fullfile(reggui_config_dir,'reggui_pacs_config.txt'),'file'))
    fid = fopen(fullfile(reggui_config_dir,'reggui_pacs_config.txt'));
    URL = fgetl(fid);
    fclose(fid);
end
if(ischar(filenames))
    filenames = {filenames};
end

% create list of files to be imported
files = {};
for i=1:length(filenames)
    if(exist(filenames{i},'dir')==7)
        d = dir_without_hidden(filenames{i});
        for j=1:length(d)
            files{end+1} = fullfile(filenames{i},d(j).name);
        end
    elseif(exist(filenames{i},'file')==2)
        files{end+1} = filenames{i};
    else
        continue
    end
end

for i=1:length(files)
    % load binary
    fid = fopen(files{i}, 'r');
    body = fread(fid,'*uchar');
    fclose(fid);
    % import into orthanc
    disp(['Importing ',files{i},' (',num2str(numel(body)*2/1e6),' MB) into Orthanc...'])
    header = struct;
    header.name='Content-Type';
    header.value='application/dicom';
    urlread2([URL,request],'POST',body,header);
end

