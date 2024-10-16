%% change_dicom_tag
% Change the value of one DICOM tag all the DICOM file stored in a folder. All the files in the folder must contains the same tags. for example, the function is typically applied to a folder containing a CT scan.
%
%% Syntax
% |change_dicom_tag()|
%
% |change_dicom_tag(dicom_dir,tag_names,new_tag_values)|
%
%
%% Description
% |change_dicom_tag()| Manually select the folder, the tags and new values to be changes in the files
%
% |change_dicom_tag(dicom_dir,tag_names,new_tag_values)| Automatically change the tags to the new values for all the files in the specified folder

%
%
%% Input arguments
%
% |dicom_dir| - _STRING_ - Name of the directory containing the DICOM files
%
% |tag_names| - _CELL VECTOR of STRING_ - DICOM tag names to be modified
%
% |new_tag_values| - _CELL VECTOR_ - |new_tag_values{j}| The new value of the jth tag. Can be _SCALAR_ or _STRING_. Cell vector must be same length as |tag_names| 
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function change_dicom_tag(dicom_dir,tag_names,new_tag_values)

current_dir = pwd;

if(nargin<1)
    dicom_dir = uigetdir(current_dir);
end

try
    
    cd(dicom_dir)
    d = dir(); %TODO Remove the .. and . otherwise line 48 fails is there is less than 3 DICOM files in the folder
    
    if(nargin<3)
        h = dicominfo(d(round(length(d)/2)).name);
        fn = fieldnames(h);
        f = cell(0);
        t = [];
        for i=1:length(fn)
            if(ischar(h.(fn{i})))                
                f{length(f)+1} = fn{i};
                t(length(f)) = 0;
            elseif(isnumeric(h.(fn{i})) && length(h.(fn{i}))==1)
                f{length(f)+1} = fn{i};
                t(length(f)) = 1;
            end
        end
        [selection,Ok] = listdlg('ListString',f,'SelectionMode','single');
        tag_names{1} = f{selection};
        tag_type(1) = t(selection);
        if(tag_type(1)==1) % if numeric tag value
            new_tag_values = cell(0);
            new_tag_string = inputdlg(tag_names{1},'New tag value',1,{num2str(h.(tag_names{1}))});
            if(isempty(new_tag_string{1}))
                new_tag_values{1} = [];
            else
                new_tag_values{1} = str2double(new_tag_string{1});
            end
        else % if string tag value
            new_tag_values = inputdlg(tag_names{1},'New tag value',1,{h.(tag_names{1})});
        end
    end
    
    for i=3:length(d)
        
        h = dicominfo(d(i).name);
        g = dicomread(d(i).name);
        
        for j=1:length(tag_names)
            if(isempty(new_tag_values{j}) && isfield(h,tag_names{j}))
                h = rmfield(h,tag_names{j});
            else
                h.(tag_names{j}) = new_tag_values{j};
            end
        end
        
        dicomwrite(g,fullfile(dicom_dir,d(i).name),h,'CreateMode','copy');
    end
    
    cd(current_dir)
    
catch ME
    cd(current_dir)
    rethrow(ME);
end
