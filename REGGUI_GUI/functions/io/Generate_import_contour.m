%% Generate_import_contour
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load a set of RT struct using the function |Import_contour|.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the RT-struct is loaded from file.
% The file name and folder containing the data is either defined in the field |which_contour| of |handles| or, alternatively, manually defined in a dialog box.
%
% For example: |instructions = Generate_import_contour(''Select contour'',...)|
% will (a) display a dialog box with the message 'Select contour' to allow the selection of the file, (b) display another dialog box to select the contours inside the DICOM file and (c) then return the following string:
% |instructions = 'handles = Import_contour(...)'|
%
% When executing the string as an instruction, it will load the contours in the relevant |handle.images| or |handle.mydata| data structure (see function |Import_contour|).
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_contour| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instruction,list_of_selectedContours,myContourFilename,list_of_importedContours,myContourDir] = Generate_import_contour(which_contour = FIELD NAME,ref_image,type,handles)|
%
% |[instruction,list_of_selectedContours,myContourFilename,list_of_importedContours,myContourDir] = Generate_import_contour(which_contour=STRING,ref_image,type,handles)|
%
%
%% Description
% |[instruction,list_of_selectedContours,myContourFilename,list_of_importedContours,myContourDir] = Generate_import_contour(which_contour= FIELD NAME,ref_image,type,handles)| Generate the instruction string to load the contours with file name and folder defined in the field |which_contour| of |handles|.
%
% |[instruction,list_of_selectedContours,myContourFilename,list_of_importedContours,myContourDir] = Generate_import_contour(which_contour=STRING,ref_image,type,handles)|  Display a dialog box to select the RT-struct file to load. Then generate a string with the instruction to load the file.
%
%
%% Input arguments
% |which_contour| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_contour| is the name of a field of |handles|, then [|handles.| _which_contour_] is the file name and directory containing the files to load. Alternatively, [|handles.| _which_contour_] can define an instance UID of the RT struc file in Orthanc PACS.
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_contour| represents the text which is displayed in this dialog box.
%
% |ref_image| - _STRING_ - Name of image in |handles.mydata| or |handles.images| to which the contours are associated.
%
% |type| - _INTEGER_ - Defines where the contour import is performed:
%
% * if |type = 1| the contours are imported in |handles.images|
% * if |type = 3| the contours are imported in |handles.mydata|.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure
%
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data
% * ||handles._which_contour_.structName| - _STRING_ - [OPTIONAL] If provided, folder and file name (alternatively: instance UID on PACS) of the RT struct file. The dialog box is not displayed
% * ||handles._which_contour_.contoursNames| - _CELL VECTOR of STRING_ - [OPTIONAL] List of contour names to import from the RT struct file. The dialog box is not displayed
% * ||handles._which_contour_.import _ all _ contours| - _STRING_ - [OPTIONAL] If the field is present, all the contours contained in the RT struct file are imported.
%
% |contour_names| - _CELL of STRINGS_ - [OPTIONAL] parameter that imposes given contour names over default names.
%
%
%% Output arguments
%
% |instruction| - _CELL VECTOR STRING_ - |instructions{u}| String representing the REGGUI/Matlab i-th instruction to execute to import the contours
%
% |list_of_selectedContours| - _CELL VECTOR of STRING_ - |list_of_selectedContours{i}| Name of the i-th contour (original name)
%
% |myContourFilename| - _STRING_ - Name of the RT structure Dicom file.
%
% |list_of_importedContours| - _CELL VECTOR of STRING_ - |list_of_selectedContours{i}| Name of the i-th binary mask as imported in reggui handles
%
% |myContourDir| - _STRING_ - Name of the directory in which the RT struct file is stored.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instruction,list_of_selectedContours,myContourFilename,list_of_importedContours,myContourDir] = Generate_import_contour(which_contour,ref_image,type,handles,contour_names)

instruction = '';
list_of_selectedContours = cell(0);

get_user_input = 1;
use_pacs = 0;
if(isfield(handles,strrep(which_contour,' ','_')))
    struct_and_contours = handles.(strrep(which_contour,' ','_'));
    if(isempty(struct_and_contours.structName))
        disp(['Warning: <<',which_contour,'>>: no contour to import.'])
        return
    end
    if(exist(struct_and_contours.structName,'file'))
        get_user_input = 0;
    else % struct_and_contours.structName is the UID of the rtstruct in the PACS
        get_user_input = 0;
        use_pacs = 1;
    end
end

if(not(get_user_input))
    if(use_pacs)        
        [~,reggui_config_dir] = get_reggui_path();
        temp_dir = fullfile(reggui_config_dir,'temp_dcm_data');
        if(not(exist(temp_dir,'dir')))
            mkdir(temp_dir);
        end
        image_dir = fullfile(temp_dir,struct_and_contours.structName); % myImageDir gives the image (series) name
        if(exist(image_dir,'dir'))
            try
                rmdir(image_dir,'s');
            catch
                disp(['Warning: cannot delete folder ',image_dir]);
            end
        end
        mkdir(image_dir);
        orthanc_save_to_disk(['instances/',struct_and_contours.structName,'/file'],fullfile(image_dir,'rtstruct.dcm')); % structName gives the UID of the instance
        try
            contours = read_dicomrtstruct(fullfile(image_dir,'rtstruct.dcm'));
        catch
            disp('This is not a valid RTStruct file!')
            return
        end
        rmdir(image_dir,'s');
        contoursAvailable = {contours.Struct.Name};
        selectedContours = [];
        if(isfield(struct_and_contours,'contoursNames'))
            contoursNames = struct_and_contours.contoursNames;
            for i=1:length(contoursAvailable)
                if(sum(strcmp(contoursNames,contoursAvailable{i})))
                    selectedContours = [selectedContours i];
                end
            end
        elseif(isfield(struct_and_contours,'import_all_contours'))
            selectedContours = 1:length(contoursAvailable);
        else
            [selectedContours,OK] = listdlg('PromptString',which_contour,...
                'SelectionMode','multiple',...
                'ListString',contoursAvailable);
            if OK==0
                disp('Wrong selection')
                return
            end
        end
        myContourFullname = struct_and_contours.structName;
        myContourFilename = '';
    else
        [myContourDir,myContourFilename,ext] = fileparts(struct_and_contours.structName);
        myContourFilename = [myContourFilename,ext];
        myContourFullname = fullfile(myContourDir,myContourFilename);
        try
            contours = read_dicomrtstruct(myContourFullname);
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
        elseif(isfield(struct_and_contours,'import_all_contours'))
            selectedContours = 1:length(contoursAvailable);
        else
            [selectedContours,OK] = listdlg('PromptString',which_contour,...
                'SelectionMode','multiple',...
                'ListString',contoursAvailable);
            if OK==0
                disp('Wrong selection')
                return
            end
        end
    end
else
    [myContourFilename, myContourDir] = uigetfile( ...
        {'*.*','RTSTRUCT Files (*)'; ...
        '*.*',  'All Files (*.*)'}, ...
        which_contour, [handles.dataPath '/Untitled']);
    myContourFullname = fullfile(myContourDir,myContourFilename);
    try
        contours = read_dicomrtstruct(myContourFullname);
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

if(nargin>4)
    contour_name_str = ',{';
    for i=1:length(selectedContours)
        contour_name_str = [contour_name_str,'''',contour_names{i},''','];
    end
    contour_name_str = [contour_name_str(1:end-1),'}'];
else
    contour_name_str = '';
end

if(length(selectedContours)>1)
    instruction = ['handles = Import_contour(''',myContourFullname,''',[',num2str(selectedContours),'],''',ref_image,''',',num2str(type),',handles',contour_name_str,');'];
    for i=1:length(selectedContours)
        if(nargin>4)
            list_of_selectedContours{i} = contour_names{i};
        else
            list_of_selectedContours{i} = contoursAvailable{selectedContours(i)};
        end
    end
elseif(length(selectedContours)==1)
    instruction = ['handles = Import_contour(''',myContourFullname,''',',num2str(selectedContours(1)),',''',ref_image,''',',num2str(type),',handles',contour_name_str,');'];
    if(nargin>4)
        list_of_selectedContours{1} = contour_names{1};
    else
        list_of_selectedContours{1} = contoursAvailable{selectedContours(1)};
    end
else
    instruction = '';
end

if(nargout>3)
    list_of_importedContours = cell(0);
    for i=1:length(selectedContours)
        list_of_importedContours{i} = [ref_image,'_',remove_bad_chars(list_of_selectedContours{i})];
        %TODO This will not work if there are two structure with the same name in the DICOM file
        % In that case 'Import_contour.m' will add _1 at the end of the name
    end
end
