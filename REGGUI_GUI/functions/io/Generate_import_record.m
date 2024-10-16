%% Generate_import_record
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load a treatment record.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the treatment record is loaded from file (using function |Import_plan|).
% The file name and folder containing the data is either defined in the field |which_record| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_record(''Select record'',...)|
% will (a) display a dialog box with the message 'Select record' to allow the selection of the record and (b) then return the following string:
% |instructions = 'handles = Import_plan(...)'|
%
% When executing the string as an instruction, it will load the record in the relevant |handles.plans| data structure (see function |Import_plan|) with the |name|.
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_record| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instruction,myRecordFilenames,myRecordDir] = Generate_import_record(which_record = FIELD NAME,myRecordName,handles)|
%
% |[instruction,myRecordFilenames,myRecordDir] = Generate_import_record(which_record=STRING,myRecordName,handles)|
%
%
%% Description
% |[instruction,myRecordFilenames,myRecordDir] = Generate_import_record(which_record = FIELD NAME,myRecordName,handles)| Generate the instruction string to load the record with file name and folder defined in the field |which_record| of |handles|
%
% |[instruction,myRecordFilenames,myRecordDir] = Generate_import_record(which_record=STRING,myRecordName,handles)| Display a dialog box to select the file to load. Then generate a string with the instruction to load the file.
%
%
%% Input arguments
% |which_record| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_record| is the name of a field of |handles|, then [|handles.| _which_plan_] is the file name and directory containing the files to load.
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_record| represents the text which is displayed in this dialog box.
%
% |myRecordName| - _STRING_ - Name of the data structure inside |handles|.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure
%
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data
%
%
%% Output arguments
%
% |instruction| - _STRING_ - String representing the REGGUI/Matlab instruction to execute to import the data
%
% |myRecordFilenames| - _STRING_ - File name of the data to be loaded
%
% |myRecordDir| - _STRING_ - Name of the folder where the data is located
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instruction,myRecordFilenames,myRecordDir] = Generate_import_record(which_record,myRecordName,handles,RefName,format)

if(nargin < 4)
    RefName = '';
end
if(nargin < 5)
    format = 'dcm';
end

get_user_input = 1;
if(isfield(handles,strrep(which_record,' ','_')))
    filename = handles.(strrep(which_record,' ','_'));
    if(exist(filename,'dir')||exist(filename,'file'))
        [myRecordDir, myRecordFilenames, ext] = fileparts(filename);
        myRecordFilenames = [myRecordFilenames,ext];
        get_user_input = 0;
    else
        format = 'pacs';
        myRecordDir = 'temp_plan';
        myRecordFilenames = filename;
        get_user_input = 0;
    end
end

if(get_user_input)
    try
        [myRecordFilenames,myRecordDir] = uigetfile( ...
            {'*.dcm;*.DCM','DICOM RT record'; ...
            '*.zip','IBA log file(s)'; ...
            '*.txt','IBA scanalgo config'; ...
            '*.*',  'All Files (*.*)'}, ...
            'MultiSelect', 'on', ...
            [handles.dataPath '/Untitled']);
        if(not(iscell(myRecordFilenames)))
            myRecordFilenames = {myRecordFilenames};
        end
        
    catch
        disp('Error : not a valid file !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        return
    end
end

if(not(isempty(RefName)))
    instruction = ['handles = Import_tx_record(''',myRecordDir,''',',cell2str(myRecordFilenames),',''',format,''',''',myRecordName,''',handles,''',RefName,''');'];
else
    instruction = ['handles = Import_tx_record(''',myRecordDir,''',',cell2str(myRecordFilenames),',''',format,''',''',myRecordName,''',handles);'];
end

