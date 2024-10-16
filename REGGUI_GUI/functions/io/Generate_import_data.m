%% Generate_import_data
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load unconstrained image data.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the image is loaded from file (using function |Import_data|).
% The file name and folder containing the data is either defined in the field |which_data| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_data(''Select image'',...)|
% will (a) display a dialog box with the message 'Select image' to allow the selection of the image file and (b) then return the following string:
% |instructions = 'handles = Import_data(...)'|
%
% When executing the string as an instruction, it will load the image in the relevant |handle.mydata| data structure (see function |Import_data|) with the |name|. The type of data will be determined from the file extension.
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_data| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instruction,myDataFilename,myDataUID,myDataDir] = Generate_import_data(which_data = FIELD NAME,name,handles)|
%
% |[instruction,myDataFilename,myDataUID,myDataDir] = Generate_import_data(which_data=STRING,name,handles)|
%
% |[instruction,myDataFilename,myDataUID,myDataDir] = Generate_import_data(which_data,name,handles,input_index)|
%
%
%% Description
% |[instruction,myDataFilename,myDataUID,myDataDir] = Generate_import_data(which_data = FIELD NAME,name,handles)| Generate the instruction string to load the image with file name and folder defined in the field |which_data| of |handles|.
%
% |[instruction,myDataFilename,myDataUID,myDataDir] = Generate_import_data(which_data=STRING,name,handles)| Display a dialog box to select the image file to load. Then generate a string with the instruction to load the file. 
%
% |[instruction,myDataFilename,myDataUID,myDataDir] = Generate_import_data(which_data,name,handles,input_index)| In the dialog box to select the files, only allow the selection of file with the specified extension types.
%
%
%% Input arguments
% |which_data| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_data| is the name of a field of |handles|, then [|handles.| _which_data_] is the file name and directory containing the files to load. 
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_data| represents the text which is displayed in this dialog box. 
%
% |name| - _STRING_ - Name of the data structure inside |handles.mydata|. 
%
% |input_index| - _INTEGER VECTOR_ - [OPTIONAL] Specify the types of file extension that can be selected in the dialog box. If the vector has more than one element, then several extension types are allowed. If not specified, then all extensions will be allowed. The following file extensions are possible:
%
% * |input_index = 1| : '*.dcm;*.DCM'  : DICOM Serie
% * |input_index = 2| : '*.dcm;*.DCM'  : 3D Dose files
% * |input_index = 3| : '*.mat'        : MATLAB Files
% * |input_index = 4| : '*.hdr'        : ANALYZE Files
% * |input_index = 5| : '*.mha;*.mhd'  : Meta Image Files
% * |input_index = 6| : '*.tif;*.bmp;*.png;*.jpg;*.gif;*.dcm' : 2D Image Files
% * |input_index = 7| : '*.txt'        : TEXT Files
% * |input_index = 8| : '*.*'          : All Files
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
% |myDataFilename| - _STRING_ - File name of the data to be loaded
%
% |myDataUID| - _STRING_ -  Patient ID
%
% |myDataDir| - _STRING_ - Name of the folder where the images are loaded
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instruction,myDataFilename,myDataUID,myDataDir] = Generate_import_data(which_data,name,handles,input_index)

typelist = {'*.dcm;*.DCM','DICOM Serie (*.dcm)'; ...
    '*.dcm;*.DCM','3D Dose files (*.dcm)'; ...
    '*.mat','MATLAB Files (*.mat)'; ...
    '*.hdr','ANALYZE Files (*.hdr)'; ...
    '*.mha;*.mhd','Meta Image Files (*.mha, *.mhd)'; ...
    '*.tif;*.bmp;*.png;*.jpg;*.gif;*.dcm','2D Image Files (*.tif, *.bmp, *.png, *.jpg, *.gif, *.dcm)'; ...
    '*.txt','TEXT Files (*.txt)'; ...
    '*.*',  'All Files (*.*)'};

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
if(isfield(handles,strrep(which_data,' ','_')))
    filename = handles.(strrep(which_data,' ','_'));
    if(exist(filename,'dir')||exist(filename,'file'))
        [myDataDir,myDataFilename,myExt] = fileparts(filename);
        myDataFilename = [myDataFilename,myExt];
        filterindex = input_index;
        get_user_input = 0;
    end
end

if(get_user_input)
    [myDataFilename, myDataDir, filterindex] = uigetfile( ...
        typelist, which_data, [handles.dataPath '/Untitled']);
    if(nargin>3)
        filterindex = filterindex -1;
        if(filterindex==0)
            filterindex = input_index;
        end
    end
end

if(isempty(filterindex))
    filterindex = 8;
end

if(filterindex==8)
    [pp nn extension] = fileparts(myDataFilename);
    switch extension
        case {'.dcm','.DCM'}
            filterindex = 1;
        case '.mat'
            filterindex = 3;
        case '.hdr'
            filterindex = 4;
        case {'.mha','.mhd'}
            filterindex = 5;
        case {'.jpg','.png','.gif','.tif','.bmp'}
            filterindex = 6;
        case {'.txt'}
            filterindex = 7;
    end
end

instruction = ['handles = Import_data(''',myDataDir,''',''',myDataFilename,''',',num2str(filterindex),',''',name,''',handles);'];

myDataUID = 'noID';
if(nargout>2 && filterindex==1)
    try
        if(isdir(fullfile(myDataDir,myDataFilename)))
            files = dir(fullfile(myDataDir,myDataFilename));
            myDataInfo = dicominfo(fullfile(fullfile(myDataDir,myDataFilename),files(4).name));
            myDataUID = myDataInfo.PatientID;
        else
            myDataInfo = dicominfo(fullfile(myDataDir,myDataFilename));
            myDataUID = myDataInfo.PatientID;
        end
    catch
    end
end
