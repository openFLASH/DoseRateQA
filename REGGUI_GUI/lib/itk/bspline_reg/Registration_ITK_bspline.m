function res = Registration_ITK_bspline(fixedname,movingname,segname,nlevels,iterations,grid_spacing,samples,elastic_iterations,elastic_anisotropism,def_image_name,def_field_name,visual,handles)

% Authors : G.Janssens

if(nargin==0)
    res = 'handles = Registration_ITK_bspline(''fixed_image'',''moving_image'',''elastic_seg'',''nlevels'',''iterations'',''grid_spacing'',''samples'',''elastic_iterations'',''elastic_anisotropism'',''deformed_image'',''def_field'',''visual'',handles);';
    return
end

current_dir = pwd;
res = handles;

if(isempty(grid_spacing))
    grid_spacing = 10*ones(1,nlevels);
end
if(isempty(samples))
    samples = 100*ones(1,nlevels);
end
if(isempty(iterations))
    iterations = 20*ones(1,nlevels);
end

%Set images
seg = 0.475;
for i=1:length(res.images.name)
    if(strcmp(res.images.name{i},fixedname))
        fixed = res.images.data{i};
        fixed_info = res.images.info{i};
    end
    if(strcmp(res.images.name{i},movingname))
        moving = res.images.data{i};
        moving_info = res.images.info{i};
    end
    if(strcmp(res.images.name{i},segname))
        seg = res.images.data{i};
        seg_info = res.images.info{i};
    end
end
% If binary images, rescale between 0 and 1024;
if(max(max(max(fixed)))<=1)
    fixed = fixed.*1024;
end
if(max(max(max(moving)))<=1)
    moving = moving.*1024;
end
elastic_regularisation = 0;
if(length(elastic_iterations)==nlevels && length(elastic_anisotropism)==nlevels && sum(elastic_iterations))
    elastic_regularisation = 1;
end
if(max(max(max(seg))) > 1)
    disp('Rescaling segmentation image...')
    seg = seg/100; % If segmentation image describe the poisson coeff multiplied by 100...
end
if(max(max(max(seg))) > 0.475)
    disp('Rescaling poisson ratio (elastic behavior) to avoid numerical instabilities... ');
    seg = 0.475*seg/(max(max(max(seg))));
end

if(handles.size(1)==1 || handles.size(2)==1 || handles.size(3)==1)
    error('Not yet implemented in 2D.')
end

% get binary folder
current_dir = pwd;
temp = mfilename('fullpath');
[plugin_dir,~] = fileparts(temp);
bspline_reg_dir = fullfile(plugin_dir,'bin');
cd(bspline_reg_dir)

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


try
    
    tic
    
    for level=nlevels:-1:1
        
        scale = level-1;
        
        fixed_resampled = standard_resampler(fixed, 'linear', 0, 2*scale, 0, size(fixed));
        fixed_resampled_info = fixed_info;
        fixed_resampled_info.Spacing = fixed_info.Spacing.*2^(scale);
        moving_resampled = standard_resampler(moving, 'linear', 0, 2*scale, 0, size(moving));
        
        if(level==nlevels)
            myField = zeros(3,size(fixed_resampled,1),size(fixed_resampled,2),size(fixed_resampled,3),'single');
            deformed = moving_resampled;
        else
            myFieldCell = field_convert(myField,3);
            myFieldCell = standard_resampler(myFieldCell, 'linear', 2*(scale+1), 2*scale, 1, size(fixed));
            deformed = linear_deformation(moving_resampled,' ', myFieldCell, []);
            myField = field_convert(myFieldCell,3);
            clear myFieldCell
        end
        deformed_info = fixed_resampled_info;
        
        % Visualization
        if visual
            animate_plot(fixed_resampled,moving_resampled,deformed,myField,scale); % GRAPHS
            CC = sum(sum(sum( deformed.*fixed_resampled )))/sqrt( sum(sum(sum(deformed.^2)))*sum(sum(sum(fixed_resampled.^2))) );
            disp(['Normalized correlation: ', num2str(CC)])
        end
        
        if(iterations(level))
            
            % Export images
            disp('Exporting images in META format...')
            save_Image(fixed_resampled,fixed_resampled_info,fullfile(temp_dir,'temp_fixed'),'mhd',1);
            save_Image(deformed,deformed_info,fullfile(temp_dir,'temp_moving'),'mhd',1);
            
            try
                if(ispc)
                    try
                        cd Release
                    catch
                        cd(current_dir)
                        error(['Can''t find Release folder in ' bspline_reg_dir]);
                    end
                    try
                        disp('Starting external executable (B-spline registration)')
                        eval(['!MyRegistration "',temp_dir,'\temp_fixed.mhd" "',temp_dir,'\temp_moving.mhd" "',temp_dir,'\def_field.mhd" ' num2str(samples(level)) ' ' num2str(grid_spacing(1,level)) ' ' num2str(iterations(level))]);
                        cd(bspline_reg_dir)
                    catch ME
                        reggui_logger.info(['ERROR during bspline registration. ',ME.message],handles.log_filename);
                        cd(current_dir)
                        rethrow(ME);
                    end
                elseif(ismac)
                    try
                        cd macos
                    catch
                        cd(current_dir)
                        error(['Can''t find macos folder in ' bspline_reg_dir]);
                    end
                    bspline_reg_dir = strrep(bspline_reg_dir,' ','\ ');
                    temp_dir_unix = strrep(temp_dir,' ','\ ');
                    try
                        disp('Starting external executable (B-spline registration)')
                        eval(['!' bspline_reg_dir '/macos/MyRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/def_field.mhd ' num2str(samples(level)) ' ' num2str(grid_spacing(level)) ' ' num2str(iterations(level))]);
                        cd(bspline_reg_dir)
                    catch ME
                        reggui_logger.info(['ERROR during bspline registration. ',ME.message],handles.log_filename);
                        cd(current_dir)
                        rethrow(ME);
                    end
                elseif(isunix)
                    try
                        cd linux
                    catch
                        cd(current_dir)
                        error(['Can''t find linux folder in ' bspline_reg_dir]);
                    end
                    bspline_reg_dir = strrep(bspline_reg_dir,' ','\ ');
                    temp_dir_unix = strrep(temp_dir,' ','\ ');
                    try
                        disp('Starting external executable (B-spline registration)')
                        eval(['!' bspline_reg_dir '/linux/MyRegistration ',temp_dir_unix,'/temp_fixed.mhd ',temp_dir_unix,'/temp_moving.mhd ',temp_dir_unix,'/def_field.mhd ' num2str(samples(level)) ' ' num2str(grid_spacing(level)) ' ' num2str(iterations(level))]);
                        cd(bspline_reg_dir)
                    catch ME
                        reggui_logger.info(['ERROR during bspline registration. ',ME.message],handles.log_filename);
                        cd(current_dir)
                        rethrow(ME);
                    end
                else
                    delete(fullfile(temp_dir,'temp_fixed.mhd'));
                    delete(fullfile(temp_dir,'temp_fixed.raw'));
                    delete(fullfile(temp_dir,'temp_moving.mhd'));
                    delete(fullfile(temp_dir,'temp_moving.raw'));
                    error('Not available for your OS. Abort')
                end
            catch ME
                reggui_logger.info(['ERROR during bspline registration. ',ME.message],handles.log_filename);
                cd(current_dir)
                rethrow(ME);
            end
            
            % Accumulation of the field
            temp_mha = open_meta(temp_dir,'def_field.mhd');
            myInfo.Spacing = temp_mha.dspa;
            myInfo.ImagePositionPatient = temp_mha.zoff;
            myInfo.Type = 'deformation_field';
            myNewField = flipdim(permute(temp_mha.dval,[4 1 2 3]),3);
            clear temp_mha
            
        else % zero iteration
            
            myNewField = zeros(3,size(fixed_resampled,1),size(fixed_resampled,2),size(fixed_resampled,3),'single');
            
        end
        
        myNewField(1,:,:,:) = myNewField(1,:,:,:)./fixed_resampled_info.Spacing(1);
        myNewField(2,:,:,:) = myNewField(2,:,:,:)./fixed_resampled_info.Spacing(2);
        myNewField(3,:,:,:) = myNewField(3,:,:,:)./fixed_resampled_info.Spacing(3);
        myNewFieldCell = field_convert(myNewField,3);
        myField(1,:,:,:) = linear_deformation(squeeze(myField(1,:,:,:)), ' ', myNewFieldCell, []) + myNewFieldCell{2};
        myField(2,:,:,:) = linear_deformation(squeeze(myField(2,:,:,:)), ' ', myNewFieldCell, []) + myNewFieldCell{1};
        myField(3,:,:,:) = linear_deformation(squeeze(myField(3,:,:,:)), ' ', myNewFieldCell, []) + myNewFieldCell{3};
        clear myNewFieldCell
        clear myNewField
        
        % Visualization
        if visual
            myFieldCell = field_convert(myField,3);
            deformed = linear_deformation(moving_resampled,' ', myFieldCell, []);
            animate_plot(fixed_resampled,moving_resampled,deformed,myField,scale); % GRAPHS
            CC = sum(sum(sum( deformed.*fixed_resampled )))/sqrt( sum(sum(sum(deformed.^2)))*sum(sum(sum(fixed_resampled.^2))) );
            disp(['Normalized correlation: ', num2str(CC)])
        end
        
        % ELASTIC REGULARISATION
        if(elastic_regularisation)
            disp('Elastic smoothing...')
            % Rescaling seg image
            if(length(seg)>1)
                seg_resampled = standard_resampler(seg, 'none', 0, 2*scale, 0, size(seg));
            else
                seg_resampled = seg;
            end
            % Second regularisation of the field
            if(size(seg,2)>1 && size(seg,1)>2)
                it = elastic_iterations(level);
                K = elastic_anisotropism(level);
                anisotrop = 2;
            else
                disp('Warning : number of iterations and K fixed !')
                it = 1;
                K = 100;
                anisotrop = 2;
            end
            if(it)
                myField = Elastic_smoother(myField,it,K,anisotrop,fixed_resampled,seg_resampled,3,fixed_resampled_info.Spacing);
            end
        end
        
    end
    
    % Visualization
    if visual
        myFieldCell = field_convert(myField,3);
        deformed = linear_deformation(moving_resampled,' ', myFieldCell, []);
        animate_plot(fixed_resampled,moving_resampled,deformed,myField,scale); % GRAPHS
        CC = sum(sum(sum( deformed.*fixed_resampled )))/sqrt( sum(sum(sum(deformed.^2)))*sum(sum(sum(fixed_resampled.^2))) );
        disp(['Normalized correlation: ', num2str(CC)])
    end
    
    delete(fullfile(temp_dir,'def_field.mhd'));
    delete(fullfile(temp_dir,'temp_fixed.mhd'));
    delete(fullfile(temp_dir,'temp_fixed.raw'));
    delete(fullfile(temp_dir,'temp_moving.mhd'));
    delete(fullfile(temp_dir,'temp_moving.raw'));
    
    t = toc;
    n = size(fixed,1)*size(fixed,2)*size(fixed,3);
    disp(['Processing time was ',num2str(round(t)),' seconds (for registering ',num2str(round(n/1e4)/1e2),' Mega-Voxels images)']);
    
catch ME
    reggui_logger.info(['ERROR during bspline registration. ',ME.message],handles.log_filename);
    cd(current_dir)
    rethrow(ME);
end
def_field_name = check_existing_names(def_field_name,handles.fields.name);
handles.fields.name{length(handles.fields.name)+1} = def_field_name;
handles.fields.data{length(handles.fields.data)+1} = myField;
handles.fields.info{length(handles.fields.info)+1} = myInfo;

handles = Deformation(movingname,def_field_name,def_image_name,handles);

res=handles;

cd(current_dir)

end



function animate_plot(fixed_resampled,moving_resampled,deformed,myField,scale)

figure(1)
hold off

slc = round(size(fixed_resampled, 1)/2);
subplot(1,2,1)
a = squeeze(fixed_resampled(slc,:,:));
b = squeeze(deformed(slc,:,:));
c = squeeze(moving_resampled(slc,:,:));
im = [(a-c),c,a;(a-b),b,a];
imagesc(im'), colormap gray
title('Before deformation     -     After deformation')
axis image
axis xy
axis off

subplot(1,2,2)
myFieldCell = field_convert(myField,3);
imagesc(b'), colormap gray
hold on
subsample = zeros(size(a));
subsample([1:ceil(size(a,1)/15):size(a,1)],[1:ceil(size(a,2)/15):size(a,2)])=1;
quiver((squeeze(myFieldCell{1}(slc,:,:)).*subsample)', (squeeze(myFieldCell{3}(slc,:,:)).*subsample)',0,'r');
title(['Displacement field at scale ' num2str(scale)])
axis image
axis xy
axis off

drawnow

end
