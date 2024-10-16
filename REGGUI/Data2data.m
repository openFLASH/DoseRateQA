%% Data2data
% *Copy* and *resample* a paralellipipedic *sub-volume* of an image (or field) from the |handles.mydata| into a new image (or field) of the |handles.mydata| structure.
%
%% Syntax
% |handles = Data2data(data_name,orig,imsize,spacing,data_dest,handles,new_patient_position)|
%
%
%% Description
% |handles = Data2data(data_name,orig,imsize,spacing,data_dest,handles,new_patient_position)| copy and resample the image or field
%
%
%% Input arguments
% |data_name| - _STRING_ - Name of the image or field contained in |handles.mydata| 
%
% |orig| - _VECTOR of INTEGER_ -  (If empty, defaul = [1;1;1]) Coordinate (x,y,z) (in |pixels| of the original coordinates) of the first voxel (first apex) of the sub-volume to be copied
%
% |imsize| - _VECTOR of DOUBLE_ -  Dimensions (dx,dy,dz) of the edges of the paralellipiped to be copied |pixels| of the resulting coordinates. If empty, the paralellipied extend to the laxt voxel of the image (or field).
%
% |spacing| - _VECTOR of DOUBLE_ -  Size of the voxels of |handles.mydata| in |mm|.
%
% |data_dest| - _STRING_ -  Name of the new image created in |handles.mydata| with the sub-volume
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
% * |handles.mydata.name| - _STRING_ - Name of the image
% * |handles.mydata.data| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.mydata.info| - _STRUCTURE_ DICOM Information about the image
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI
%
% |new_patient_position| - _SCALAR VECTOR_ -  |new_patient_position(x,y,z)| Coordinates (in mm) of the new origin for the DICOM coordiante system = coordinate ofthe first voxel in the image
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) = the resampled sub-volume of the image
% * |handles.mydata.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info|
% * |handles.mydata.info{i}.Spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the image = |spacing|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Data2data(data_name,orig,imsize,spacing,data_dest,handles,new_patient_position)

% Authors : G.Janssens, J.Orban

data = [];
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},data_name))
        data = handles.mydata.data{i};
        data_info = handles.mydata.info{i};
    end
end
if(isempty(data))
   error('Data not found !')
end
if(isempty(orig))
    orig = [1;1;1];
end
if(isempty(imsize) && not(isempty(spacing)))
    imsize = size(data)'.*data_info.Spacing./spacing;
end
if(isempty(imsize) && isempty(spacing))
    imsize = size(data)';
end
if(isempty(spacing))
    spacing = data_info.Spacing;
end
% same_spacing = 0;
% for i=1:3
%     if(round(spacing(i)*1e3)==round(data_info.Spacing(i)*1e3))
%         spacing(i) = data_info.Spacing(i);
%         same_spacing = same_spacing+1;
%     end
% end
info = Create_default_info('image',handles,[],[],data_info);
if(isfield(data_info,'OriginalHeader'))
    info.OriginalHeader = data_info.OriginalHeader;
end
if(nargin>6)
    data_info.ImagePositionPatient = new_patient_position;
end
info.Spacing = spacing;
info.ImagePositionPatient = data_info.ImagePositionPatient + (orig-1).*data_info.Spacing;
if(handles.size(3) == 1)
    if(spacing(1)>data_info.Spacing(1))
        downfactor = spacing(1)./data_info.Spacing(1);
        sigma = downfactor*.4;
        fsz = round(sigma * 5);
        fsz = fsz + (1-mod(fsz,2));
        filterx = gaussian_kernel(fsz, sigma);
        filterx = filterx/sum(filterx);
        data = conv2(data, filterx);
    end
    if(spacing(2)>data_info.Spacing(2))
        downfactor = spacing(2)./data_info.Spacing(2);
        sigma = downfactor*.4;
        fsz = round(sigma * 5);
        fsz = fsz + (1-mod(fsz,2));
        filtery = gaussian_kernel(fsz, sigma);
        filtery = filtery'/sum(filtery);
        data = conv2(data, filtery);
    end
    %     if(same_spacing==3)
    %         data = data(orig(1):orig(1)+imsize(1)-1,orig(2):orig(2)+imsize(2)-1);
    %     else
    lastpt = orig + (imsize-1).*spacing./data_info.Spacing;
    [X Y] = meshgrid(linspace(orig(2)+1,lastpt(2),imsize(2)),linspace(orig(1)+1,lastpt(1),imsize(1)));
    X = single(X);
    Y = single(Y);
    data_new = interp2(data,X,Y);
    %     end
else
    if (isafield(data))
        for i=1:3
            datai=data(i,:,:,:);
            if(spacing(1)>data_info.Spacing(1))
                downfactor = spacing(1)./data_info.Spacing(1);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filterx = gaussian_kernel(fsz, sigma);
                filterx = filterx/sum(filterx);
                datai = padarray(datai, [length(filterx) 0 0], 'replicate');
                datai = conv3f(datai, single(filterx));
                datai = datai(length(filterx)+1:end-length(filterx), :, :);
            end
            if(spacing(2)>data_info.Spacing(2))
                downfactor = spacing(2)./data_info.Spacing(2);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filtery = gaussian_kernel(fsz, sigma);
                filtery = filtery'/sum(filtery);
                datai = padarray(datai, [0 length(filtery) 0], 'replicate');
                datai = conv3f(datai, single(filtery));
                datai = datai(:,length(filtery)+1:end-length(filtery), :);
            end
            if(spacing(3)>data_info.Spacing(3))
                downfactor = spacing(3)./data_info.Spacing(3);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filterz = gaussian_kernel(fsz, sigma);
                filterz = filterz/sum(filterz);
                datai = padarray(datai, [0 0 length(filterz)], 'replicate');
                datai = conv3f(datai, single(permute(filterz, [3 2 1])));
                datai = datai(:,:,length(filterz)+1:end-length(filterz));
            end
            
            lastpt = orig + (imsize-1).*spacing./data_info.Spacing;
            datai = resampler3(datai,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)),0);
            if (i==1)
                data_new = zeros([3,size(datai)],'single');
            end
            data_new(i,:,:,:)=datai;
        end
        
    else % Images...
        if(spacing(1)>data_info.Spacing(1))
            downfactor = spacing(1)./data_info.Spacing(1);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filterx = gaussian_kernel(fsz, sigma);
            filterx = filterx/sum(filterx);
            data = padarray(data, [length(filterx) 0 0], 'replicate');
            data = conv3f(data, single(filterx));
            data = data(length(filterx)+1:end-length(filterx), :, :);
        end
        if(spacing(2)>data_info.Spacing(2))
            downfactor = spacing(2)./data_info.Spacing(2);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filtery = gaussian_kernel(fsz, sigma);
            filtery = filtery'/sum(filtery);
            data = padarray(data, [0 length(filtery) 0], 'replicate');
            data = conv3f(data, single(filtery));
            data = data(:,length(filtery)+1:end-length(filtery), :);
        end
        if(spacing(3)>data_info.Spacing(3))
            downfactor = spacing(3)./data_info.Spacing(3);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filterz = gaussian_kernel(fsz, sigma);
            filterz = filterz/sum(filterz);
            data = padarray(data, [0 0 length(filterz)], 'replicate');
            data = conv3f(data, single(permute(filterz, [3 2 1])));
            data = data(:,:,length(filterz)+1:end-length(filterz));
        end
        % if(same_spacing==3)
        % data = data(orig(1):min(size(data,1),orig(1)+imsize(1)-1),orig(2):min(size(data,2),orig(2)+imsize(2)-1),orig(3):min(size(data,3),orig(3)+imsize(3)-1));
        % else
        lastpt = orig + (imsize-1).*spacing./data_info.Spacing;
        data_new = resampler3(data,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)));
        % [X Y Z] = meshgrid(linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(3)+1,lastpt(3),imsize(3)));
        % X = single(X);
        % Y = single(Y);
        % Z = single(Z);
        % data = interp3(data,X,Y,Z);
    end
end
data_dest = check_existing_names(data_dest,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
handles.mydata.data{length(handles.mydata.data)+1} = data_new;
handles.mydata.info{length(handles.mydata.info)+1} = info;

function f=isafield(data)
s=size(data);
f = (length(s)==4) & (s(1)==3);

