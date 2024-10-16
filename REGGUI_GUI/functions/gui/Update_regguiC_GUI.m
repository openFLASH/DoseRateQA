% Update the regguiC graphical interface according to current handles information

% Authors: G. Janssens

function handles = Update_regguiC_GUI(handles,varargin)

% Update the check boxes
set(handles.on_region_of_interest,'Value',handles.roi_mode);
% Reset values if empty workspace
if(not(handles.spatialpropsettled))
    handles.slice1 = 1;
    handles.slice2 = 1;
    handles.slice3 = 1;
    handles.minscale = 0;
    handles.maxscale = 1;
    set(handles.slider1,'Value',0);
    set(handles.slider2,'Value',0);
    set(handles.slider3,'Value',0);
    set(handles.slider4,'Value',0);
    if(handles.current_special_axes == 5)
        axes(handles.axes5)
        cla
        set(handles.uipanel2,'Visible','on');
        set(handles.uipanel3,'Visible','on');
        set(handles.uipanel4,'Visible','on');
        set(handles.slider1,'Visible','on');
        set(handles.slider2,'Visible','on');
        set(handles.slider3,'Visible','on');
        set(handles.Joint_slider,'Visible','on');
        handles.current_special_axes = 4;
        set(handles.zoom,'Value',1);
    end
end
% Update and apply the viewing point
if((handles.view_point(1)<1 || handles.view_point(1)>handles.size(1)) || (handles.view_point(2)<1 || handles.view_point(2)>handles.size(2)) || (handles.view_point(3)<1 || handles.view_point(3)>handles.size(3)))
    handles.view_point = [1;1;1];
    handles = Apply_view_point(handles);
end
% Update the data to be displayed
if(nargin>1)
    args = '';
    for i=1:length(varargin)
        args = [args,',varargin{',num2str(i),'}'];
    end
    eval(['handles = Update_regguiC_lists(handles',args,');']);
else
    handles = Update_regguiC_lists(handles);
end
% Set image display scale
update_image_scale = 0;
update_fusion_scale = 0;
if(not(isempty(varargin)))
    for i=1:length(varargin)
        if(ischar(varargin{i}))
            if(strcmp(varargin{i},'show_last_image'))
                update_image_scale = 1;
            elseif(strcmp(varargin{i},'show_last_fusion'))
                update_fusion_scale = 1;
            end
        end
    end
end
if((update_image_scale || update_fusion_scale) && ~isempty(handles.images.data))
    if(update_fusion_scale)
        indices = unique([get(handles.fusion1,'Value'),get(handles.fusion2,'Value'),get(handles.fusion3,'Value'),get(handles.fusion4,'Value')]);
        current_images = cell(0);
        for i=1:length(indices)
            current_images{i} = handles.images.data{indices(i)};
        end
        [handles.minscaleF,handles.maxscaleF] = get_image_scale(current_images,handles.scale_prctile);
    end
    if(update_image_scale)
        indices = unique([get(handles.image1,'Value'),get(handles.image2,'Value'),get(handles.image3,'Value'),get(handles.image4,'Value')]);
        current_images = cell(0);
        for i=1:length(indices)
            current_images{i} = handles.images.data{indices(i)};
        end
        [handles.minscale,handles.maxscale] = get_image_scale(current_images,handles.scale_prctile);
    end
end
set(handles.edit_minscale,'String',num2str(handles.minscale));
set(handles.edit_maxscale,'String',num2str(handles.maxscale));
set(handles.edit_minscaleF,'String',num2str(handles.minscaleF));
set(handles.edit_maxscaleF,'String',num2str(handles.maxscaleF));
% When workspace is 2D, no need for slice navigation sliders
if(handles.spatialpropsettled && handles.size(3)==1)
    set(handles.xyz1,'Value',3);
    set(handles.xyz2,'Value',3);
    set(handles.xyz3,'Value',3);
    set(handles.xyz1,'Visible','off');
    set(handles.xyz2,'Visible','off');
    set(handles.xyz3,'Visible','off');
    set(handles.slider1,'Visible','off');
    set(handles.slider2,'Visible','off');
    set(handles.slider3,'Visible','off');
else
    set(handles.xyz1,'Visible','on');
    set(handles.xyz2,'Visible','on');
    set(handles.xyz3,'Visible','on');
    set(handles.slider1,'Visible','on');
    set(handles.slider2,'Visible','on');
    set(handles.slider3,'Visible','on');
end
% Remove the black message screen
message{7} = '';
set(handles.processing_message,'String',message);
set(handles.processing_message,'Visible','off');
% Plot all views
Update_regguiC_all_plots(handles);
drawnow
% Set reggui in non-automatic mode for manual processing
handles = Automatic(handles,0);
