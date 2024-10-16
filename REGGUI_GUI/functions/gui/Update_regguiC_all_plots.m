% Update all plots in the regguiC graphical interface

% Authors: G. Janssens

function Update_regguiC_all_plots(handles)

% Update plots
if(handles.current_special_axes==4)
    Update_regguiC_plot(handles,1);
    Update_regguiC_plot(handles,2);
    Update_regguiC_plot(handles,3);
    Update_regguiC_plot(handles,4);
else
    Update_regguiC_plot(handles,4);
end

% Update colorbars
update_colorbar = 0;
update_fusion_colorbar = 0;
i = 1;
while(isfield(handles,['image',num2str(i)]))
    image_tag = ['image',num2str(i)];
    fusion_tag = ['fusion',num2str(i)];    
    if(get(handles.(image_tag),'Value')>1)
        update_colorbar = 1;
    end
    if(get(handles.(fusion_tag),'Value')>1 && handles.fusion_mode==1)
        update_fusion_colorbar = 1;
    end
    i = i+1;
end
if(update_colorbar)
    Update_regguiC_colorbar(handles);
else
    axes(handles.axes_leg);
    imshow(zeros(1,1),[0 1]);
end
if(update_fusion_colorbar)
    Update_regguiC_colorbar(handles,'fusion');
else
    axes(handles.axes_leg_fusion);
    imshow(zeros(1,1),[0 1]);
end
guidata(handles.axes4,handles);