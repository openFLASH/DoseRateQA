function res = Registration_ITK_affine(fixedname,movingname,def_image_name,def_field_name,handles)

% Authors : G.Janssens

if(nargin==0)
    res = 'handles = Registration_ITK_affine(''fixed_image'',''moving_image'',''deformed_image'',''affine_transformation'',handles);';
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
affine_reg_dir = fullfile(plugin_dir,'bin');
cd(affine_reg_dir)

% get temp data folder
[~,reggui_config_dir] = get_reggui_path;
temp_dir = fullfile(reggui_config_dir,'temp');
if(not(isdir(temp_dir)))
    try
        mkdir(temp_dir)
    catch
        disp('Could not create temp dir. Use bin dir instead.')
        temp_dir = affine_reg_dir;
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
            error(['Can''t find release folder in ' affine_reg_dir]);
        end
        eval(['!MyAffineRegistration "',temp_dir,'\temp_fixed.mhd" "',temp_dir,'\temp_moving.mhd" "',temp_dir,'\temp_result.mhd" 5 15" "',temp_dir,'\transform.txt"']);
        cd(affine_reg_dir)
    elseif(ismac)
        try
            cd macos
        catch
            cd(current_dir)
            error(['Can''t find macos folder in ' affine_reg_dir]);
        end
        affine_reg_dir = strrep(affine_reg_dir,' ','\ ');
        temp_dir_unix = strrep(temp_dir,' ','\ ');
        eval(['!' affine_reg_dir '/macos/MyAffineRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/temp_result.mhd 5 15 ',temp_dir_unix,'/transform.txt']);
        cd(affine_reg_dir)
    elseif(isunix)
        try
            cd linux
        catch
            cd(current_dir)
            error(['Can''t find linux folder in ' affine_reg_dir]);
        end
        affine_reg_dir = strrep(affine_reg_dir,' ','\ ');
        temp_dir_unix = strrep(temp_dir,' ','\ ');
        eval(['!' affine_reg_dir '/linux/MyAffineRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/temp_result.mhd 5 15 ',temp_dir_unix,'/transform.txt']);
        cd(affine_reg_dir)
    else        
        delete(fullfile(temp_dir,'temp_fixed.mhd'));
        delete(fullfile(temp_dir,'temp_fixed.raw'));
        delete(fullfile(temp_dir,'temp_moving.mhd'));
        delete(fullfile(temp_dir,'temp_moving.raw'));
        error('Not available for your OS. Abort')
    end
    
    temp_mha = open_meta(temp_dir,'temp_result.mhd');
    deformed = flipdim(temp_mha.dval,2);
    
    fid = fopen('transform.txt','r');
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
    
    res_translation = (total_translation - (handles.origin - moving_info.ImagePositionPatient)')./handles.spacing';
    %     total_translation = res_translation.*handles.spacing' + (handles.origin - moving_info.ImagePositionPatient)';
    myTransformation = [res_translation;total_translation;rotation];
    
    cd(res.path)
    
    def_image_name = check_existing_names(def_image_name,res.images.name);
    res.images.name{length(res.images.name)+1} = def_image_name;
    res.images.data{length(res.images.data)+1} = deformed;
    info = Create_default_info('image',res);
    if(isfield(moving_info,'OriginalHeader'))
        info.OriginalHeader = moving_info.OriginalHeader;
    end
    res.images.info{length(res.images.info)+1} = info;
    
    def_field_name = check_existing_names(def_field_name,res.fields.name);
    res.fields.name{length(res.fields.name)+1} = def_field_name;
    res.fields.data{length(res.fields.data)+1} = myTransformation;
    res.fields.info{length(res.fields.info)+1} = Create_default_info('rigid_transform',res);
    
catch ME
    reggui_logger.info(['ERROR occured during registration. You might need to re-compile the application. ',ME.message],handles.log_filename);
    cd(current_dir)
    rethrow(ME);
end

delete(fullfile(temp_dir,'transform.txt'));
delete(fullfile(temp_dir,'temp_fixed.mhd'));
delete(fullfile(temp_dir,'temp_fixed.raw'));
delete(fullfile(temp_dir,'temp_moving.mhd'));
delete(fullfile(temp_dir,'temp_moving.raw'));
delete(fullfile(temp_dir,'temp_result.mhd'));
delete(fullfile(temp_dir,'temp_result.raw'));

cd(current_dir)
