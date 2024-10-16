function Update_regguiC_colorbar(handles,axes_id)

if(nargin<2)
    axes_id = '';
end

if(ischar(handles.colormap))
    eval(['handles.colormap = ',handles.colormap,';'])
end

switch axes_id
    case 'fusion'
        cb = handles.second_colormap;
        cb(1,:) = 0;
        axes(handles.axes_leg_fusion);
        imshow(zeros(30,1),[0 1]);
        colormap(gca,cb);
        cbh=colorbar(gca,'location','eastoutside','Color','w');
        set(cbh,'XTick',[0:0.5:1]);
        scale = [handles.minscaleF,(handles.maxscaleF+handles.minscaleF)/2,handles.maxscaleF];
        if(abs(scale(1))>1 || abs(scale(2))>1)
            scale = round(scale);
        end
        set(cbh,'XTickLabel',{num2str(scale(1)),num2str(scale(2)),num2str(scale(3))});
        guidata(handles.axes_leg_fusion,handles);
    otherwise
        cb = handles.colormap;
        cb(1,:) = 0;
        axes(handles.axes_leg);
        imshow(zeros(30,1),[0 1]);
        colormap(gca,cb);
        cbh=colorbar(gca,'location','eastoutside','Color','w');
        set(cbh,'XTick',[0:0.5:1]);
        scale = [handles.minscale,(handles.maxscale+handles.minscale)/2,handles.maxscale];
        if(abs(scale(1))>1 || abs(scale(2))>1)
            scale = round(scale);
        end
        set(cbh,'XTickLabel',{num2str(scale(1)),num2str(scale(2)),num2str(scale(3))});
        guidata(handles.axes_leg,handles);
end
