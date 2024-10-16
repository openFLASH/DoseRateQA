%% Registration_ITK_rigid_multimodal
% Computes the transform for a rigid registration between a fixed image and a mobile image. The computations are carried out using the Mattes Mutual rigid registration algorithm in ITK.
%
%% Syntax
%
% |res = Registration_ITK_rigid_multimodal()|
%
% |res = Registration_ITK_rigid_multimodal(fixedname,movingname,def_image_name,def_field_name,handles)| 
%
%
%% Description
%
% |res = Registration_ITK_rigid_multimodal()| Returns a string defining the call to the function withthe defaul parameters.
%
% |res = Registration_ITK_rigid_multimodal(fixedname,movingname,def_image_name,def_field_name,handles)| Computes the rigid registration between mobile and fixed image.
%
%
%% Input arguments
%
% |fixedname| - _STRING_ -  Name of the fixed image contained in |handles.images|. The image can be 2D or 3D.
%
% |movingname| - _STRING_ -  Name of the moving image contained either in |handles.images| or, if absent there, in |handles.mydata|
%
% |def_image_name| -  _STRING_ - Name of the image where the result will be copied in  |res.images|.
%
% |def_field_name| -  _STRING_ -  Name of the field field where the transform will be copied in  |res.fields|.
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (x,y,z) (in mm) of the voxel (1,1,1) of the image in the DICOM coordinate system
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.images| - _STRUCTURE_ - Data structure containing the images displayed in GUI
% * |handles.mydata| - _STRUCTURE_ - Data structure containing the images at original format
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  REGGUI data structure (|handles|) with the updated data. The following elements are updated:
%
% * res.images : The translated image is copied into the image with name |def_image_name|
%
% * res.fields: the deformation matrix is stored in a field with name |def_field_name|
% * ----res.fields.name{} = deformation field name 
% * ----res.fields.data{} = transformation matrix T: T(1,:)= translation; T(2-4,:) = 3x3 rotation matrix
% * ----res.fields.info{} = default field information for rigid registration fields
%
%% Notes
%
% * If the modality (images.info.OriginalHeader.Modality) of either the moving or the fixed images is 'CT', then the intensities of both moving and fixed images are made positive by adding 1024 to all voxels and setting the remaining negative voxels equal to 0.
%
% * The computations are carried out by a compiled executable compiled using the Mattes Mutual rigid registration algorithm in ITK. The executable is stored in the folder ./reggui/itkplugins/Registration_ITK_rigid_multimodal/bin/XX where XX is a sub-folder depending on the operating system. The data is passed from Matlab to the ITK executable via the file system.
%
% * Before returning, the function changes the path to |handles.path|
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)
%
%TODO Improve directory management. Directly move to the bin directory by building the directory path from the REGGUI path defined in handles, so as not to deal with all the intermediate directory cases
%TODO switch-case for directory change: the "switch" string contains only 6 characters but some "case" strings contain more.

function res = Registration_ITK_rigid_multimodal(fixedname,movingname,def_image_name,def_field_name,handles)


if(nargin==0)
    res = 'handles = Registration_ITK_rigid_multimodal(''fixed_image'',''moving_image'',''deformed_image'',''rigid_transformation'',handles);';
    return
end

res = handles;

% get path
current_dir = pwd;
temp = mfilename('fullpath');
[plugin_dir,~] = fileparts(temp);

%Set images
for i=1:length(res.mydata.name)
    if(strcmp(res.mydata.name{i},movingname))
        moving = single(res.mydata.data{i});
        moving_info = res.mydata.info{i};
    end
end
for i=1:length(res.images.name)
    if(strcmp(res.images.name{i},fixedname))
        fixed = res.images.data{i};
        fixed_info = res.images.info{i};
    end
    if(strcmp(res.images.name{i},movingname))
        moving = res.images.data{i};
        moving_info = res.images.info{i};
    end
end

% get binary folder
current_dir = pwd;
temp = mfilename('fullpath');
[plugin_dir,~] = fileparts(temp);
if(handles.size(1)==1 || handles.size(2)==1 || handles.size(3)==1)
    rigid_mm_reg_dir = fullfile(fullfile(plugin_dir,'rigid_mm_reg_2D'),'bin');
    reg_dim = 2;
else    
    rigid_mm_reg_dir = fullfile(plugin_dir,'bin');
    reg_dim = 3;
end
cd(rigid_mm_reg_dir)

% get temp data folder
[~,reggui_config_dir] = get_reggui_path;
temp_dir = fullfile(reggui_config_dir,'temp');
if(not(isdir(temp_dir)))
    try
        mkdir(temp_dir)
    catch
        disp('Could not create temp dir. Use bin dir instead.')
        temp_dir = rigid_reg_dir;
    end
end

% If CT images, set to positive intensities
CT_correction = 0;
if(isfield(fixed_info,'OriginalHeader'))
    if(isfield(fixed_info.OriginalHeader,'Modality'))
        if(strcmp(fixed_info.OriginalHeader.Modality,'CT'))
            CT_correction = 1;
        end
    end
elseif(isfield(moving_info,'OriginalHeader'))
    if(isfield(moving_info.OriginalHeader,'Modality'))
        if(strcmp(moving_info.OriginalHeader.Modality,'CT'))
            CT_correction = 1;
        end
    end
end
if(CT_correction)
    fixed = fixed+1024;fixed(fixed<0)=0;
    moving = moving+1024;moving(moving<0)=0;
end

% Rescale image intensities for itk
moving_offset = 0;
moving_rescaling = 1;
if(reg_dim == 2)
    fixed = (fixed-min(fixed(:)))/(max(fixed(:))-min(fixed(:)))*255;
    moving_rescaling = 1/(max(moving(:))-min(moving(:)))*255;
    moving_offset = min(moving(:));
    moving = (moving-moving_offset)*moving_rescaling;    
else
    if(max(abs(fixed(:)))<255)
        fixed_rescaling = 4096/max(abs(fixed(:)));
        fixed = fixed.*fixed_rescaling;
    end
    moving_rescaling = 1;
    if(max(abs(moving(:)))<255)
        moving_rescaling = 4096/max(abs(moving(:)));
        moving = moving.*moving_rescaling;
    end
end

% Export images
disp('Exporting images in META format...')
save_Image(fixed,fixed_info,fullfile(temp_dir,'temp_fixed'),'mhd',1);
save_Image(moving,moving_info,fullfile(temp_dir,'temp_moving'),'mhd',1);

try
    if(ispc)
        try
            cd Release
        catch
            cd(current_dir)
            error(['Can''t find release folder in ' rigid_mm_reg_dir]);
        end
        if(reg_dim == 2)
            eval(['!MyRigidMMRegistration2D "',temp_dir,'\temp_fixed.mhd" "',temp_dir,'\temp_moving.mhd" "',temp_dir,'\temp_result.mhd" 50 "',temp_dir,'\transform.txt"']);
        else
            eval(['!MyRigidMMRegistration "',temp_dir,'\temp_fixed.mhd" "',temp_dir,'\temp_moving.mhd" "',temp_dir,'\temp_result.mhd" 5 15 "',temp_dir,'\transform.txt"']);
        end
        cd(rigid_mm_reg_dir)
    elseif(ismac)
        try
            cd macos
        catch
            cd(current_dir)
            error(['Can''t find macos folder in ' rigid_mm_reg_dir]);
        end
        rigid_mm_reg_dir = strrep(rigid_mm_reg_dir,' ','\ ');
        temp_dir_unix = strrep(temp_dir,' ','\ ');
        eval(['!',rigid_mm_reg_dir,'/macos/MyRigidMMRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/temp_result.mhd 5 15 ',temp_dir_unix,'/transform.txt']);
        cd(rigid_mm_reg_dir)
    elseif(isunix)
        try
            cd linux
        catch
            cd(current_dir)
            error(['Can''t find linux folder in ' rigid_mm_reg_dir]);
        end
        rigid_mm_reg_dir = strrep(rigid_mm_reg_dir,' ','\ ');
        temp_dir_unix = strrep(temp_dir,' ','\ ');
        eval(['!',rigid_mm_reg_dir,'/linux/MyRigidMMRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/temp_result.mhd 5 15 ',temp_dir_unix,'/transform.txt']);
        cd(rigid_mm_reg_dir)
    else        
        delete(fullfile(temp_dir,'temp_fixed.mhd'));
        delete(fullfile(temp_dir,'temp_fixed.raw'));
        delete(fullfile(temp_dir,'temp_moving.mhd'));
        delete(fullfile(temp_dir,'temp_moving.raw'));
        error('Not available for your OS. Abort')
    end
    
    if(reg_dim == 2)       
        temp_mha = open_meta(temp_dir,'temp_result.mhd');
        deformed = flipdim(temp_mha.dval,2);        
        fid = fopen(fullfile(temp_dir,'transform.txt'),'r');
        total_translation = [];
        rotation = [];
        for i=1:20
            current_line = fgetl(fid);
            if(strcmp(current_line,'Translation'))
                eval(['total_translation = ' fgetl(fid) ';']);
                total_translation(3) = 0;
            end
            if(strcmp(current_line,'Rotation'))
                eval(['rotation(1,:) = [' fgetl(fid) '];']);
                eval(['rotation(2,:) = [' fgetl(fid) '];']);
                rotation(1,3) = 0;
                rotation(2,3) = 0;
                rotation(3,:) = [0 0 1];
            end
        end
        fclose(fid);
    else
        temp_mha = open_meta(temp_dir,'temp_result.mhd');
        deformed = flipdim(temp_mha.dval,2);
        fid = fopen(fullfile(temp_dir,'transform.txt'),'r');
        total_translation = [];
        rotation = [];
        for i=1:20
            current_line = fgetl(fid);
            if(strcmp(current_line,'Translation'))
                eval(['total_translation = ' fgetl(fid) ';']);
            end
            if(strcmp(current_line,'Rotation'))
                eval(['rotation(1,:) = [' fgetl(fid) '];']);
                eval(['rotation(2,:) = [' fgetl(fid) '];']);
                eval(['rotation(3,:) = [' fgetl(fid) '];']);
            end
        end
        fclose(fid);
    end
    
    if(CT_correction)
        deformed = deformed-1024;
    end
    
    res_translation = (total_translation - (handles.origin - moving_info.ImagePositionPatient)')./handles.spacing';
    %     total_translation = res_translation.*handles.spacing' + (handles.origin - moving_info.ImagePositionPatient)';
    myTransformation = [res_translation;total_translation;rotation];
    
    cd(res.path)
    
    if(not(moving_rescaling==1))
        deformed = deformed./moving_rescaling;
    end
    if(abs(moving_offset)>0)
       deformed = deformed + moving_offset;
    end
    
    def_image_name = check_existing_names(def_image_name,res.images.name);
    res.images.name{length(res.images.name)+1} = def_image_name;
    res.images.data{length(res.images.data)+1} = single(deformed);
    info = Create_default_info('image',res);
    if(isfield(moving_info,'OriginalHeader'))
        info.OriginalHeader = moving_info.OriginalHeader;
    end
    res.images.info{length(res.images.info)+1} = info;
    
    def_field_name = check_existing_names(def_field_name,res.fields.name);
    res.fields.name{length(res.fields.name)+1} = def_field_name;
    res.fields.data{length(res.fields.data)+1} = myTransformation;
    if(isfield(moving_info,'OriginalHeader'))
        if(isfield(moving_info.OriginalHeader,'SeriesInstanceUID'))
            moving_info.OriginalHeader.ReferencedSeriesSequence.Item_1.SeriesInstanceUID = moving_info.OriginalHeader.SeriesInstanceUID;
        end
    end
    res.fields.info{length(res.fields.info)+1} = Create_default_info('rigid_transform',handles,[],[],moving_info);
    
    delete(fullfile(temp_dir,'transform.txt'));
    delete(fullfile(temp_dir,'temp_result.mhd'));
    delete(fullfile(temp_dir,'temp_result.raw'));
    
catch ME
    reggui_logger.info(['ERROR occured during registration. You might need to re-compile the application. ',ME.message],handles.log_filename);
    cd(current_dir)
    rethrow(ME);
end

delete(fullfile(temp_dir,'temp_fixed.mhd'));
delete(fullfile(temp_dir,'temp_fixed.raw'));
delete(fullfile(temp_dir,'temp_moving.mhd'));
delete(fullfile(temp_dir,'temp_moving.raw'));

cd(current_dir)
