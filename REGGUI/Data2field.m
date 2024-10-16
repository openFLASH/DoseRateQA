%% Data2field
% *Copy* and *resample* a field from the |handles.mydata| into the 
% |handles.fields| structure.
%
% All the fields stored in |handles.fields| have the same pixel spacing 
% (defined in |handles.spacing|) while the fields stored in |handles.mydata| 
% can each have their own spacing defined in |handles.mydata.info|. 
% The function |Data2field| takes care of the resampling when copying a 
% field from one structure to the other. The purpose of the data in 
% |handles.fields| is for display in the main GUI. The purpose of the data 
% in |handles.mydata| is for computation.
%%

%% Syntax
% |handles = Data2field(mydata_name,field_dest,handles)| 

%% Description
% |handles = Data2field(mydata_name,field_dest,handles)| resample and copy 
% the field from |handles.mydata| to the |handles.fields| structure.

%% Input arguments
% |mydata_name| - _STRING_ - Name of the field contained in |handles.mydata| 
% to be copied
%
% |field_dest| - _STRING_ - Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. 
% The following data must be present in the structure:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the field
% * |handles.mydata.data{i}| _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z) of the ith field. The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
% * |handles.mydata.info{i}.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the ith images in |mydata|
% * |handles.mydata.info{i}.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (x,y,z) (in mm) of the voxel (1,1,1) of the ith image ( in |mydata|) in the DICOM coordinate system
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI

%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. 
% The following information is updated  in the destimation image |i|:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the field
%
%% Notes
% * The |handles.mydata| field is resampled to create the |handles.fields|. 
% A round filter with a sigma = 2*old spacing / new spacing is convolved 
% with the field (conv2 or, if Z spacing is not 1mm: conv3 ). Then the new 
% field is interpolated from the convolved field with the required voxel 
% spacing.
%
% * If no fields are defined in the main GUI, the function defines the 
% values for the display properties (size, origin and spacing) using the \
% parameters of the field in |handles.mydata|

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com), J.Orban

function handles = Data2field(mydata_name,field_dest,handles)

Field_load = 1;
myDataField = [];
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},mydata_name))
        myDataField = single(handles.mydata.data{i});
        myInfo = handles.mydata.info{i};
    end
end
if(isempty(myDataField))
    error('Data not found !')
end    
if(strcmp(myInfo.Type,'deformation_field'))
    if(handles.spatialpropsettled)
        for i=1:3
            if(round(myInfo.Spacing(i)*1e3)==round(handles.spacing(i)*1e3))
                myInfo.Spacing(i) = handles.spacing(i);
            end
        end
        orig = (- myInfo.ImagePositionPatient + handles.origin)./myInfo.Spacing +1;
        field_tot = [];
        for n=1:size(myDataField,1)
            myData = squeeze(myDataField(n,:,:,:));
            if(handles.size(3) == 1)
                if(handles.spacing(1)>myInfo.Spacing(1))
                    downfactor = handles.spacing(1)./myInfo.Spacing(1);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filterx = gaussian_kernel(fsz, sigma);
                    filterx = filterx/sum(filterx);
                    myData = conv2(myData, filterx);
                end
                if(handles.spacing(2)>myInfo.Spacing(2))
                    downfactor = handles.spacing(2)./myInfo.Spacing(2);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filtery = gaussian_kernel(fsz, sigma);
                    filtery = filtery'/sum(filtery);
                    myData = conv2(myData, filtery);
                end
                lastpt = orig + (handles.size-1).*handles.spacing./myInfo.Spacing;
                [X Y] = meshgrid(linspace(orig(2)+1,lastpt(2),handles.size(2)),linspace(orig(1)+1,lastpt(1),handles.size(1)));
                X = single(X);
                Y = single(Y);
                field = interp2(myData,X,Y);
            else
                if(handles.spacing(1)>myInfo.Spacing(1))
                    downfactor = handles.spacing(1)./myInfo.Spacing(1);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filterx = gaussian_kernel(fsz, sigma);
                    filterx = filterx/sum(filterx);
                    myData = padarray(myData, [length(filterx) 0 0], 'replicate');
                    myData = conv3f(myData, single(filterx));
                    myData = myData(length(filterx)+1:end-length(filterx), :, :);
                end
                if(handles.spacing(2)>myInfo.Spacing(2))
                    downfactor = handles.spacing(2)./myInfo.Spacing(2);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filtery = gaussian_kernel(fsz, sigma);
                    filtery = filtery'/sum(filtery);
                    myData = padarray(myData, [0 length(filtery) 0], 'replicate');
                    myData = conv3f(myData, single(filtery));
                    myData = myData(:,length(filtery)+1:end-length(filtery), :);
                end
                if(handles.spacing(3)>myInfo.Spacing(3))
                    downfactor = handles.spacing(3)./myInfo.Spacing(3);
                    sigma = downfactor*.4;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    filterz = gaussian_kernel(fsz, sigma);
                    filterz = filterz/sum(filterz);
                    myData = padarray(myData, [0 0 length(filterz)], 'replicate');
                    myData = conv3f(myData, single(permute(filterz, [3 2 1])));
                    myData = myData(:,:,length(filterz)+1:end-length(filterz));
                end
                lastpt = orig + (handles.size-1).*handles.spacing./myInfo.Spacing;
                %         [X Y Z] = meshgrid(linspace(orig(2),lastpt(2),handles.size(2)),linspace(orig(1),lastpt(1),handles.size(1)),linspace(orig(3),lastpt(3),handles.size(3)));
                %         X = single(X);
                %         Y = single(Y);
                %         Z = single(Z);
                %         image = interp3(myData,X,Y,Z);
                field = resampler3(myData,linspace(orig(1),lastpt(1),handles.size(1)),linspace(orig(2),lastpt(2),handles.size(2)),linspace(orig(3),lastpt(3),handles.size(3)),0);
            end
            field(isnan(field))=0;
            if(n==1)
                field_tot = zeros([1 size(field)],'single');
            end
            field_tot(n,:,:,:) = field*myInfo.Spacing(n)/handles.spacing(n);
        end
        info = Create_default_info('deformation_field',handles,[],[],myInfo);
        if(isfield(myInfo,'OriginalHeader'))
            info.OriginalHeader = myInfo.OriginalHeader;
        end
    else
        if(~handles.auto_mode)
            Choice = questdlg('This operation will set workspace properties', ...
                'Choose', ...
                'Continue','Cancel','Cancel');
            if(strcmp(Choice,'Cancel'))
                Field_load = 0;
            end
        end
        if(Field_load)
            field_tot = myDataField;
            info = myInfo;
            disp('Setting spatial properties for this project !')
            handles.size(1) = size(field_tot,2);
            handles.size(2) = size(field_tot,3);
            handles.size(3) = size(field_tot,4);
            handles.spacing = myInfo.Spacing;
            handles.origin = myInfo.ImagePositionPatient;
            handles.spatialpropsettled = 1;
        end
    end
elseif(strcmp(myInfo.Type,'rigid_transform'))
    field_tot = myDataField;
    for j=1:3
        field_tot(1,j) = round(field_tot(1,j)*myInfo.Spacing(j)/handles.spacing(j));
    end
    info = Create_default_info('rigid_transform',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
else
    error('Impossible to convert this data because it is not of type ''deformation_field''');
end
if(Field_load)
    field_dest = check_existing_names(field_dest,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = field_dest;
    handles.fields.data{length(handles.fields.data)+1} = field_tot;
    handles.fields.info{length(handles.fields.info)+1} = info;
end
