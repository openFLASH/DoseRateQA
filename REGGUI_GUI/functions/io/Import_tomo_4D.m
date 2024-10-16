%% Import_tomo_4D
% Display a dialog box allowing the user to select several files images at binary format ('*.img' extension). Each file contains a stack of 2D images.
% Each stack of images from eaach file will be loaded in a different image of |handles.image| with a name equal to the file name.
%
%% Syntax
% |res = Import_tomo_4D(handles)|
%
%
%% Description
% |res = Import_tomo_4D(handles)| Load binary images
%
%
%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI data structure containing the data to be processed.
%
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
% * |handles.path| - _STRING_ - Define the path where to save the log file
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data 
%
%
%% Output arguments
%
% |res= handles| - _STRUCTURE_ -  Description
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Import_tomo_4D(handles)

res = handles;

current_dir = pwd;
eventdata = 'Select directory';
Images_load = 1;
try
    myImageDir = uigetdir(handles.dataPath,eventdata);
    cd(myImageDir)
    all_files = struct2cell(dir);
    all_files = all_files(1,3:end);
    isimgfile = strfind(all_files,'.img');
    for j=1:length(all_files)
        if(isempty(isimgfile{j}))
            isimgfile{j} = 0;
        end
    end
    all_files = all_files(find(cell2mat(isimgfile)));
    [selectedDirs,OK] = listdlg('PromptString','Select all tomo matrices',...
        'SelectionMode','multiple',...
        'ListString',all_files);
    cd(handles.path)
catch ME    
    reggui_logger.info(['Error : not a valid file. ',ME.message],handles.log_filename);
    cd(current_dir)
    rethrow(ME);
end
if(Images_load)
    for i=1:length(selectedDirs)
            handles = Import_tomo_matrix(all_files{selectedDirs(i)},handles,fullfile(myImageDir,all_files{selectedDirs(i)}));
    end
end

res = handles;
