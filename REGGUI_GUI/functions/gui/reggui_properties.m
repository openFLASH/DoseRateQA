function varargout = reggui_properties(varargin)
% REGGUI_PROPERTIES M-file for reggui_properties.fig
%      REGGUI_PROPERTIES, by itself, creates a new REGGUI_PROPERTIES or raises the existing
%      singleton*.
%
%      H = REGGUI_PROPERTIES returns the handle to a new REGGUI_PROPERTIES or the handle to
%      the existing singleton*.
%
%      REGGUI_PROPERTIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGGUI_PROPERTIES.M with the given input arguments.
%
%      REGGUI_PROPERTIES('Property','Value',...) creates a new REGGUI_PROPERTIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before reggui_properties_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to reggui_properties_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help reggui_properties

% Last Modified by GUIDE v2.5 26-Feb-2016 16:59:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @reggui_properties_OpeningFcn, ...
    'gui_OutputFcn',  @reggui_properties_OutputFcn, ...
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


% --- Executes just before reggui_properties is made visible.
function reggui_properties_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to reggui_properties (see VARARGIN)

handles.ancest = varargin{1};
handles.images = handles.ancest.images;
handles.fields = handles.ancest.fields;
handles.mydata = handles.ancest.mydata;
handles.plans = handles.ancest.plans;
handles.meshes = handles.ancest.meshes;
handles.registrations = handles.ancest.registrations;
handles.indicators = handles.ancest.indicators;
handles.proj_prop = cell(0);
handles.data_prop = cell(0);
set(handles.data_type_menu,'Value',1);
set(handles.data_menu,'String',handles.ancest.images.name);
handles.current = handles.ancest.images.data{1};
handles.proj_prop{2} = 'Size :                                                                ';
handles.proj_prop{3} = [num2str(handles.ancest.size(1)) '  ' num2str(handles.ancest.size(2)) '  ' num2str(handles.ancest.size(3))];
handles.proj_prop{5} = 'Spacing :                                                          ';
handles.proj_prop{6} = [num2str(handles.ancest.spacing(1)) '  ' num2str(handles.ancest.spacing(2)) '  ' num2str(handles.ancest.spacing(3))];
handles.proj_prop{8} = 'Origin :                                                            ';
handles.proj_prop{9} = [num2str(handles.ancest.origin(1)) '  ' num2str(handles.ancest.origin(2)) '  ' num2str(handles.ancest.origin(3))];
set(handles.text4,'String',handles.proj_prop);
handles.data_prop{2} = ['Minimum value  ' ];
handles.data_prop{6} = ['Maximum value  ' ];
handles.data_prop{10} = ['Mean value  ' ];
set(handles.text5,'String',handles.data_prop);
handles.info_prop{2} = 'Size :                                                                ';
handles.info_prop{5} = 'Spacing :                                                          ';
handles.info_prop{8} = 'Origin :                                                            ';
handles.info_prop{12} = '[Type]                                                               ';
set(handles.text7,'String',handles.info_prop);
handles.output = struct;
handles.output.registrations = handles.registrations;
handles.output.indicators = handles.indicators;
plot_histo(0,[],handles);
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = reggui_properties_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
varargout{2} = handles.ancest;
delete(handles.figure1);


% --- Executes on selection change in data_type_menu.
function data_type_menu_Callback(hObject, eventdata, handles)
for i=1:length(handles.info_prop)
    handles.info_prop{i} = ' ';
end
for i=1:length(handles.data_prop)
    handles.data_prop{i} = ' ';
end
choice = get(hObject,'Value');
switch choice
    case 1
        set(handles.data_menu,'Value',1);
        set(handles.data_menu,'String',handles.ancest.images.name);
        handles.current = handles.ancest.images.data{1};
        handles.data_prop{2} = 'Minimum value';
        handles.data_prop{6} = 'Maximum value';
        handles.data_prop{10} = 'Mean value';
        handles.info_prop{12} = '[Type]                                                               ';
        set(handles.edit_button,'Visible','on');
        set(handles.button_header,'Visible','on');
        set(handles.button_3D,'Visible','on');
        set(handles.button_view,'Visible','on');
    case 2
        set(handles.data_menu,'Value',1);
        set(handles.data_menu,'String',handles.ancest.fields.name);
        handles.current = handles.ancest.fields.data{1};
        handles.info_prop{12} = '[Type]                                                               ';
        set(handles.edit_button,'Visible','on');
        set(handles.button_header,'Visible','off');
        set(handles.button_3D,'Visible','off');
        set(handles.button_view,'Visible','on');
    case 3
        set(handles.data_menu,'Value',1);
        set(handles.data_menu,'String',handles.ancest.mydata.name);
        handles.current = handles.ancest.mydata.data{1};
        handles.data_prop{2} = 'Minimum value';
        handles.data_prop{6} = 'Maximum value';
        handles.data_prop{10} = 'Mean value';
        handles.info_prop{12} = '[Type]                                                               ';
        set(handles.edit_button,'Visible','on');
        set(handles.button_header,'Visible','on');
        set(handles.button_3D,'Visible','on');
        set(handles.button_view,'Visible','on');
    case 4
        set(handles.data_menu,'Value',1);
        set(handles.data_menu,'String',handles.ancest.plans.name);
        handles.current = handles.ancest.plans.data{1};
        handles.info_prop{12} = '[Type]                                                               ';
        set(handles.edit_button,'Visible','on');
        set(handles.button_header,'Visible','on');
        set(handles.button_3D,'Visible','off');
        set(handles.button_view,'Visible','on');
    case 5
        set(handles.data_menu,'Value',1);
        set(handles.data_menu,'String',handles.ancest.meshes.name);
        handles.current = handles.ancest.meshes.data{1};
        handles.info_prop{12} = '[Type]                                                               ';
        set(handles.edit_button,'Visible','on');
        set(handles.button_header,'Visible','off');
        set(handles.button_3D,'Visible','off');
        set(handles.button_view,'Visible','off');
    case 6
        set(handles.data_menu,'Value',1);
        set(handles.data_menu,'String',handles.ancest.registrations.name);
        handles.current = handles.ancest.registrations.data{1};
        handles.info_prop{12} = '[Type]                                                               ';
        set(handles.edit_button,'Visible','off');
        set(handles.button_header,'Visible','off');
        set(handles.button_3D,'Visible','off');
        set(handles.button_view,'Visible','off');
    case 7
        set(handles.data_menu,'Value',1);
        set(handles.data_menu,'String',handles.ancest.indicators.name);
        handles.current = handles.ancest.indicators.data{1};
        handles.info_prop{12} = '[Type]                                                               ';
        set(handles.edit_button,'Visible','off');
        set(handles.button_header,'Visible','off');
        set(handles.button_3D,'Visible','off');
        set(handles.button_view,'Visible','off');
end
set(handles.text7,'String',handles.info_prop);
set(handles.text5,'String',handles.data_prop);
plot_histo(0,[],handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function data_type_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in data_menu.
function data_menu_Callback(hObject, eventdata, handles)
for i=1:length(handles.data_prop)
    handles.data_prop{i} = ' ';
end
choice = get(handles.data_type_menu,'Value');
switch choice
    case 1
        handles.data_prop{2} = 'Minimum value';
        handles.data_prop{6} = 'Maximum value';
        handles.data_prop{10} = 'Mean value';
    case 3
        handles.data_prop{2} = 'Minimum value';
        handles.data_prop{6} = 'Maximum value';
        handles.data_prop{10} = 'Mean value';
    case 4
        handles.data_prop{2} = 'Isocenter [mm]';
        handles.data_prop{5} = 'Gantry angle';
        handles.data_prop{8} = 'Table angle';
        handles.data_prop{11} = 'Sum of weights';
end
handles.info_prop{3} = ' ';
handles.info_prop{6} = ' ';
handles.info_prop{9} = ' ';
handles.info_prop{12} = '[Type]                                                               ';
choice = get(handles.data_type_menu,'Value');
index = get(hObject,'Value');
switch choice
    case 1
        handles.current = handles.ancest.images.data{index};
        if(~isempty(handles.current))
            handles.data_prop{3} = num2str(min(min(min(handles.current))));
            handles.data_prop{7} = num2str(max(max(max(handles.current))));
            handles.data_prop{11} = num2str(mean(mean(mean(handles.current))));
            handles.info_prop{3} = [num2str(size(handles.ancest.images.data{index},1)) '  ' num2str(size(handles.ancest.images.data{index},2)) '  ' num2str(size(handles.ancest.images.data{index},3))];
            handles.info_prop{6} = [num2str(handles.ancest.images.info{index}.Spacing(1)) '  ' num2str(handles.ancest.images.info{index}.Spacing(2)) '  ' num2str(handles.ancest.images.info{index}.Spacing(3))];
            handles.info_prop{9} = [num2str(handles.ancest.images.info{index}.ImagePositionPatient(1)) '  ' num2str(handles.ancest.images.info{index}.ImagePositionPatient(2)) '  ' num2str(handles.ancest.images.info{index}.ImagePositionPatient(3))];
            try
                handles.info_prop{12} = ['[Type = ' handles.ancest.images.info{index}.Type ']'];
            catch
                handles.info_prop{12} = '[Unknown type]                                                      ';
            end
        end
    case 2
        handles.current = round(handles.ancest.fields.data{index}*1000)/1000;
        if(~isempty(handles.current))
            if(strcmp(handles.ancest.fields.info{index}.Type,'deformation_field'))
                handles.data_prop{2} = 'Min values (x,y,z)';
                handles.data_prop{6} = 'Max values (x,y,z)';
                handles.data_prop{10} = 'Mean values (x,y,z)';
                if(handles.ancest.size(3) == 1)
                    handles.data_prop{3} = [num2str(min(min(min(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(min(min(min(squeeze(handles.current(2,:,:,:))))))];
                    handles.data_prop{7} = [num2str(max(max(max(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(max(max(max(squeeze(handles.current(2,:,:,:))))))];
                    handles.data_prop{11} = [num2str(mean(mean(mean(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(mean(mean(mean(squeeze(handles.current(2,:,:,:))))))];
                else
                    handles.data_prop{3} = [num2str(min(min(min(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(min(min(min(squeeze(handles.current(2,:,:,:)))))) '  ' num2str(min(min(min(squeeze(handles.current(3,:,:,:))))))];
                    handles.data_prop{7} = [num2str(max(max(max(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(max(max(max(squeeze(handles.current(2,:,:,:)))))) '  ' num2str(max(max(max(squeeze(handles.current(3,:,:,:))))))];
                    handles.data_prop{11} = [num2str(mean(mean(mean(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(mean(mean(mean(squeeze(handles.current(2,:,:,:)))))) '  ' num2str(mean(mean(mean(squeeze(handles.current(3,:,:,:))))))];
                end
                handles.info_prop{3} = [num2str(size(handles.ancest.fields.data{index},1)) '  ' num2str(size(handles.ancest.fields.data{index},2)) '  ' num2str(size(handles.ancest.fields.data{index},3)) '  ' num2str(size(handles.ancest.fields.data{index},4))];
            elseif(strcmp(handles.ancest.fields.info{index}.Type,'rigid_transform'))
                handles.data_prop{2} = 'Translation :';
                handles.data_prop{3} = [num2str(handles.current(2,1)) ' ' num2str(handles.current(2,2)) ' ' num2str(handles.current(2,3)) ' [mm]'];
                handles.data_prop{6} = 'Rotation matrix:';
                handles.data_prop{7} = [num2str(handles.current(3,1)) ' ' num2str(handles.current(3,2)) ' ' num2str(handles.current(3,3))];
                handles.data_prop{8} = [num2str(handles.current(4,1)) ' ' num2str(handles.current(4,2)) ' ' num2str(handles.current(4,3))];
                handles.data_prop{9} = [num2str(handles.current(5,1)) ' ' num2str(handles.current(5,2)) ' ' num2str(handles.current(5,3))];
                handles.info_prop{3} = [num2str(size(handles.ancest.fields.data{index},1)) '  ' num2str(size(handles.ancest.fields.data{index},2)) '  ' num2str(size(handles.ancest.fields.data{index},3))];
                choice = 0;
            end
            handles.info_prop{6} = [num2str(handles.ancest.fields.info{index}.Spacing(1)) '  ' num2str(handles.ancest.fields.info{index}.Spacing(2)) '  ' num2str(handles.ancest.fields.info{index}.Spacing(3))];
            handles.info_prop{9} = [num2str(handles.ancest.fields.info{index}.ImagePositionPatient(1)) '  ' num2str(handles.ancest.fields.info{index}.ImagePositionPatient(2)) '  ' num2str(handles.ancest.fields.info{index}.ImagePositionPatient(3))];
            try
                handles.info_prop{12} = ['[Type = ' handles.ancest.fields.info{index}.Type ']'];
            catch
                handles.info_prop{12} = '[Unknown type]                                                      ';
            end
        end
    case 3
        handles.current = handles.ancest.mydata.data{index};
        if(~isempty(handles.current))
            try
                handles.data_prop{3} = '';
                handles.data_prop{7} = '';
                handles.data_prop{11} = '';
                handles.info_prop{6} = [num2str(handles.ancest.mydata.info{index}.Spacing(1)) '  ' num2str(handles.ancest.mydata.info{index}.Spacing(2)) '  ' num2str(handles.ancest.mydata.info{index}.Spacing(3))];
                handles.info_prop{9} = [num2str(handles.ancest.mydata.info{index}.ImagePositionPatient(1)) '  ' num2str(handles.ancest.mydata.info{index}.ImagePositionPatient(2)) '  ' num2str(handles.ancest.mydata.info{index}.ImagePositionPatient(3))];
                if(strcmp(handles.ancest.mydata.info{index}.Type,'image'))
                    handles.data_prop{3} = num2str(min(min(min(handles.current))));
                    handles.data_prop{7} = num2str(max(max(max(handles.current))));
                    handles.data_prop{11} = num2str(mean(mean(mean(handles.current))));
                    handles.info_prop{3} = [num2str(size(handles.ancest.mydata.data{index},1)) '  ' num2str(size(handles.ancest.mydata.data{index},2)) '  ' num2str(size(handles.ancest.mydata.data{index},3))];
                    choice = 1;
                elseif(strcmp(handles.ancest.mydata.info{index}.Type,'deformation_field'))
                    if(handles.ancest.size(3) == 1)
                        handles.data_prop{3} = [num2str(min(min(min(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(min(min(min(squeeze(handles.current(2,:,:,:))))))];
                        handles.data_prop{7} = [num2str(max(max(max(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(max(max(max(squeeze(handles.current(2,:,:,:))))))];
                        handles.data_prop{11} = [num2str(mean(mean(mean(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(mean(mean(mean(squeeze(handles.current(2,:,:,:))))))];
                    else
                        handles.data_prop{3} = [num2str(min(min(min(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(min(min(min(squeeze(handles.current(2,:,:,:)))))) '  ' num2str(min(min(min(squeeze(handles.current(3,:,:,:))))))];
                        handles.data_prop{7} = [num2str(max(max(max(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(max(max(max(squeeze(handles.current(2,:,:,:)))))) '  ' num2str(max(max(max(squeeze(handles.current(3,:,:,:))))))];
                        handles.data_prop{11} = [num2str(mean(mean(mean(squeeze(handles.current(1,:,:,:)))))) '  ' num2str(mean(mean(mean(squeeze(handles.current(2,:,:,:)))))) '  ' num2str(mean(mean(mean(squeeze(handles.current(3,:,:,:))))))];
                    end
                    handles.info_prop{3} = [num2str(size(handles.ancest.mydata.data{index},1)) '  ' num2str(size(handles.ancest.mydata.data{index},2)) '  ' num2str(size(handles.ancest.mydata.data{index},3)) '  ' num2str(size(handles.ancest.mydata.data{index},4))];
                    choice = 2;
                elseif(strcmp(handles.ancest.mydata.info{index}.Type,'rigid_transform'))
                    handles.data_prop{11} = [num2str(handles.current(2,1)) ' ' num2str(handles.current(2,2)) ' ' num2str(handles.current(2,3)) ' [mm]'];
                    handles.info_prop{3} = [num2str(size(handles.ancest.mydata.data{index},1)) '  ' num2str(size(handles.ancest.mydata.data{index},2)) '  ' num2str(size(handles.ancest.mydata.data{index},3))];
                    choice = 0;
                elseif(strcmp(handles.ancest.mydata.info{index}.Type,'point'))
                    handles.data_prop{11} = [num2str(handles.current(1)) ' ' num2str(handles.current(2)) ' ' num2str(handles.current(3))];
                    choice = 0;
                end
                try
                    handles.info_prop{12} = ['[Type = ' handles.ancest.mydata.info{index}.Type ']'];
                catch
                    handles.info_prop{12} = '[Unknown type]                                                      ';
                end
            catch
            end
        end
    case 4
        if(index>1)
            beams = handles.ancest.plans.data{index};
            gantry_str = '';
            table_str = '';
            isocenter_str = '';
            total_weight_str = '';
            for f = 1:length(beams)
                gantry_str = [gantry_str,'beam',num2str(f),': ',num2str(beams{f}.gantry_angle),'; '];
                table_str = [table_str,'beam',num2str(f),': ',num2str(beams{f}.table_angle),'; '];
                isocenter_str = [isocenter_str,'beam',num2str(f),': ',num2str(beams{f}.isocenter(1)),',',num2str(beams{f}.isocenter(2)),',',num2str(beams{f}.isocenter(3)),'; '];
                total_weight = 0;
                if(isfield(beams{f},'spots'))
                    for i=1:length(beams{f}.spots)
                        total_weight = total_weight + sum(beams{f}.spots(i).weight);
                    end
                end
                total_weight_str = [total_weight_str,'beam',num2str(f),': ',num2str(total_weight),'; '];
            end
            handles.data_prop{3} = isocenter_str;
            handles.data_prop{6} = gantry_str;
            handles.data_prop{9} = table_str;
            handles.data_prop{12} = total_weight_str;
            try
                handles.info_prop{12} = ['[Type = ' handles.ancest.plans.info{index}.Type ']'];
            catch
                handles.info_prop{12} = '[Unknown type]                                                      ';
            end
        end
    case 5
        if(index>1)
            try
                handles.info_prop{12} = ['[Type = ' handles.ancest.meshes.info{index}.Type ']'];
            catch
                handles.info_prop{12} = '[Unknown type]                                                      ';
            end
        end
    case 6
        if(index>1)
            try
                [m,handles] = registration_modules_params(handles,handles.registrations.data{index});
                if(not(isempty(m)))
                    handles.registrations.data{index} = m;
                end
                handles.current = 0;
            catch
                err = lasterror;
                disp(['    ',err.message]);
                disp(err.stack(1));
            end
        end
    case 7
        if(index>1)
            try
                m = Create_indicators(handles,handles.indicators.data{index});
                if(not(isempty(m)))
                    handles.indicators.data{index} = m;
                end
                handles.current = 0;
            catch
                err = lasterror;
                disp(['    ',err.message]);
                disp(err.stack(1));
            end
        end
end
set(handles.text5,'String',handles.data_prop);
set(handles.text7,'String',handles.info_prop);
plot_histo(choice,handles.current,handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function data_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
handles.output.registrations = handles.registrations;
handles.output.indicators = handles.indicators;
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in button_view.
function button_view_Callback(hObject, eventdata, handles)
if(get(handles.data_type_menu,'Value')==1)
    index = get(handles.data_menu,'Value');
    image = handles.ancest.images.data{index};
    info = handles.ancest.images.info{index};
    try
        image_viewer(image,info,'',handles.ancest.view_point);
    catch
    end
elseif(get(handles.data_type_menu,'Value')==2)
    index = get(handles.data_menu,'Value');
    field = handles.ancest.fields.data{index};
    info = handles.ancest.fields.info{index};
    if(strcmp(info.Type,'rigid_transform'))
        try
            msgbox({'Translation (x,y,z) in [mm]';' ';num2str(field(2,:));' ';' ';'Rotation matrix';num2str(field(3,:));num2str(field(4,:));num2str(field(5,:))},'transformation matrix');
        catch
        end
    end
elseif(get(handles.data_type_menu,'Value')==3)
    index = get(handles.data_menu,'Value');
    data = handles.ancest.mydata.data{index};
    info = handles.ancest.mydata.info{index};
    if(strcmp(info.Type,'image'))
        try
            image_viewer(data,info);
        catch
        end
    elseif(strcmp(info.Type,'rigid_transform'))
        try
            msgbox({'Translation (x,y,z) in [mm]';' ';num2str(data(2,:));' ';' ';'Rotation matrix';' ';num2str(data(3,:));num2str(data(4,:));num2str(data(5,:))},'transformation matrix');
        catch
        end
    end
elseif(get(handles.data_type_menu,'Value')==4)
    index = get(handles.data_menu,'Value');
    beams = handles.ancest.plans.data{index};
    plan = struct;
    fields = {};
    for i=1:length(beams)
        fields = unique([fields;fieldnames(beams{i})]);
    end
    for i=1:length(beams)
        for j=1:length(fields)
            if(isfield(beams{i},fields{j}))
                plan.beams(i).(fields{j}) = beams{i}.(fields{j});
            end
        end
    end
    explore_plan(plan);
end


% --- Executes on button press in button_3D.
function button_3D_Callback(hObject, eventdata, handles)
if(get(handles.data_type_menu,'Value')==1)
    index = get(handles.data_menu,'Value');
    image = handles.ancest.images.data{index};
    info = handles.ancest.images.info{index};
    try
        image_viewer_3D(image,info);
    catch
    end
elseif(get(handles.data_type_menu,'Value')==3)
    index = get(handles.data_menu,'Value');
    image = handles.ancest.mydata.data{index};
    info = handles.ancest.mydata.info{index};
    if(strcmp(info.Type,'image'))
        try
            image_viewer_3D(image,info);
        catch
        end
    end
end


% --- Executes on button press in button_header.
function button_header_Callback(hObject, eventdata, handles)
if(get(handles.data_type_menu,'Value')==1)
    index = get(handles.data_menu,'Value');
    info = handles.ancest.images.info{index};
    if(isfield(info,'OriginalHeader'))
        try
            header = info.OriginalHeader;
            disp(header);
            save 'header.mat' header;
            evalin('base','header = load(''header.mat'');');
            delete('header.mat');
        catch
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
elseif(get(handles.data_type_menu,'Value')==3)
    index = get(handles.data_menu,'Value');
    info = handles.ancest.mydata.info{index};
    if(isfield(info,'OriginalHeader'))
        try
            header = info.OriginalHeader;
            disp(header);
            save 'header.mat' header;
            evalin('base','header = load(''header.mat'');');
            delete('header.mat');
        catch
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
elseif(get(handles.data_type_menu,'Value')==4)
    index = get(handles.data_menu,'Value');
    plan = handles.ancest.plans.data{index};
    info = handles.ancest.plans.info{index};
    if(isfield(info,'OriginalHeader'))
        try
            header = info.OriginalHeader;
            disp(header);
            save 'plan.mat' plan;
            save 'header.mat' header;
            evalin('base','plan = load(''plan.mat'');');
            evalin('base','header = load(''header.mat'');');
            delete('plan.mat');
            delete('header.mat');
        catch
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
end


% --- Executes on button press in edit_button.
function edit_button_Callback(hObject, eventdata, handles)
switch get(handles.data_type_menu,'Value')
    case 1
        index = get(handles.data_menu,'Value');
        info = handles.ancest.images.info{index};
        name = handles.ancest.images.name{index};
    case 2
        index = get(handles.data_menu,'Value');
        info = handles.ancest.fields.info{index};
        name = handles.ancest.fields.name{index};
    case 3
        index = get(handles.data_menu,'Value');
        info = handles.ancest.mydata.info{index};
        name = handles.ancest.mydata.name{index};
    case 4
        index = get(handles.data_menu,'Value');
        info = handles.ancest.plans.info{index};
        name = handles.ancest.plans.name{index};
    case 5
        index = get(handles.data_menu,'Value');
        info = handles.ancest.meshes.info{index};
        name = handles.ancest.meshes.name{index};
end
myTags = {'Name'};
tags = fieldnames(info);
for i=1:length(tags)
    if(ischar(info.(tags{i})) || isnumeric(info.(tags{i})))
        myTags{end+1} = tags{i};
    end
end
myString = {name};
for i=2:length(myTags)
    try
        if(ischar(info.(myTags{i})))
            if(not(isempty(info.(myTags{i}))))
                myString{end+1} = info.(myTags{i});
            else
                myString{end+1} = '';
            end
        elseif(isnumeric(info.(myTags{i})))
            tag = info.(myTags{i});
            if(not(isempty(tag)))
                tag_str = '[';
                for r=1:size(tag,1)
                    for c=1:size(tag,2)
                        tag_str = [tag_str,num2str(tag(r,c)),','];
                    end
                    tag_str = [tag_str(1:end-1),';'];
                end
                tag_str = [tag_str(1:end-1),']'];
                myString{end+1} = tag_str;
            else
                myString{end+1} = '[]';
            end
        end
    catch
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        return
    end
end
myString = image_edit('Edit properties',myTags,myString);
myString{1} = remove_bad_chars(myString{1}); % name
for i=2:length(myTags)
    try
        if(strcmp(myString{i}(1),'[')&&strcmp(myString{i}(end),']'))
            eval(['myString{i} = ',myString{i},';']);
        end
        info.(myTags{i}) = myString{i};
        if(isfield(info,'OriginalHeader'))
            info.OriginalHeader.PatientID = info.PatientID;
        end
    catch
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        return
    end
end
switch get(handles.data_type_menu,'Value')
    case 1
        handles.ancest.images.name{index} = myString{1};
        handles.ancest.images.info{index} = info;
        set(handles.data_menu,'String',handles.ancest.images.name);
    case 2
        handles.ancest.fields.name{index} = myString{1};
        handles.ancest.fields.info{index} = info;
        set(handles.data_menu,'String',handles.ancest.fields.name);
    case 3
        handles.ancest.mydata.name{index} = myString{1};
        handles.ancest.mydata.info{index} = info;
        set(handles.data_menu,'String',handles.ancest.mydata.name);
    case 4
        handles.ancest.plans.name{index} = myString{1};
        handles.ancest.plans.info{index} = info;
        set(handles.data_menu,'String',handles.ancest.plans.name);
    case 5
        handles.ancest.meshes.name{index} = myString{1};
        handles.ancest.meshes.info{index} = info;
        set(handles.data_menu,'String',handles.ancest.meshes.name);
end
guidata(hObject,handles);


% ----------------------------------------------------------
function plot_histo(type,current,handles)
if(~isempty(current))
    axes(handles.axes1);
    switch type
        case 1
            hist(current(:),255);
        case 2
            %             hist(squeeze(reshape(current,3,size(current,2)*size(current,3)*size(current,4),1,1))',127,'EdgeColor','w');
            %             legend
    end
else
    hist([]);
end
guidata(handles.axes1,handles);

