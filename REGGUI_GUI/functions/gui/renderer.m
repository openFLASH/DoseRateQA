function varargout = renderer(varargin)
% RENDERER M-file for renderer.fig
%      RENDERER, by itself, creates a new RENDERER or raises the existing
%      singleton*.
%
%      H = RENDERER returns the handle to a new RENDERER or the handle to
%      the existing singleton*.
%
%      RENDERER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RENDERER.M with the given input arguments.
%
%      RENDERER('Property','Value',...) creates a new RENDERER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before renderer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to renderer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help renderer

% Last Modified by GUIDE v2.5 14-Mar-2011 11:12:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @renderer_OpeningFcn, ...
    'gui_OutputFcn',  @renderer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before renderer is made visible.
function renderer_OpeningFcn(hObject, eventdata, handles, varargin)
handles.ancest = varargin{1};
handles.output = [];
set(handles.set_index,'String',num2str(handles.ancest.view_point(1)));
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = renderer_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
varargout{2} = handles.ancest;
delete(handles.figure1);


% --- Executes on button press in movie_button.
function movie_button_Callback(hObject, eventdata, handles)
% Add frames to a new sequence
rd_nb = length(handles.ancest.rendering_frames)+1;
rd_view = get(handles.set_view,'String');
rd_view = rd_view{get(handles.set_view,'Value')};
eval(['rd_index = ',get(handles.set_index,'String'),';']);
image_name = get(handles.list_images,'String');
contour_name = get(handles.list_contours,'String');
fusion_name = get(handles.list_fusion,'String');
field_name = get(handles.list_fields,'String');
for i=1:length(image_name)
    if(length(contour_name)<i)
        contour_name{i} = '';
    end
    if(length(fusion_name)<i)
        fusion_name{i} = '';
    end
    if(length(field_name)<i)
        field_name{i} = '';
    end    
    if(not(isempty(strfind(contour_name{i},'{'))) && not(isempty(strfind(contour_name{i},'}'))))
        eval(['list_of_contours = ',contour_name{i},';']);
    else
        list_of_contours = contour_name{i};
    end
    handles.ancest = Addframe(rd_nb,rd_view,rd_index,image_name{i},handles.ancest,list_of_contours,fusion_name{i},field_name{i});
end
% Create instruction
default_name = cell(0);
default_name{1} = [handles.ancest.dataPath,'/movie_seq',num2str(rd_nb)];
outputname = char(inputdlg({'Choose a name to export (without file extension)'},' ',1,default_name));
eval(['fps = ',get(handles.set_fps,'String'),';']);
eval(['image_duration = ',get(handles.set_image_duration,'String'),';']);
eval(['fade_duration = ',get(handles.set_fade_duration,'String'),';']);
frame_size = ['[',get(handles.set_frame_size_w,'String'),' ',get(handles.set_frame_size_h,'String'),']'];
loop = get(handles.set_loop,'Value');
handles.output = ['movie_rendering(handles.rendering_frames{',num2str(rd_nb),'},''',outputname,'.gif'',',num2str(fps),',',num2str(image_duration),',',num2str(fade_duration),',',frame_size,',',num2str(loop),',''gif'');'];
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in Images_button.
function Images_button_Callback(hObject, eventdata, handles)
% Add frames to a new sequence
rd_nb = length(handles.ancest.rendering_frames)+1;
rd_view = get(handles.set_view,'String');
rd_view = rd_view{get(handles.set_view,'Value')};
eval(['rd_index = ',get(handles.set_index,'String'),';']);
image_name = get(handles.list_images,'String');
contour_name = get(handles.list_contours,'String');
fusion_name = get(handles.list_fusion,'String');
field_name = get(handles.list_fields,'String');
for i=1:length(image_name)
    if(length(contour_name)<i)
        contour_name{i} = '';
    end
    if(length(fusion_name)<i)
        fusion_name{i} = '';
    end
    if(length(field_name)<i)
        field_name{i} = '';
    end
    if(not(isempty(strfind(contour_name{i},'{'))) && not(isempty(strfind(contour_name{i},'}'))))
        eval(['list_of_contours = ',contour_name{i},';']);
    else
        list_of_contours = contour_name{i};
    end
    handles.ancest = Addframe(rd_nb,'ZY',handles.ancest.view_point(1),image_name{i},handles.ancest,list_of_contours,fusion_name{i},field_name{i});
    handles.ancest = Addframe(rd_nb+1,'ZX',handles.ancest.view_point(2),image_name{i},handles.ancest,list_of_contours,fusion_name{i},field_name{i});
    handles.ancest = Addframe(rd_nb+2,'YX',handles.ancest.view_point(3),image_name{i},handles.ancest,list_of_contours,fusion_name{i},field_name{i});
end
% Create instruction
default_name = cell(0);
default_name{1} = [handles.ancest.dataPath,'/image_seq',num2str(length(handles.ancest.rendering_frames)+1)];
outputname = char(inputdlg({'Choose a name to export (without file extension)'},' ',1,default_name));
frame_size = ['[',get(handles.set_frame_size_w,'String'),' ',get(handles.set_frame_size_h,'String'),']'];
handles.output = ['image_rendering(handles.rendering_frames{',num2str(rd_nb),'},''',outputname,'_sagital'',',frame_size,');image_rendering(handles.rendering_frames{',num2str(rd_nb+1),'},''',outputname,'_coronal'',',frame_size,');image_rendering(handles.rendering_frames{',num2str(rd_nb+2),'},''',outputname,'_axial'',',frame_size,');'];
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on selection change in list_images.
function list_images_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_images_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_contours.
function list_contours_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_contours_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_fusion.
function list_fusion_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_fusion_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_fields.
function list_fields_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_fields_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_image.
function Load_image_Callback(hObject, eventdata, handles)
[selectedImages,OK] = listdlg('PromptString','Which image do you want to add to the rendering list ?',...
    'SelectionMode','multiple',...
    'ListString',handles.ancest.images.name);
if OK==0
    disp('Wrong selection')
    return
end
list = get(handles.list_images,'String');
if(isempty(list))
    for i=1:length(selectedImages)
        a = handles.ancest.images.name{selectedImages(i)};
            list{i} = a;
    end
else
    index = get(handles.list_images,'Value');
    list_end = list(index+1:end);
    for i=1:length(selectedImages)
        a = handles.ancest.images.name{selectedImages(i)};
            list{index+i} = a;
    end
    list(end+1:end+length(list_end))=list_end;
end
set(handles.list_images,'String',list);
set(handles.list_images,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in Load_contour.
function Load_contour_Callback(hObject, eventdata, handles)
[selectedImages,OK] = listdlg('PromptString','Which contour do you want to add to the rendering list ?',...
    'SelectionMode','multiple',...
    'ListString',handles.ancest.images.name);
if OK==0
    disp('Wrong selection')
    return
end
list = get(handles.list_contours,'String');
if(isempty(list))
    for i=1:length(selectedImages)
        a = handles.ancest.images.name{selectedImages(i)};
        list{i} = a;
    end
else
    index = get(handles.list_contours,'Value');
    list_end = list(index+1:end);
    for i=1:length(selectedImages)
        a = handles.ancest.images.name{selectedImages(i)};
        list{index+i} = a;
    end
    list(end+1:end+length(list_end))=list_end;
end
set(handles.list_contours,'String',list);
set(handles.list_contours,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in Load_mult_contours.
function Load_mult_contours_Callback(hObject, eventdata, handles)
[selectedImages,OK] = listdlg('PromptString','Which contour do you want to add to the rendering list ?',...
    'SelectionMode','multiple',...
    'ListString',handles.ancest.images.name);
if OK==0
    disp('Wrong selection')
    return
end
list = get(handles.list_contours,'String');
if(isempty(list))
    index = 0;
else
    index = get(handles.list_contours,'Value');
end
a = ['{''' handles.ancest.images.name{selectedImages(1)}];
for i=2:length(selectedImages)
    a = [a ''',''' handles.ancest.images.name{selectedImages(i)}];
end
a = [a '''}'];
list{index+1} = a;
set(handles.list_contours,'String',list);
set(handles.list_contours,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in Load_fusion.
function Load_fusion_Callback(hObject, eventdata, handles)
[selectedImages,OK] = listdlg('PromptString','Which image do you want to add to the fusion rendering list ?',...
    'SelectionMode','multiple',...
    'ListString',handles.ancest.images.name);
if OK==0
    disp('Wrong selection')
    return
end
list = get(handles.list_fusion,'String');
if(isempty(list))
    for i=1:length(selectedImages)
        a = handles.ancest.images.name{selectedImages(i)};
            list{i} = a;
    end
else
    index = get(handles.list_fusion,'Value');
    list_end = list(index+1:end);
    for i=1:length(selectedImages)
        a = handles.ancest.images.name{selectedImages(i)};
        list{index+i} = a;
    end
    list(end+1:end+length(list_end))=list_end;
end
set(handles.list_fusion,'String',list);
set(handles.list_fusion,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in Load_field.
function Load_field_Callback(hObject, eventdata, handles)
[selectedFields,OK] = listdlg('PromptString','Which field do you want to add to the rendering list ?',...
    'SelectionMode','multiple',...
    'ListString',handles.ancest.fields.name);
if OK==0
    disp('Wrong selection')
    return
end
list = get(handles.list_fields,'String');
if(isempty(list))
    for i=1:length(selectedFields)
        a = handles.ancest.fields.name{selectedFields(i)};
        list{i} = a;
    end
else
    index = get(handles.list_fields,'Value');
    list_end = list(index+1:end);
    for i=1:length(selectedFields)
        a = handles.ancest.fields.name{selectedFields(i)};
        list{index+i} = a;
    end
    list(end+1:end+length(list_end))=list_end;
end
set(handles.list_fields,'String',list);
set(handles.list_fields,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in Remove_image.
function Remove_image_Callback(hObject, eventdata, handles)
index = get(handles.list_images,'Value');
list = get(handles.list_images,'String');
for i=1:length(index)
    list = list([1:index-1,index+1:length(list)]);
end
set(handles.list_images,'String',list);
set(handles.list_images,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in remove_contour.
function remove_contour_Callback(hObject, eventdata, handles)
index = get(handles.list_contours,'Value');
list = get(handles.list_contours,'String');
for i=1:length(index)
    list = list([1:index-1,index+1:length(list)]);
end
set(handles.list_contours,'String',list);
set(handles.list_contours,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in Remove_fusion.
function Remove_fusion_Callback(hObject, eventdata, handles)
index = get(handles.list_fusion,'Value');
list = get(handles.list_fusion,'String');
for i=1:length(index)
    list = list([1:index-1,index+1:length(list)]);
end
set(handles.list_fusion,'String',list);
set(handles.list_fusion,'Value',length(list));
guidata(hObject, handles);


% --- Executes on button press in Remove_field.
function Remove_field_Callback(hObject, eventdata, handles)
index = get(handles.list_fields,'Value');
list = get(handles.list_fields,'String');
for i=1:length(index)
    list = list([1:index-1,index+1:length(list)]);
end
set(handles.list_fields,'String',list);
set(handles.list_fields,'Value',length(list));
guidata(hObject, handles);


% --- Executes on selection change in set_view.
function set_view_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        set(handles.set_index,'String',num2str(handles.ancest.view_point(1)));
    case 2
        set(handles.set_index,'String',num2str(handles.ancest.view_point(2)));
    case 3
        set(handles.set_index,'String',num2str(handles.ancest.view_point(3)));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function set_view_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_index_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function set_index_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_image_duration_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function set_image_duration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_fade_duration_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function set_fade_duration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_frame_size_w_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function set_frame_size_w_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_fps_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function set_fps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_frame_size_h_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function set_frame_size_h_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in set_loop.
function set_loop_Callback(hObject, eventdata, handles)

