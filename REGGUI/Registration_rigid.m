%% Registration_rigid
% Performs rigid registration of the moving 3D image onto the fixed 3D image using the specified metric.
%
%% Syntax
% |handles = Registration_rigid(fixedname, movingname, def_image_name, def_field_name, moving_type, metric_type, handles)|
%
%
%% Description
% |handles = Registration_rigid(fixedname, movingname, def_image_name, def_field_name, moving_type, metric_type, handles)| Performs rigid registration
%
%
%% Input arguments
% |fixedname| - _STRING_ -  Name of the fixed image contained in |handles.images|.
%
% |movingname| - _STRING_ -  Name of the moving image contained in |handles.images|.
%
% |def_image_name| - _STRING_ -  Name of the image in |handles.images| that will receive the deformed image
%
% |def_field_name| - _STRING_ -  Name of the field in |handles.fields| that will receive the deformation field
%
% |moving_type| - _INTEGER_ -  Defines where the moving image is stored:
%
% % |moving_type = 1| : the moving image is stored in handles.images
% % |moving_type = 3| : the moving image is stored in handles.mydata
%
% |metric_type| - _STRING_ -  Define the metric to use to register the images
%
% * 'ssd' : Sum of square differences
% * 'mi' : Mutual Information
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images| - _STRUCTURE_ - The fixed and (optional, used only if |moving_type = 1|) mobile images
% * |handles.mydata| - _STRUCTURE_ - The mobile image (optional, used only if |moving_type = 3|)
% * |handles.spacing| - _VECTOR of SCALAR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.auto_mode| - _INTEGER_ - 0 = Display dialog box for interaction with user. 1 = No dialog box. The image is resampled automatically.
%
%
%% Output arguments
%
% |handles| - _TYPE_ - description for 1st syntax
%
% * |handles.images|- _STRUCTURE_ - The deformed image with name |def_image_name|
% * |handles.fields|- _STRUCTURE_ - The deformation field with name |def_field_name|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Registration_rigid(fixedname, movingname, def_image_name, def_field_name, moving_type, metric_type, handles)

%Set images
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},fixedname))
        fixed = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},movingname) && moving_type==1)
        moving = handles.images.data{i};
        moving_info = handles.images.info{i};
    end
end

if(moving_type==3)
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},movingname))
            moving = single(handles.mydata.data{i});
            moving_info = handles.mydata.info{i};
        end
    end
end

spacing = moving_info.Spacing;

if(sum(round(spacing*1e4)~=round(handles.spacing*1e4)))
    if(~handles.auto_mode)

        SetSpacing = questdlg('Warning: Spacings of the 2 images are not the same.', ...
            'Spacing', ...
            'Don''t worry about spacings! I know what I''m doing', 'Interpolate moving image first', 'Cancel', 'Interpolate moving image first');
        if(strcmp(SetSpacing,'Interpolate moving image first'))
            imsize = round(size(moving)'.*spacing./handles.spacing);
            handles = Data2data(movingname,[1;1;1],imsize,handles.spacing,strcat(movingname,'_resampled'),handles);
            movingname = strcat(movingname,'_resampled');
            for i=1:length(handles.mydata.name)
                if(strcmp(handles.mydata.name{i},movingname))
                    moving = single(handles.mydata.data{i});
                    moving_info = handles.mydata.info{i};
                end
            end
        end
        if(strcmp(SetSpacing,'Cancel'))
            return;
        end
    else
        disp('Warning: Spacings of the 2 images are not the same. Interpolate moving image first.');
        imsize = round(size(moving)'.*spacing./handles.spacing);
        handles = Data2data(movingname,[1;1;1],imsize,handles.spacing,strcat(movingname,'_resampled'),handles);
        movingname = strcat(movingname,'_resampled');
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},movingname))
                moving = single(handles.mydata.data{i});
                moving_info = handles.mydata.info{i};
            end
        end
    end
end

deformed = zeros(size(fixed),'single');

%Registration
if(ndims(fixed)==3 && ndims(moving)==3)

    max_scale = floor(log2(min([size(fixed),size(moving)])/8))*2;
    min_scale = 0;
    scale = max_scale;

    translations = zeros(9.^3,3);
    for i=1:9
        for j=1:9
            for k=1:9
                translations((i-1)*81+(j-1)*9+k,:) = [i-5 j-5 k-5];
            end
        end
    end

    metrics = zeros(size(translations,1),1);
    res_translation = round((size(fixed)-size(moving))/2/2^(scale/2+1));


    while(scale >= min_scale)

        res_translation = res_translation*2;

        A = standard_resampler(fixed,'linear',0,scale,0,size(fixed));
        B = standard_resampler(moving,'linear',0,scale,0,size(moving));

        if(strcmp(metric_type,'ssd'))
            current_metric = mySSD(res_translation,A,B);
            for i=1:length(metrics)
                metrics(i) = mySSD(res_translation + translations(i,:),A,B);
            end
        elseif(strcmp(metric_type,'mi'))
            current_metric = -MI2(res_translation,A,B,'Normalized');
            for i=1:length(metrics)
                metrics(i) = -MI2(res_translation + translations(i,:),A,B,'Normalized');
            end
        else
            disp('Metric not implemented')
        end

        [min_metric,I] = min(metrics);
        res_translation = res_translation + translations(I,:);
        disp(['Scale: ', num2str(scale/2), ' : metric ',num2str(current_metric),' reduced to ',num2str(min_metric), ' ---> translation vector = ' num2str(-res_translation*2^(scale/2))]);
        scale = scale -2;

    end
    
    res_translation = -res_translation;

    deformed = myDef(res_translation,deformed,moving);

else
    error('Not yet implemented in 2D !')
end

total_translation = res_translation.*handles.spacing' - (handles.origin - moving_info.ImagePositionPatient)';

disp(['Translation in voxels: ',num2str(res_translation)]);
disp(['Translation in mm: ',num2str(total_translation)]);

def_image_name = check_existing_names(def_image_name,handles.images.name);
handles.images.name{length(handles.images.name)+1} = def_image_name;
handles.images.data{length(handles.images.data)+1} = deformed;
info = Create_default_info('image',handles);
if(isfield(moving_info,'OriginalHeader'))
    info.OriginalHeader = moving_info.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;

def_field_name = check_existing_names(def_field_name,handles.fields.name);
handles.fields.name{length(handles.fields.name)+1} = def_field_name;
handles.fields.data{length(handles.fields.data)+1} = [res_translation;total_translation;eye(3,3)];
if(isfield(moving_info,'OriginalHeader'))
    moving_info.OriginalHeader.ReferencedSeriesSequence.Item_1.SeriesInstanceUID = moving_info.OriginalHeader.SeriesInstanceUID;
end
handles.fields.info{length(handles.fields.info)+1} = Create_default_info('rigid_transform',handles,[],[],moving_info);

end

%------------------------------

function SSD = mySSD(x,A,B)
x = round(x);
D = A(1+max(0,x(1)):min(size(A,1),size(B,1)+x(1)),1+max(0,x(2)):min(size(A,2),size(B,2)+x(2)),1+max(0,x(3)):min(size(A,3),size(B,3)+x(3)))-...
    B(1+max(0,-x(1)):min(size(B,1),size(A,1)-x(1)),1+max(0,-x(2)):min(size(B,2),size(A,2)-x(2)),1+max(0,-x(3)):min(size(B,3),size(A,3)-x(3)));
SSD = sum(sum(sum(D.^2)))/(size(D,1)*size(D,2)*size(D,3));
if(isnan(SSD))
    SSD = sum(sum(sum(D.^2)));
end
end

%------------------------------

function h=joint_h(image_1,image_2)
% function h=joint_h(image_1,image_2)
%
% takes a pair of images of equal size and returns the 3d joint histogram.
% used for MI calculation
%
% based on a script written by http://www.flash.net/~strider2/matlab.htm

image_1 = image_1 - min(image_1);
image_2 = image_2 - min(image_2);

rows=size(image_1,1);
cols=size(image_1,2);
depth=size(image_1,3);

N=256;
m1 = max(max(max(image_1)));
m2 = max(max(max(image_2)));

image_1 = round(image_1*(N-1)/m1);
image_2 = round(image_2*(N-1)/m2);

h=zeros(N,N);

for i=1:rows;    %  col
    for j=1:cols;   %   rows
        for k=1:depth;
            h(image_1(i,j,k)+1,image_2(i,j,k)+1)= h(image_1(i,j,k)+1,image_2(i,j,k)+1)+1;
        end
    end
end
end

%------------------------------


function h=MI2(x,A,B,method)
% function h=MI2(image_1,image_2,method)
%
% Takes a pair of images and returns the mutual information Ixy using joint entropy function JOINT_H.m
%
% written by http://www.flash.net/~strider2/matlab.htm
x = round(x);
image_1 = A(1+max(0,x(1)):min(size(A,1),size(B,1)+x(1)),1+max(0,x(2)):min(size(A,2),size(B,2)+x(2)),1+max(0,x(3)):min(size(A,3),size(B,3)+x(3)));
image_2 = B(1+max(0,-x(1)):min(size(B,1),size(A,1)-x(1)),1+max(0,-x(2)):min(size(B,2),size(A,2)-x(2)),1+max(0,-x(3)):min(size(B,3),size(A,3)-x(3)));
image_1(find(isnan(image_1))) = 0;
image_2(find(isnan(image_2))) = 0;

a=joint_h(image_1,image_2); % calculating joint histogram for two images
[r,c] = size(a);
b= a./(r*c); % normalized joint histogram
y_marg=sum(b); %sum of the rows of normalized joint histogram
x_marg=sum(b,2);%sum of columns of normalized joint histogran

Hy=0;
for i=1:c;    %  col
    if( y_marg(i)==0 )
        %do nothing
    else
        Hy = Hy + -(y_marg(i)*(log2(y_marg(i)))); %marginal entropy for image 1
    end
end

Hx=0;
for i=1:r;    %rows
    if( x_marg(i)==0 )
        %do nothing
    else
        Hx = Hx + -(x_marg(i)*(log2(x_marg(i)))); %marginal entropy for image 2
    end
end
h_xy = -sum(sum(b.*(log2(b+(b==0))))); % joint entropy

if method=='Normalized';
    h = (Hx + Hy)/h_xy;% Mutual information
else
    h = Hx + Hy - h_xy;% Mutual information
end
end


%------------------------------

function A = myDef(x,A,B)
x = -round(x);
A(1+max(0,x(1)):min(size(A,1),size(B,1)+x(1)),1+max(0,x(2)):min(size(A,2),size(B,2)+x(2)),1+max(0,x(3)):min(size(A,3),size(B,3)+x(3)))=...
    B(1+max(0,-x(1)):min(size(B,1),size(A,1)-x(1)),1+max(0,-x(2)):min(size(B,2),size(A,2)-x(2)),1+max(0,-x(3)):min(size(B,3),size(A,3)-x(3)));
end

