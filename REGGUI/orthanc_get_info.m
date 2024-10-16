%% orthanc_get_info
% Send a query to the PACS and return the list of DICOM objects matching the query. The function will use the default IP address (URL) of the PACS unless another address has been defined in reggui_pacs_config.txt in the folder /REGGUI_userdata.
%
% To query the PACS, the function appends the request string to the URL of the PACS (URL/request). The PACS replies by sending a JSON file containing the requested information. The function then processes the returned JSON file in order to package the information in a Matlab cell vector of structure or strings.
%
%% Syntax
% |res = orthanc_get_info(request)|
%
%% Description
% |res = orthanc_get_info(request)| Load a treatment indicators from file
%
%% Input arguments
% |request| - _STRING_ - Text string defining the request to be sent to the PACS. The request is appended to the URL. For more information on the syntax of |request|, see https://openreggui.org/git/open/REGGUI/wikis/configure-PACS#interacting-with-the-pacs-from-the-scripts
%
%% Output arguments
%
% |res| - _CELL VECTOR of STRUCTURE_ or _CELL VECTOR of STRING_ - Depending on the request, the result can be either a cell vector of string |res{i}| or a cell vector of structures |res{i}.MainDicomTags| with the DICOM tags of the i-th object found in the request.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = orthanc_get_info(request)
URL = 'http://localhost:8042/'; % default value
[~,reggui_config_dir] = get_reggui_path;
if(exist(fullfile(reggui_config_dir,'reggui_pacs_config.txt'),'file'))
    fid = fopen(fullfile(reggui_config_dir,'reggui_pacs_config.txt'));
    URL = fgetl(fid);
    fclose(fid);
end
% disp([URL,request])
res = loadjson(urlread([URL request],'Timeout',60));
