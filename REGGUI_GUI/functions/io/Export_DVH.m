%% Export_DVH
% Save the dose volume historgram (DVH) stored in |handles.dvhs| into a file at the specified format. See |save_DVH| for more information.
%
%% Syntax
% |Export_DVH(outname,handles)|
%
% |Export_DVH(outname,handles,format)|
%
%
%% Description
% |Export_DVH(outname,handles)| Display a dialog box to select the format and then save the file.
%
% |Export_DVH(outname,handles,format)| Save the DVH to file
%
%
%% Input arguments
% |outname| - _STRING_ - Name of the file in which the DVH should be saved 
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
%  |handles.dvhs| - _CELL VECTOR of STRUCTURE_ - Data strcture of the dose volume histogram. See |save_DVH| for more information.
%
% |format| - _INTEGER_ - [OPTIONAL] Format to use to save the file. The options are: 1 = Matlab '.mat' 2 = JSON. If absent or empty, displays a dialog box to select the format
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Export_DVH(outname,handles,format,sampling,max_dose)

if(nargin<3)
    format = [];
end
if(nargin<4)
    sampling = 0;
end
if(nargin<5)
    max_dose = [];
end

if(isempty(format))
    choice_list = ['In which format do you want to export ?';...
        '  1 : Matlab File                      ';...
        '  2 : Json File                        '];
    format = str2double(char(inputdlg(choice_list,'Select output type',1,{'1'})));
end

% convert numeric input format into string
if(isnumeric(format))
    switch format
        case 1
            format = 'mat';
        case 2
            format = 'json';
        otherwise
            error('Invalid type number.')
    end
end

% export dvh
save_DVH(handles.dvhs,outname,format,sampling,max_dose);
