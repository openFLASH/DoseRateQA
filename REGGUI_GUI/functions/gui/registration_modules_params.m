function varargout = registration_modules_params(varargin)
% REGISTRATION_MODULES_PARAMS M-file for registration_modules_params.fig
%      REGISTRATION_MODULES_PARAMS, by itself, creates a new REGISTRATION_MODULES_PARAMS or raises the existing
%      singleton*.
%
%      H = REGISTRATION_MODULES_PARAMS returns the handle to a new REGISTRATION_MODULES_PARAMS or the handle to
%      the existing singleton*.
%
%      REGISTRATION_MODULES_PARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTRATION_MODULES_PARAMS.M with the given input arguments.
%
%      REGISTRATION_MODULES_PARAMS('Property','Value',...) creates a new REGISTRATION_MODULES_PARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before registration_modules_params_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to registration_modules_params_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help registration_modules_params

% Last Modified by GUIDE v2.5 15-Oct-2009 12:47:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @registration_modules_params_OpeningFcn, ...
    'gui_OutputFcn',  @registration_modules_params_OutputFcn, ...
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


% --- Executes during object creation, after setting all properties.
function def_field_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function def_image_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function num_of_processes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function num_of_scales_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function moving1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function moving2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function moving3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fixed1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fixed2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fixed3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function reg1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function merging1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function merging2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function merging3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function accumulation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function solidregul_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fluidregul_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function preregul1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function preregul2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function preregul3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function reg2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function reg3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function report_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function iterations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% End of CreateFcn



%% INIT
% --- Executes just before registration_modules_params is made visible.
function registration_modules_params_OpeningFcn(hObject, eventdata, handles, varargin)
handles.ancest = varargin{1};

set(handles.fixed1,'String',handles.ancest.images.name);
set(handles.moving1,'String',handles.ancest.images.name);
set(handles.pre_var1,'String','');

set(handles.fixed2,'Value',1);set(handles.fixed2,'Enable','off');
set(handles.moving2,'Value',1);set(handles.moving2,'Enable','off');
set(handles.fixed3,'Value',1);set(handles.fixed3,'Enable','off');
set(handles.moving3,'Value',1);set(handles.moving3,'Enable','off');
set(handles.reg2,'Value',1);set(handles.reg2,'Enable','off');
set(handles.preregul2,'Value',1);set(handles.preregul2,'Enable','off');
set(handles.merging2,'Value',0.5);set(handles.merging2,'Enable','off');
set(handles.reg3,'Value',1);set(handles.reg3,'Enable','off');
set(handles.preregul3,'Value',1);set(handles.preregul3,'Enable','off');
set(handles.merging3,'Value',0.5);set(handles.merging3,'Enable','off');
set(handles.fixed2,'String','none');
set(handles.moving2,'String','none');
set(handles.fixed3,'String','none');
set(handles.moving3,'String','none');
set(handles.reg2,'String','none');
set(handles.preregul2,'String','none');
set(handles.pre_var2,'String','');
set(handles.reg3,'String','none');
set(handles.preregul3,'String','none');
set(handles.pre_var3,'String','');

handles.report_name_bck = 'report';
handles.discontinuity_mask = 'none';

if(length(varargin)>1)
    handles = set_loaded(varargin{2},handles);
end

handles.output = [];
guidata(hObject, handles);
uiwait(handles.figure1);


% ----------------------------------
function handles = set_loaded(loaded,handles)

set(handles.num_of_processes,'Value',loaded.num_of_processes);
switch loaded.num_of_processes
    case 1
        set(handles.fixed2,'Value',1);set(handles.fixed2,'Enable','off');
        set(handles.moving2,'Value',1);set(handles.moving2,'Enable','off');
        set(handles.fixed3,'Value',1);set(handles.fixed3,'Enable','off');
        set(handles.moving3,'Value',1);set(handles.moving3,'Enable','off');
        set(handles.reg2,'Value',1);set(handles.reg2,'Enable','off');
        set(handles.preregul2,'Value',1);set(handles.preregul2,'Enable','off');
        set(handles.merging2,'Value',0.5);set(handles.merging2,'Enable','off');
        set(handles.reg3,'Value',1);set(handles.reg3,'Enable','off');
        set(handles.preregul3,'Value',1);set(handles.preregul3,'Enable','off');
        set(handles.merging3,'Value',0.5);set(handles.merging3,'Enable','off');
        set(handles.fixed2,'String','none');
        set(handles.moving2,'String','none');
        set(handles.fixed3,'String','none');
        set(handles.moving3,'String','none');
        set(handles.reg2,'String','none');
        set(handles.preregul2,'String','none');
        set(handles.pre_var2,'String','');
        set(handles.reg3,'String','none');
        set(handles.preregul3,'String','none');
        set(handles.pre_var3,'String','');
    case 2
        set(handles.fixed2,'Enable','on');
        set(handles.moving2,'Enable','on');
        set(handles.reg2,'Enable','on');
        set(handles.preregul2,'Enable','on');
        set(handles.merging2,'Enable','on');
        set(handles.fixed2,'String',handles.ancest.images.name);
        set(handles.moving2,'String',handles.ancest.images.name);
        if(strcmp(get(handles.reg2,'String'),'none'))
            set(handles.reg2,'Value',4);
            set(handles.pre_var2,'String','');
        end
        set(handles.reg2,'String',get(handles.reg1,'String'));
        set(handles.preregul2,'String',get(handles.preregul1,'String'));
        set(handles.fixed3,'Value',1);set(handles.fixed3,'Enable','off');
        set(handles.moving3,'Value',1);set(handles.moving3,'Enable','off');
        set(handles.reg3,'Value',1);set(handles.reg3,'Enable','off');
        set(handles.preregul3,'Value',1);set(handles.preregul3,'Enable','off');
        set(handles.merging3,'Value',0.5);set(handles.merging3,'Enable','off');
        set(handles.fixed3,'String','none');
        set(handles.moving3,'String','none');
        set(handles.reg3,'String','none');
        set(handles.preregul3,'String','none');
        set(handles.pre_var3,'String','');
    case 3
        set(handles.fixed2,'Enable','on');
        set(handles.moving2,'Enable','on');
        set(handles.reg2,'Enable','on');
        set(handles.preregul2,'Enable','on');
        set(handles.merging2,'Enable','on');
        set(handles.fixed2,'String',handles.ancest.images.name);
        set(handles.moving2,'String',handles.ancest.images.name);
        if(strcmp(get(handles.reg2,'String'),'none'))
            set(handles.reg2,'Value',4);
            set(handles.pre_var2,'String','');
        end
        set(handles.reg2,'String',get(handles.reg1,'String'));
        set(handles.preregul2,'String',get(handles.preregul1,'String'));
        set(handles.fixed3,'Enable','on');
        set(handles.moving3,'Enable','on');
        set(handles.reg3,'Enable','on');
        set(handles.preregul3,'Enable','on');
        set(handles.merging3,'Enable','on');
        set(handles.fixed3,'String',handles.ancest.images.name);
        set(handles.moving3,'String',handles.ancest.images.name);
        if(strcmp(get(handles.reg3,'String'),'none'))
            set(handles.reg3,'Value',4);
            set(handles.pre_var3,'String','');
        end
        set(handles.reg3,'String',get(handles.reg1,'String'));
        set(handles.preregul3,'String',get(handles.preregul1,'String'));
end

set(handles.def_field_name,'String',loaded.def_field_name);
set(handles.visual,'Value',loaded.visual);
set(handles.logdomain,'Value',loaded.logdomain);
handles.discontinuity_mask = loaded.discontinuity_mask;
if(not(strcmp(handles.discontinuity_mask,'none')||isempty(handles.discontinuity_mask)))
set(handles.checkbox1,'Value',1);
set(handles.checkbox2,'Value',1);
set(handles.checkbox3,'Value',1);
set(handles.discontinuity_mask_txt,'String',['Discontinuity mask : ',handles.discontinuity_mask]);
end
if(not(isempty(loaded.report_name)))
    set(handles.report_name,'String',loaded.report_name);
    handles.report_name_bck = loaded.report_name;
    set(handles.report,'Value',1);
end

set(handles.num_of_scales,'value',loaded.num_of_scales);
if(max(size(unique(loaded.iterations)))==1)
    loaded.iterations = unique(loaded.iterations);
end
set(handles.iterations,'String',['[',num2str(loaded.iterations),']']);
set(handles.fluidregul,'Value',loaded.fluidregul);
if(not(isempty(loaded.fluid_var)))
    if(max(size(unique(loaded.fluid_var)))==1)
        loaded.fluid_var = unique(loaded.fluid_var);
    end
    set(handles.fluid_var,'String',['[',num2str(loaded.fluid_var),']']);
end
set(handles.solidregul,'Value',loaded.solidregul);
if(not(isempty(loaded.solid_var)))
    if(max(size(unique(loaded.solid_var)))==1)
        loaded.solid_var = unique(loaded.solid_var);
    end
    set(handles.solid_var,'String',['[',num2str(loaded.solid_var),']']);
end
set(handles.accumulation,'Value',loaded.accumulation);


% ONE PROCESS
try
    if(sum(strcmp(get(handles.fixed1,'String'),loaded.fixed{1}))==1)
        I = find(strcmp(get(handles.fixed1,'String'),loaded.fixed{1}));
        set(handles.fixed1,'Value',I);
    else
        disp('Warning : image not found ! Replaced by none')
        set(handles.fixed1,'Value',1);
    end
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
try
    if(sum(strcmp(get(handles.moving1,'String'),loaded.moving{1}))==1)
        I = find(strcmp(get(handles.moving1,'String'),loaded.moving{1}));
        set(handles.moving1,'Value',I);
    else
        disp(loaded.moving{1})
        disp(get(handles.moving1,'String'))
        disp('Warning : image not found ! Replaced by none')
        set(handles.moving1,'Value',1);
    end
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
set(handles.reg1,'Value',loaded.reg{1});
set(handles.preregul1,'Value',loaded.preregul{1});
if(not(isempty(loaded.pre_var{1})))
    if(max(size(unique(loaded.pre_var{1})))==1)
        loaded.pre_var{1} = unique(loaded.pre_var{1});
    end
    set(handles.pre_var1,'String',['[',num2str(loaded.pre_var{1}),']']);
end
set(handles.merging1,'Value',loaded.merging{1});



% TWO PROCESSES
if(loaded.num_of_processes>1)
    try
        if(sum(strcmp(get(handles.fixed2,'String'),loaded.fixed{2}))==1)
            I = find(strcmp(get(handles.fixed2,'String'),loaded.fixed{2}));
            set(handles.fixed2,'Value',I);
        else
            disp('Warning : image not found ! Replaced by none')
            set(handles.fixed2,'Value',1);set(handles.fixed2,'Enable','off');
        end
    catch
        disp('Error occured !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    try
        if(sum(strcmp(get(handles.moving2,'String'),loaded.moving{2}))==1)
            I = find(strcmp(get(handles.moving2,'String'),loaded.moving{2}));
            set(handles.moving2,'Value',I);
        else
            disp('Warning : image not found ! Replaced by none')
            set(handles.moving2,'Value',1);set(handles.moving2,'Enable','off');
        end
    catch
        disp('Error occured !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    set(handles.reg2,'Value',loaded.reg{2});
    set(handles.preregul2,'Value',loaded.preregul{2});
    if(not(isempty(loaded.pre_var{2})))
        if(max(size(unique(loaded.pre_var{2})))==1)
            loaded.pre_var{2} = unique(loaded.pre_var{2});
        end
        set(handles.pre_var2,'String',['[',num2str(loaded.pre_var{2}),']']);
    end
    set(handles.merging2,'Value',loaded.merging{2});
end



% THREE PROCESSES
if(loaded.num_of_processes>2)
    try
        if(sum(strcmp(get(handles.fixed3,'String'),loaded.fixed{3}))==1)
            I = find(strcmp(get(handles.fixed3,'String'),loaded.fixed{3}));
            set(handles.fixed3,'Value',I);
        else
            disp('Warning : image not found ! Replaced by none')
            set(handles.fixed3,'Value',1);set(handles.fixed3,'Enable','off');
        end
    catch
        disp('Error occured !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    try
        if(sum(strcmp(get(handles.moving3,'String'),loaded.moving{3}))==1)
            I = find(strcmp(get(handles.moving3,'String'),loaded.moving{3}));
            set(handles.moving3,'Value',I);
        else
            disp('Warning : image not found ! Replaced by none')
            set(handles.moving3,'Value',1);set(handles.moving3,'Enable','off');
        end
    catch
        disp('Error occured !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    set(handles.reg3,'Value',loaded.reg{3});
    set(handles.preregul3,'Value',loaded.preregul{3});
    if(not(isempty(loaded.pre_var{3})))
        if(max(size(unique(loaded.pre_var{3})))==1)
            loaded.pre_var{3} = unique(loaded.pre_var{3});
        end
        set(handles.pre_var3,'String',['[',num2str(loaded.pre_var{3}),']']);
    end
    set(handles.merging3,'Value',loaded.merging{3});
end

guidata(handles.def_field_name,handles);




% --- Outputs from this function are returned to the command line.
function varargout = registration_modules_params_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
varargout{2} = handles.ancest;
delete(handles.figure1);






%% Callbacks ----------------------------------------------------------
% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)

myRegistration = struct;

myRegistration.def_field_name = get(handles.def_field_name,'String');
if(isempty(myRegistration.def_field_name))
    myRegistration.def_field_name = 'def_field';
end
if(get(handles.report,'Value'))
    myRegistration.report_name = get(handles.report_name,'String');
else
    myRegistration.report_name = '';
end
myRegistration.num_of_processes = get(handles.num_of_processes,'Value');
myRegistration.num_of_scales = get(handles.num_of_scales,'Value');
try
    eval(['iterations = ',get(handles.iterations,'String'),';']);
catch
    iterations = '';
end
if(isnumeric(iterations))
    if(length(iterations)<myRegistration.num_of_scales)
        iterations = [iterations,ones(1,myRegistration.num_of_scales-length(iterations))*iterations(end)];
    else
        iterations = iterations(1:myRegistration.num_of_scales);
    end
else
    iterations = 10*ones(1,myRegistration.num_of_scales);
end
myRegistration.iterations = iterations;
myRegistration.logdomain = get(handles.logdomain,'Value');
myRegistration.visual = get(handles.visual,'Value');
myRegistration.discontinuity_mask = handles.discontinuity_mask;
myRegistration.fluidregul = get(handles.fluidregul,'Value');
if(myRegistration.fluidregul>1)
    try
        eval(['fluid_var = ',get(handles.fluid_var,'String'),';']);
    catch
        fluid_var = '';
    end
    if(isnumeric(fluid_var))
        if(length(fluid_var)<myRegistration.num_of_scales)
            fluid_var = [fluid_var,ones(1,myRegistration.num_of_scales-length(fluid_var))*fluid_var(end)];
        else
            fluid_var = fluid_var(1:myRegistration.num_of_scales);
        end
    else
        fluid_var = ones(1,myRegistration.num_of_scales);
    end
    myRegistration.fluid_var = fluid_var;
else
    myRegistration.fluid_var = [];
end

myRegistration.solidregul = get(handles.solidregul,'Value');
if(myRegistration.solidregul>1)
    try
        eval(['solid_var = ',get(handles.solid_var,'String'),';']);
    catch
        solid_var = '';
    end
    if(isnumeric(solid_var))
        if(length(solid_var)<myRegistration.num_of_scales)
            solid_var = [solid_var,ones(1,myRegistration.num_of_scales-length(solid_var))*solid_var(end)];
        else
            solid_var = solid_var(1:myRegistration.num_of_scales);
        end
    else
        solid_var = ones(1,myRegistration.num_of_scales);
    end
    myRegistration.solid_var = solid_var;
else
    myRegistration.solid_var = [];
end

myRegistration.accumulation = get(handles.accumulation,'Value');

fixed = cell(0);
fixed_images = get(handles.fixed1,'String');
fixed{1} = fixed_images{get(handles.fixed1,'Value')};
moving = cell(0);
moving_images = get(handles.moving1,'String');
moving{1} = moving_images{get(handles.moving1,'Value')};
reg = cell(0);
reg{1} = get(handles.reg1,'Value');
merging = cell(0);
merging{1} = get(handles.merging1,'Value');

myRegistration.preregul = cell(0);
myRegistration.preregul{1} = get(handles.preregul1,'Value');
myRegistration.pre_var = cell(0);
if(myRegistration.preregul{1}>1)
    try
        eval(['pre_var = ',get(handles.pre_var1,'String'),';']);
    catch
        pre_var = '';
    end
    if(isnumeric(pre_var))
        if(length(pre_var)<myRegistration.num_of_scales)
            pre_var = [pre_var,ones(1,myRegistration.num_of_scales-length(pre_var))*pre_var(end)];
        else
            pre_var = pre_var(1:myRegistration.num_of_scales);
        end
    else
        pre_var = ones(1,myRegistration.num_of_scales);
    end
    myRegistration.pre_var{1} = pre_var;
else
    myRegistration.pre_var{1} = [];
end

if(myRegistration.num_of_processes>1)
    fixed{2} = fixed_images{get(handles.fixed2,'Value')};
    moving{2} = moving_images{get(handles.moving2,'Value')};
    reg{2} = get(handles.reg2,'Value');
    merging{2} = get(handles.merging2,'Value');
    myRegistration.preregul{2} = get(handles.preregul2,'Value');
    if(myRegistration.preregul{2}>1)
        try
            eval(['pre_var = ',get(handles.pre_var2,'String'),';']);
        catch
            pre_var = '';
        end
        if(isnumeric(pre_var))
            if(length(pre_var)<myRegistration.num_of_scales)
                pre_var = [pre_var,ones(1,myRegistration.num_of_scales-length(pre_var))*pre_var(end)];
            else
                pre_var = pre_var(1:myRegistration.num_of_scales);
            end
        else
            pre_var = ones(1,myRegistration.num_of_scales);
        end
        myRegistration.pre_var{2} = pre_var;
    else
        myRegistration.pre_var{2} = [];
    end
end

if(myRegistration.num_of_processes>2)
    fixed{3} = fixed_images{get(handles.fixed3,'Value')};
    moving{3} = moving_images{get(handles.moving3,'Value')};
    reg{3} = get(handles.reg3,'Value');
    merging{3} = get(handles.merging3,'Value');
    myRegistration.preregul{3} = get(handles.preregul3,'Value');
    if(myRegistration.preregul{3}>1)
        try
            eval(['pre_var = ',get(handles.pre_var3,'String'),';']);
        catch
            pre_var = '';
        end
        if(isnumeric(pre_var))
            if(length(pre_var)<myRegistration.num_of_scales)
                pre_var = [pre_var,ones(1,myRegistration.num_of_scales-length(pre_var))*pre_var(end)];
            else
                pre_var = pre_var(1:myRegistration.num_of_scales);
            end
        else
            pre_var = ones(1,myRegistration.num_of_scales);
        end
        myRegistration.pre_var{3} = pre_var;
    else
        myRegistration.pre_var{3} = [];
    end
end

myRegistration.fixed = fixed;
myRegistration.moving = moving;
myRegistration.reg = reg;
myRegistration.merging = merging;

handles.output = myRegistration;

guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);


% ---------------------------------------
function def_field_name_Callback(hObject, eventdata, handles)


% ---------------------------------------
function report_name_Callback(hObject, eventdata, handles)
if(get(handles.report,'Value'))
handles.report_name_bck = get(hObject,'String');
guidata(hObject,handles)
else
    set(hObject,'String','');
    guidata(hObject,handles)
end


function report_Callback(hObject, eventdata, handles)
if(get(hObject,'Value'))
    if(isempty(get(handles.report_name,'String')))
        set(handles.report_name,'String',handles.report_name_bck);
    end
else
    set(handles.report_name,'String','');
end
guidata(hObject,handles)

% --- Executes on selection change in num_of_processes.
function num_of_processes_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        set(handles.fixed2,'Value',1);set(handles.fixed2,'Enable','off');
        set(handles.moving2,'Value',1);set(handles.moving2,'Enable','off');
        set(handles.fixed3,'Value',1);set(handles.fixed3,'Enable','off');
        set(handles.moving3,'Value',1);set(handles.moving3,'Enable','off');
        set(handles.reg2,'Value',1);set(handles.reg2,'Enable','off');
        set(handles.preregul2,'Value',1);set(handles.preregul2,'Enable','off');
        set(handles.merging2,'Value',0.5);set(handles.merging2,'Enable','off');
        set(handles.reg3,'Value',1);set(handles.reg3,'Enable','off');
        set(handles.preregul3,'Value',1);set(handles.preregul3,'Enable','off');
        set(handles.merging3,'Value',0.5);set(handles.merging3,'Enable','off');
        set(handles.fixed2,'String','none');
        set(handles.moving2,'String','none');
        set(handles.fixed3,'String','none');
        set(handles.moving3,'String','none');
        set(handles.reg2,'String','none');
        set(handles.preregul2,'String','none');
        set(handles.pre_var2,'String','');
        set(handles.reg3,'String','none');
        set(handles.preregul3,'String','none');
        set(handles.pre_var3,'String','');
    case 2
        set(handles.fixed2,'Enable','on');
        set(handles.moving2,'Enable','on');
        set(handles.reg2,'Enable','on');
        set(handles.preregul2,'Enable','on');
        set(handles.merging2,'Enable','on');  
        set(handles.fixed2,'String',handles.ancest.images.name);
        set(handles.moving2,'String',handles.ancest.images.name);
        if(strcmp(get(handles.reg2,'String'),'none'))
            set(handles.reg2,'Value',4);
            set(handles.pre_var2,'String','');
        end
        set(handles.reg2,'String',get(handles.reg1,'String'));
        set(handles.preregul2,'String',get(handles.preregul1,'String'));
        set(handles.fixed3,'Value',1);set(handles.fixed3,'Enable','off');
        set(handles.moving3,'Value',1);set(handles.moving3,'Enable','off');
        set(handles.reg3,'Value',1);set(handles.reg3,'Enable','off');
        set(handles.preregul3,'Value',1);set(handles.preregul3,'Enable','off');
        set(handles.merging3,'Value',0.5);set(handles.merging3,'Enable','off');
        set(handles.fixed3,'String','none');
        set(handles.moving3,'String','none');
        set(handles.reg3,'String','none');
        set(handles.preregul3,'String','none');
        set(handles.pre_var3,'String','');
    case 3
        set(handles.fixed2,'Enable','on');
        set(handles.moving2,'Enable','on');
        set(handles.reg2,'Enable','on');
        set(handles.preregul2,'Enable','on');
        set(handles.merging2,'Enable','on');  
        set(handles.fixed2,'String',handles.ancest.images.name);
        set(handles.moving2,'String',handles.ancest.images.name);
        if(strcmp(get(handles.reg2,'String'),'none'))
            set(handles.reg2,'Value',4);
            set(handles.pre_var2,'String','');
        end
        set(handles.reg2,'String',get(handles.reg1,'String'));
        set(handles.preregul2,'String',get(handles.preregul1,'String'));        
        set(handles.fixed3,'Enable','on');
        set(handles.moving3,'Enable','on');
        set(handles.reg3,'Enable','on');
        set(handles.preregul3,'Enable','on');
        set(handles.merging3,'Enable','on');  
        set(handles.fixed3,'String',handles.ancest.images.name);
        set(handles.moving3,'String',handles.ancest.images.name);
        if(strcmp(get(handles.reg3,'String'),'none'))
            set(handles.reg3,'Value',4);
            set(handles.pre_var3,'String','');
        end
        set(handles.reg3,'String',get(handles.reg1,'String'));
        set(handles.preregul3,'String',get(handles.preregul1,'String'));
end
guidata(hObject, handles);


% --- Executes on selection change in num_of_scales.
function num_of_scales_Callback(hObject, eventdata, handles)
% --- Executes on selection change in fixed1.
function fixed1_Callback(hObject, eventdata, handles)
% --- Executes on selection change in fixed2.
function fixed2_Callback(hObject, eventdata, handles)
% --- Executes on selection change in fixed3.
function fixed3_Callback(hObject, eventdata, handles)
% --- Executes on selection change in moving1.
function moving1_Callback(hObject, eventdata, handles)
% --- Executes on selection change in moving2.
function moving2_Callback(hObject, eventdata, handles)
% --- Executes on selection change in moving3.
function moving3_Callback(hObject, eventdata, handles)
% --- Executes on selection change in reg1.
function reg1_Callback(hObject, eventdata, handles)
% --- Executes on selection change in reg2.
function reg2_Callback(hObject, eventdata, handles)
% --- Executes on selection change in reg3.
function reg3_Callback(hObject, eventdata, handles)


% --- Executes on selection change in preregul1.
function preregul1_Callback(hObject, eventdata, handles)
if(get(hObject,'Value')>1)
    default_answer = cell(0);
    default_answer{1} = get(handles.pre_var1,'String');
    if(isempty(default_answer{1}))
        default_answer{1} = '[1]';
    end
    current_var = inputdlg('Choose gaussian smoothing standard deviation (in voxel)','Setting Properties',1,default_answer);
    set(handles.pre_var1,'String',current_var{1});
else
    set(handles.pre_var1,'String','');
end
guidata(hObject,handles)


% --- Executes on selection change in preregul2.
function preregul2_Callback(hObject, eventdata, handles)
if(get(hObject,'Value')>1)
    default_answer = cell(0);
    default_answer{1} = get(handles.pre_var2,'String');
    if(isempty(default_answer{1}))
        default_answer{1} = '[1]';
    end
    current_var = inputdlg('Choose gaussian smoothing standard deviation (in voxel)','Setting Properties',1,default_answer);
    set(handles.pre_var2,'String',current_var{1});
else
    set(handles.pre_var2,'String','');
end
guidata(hObject,handles)


% --- Executes on selection change in preregul3.
function preregul3_Callback(hObject, eventdata, handles)
if(get(hObject,'Value')>1)
    default_answer = cell(0);
    default_answer{1} = get(handles.pre_var3,'String');
    if(isempty(default_answer{1}))
        default_answer{1} = '[1]';
    end
    current_var = inputdlg('Choose gaussian smoothing standard deviation (in voxel)','Setting Properties',1,default_answer);
    set(handles.pre_var3,'String',current_var{1});
else
    set(handles.pre_var3,'String','');
end
guidata(hObject,handles)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
check = get(hObject,'Value');
if(check)
    try
        [image type] = Image_list(handles.ancest,'Choose a discontinuity mask',1);
        handles.discontinuity_mask = image;
    catch
        type = 0;
    end
    if(not(type==1))
        check = 0;
        set(hObject,'Value',check);
        handles.discontinuity_mask = 'none';
        set(handles.discontinuity_mask_txt,'String','');
    end
else
    handles.discontinuity_mask = 'none';
    set(handles.discontinuity_mask_txt,'String','');
end
set(handles.checkbox2,'Value',check);
set(handles.checkbox3,'Value',check);
if(check)
    set(handles.discontinuity_mask_txt,'String',['Discontinuity mask : ',handles.discontinuity_mask]);
end
guidata(hObject,handles)


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
check = get(hObject,'Value');
if(check)
    try
        [image type] = Image_list(handles.ancest,'Choose a discontinuity mask',1);
        handles.discontinuity_mask = image;
    catch
        type = 0;
    end
    if(not(type==1))
        check = 0;
        set(hObject,'Value',check);
        handles.discontinuity_mask = 'none';
        set(handles.discontinuity_mask_txt,'String','');
    end
else
    handles.discontinuity_mask = 'none';
    set(handles.discontinuity_mask_txt,'String','');
end
set(handles.checkbox1,'Value',check);
set(handles.checkbox3,'Value',check);
if(check)
    set(handles.discontinuity_mask_txt,'String',['Discontinuity mask : ',handles.discontinuity_mask]);
end
guidata(hObject,handles)


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
check = get(hObject,'Value');
if(check)
    try
        [image type] = Image_list(handles.ancest,'Choose a discontinuity mask',1);
        handles.discontinuity_mask = image;
    catch
        type = 0;
    end
    if(not(type==1))
        check = 0;
        set(hObject,'Value',check);
        handles.discontinuity_mask = 'none';
        set(handles.discontinuity_mask_txt,'String','');
    end
else
    handles.discontinuity_mask = 'none';
    set(handles.discontinuity_mask_txt,'String','');
end
set(handles.checkbox1,'Value',check);
set(handles.checkbox2,'Value',check);
if(check)
    set(handles.discontinuity_mask_txt,'String',['Discontinuity mask : ',handles.discontinuity_mask]);
end
guidata(hObject,handles)


% --- Executes on slider movement.
function merging1_Callback(hObject, eventdata, handles)
% --- Executes on slider movement.
function merging2_Callback(hObject, eventdata, handles)
% --- Executes on slider movement.
function merging3_Callback(hObject, eventdata, handles)


% --- Executes on selection change in fluidregul.
function fluidregul_Callback(hObject, eventdata, handles)
if(get(hObject,'Value')>1)
    default_answer = cell(0);
    default_answer{1} = get(handles.fluid_var,'String');
    if(isempty(default_answer{1}))
        default_answer{1} = '[1]';
    end
    current_var = inputdlg('Choose gaussian smoothing standard deviation (in voxel)','Setting Properties',1,default_answer);
    set(handles.fluid_var,'String',current_var{1});
else
    set(handles.fluid_var,'String','');
end
guidata(hObject,handles)


% --- Executes on selection change in accumulation.
function accumulation_Callback(hObject, eventdata, handles)


% --- Executes on selection change in solidregul.
function solidregul_Callback(hObject, eventdata, handles)
if(get(hObject,'Value')>1)
    default_answer = cell(0);
    default_answer{1} = get(handles.solid_var,'String');
    if(isempty(default_answer{1}))
        default_answer{1} = '[1.5]';
    end
    current_var = inputdlg('Choose gaussian smoothing standard deviation (in voxel)','Setting Properties',1,default_answer);
    set(handles.solid_var,'String',current_var{1});
else
    set(handles.solid_var,'String','');
end
guidata(hObject,handles)

% --------------------------------------------------
function iterations_Callback(hObject, eventdata, handles)

% --- Executes on button press in visual.
function visual_Callback(hObject, eventdata, handles)
% --- Executes on button press in logdomain.
function logdomain_Callback(hObject, eventdata, handles)





%% Documentation functions
% --- Executes on button press in what_properties.
function what_properties_Callback(hObject, eventdata, handles)
im = imread('help_im_multi-scaling.png');
try
help_gui(im,'Registration properties',...
         {'Number of processes';'-----------------';...
          '  This framework allows the execution of several displacement estimation processes at the same time (upt to 3). These estimations (deformation';...
          '  fields) are then merged together to create a global transformation based on the different inputs and metrics. For instance, one can perform a';...
          '  registration between anatomical images and, in the same time, between associated masks and merge correspondances from both modalities.';...
          ' ';...
          'Number of scales';'--------------';...
          '  These dense-field registration methods computing local displacement, it is useful to start estimating displacements on sub-sampled images, in';...
          '  in order to be able to catch large displacements (a displacement of 8 pixels will result in only 1 pixel on an image subsampled by 8). The field';...
          '  will then be over-sampled to the next scale as ''initial field'' for the displacement estimation at the finer resolution.';...
          ' ';...
          'Iterations';'-------';...
          '  As the registration is composed of displacement estimation followed by a regularization of the field, the algorithm needs several iterations in';...
          '  order to converge to a proper solution. The number of iteration can be set for each scale (parameter = vector of iteration numbers).'});
catch
end

% --- Executes on button press in what_displ.
function what_displ_Callback(hObject, eventdata, handles)
im = imread('help/help_im_displacement_estimation.png');
try
help_gui(im,'DISPLACEMENT ESTIMATION',...
         {'For each parallel process, based on the fixed and deformed images, a vector will be computed for each voxel (of the fixed image) by estimating the';...
         'most probable destination of this voxel in the neighbouring voxels of the deformed image. This estimation can be based on different metrics:';...
         ' ';...
         '  Sum of square differences : just by looking at small block of voxels (for example a 3x3x3 window), one can choose the vector (+/-1 in every directions)';...
         '  which minimize the SSD between the block (around the considered voxel) in the fixed image and the block around the voxel+vector location in the deformed';...
         '  image.';...
         ' ';...
         '  The demons method uses the gradient in both images to compute the displacement vector direction, while its intensity is relative to the difference';...
         '  in intensity at the considered voxel';...
         ' ';...
         '  The block matching method can also use other kind of measure (metric) that SSD for comparing blocks. For instance, mutual information can be used for';...
         '  comparing images of different modalities.';...
         ' ';...
         '  The morphons method computes the local phase in order to choose the best direction for deformation vectors. The local phase is relative to the local';...
         '  contrast information.';...
         ' ';...
         '(remark: note that one computes also a certainty map, which is a image which tells for each vector how confident one can be about the estimation.)'});
catch
end

% --- Executes on button press in what_preregul.
function what_preregul_Callback(hObject, eventdata, handles)
im = imread('help/help_im_smoothing.png');
try
help_gui(im,'PRE-MERGING REGULARIZATION',...
         {'As the displacement vectors are computed individualy for each voxel, it may be quite irregular. Regularization can be used to reduce the number';...
          'of possible solutions to a set of smooth fields, by smoothing the vector field. This can be performed just after estimation for each process indepently.';...
          'Possible methods are:';...
          ' ';...
          '  Gaussian: simple convolution between the field and a gaussian kernel (parameter = standard deviation (in voxel) of the gaussian).';...
          ' ';...
          '  Normalized gaussian: normalized convolution between the field and a gaussian kernel (parameter = standard deviation (in voxel) of';...
          '  the gaussian), using the certainty map as weighting factors.'});
catch
end

% --- Executes on button press in what_merging.
function what_merging_Callback(hObject, eventdata, handles)
% im = imread('');
try
help_gui([],'MERGING FIELDS',...
         {'This operation will add the fields resulting from the different processes. The sum can be weighted (using the sliding bar).'});
catch
end

% --- Executes on button press in what_fluidregul.
function what_fluidregul_Callback(hObject, eventdata, handles)
im = imread('help/help_im_smoothing.png');
try
help_gui(im,'FLUID REGULARIZATION',...
         {'As the displacement vectors are computed individualy for each voxel, it may be quite irregular. Regularization can be used to reduce the number';...
          'of possible solutions to a set of smooth fields, by smoothing the vector field. Regularization can be applied on the update field (the estimation';...
          'of the deformation between fixed and DEFORMED images). It is called ''fluid'' regularization because it is the increment which is forced to be smooth.';...
          'Possible methods are:';...
          ' ';...
          '  Gaussian: simple convolution between the field and a gaussian kernel (parameter = standard deviation (in voxel) of the gaussian).';...
          ' ';...
          '  Normalized gaussian: normalized convolution between the field and a gaussian kernel (parameter = standard deviation (in voxel) of';...
          '  the gaussian), using the certainty map as weighting factors.'});
catch
end

% --- Executes on button press in what_accumulation.
function what_accumulation_Callback(hObject, eventdata, handles)
% im = imread('');
try
help_gui([],'FIELD ACCUMULATION',...
         {'The accumulation is the operation of adding the update field to the previously accumulated field. Indeed, as the update field is computed based on';...
          'the fixed and DEFORMED images, it does not correspond to the transformation between fixed and MOVING images. The accumulated, on the contrary, represents';...
          'the global transformation between fixed and moving images. Different possibilies exist for accumulating the field:';...
          ' ';...
          '  A simple sum of the fields.';...
          ' ';...
          '  A sum weighted by the corresponding certainty maps.';...
          ' ';...
          '  A diffeomorphic accumulation, which will force the solution to be invertible.'});
catch
end

% --- Executes on button press in what_solidregul.
function what_solidregul_Callback(hObject, eventdata, handles)
im = imread('help/help_im_smoothing.png');
try
help_gui(im,'SOLID REGULARIZATION',...
         {'As the displacement vectors are computed individualy for each voxel, it may be quite irregular. Regularization can be used to reduce the number';...
          'of possible solutions to a set of smooth fields, by smoothing the vector field.  Regularization can be applied on the accumulated field (the ';...
          'estimation of the deformation between fixed and moving images). It is called ''solid'' regularization because it is the global transformation which';...
          'is forced to be smooth in this case. Possible methods are:';...
          ' ';...
          '  Gaussian: simple convolution between the field and a gaussian kernel (parameter = standard deviation (in voxel) of the gaussian).';...
          ' ';...
          '  Normalized gaussian: normalized convolution between the field and a gaussian kernel (parameter = standard deviation (in voxel) of';...
          '  the gaussian), using the certainty map as weighting factors.'});
catch
end

% --- Executes on button press in help_reg.
function help_reg_Callback(hObject, eventdata, handles)
im = imread('help/help_im_modules_registration.png');
try
help_gui(im,'Multiple parallel dense-field registration processes',...
        {'1. Based on the fixed and deformed images, a vector will be computed for each voxel (of the fixed image) by estimating the most probable destination ';...
        'of this voxel in the neighbouring voxels of the deformed image. This estimation can be based on different metrics (sum of square differences, local phase, ...).';...
        'This orperation is performed on each pair of images (fixed-deformed), depending on the number of parallel processes.';...
        ' ';...
        '2. As the displacement vectors are computed individualy for each voxel, it may be quite irregular. Regularization can be used to reduce the number';...
        'of possible solutions to a set of smooth fields, by smoothing the vector field. This can be performed just after estimation for each process indepently.';...
        ' ';...
        '3. As images from different processes must be in the same spatial reference system (the voxel locations are the same everywhere), the deformation fields';...
        'computed in the different parallel processes can be merge together in order to get a global field for all inputs.';...
        ' ';...
        '4. Regularization can be applied on the update field (the estimation of the deformation between fixed and DEFORMED images). It is called ''fluid''';...
        'regularization because it is the increment which is forced to be smooth in this case.';...
        ' ';...
        '5. The accumulation is the operation of adding the update field to the previously accumulated field. Indeed, as the update field is computed based on';...
        'the fixed and DEFORMED images, it does not correspond to the transformation between fixed and MOVING images. The accumulated, on the contrary, represents';...
        'the global transformation between fixed and moving images.';...
        ' ';...
        '6. Regularization can be applied on the accumulated field (the estimation of the deformation between fixed and moving images). It is called ''solid''';...
        'regularization because it is the global transformation which is forced to be smooth in this case.';...
        ' ';...
        '7. At each iteration, the moving image is deformed according to the accumulated field in order to compute the deformed image. Different interpolators can';...
        'be used to ''fill in'' each voxel of the deformed image by the intensity value located at the voxel location incremented by the displacement vector.'});
catch
end





