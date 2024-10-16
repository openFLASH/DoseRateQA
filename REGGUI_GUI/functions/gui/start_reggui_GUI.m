function start_reggui_GUI(handles)

if(nargin<1)
    reggui('GUI',1);
else
    input_project_filename = fullfile(handles.dataPath,['temp_reggui_handles_',datestr(now,'yy_mm_dd_HH_MM'),'.mat']);
    Save_reggui_handles(handles,input_project_filename);
    instruction = ['handles = Open_reggui_handles(handles,''',input_project_filename,''');'];
    if(isempty(handles.instructions))
        regguiC([],handles.dataPath,{instruction},handles.log_filename);
    else
        regguiC(1,handles.dataPath,[instruction,handles.instructions],handles.log_filename);
    end
    delete(input_project_filename);
end
