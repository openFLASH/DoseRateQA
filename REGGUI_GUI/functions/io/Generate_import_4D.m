%% Generate_import_4D
% Generate a string representing the REGGUI/Matlab instruction to execute in order to load a set of CT slices representing a 4D-CT using the function |Import_image|.
% This string can be recorded in the REGGUI instruction list. When the string is executed in REGGUI, the 4D-CT is loaded.
% The folder containing the data is either defined in the field |which_image| of |handles| or, alternatively, manually defined in a dialog box.
% The 
%
% For example: |instructions = Generate_import_4D(''Select image'',handles)|
% will (a) display a dialog box with the message 'Select image' to allow the selection of the directory where the CT of the reference phase is located, (b) display another dialog box  to select the CT of the other phases and (c) then return the following string:
% |instructions = 'handles = Import_image(...)'|
%
% When executing the string as an instruction, it will load the images in the relevant |handle.images| data structure (see function |Import_image|). The name of the file will be used to defined the name of the image in |handles|.
%
% The CT scan of the reference phase is imported first if |ref_phase_index| is present in the output list.
%
% Optionaly, it is possible to work in the automatic mode (i.e. no display of dialog boxes). In that case, in the structure |handles|, add a fieldf with a name equal to the string |which_image| (i.e. the string that would normally be displayed in the dialog box). Replace the space characters by '_' character. For example, if the text of the dialog box is 'Select a file', the field should be |handles.Select_a_file|.
%
%% Syntax
% |[instructions,myImageFilenames,myImageDir,ref_phase_index] = Generate_import_4D(which_image,handles)|
%
% |instructions = Generate_import_4D(which_image = STRING,handles)|
%
%
%% Description
% |[instructions,myImageFilenames,myImageDir,ref_phase_index] = Generate_import_4D(which_image = FIELD NAME,handles)| Generate the instruction string to load the image from the folder defined in the field |which_image| of |handles|. The index of the reference phase is returned in |ref_phase_index|.
%
% |[instructions,myImageFilenames,myImageDir,ref_phase_index] = Generate_import_4D(which_image = STRING,handles)| Display a dialog box to select the directories containing the files to load. Then generate an instruction to load the file. The index of the reference phase is returned in |ref_phase_index|
%
% |instructions = Generate_import_4D(which_image = STRING,handles)| Generate a string with the instruction to load the file.  The CT scan of the reference phase is loaded first, before the other phases
%
%
%% Input arguments
% |which_image| - _STRING_ - String defining where to load the data. The string can be either:
%
% * Name of a *field* in |handles| :  If |which_image| is the name of a field of |handles|, then [|handles.| _which_image_] is the name of the directory containing the files to load. In that case, |ref_phase_index| will be null.
% * *Text* to be displayed in a dialog box : If the string is not a field name in |handles|, then a dialog box is displayed to allow the selection of files and |which_image| represents the text which is displayed in this dialog box.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure 
%
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data
% * |handles._which_image_| - _CELL VECTOR of STRINGS_ - [OPTIONAL] |handles._which_image_{i}| If present, define the folder containing the i-th phase of the CT scan. The folder are ordered in increasing phase sequence. The reference phase |ref_phase_index| is the first folder in the list
%
%
%% Output arguments
%
% |instructions| - _CELL VECTOR STRING_ - |instructions{i}| String representing the REGGUI/Matlab i-th instruction to execute to load a set of CT slices representing a 4D-CT.
%
% |myImageFilenames| - _CELL VECTOR of STRING_ - |myImageFilenames{i}| File name of the i-th image to be loaded
%
% |myImageDir| - _STRING_ - Name of the folder where the images are loaded
%
% |ref_phase_index| - _SCALAR_ - Index of the breathing phase that is defined as the reference phase (i.e. the one selected in the first dialog box)
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [instructions,myImageFilenames,myImageDir,ref_phase_index] = Generate_import_4D(which_image,handles)

instructions = cell(0);
current_dir = pwd;
Images_load = 1;
ref_phase_index = 0;

if(isfield(handles,strrep(which_image,' ','_')))
    eval(['imageNames = handles.',strrep(which_image,' ','_'),';']);
    if(exist(imageNames{1},'dir')||exist(imageNames{1},'file'))        
        [myImageDir, myImageFilenames{1}] = fileparts(imageNames{1});
	ref_phase_index =1;
        instructions{1} = ['handles = Import_image(''',myImageDir,''',''',myImageFilenames{1},''',''dcm'',''',myImageFilenames{1},''',handles);'];
        try
            for i=2:length(imageNames)
                [~,myImageFilenames{i}] = fileparts(imageNames{i});
                instructions{i} = ['handles = Import_image(''',myImageDir,''',''',myImageFilenames{i},''',''dcm'',''',myImageFilenames{i},''',handles);'];
            end
        catch
            cd(current_dir)
            disp('Error : image name not found in the input struct !')
            return
        end        
    else % try from the PACS                
        try
            for i=1:length(imageNames)
                temp = orthanc_get_info(['series/',imageNames{i}]);
                myImageDir{i} = temp.MainDicomTags.SeriesDescription;
                myImageFilenames{i} = remove_bad_chars(myImageDir{i});
                instructions{i} = ['handles = Import_image(''',myImageDir{i},''',''',imageNames{i},''',''pacs'',''',myImageFilenames{i},''',handles);'];
            end
        catch
            cd(current_dir)
            disp('Error : image name not found in the PACS or in the input struct !')
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
            return
        end
        
    end
else
    try
        myDirFilename = uigetdir(handles.dataPath,which_image);
        cd(myDirFilename)
        cd ..
        myImageDir = pwd;
        [~,myImageFilename] = fileparts(myDirFilename);
        otherfiles = struct2cell(dir_without_hidden(pwd,'folders'));
        otherfiles = otherfiles(1,:);       
        [selectedDirs,~] = listdlg('PromptString','Select all other phases',...
            'SelectionMode','multiple',...
            'ListString',otherfiles);
        for i=1:length(selectedDirs)
            if(strcmp(otherfiles{selectedDirs(i)},myImageFilename))
                ref_phase_index = i;
                if(nargout<4) % import reference phase first if the index is not an output
                    if(i==1)
                        selectedDirs = selectedDirs(2:end);
                    elseif(i==length(selectedDirs))
                        selectedDirs = selectedDirs(1:end-1);
                    else
                        selectedDirs = [selectedDirs(1:i-1),selectedDirs(i+1:end)];
                    end
                    break
                end
            end
        end
        cd(current_dir)
    catch
        cd(current_dir)
        Images_load = 0;
        disp('Error : not a valid file !')
    end
    myImageFilenames = cell(0);
    if(Images_load)
        if(nargout<4) % import reference phase first if the index is not an output
            instructions{1} = ['handles = Import_image(''',myImageDir,''',''',myImageFilename,''',',num2str(7),',''',myImageFilename,''',handles);'];
            myImageFilenames{1} = myImageFilename;
            for i=1:length(selectedDirs)
                myImageFilenames{i+1} = otherfiles{selectedDirs(i)};
                instructions{i+1} = ['handles = Import_image(''',myImageDir,''',''',myImageFilenames{i+1},''',',num2str(7),',''',myImageFilenames{i+1},''',handles);'];
            end
        else
            for i=1:length(selectedDirs)
                myImageFilenames{i} = otherfiles{selectedDirs(i)};
                instructions{i} = ['handles = Import_image(''',myImageDir,''',''',myImageFilenames{i},''',',num2str(7),',''',myImageFilenames{i},''',handles);'];
            end
        end
    end
end

cd(current_dir)
