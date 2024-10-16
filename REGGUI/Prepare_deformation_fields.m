function handles = Prepare_deformation_fields( handles, SimuParam, log_domain )


FieldDir = fullfile(handles.dataPath, 'Reggui_registration_data');
if(not(exist(FieldDir, 'dir')))
    mkdir(FieldDir);
end
MC2_FieldDir = fullfile(SimuParam.Folder, 'Fields');
mkdir(MC2_FieldDir)


if(SimuParam.register == 1)
    handles_tmp = handles;
    
    handles_tmp = Remove_all_fields(handles_tmp);
    CT_list = [SimuParam.CT_phases SimuParam.ref_4D];
    for i=length(handles_tmp.images.name):-1:2
        if(sum(strcmp(handles_tmp.images.name{i}, CT_list)) == 0)
            handles_tmp = Remove_image(handles_tmp.images.name{i}, handles_tmp);
        end
    end
    handles_tmp = Resample_all(handles_tmp,[],[],[3;3;3]);
    
    for p=1:length(SimuParam.CT_phases)
        Phase_name = SimuParam.CT_phases{p};
        
        handles_tmp = Registration_modules(1,{SimuParam.ref_4D},{Phase_name},'none',8,[2 5 10 10 10 10 10 10],{4},{1},{[]},{1},1,[],6,3,[1.25 1.25 1.25 1.25 1.25 1.25 1.25 1.25], 'Phase_def', 'def_field', '', 0, handles_tmp, 1);
        handles_tmp = Export_field('def_field_log', fullfile(FieldDir, [Phase_name '_to_' SimuParam.ref_4D '_log']), 'dcm', handles_tmp);
        
        handles_tmp = Remove_field('def_field', handles_tmp);
        handles_tmp = Remove_field('def_field_log', handles_tmp);
        handles_tmp = Remove_image('Phase_def', handles_tmp);
    end
    
end


for p=1:length(SimuParam.CT_phases)
    Phase_name = SimuParam.CT_phases{p};
    Field_name = [Phase_name '_to_' SimuParam.CT '_log.dcm'];
    
    handles = Import_data(FieldDir, Field_name, 1, 'def_field_log_data', handles);
    
    if(log_domain ~= 1)
        handles = Field_exponential('def_field_log_data', 'def_field_data', handles, 0); % 0 = not inversed
        handles = Data2field('def_field_data', 'def_field', handles);
        id = length(handles.fields.name);
        df_info = handles.fields.info{id};
        df_data = handles.fields.data{id};
        Export_MC2_Field(df_info, df_data, fullfile(MC2_FieldDir, ['Field_phase' num2str(p) '_to_Ref.mhd']));
        handles = Remove_field('def_field', handles);
        handles = Remove_data('def_field_data', handles);
        
        handles = Field_exponential('def_field_log_data', 'def_field_data', handles, 1); % 1 = inversed def field
        handles = Data2field('def_field_data', 'def_field', handles);
        id = length(handles.fields.name);
        df_info = handles.fields.info{id};
        df_data = handles.fields.data{id};
        Export_MC2_Field(df_info, df_data, fullfile(MC2_FieldDir, ['Field_Ref_to_phase' num2str(p) '.mhd']));
        handles = Remove_field('def_field', handles);
        handles = Remove_data('def_field_data', handles);
    else
        handles = Data2field('def_field_log_data', 'def_field', handles);
        id = length(handles.fields.name);
        df_info = handles.fields.info{id};
        df_data = - handles.fields.data{id};
        Export_MC2_Field(df_info, df_data, fullfile(MC2_FieldDir, ['Field_Ref_to_phase' num2str(p) '.mhd']));
        handles = Remove_field('def_field', handles);
    end
    
    handles = Remove_data('def_field_log_data', handles);
    
end

end

