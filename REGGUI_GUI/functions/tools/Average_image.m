%% Average_image
% Compute the average of chosen images stored either in |handles.mydata| or |handles.images| or of deformation fields in |handles.fields| 
%
%% Syntax
% |handles = Average_image(imageNames,outname,handles,datatype)|
%
%
%% Description
% |handles = Average_image(imageNames,outname,handles,datatype)| computes the average of the selected images or fields
%
%
%% Input arguments
% |imageNames| - _CELL VECTOR of STRING_ -  |imageNames{i}| Name of the ith image in |handles.images|, |handles.fileds| or |handles.mydata| that is included in the average
%
% |outname| - _STRING_ -  Name of the average image in |handles.images|, |handles.fileds| or |handles.mydata|, depending on location of input data
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images', 'fields' or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |datatype| - _INTEGER_ -  Type of the image to average:
%
% * |datatype = 1| : The data are images stored in |handles.images|
% * |datatype = 2| : The data are fields stored in |handles.fields|
% * Otherwise : The data is stored in |handles.mydata|
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images', 'fields' or "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the resulting image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| resulting intensity at voxel (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Created with Create_default_info.m
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Average_image(imageNames,outname,handles,datatype)

if nargin<4
    datatype = 1;
    disp('As no datatype was selected, default type ''image'' was chosen.');
end

info = [];
type = 'data';

if datatype ==1
    res = [];
    indices = zeros(length(imageNames),1);
    % Initialize result (equal to first image)
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},imageNames{1}))
            res = handles.images.data{i};
            info = handles.images.info{i};
            indices(1) = i;
        end
    end
    if(isempty(info))
        error('First image not found. Abort.')
    else
        type = 'image';
    end
    % Find image indices in handles
    for j=2:length(imageNames)
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},imageNames{j}))
                indices(j) = i;
            end
        end
    end
    if(not(isempty(find(indices==0))))
        error(['Image(s) ',num2str(find(indices==0)),' not found. Abort.'])
    end  
    % Compute the mean for each slice
    for s=1:size(res,3)
        temp = zeros(length(indices),size(res,1),size(res,2),'single');
        for j=1:length(indices)
            temp(j,:,:) = handles.images.data{indices(j)}(:,:,s);
        end
        res(:,:,s) = mean(temp,1);
    end
    outname = check_existing_names(outname,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = outname;
    handles.images.data{length(handles.images.data)+1} = single(squeeze(res));
    info = Create_default_info('image',handles,info);
    handles.images.info{length(handles.images.info)+1} = info;
elseif datatype ==2    
    res = [];
    indices = zeros(length(imageNames),1);
    % Initialize result (equal to first image)
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},imageNames{1}) && strcmp(handles.fields.info{i}.Type,'deformation_field'))
            res = handles.fields.data{i};
            info = handles.fields.info{i};
            indices(1) = i;
        end
    end
    if(isempty(info))
        error('First field not found. Abort.')
    else
        type = 'deformation_field';
    end    
    % Find image indices in handles
    for j=2:length(imageNames)
        for i=1:length(handles.fields.name)
            if(strcmp(handles.fields.name{i},imageNames{j}))
                indices(j) = i;
            end
        end
    end
    if(not(isempty(find(indices==0))))
        error(['Field(s) ',num2str(find(indices==0)),' not found. Abort.'])
    end  
    % Compute the mean for each slice
    for s=1:size(res,4)
        temp = zeros(length(indices),size(res,1),size(res,2),size(res,3));
        for j=1:length(indices)
            temp(j,:,:,:) = handles.fields.data{indices(j)}(:,:,:,s);
        end
        res(:,:,:,s) = mean(temp,1);
    end
    outname = check_existing_names(outname,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = outname;
    handles.fields.data{length(handles.fields.data)+1} = single(squeeze(res));
    info = Create_default_info('deformation_field',handles,info);
    handles.fields.info{length(handles.fields.info)+1} = info;
else
    res = [];
    indices = zeros(length(imageNames),1);
    % Initialize result (equal to first image)
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},imageNames{1}))
            res = zeros(size(handles.mydata.data{i}),'single');
            info = handles.mydata.info{i};
            data_dim = ndims(res);
            indices(1) = i;
        end
    end
    if(isempty(info))
        error('First data not found. Abort.')
    else
        type = info.Type;
    end       
    % Find image indices in handles
    for j=2:length(imageNames)
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},imageNames{j}) && data_dim==ndims(handles.mydata.data{i}))
                if(sum(size(res)==size(handles.mydata.data{i}))==data_dim)
                    indices(j) = i;
                else
                    disp(['Data ',num2str(i),' has incorrect size.'])                    
                end
            end
        end
    end
    if(not(isempty(find(indices==0))))
        error(['Data ',num2str(find(indices==0)),' not found. Abort.'])
    end  
    if(data_dim==4)
        for s=1:size(res,4)
            temp = zeros(length(indices),size(res,1),size(res,2),size(3));
            for j=1:length(indices)
                temp(j,:,:,:) = handles.fields.data{indices(j)}(:,:,:,s);
            end
            res(:,:,:,s) = mean(temp,1);
        end
    else
        % Compute the mean for each slice
        for s=1:size(res,3)
            temp = zeros(length(indices),size(res,1),size(res,2));
            for j=1:length(indices)
                temp(j,:,:) = handles.mydata.data{indices(j)}(:,:,s);
            end
            res(:,:,s) = mean(temp,1);
        end
    end 
    outname = check_existing_names(outname,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = outname;
    handles.mydata.data{length(handles.mydata.data)+1} = single(squeeze(res));
    info = Create_default_info(type,handles,info);
    handles.mydata.info{length(handles.mydata.info)+1} = info;
end

