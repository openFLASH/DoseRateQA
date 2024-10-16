function handles = Apply_view_point(handles)

new_slider_pos = handles.view_point./handles.size;
new_slider_pos(isinf(new_slider_pos))=0;

switch get(handles.xyz1,'Value')
    case 1
        if(new_slider_pos(1)>=0)
            set(handles.slider1,'Value',new_slider_pos(1));
            handles.slice1 = handles.view_point(1);
        end
    case 2
        if(new_slider_pos(2)>=0)
            set(handles.slider1,'Value',new_slider_pos(2));
            handles.slice1 = handles.view_point(2);
        end
    case 3
        if(new_slider_pos(3)>=0)
            set(handles.slider1,'Value',new_slider_pos(3));
            handles.slice1 = handles.view_point(3);
        end
end
switch get(handles.xyz2,'Value')
    case 1
        if(new_slider_pos(1)>=0)
            set(handles.slider2,'Value',new_slider_pos(1));
            handles.slice2 = handles.view_point(1);
        end
    case 2
        if(new_slider_pos(2)>=0)
            set(handles.slider2,'Value',new_slider_pos(2));
            handles.slice2 = handles.view_point(2);
        end
    case 3
        if(new_slider_pos(3)>=0)
            set(handles.slider2,'Value',new_slider_pos(3));
            handles.slice2 = handles.view_point(3);
        end
end
switch get(handles.xyz3,'Value')
    case 1
        if(new_slider_pos(1)>=0)
            set(handles.slider3,'Value',new_slider_pos(1));
            handles.slice3 = handles.view_point(1);
        end
    case 2
        if(new_slider_pos(2)>=0)
            set(handles.slider3,'Value',new_slider_pos(2));
            handles.slice3 = handles.view_point(2);
        end
    case 3
        if(new_slider_pos(3)>=0)
            set(handles.slider3,'Value',new_slider_pos(3));
            handles.slice3 = handles.view_point(3);
        end
end
switch get(handles.xyz4,'Value')
    case 1
        if(new_slider_pos(1)>=0)
            set(handles.slider4,'Value',new_slider_pos(1));
            handles.slice4 = handles.view_point(1);
        end
    case 2
        if(new_slider_pos(2)>=0)
            set(handles.slider4,'Value',new_slider_pos(2));
            handles.slice4 = handles.view_point(2);
        end
    case 3
        if(new_slider_pos(3)>=0)
            set(handles.slider4,'Value',new_slider_pos(3));
            handles.slice4 = handles.view_point(3);
        end
end
