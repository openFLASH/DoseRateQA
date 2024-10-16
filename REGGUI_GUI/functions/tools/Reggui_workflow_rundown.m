function Reggui_workflow_rundown(handles)

if(not(handles.error_count))
    get_computation_time(clock,handles.time);disp(['Number of errors : ',num2str(handles.error_count)]);
else
    reggui_message({'WORKFLOW ENDED';' ';['Number of errors : ',num2str(handles.error_count)]});
end