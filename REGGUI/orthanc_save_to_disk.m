%% orthanc_save_to_disk
% Transfer a file from the PACS to the local disk. The function will use the default IP address (URL) of the PACS unless another address has been defined in reggui_pacs_config.txt in the folder /REGGUI_userdata. To interact with the PACS, the function appends the request string to the URL of the PACS (URL/request). For more information on the syntax of |request|, see https://openreggui.org/git/open/REGGUI/wikis/configure-PACS#interacting-with-the-pacs-from-the-scripts
%
%% Syntax
% |orthanc_save_to_disk(request,dest_name)|
%
%% Description
% |orthanc_save_to_disk(request,dest_name)| Transfer a file from the PACS to the local disk
%
%% Input arguments
% |request| - _STRING_ - Text string deifning the request to be sent to the PACS. The request is appended to the URL.
%
% |dest_name| - _STRING_ - File name (including path) where the PACS data will be stored
%
%% Output arguments
%
% None
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function orthanc_save_to_disk(request,dest_name)
URL = 'http://localhost:8042/'; % default value
[~,reggui_config_dir] = get_reggui_path;
if(exist(fullfile(reggui_config_dir,'reggui_pacs_config.txt'),'file'))
    fid = fopen(fullfile(reggui_config_dir,'reggui_pacs_config.txt'));
    URL = fgetl(fid);
    fclose(fid);
end
% disp([URL,request])
urlwrite([URL,request],dest_name,'Timeout',60);
