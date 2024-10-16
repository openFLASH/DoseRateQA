
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Inverse_transform(input_trans_name,output_trans_name,handles)

Transform = [];
type = 2;
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},input_trans_name))
        Transform = handles.mydata.data{i};
        myInfo = handles.mydata.info{i};
        type = 3;
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},input_trans_name))
        Transform = handles.fields.data{i};
        myInfo = handles.fields.info{i};
        type = 2;
    end
end
if(isempty(Transform))
    error('Error : input transform not found in the current list !')
end

Transform = rigid_trans_inversion(Transform);

if(type==2)
    output_trans_name = check_existing_names(output_trans_name,handles.fields.name);
    handles.fields.name{length(handles.fields.name)+1} = output_trans_name;
    handles.fields.data{length(handles.fields.data)+1} = Transform;
    info = Create_default_info('rigid_transform',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.fields.info{length(handles.fields.info)+1} = info;
elseif(type==3)
    output_trans_name = check_existing_names(output_trans_name,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = output_trans_name;
    handles.mydata.data{length(handles.mydata.data)+1} = Transform;
    info = Create_default_info('rigid_transform',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.mydata.info{length(handles.mydata.info)+1} = info;
end
