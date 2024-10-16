function varargout = rendering_list(varargin)
% RENDERING_LIST M-file for rendering_list.fig
%      RENDERING_LIST, by itself, creates a new RENDERING_LIST or raises the existing
%      singleton*.
%
%      H = RENDERING_LIST returns the handle to a new RENDERING_LIST or the handle to
%      the existing singleton*.
%
%      RENDERING_LIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RENDERING_LIST.M with the given input arguments.
%
%      RENDERING_LIST('Property','Value',...) creates a new RENDERING_LIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rendering_list_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rendering_list_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help rendering_list

% Last Modified by GUIDE v2.5 16-Nov-2017 10:59:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @rendering_list_OpeningFcn, ...
    'gui_OutputFcn',  @rendering_list_OutputFcn, ...
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


% --- Executes just before rendering_list is made visible.
function rendering_list_OpeningFcn(hObject, eventdata, handles, varargin)
handles.ancest = varargin{1};
handles.output = [];
sequences = cell(0);
for i=1:length(handles.ancest.rendering_frames)
    sequences{i} = ['Sequence ',num2str(i)];
end
set(handles.listbox1,'String',sequences);
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rendering_list_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
varargout{2} = handles.ancest;
delete(handles.figure1);


% --- Executes on button press in Movie_button.
function Movie_button_Callback(hObject, eventdata, handles)
sequence_index = get(handles.listbox1,'Value');
default_name = cell(0);
default_name{1} = [handles.ancest.dataPath,'/movie_seq',num2str(sequence_index)];
outputname = char(inputdlg({'Choose a name to export (without file extension)'},' ',1,default_name));
eval(['fps = ',get(handles.set_fps,'String'),';']);
eval(['image_duration = ',get(handles.set_image_duration,'String'),';']);
eval(['fade_duration = ',get(handles.set_fade_duration,'String'),';']);
frame_size = ['[',get(handles.set_frame_size_w,'String'),' ',get(handles.set_frame_size_h,'String'),']'];
loop = get(handles.set_loop,'Value');
handles.output = ['movie_rendering(handles.rendering_frames{',num2str(sequence_index),'},''',outputname,'.gif'',',num2str(fps),',',num2str(image_duration),',',num2str(fade_duration),',',frame_size,',',num2str(loop),',''gif'');'];
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in Images_button.
function Images_button_Callback(hObject, eventdata, handles)
sequence_index = get(handles.listbox1,'Value');
default_name = cell(0);
default_name{1} = [handles.ancest.dataPath,'/image_seq',num2str(sequence_index)];
frame_size = ['[',get(handles.set_frame_size_w,'String'),' ',get(handles.set_frame_size_h,'String'),']'];
outputname = char(inputdlg({'Choose a name to export (without file extension)'},' ',1,default_name));
if(isempty(outputname))
    handles.output = '';
else
handles.output = ['image_rendering(handles.rendering_frames{',num2str(sequence_index),'},''',outputname,''',',frame_size,');'];
end
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
index = get(hObject,'Value');
index = index(1);
nbf = min(size(handles.ancest.rendering_frames{index},4),5);
axes(handles.axes_sequence)
if(nbf>1)
    im_to_show = zeros(size(handles.ancest.rendering_frames{index}(:,:,:,1),1),size(handles.ancest.rendering_frames{index}(:,:,:,1),2)*nbf,3,'uint8');
    for i=1:nbf
        im_to_show(:,1+(i-1)*size(handles.ancest.rendering_frames{index}(:,:,:,1),2):i*size(handles.ancest.rendering_frames{index}(:,:,:,1),2),:) = (handles.ancest.rendering_frames{index}(:,:,:,i));
    end
    imshow(im_to_show)
else
    imshow(handles.ancest.rendering_frames{index}(:,:,:,1));
end


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
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
function set_compression_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function set_compression_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function set_loop_Callback(hObject, eventdata, handles)

