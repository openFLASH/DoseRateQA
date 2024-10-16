
%% Set_reggui_data
% Replaces the raw data and the meta-information in the reggui handles
%
%% Syntax
% |handles = Set_reggui_data(handles,name,data)|
%
% |handles = Set_reggui_data(handles,name,data,info)|
%
% |handles = Set_reggui_data(handles,name,data,info,type)|
%
% |handles = Set_reggui_data(handles,name,data,info,type,overwrite)|
%
% |[handles,name] = Set_reggui_data(handles,name,data,info,type,overwrite)|
%
%
%% Description
% |handles = Set_reggui_data(handles,name,data)| Replaces the raw data corresponding to the input name in reggui handles
%
% |handles = Set_reggui_data(handles,name,data,info)| Replaces the raw data and the meta-information corresponding to the input name in reggui handles
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure.
%
% |name| - _STRING_ -  Name of the data in handles
%
% |data| - raw data  
% 
% |info| - _STRUCTURE_ -  Meta-information about the data.
%
% |type| - _STRING_ -  Type of data. Possible options:
%
% * 'images' : list of images
% * 'fields' : list of fields
% * 'mydata' : list of data
% * 'plans' : list of plans
%
% |overwrite| - _BOOLEAN_ - If the name already exists in the reggui handles, overwrites the existing value (overwrite=1) or creates a new entry (overwrite=0) 
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be set. 
% 
% |name| - _STRING_ -  Name of the data that have been replaced (or created if overwrite=0 and name already existing).
% 
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [handles,name] = Set_reggui_data(handles,name,data,info,type,overwrite)

if(nargin<6)
    overwrite = 1;
end
if(nargin<5)
    type = 'mydata';
end
if(nargin<4)
    info = [];
end
if(nargin<3)
    data = [];
end

% if type does not exist, create it
if(not(isfield(handles,type)))
    handles.(type).name = {'none'};
    handles.(type).data = {[]};
    handles.(type).info = {[]};
end

% remove ambiguous characters
name = remove_bad_chars(name);

% find data in list
[new_name,index] = check_existing_names(name,handles.(type).name);
if(not(overwrite) || index==0) % create new data entry
    index = length(handles.(type).name)+1;
    name = new_name;
    handles.(type).name{index} = name;
    overwrite = 0;
end

% set data to input value
if(isempty(data))
    if(not(overwrite))
        switch type
            case 'images'
                handles.(type).data{index} = zeros(handles.size(1),handles.size(2),handles.size(3),'single');
            case 'fields'
                handles.(type).data{index} = zeros(2+(handles.size(3)>1),handles.size(1),handles.size(2),handles.size(3),'single');
            otherwise
                handles.(type).data{index} = [];
        end
    end
else
    handles.(type).data{index} = data;
end

% set info to input value
if(isempty(info))
    if(not(overwrite))
        switch type
            case 'images'
                handles.(type).info{index} = Create_default_info('image',handles);
            case 'fields'
                handles.(type).info{index} = Create_default_info('deformation_field',handles);
            case 'mydata'
                handles.(type).info{index} = Create_default_info('unknown',handles);
            case 'plan'
                handles.(type).info{index} = Create_default_info('plan',handles);
            otherwise
                handles.(type).info{index} = Create_default_info('unknown',handles);
        end
    end
else
    handles.(type).info{index} = info;
end

% Setting workspace info if needed
if(strcmp(type,'images') && not(handles.spatialpropsettled))
    disp('Setting spatial properties for this project !')
    handles.size(1) = size(handles.(type).data{index},1);
    handles.size(2) = size(handles.(type).data{index},2);
    handles.size(3) = size(handles.(type).data{index},3);
    handles.spacing = handles.(type).info{index}.Spacing;
    handles.origin = handles.(type).info{index}.ImagePositionPatient;
    handles.spatialpropsettled = 1;
end

