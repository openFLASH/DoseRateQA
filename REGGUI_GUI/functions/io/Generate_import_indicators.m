%% Generate_import_indicators
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load a treatment indicators.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the treatment indicators is loaded from file (using function |Import_indicators|).
% The file name and folder containing the data is either defined in the field |which_indicators| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_indicators(''Select indicators'',...)|
% will (a) display a dialog box with the message 'Select indicators' to allow the selection of the indicators and (b) then return the following string:
% |instructions = 'handles = Import_indicators(...)'|
%
% When executing the string as an instruction, it will load the indicators in the relevant |handles.indicators| data structure (see function |Import_indicators|) with the |name|.
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_indicators| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instruction,myIndicFilename,myIndicDir] = Generate_import_indicators(which_indicators = FIELD NAME,myIndicName,handles)|
%
% |[instruction,myIndicFilename,myIndicDir] = Generate_import_indicators(which_indicators=STRING,myIndicName,handles)|
%
%
%% Description
% |[instruction,myIndicFilename,myIndicDir] = Generate_import_indicators(which_indicators = FIELD NAME,myIndicName,handles)| Generate the instruction string to load the indicators with file name and folder defined in the field |which_indicators| of |handles|
%
% |[instruction,myIndicFilename,myIndicDir] = Generate_import_indicators(which_indicators=STRING,myIndicName,handles)| Display a dialog box to select the file to load. Then generate a string with the instruction to load the file. 
%
%
%% Input arguments
% |which_indicators| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_indicators| is the name of a field of |handles|, then [|handles.| _which_indicators_] is the file name and directory containing the files to load. 
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_indicators| represents the text which is displayed in this dialog box. 
%
% |myIndicName| - _STRING_ - Name of the data structure inside |handles|. 
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
% |myIndicFilename| - _STRING_ - File name of the data to be loaded
%
% |myIndicDir| - _STRING_ - Name of the folder where the data is located
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instruction,myIndicFilename,myIndicDir] = Generate_import_indicators(which_indicators,myIndicName,handles)


get_user_input = 1;
if(isfield(handles,strrep(which_indicators,' ','_')))
    filename = handles.(strrep(which_indicators,' ','_'));
    if(exist(filename,'dir')||exist(filename,'file'))
        [myIndicDir, myIndicFilename, ext] = fileparts(filename);
        myIndicFilename = [myIndicFilename,ext];
        get_user_input = 0;
    end
end

if(get_user_input)
    try
        [myIndicFilename,myIndicDir] = uigetfile('*.json', ...
            which_indicators, [handles.dataPath '/Untitled']);
    catch
        disp('Error : not a valid file !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        return
    end
end

instruction = ['handles = Import_indicators(''',myIndicDir,''',''',myIndicFilename,''',1,''',myIndicName,''',handles);'];

