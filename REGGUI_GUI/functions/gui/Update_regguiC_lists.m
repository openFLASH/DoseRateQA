% Update the data lists in the regguiC graphical interface according to current handles information

% Authors: G. Janssens

function handles = Update_regguiC_lists(handles,varargin)
images_to_show = cell(0);
fields_to_show = cell(0);
fusions_to_show = cell(0);
contours_to_show = cell(0);
plan_to_show = cell(0);
i=1;
while i<=length(varargin)
    switch varargin{i}
        case 'images_to_show'
            images_to_show = varargin{i+1};
            i = i+1;
        case 'fields_to_show'
            fields_to_show = varargin{i+1};
            i = i+1;
        case 'fusions_to_show'
            fusions_to_show = varargin{i+1};
            i = i+1;
        case 'contours_to_show'
            contours_to_show = varargin{i+1};
            i = i+1;
        case 'plan_to_show'
            contours_to_show = varargin{i+1};
            i = i+1;
        case 'show_last_image'
            images_to_show = {handles.images.name{end},handles.images.name{end},handles.images.name{end},handles.images.name{end}};
        case 'show_last_field'
            fields_to_show = {handles.fields.name{end},handles.fields.name{end},handles.fields.name{end},handles.fields.name{end}};
        case 'show_last_fusion'
            fusions_to_show = {handles.images.name{end},handles.images.name{end},handles.images.name{end},handles.images.name{end}};
        case 'show_last_contour'
            contours_to_show = {handles.images.name{end}};
        case 'show_last_plan'
            plan_to_show = {handles.plans.name{end}};
    end
    i = i+1;
end
% Update lists
i = 1;
while(isfield(handles,['image',num2str(i)]))
    image_tag = ['image',num2str(i)];
    fusion_tag = ['fusion',num2str(i)];
    field_tag = ['field',num2str(i)];
    % update image lists
    if(length(images_to_show)>=i)
        for j=1:length(handles.images.name)
            if(strcmp(handles.images.name{j},images_to_show{i}))
                set(handles.(image_tag),'Value',j);
            end
        end
    end
    if(get(handles.(image_tag),'Value')>length(handles.images.name))
        set(handles.(image_tag),'Value',1);
    end
    set(handles.(image_tag),'String',handles.images.name);
    % update field lists
    if(length(fields_to_show)>=i)
        for j=1:length(handles.fields.name)
            if(strcmp(handles.fields.name{j},fields_to_show{i}))
                set(handles.(field_tag),'Value',j);
            end
        end
    end
    if(get(handles.(field_tag),'Value')>length(handles.fields.name))
        set(handles.(field_tag),'Value',1);
    end
    set(handles.(field_tag),'String',handles.fields.name);
    % update fusion lists
    if(length(fusions_to_show)>=i)
        for j=1:length(handles.images.name)
            if(strcmp(handles.images.name{j},fusions_to_show{i}))
                set(handles.(fusion_tag),'Value',j);
            end
        end
    end
    if(get(handles.(fusion_tag),'Value')>length(handles.images.name))
        set(handles.(fusion_tag),'Value',1);
    end
    set(handles.(fusion_tag),'String',handles.images.name);
    i = i+1;
end
% Update contours
handles.contours_to_plot = handles.contours_to_plot(handles.contours_to_plot<=length(handles.images.name));
if(not(isempty(contours_to_show)))
    handles.contours_to_plot = [];
    for i=1:length(handles.images.name)
        if(sum(strcmp(contours_to_show,handles.images.name{i})))
            handles.contours_to_plot = [handles.contours_to_plot,i];
        end
    end
end
if(not(isempty(handles.contours_to_plot)))
    set(handles.multiple_contours,'Value',1);
    for i=1:6
        eval(['set(handles.multiple_contours_legend_',num2str(i),',''Visible'',''off'');']);
    end
    for i=1:min(length(handles.contours_to_plot),6)
        eval(['set(handles.multiple_contours_legend_',num2str(i),',''Visible'',''on'');']);
    end
else
    set(handles.multiple_contours,'Value',0);
    for i=1:6
        eval(['set(handles.multiple_contours_legend_',num2str(i),',''Visible'',''off'');']);
    end
end
% Update plan
handles.plan_to_plot = handles.plan_to_plot(handles.plan_to_plot<=length(handles.plans.name));
if(not(isempty(plan_to_show)))
    handles.plan_to_plot = [];
    for i=1:length(handles.plans.name)
        if(sum(strcmp(plan_to_show,handles.plans.name{i})))
            handles.plan_to_plot = [handles.plan_to_plot,i];
        end
    end
end
if(not(isempty(handles.plan_to_plot)))
    set(handles.display_plan,'Value',1);
    set(handles.plan_legend_1,'Visible','on');
else
    set(handles.display_plan,'Value',0);
    set(handles.plan_legend_1,'Visible','off');
end