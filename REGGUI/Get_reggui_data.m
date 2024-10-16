%% Get_reggui_data
% Return the raw data and the meta-information from the reggui handles
%
%% Syntax
% |data = Get_reggui_data(handles,name)|
%
% |[data,info] = Get_reggui_data(handles,name)|
%
% |[data,info,type] = Get_reggui_data(handles,name)|
%
% |[data,info] = Get_reggui_data(handles,name,type)|
%
%
%% Description
% |data = Get_reggui_data(handles,name)| Returns the raw data corresponding to its name in reggui handles
%
% |[data,info] = Get_reggui_data(handles,name)| Returns the raw data and the meta-information corresponding to its name in reggui handles
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure.
%
% |name| - _STRING_ -  Name of the data in handles
%
% |type| - _STRING_ -  Type of data. Possible options:
%
% * 'images' : list of images
% * 'fields' : list of fields
% * 'mydata' : list of data
% * 'plans' : list of plans
% * 'indicators' : list of indicators
%
%
%% Output arguments
%
% |data| - raw data  
% 
% |info| - _STRUCTURE_ -  Meta-information about the data.
%
% |type| - _STRING_ -  Type of data.
% 
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


function [data,info,type] = Get_reggui_data(handles,name,type)

if(nargin<3)
    type = 'undefined_type';
end

if(isfield(handles,type))
    for i=1:length(handles.(type).name)
        if(strcmp(handles.(type).name{i},name))
            data = handles.(type).data{i};
            info = handles.(type).info{i};
        end
    end
else
    for i=1:length(handles.indicators.name)
        if(strcmp(handles.indicators.name{i},name))
            data = handles.indicators.data{i};
            info = handles.indicators.info{i};
            type = 'indicators';
        end
    end
    for i=1:length(handles.plans.name)
        if(strcmp(handles.plans.name{i},name))
            data = handles.plans.data{i};
            info = handles.plans.info{i};
            type = 'plans';
        end
    end
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},name))
            data = handles.mydata.data{i};
            info = handles.mydata.info{i};
            type = 'mydata';
        end
    end
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},name))
            data = handles.fields.data{i};
            info = handles.fields.info{i};
            type = 'fields';
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},name))
            data = handles.images.data{i};
            info = handles.images.info{i};
            type = 'images';
        end
    end
end
