%% Export_plan
% Save to disk a treatment plan stored in |handles.plans|. If |name| and |outname| are cell vectors, several files will be created on disk, one for each specified image.
% The format of the file can be specified.
%
%% Syntax
% |Export_plan(name,outname,[],handles)|
%
% |Export_plan(name,outname,format,handles)|
%
% |Export_plan(name,outname,format,handles,dicom_tags)|
%
%
%% Description
% |Export_plan(name,outname,[],handles)| Save the treatmetn plan after displaying a dialog box to select the format
%
% |Export_plan(name,outname,format,handles)| Save the treatment plan at the specified format
%
% |Export_plan(name,outname,format,handles,dicom_tags)| Save the treatment plan with additional DICOM tags at the specified format

%
%
%% Input arguments
% |name| - _CELL VECTOR of STRING_ -  |name{i}| Name of the i-th plan contained in |handles.plans| to be saved on disk
%
% |outname| - _CELL VECTOR of STRING_ - |outname{i}| Name of the file in which the i-th plan should be saved
%
% |format| - _STRING or INTEGER_ -   Format to use to save the file. If empty, a dialog box is display to manually select the format. The options are:
%
% * 1 or 'json' : JSON  File
% * 2 or 'gate' : GATE  File
% * 3 or 'pld' : PLD   File
% * 4 or 'dcm' : DICOM File
% * 5 or 'dcm_record' : DICOM RT Record File
% * 6 or 'csv' : CSV File (list of spots)
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.plans.names{i}| - _CELL VECTOR of STRING_ - Name of the i-th treatment plan
% * |handles.plans.data{i}| - _STRUCTURE_ Structure describing the i-th treatment plan
% * |handles.plans.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.
%
% |dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the file
%
% * |dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |dicom_tags{i,2}| - _ANY_ Value of the tag
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Export_plan(name,outname,format,handles,dicom_tags)

if(ischar(name))
    name = {name}; % convert input string in cell
end
if(ischar(outname))
    outname = {outname}; % convert output string in cell
end

% export fields
for n=1:length(name)
    % find plan in the list
    for i=1:length(handles.plans.name)
        if(strcmp(handles.plans.name{i},name{n}))
            outdata = handles.plans.data{i};
            info = handles.plans.info{i};
        end
    end
    if(isempty(outdata))
        error(['Error : ''',name{n},''' not found in the list.'])
    end
    % select format
    if(isempty(format))
        choice_list = ['In which format do you want to export ?';...
            '  1 : JSON  File                       ';...
            '  2 : GATE  File                       ';...
            '  3 : PLD   File                       ';...
            '  4 : DICOM RT Plan File               ';...
            '  5 : DICOM RT Record File             ';...
            '  6 : CSV File                         '];
        format = str2double(char(inputdlg(choice_list,'Select output type',1,{'3'})));
    end
    % convert format in string
    if(isnumeric(format))
        switch format
            case 1
                format = 'json';
            case 2
                format = 'gate';
            case 3
                format = 'pld';
            case 5
                format = 'dcm_record';
            case 6
                format = 'csv';
            case 7
                format = 'pld_folders';
            case 8
                format = 'mcnpx';
            case 9
                format = 'pld_list';
            otherwise
                format = 'dcm';
        end
    end
    try
        if(nargin>4)
            save_Plan_PBS(outdata,outname{n},format,info,[],dicom_tags);
        else
            save_Plan_PBS(outdata,outname{n},format,info);
        end
    catch ME
        cd(handles.path);
        reggui_logger.info(['Error : impossible to export plan. ',ME.message],handles.log_filename);
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        rethrow(ME);
    end
end

