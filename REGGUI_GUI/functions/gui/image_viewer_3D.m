function varargout = image_viewer_3D(varargin)
% IMAGE_VIEWER_3D M-file for image_viewer_3D.fig
%      IMAGE_VIEWER_3D, by itself, creates a new IMAGE_VIEWER_3D or raises the existing
%      singleton*.
%
%      H = IMAGE_VIEWER_3D returns the handle to a new IMAGE_VIEWER_3D or the handle to
%      the existing singleton*.
%
%      IMAGE_VIEWER_3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_VIEWER_3D.M with the given input arguments.
%
%      IMAGE_VIEWER_3D('Property','Value',...) creates a new IMAGE_VIEWER_3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_viewer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_viewer_3D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help image_viewer_3D

% Last Modified by GUIDE v2.5 21-May-2010 16:51:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @image_viewer_3D_OpeningFcn, ...
    'gui_OutputFcn',  @image_viewer_3D_OutputFcn, ...
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


% --- Executes just before image_viewer_3D is made visible.
function image_viewer_3D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_viewer_3D (see VARARGIN)

handles.image = single(varargin{1});
handles.image = handles.image - min(min(min(handles.image)));
handles.image = handles.image/max(max(max(handles.image)));
handles.info = varargin{2};
[nx ny nz] = size(handles.image);
[handles.x handles.y handles.z] = meshgrid([1:ny]*handles.info.Spacing(2)+handles.info.ImagePositionPatient(2),[1:nx]*handles.info.Spacing(1)+handles.info.ImagePositionPatient(1),[1:nz]*handles.info.Spacing(3)+handles.info.ImagePositionPatient(3));
handles.output = [];
handles.alpha = 0.3;
handles.threshold = 0.5;
handles.threshold2 = 0.5;
handles.angle = 0;
handles.height = 0;
handles.points = [];
try
    handles.size(1) = size(handles.image,1);
    handles.size(2) = size(handles.image,2);
    handles.size(3) = size(handles.image,3);
    handles.minscale = min(min(min(handles.image)));
    handles.maxscale = max(max(max(handles.image)));
    handles.max = handles.maxscale;
    handles.spacing = handles.info.Spacing;
    handles.origin = handles.info.ImagePositionPatient;
    guidata(hObject, handles);
    handles = Plot_image(handles);
    uiwait(handles.figure1);
catch
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    guidata(hObject, handles);
    uiresume(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = image_viewer_3D_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);
disp('3D viewer closed');


function handles = Plot_image(handles)

axes(handles.axes1)
cla

if(get(handles.show_th1,'Value'))
    p = patch(isosurface(handles.x,handles.y,handles.z,handles.image,handles.threshold,'noshare'), 'FaceColor', [0.6 0.5 0.3], 'EdgeColor', 'none');
    isonormals(handles.x,handles.y,handles.z,handles.image,p);
end

if(get(handles.show_th2,'Value'))
    p = patch(isosurface(handles.x,handles.y,handles.z,handles.image,handles.threshold2,'noshare'), 'FaceColor', [0.2 0.2 0.3], 'EdgeColor', 'none');
    isonormals(handles.x,handles.y,handles.z,handles.image,p);
end

if(not(isempty(handles.points)) && get(handles.show_points,'Value'))
   hold on
   plot3(handles.points(:,2),handles.points(:,1),handles.points(:,3),'y.')
   hold off
end

alpha(handles.alpha)
camlight(40, 40);
camlight(-20,-10);
view(handles.angle,handles.height);
box off
axis off

lighting gouraud

guidata(handles.axes1,handles);


% --- Executes on slider movement.
function slider_alpha_Callback(hObject, eventdata, handles)
handles.alpha = get(hObject,'Value');
disp(['Alpha = ',num2str(handles.alpha)])
guidata(hObject, handles);
handles = Plot_image(handles);


% --- Executes during object creation, after setting all properties.
function slider_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_angle1_Callback(hObject, eventdata, handles)
handles.angle = (get(hObject,'Value')-0.5)*360;
disp(['Angle = ',num2str(handles.angle)])
guidata(hObject, handles);
Plot_image(handles);


% --- Executes during object creation, after setting all properties.
function slider_angle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_angle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_angle2_Callback(hObject, eventdata, handles)
handles.height = (get(hObject,'Value')-0.5)*100;
disp(['Height = ',num2str(handles.height)])
guidata(hObject, handles);
Plot_image(handles);


% --- Executes during object creation, after setting all properties.
function slider_angle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_angle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_threshold_Callback(hObject, eventdata, handles)
handles.threshold = get(hObject,'Value');
disp(['Treshold = ',num2str(handles.threshold)])
guidata(hObject, handles);
Plot_image(handles);


% --- Executes during object creation, after setting all properties.
function slider_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider_threshold2_Callback(hObject, eventdata, handles)
handles.threshold2 = get(hObject,'Value');
disp(['Treshold 2 = ',num2str(handles.threshold2)])
guidata(hObject, handles);
Plot_image(handles);


% --- Executes during object creation, after setting all properties.
function slider_threshold2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_threshold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Load_points.
function Load_points_Callback(hObject, eventdata, handles)
try
    [ptFile,ptPath,filterindex] = uigetfile({'*.txt','Text File';'*.mat','Matlab File'}, ...
        eventdata, '');
    myStruct = load(fullfile(ptPath,ptFile));
    list_names = fieldnames(myStruct);
    eval(['handles.points = myStruct.',list_names{1},';'])
    guidata(hObject, handles);
    Plot_image(handles);
catch
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end


% --- Executes on button press in show_th2.
function show_th2_Callback(hObject, eventdata, handles)
% hObject    handle to show_th2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_th2


% --- Executes on button press in show_th1.
function show_th1_Callback(hObject, eventdata, handles)
% hObject    handle to show_th1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_th1


% --- Executes on button press in show_points.
function show_points_Callback(hObject, eventdata, handles)
% hObject    handle to show_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_points







