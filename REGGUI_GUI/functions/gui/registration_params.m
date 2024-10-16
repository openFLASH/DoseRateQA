function varargout = registration_params(varargin)
% REGISTRATION_PARAMS M-file for registration_params.fig
%      REGISTRATION_PARAMS, by itself, creates a new REGISTRATION_PARAMS or raises the existing
%      singleton*.
%
%      H = REGISTRATION_PARAMS returns the handle to a new REGISTRATION_PARAMS or the handle to
%      the existing singleton*.
%
%      REGISTRATION_PARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTRATION_PARAMS.M with the given input arguments.
%
%      REGISTRATION_PARAMS('Property','Value',...) creates a new REGISTRATION_PARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before registration_params_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to registration_params_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help registration_params

% Last Modified by GUIDE v2.5 23-Jun-2008 10:29:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @registration_params_OpeningFcn, ...
    'gui_OutputFcn',  @registration_params_OutputFcn, ...
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


% --- Executes just before registration_params is made visible.
function registration_params_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to registration_params (see VARARGIN)

handles.images.name = varargin{1};
handles.ancest = varargin{2};
if(length(varargin)>2)
    handles.framework = varargin{3};
else
    handles.framework = 'non_parametric';
end
if(strcmp(handles.framework,'parametric'))
    set(handles.checkbox4,'Visible','off');
    set(handles.method,'String','B-splines');
    set(handles.mask,'Visible','off');
    set(handles.uipanel5,'Visible','off');
    set(handles.edit7,'Visible','off');
    set(handles.text2,'String','Number of grid points');
end
handles.matitk = 0;
set(handles.fixed_images,'String',handles.images.name);
set(handles.moving_images,'String',handles.images.name);
set(handles.segmentation,'String',handles.images.name);
set(handles.mask,'String',handles.images.name);
handles.output = [];
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = registration_params_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.ancest;
% The figure can be deleted now
delete(handles.figure1);

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
[myReg_Params_Name, myReg_Params_Dir, filterindex] = uigetfile( ...
    {'*.mat','MATLAB Files (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', 'Untitled');
myReg_Params = load(fullfile(myReg_Params_Dir,myReg_Params_Name));
handles = myReg_Params.handles;
put_default(hObject,handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
myReg_Params_Name = inputdlg('Choose a name to save registration parameters');
save(myReg_Params_Name{1});


% --- Executes on button press in Ok_button.
function Ok_button_Callback(hObject, eventdata, handles)
if(strcmp(handles.framework,'parametric'))
    str1 = 'handles = Registration_ITK_bspline(''';
    str2 = get(handles.fixed_images,'String');
    str2 = str2{get(handles.fixed_images,'Value')};
    str3 = get(handles.moving_images,'String');
    str3 = str3{get(handles.moving_images,'Value')};
    str4 = get(handles.segmentation,'String');
    str4 = str4{get(handles.segmentation,'Value')};
    str7 = num2str(get(handles.popupmenu7,'Value'));
    str8 = get(handles.edit1,'String');
    if(isempty(str8))
        str8 = '[]';
    end
    str9 = get(handles.edit2,'String');
    if(isempty(str9))
        str9 = '[]';
    end
    str9bis = ['[',num2str(10*ones(1,get(handles.popupmenu7,'Value'))),']'];
    if(get(handles.checkbox1,'Value'))
        str10 = get(handles.edit3,'String');
        if(isempty(str10))
            str10 = '[]';
        end
        str11 = get(handles.edit4,'String');
        if(isempty(str11))
            str11 = '[]';
        end
    else
        str10 = '[]';
        str11 = '[]';
    end
    str12 = get(handles.output_image,'String');
    str12 = check_existing_names(str12,handles.ancest.images.name);
    str13 = get(handles.output_field,'String');
    str13 = check_existing_names(str13,handles.ancest.fields.name);
    str15 = num2str(get(handles.checkbox3,'Value'));
    myInstruction = ([str1,str2,''',''',str3,''',''',str4,''',',str7,',',str8,',',str9,',',str9bis,',',str10,',',str11,',''',str12,''',''',str13,''',',str15,',handles);']);
else
    str1 = 'handles = Registration_nonrigid(''';
    str2 = get(handles.fixed_images,'String');
    str2 = str2{get(handles.fixed_images,'Value')};
    str3 = get(handles.moving_images,'String');
    str3 = str3{get(handles.moving_images,'Value')};
    str4 = get(handles.segmentation,'String');
    str4 = str4{get(handles.segmentation,'Value')};
    str5 = get(handles.mask,'String');
    str5 = str5{get(handles.mask,'Value')};
    str6 = get(handles.method,'String');
    str6 = str6{get(handles.method,'Value')};
    str7 = num2str(get(handles.popupmenu7,'Value'));
    str8 = get(handles.edit1,'String');
    if(isempty(str8))
        str8 = '[]';
    end
    str9 = get(handles.edit2,'String');
    if(isempty(str9))
        str9 = '[]';
    end
    if(get(handles.checkbox1,'Value'))
        str10 = get(handles.edit3,'String');
        if(isempty(str10))
            str10 = '[]';
        end
        str11 = get(handles.edit4,'String');
        if(isempty(str11))
            str11 = '[]';
        end
    else
        str10 = '[]';
        str11 = '[]';
    end
    str12 = get(handles.output_image,'String');
    str12 = check_existing_names(str12,handles.ancest.images.name);
    str13 = get(handles.output_field,'String');
    str13 = check_existing_names(str13,handles.ancest.fields.name);
    if(get(handles.checkbox4,'Value'))
        str14 = ['''' get(handles.edit7,'String') ''''];
    else
        str14 = '[]';
    end
    str15 = num2str(get(handles.checkbox3,'Value'));
    myInstruction = ([str1,str2,''',''',str3,''',''',str4,''',''',str5,''',''',str6,''',',str7,',',str8,',',str9,',',str10,',',str11,',''',str12,''',''',str13,''',',str14,',',str15,',handles);']);
end
handles.output = myInstruction;
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on selection change in fixed_images.
function fixed_images_Callback(hObject, eventdata, handles)
fixed_list = get(hObject,'String');
list = get(handles.moving_images,'String');
set(handles.output_image,'String',[list{get(handles.moving_images,'Value')} '_def']);
set(handles.output_field,'String',[list{get(handles.moving_images,'Value')} '_to_' fixed_list{get(hObject,'Value')} '_field']);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fixed_images_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in moving_images.
function moving_images_Callback(hObject, eventdata, handles)
list = get(hObject,'String');
fixed_list = get(handles.fixed_images,'String');
set(handles.output_image,'String',[list{get(hObject,'Value')} '_def']);
set(handles.output_field,'String',[list{get(hObject,'Value')} '_to_' fixed_list{get(handles.fixed_images,'Value')}]);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function moving_images_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in segmentation.
function segmentation_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function segmentation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mask.
function mask_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function mask_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in method.
function method_Callback(hObject, eventdata, handles)
current_m = get(hObject,'Value');
if(current_m == 5)
    handles.matitk = 1;
else
    handles.matitk = 0;
end
put_default(hObject,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function method_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
put_default(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function put_default(hObject,handles)
if(handles.matitk)
    set(handles.edit1,'String','[ 150 ]');
    set(handles.edit2,'String','[ 2.0 ]');
    set(handles.edit3,'String','');
    set(handles.edit4,'String','');
    set(handles.popupmenu7,'Value',1);
elseif(strcmp(handles.framework,'parametric'))
    nlevel = get(handles.popupmenu7,'Value');
    myStr1 = '[';
    myStr2 = '[';
    myStr3 = '[';
    myStr4 = '[';
    for i=nlevel:-1:2
        myStr1 = [myStr1,'20,'];
        myStr2 = [myStr2,num2str(2*i+1),','];
        myStr3 = [myStr3,'32,'];
        myStr4 = [myStr4,'100,'];
    end
    myStr1 = [myStr1,'20]'];
    myStr2 = [myStr2,'3]'];
    myStr3 = [myStr3,'32]'];
    myStr4 = [myStr4,'100]'];
    set(handles.edit1,'String',myStr1);
    set(handles.edit2,'String',myStr2);
    if(get(handles.checkbox1,'Value'))
        set(handles.edit3,'String',myStr3);
        set(handles.edit4,'String',myStr4);
    end
else
    switch get(handles.method,'Value')
        case 1 %morphons
            default_numit = '10';
            defautl_sigma = '1.5';
        case {2,3,4} %demons and block matching
            default_numit = '20';
            defautl_sigma = '1.5';
        case 6 %diffeo morphons
            default_numit = '10';
            defautl_sigma = '1.0';
        case {7,8,9} %diffeo demons and diffeo block matching
            default_numit = '20';
            defautl_sigma = '1.0';
        otherwise
            default_numit = '20';
            defautl_sigma = '2';
    end
    nlevel = get(handles.popupmenu7,'Value');
    myStr1 = '[';
    myStr2 = '[';
    myStr3 = '[';
    myStr4 = '[';
    for i=1:nlevel-1
        myStr1 = [myStr1,default_numit,','];
        myStr2 = [myStr2,defautl_sigma,','];
        myStr3 = [myStr3,'32,'];
        myStr4 = [myStr4,'100,'];
    end
    myStr1 = [myStr1,default_numit,']'];
    myStr2 = [myStr2,defautl_sigma,']'];
    myStr3 = [myStr3,'32]'];
    myStr4 = [myStr4,'100]'];
    set(handles.edit1,'String',myStr1);
    set(handles.edit2,'String',myStr2);
    if(get(handles.checkbox1,'Value'))
        set(handles.edit3,'String',myStr3);
        set(handles.edit4,'String',myStr4);
    end
end
guidata(hObject, handles);


function edit1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)



function edit3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output_image_Callback(hObject, eventdata, handles)
% hObject    handle to output_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_image as text
%        str2double(get(hObject,'String')) returns contents of output_image as a double


% --- Executes during object creation, after setting all properties.
function output_image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output_field_Callback(hObject, eventdata, handles)
% hObject    handle to output_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_field as text
%        str2double(get(hObject,'String')) returns contents of output_field as a double


% --- Executes during object creation, after setting all properties.
function output_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


