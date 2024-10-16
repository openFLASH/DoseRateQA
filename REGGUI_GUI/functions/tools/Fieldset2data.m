%% Fieldset2data
% *Resample* a set of displacement fields from |handles.mydata| into |handles.mydata| internal structure. All the deformations field in the set are resampled.
%
%% Syntax
% |handles = Fieldset2data(fieldset_name,orig,imsize,spacing,data_dest,handles)|
%
%
%% Description
% |handles = Fieldset2data(fieldset_name,orig,imsize,spacing,data_dest,handles)| describes the function
%
%
%% Input arguments
% |field_name| - _STRING_ -  Name of the field  to be copied, contained in |handles.mydata|.
%
% |orig| - _VECTOR of INTEGER_ - (If empty, defaul = [1;1;1]) Coordinate 
% (x,y,z) (in |pixels| of the original |fieldset_name| coordinates) of the
% first voxel (first apex) of the sub-volume to be copied.
%
% |imsize| - _VECTOR of DOUBLE_ - Dimensions (dx,dy,dz) of the edges of the
% paralellipiped to be copied |pixels| of the resulting |handles.mydata| 
% coordinates. If empty, the paralellipied extend to the last voxel of 
% |fieldset_name|.
%
% |spacing| - _VECTOR of DOUBLE_ - Size of the voxels of |handles.mydata| 
% in |mm|. If empty, then it is the size |handles.spacing| of the input image
%
% |data_dest| - _STRING_ - Name of the new image created in |handles.mydata| 
% with the sub-volume
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the field set (contained in ith data structure)
% * |handles.mydata.data{i}| - _CELL of SCALAR MATRIX_ - |data{i}{j}(x,y,z)|  _MATRIX of SCALAR_ The ith data element is a field set. The jth element oif the set is a defomation field = |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.mydata.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. 
% The following information is updated in the destimation image |i|:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| - _CELL of SCALAR MATRIX_ - |data{i}{j}(x,y,z)|  _MATRIX of SCALAR_ The ith data element is a field set. The jth element oif the set is a defomation field = |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.mydata.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field. Copied from input data.
%
%% Contributors
% Authors : G.Janssens, M.Taquet (open.reggui@gmail.com)


function handles = Fieldset2data(fieldset_name,orig,imsize,spacing,data_dest,handles)

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},fieldset_name))
        fieldset = handles.mydata.data{i};
        fieldset_info = handles.mydata.info{i};
        export = fieldset_info.export;
        if (export)
            fieldset = fieldset.outStruct.data;
        else
            fieldset = fieldset{1};
        end
    end
end
if(isempty(orig))
    orig = [1;1;1];
end
if(isempty(imsize))
        imsize = [size(fieldset{1},2);size(fieldset{1},3);size(fieldset{1},4)];
end
if(isempty(spacing))
    spacing = handles.spacing;
end
% same_spacing = 0;
% for i=1:3
%     if(round(spacing(i)*1e3)==round(handles.spacing(i)*1e3))
%         spacing(i) = handles.spacing(i);
%         same_spacing = same_spacing+1;
%     end
% end
info = Create_default_info('deformation_field',handles);
if(isfield(fieldset_info,'OriginalHeader'))
    info.OriginalHeader = fieldset_info.OriginalHeader;
end
info.Spacing = spacing;
try
    info.ImagePositionPatient = fieldset_info.ImagePositionPatient + (orig-1).*fieldset_info.Spacing;
catch
    error('Error: Image info not found !')
end

field_sub = cell(1,length(fieldset));
for f=1:length(fieldset)
    fprintf('Field %ld/%ld is being resampled...\n',f,length(fieldset));
    field = fieldset{f};
    for n=1:size(field,1)
        image = squeeze(field(n,:,:,:));
        if(handles.size(3) == 1)
            if(spacing(1)>handles.spacing(1))
                downfactor = spacing(1)./handles.spacing(1);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filterx = gaussian_kernel(fsz, sigma);
                filterx = filterx/sum(filterx);
                image = conv2(image, filterx);
            end
            if(spacing(2)>handles.spacing(2))
                downfactor = spacing(2)./handles.spacing(2);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filtery = gaussian_kernel(fsz, sigma);
                filtery = filtery'/sum(filtery);
                image = conv2(image, filtery);
            end
            %         if(same_spacing==3)
            %             data = image(orig(1):orig(1)+imsize(1)-1,orig(2):orig(2)+imsize(2)-1);
            %         else
            lastpt = orig + (imsize-1).*spacing./handles.spacing;
            [X Y] = meshgrid(linspace(orig(2)+1,lastpt(2),imsize(2)),linspace(orig(1)+1,lastpt(1),imsize(1)));
            X = single(X);
            Y = single(Y);
            data = interp2(image,X,Y);
            %         end
        else
            if(spacing(1)>handles.spacing(1))
                downfactor = spacing(1)./handles.spacing(1);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filterx = gaussian_kernel(fsz, sigma);
                filterx = filterx/sum(filterx);
                image = padarray(image, [length(filterx) 0 0], 'replicate');
                image = conv3f(image, single(filterx));
                image = image(length(filterx)+1:end-length(filterx), :, :);
            end
            if(spacing(2)>handles.spacing(2))
                downfactor = spacing(2)./handles.spacing(2);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filtery = gaussian_kernel(fsz, sigma);
                filtery = filtery'/sum(filtery);
                image = padarray(image, [0 length(filtery) 0], 'replicate');
                image = conv3f(image, single(filtery));
                image = image(:,length(filtery)+1:end-length(filtery), :);
            end
            if(spacing(3)>handles.spacing(3))
                downfactor = spacing(3)./handles.spacing(3);
                sigma = downfactor*.4;
                fsz = round(sigma * 5);
                fsz = fsz + (1-mod(fsz,2));
                filterz = gaussian_kernel(fsz, sigma);
                filterz = filterz/sum(filterz);
                image = padarray(image, [0 0 length(filterz)], 'replicate');
                image = conv3f(image, single(permute(filterz, [3 2 1])));
                image = image(:,:,length(filterz)+1:end-length(filterz));
            end
            %         if(same_spacing==3)
            %             data = image(orig(1):orig(1)+imsize(1)-1,orig(2):orig(2)+imsize(2)-1,orig(3):orig(3)+imsize(3)-1);
            %         else
            lastpt = orig + (imsize-1).*spacing./handles.spacing;
            %         [X Y Z] = meshgrid(linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(3)+1,lastpt(3),imsize(3)));
            %                 X = single(X);
            %         Y = single(Y);
            %         Z = single(Z);
            %         data = interp3(image,X,Y,Z);
            data = resampler3(image,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)));
            %         end
        end
        if(n==1)
            data_tot = zeros([1 size(data)],'single');
        end
        data_tot(n,:,:,:) = data/spacing(n)*handles.spacing(n);
    end
    field_sub{f}=data_tot;
end
    
data_dest = check_existing_names(data_dest,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest;
handles.mydata.data{length(handles.mydata.data)+1} = field_sub;
handles.mydata.info{length(handles.mydata.info)+1} = info;
end
