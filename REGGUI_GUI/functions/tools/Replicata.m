%% Replicata
% Make a copy of the specified data (image or field) in the same repository ("images" or "mydata" or "fields"). The data can also be multiplied by a specified factor before being copied.
%
%% Syntax
% |handles = Replicata(data_to_copy,data_dest,type,handles)|
%
% |handles = Replicata(data_to_copy,data_dest,type,handles,multiplicative_factor)|
%
%
%% Description
% |handles = Replicata(data_to_copy,data_dest,type,handles)| Make a copy of the data
%
% |handles = Replicata(data_to_copy,data_dest,type,handles,multiplicative_factor)| Make a copy of the data multiplied by the specified factor
%
%
%% Input arguments
% |data_to_copy| - _STRING_ - Name of the image contained in |handles.XXX.name| to be copied
%
% |data_dest| - _STRING_ -  Name of the new image created in |handles.XXX.name|
%
% |type| - _INTEGER_ - specify where the source data is located:
%
% * |type=1| : data is located in |handles.images| 
% * |type=2| : data is located in |handles.fields|
% * |type=3| : data is located in |handles.mydata|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "images" or "mydata" or "fields"):
%
% * |handles.XXX.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _CELL VECTOR_ - 
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |multiplicative_factor| - _SCALAR VECTOR_ -  [OPTIONAL. Default = 1] If the input is an image, then this is a _SCALAR_ defining the multiplication factor to apply to the input image before copying it. If the input is a deformation field, then this is a _SCALAR VECTOR_ defining the multiplication factor of the (x,y,z) components of the vector ofthe deformation field.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated: (where XXX is either "images" or "mydata" or "fields", depending on the location of the input data):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _CELL VECTOR_ -
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Replicata(data_to_copy,data_dest,type,handles,multiplicative_factor)

% convert numeric input format into string
if(isnumeric(type))
    switch type
        case 1
            type = 'images';
        case 2
            type = 'fields';
        case 3
            type = 'mydata';
        case 4
            type = 'plans';
        otherwise
            error('Invalid type number.')
    end
end

switch type
    case 'images'
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},data_to_copy))
                myInfo = handles.images.info{i};
                myData = handles.images.data{i};
            end
        end
        if(nargin>4)
            myData = myData .* multiplicative_factor ;
        end
        data_dest = check_existing_names(data_dest,handles.images.name);
        handles.images.name{length(handles.images.name)+1} = data_dest;
        handles.images.data{length(handles.images.data)+1} = myData;
        handles.images.info{length(handles.images.info)+1} = myInfo;
    case 'fields'
        for i=1:length(handles.fields.name)
            if(strcmp(handles.fields.name{i},data_to_copy))
                myInfo = handles.fields.info{i};
                myData = handles.fields.data{i};
            end
        end
        if(nargin>4)
            if(length(multiplicative_factor)==1)
                myData = myData .* multiplicative_factor ;
            elseif(length(multiplicative_factor)==size(myData,1))
                for n=1:size(myData,1)
                    myData(n,:,:,:) = myData(n,:,:,:) .* multiplicative_factor(n);
                end
            end
        end
        data_dest = check_existing_names(data_dest,handles.fields.name);
        handles.fields.name{length(handles.fields.name)+1} = data_dest;
        handles.fields.data{length(handles.fields.data)+1} = myData;
        handles.fields.info{length(handles.fields.info)+1} = myInfo;
    case 'mydata'
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},data_to_copy))
                myInfo = handles.mydata.info{i};
                myData = handles.mydata.data{i};
            end
        end
        if(nargin>4)
            myData = myData .* multiplicative_factor ;
        end
        data_dest = check_existing_names(data_dest,handles.mydata.name);
        handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
        handles.mydata.data{length(handles.mydata.data)+1} = myData;
        handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
    case 'plans'
        for i=1:length(handles.plans.name)
            if(strcmp(handles.plans.name{i},data_to_copy))
                myInfo = handles.plans.info{i};
                myData = handles.plans.data{i};
            end
        end
        data_dest = check_existing_names(data_dest,handles.plans.name);
        handles.plans.name{length(handles.plans.name)+1} = data_dest;
        handles.plans.data{length(handles.plans.data)+1} = myData;
        handles.plans.info{length(handles.plans.info)+1} = myInfo;
    otherwise
        error('Invalid type.')
end
