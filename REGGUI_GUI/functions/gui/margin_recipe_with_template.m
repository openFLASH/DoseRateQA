function varargout = margin_recipe_with_template(varargin)
% MARGIN_RECIPE_WITH_TEMPLATE M-file for margin_recipe_with_template.fig
%      MARGIN_RECIPE_WITH_TEMPLATE, by itself, creates a new MARGIN_RECIPE_WITH_TEMPLATE or raises the existing
%      singleton*.
%
%      H = MARGIN_RECIPE_WITH_TEMPLATE returns the handle to a new MARGIN_RECIPE_WITH_TEMPLATE or the handle to
%      the existing singleton*.
%
%      MARGIN_RECIPE_WITH_TEMPLATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MARGIN_RECIPE_WITH_TEMPLATE.M with the given input arguments.
%
%      MARGIN_RECIPE_WITH_TEMPLATE('Property','Value',...) creates a new MARGIN_RECIPE_WITH_TEMPLATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before margin_recipe_with_template_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to margin_recipe_with_template_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help margin_recipe_with_template

% Last Modified by GUIDE v2.5 20-Jan-2016 14:30:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @margin_recipe_with_template_OpeningFcn, ...
    'gui_OutputFcn',  @margin_recipe_with_template_OutputFcn, ...
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


% --- Executes just before margin_recipe_with_template is made visible.
function margin_recipe_with_template_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to margin_recipe_with_template (see VARARGIN)

handles.currentDir = pwd;
handles.margin_parameters = struct;
handles.margin_parameters.dynamic_jaws = 0;
handles.margin_parameters.field_size_index = 1;
handles.margin_parameters.density_index = 1;
handles.margins = [0 0 0];
handles.coms = [];
close_now = 0;

handles.use_COM = length(varargin)>1;

if(handles.use_COM)
    handles.com_path = varargin{2};
    [handles.patientDir handles.com_filename] = fileparts(handles.com_path);
    handles.margin_filename = ['margin_',handles.com_filename];
    handles.margin_filename = [strrep(strrep(handles.margin_filename,'com_',''),'.mat',''),'.mat'];
    try
        input = load(handles.com_path);
        handles.coms = input.outStruct.data;
    catch
        close_now = 1;
        disp('Failed to open file containing COM coordinates.')
        err = lasterror;
        disp([' ',err.message]);
        disp(err.stack(1));
    end
else
    handles.ancest = varargin{1};
    handles.patientDir = handles.ancest.dataPath;
    handles.com_filename = '';
    handles.margin_filename = '';
    handles.coms = [];
end

try
    image_path = fullfile(fullfile(fullfile(get_reggui_path,'functions'),'gui'),'reggui_images');
    axes(handles.axes1);
    imshow(imread([image_path,'/margins_van_herk.jpg']));
    axes(handles.axes2);
    imshow(imread([image_path,'/margins_van_herk_tm_sys.jpg']));
    axes(handles.axes3);
    imshow(imread([image_path,'/margins_van_herk_baseline_sys.jpg']));
    axes(handles.axes4);
    imshow(imread([image_path,'/margins_van_herk_setup_sys.jpg']));
    axes(handles.axes5);
    imshow(imread([image_path,'/margins_van_herk_tm_al.jpg']));
    axes(handles.axes6);
    imshow(imread([image_path,'/margins_van_herk_baseline_al.jpg']));
    axes(handles.axes7);
    imshow(imread([image_path,'/margins_van_herk_setup_al.jpg']));
    axes(handles.axes8);
    imshow(imread([image_path,'/margins_van_herk_penumbra.jpg']));
    axes(handles.axes9);
    imshow(imread([image_path,'/margins_van_herk_W_sys.jpg']));
    axes(handles.axes10);
    imshow(imread([image_path,'/margins_van_herk_W_al.jpg']));
    axes(handles.axes11);
    imshow(imread([image_path,'/margins_van_herk_del_sys.jpg']));
catch
    disp('Equation images not found !');
end

if(exist(fullfile(handles.patientDir,handles.margin_filename),'file'))
    try
        input = load(fullfile(handles.patientDir,handles.margin_filename));
        handles.margin_parameters= input.output;
        handles = update_parameters(handles);
    catch
    end
end

if(not(isempty(handles.coms)))
    LR = handles.coms(:,1); LR = LR(not(isnan(LR)));
    AP = handles.coms(:,2); AP = AP(not(isnan(AP)));
    SI = handles.coms(:,3); SI = SI(not(isnan(SI)));
    set(handles.stm_LR,'String',num2str(std(LR)));
    set(handles.stm_AP,'String',num2str(std(AP)));
    set(handles.stm_SI,'String',num2str(std(SI)));
end

handles = margin_computation(handles);

% Update handles structure
guidata(hObject, handles);

if(close_now)
    disp('Cannot proceed to margin recipe computation.')
    handles.margins = [];
    guidata(handles.OK_Button,handles);
    uiresume(handles.figure1);
else
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = margin_recipe_with_template_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.margins;
disp('Closing margin recipe gui.')
delete(handles.figure1);


% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
if(handles.use_COM)
    cd(handles.patientDir)
    output = handles.margin_parameters;
    save(handles.margin_filename,'output');
    cd(handles.currentDir)
end
uiresume(handles.figure1);


% --------------------------------------------------
% --- Executes during object creation, after setting all properties.
function TM_LR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function BS_LR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function SETUP_LR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function stm_LR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function sbs_LR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ssetup_LR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function TM_AP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function BS_AP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function SETUP_AP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function stm_AP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function sbs_AP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ssetup_AP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function TM_SI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function BS_SI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function SETUP_SI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function stm_SI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function sbs_SI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ssetup_SI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function W1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function Ws_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function pen_LR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function pen_AP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function pen_SI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_delineation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function field_size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function density_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------



function TM_LR_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function BS_LR_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function SETUP_LR_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function stm_LR_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function sbs_LR_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function ssetup_LR_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function TM_AP_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function BS_AP_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function SETUP_AP_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function stm_AP_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function sbs_AP_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function ssetup_AP_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function TM_SI_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function BS_SI_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function SETUP_SI_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function stm_SI_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function sbs_SI_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function ssetup_SI_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function W1_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function Ws_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function edit21_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function pen_LR_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function pen_AP_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function pen_SI_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function edit_delineation_Callback(hObject, eventdata, handles)
handles = margin_computation(handles);
guidata(hObject,handles)

function field_size_Callback(hObject, eventdata, handles)
handles.margin_parameters.field_size_index = get(hObject,'Value');
handles = pen_computation(handles);
handles = margin_computation(handles);
guidata(hObject,handles)

function density_Callback(hObject, eventdata, handles)
handles.margin_parameters.density_index = get(hObject,'Value');
handles = pen_computation(handles);
handles = margin_computation(handles);
guidata(hObject,handles)

function dynamic_jaws_Callback(hObject, eventdata, handles)
handles.margin_parameters.dynamic_jaws = get(hObject,'Value');
handles = pen_computation(handles);
handles = margin_computation(handles);
guidata(hObject,handles)


% ----------------------------------------------------------------


function handles = margin_computation(handles)
handles.margins = [0 0 0];
handles.margin_parameters.TM_LR = strrep(get(handles.TM_LR,'String'),',','.');
TM_LR = abs(str2double(strrep(get(handles.TM_LR,'String'),',','.')));
handles.margin_parameters.TM_AP = strrep(get(handles.TM_AP,'String'),',','.');
TM_AP = abs(str2double(strrep(get(handles.TM_AP,'String'),',','.')));
handles.margin_parameters.TM_SI = strrep(get(handles.TM_SI,'String'),',','.');
TM_SI = abs(str2double(strrep(get(handles.TM_SI,'String'),',','.')));
handles.margin_parameters.BS_LR = strrep(get(handles.BS_LR,'String'),',','.');
BS_LR = abs(str2double(strrep(get(handles.BS_LR,'String'),',','.')));
handles.margin_parameters.BS_AP = strrep(get(handles.BS_AP,'String'),',','.');
BS_AP = abs(str2double(strrep(get(handles.BS_AP,'String'),',','.')));
handles.margin_parameters.BS_SI = strrep(get(handles.BS_SI,'String'),',','.');
BS_SI = abs(str2double(strrep(get(handles.BS_SI,'String'),',','.')));
handles.margin_parameters.SETUP_LR = strrep(get(handles.SETUP_LR,'String'),',','.');
SETUP_LR = abs(str2double(strrep(get(handles.SETUP_LR,'String'),',','.')));
handles.margin_parameters.SETUP_AP = strrep(get(handles.SETUP_AP,'String'),',','.');
SETUP_AP = abs(str2double(strrep(get(handles.SETUP_AP,'String'),',','.')));
handles.margin_parameters.SETUP_SI = strrep(get(handles.SETUP_SI,'String'),',','.');
SETUP_SI = abs(str2double(strrep(get(handles.SETUP_SI,'String'),',','.')));
handles.margin_parameters.stm_LR = strrep(get(handles.stm_LR,'String'),',','.');
stm_LR = abs(str2double(strrep(get(handles.stm_LR,'String'),',','.')));
handles.margin_parameters.stm_AP = strrep(get(handles.stm_AP,'String'),',','.');
stm_AP = abs(str2double(strrep(get(handles.stm_AP,'String'),',','.')));
handles.margin_parameters.stm_SI = strrep(get(handles.stm_SI,'String'),',','.');
stm_SI = abs(str2double(strrep(get(handles.stm_SI,'String'),',','.')));
handles.margin_parameters.sbs_LR = strrep(get(handles.sbs_LR,'String'),',','.');
sbs_LR = abs(str2double(strrep(get(handles.sbs_LR,'String'),',','.')));
handles.margin_parameters.sbs_AP = strrep(get(handles.sbs_AP,'String'),',','.');
sbs_AP = abs(str2double(strrep(get(handles.sbs_AP,'String'),',','.')));
handles.margin_parameters.sbs_SI = strrep(get(handles.sbs_SI,'String'),',','.');
sbs_SI = abs(str2double(strrep(get(handles.sbs_SI,'String'),',','.')));
handles.margin_parameters.ssetup_LR  = strrep(get(handles.ssetup_LR ,'String'),',','.');
ssetup_LR = abs(str2double(strrep(get(handles.ssetup_LR,'String'),',','.')));
handles.margin_parameters.ssetup_AP = strrep(get(handles.ssetup_AP,'String'),',','.');
ssetup_AP = abs(str2double(strrep(get(handles.ssetup_AP,'String'),',','.')));
handles.margin_parameters.ssetup_SI = strrep(get(handles.ssetup_SI,'String'),',','.');
ssetup_SI = abs(str2double(strrep(get(handles.ssetup_SI,'String'),',','.')));
handles.margin_parameters.pen_LR = strrep(get(handles.pen_LR,'String'),',','.');
pen_LR = abs(str2double(strrep(get(handles.pen_LR,'String'),',','.')));
handles.margin_parameters.pen_AP = strrep(get(handles.pen_AP,'String'),',','.');
pen_AP = abs(str2double(strrep(get(handles.pen_AP,'String'),',','.')));
handles.margin_parameters.pen_SI = strrep(get(handles.pen_SI,'String'),',','.');
pen_SI = abs(str2double(strrep(get(handles.pen_SI,'String'),',','.')));
handles.margin_parameters.W1 = strrep(get(handles.W1,'String'),',','.');
W1 = abs(str2double(strrep(get(handles.W1,'String'),',','.')));
handles.margin_parameters.Ws = strrep(get(handles.Ws,'String'),',','.');
Ws = abs(str2double(strrep(get(handles.Ws,'String'),',','.')));
handles.margin_parameters.delineation = strrep(get(handles.edit_delineation,'String'),',','.');
Del = abs(str2double(strrep(get(handles.edit_delineation,'String'),',','.')));
M_LR = W1 * sqrt( Del^2 + TM_LR^2 + BS_LR^2 + SETUP_LR^2 ) + Ws * sqrt( stm_LR^2 + sbs_LR^2 + ssetup_LR^2 + pen_LR^2 ) - Ws * pen_LR;
M_AP = W1 * sqrt( Del^2 + TM_AP^2 + BS_AP^2 + SETUP_AP^2 ) + Ws * sqrt( stm_AP^2 + sbs_AP^2 + ssetup_AP^2 + pen_AP^2 ) - Ws * pen_AP;
M_SI = W1 * sqrt( Del^2 + TM_SI^2 + BS_SI^2 + SETUP_SI^2 ) + Ws * sqrt( stm_SI^2 + sbs_SI^2 + ssetup_SI^2 + pen_SI^2 ) - Ws * pen_SI;
% Rounding to 1/10mm
M_LR = ceil(M_LR*100-0.001)/100;
M_AP = ceil(M_AP*100-0.001)/100;
M_SI = ceil(M_SI*100-0.001)/100;
set(handles.M_LR,'String',num2str(M_LR));
set(handles.M_AP,'String',num2str(M_AP));
set(handles.M_SI,'String',num2str(M_SI));
handles.margins = [M_LR M_AP M_SI];
handles.margin_parameters.margins = [M_LR M_AP M_SI];
guidata(handles.M_LR, handles);


function handles = pen_computation(handles)
if(handles.margin_parameters.density_index==1)
    density_ratio = 1;
else
    density_ratio = 5.4/3.2;
end
set(handles.pen_LR,'String',num2str(2.7*density_ratio));
set(handles.pen_AP,'String',num2str(2.7*density_ratio));
if(handles.margin_parameters.field_size_index==1) % 2.5cm
    if(handles.margin_parameters.dynamic_jaws==1)
        set(handles.pen_SI,'String',num2str(3.2*density_ratio));
    else
        set(handles.pen_SI,'String',num2str(sqrt( 25^2/12 + (3.2*density_ratio)^2 )));
    end
else % 1cm
    if(handles.margin_parameters.dynamic_jaws==1)
        set(handles.pen_SI,'String',num2str(1.9*density_ratio));
    else
        set(handles.pen_SI,'String',num2str(sqrt( 10^2/12 + (1.9*density_ratio)^2 )));
    end
end


function handles = update_parameters(handles)
set(handles.TM_LR,'String',handles.margin_parameters.TM_LR);
set(handles.TM_AP,'String',handles.margin_parameters.TM_AP);
set(handles.TM_SI,'String',handles.margin_parameters.TM_SI);
set(handles.BS_LR,'String',handles.margin_parameters.BS_LR);
set(handles.BS_AP,'String',handles.margin_parameters.BS_AP);
set(handles.BS_SI,'String',handles.margin_parameters.BS_SI);
set(handles.SETUP_LR,'String',handles.margin_parameters.SETUP_LR);
set(handles.SETUP_AP,'String',handles.margin_parameters.SETUP_AP);
set(handles.SETUP_SI,'String',handles.margin_parameters.SETUP_SI);
set(handles.stm_LR,'String',handles.margin_parameters.stm_LR);
set(handles.stm_AP,'String',handles.margin_parameters.stm_AP);
set(handles.stm_SI,'String',handles.margin_parameters.stm_SI);
set(handles.sbs_LR,'String',handles.margin_parameters.sbs_LR);
set(handles.sbs_AP,'String',handles.margin_parameters.sbs_AP);
set(handles.sbs_SI,'String',handles.margin_parameters.sbs_SI);
set(handles.ssetup_LR,'String',handles.margin_parameters.ssetup_LR);
set(handles.ssetup_AP,'String',handles.margin_parameters.ssetup_AP);
set(handles.ssetup_SI,'String',handles.margin_parameters.ssetup_SI);
set(handles.pen_LR,'String',handles.margin_parameters.pen_LR);
set(handles.pen_AP,'String',handles.margin_parameters.pen_AP);
set(handles.pen_SI,'String',handles.margin_parameters.pen_SI);
set(handles.W1,'String',handles.margin_parameters.W1);
set(handles.Ws,'String',handles.margin_parameters.Ws);
set(handles.edit_delineation,'String',handles.margin_parameters.delineation);
set(handles.field_size,'Value',handles.margin_parameters.field_size_index);
set(handles.density,'Value',handles.margin_parameters.density_index);
set(handles.dynamic_jaws,'Value',handles.margin_parameters.dynamic_jaws);
handles = margin_computation(handles);
guidata(handles.M_LR, handles);


% --- Executes on button press in load_template.
function load_template_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile( ...
    {'*.txt', 'Text files (*.txt)'; ...
    '*.*',                   'All Files (*.*)'}, ...
    'Pick a file',fullfile(fullfile(pwd,'margin_templates'),'*'));

try
    fid=fopen(fullfile(pathname,filename),'r');
    while 1
        tline = fgetl(fid);        
        if ~ischar(tline), break, end      
        eval([tline,';'])
    end
    fclose(fid);
catch
    disp('Error: could not read file')
    return
end

handles.margin_parameters.TM_LR = num2str(SIG_TM_LR);
handles.margin_parameters.TM_AP = num2str(SIG_TM_AP);
handles.margin_parameters.TM_SI = num2str(SIG_TM_SI);
handles.margin_parameters.BS_LR = num2str(SIG_BL_LR);
handles.margin_parameters.BS_AP = num2str(SIG_BL_AP);
handles.margin_parameters.BS_SI = num2str(SIG_BL_SI);
handles.margin_parameters.SETUP_LR = num2str(SIG_SETUP_LR);
handles.margin_parameters.SETUP_AP = num2str(SIG_SETUP_AP);
handles.margin_parameters.SETUP_SI = num2str(SIG_SETUP_SI);
handles.margin_parameters.sbs_LR = num2str(sig_BL_LR);
handles.margin_parameters.sbs_AP = num2str(sig_BL_AP);
handles.margin_parameters.sbs_SI = num2str(sig_BL_SI);
handles.margin_parameters.ssetup_LR = num2str(sig_SETUP_LR);
handles.margin_parameters.ssetup_AP = num2str(sig_SETUP_AP);
handles.margin_parameters.ssetup_SI = num2str(sig_SETUP_SI);
handles.margin_parameters.pen_LR = num2str(sig_PENUM_LR);
handles.margin_parameters.pen_AP = num2str(sig_PENUM_AP);
handles.margin_parameters.pen_SI = num2str(sig_PENUM_SI);
handles.margin_parameters.W1 = num2str(W_SIG);
handles.margin_parameters.Ws = num2str(W_sig);
handles.margin_parameters.delineation = num2str(SIG_DELINEAT);

handles = update_parameters(handles);
guidata(hObject, handles);
