%% Generate_import_field
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load deformation field.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the image is loaded from file (using function |Import_field|).
% The file name and folder containing the data is either defined in the field |which_field| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_field(''Select filed'',...)|
% will (a) display a dialog box with the message 'Select image' to allow the selection of the deformation file and (b) then return the following string:
% |instructions = 'handles = Import_field(...)'|
%
% When executing the string as an instruction, it will load the field in the relevant |handle.fields| or |handle.mydata| data structure (see function |Import_field|) with the |name|. The type of data will be determined from the file extension.
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_field| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instruction,myFieldFilename] = Generate_import_field(which_field = FIELD NAME,name,handles)|
%
% |[instruction,myFieldFilename] = Generate_import_field(which_field=STRING,name,handles)|
%
% |[instruction,myFieldFilename] = Generate_import_field(which_field,name,handles,input_index)|
%
%
%% Description
% |[instruction,myFieldFilename] = Generate_import_field(which_field = FIELD NAME,name,handles)|  Generate the instruction string to load the deformation field with file name and folder defined in the field |which_field| of |handles|.
%
% |[instruction,myFieldFilename] = Generate_import_field(which_field=STRING,name,handles)| Display a dialog box to select the deformation field file to load. Then generate a string with the instruction to load the file. 
%
% |[instruction,myFieldFilename] = Generate_import_field(which_field,name,handles,input_index)| In the dialog box to select the files, only allow the selection of file with the specified extension types.
%
%
%% Input arguments
% |which_field| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_field| is the name of a field of |handles|, then [|handles.| _which_field_] is the file name and directory containing the files to load. 
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_field| represents the text which is displayed in this dialog box. 
%
% |name|- _STRING_ - Name of the data structure inside |handles|. 
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure 
%
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data
%
% |input_index| - _INTEGER VECTOR_ - [OPTIONAL] Specify the types of file extension that can be selected in the dialog box. If the vector has more than one element, then several extension types are allowed. If not specified, then all extensions will be allowed. The following file extensions are possible:
%
% * |input_index = 1| : '*.dcm;*.DCM'  : DICOM Serie
% * |input_index = 2| : '*.mat'        : MATLAB Files
% * |input_index = 3| : '*.mha;*.mhd'  : Meta Image Files
% * |input_index = 4| : '*.txt'        : TEXT Files
%
%
%% Output arguments
%
% |instruction| - _STRING_ - String representing the REGGUI/Matlab instruction to execute to import the data
%
% |myFieldFilename| - _STRING_ - File name of the data to be loaded
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instruction,myFieldFilename] = Generate_import_field(which_field,name,handles,input_index)

% Authors : G.Janssens

typelist = {'*.dcm','Dicom File';...
    '*.mat','Matlab File';...
    '*.mha;*.mhd','Meta File';...
    '*.txt','Text File'};

if(nargin>3)
    if(input_index>length(typelist))
        input_index = 1;
    end
    typelist_create = 'typelist = {typelist{input_index,:}';
    for i=1:length(typelist)
        typelist_create = [typelist_create ';typelist{' num2str(i) ',:}'];
    end
    typelist_create = [typelist_create '};'];
    eval(typelist_create);
else
    input_index = 1;
end

get_user_input = 1;
if(isfield(handles,strrep(which_field,' ','_')))
    filename = handles.(strrep(which_field,' ','_'));
    if(exist(filename,'dir')||exist(filename,'file'))
        [myFieldDir,myFieldFilename,ext] = fileparts(filename);
        myFieldFilename = [myFieldFilename,ext];
        filterindex = 5;
        get_user_input = 0;
    end
end

if(get_user_input)
    try
        [myFieldFilename,myFieldDir,filterindex] = uigetfile(typelist, which_field,[handles.dataPath '/Untitled']);
        filterindex = 5;
    catch
        filterindex = 5;
        Field_load = 0;
        disp('Error : not a valid file !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
end


if(filterindex==5)
    [pp nn extension] = fileparts(myFieldFilename);
    switch extension
        case {'.dcm','.DCM'}
            filterindex = 1;
        case '.mat'
            filterindex = 2;
        case {'.mha','.mhd'}
            filterindex = 3;
        case {'.txt'}
            filterindex = 4;
    end
end

instruction = ['handles = Import_field(''',myFieldDir,''',''',myFieldFilename,''',',num2str(filterindex),',''',name,''',handles);'];

