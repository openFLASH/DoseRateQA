function varargout = resample_resize(varargin)
% resample_resize M-file for resample_resize.fig
%      resample_resize, by itself, creates a new resample_resize or raises the existing
%      singleton*.
%
%      H = resample_resize returns the handle to a new resample_resize or the handle to
%      the existing singleton*.
%
%      resample_resize('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in resample_resize.M with the given input arguments.
%
%      resample_resize('Property','Value',...) creates a new resample_resize or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before resample_resize_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to resample_resize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help resample_resize

% Last Modified by GUIDE v2.5 09-Feb-2016 13:22:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @resample_resize_OpeningFcn, ...
    'gui_OutputFcn',  @resample_resize_OutputFcn, ...
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


% --- Executes just before resample_resize is made visible.
function resample_resize_OpeningFcn(hObject, eventdata, handles, varargin)

handles.ancest = varargin{1};
handles.dataType = varargin{2};
handles.modify_origin = 0;

switch handles.dataType
    case 'data'
        set(handles.edit4,'String',1);
        set(handles.edit5,'String',1);
        set(handles.edit6,'String',1);
        set(handles.edit7,'String',1);
        set(handles.edit8,'String',1);
        set(handles.edit9,'String',1);
        set(handles.edit10,'String',1);
        set(handles.edit11,'String',1);
        set(handles.edit12,'String',1);
        set(handles.edit17,'Visible','on');
        set(handles.edit17,'String',num2str(handles.ancest.origin(1)));
        set(handles.edit18,'Visible','on');
        set(handles.edit18,'String',num2str(handles.ancest.origin(2)));
        set(handles.edit19,'Visible','on');
        set(handles.edit19,'String',num2str(handles.ancest.origin(3)));
        set(handles.text9,'Visible','on');
        set(handles.data_selection,'String',handles.ancest.mydata.name);
    case 'field'
        set(handles.edit4,'String',handles.ancest.size(1)+1);
        set(handles.edit5,'String',handles.ancest.size(2)+1);
        set(handles.edit6,'String',handles.ancest.size(3)+1);
        set(handles.edit7,'String',handles.ancest.size(1));
        set(handles.edit8,'String',handles.ancest.size(2));
        set(handles.edit9,'String',handles.ancest.size(3));
        set(handles.edit10,'String',handles.ancest.spacing(1));
        set(handles.edit11,'String',handles.ancest.spacing(2));
        set(handles.edit12,'String',handles.ancest.spacing(3));
        set(handles.data_selection,'String',handles.ancest.fields.name);
    case 'fieldset'
        set(handles.edit4,'String',handles.ancest.size(1)+1);
        set(handles.edit5,'String',handles.ancest.size(2)+1);
        set(handles.edit6,'String',handles.ancest.size(3)+1);
        set(handles.edit7,'String',handles.ancest.size(1));
        set(handles.edit8,'String',handles.ancest.size(2));
        set(handles.edit9,'String',handles.ancest.size(3));
        set(handles.edit10,'String',handles.ancest.spacing(1));
        set(handles.edit11,'String',handles.ancest.spacing(2));
        set(handles.edit12,'String',handles.ancest.spacing(3));
        set(handles.data_selection,'String',handles.ancest.mydata.name);
    case 'all'
        set(handles.edit_output_name,'Visible','off');
        set(handles.edit4,'String',handles.ancest.size(1)+1);
        set(handles.edit5,'String',handles.ancest.size(2)+1);
        set(handles.edit6,'String',handles.ancest.size(3)+1);
        set(handles.edit7,'String',handles.ancest.size(1));
        set(handles.edit8,'String',handles.ancest.size(2));
        set(handles.edit9,'String',handles.ancest.size(3));
        set(handles.edit10,'String',handles.ancest.spacing(1));
        set(handles.edit11,'String',handles.ancest.spacing(2));
        set(handles.edit12,'String',handles.ancest.spacing(3));
        set(handles.data_selection,'String',handles.ancest.mydata.name);
    case 'crop'
        set(handles.edit_output_name,'String','[0]');
        set(handles.edit1,'Visible','off');
        set(handles.edit2,'Visible','off');
        set(handles.edit3,'Visible','off');
        set(handles.edit4,'Visible','off');
        set(handles.edit5,'Visible','off');
        set(handles.edit6,'Visible','off');
        set(handles.edit7,'Visible','off');
        set(handles.edit8,'Visible','off');
        set(handles.edit9,'Visible','off');
        set(handles.edit10,'String',handles.ancest.spacing(1));
        set(handles.edit11,'String',handles.ancest.spacing(2));
        set(handles.edit12,'String',handles.ancest.spacing(3));
        set(handles.data_selection,'String',handles.ancest.images.name);
    case 'grid'
        set(handles.edit_output_name,'String','[0]');
        set(handles.edit1,'Visible','off');
        set(handles.edit2,'Visible','off');
        set(handles.edit3,'Visible','off');
        set(handles.edit4,'Visible','off');
        set(handles.edit5,'Visible','off');
        set(handles.edit6,'Visible','off');
        set(handles.edit7,'Visible','off');
        set(handles.edit8,'Visible','off');
        set(handles.edit9,'Visible','off');
        set(handles.edit10,'Visible','off');
        set(handles.edit11,'Visible','off');
        set(handles.edit12,'Visible','off');
        set(handles.data_selection,'String',handles.ancest.mydata.name);
    otherwise
        set(handles.edit4,'String',handles.ancest.size(1)+1);
        set(handles.edit5,'String',handles.ancest.size(2)+1);
        set(handles.edit6,'String',handles.ancest.size(3)+1);
        set(handles.edit7,'String',handles.ancest.size(1));
        set(handles.edit8,'String',handles.ancest.size(2));
        set(handles.edit9,'String',handles.ancest.size(3));
        set(handles.edit10,'String',handles.ancest.spacing(1));
        set(handles.edit11,'String',handles.ancest.spacing(2));
        set(handles.edit12,'String',handles.ancest.spacing(3));
        set(handles.data_selection,'String',handles.ancest.images.name);
end
handles.output = [];
guidata(hObject, handles);
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = resample_resize_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
varargout{2} = handles.ancest;
delete(handles.figure1);

% -------------------------------------------------------------------
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end% -------------------------------------------------------------------
function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit_output_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit18_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function edit19_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------------------------------------------
function data_selection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -------------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)
a = str2double(get(hObject,'String'));
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSize = size(handles.ancest.mydata.data{dataI});
        if(a>=dataSize(1))
            a = 1;
        end
    else
        return
    end
else
    if(a>=handles.ancest.size(1))
        a = 1;
    end
end
b = str2double(get(handles.edit4,'String'));
d = str2double(get(handles.edit13,'String'));
c = floor((b-a)*d);
b = a+c/(d);
set(handles.edit7,'String',num2str(c));
set(handles.edit4,'String',num2str(b));
set(handles.edit1,'String',num2str(a));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit2_Callback(hObject, eventdata, handles)
a = str2double(get(hObject,'String'));
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSize = size(handles.ancest.mydata.data{dataI});
        if(a>=dataSize(2))
            a = 1;
        end
    else
        return
    end
else
    if(a>=handles.ancest.size(2))
        a = 1;
    end
end
b = str2double(get(handles.edit5,'String'));
d = str2double(get(handles.edit14,'String'));
c = floor((b-a)*d);
b = a+c/d;
set(handles.edit8,'String',num2str(c));
set(handles.edit5,'String',num2str(b));
set(handles.edit2,'String',num2str(a));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit3_Callback(hObject, eventdata, handles)
a = str2double(get(hObject,'String'));
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSize = size(handles.ancest.mydata.data{dataI});
        if(a>=dataSize(3))
            a = 1;
        end
    else
        return
    end
else
    if(a>=handles.ancest.size(3))
        a = 1;
    end
end
b = str2double(get(handles.edit6,'String'));
d = str2double(get(handles.edit15,'String'));
c = floor((b-a)*d);
b = a+c/d;
set(handles.edit9,'String',num2str(c));
set(handles.edit6,'String',num2str(b));
set(handles.edit3,'String',num2str(a));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit4_Callback(hObject, eventdata, handles)
a = str2double(get(handles.edit1,'String'));
b = str2double(get(hObject,'String'));
if(b<=a)
    b = a+1;
end
d = str2double(get(handles.edit13,'String'));
c = floor((b-a)*d);
b = a+c/d;
set(handles.edit7,'String',num2str(c));
set(handles.edit4,'String',num2str(b));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit5_Callback(hObject, eventdata, handles)
a = str2double(get(handles.edit2,'String'));
b = str2double(get(hObject,'String'));
if(b<=a)
    b = a+1;
end
d = str2double(get(handles.edit14,'String'));
c = floor((b-a)*d);
b = a+c/d;
set(handles.edit8,'String',num2str(c));
set(handles.edit5,'String',num2str(b));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit6_Callback(hObject, eventdata, handles)
a = str2double(get(handles.edit3,'String'));
b = str2double(get(hObject,'String'));
if(b<=a)
    b = a+1;
end
d = str2double(get(handles.edit15,'String'));
c = floor((b-a)*d);
b = a+c/d;
set(handles.edit9,'String',num2str(c));
set(handles.edit6,'String',num2str(b));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit7_Callback(hObject, eventdata, handles)
a = str2double(get(handles.edit1,'String'));
c = str2double(get(handles.edit7,'String'));
if(c<=1)
    c = 1;
end
d = str2double(get(handles.edit13,'String'));
b = a+c/d;
c = floor((b-a)*d);
set(handles.edit7,'String',num2str(c));
set(handles.edit4,'String',num2str(b));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit8_Callback(hObject, eventdata, handles)
a = str2double(get(handles.edit2,'String'));
c = str2double(get(handles.edit8,'String'));
if(c<=1)
    c = 1;
end
d = str2double(get(handles.edit14,'String'));
b = a+c/d;
c = floor((b-a)*d);
set(handles.edit8,'String',num2str(c));
set(handles.edit5,'String',num2str(b));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit9_Callback(hObject, eventdata, handles)
a = str2double(get(handles.edit3,'String'));
c = str2double(get(handles.edit9,'String'));
if(c<=1)
    c = 1;
end
d = str2double(get(handles.edit15,'String'));
b = a+c/d;
c = floor((b-a)*d);
set(handles.edit9,'String',num2str(c));
set(handles.edit6,'String',num2str(b));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit10_Callback(hObject, eventdata, handles)
sx = str2double(get(hObject,'String'));
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSpacing = handles.ancest.mydata.info{dataI}.Spacing;
        sx_old = dataSpacing(1);
    else
        return
    end
else
    sx_old = handles.ancest.spacing(1);
end
a = str2double(get(handles.edit1,'String'));
b = str2double(get(handles.edit4,'String'));
d = sx_old / sx;
c = floor((b-a)*d);
b = a+c/d;
if strcmp(handles.dataType,'data')
    if(dataI>1)
        dataSize = size(handles.ancest.mydata.data{dataI});
        if(b>dataSize(1)+1 )
            b = dataSize(1)+1;
            c = floor((b-a)*d);
        end
    end
else
    if(b>handles.ancest.size(1)+1)
        b = handles.ancest.size(1)+1;
        c = floor((b-a)*d);
    end
end
set(handles.edit7,'String',num2str(c));
set(handles.edit4,'String',num2str(b));
set(handles.edit13,'String',num2str(d));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit11_Callback(hObject, eventdata, handles)
sx = str2double(get(hObject,'String'));

if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSpacing = handles.ancest.mydata.info{dataI}.Spacing;
        sx_old = dataSpacing(2);
    else
        return
    end
else
    sx_old = handles.ancest.spacing(2);
end
a = str2double(get(handles.edit2,'String'));
b = str2double(get(handles.edit5,'String'));
d = sx_old / sx;
c = floor((b-a)*d);
b = a+c/d;
if strcmp(handles.dataType,'data')
    if(dataI>1)
        dataSize = size(handles.ancest.mydata.data{dataI});
        if(b>dataSize(2)+1 )
            b = dataSize(2)+1;
            c = floor((b-a)*d);
        end
    end
else
    if(b>handles.ancest.size(2)+1)
        b = handles.ancest.size(2)+1;
        c = floor((b-a)*d);
    end
end
set(handles.edit8,'String',num2str(c));
set(handles.edit5,'String',num2str(b));
set(handles.edit14,'String',num2str(d));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit12_Callback(hObject, eventdata, handles)
sx = str2double(get(hObject,'String'));
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSpacing = handles.ancest.mydata.info{dataI}.Spacing;
        sx_old = dataSpacing(3);
    else
        return
    end
else
    sx_old = handles.ancest.spacing(3);
end
a = str2double(get(handles.edit3,'String'));
b = str2double(get(handles.edit6,'String'));
d = sx_old / sx;
c = floor((b-a)*d);
b = a+c/d;
if strcmp(handles.dataType,'data')
    if(dataI>1)
        dataSize = size(handles.ancest.mydata.data{dataI});
        if(b>dataSize(3)+1 )
            b = dataSize(3)+1;
            c = floor((b-a)*d);
        end
    end
else
    if(b>handles.ancest.size(3)+1)
        b = handles.ancest.size(3)+1;
        c = floor((b-a)*d);
    end
end
set(handles.edit9,'String',num2str(c));
set(handles.edit6,'String',num2str(b));
set(handles.edit15,'String',num2str(d));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit13_Callback(hObject, eventdata, handles)
try
    eval(['d = ' get(hObject,'String') ';']);
catch
    return
end
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSpacing = handles.ancest.mydata.info{dataI}.Spacing;
        sx_old = dataSpacing(1);
    else
        return
    end
else
    sx_old = handles.ancest.spacing(1);
end
a = str2double(get(handles.edit1,'String'));
b = str2double(get(handles.edit4,'String'));
sx = sx_old/d;
c = floor((b-a)*d);
b = a+c/d;
if(d<1)
    set(handles.edit1,'String',num2str(sx/2));
    set(handles.edit4,'String',num2str(b-sx/2));
else
    set(handles.edit4,'String',num2str(b));
end
set(handles.edit7,'String',num2str(c));
set(handles.edit10,'String',num2str(sx));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit14_Callback(hObject, eventdata, handles)
try
    eval(['d = ' get(hObject,'String') ';']);
catch
    return
end
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSpacing = handles.ancest.mydata.info{dataI}.Spacing;
        sx_old = dataSpacing(2);
    else
        return
    end
else
    sx_old = handles.ancest.spacing(2);
end
a = str2double(get(handles.edit2,'String'));
b = str2double(get(handles.edit5,'String'));
sx = sx_old/d;
c = floor((b-a)*d);
b = a+c/d ;
if(d<1)
    set(handles.edit2,'String',num2str(sx/2));
    set(handles.edit5,'String',num2str(b-sx/2));
else
    set(handles.edit5,'String',num2str(b));
end
set(handles.edit8,'String',num2str(c));
set(handles.edit11,'String',num2str(sx));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit15_Callback(hObject, eventdata, handles)
try
    eval(['d = ' get(hObject,'String') ';']);
catch
    return
end

if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSpacing = handles.ancest.mydata.info{dataI}.Spacing;
        sx_old = dataSpacing(3);
    else
        return
    end
else
    sx_old = handles.ancest.spacing(3);
end
a = str2double(get(handles.edit3,'String'));
b = str2double(get(handles.edit6,'String'));
sx = sx_old/d;
c = floor((b-a)*d);
b = a+c/d ;
if(d<1)
    set(handles.edit3,'String',num2str(sx/2));
    set(handles.edit6,'String',num2str(b-sx/2));
else
    set(handles.edit6,'String',num2str(b));
end
set(handles.edit9,'String',num2str(c));
set(handles.edit12,'String',num2str(sx));
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit17_Callback(hObject, eventdata, handles)
handles.modify_origin = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit18_Callback(hObject, eventdata, handles)
handles.modify_origin = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------
function edit19_Callback(hObject, eventdata, handles)
handles.modify_origin = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------
function data_selection_Callback(hObject, eventdata, handles)
if strcmp(handles.dataType,'data')
    dataI = get(handles.data_selection,'Value');
    if(dataI>1)
        dataSpacing = handles.ancest.mydata.info{dataI}.Spacing;
        dataSize = size(handles.ancest.mydata.data{dataI});
        if (isafield(dataSize))
            dataSize = dataSize(2:4);
        end
        set(handles.edit4,'String',dataSize(1)+1);
        set(handles.edit5,'String',dataSize(2)+1);
        set(handles.edit6,'String',dataSize(3)+1);
        set(handles.edit7,'String',dataSize(1));
        set(handles.edit8,'String',dataSize(2));
        set(handles.edit9,'String',dataSize(3));
        set(handles.edit10,'String',dataSpacing(1));
        set(handles.edit11,'String',dataSpacing(2));
        set(handles.edit12,'String',dataSpacing(3));
    end
end

% -------------------------------------------------------------------
function edit_output_name_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------
function ok_button_Callback(hObject, eventdata, handles, dataType)
str2 = get(handles.data_selection,'String');
str2 = str2{get(handles.data_selection,'Value')};
str3 = get(handles.edit1,'String');
if(isempty(str3))
    str3 = '[]';
end
str4 = get(handles.edit2,'String');
if(isempty(str4))
    str4 = '[]';
end
str5 = get(handles.edit3,'String');
if(isempty(str5))
    str5 = '[]';
end
str6 = get(handles.edit7,'String');
if(isempty(str6))
    str6 = '[]';
end
str7 = get(handles.edit8,'String');
if(isempty(str7))
    str7 = '[]';
end
str8 = get(handles.edit9,'String');
if(isempty(str8))
    str8 = '[]';
end
str9 = get(handles.edit10,'String');
if(isempty(str9))
    str9 = '[]';
end
str10 = get(handles.edit11,'String');
if(isempty(str10))
    str10 = '[]';
end
str11 = get(handles.edit12,'String');
if(isempty(str11))
    str11 = '[]';
end
str12 = get(handles.edit_output_name,'String');
if(isempty(str12))
    str12 = str2;
end
if strcmp(handles.dataType,'all')
    if(get(handles.data_selection,'Value')==1)
        myInstruction = ['handles = Resample_all(handles,[', str3, ';', str4, ';', str5, '],[',str6, ';', str7, ';', str8, '],[', str9, ';', str10, ';', str11, ']);'];
    else
        myInstruction = ['handles = Resample_all(handles,''',str2,''');'];
    end
elseif strcmp(handles.dataType,'crop')
    myInstruction = ['handles = Resample_all(handles,''',str2,''',' str12 ',[', str9, ';', str10, ';', str11, '],''from_mask'');'];
elseif strcmp(handles.dataType,'grid')
    myInstruction = ['handles = Resample_all(handles,''',str2,''',[],[],''from_image'');'];    
else
    dataI = get(handles.data_selection,'Value');
    if(dataI<=1)
        myInstruction = '';
    else
        if strcmp(handles.dataType,'data')
            if(handles.modify_origin == 1)
            str_origin = ['[',get(handles.edit17,'String'),';',get(handles.edit18,'String'),';',get(handles.edit19,'String'),']'];
            end
            str1 = 'handles = Data2data(''';
        elseif strcmp(handles.dataType,'field')
            str1 = 'handles = Field2data(''';
        elseif strcmp(handles.dataType,'fieldset')
            str1 = 'handles = Fieldset2data(''';
        else
            str1 = 'handles = Image2data(''';
        end
        if(handles.modify_origin == 1)
            myInstruction = [str1,str2,''',[', str3, ';', str4, ';', str5, '],[',str6, ';', str7, ';', str8, '],[', str9, ';', str10, ';', str11, '],''', str12, ''',handles,',str_origin,');'];
        else
            myInstruction = [str1,str2,''',[', str3, ';', str4, ';', str5, '],[',str6, ';', str7, ';', str8, '],[', str9, ';', str10, ';', str11, '],''', str12, ''',handles);'];
        end
    end
end
handles.output = myInstruction;
guidata(hObject, handles);
uiresume(handles.figure1);

% -------------------------------------------------------------------
function f=isafield(dataSize)
f = (length(dataSize)==4) & (dataSize(1)==3);