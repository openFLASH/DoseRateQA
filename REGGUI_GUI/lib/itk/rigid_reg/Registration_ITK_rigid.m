function res = Registration_ITK_rigid(fixedname,movingname,def_image_name,def_field_name,handles)

% Authors : G.Janssens

if(nargin==0)
    res = 'handles = Registration_ITK_rigid(''fixed_image'',''moving_image'',''deformed_image'',''rigid_transformation'',handles);';
    return
end

res = handles;

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
    rigid_reg_dir = fullfile(fullfile(plugin_dir,'rigid_reg_2D'),'bin');
    reg_dim = 2;
else    
    rigid_reg_dir = fullfile(plugin_dir,'bin');
    reg_dim = 3;
end
cd(rigid_reg_dir)

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

% Export images
moving_min = min(moving(:));
disp('Exporting images in META format...')
save_Image(fixed-moving_min,fixed_info,fullfile(temp_dir,'temp_fixed'),'mhd',1);
save_Image(moving-moving_min,moving_info,fullfile(temp_dir,'temp_moving'),'mhd',1);

try
    if(ispc)
        try
            cd Release
        catch
            cd(current_dir)
            error(['Can''t find release folder in ' rigid_reg_dir]);
        end
        if(reg_dim == 2)
            eval(['!MyRigidRegistration2D "',temp_dir,'\temp_fixed.mhd" "',temp_dir,'\temp_moving.mhd" "',temp_dir,'\temp_result.png" 50 "',temp_dir,'\transform.txt"']);
        else
            eval(['!MyRigidRegistration "',temp_dir,'\temp_fixed.mhd" "',temp_dir,'\temp_moving.mhd" "',temp_dir,'\temp_result.mhd" 5 15 "',temp_dir,'\transform.txt"']);
        end
        cd(rigid_reg_dir)
    elseif(ismac)
        try
            cd macos
        catch
            cd(current_dir)
            error(['Can''t find macos folder in ' rigid_reg_dir]);
        end
        rigid_reg_dir = strrep(rigid_reg_dir,' ','\ ');
        temp_dir_unix = strrep(temp_dir,' ','\ ');
        eval(['!' rigid_reg_dir '/macos/MyRigidRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/temp_result.mhd 5 15 ',temp_dir_unix,'/transform.txt']);
        cd(rigid_reg_dir)
    elseif(isunix)
        try
            cd linux
        catch
            cd(current_dir)
            error(['Can''t find linux folder in ' rigid_reg_dir]);
        end
        rigid_reg_dir = strrep(rigid_reg_dir,' ','\ ');
        temp_dir_unix = strrep(temp_dir,' ','\ ');
        eval(['!' rigid_reg_dir '/linux/MyRigidRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/temp_result.mhd 5 15 ',temp_dir_unix,'/transform.txt']);
        cd(rigid_reg_dir)
    else        
        delete(fullfile(temp_dir,'temp_fixed.mhd'));
        delete(fullfile(temp_dir,'temp_fixed.raw'));
        delete(fullfile(temp_dir,'temp_moving.mhd'));
        delete(fullfile(temp_dir,'temp_moving.raw'));
        error('Not available for your OS. Abort')
    end
    
    if(reg_dim == 2)
        deformed = imread(fullfile(temp_dir,'temp_result.png'));
        deformed = deformed';
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
        deformed = flipdim(temp_mha.dval,2)+moving_min;
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
        moving_info.OriginalHeader.ReferencedSeriesSequence.Item_1.SeriesInstanceUID = moving_info.OriginalHeader.SeriesInstanceUID;
    end
    res.fields.info{length(res.fields.info)+1} = Create_default_info('rigid_transform',handles,[],[],moving_info);
    
    delete(fullfile(temp_dir,'transform.txt'));
    if(reg_dim == 2)
        delete(fullfile(temp_dir,'temp_result.png'));
    else
        delete(fullfile(temp_dir,'temp_result.mhd'));
        delete(fullfile(temp_dir,'temp_result.raw'));
    end
    
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
