%% Generate_import_reg
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load a registration data structure.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the registration data structure is loaded from file (using function |Import_reg|).
% The file name and folder containing the data is either defined in the field |which_reg| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_reg(''Select registration'',...)|
% will (a) display a dialog box with the message 'Select registration' to allow the selection of the registration data structure and (b) then return the following string:
% |instructions = 'handles = Import_reg(...)'|
%
% When executing the string as an instruction, it will load the registration data structure in the relevant |handles.registrations| data structure (see function |Import_reg|) with the |myRegName|.
%
%% Syntax
% |instruction = Generate_import_reg(which_reg = FIELD NAME,myRegName,handles)|
%
% |instruction = Generate_import_reg(which_reg=STRING,myRegName,handles)|
%
%
%% Description
% |instruction = Generate_import_reg(which_reg = FIELD NAME,myRegName,handles)| Generate the instruction string to load the registration data structure with file name and folder defined in the field |which_reg| of |handles|
%
% |instruction = Generate_import_reg(which_reg=STRING,myRegName,handles)| Display a dialog box to select the file to load. Then generate a string with the instruction to load the file. 
%
%
%% Input arguments
% |which_reg| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_reg| is the name of a field of |handles|, then [|handles.| _which_reg_] is the file name and directory containing the files to load. 
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_reg| represents the text which is displayed in this dialog box. 
%
% |myRegName| - _STRING_ - Name of the data structure inside |handles|. 
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
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function instruction = Generate_import_reg(which_reg,myRegName,handles)

% Authors : G.Janssens

if(isfield(handles,'patientDir') && isfield(handles,myRegName))
    eval(['[path, regFile] = fileparts(handles.',myRegName,');']);
else
    try
        [regFile,path] = uigetfile('*.mat', ...
            which_reg, [handles.dataPath '/Untitled']);
    catch
        disp('Error : not a valid file !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        return
    end
end

instruction = ['handles = Import_reg(''',path,''',''',regFile,''',''',myRegName,''',handles);'];
