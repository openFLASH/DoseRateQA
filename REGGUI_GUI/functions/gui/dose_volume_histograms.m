function varargout = dose_volume_histograms(varargin)
% DOSE_VOLUME_HISTOGRAMS M-file for dose_volume_histograms.fig
%      DOSE_VOLUME_HISTOGRAMS, by itself, creates a new DOSE_VOLUME_HISTOGRAMS or raises the existing
%      singleton*.
%
%      H = DOSE_VOLUME_HISTOGRAMS returns the handle to a new DOSE_VOLUME_HISTOGRAMS or the handle to
%      the existing singleton*.
%
%      DOSE_VOLUME_HISTOGRAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOSE_VOLUME_HISTOGRAMS.M with the given input arguments.
%
%      DOSE_VOLUME_HISTOGRAMS('Property','Value',...) creates a new DOSE_VOLUME_HISTOGRAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dose_volume_histograms_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dose_volume_histograms_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Authors : G.Janssens

% Edit the above text to modify the response to help dose_volume_histograms

% Last Modified by GUIDE v2.5 14-Mar-2017 16:27:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @dose_volume_histograms_OpeningFcn, ...
    'gui_OutputFcn',  @dose_volume_histograms_OutputFcn, ...
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

% --- Executes just before dose_volume_histograms is made visible.
function dose_volume_histograms_OpeningFcn(hObject, eventdata, handles, varargin)

% input and default parameters
handles.ancest = varargin{1};
if(isfield(handles.ancest,'dvhs'))
    handles.dvhs = handles.ancest.dvhs;
else
    handles.dvhs = {};
end
handles.interval = [0 100];
handles.legend = cell(0);

% update GUI
handles = update_list(handles);
handles.show_items = ones(length(handles.dvhs),1);
plot_dvhs(handles);
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dose_volume_histograms_OutputFcn(hObject, eventdata, handles)
try
    delete(handles.figure1);
catch
end


% --- Executes on button press in OK_button.
function OK_button_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
uiresume(handles.figure1);


% CREATE FUNCTIONS --------------------------------------------------
% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function D1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function D2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function V1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function Dmean_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function gEUD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function Dp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function D1_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function D2_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function V1_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function select_V_unit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% ------------------------------------------------------------------

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
handles = setLine(handles,line);
guidata(hObject,handles)

% --- Executes on selection change in D1.
function D1_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
handles = setLine(handles,line);
guidata(hObject,handles)

% --- Executes on selection change in D2.
function D2_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
handles = setLine(handles,line);
guidata(hObject,handles)

% --- Executes on selection change in V1.
function V1_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
handles = setLine(handles,line);
guidata(hObject,handles)

% --- Executes on selection change in Dmean.
function Dmean_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
handles = setLine(handles,line);
guidata(hObject,handles)

% --- Executes on selection change in gEUD.
function gEUD_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
handles = setLine(handles,line);
guidata(hObject,handles)

% --- Executes on selection change in Dp.
function Dp_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
handles = setLine(handles,line);
guidata(hObject,handles)

function D1_edit_Callback(hObject, eventdata, handles)
handles = update_list(handles);
guidata(hObject,handles)

function D2_edit_Callback(hObject, eventdata, handles)
handles = update_list(handles);
guidata(hObject,handles)

function V1_edit_Callback(hObject, eventdata, handles)
handles = update_list(handles);
guidata(hObject,handles)


% --- Executes on button press in show_button.
function show_button_Callback(hObject, eventdata, handles)
line = get(handles.listbox1,'Value');
if(line<=length(handles.dvhs))
    handles.show_items(line) = not(handles.show_items(line));
    plot_dvhs(handles);
    guidata(hObject, handles);
end


% --- Executes on button press in hide_all_button.
function hide_all_button_Callback(hObject, eventdata, handles)
handles.show_items = handles.show_items*0;
plot_dvhs(handles);
guidata(hObject, handles);


% --- Executes on button press in set_as_band_button.
function set_as_band_button_Callback(hObject, eventdata, handles)
lines = get(handles.listbox1,'Value');
for line = lines
    if(line<=length(handles.dvhs))
        handles.show_items(line) = 1;
        handles.dvhs{line}.style = 'band';
        plot_dvhs(handles);
        guidata(hObject, handles);
    end
end


% --- Executes on button press in color_button.
function color_button_Callback(hObject, eventdata, handles)
line = get(handles.listbox1,'Value');
color = inputdlg('Color (RGB)','Set color',1,{mat2str(round(handles.dvhs{line(1)}.color*255))});
eval(['color = ',color{1},';']);
if(length(color)==3 && min(color)>=0 && max(color)<256)
    for i=1:length(line)
        if(line(i)<=length(handles.dvhs))
            handles.dvhs{line(i)}.color = color/255;
            handles.dvhs{line(i)}.hexcolor = [dec2hex(round(color(1)),2),dec2hex(round(color(2)),2),dec2hex(round(color(3)),2)];
        end
    end
    handles = update_list(handles);
    plot_dvhs(handles);
    guidata(hObject, handles);
end
    

% --- Executes on button press in Dp_button.
function Dp_button_Callback(hObject, eventdata, handles)
line = get(handles.listbox1,'Value');
Dp = str2double(inputdlg('Prescription'));
for i=1:length(line)
    if(line(i)<=length(handles.dvhs))        
        if(isnumeric(Dp))
            handles.dvhs{line(i)}.Dp = Dp;
        end
    end
end
handles = update_list(handles);
guidata(hObject, handles);


% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
export_fig = figure();
newax = copyobj(handles.axes1,export_fig);
set(newax, 'units', 'normalized', 'position', [0.13 0.11 0.775 0.815]);
fig_name = inputdlg('Choose figure name','DVH export',1,{'dvhs.fig'});
if(isfield(handles.ancest,'dataPath'))
    hgsave(export_fig,fullfile(handles.ancest.dataPath,fig_name{1}));
else
    hgsave(export_fig,fig_name{1});
end
close(export_fig)


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
dvhs = handles.dvhs;
if(isfield(handles.ancest,'dataPath'))
    uisave('dvhs',fullfile(handles.ancest.dataPath,'dvhs.mat'));
else
    uisave('dvhs','dvhs.mat');
end


% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
if(isfield(handles.ancest,'dataPath'))
    [DVHs_Name, DVHs_Dir, filterindex] = uigetfile( ...
        {'*.mat','MATLAB Files (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a file', [handles.ancest.dataPath '/dvhs.mat']);
else
    [DVHs_Name, DVHs_Dir, filterindex] = uigetfile( ...
        {'*.mat','MATLAB Files (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a file', 'dvhs.mat');
end
DVHs_Name = fullfile(DVHs_Dir,DVHs_Name);
if(not(isempty(DVHs_Name)))
    temp = load(DVHs_Name);
    handles.dvhs = temp.dvhs;
    handles = update_list(handles);
    handles.show_items = ones(length(handles.dvhs),1);
    plot_dvhs(handles);
    handles.output = handles.dvhs;
    guidata(hObject, handles);
end


function handles = setLine(handles,line)
set(handles.listbox1,'Value',line);
set(handles.Dp,'Value',line(1));
set(handles.D1,'Value',line(1));
set(handles.D2,'Value',line(1));
set(handles.V1,'Value',line(1));
set(handles.Dmean,'Value',line(1));
set(handles.gEUD,'Value',line(1));


function plot_dvhs(handles)
axes(handles.axes1);
cla
handles.legend = plot_dose_volume_histogram(handles.dvhs,handles.show_items,handles.interval,handles.legend);
guidata(handles.axes1, handles);


function handles = update_list(handles)
myList = cell(0);
myDp = cell(0);
myD1 = cell(0);
myD2 = cell(0);
myV1 = cell(0);
myDmean = cell(0);
mygEUD = cell(0);
for d=1:length(handles.dvhs)
    h = handles.dvhs{d}.dvh;
    h = h./(max(h))*100;
    Dx = handles.dvhs{d}.dvh_X;
    myList{d} = ['<html><font color="#',handles.dvhs{d}.hexcolor,'"><b>',handles.dvhs{d}.dose,' </b> :  ',handles.dvhs{d}.volume,'</font></html>'];
    D = str2double(get(handles.D1_edit,'String'));
    w2 = (h(find(h<D,1)-1)-D)/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
    w1 = (D-h(find(h<D,1)))/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
    myD1{d} = num2str(round((w1*Dx(find(h<D,1)-1)+w2*Dx(find(h<D,1)))*100)/100);
    D = str2double(get(handles.D2_edit,'String'));
    w2 = (h(find(h<D,1)-1)-D)/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
    w1 = (D-h(find(h<D,1)))/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
    myD2{d} = num2str(round((w1*Dx(find(h<D,1)-1)+w2*Dx(find(h<D,1)))*100)/100);
    if(not(isempty(handles.dvhs{d}.Dp)))
        myDp{d} = num2str(round(handles.dvhs{d}.Dp*100)/100);
    end
    if(not(isempty(handles.dvhs{d}.Dp)) || get(handles.select_V_unit,'Value')==1)
        if(get(handles.select_V_unit,'Value')==1)
            V = str2double(get(handles.V1_edit,'String'));% in Gy
        else
            V = str2double(get(handles.V1_edit,'String'))/100*handles.dvhs{d}.Dp;% in %
        end
        if(min(Dx)>V)
            myV1{d} = 100;
        elseif(max(Dx)<V)
            myV1{d} = 0;
        else
            w2 = (Dx(find(Dx>V,1)-1)-V)/(Dx(find(Dx>V,1)-1) - Dx(find(Dx>V,1)) + eps);
            w1 = (V-Dx(find(Dx>V,1)))/(Dx(find(Dx>V,1)-1) - Dx(find(Dx>V,1)) + eps);
            myV1{d} = num2str(round((w1*h(find(Dx>V,1)-1)+w2*h(find(Dx>V,1)))*100)/100);
        end
    end
    myDmean{d} = num2str(round(handles.dvhs{d}.dmean*100)/100);
    mygEUD{d} = num2str(round(handles.dvhs{d}.geud*100)/100);
end
myList{length(handles.dvhs)+1} = '';
myDp{length(handles.dvhs)+1} = '';
myD1{length(handles.dvhs)+1} = '';
myD2{length(handles.dvhs)+1} = '';
myV1{length(handles.dvhs)+1} = '';
myDmean{length(handles.dvhs)+1} = '';
mygEUD{length(handles.dvhs)+1} = '';
set(handles.listbox1,'String',myList)
set(handles.Dp,'String',myDp)
set(handles.D1,'String',myD1)
set(handles.D2,'String',myD2)
set(handles.V1,'String',myV1)
set(handles.Dmean,'String',myDmean)
set(handles.gEUD,'String',mygEUD)


% --- Executes on selection change in select_V_unit.
function select_V_unit_Callback(hObject, eventdata, handles)
handles = update_list(handles);
guidata(handles.axes1,handles);

% --------------------------------------------------------------------
function uitoggletool1_ClickedCallback(hObject, eventdata, handles)
axes(handles.axes1)
datacursormode toggle
guidata(hObject,handles)
% --------------------------------------------------------------------
function uitoggletool2_ClickedCallback(hObject, eventdata, handles)
axes(handles.axes1)
zoom on
guidata(hObject,handles)
% --------------------------------------------------------------------
function uitoggletool3_ClickedCallback(hObject, eventdata, handles)
axes(handles.axes1)
zoom out
guidata(hObject,handles)
% --------------------------------------------------------------------
function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
axes(handles.axes1)
pan
guidata(hObject,handles)

