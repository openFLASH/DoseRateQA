%% Empty_data
% Creates a void 3D image inside |handles.mydata| that can generally be 
% employed as a mask.
%%

%% Syntax
% |handles = Empty_data(data_dest,handles)|
%
% |handles = Empty_data(data_dest,handles,type)|
%
% |handles = Empty_data(data_dest,handles,type,info_data)|

%% Description
% |handles = Empty_data(data_dest,handles)| creates an empty data entry
% inside |handles.mydata| of type _'unkown'_.
%
% |handles = Empty_data(data_dest,handles,type)| creates an empty data entry
% inside |handles.mydata| of given type stored in |handles.myInfo|.
%
% |handles = Empty_data(data_dest,handles,type,info_data)| creates an empty 
% data entry inside |handles.mydata| associating the type stored in 
% |handles.myInfo| with pre-existent types inside |handles.mydata| or 
% |handles.images|

%% Input arguments
% |data_dest| - _STRING_ - name of the emtpy data to be created inside 
% |handles.mydata|
%
% |handles| - _STRUCTURE_ - REGGUI internal structure where to add the new
% empty data.
%
% |type| - _STRING_ - type of data container to create in |handles.myInfo|
%
% |info_data| - _STRING_ - name of pre-existent data inside |handles.mydata| 
% or |handles.images| to associate |handles.myInfo| to.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the
% newly created empty data.

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Empty_data(data_dest,handles,type,info_data)
if(nargin<3)
    type = 'unknown';
end
dataEmpty = [];
data_dest = check_existing_names(data_dest,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
handles.mydata.data{length(handles.mydata.data)+1} = dataEmpty;
if(nargin<4)
    handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info(type,handles);
else
    myInfo = Create_default_info(type,handles);
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},info_data))
            myInfo = handles.mydata.info{i};
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},info_data))
            myInfo = handles.images.info{i};
        end
    end
    handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
end
