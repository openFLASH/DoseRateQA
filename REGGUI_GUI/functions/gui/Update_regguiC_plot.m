% Update a plot in the regguiC graphical interface

% Authors: G. Janssens

function Update_regguiC_plot(handles,ref_axes)

% Display workspace geometrical parameters
proj_prop = cell(0);
proj_prop{2} = 'Size [voxels]:                                                                ';
proj_prop{3} = [num2str(handles.size(1)) '  ' num2str(handles.size(2)) '  ' num2str(handles.size(3))];
proj_prop{4} = 'Spacing [mm]:                                                          ';
proj_prop{5} = [num2str(round(handles.spacing(1)*1e3)/1e3) '  ' num2str(round(handles.spacing(2)*1e3)/1e3) '  ' num2str(round(handles.spacing(3)*1e3)/1e3)];
proj_prop{6} = 'Origin [mm]:                                                            ';
proj_prop{7} = [num2str(round(handles.origin(1)*1e3)/1e3) '  ' num2str(round(handles.origin(2)*1e3)/1e3) '  ' num2str(round(handles.origin(3)*1e3)/1e3)];
if(get(handles.Joint_slider,'Value'))
    proj_prop{8} = 'View point :                                                   ';
    proj_prop{9} = [num2str(handles.view_point(1)) '  ' num2str(handles.view_point(2)) '  ' num2str(handles.view_point(3)) ' [voxels]'];
    proj_prop{10} = [num2str(handles.view_point(1)*handles.spacing(1)+handles.origin(1)) '  ' num2str(handles.view_point(2)*handles.spacing(2)+handles.origin(2)) '  ' num2str(handles.view_point(3)*handles.spacing(3)+handles.origin(3)) ' [mm]'];
    intensities = '';
    if(not(isempty(handles.images.data{get(handles.image1,'Value')})))
        intensities = [intensities,'Top-left: ',num2str(round(handles.images.data{get(handles.image1,'Value')}(handles.view_point(1),handles.view_point(2),handles.view_point(3))*10)/10),' ; '];
    end
    if(not(isempty(handles.images.data{get(handles.image2,'Value')})))
        intensities = [intensities,'Top-right: ',num2str(round(handles.images.data{get(handles.image2,'Value')}(handles.view_point(1),handles.view_point(2),handles.view_point(3))*10)/10),' ; '];
    end
    if(not(isempty(handles.images.data{get(handles.image3,'Value')})))
        intensities = [intensities,'Bottom-left: ',num2str(round(handles.images.data{get(handles.image3,'Value')}(handles.view_point(1),handles.view_point(2),handles.view_point(3))*10)/10),' ; '];
    end
    if(not(isempty(intensities)))
        proj_prop{11} = 'Intensities :                                                  ';
        proj_prop{12} = intensities;
    end
end
set(handles.prop_text,'String',proj_prop);

% Display contour and plan names
for contour_index = 1:min(length(handles.contours_to_plot),6)
    if(not(length(handles.images.data)<handles.contours_to_plot(contour_index)))
        eval(['set(handles.multiple_contours_legend_',num2str(contour_index),',''String'',''',handles.images.name{handles.contours_to_plot(contour_index)},''');']);
    end
end
for plan_index = 1:min(length(handles.plan_to_plot),1)
    set(handles.plan_legend_1,'String',handles.plans.name{handles.plan_to_plot(plan_index)});
end

% Select views
if(handles.current_special_axes==5)
    set(handles.uipanel2,'Visible','off');
    set(handles.uipanel3,'Visible','off');
    set(handles.uipanel4,'Visible','off');
    set(handles.slider1,'Visible','off');
    set(handles.slider2,'Visible','off');
    set(handles.slider3,'Visible','off');
    set(handles.Joint_slider,'Visible','off');
    eval(['axes(handles.axes5);']);
    current_axes = 5;
else
    set(handles.uipanel2,'Visible','on');
    set(handles.uipanel3,'Visible','on');
    set(handles.uipanel4,'Visible','on');
    set(handles.slider1,'Visible','on');
    set(handles.slider2,'Visible','on');
    set(handles.slider3,'Visible','on');
    set(handles.Joint_slider,'Visible','on');
    eval(['axes(handles.axes',num2str(ref_axes),');']);
    current_axes = ref_axes;
end
axe_BDF = get(gca,'ButtonDownFcn');
hold off
eval(['current_image = get(handles.image',num2str(ref_axes),',''Value'');']);
eval(['current_view = get(handles.xyz',num2str(ref_axes),',''Value'');']);
eval(['current_field = get(handles.field',num2str(ref_axes),',''Value'');']);
eval(['current_fusion = get(handles.fusion',num2str(ref_axes),',''Value'');']);
alphaF = get(handles.slider_fusion,'Value');

% Display data
switch current_view
    case 1 % Sagittal
        eval(['curr_im = imshow(zeros(handles.size(3),handles.size(2)),[0 1]);']);
        hold on
        if(not(isempty(handles.images.data{current_image})))
            if(ref_axes>3 && get(handles.DRR,'Value'))
                eval(['curr_im = imshow((abs((squeeze(mean((handles.images.data{current_image}-min(handles.images.data{current_image}(:))).^5,1)))+min(handles.images.data{current_image}(:))).^(1/5))'',[handles.minscale handles.maxscale+eps]);']);
            else
                eval(['if(handles.slice',num2str(ref_axes),' > size(handles.images.data{current_image},1));handles.slice',num2str(ref_axes),'=1;end']);
                eval(['Im = squeeze(handles.images.data{current_image}(handles.slice',...
                    num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                Im  = safe_label2rgb(Im,handles.colormap,[handles.minscale handles.maxscale+eps],size(handles.colormap,1));
                curr_im = imshow(Im,'Border','tight');
            end
            if(get(handles.multiple_contours,'Value'))
                if(not(isempty(handles.images.data{current_fusion})))
                    switch handles.fusion_mode
                        case 1
                            eval(['F = squeeze(handles.images.data{current_fusion}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            curr_im = plot_reggui_fusion(Im,F,alphaF,[handles.minscale,handles.maxscale],[handles.minscaleF,handles.maxscaleF],handles.colormap,handles.second_colormap);
                        case 2
                            eval(['F = squeeze(handles.images.data{current_fusion}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            curr_im = plot_reggui_difference(Im,F,[handles.minscale,handles.maxscale],handles.colormap);
                    end
                end
                contour_colors = {'y';'r';'b';'g';'c';'m'};
                for contour_index = 1:min(length(handles.contours_to_plot),6)
                    if(not(length(handles.images.data)<handles.contours_to_plot(contour_index)))
                        eval(['F = squeeze(handles.images.data{handles.contours_to_plot(contour_index)}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)));']);
                        eval(['F = (F-min(min(F(:)),0)) >= max(max(max(handles.images.data{handles.contours_to_plot(contour_index)})))/',num2str(handles.contour_level),';']);
                        plot_reggui_contours(F,['''',contour_colors{contour_index},'''']);
                    end
                end
            else
                if(not(isempty(handles.images.data{current_fusion})))
                    switch handles.fusion_mode
                        case 1
                            eval(['F = squeeze(handles.images.data{current_fusion}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            curr_im = plot_reggui_fusion(Im,F,alphaF,[handles.minscale,handles.maxscale],[handles.minscaleF,handles.maxscaleF],handles.colormap,handles.second_colormap);
                        case 2
                            eval(['F = squeeze(handles.images.data{current_fusion}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)))'';']);
                            curr_im = plot_reggui_difference(Im,F,[handles.minscale,handles.maxscale],handles.colormap);
                        otherwise
                            eval(['F = squeeze(handles.images.data{current_fusion}(handles.slice',num2str(ref_axes),',1:handles.size(2),1:handles.size(3)));'])
                            eval(['F = (F-min(min(F(:)),0)) >= max(max(max(handles.images.data{current_fusion})))/',num2str(handles.contour_level),';']);
                            plot_reggui_contours(F,['[',num2str(handles.contour_color),']']);
                    end
                end
            end
        end
        if(not(isempty(handles.fields.data{current_field})) && handles.size(2)>1 && handles.size(3)>1 && strcmp(handles.fields.info{current_field}.Type,'deformation_field'))
            eval(['quiver(handles.axes',num2str(current_axes),',[1:handles.fielddensity:handles.size(2)],[1:handles.fielddensity:handles.size(3)],squeeze(handles.fields.data{current_field}(2,handles.slice',num2str(ref_axes),',[1:handles.fielddensity:handles.size(2)],[1:handles.fielddensity:handles.size(3)]))'',squeeze(handles.fields.data{current_field}(3,handles.slice',num2str(ref_axes),',[1:handles.fielddensity:handles.size(2)],[1:handles.fielddensity:handles.size(3)]))'',0,''Color'',[',num2str(handles.field_color),']'');']);
        elseif(not(isempty(handles.fields.data{current_field})) && handles.size(2)>1 && handles.size(3)>1 && strcmp(handles.fields.info{current_field}.Type,'rigid_transform'))
            eval(['quiver(handles.axes',num2str(current_axes),',handles.size(2)/2,handles.size(3)/2,handles.fields.data{current_field}(2,2)/handles.spacing(2),handles.fields.data{current_field}(2,3)/handles.spacing(3),0,''o'',''filled'',''Color'',[',num2str(handles.field_color),'],''LineWidth'',2);']);
        end
        if(get(handles.display_plan,'Value'))
            if(not(isempty(handles.plan_to_plot)))
                plan = handles.plans.data{handles.plan_to_plot};
                sad = 2e3; % not used (because only central beam axis displayed)
                for b=1:length(plan)
                    [pt1,pt2] = compute_beam_isoplane([0;0],plan{b},sad);
                    pt1 = (pt1 - handles.origin)./handles.spacing;
                    pt2 = (pt2 - handles.origin)./handles.spacing;
                    plot([pt1(2),pt2(2)],[pt1(3),pt2(3)],'m');
                end
            end
        end
        if(ref_axes<4 && get(handles.Joint_slider,'Value'))
            hold on
            plot([1 handles.size(2)],[handles.view_point(3) handles.view_point(3)],'Color','b');
            plot([handles.view_point(2) handles.view_point(2)],[1 handles.size(3)],'Color','b');
            hold off
        end
        daspect([handles.spacing(3) handles.spacing(2) 1]);
    case 2 % Coronal
        eval(['curr_im = imshow(zeros(handles.size(3),handles.size(1)),[0 1]);']);
        hold on
        if(not(isempty(handles.images.data{current_image})))
            if(ref_axes>3 && get(handles.DRR,'Value'))
                eval(['curr_im = imshow((abs((squeeze(mean((handles.images.data{current_image}-min(handles.images.data{current_image}(:))).^5,2)))+min(handles.images.data{current_image}(:))).^(1/5))'',[handles.minscale handles.maxscale+eps]);']);
            else
                eval(['if(handles.slice',num2str(ref_axes),' > size(handles.images.data{current_image},2));handles.slice',num2str(ref_axes),'=1;end']);
                eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.slice',...
                    num2str(ref_axes),',1:handles.size(3)))'';']);
                Im  = safe_label2rgb(Im,handles.colormap,[handles.minscale handles.maxscale+eps],size(handles.colormap,1));
                curr_im = imshow(Im,'Border','tight');
            end
            if(get(handles.multiple_contours,'Value'))
                if(not(isempty(handles.images.data{current_fusion})))
                    switch handles.fusion_mode
                        case 1
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            curr_im = plot_reggui_fusion(Im,F,alphaF,[handles.minscale,handles.maxscale],[handles.minscaleF,handles.maxscaleF],handles.colormap,handles.second_colormap);
                        case 2
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            curr_im = plot_reggui_difference(Im,F,[handles.minscale,handles.maxscale],handles.colormap);
                    end
                end
                contour_colors = {'y';'r';'b';'g';'c';'m'};
                for contour_index = 1:min(length(handles.contours_to_plot),6)
                    if(not(length(handles.images.data)<handles.contours_to_plot(contour_index)))
                        eval(['F = squeeze(handles.images.data{handles.contours_to_plot(contour_index)}(1:handles.size(1),handles.slice',num2str(ref_axes),',1:handles.size(3)));']);
                        eval(['F = (F-min(min(F(:)),0)) >= max(max(max(handles.images.data{handles.contours_to_plot(contour_index)})))/',num2str(handles.contour_level),';']);
                        plot_reggui_contours(F,['''',contour_colors{contour_index},'''']);
                    end
                end
            else
                if(not(isempty(handles.images.data{current_fusion})))
                    switch handles.fusion_mode
                        case 1
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            curr_im = plot_reggui_fusion(Im,F,alphaF,[handles.minscale,handles.maxscale],[handles.minscaleF,handles.maxscaleF],handles.colormap,handles.second_colormap);
                        case 2
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.slice',...
                                num2str(ref_axes),',1:handles.size(3)))'';']);
                            curr_im = plot_reggui_difference(Im,F,[handles.minscale,handles.maxscale],handles.colormap);
                        otherwise
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.slice',num2str(ref_axes),',1:handles.size(3)));'])
                            eval(['F = (F-min(min(F(:)),0)) >= max(max(max(handles.images.data{current_fusion})))/',num2str(handles.contour_level),';']);
                            plot_reggui_contours(F,['[',num2str(handles.contour_color),']']);
                    end
                end
            end
        end
        if(not(isempty(handles.fields.data{current_field})) && handles.size(1)>1 && handles.size(3)>1 && strcmp(handles.fields.info{current_field}.Type,'deformation_field'))
            eval(['quiver(handles.axes',num2str(current_axes),',[1:handles.fielddensity:handles.size(1)],[1:handles.fielddensity:handles.size(3)],squeeze(handles.fields.data{current_field}(1,[1:handles.fielddensity:handles.size(1)],handles.slice',num2str(ref_axes),',[1:handles.fielddensity:handles.size(3)]))'',squeeze(handles.fields.data{current_field}(3,[1:handles.fielddensity:handles.size(1)],handles.slice',num2str(ref_axes),',[1:handles.fielddensity:handles.size(3)]))'',0,''Color'',[',num2str(handles.field_color),']'');']);
        elseif(not(isempty(handles.fields.data{current_field})) && handles.size(1)>1 && handles.size(3)>1 && strcmp(handles.fields.info{current_field}.Type,'rigid_transform'))
            eval(['quiver(handles.axes',num2str(current_axes),',handles.size(1)/2,handles.size(3)/2,handles.fields.data{current_field}(2,1)/handles.spacing(1),handles.fields.data{current_field}(2,3)/handles.spacing(3),0,''o'',''filled'',''Color'',[',num2str(handles.field_color),'],''LineWidth'',2);']);
        end
        if(get(handles.display_plan,'Value'))
            if(not(isempty(handles.plan_to_plot)))
                plan = handles.plans.data{handles.plan_to_plot};
                sad = 2e3; % not used (because only central beam axis displayed)
                for b=1:length(plan)
                    [pt1,pt2] = compute_beam_isoplane([0;0],plan{b},sad);
                    pt1 = (pt1 - handles.origin)./handles.spacing;
                    pt2 = (pt2 - handles.origin)./handles.spacing;
                    plot([pt1(1),pt2(1)],[pt1(3),pt2(3)],'m');
                end
            end
        end
        if(ref_axes<4 && get(handles.Joint_slider,'Value'))
            hold on
            plot([1 handles.size(1)],[handles.view_point(3) handles.view_point(3)],'Color','b');
            plot([handles.view_point(1) handles.view_point(1)],[1 handles.size(3)],'Color','b');
            hold off
        end
        daspect([handles.spacing(3) handles.spacing(1) 1]);
    case 3 % Axial
        eval(['curr_im = imshow(zeros(handles.size(2),handles.size(1)),[0 1]);']);
        hold on
        if(not(isempty(handles.images.data{current_image})))
            if(ref_axes>3 && get(handles.DRR,'Value'))
                eval(['curr_im = imshow(flipdim((abs((squeeze(mean((handles.images.data{current_image}-min(handles.images.data{current_image}(:))).^5,3)))+min(handles.images.data{current_image}(:))).^(1/5))'',1),[handles.minscale handles.maxscale+eps]);']);
            else
                eval(['if(handles.slice',num2str(ref_axes),' > size(handles.images.data{current_image},3));handles.slice',num2str(ref_axes),'=1;end']);
                eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                    num2str(ref_axes),'))'';']);
                Im  = safe_label2rgb(Im,handles.colormap,[handles.minscale handles.maxscale+eps],size(handles.colormap,1));
                curr_im = imshow(Im,'Border','tight');
            end
            if(get(handles.multiple_contours,'Value'))
                if(not(isempty(handles.images.data{current_fusion})))
                    switch handles.fusion_mode
                        case 1
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            curr_im = plot_reggui_fusion(Im,F,alphaF,[handles.minscale,handles.maxscale],[handles.minscaleF,handles.maxscaleF],handles.colormap,handles.second_colormap);
                        case 2
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            curr_im = plot_reggui_difference(Im,F,[handles.minscale,handles.maxscale],handles.colormap);
                    end
                end
                contour_colors = {'y';'r';'b';'g';'c';'m'};
                for contour_index = 1:min(length(handles.contours_to_plot),6)
                    if(not(length(handles.images.data)<handles.contours_to_plot(contour_index)))
                        eval(['F = squeeze(handles.images.data{handles.contours_to_plot(contour_index)}(1:handles.size(1),handles.size(2):-1:1,handles.slice',num2str(ref_axes),'));']);
                        eval(['F = (F-min(min(F(:)),0)) >= max(max(max(handles.images.data{handles.contours_to_plot(contour_index)})))/',num2str(handles.contour_level),';']);
                        plot_reggui_contours(F,['''',contour_colors{contour_index},'''']);
                    end
                end
            else
                if(not(isempty(handles.images.data{current_fusion})))
                    switch handles.fusion_mode
                        case 1
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            curr_im = plot_reggui_fusion(Im,F,alphaF,[handles.minscale,handles.maxscale],[handles.minscaleF,handles.maxscaleF],handles.colormap,handles.second_colormap);
                        case 2
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            eval(['Im = squeeze(handles.images.data{current_image}(1:handles.size(1),handles.size(2):-1:1,handles.slice',...
                                num2str(ref_axes),'))'';']);
                            curr_im = plot_reggui_difference(Im,F,[handles.minscale,handles.maxscale],handles.colormap);
                        otherwise
                            eval(['F = squeeze(handles.images.data{current_fusion}(1:handles.size(1),handles.size(2):-1:1,handles.slice',num2str(ref_axes),'));'])
                            eval(['F = (F-min(min(F(:)),0)) >= max(max(max(handles.images.data{current_fusion})))/',num2str(handles.contour_level),';']);
                            plot_reggui_contours(F,['[',num2str(handles.contour_color),']']);
                    end
                end
            end
        end
        if(not(isempty(handles.fields.data{current_field})) && handles.size(1)>1 && handles.size(2)>1 && strcmp(handles.fields.info{current_field}.Type,'deformation_field'))
            eval(['quiver(handles.axes',num2str(current_axes),',[1:handles.fielddensity:handles.size(1)],[handles.size(2):-handles.fielddensity:1],squeeze(handles.fields.data{current_field}(1,[1:handles.fielddensity:handles.size(1)],[1:handles.fielddensity:handles.size(2)],handles.slice',num2str(ref_axes),'))'',-squeeze(handles.fields.data{current_field}(2,[1:handles.fielddensity:handles.size(1)],[1:handles.fielddensity:handles.size(2)],handles.slice',num2str(ref_axes),'))'',0,''Color'',[',num2str(handles.field_color),']'');']);
        elseif(not(isempty(handles.fields.data{current_field})) && handles.size(1)>1 && handles.size(2)>1 && strcmp(handles.fields.info{current_field}.Type,'rigid_transform'))
            eval(['quiver(handles.axes',num2str(current_axes),',handles.size(1)/2,handles.size(2)/2,handles.fields.data{current_field}(2,1)/handles.spacing(1),-handles.fields.data{current_field}(2,2)/handles.spacing(2),0,''o'',''filled'',''Color'',[',num2str(handles.field_color),'],''LineWidth'',2);']);
        end
        if(get(handles.display_plan,'Value'))
            if(not(isempty(handles.plan_to_plot)))
                plan = handles.plans.data{handles.plan_to_plot};
                sad = 2e3; % not used (because only central beam axis displayed)
                for b=1:length(plan)
                    [pt1,pt2] = compute_beam_isoplane([0;0],plan{b},sad);
                    pt1 = (pt1 - handles.origin)./handles.spacing;
                    pt2 = (pt2 - handles.origin)./handles.spacing;
                    plot([pt1(1),pt2(1)],handles.size(2)-[pt1(2),pt2(2)],'m');
                end
            end
        end
        if(ref_axes<4 && get(handles.Joint_slider,'Value'))
            hold on
            plot([1 handles.size(1)],handles.size(2)-[handles.view_point(2) handles.view_point(2)]+1,'Color','b');
            plot([handles.view_point(1) handles.view_point(1)],[1 handles.size(2)],'Color','b');
            hold off
        end
        daspect([handles.spacing(2) handles.spacing(1) 1]);
end
if(ref_axes>3 && length(handles.images.data)>1 && get(handles.zoom,'Value')>1)
    zoom(get(handles.zoom,'Value')^4);
end
%colormap(handles.colormap);
axis xy;
if(get(handles.Joint_slider,'Value') || ref_axes>3)
    set(curr_im,'ButtonDownFcn',axe_BDF);
else
    set(curr_im,'ButtonDownFcn','');
end
set(gca,'ButtonDownFcn',axe_BDF);
eval(['guidata(handles.axes',num2str(ref_axes),', handles);']);
