%% Generate_import_RT
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load a RT-struct and the associated images. The images and contours are stored in |handles.images| or |handles.mydata| dependong on the parameter |type|.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the RT-struct is loaded from file (using function |Import_image| or |Import_data| or |Import_contour|).
% The file name and folder containing the data is either defined in the field |which_contour| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_RT(''Select RT-struct'',...)|
% will (a) display a dialog box with the message 'Select RT-struct' to allow the selection of the RT-struct and (b) then return the following string:
% |instructions = 'handles = Import_contour(...)'|
%
% When executing the string as an instruction, it will load the registration data structure in the relevant |handles| data structure (see function |Import_image| or |Import_data| or |Import_contour|) with the |image_name|.
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_contour| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir] = Generate_import_RT(which_contour = FIELD NAME,image_name,type,handles)|
%
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir] = Generate_import_RT(which_contour=STRING,image_name,type,handles)|
%
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir,instruction_import_contours] = Generate_import_RT(which_contour,image_name,type,handles)|
%
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir,instruction_import_contours,myImageUID] = Generate_import_RT(which_contour,image_name,type,handles)|
%
%% Description
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir,instruction_import_contours,myImageUID] = Generate_import_RT(which_contour = FIELD NAME,image_name,type,handles)| Generate the instruction string to load the RT-struct with file name and folder defined in the field |which_contour| of |handles|
%
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir,instruction_import_contours,myImageUID] = Generate_import_RT(which_contour=STRING,image_name,type,handles)| Display a dialog box to select the file to load. Then generate a string with the instruction to load the file. 
%
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir,instruction_import_contours] = Generate_import_RT(which_contour,image_name,type,handles)| The instructions to load the images are stored in |instructions| and the instructions to load the contours are stored in |instruction_import_contours|.
%
% |[instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir,instruction_import_contours,myImageUID] = Generate_import_RT(which_contour,image_name,type,handles)|
%
%% Input arguments
% |which_contour| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_contour| is the name of a field of |handles|, then [|handles.| _which_contour_] is the file name and directory containing the files to load. 
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_contour| represents the text which is displayed in this dialog box. 
%
% |image_name| - _STRING_ - Name of the data structure inside |handles|. 
%
% |type| - _INTEGER_ - Define how to load the image and contours:
%
% * if |type = 1| the contours are imported in |handles.images| and the image is imported using the function |Import_image|
% * if |type = 3| the contours are imported in |handles.mydata| and the image is imported using the function |Import_data|.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure 
%
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data  
%
%
%% Output arguments
%
% |instruction| - _CELL VECTOR STRING_ - |instructions{i}| String representing the REGGUI/Matlab i-th instruction to execute to import the data
%
% |myImageFilename| - _STRING_ - File name of the image to be loaded
%
% |myContourFilename| - _STRING_ - File name of the RT-struct to be loaded
%
% |list_of_selectedContours| - _CELL VECTOR STRING_ - List with the name of the controus that have been loaded
%
% |myImageDir| - _STRING_ - Name of the folder where the images are loaded
%
% |instruction_import_contours| - _CELL VECTOR of STRING_ -  If present, the instructions to load the images are stored in |instructions| and the instructions to load the contours are stored in |instruction_import_contours|. Otherwise, all the instructions are stored in |instruction|.
%
% |myImageUID| - _STRING_ -  Patient ID
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instruction,myImageFilename,myContourFilename,list_of_selectedContours,myImageDir,instruction_import_contours,myImageUID] = Generate_import_RT(which_contour,image_name,type,handles)

% Authors : G.Janssens

instruction = '';

get_user_input = 1;
if(isfield(handles,strrep(which_contour,' ','_')))
    struct_and_contours = handles.(strrep(which_contour,' ','_'));
    if(exist(struct_and_contours.structName,'file'))
        get_user_input = 0;
    end
end

if(not(get_user_input))
    [myContourDir,myContourFilename] = fileparts(struct_and_contours.structName);
    try
        contours = read_dicomrtstruct(fullfile(myContourDir,myContourFilename));
    catch
        disp('This is not a valid RTStruct file!')
        return
    end
    contoursAvailable = {contours.Struct.Name};
    selectedContours = [];
    if(isfield(struct_and_contours,'contoursNames'))
        contoursNames = struct_and_contours.contoursNames;
        for i=1:length(contoursAvailable)
            if(sum(strcmp(contoursNames,contoursAvailable{i})))
                selectedContours = [selectedContours i];
            end
        end
    else
        [selectedContours,OK] = listdlg('PromptString',which_contour,...
            'SelectionMode','multiple',...
            'ListString',contoursAvailable);
        if OK==0
            disp('Wrong selection')
            return
        end
    end
else
    [myContourFilename, myContourDir] = uigetfile( ...
        {'*.*','RTSTRUCT Files (*)'; ...
        '*.*',  'All Files (*.*)'}, ...
        which_contour, [handles.dataPath '/Untitled']);
    try
        contours = read_dicomrtstruct(fullfile(myContourDir,myContourFilename));
    catch
        disp('This is not a valid RTStruct file!')
        return
    end
    contoursAvailable = {contours.Struct.Name};
    [selectedContours,OK] = listdlg('PromptString',which_contour,...
        'SelectionMode','multiple',...
        'ListString',contoursAvailable);
    if OK==0
        disp('Wrong selection')
        return
    end
end

if(strcmp(myContourDir(end),'\')||strcmp(myContourDir(end),'/'))
    myContourDir = myContourDir(1:end-1);
end
[myImageDir myImageFilename] = fileparts(myContourDir);

if(type==1)
    instruction = ['handles = Import_image(''',myImageDir,''',''',myImageFilename,''',7,''',image_name,''',handles);'];
else
    instruction = ['handles = Import_data(''',myImageDir,''',''',myImageFilename,''',8,''',image_name,''',handles);'];
end

myImageUID = [];
if(nargout>2)
    try
        if(isdir(fullfile(myImageDir,myImageFilename)))
            files = dir(fullfile(myImageDir,myImageFilename));
            myImageInfo = dicominfo(fullfile(fullfile(myImageDir,myImageFilename),files(4).name));
            myImageUID = myImageInfo.PatientID;
        else
            myImageInfo = dicominfo(fullfile(myImageDir,myImageFilename));
            myImageUID = myImageInfo.PatientID;
        end
    catch
    end
end

if(nargout<6)
    if(length(selectedContours)==1)
        instruction = [instruction,'handles = Import_contour(''',fullfile(myContourDir,myContourFilename),''',',num2str(selectedContours(1)),',''',image_name,''',',num2str(type),',handles);'];
    elseif(length(selectedContours)>1)
        instruction = [instruction,'handles = Import_contour(''',fullfile(myContourDir,myContourFilename),''',[',num2str(selectedContours),'],''',image_name,''',',num2str(type),',handles);'];
    end
else
    if(length(selectedContours)==1)
        instruction_import_contours = ['handles = Import_contour(''',fullfile(myContourDir,myContourFilename),''',',num2str(selectedContours(1)),',''',image_name,''',',num2str(type),',handles);'];
    elseif(length(selectedContours)>1)
        instruction_import_contours = ['handles = Import_contour(''',fullfile(myContourDir,myContourFilename),''',[',num2str(selectedContours),'],''',image_name,''',',num2str(type),',handles);'];
    end
end

list_of_selectedContours = cell(0);
list_of_selectedContours{1} = contoursAvailable{selectedContours(1)};

if(nargout>3 && length(selectedContours)>1)
    list_of_selectedContours = cell(0);
    for i=1:length(selectedContours)
        list_of_selectedContours{i} = contoursAvailable{selectedContours(i)};
    end
end
