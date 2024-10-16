function varargout = Create_PBS_plan(varargin)
% CREATE_PBS_PLAN MATLAB code for Create_PBS_plan.fig
%      CREATE_PBS_PLAN, by itself, creates a new CREATE_PBS_PLAN or raises the existing
%      singleton*.
%
%      H = CREATE_PBS_PLAN returns the handle to a new CREATE_PBS_PLAN or the handle to
%      the existing singleton*.
%
%      CREATE_PBS_PLAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_PBS_PLAN.M with the given input arguments.
%
%      CREATE_PBS_PLAN('Property','Value',...) creates a new CREATE_PBS_PLAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Create_PBS_plan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Create_PBS_plan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Create_PBS_plan

% Last Modified by GUIDE v2.5 17-Jun-2016 16:56:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Create_PBS_plan_OpeningFcn, ...
    'gui_OutputFcn',  @Create_PBS_plan_OutputFcn, ...
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


% --- Executes just before Create_PBS_plan is made visible.
function Create_PBS_plan_OpeningFcn(hObject, eventdata, handles, varargin)
if(nargin>2)
    isocenter = varargin{1};
else
    isocenter = [0,0,0];
end
set(handles.edit_isocenter,'String',['[',num2str(isocenter(1)),',',num2str(isocenter(2)),',',num2str(isocenter(3)),']']);
handles.output = [];
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Create_PBS_plan_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on button press in Quit_button.
function Quit_button_Callback(hObject, eventdata, handles)

eval(['isocenter = [',get(handles.edit_isocenter,'String'),'];']);
eval(['gantry_angle = [',get(handles.edit_gantry_angle,'String'),'];']);
eval(['table_angle = [',get(handles.edit_table_angle,'String'),'];']);
eval(['layers = [',get(handles.edit_energy,'String'),'];']);
eval(['field_size = [',get(handles.edit_size_x,'String'),',',get(handles.edit_size_y,'String'),'];']);
eval(['nb_spots = [',get(handles.edit_nb_spots_x,'String'),',',get(handles.edit_nb_spots_y,'String'),'];']);
eval(['weight = [',get(handles.edit_weight,'String'),'];']);

if(size(isocenter,1)<length(gantry_angle))
    isocenter = repmat(isocenter(1,:),length(gantry_angle),1);
end
if(length(table_angle)<length(gantry_angle))
    table_angle = repmat(table_angle(1,:),length(gantry_angle),1);
end
if(size(layers,1)<length(gantry_angle))
    layers = repmat(layers(1,:),length(gantry_angle),1);
end
if(length(field_size)<length(gantry_angle))
    field_size = repmat(field_size(1,:),length(gantry_angle),1);
end
if(length(nb_spots)<length(gantry_angle))
    nb_spots = repmat(nb_spots(1,:),length(gantry_angle),1);
end
if(length(weight)<length(gantry_angle))
    weight = repmat(weight(1,:),length(gantry_angle),1);
end

myBeamData = [];
try
    for n=1:length(gantry_angle)
        myBeamData{n}.isocenter = isocenter(n,:)';
        myBeamData{n}.gantry_angle = gantry_angle(n);
        myBeamData{n}.table_angle = table_angle(n);
        [x,y] = meshgrid(linspace(-field_size(n,1)*10/2,field_size(n,1)*10/2,nb_spots(n,1)),linspace(-field_size(n,2)*10/2,field_size(n,2)*10/2,nb_spots(n,2)));
        x = reshape(x,[nb_spots(n,1)*nb_spots(n,2),1]);
        y = reshape(y,[nb_spots(n,1)*nb_spots(n,2),1]);
        for layer=1:size(layers,2)
            myBeamData{n}.spots(layer).energy = layers(n,layer);
            for spot=1:length(x)
                myBeamData{n}.spots(layer).xy(spot,:) = [x(spot),y(spot)];
                myBeamData{n}.spots(layer).weight(spot,1) = weight(n);
            end
        end
    end
catch
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end

handles.output = myBeamData;
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes during object creation, after setting all properties.
function edit_table_angle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_gantry_angle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_energy_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_isocenter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_nb_spots_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_size_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_nb_spots_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_size_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_weight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_gantry_angle_Callback(hObject, eventdata, handles)

function edit_table_angle_Callback(hObject, eventdata, handles)

function edit_energy_Callback(hObject, eventdata, handles)

function edit_isocenter_Callback(hObject, eventdata, handles)

function edit_nb_spots_x_Callback(hObject, eventdata, handles)

function edit_size_x_Callback(hObject, eventdata, handles)

function edit_nb_spots_y_Callback(hObject, eventdata, handles)

function edit_size_y_Callback(hObject, eventdata, handles)

function edit_weight_Callback(hObject, eventdata, handles)
