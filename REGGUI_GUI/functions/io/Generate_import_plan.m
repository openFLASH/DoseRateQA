%% Generate_import_plan
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load a treatment plan.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the treatment plan is loaded from file (using function |Import_plan|).
% The file name and folder containing the data is either defined in the field |which_plan| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_plan(''Select plan'',...)|
% will (a) display a dialog box with the message 'Select plan' to allow the selection of the plan and (b) then return the following string:
% |instructions = 'handles = Import_plan(...)'|
%
% When executing the string as an instruction, it will load the plan in the relevant |handles.plans| data structure (see function |Import_plan|) with the |name|.
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_plan| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instruction,myPlanFilename,myPlanDir] = Generate_import_plan(which_plan = FIELD NAME,myPlanName,handles)|
%
% |[instruction,myPlanFilename,myPlanDir] = Generate_import_plan(which_plan=STRING,myPlanName,handles)|
%
%
%% Description
% |[instruction,myPlanFilename,myPlanDir] = Generate_import_plan(which_plan = FIELD NAME,myPlanName,handles)| Generate the instruction string to load the plan with file name and folder defined in the field |which_plan| of |handles|
%
% |[instruction,myPlanFilename,myPlanDir] = Generate_import_plan(which_plan=STRING,myPlanName,handles)| Display a dialog box to select the file to load. Then generate a string with the instruction to load the file. 
%
%
%% Input arguments
% |which_plan| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_plan| is the name of a field of |handles|, then [|handles.| _which_plan_] is the file name and directory containing the files to load. 
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_plan| represents the text which is displayed in this dialog box. 
%
% |myPlanName| - _STRING_ - Name of the data structure inside |handles|. 
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
% |myPlanFilename| - _STRING_ - File name of the data to be loaded
%
% |myPlanDir| - _STRING_ - Name of the folder where the data is located
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instruction,myPlanFilename,myPlanDir] = Generate_import_plan(which_plan,myPlanName,handles,format)

if(nargin < 4)
	format = 'dcm';
end	


get_user_input = 1;
if(isfield(handles,strrep(which_plan,' ','_')))
    filename = handles.(strrep(which_plan,' ','_'));
    if(exist(filename,'dir')||exist(filename,'file'))
        [myPlanDir, myPlanFilename, ext] = fileparts(filename);
        myPlanFilename = [myPlanFilename,ext];
        get_user_input = 0;
    else
        format = 'pacs';
        myPlanDir = 'temp_plan';
        myPlanFilename = filename;
        get_user_input = 0;
    end
end

if(get_user_input)
    try
        [myPlanFilename,myPlanDir] = uigetfile('*.dcm', ...
            which_plan, [handles.dataPath '/Untitled']);
    catch
        disp('Error : not a valid file !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        return
    end
end

instruction = ['handles = Import_plan(''',myPlanDir,''',''',myPlanFilename,''',''',format,''',''',myPlanName,''',handles);'];

