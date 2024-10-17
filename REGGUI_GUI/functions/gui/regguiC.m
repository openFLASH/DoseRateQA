function varargout = regguiC(varargin)
% REGGUIC M-file for regguiC.fig
%      REGGUIC, by itself, creates a new REGGUIC or raises the existing
%      singleton*.
%      H = REGGUIC returns the handle to a new REGGUIC or the handle to
%      the existing singleton*.
%
% Authors : G.Janssens, J.Orban, J.A.Lee, M.Taquet
% Contact : open.reggui@gmail.com
%
% Last Modified by GUIDE v2.5 03-Aug-2020 16:15:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @regguiC_OpeningFcn, ...
    'gui_OutputFcn',  @regguiC_OutputFcn, ...
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

% --- Executes just before regguiC is made visible.
function regguiC_OpeningFcn(hObject, eventdata, handles, varargin)

% Get path
regguiC_path = mfilename('fullpath');
handles.path = fileparts(fileparts(fileparts(regguiC_path)));
regguiC_file = dir([regguiC_path ,'.m']);
handles.reggui_version = regguiC_file.date;

% Initialize the handles structure
handles = Initialize_reggui_handles(handles);

% Add the default GUI information to the handles
if(varargin{1}==1)
    handles.reggui_mode = 1;
else
    handles.reggui_mode = 0;
end
handles.slice1 = 1;
handles.slice2 = 1;
handles.slice3 = 1;
handles.slice4 = 1;
handles.current_special_axes = 4;
handles.fusion_mode = 1;
handles.contour_level = 2;
handles.contours_to_plot = [];
handles.plan_to_plot = [];

% Modify default fields
if(nargin>7)
    if(not(isempty(varargin{5})))
        handles_fields = varargin{5};
        if(not(isempty(handles_fields)))
            for i=1:2:length(handles_fields)-1
                if(ischar(handles_fields{i}))
                    try
                        handles.(handles_fields{i})= handles_fields{i+1};
                    catch
                        disp(['Cannot create handles field: ',handles_fields{i}]);
                    end
                end
            end
        end
    end
end

% Add the menus according to available plugins
list_of_workflows = {};
list_of_tools = {};

if(exist(fullfile(fullfile(fileparts(handles.path),'REGGUI_userdata'),'plugins_config.txt'),'file'))
    [list_of_workflows,list_of_tools] = load_list_of_plugins(fullfile(fullfile(fileparts(handles.path),'REGGUI_userdata'),'plugins_config.txt'));
elseif(exist(fullfile(fullfile(fileparts(regguiC_path),'reggui_config'),'plugins_config_default.txt'),'file'))
    [list_of_workflows,list_of_tools] = load_list_of_plugins(fullfile(fullfile(fileparts(regguiC_path),'reggui_config'),'plugins_config_default.txt'));
end
for i=1:length(list_of_workflows)
    [~,label] = fileparts(list_of_workflows{i});
    uimenu(handles.Workflows,'Label',label,'Callback',{@(hObject,eventdata)regguiC('Generate_instructions_Callback',hObject,eventdata,guidata(hObject),list_of_workflows{i})});
end
for i=1:length(list_of_tools)
    [~,label] = fileparts(list_of_tools{i});
    uimenu(handles.Tools,'Label',label,'Callback',{@(hObject,eventdata)regguiC('Generate_instructions_Callback',hObject,eventdata,guidata(hObject),list_of_tools{i})});
end
if(isempty(list_of_tools))
    set(handles.Tools,'Visible','off');
end

%-----------------------------------------------------
handles.dataPath = pwd;
if(nargin>4)
    if(not(isempty(varargin{2})))
        handles.dataPath = varargin{2};
    end
end

%-----------------------------------------------------
if(nargin>5)
    if(not(isempty(varargin{3})))
        handles.instructions = varargin{3};
    end
end

%-----------------------------------------------------
if(nargin>6)
    if(not(isempty(varargin{4})))
        handles.log_filename = varargin{4};
    end
end

% Print the start to log  ----------------------------
reggui_logger.info(['Starting regguiC (version ',handles.reggui_version,') with path to data: ',handles.dataPath],handles.log_filename)

% Plot data ------------------------------------------
handles = Update_regguiC_GUI(handles);

% Execute input instructions -------------------------
if(handles.reggui_mode)
    set(handles.instruction_list_check,'Value',1);
    handles = Update_instruction_list(handles,1);
end
handles = executeall(handles);

% Replace the close function
set(handles.regguiC_gui,'CloseRequestFcn',@closeGUI);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = regguiC_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles;

% -----------------------------------------------------------------------
function closeGUI(src,evnt)
selection = questdlg('Do you really want to close REGGUIC?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        handles = guidata(gcbo);
        % if instruction list is opened, close it
        if(get(handles.instruction_list_check,'Value'))
            instructions_gui=findobj('Tag','reggui_instructions_gui');
            if(not(isempty(instructions_gui)))
                close(instructions_gui)
            end
            handles = rmfield(handles,'instructions_handles');
            handles.reggui_mode = 0;
        end
        % close regguiC window
        delete(gcf)
    case 'No'
        return
end

% -----------------------------------------------------------------------
function [list_of_workflows,list_of_tools] = load_list_of_plugins(config_filename)
list_of_workflows = {};
list_of_tools = {};
try
    fid = fopen(config_filename,'r');
    update_workflows = 0;
    update_tools = 0;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        if(not(isempty(strfind(tline,'workflows :'))))
            update_workflows = 1;
            update_tools = 0;
            continue
        elseif(not(isempty(strfind(tline,'tools :'))))
            update_workflows = 0;
            update_tools = 1;
            continue
        end
        if(update_workflows)
            list_of_workflows{end+1} = tline;
        elseif(update_tools)
            list_of_tools{end+1} = tline;
        end
    end
    fclose(fid);
catch
    disp('Could not load the list of plugins.')
    fclose(fid);
end


% -----------------------------------------------------------------------
% GUI Create Functions
% -----------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function edit_instruction_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function image1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function xyz1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function field1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fusion1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function image2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function xyz2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function field2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fusion2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function image3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function xyz3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function field3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fusion3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function image4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function xyz4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function field4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function fusion4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function zoom_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function edit_minscale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_maxscale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_minscaleF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit_maxscaleF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function slider_fusion_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% -----------------------------------------------------------------------
% GUI Callback functions
% -----------------------------------------------------------------------

% ---------------------------------------------------------------
function Automatic_Callback(hObject, eventdata, handles)
handles.auto_mode = get(hObject,'Value');
if(handles.auto_mode)
    disp('Automatic mode ON')
    handles.backup_mode = 0;
    set(handles.backup,'Value',handles.backup_mode);
    disp('Backup mode OFF')
else
    disp('Automatic mode OFF')
end
guidata(hObject, handles);

% ---------------------------------------------------------------
function on_region_of_interest_Callback(hObject, eventdata, handles)
handles.roi_mode = get(hObject,'Value');
handles.current_roi = cell(0);
if(handles.roi_mode)
    try
        [handles.current_roi{1} type1] = Image_list(handles,'Select ROI image',1);
        if(type1==1)
            for i=1:length(handles.images.name)
                if(strcmp(handles.images.name{i},handles.current_roi{1}))
                    handles.current_roi{2} = i;
                end
            end
        end
    catch
    end
    if(handles.current_roi{2}>1)
        disp('Region of Interest mode ON')
    else
        set(hObject,'Value',0);
        handles.current_roi = cell(0);
    end
else
    disp('Region of Interest mode OFF')
end
guidata(hObject, handles);

% ---------------------------------------------------------------
function command_line_check_Callback(hObject, eventdata, handles)
if(get(hObject,'Value'))
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','on');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','on');
    handles.reggui_mode = 0;
else
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles.reggui_mode = 0;
end
guidata(hObject, handles);

% ---------------------------------------------------------------
function execute_manual_button_Callback(hObject, eventdata, handles)
set(handles.processing_message,'Visible','off');
for i=length(handles.instructions):-1:1
    handles.instructions{i+1} = handles.instructions{i};
end
handles.instructions{1} = get(handles.edit_instruction,'String');
handles = executeall(handles);
set(handles.processing_message,'Visible','off');
guidata(hObject, handles);

% ---------------------------------------------------------------
function edit_instruction_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

% ---------------------------------------------------------------
function instruction_list_check_Callback(hObject, eventdata, handles)
handles.instructions = cell(0);
handles = Update_instruction_list(handles,get(hObject,'Value'));
guidata(hObject, handles);
% ---------------------------------------------------------------
function handles = Update_instruction_list(handles,checked)
if(checked)
    set(handles.command_line_check,'Value',0);
    set(handles.edit_instruction,'Visible','on');
    set(handles.add_button,'Visible','on');
    set(handles.replace_button,'Visible','on');
    set(handles.remove_button,'Visible','on');
    set(handles.insert_button,'Visible','on');
    set(handles.execute_button,'Visible','on');
    set(handles.execute_all_button,'Visible','on');
    set(handles.Export_instructions,'Visible','on');
    set(handles.execute_manual_button,'Visible','off');
    instructions_gui=findobj('Tag','reggui_instructions_gui');
    if(isempty(instructions_gui))
        reggui_instructions();
        instructions_gui=findobj('Tag','reggui_instructions_gui');
        handles.instructions_handles = guidata(instructions_gui);
        set(handles.instructions_handles.listbox1,'String',cell(0));
    else
        handles.instructions_handles = guidata(instructions_gui);
    end
    if(isempty(instructions_gui))
        disp('Could not open reggui instructions list');
        return
    end
    handles.reggui_mode = 1;
else
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.Export_instructions,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    instructions_gui=findobj('Tag','reggui_instructions_gui');
    if(not(isempty(instructions_gui)))
        close(instructions_gui)
    end
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
end

% ---------------------------------------------------------------
function add_button_Callback(hObject, eventdata, handles)
try
    instruction_list = get(handles.instructions_handles.listbox1,'String');
catch
    disp('Instruction list was closed. Exiting instruction list mode.');
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
    return
end
instruction_list{length(instruction_list)+1} = get(handles.edit_instruction,'String');
set(handles.instructions_handles.listbox1,'String',instruction_list);
set(handles.instructions_handles.listbox1,'Value',length(instruction_list));

% ---------------------------------------------------------------
function replace_button_Callback(hObject, eventdata, handles)
try
    instruction_list = get(handles.instructions_handles.listbox1,'String');
    var_index = get(handles.instructions_handles.listbox1,'Value');
catch
    disp('Instruction list was closed. Exiting instruction list mode.');
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
    return
end
if(var_index>0)
    instruction_list{var_index(1)} = get(handles.edit_instruction,'String');
    if(length(var_index)>1)
        for i=2:length(var_index)
            instruction_list = Remove_Instruction(var_index(i)-i+2,instruction_list);
        end
    end
    set(handles.instructions_handles.listbox1,'String',instruction_list);
    if(length(instruction_list)<max(var_index))
        set(handles.instructions_handles.listbox1,'Value',length(instruction_list));
    end
end

% ---------------------------------------------------------------
function remove_button_Callback(hObject, eventdata, handles)
try
    instruction_list = get(handles.instructions_handles.listbox1,'String');
    var_index = get(handles.instructions_handles.listbox1,'Value');
catch
    disp('Instruction list was closed. Exiting instruction list mode.');
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
    return
end
if(var_index>0)
    for i=1:length(var_index)
        instruction_list = Remove_Instruction(var_index(i)-i+1,instruction_list);
    end
    set(handles.instructions_handles.listbox1,'String',instruction_list);
    if(length(instruction_list)<max(var_index))
        set(handles.instructions_handles.listbox1,'Value',length(instruction_list));
    end
end

% ---------------------------------------------------------------
function insert_button_Callback(hObject, eventdata, handles)
try
    instruction_list = get(handles.instructions_handles.listbox1,'String');
    var_index = get(handles.instructions_handles.listbox1,'Value');
catch
    disp('Instruction list was closed. Exiting instruction list mode.');
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
    return
end
if(var_index>0)
    instruction_list(var_index(1)+1:end+1) = instruction_list(var_index(1):length(instruction_list));
    instruction_list{var_index(1)} = get(handles.edit_instruction,'String');
    set(handles.instructions_handles.listbox1,'String',instruction_list);
    if(length(instruction_list)<max(var_index))
        set(handles.instructions_handles.listbox1,'Value',length(instruction_list));
    end
end

% ---------------------------------------------------------------
function execute_button_Callback(hObject, eventdata, handles)
try
    instruction_list = get(handles.instructions_handles.listbox1,'String');
    var_index = get(handles.instructions_handles.listbox1,'Value');
catch
    disp('Instruction list was closed. Exiting instruction list mode.');
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
    return
end
if(var_index>0)
    set(handles.processing_message,'Visible','off');
    handles.instructions{1} = 'handles = Automatic(handles,1);';
    for i=1:length(var_index)
        handles.instructions{i+1} = instruction_list{var_index(i)};
    end
    handles = executeall(handles,0);
    set(handles.processing_message,'Visible','off');
end
guidata(hObject, handles);

% ---------------------------------------------------------------
function execute_all_button_Callback(hObject, eventdata, handles)
try
    instruction_list = get(handles.instructions_handles.listbox1,'String');
    var_index = get(handles.instructions_handles.listbox1,'Value');
catch
    disp('Instruction list was closed. Exiting instruction list mode.');
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
    return
end
handles.instructions = cell(0);
if(var_index>0)
    set(handles.processing_message,'Visible','off');
    handles.instructions{1} = 'handles = Automatic(handles,1);';
    handles.instructions(2:length(instruction_list)+1) = instruction_list;
    handles = executeall(handles,0);
    set(handles.processing_message,'Visible','off');
end
guidata(hObject, handles);

% ---------------------------------------------------------------
function handles = executeall(handles,no_process)
if(nargin<2)
    no_process = 1;
end

if(handles.reggui_mode && no_process)
    try
        instruction_list = get(handles.instructions_handles.listbox1,'String');
    catch
        disp('Instruction list was closed. Exiting instruction list mode.');
        set(handles.instruction_list_check,'Value',0);
        set(handles.edit_instruction,'Visible','off');
        set(handles.add_button,'Visible','off');
        set(handles.replace_button,'Visible','off');
        set(handles.remove_button,'Visible','off');
        set(handles.insert_button,'Visible','off');
        set(handles.execute_button,'Visible','off');
        set(handles.execute_all_button,'Visible','off');
        set(handles.execute_manual_button,'Visible','off');
        if(isfield(handles,'instructions_handles'))
            handles = rmfield(handles,'instructions_handles');
        end
        handles.reggui_mode = 0;
        return
    end
    for i=1:length(handles.instructions)
        instruction_list{length(instruction_list)+1} = handles.instructions{i};
    end
    set(handles.instructions_handles.listbox1,'String',instruction_list);
    set(handles.instructions_handles.listbox1,'Value',length(instruction_list));
    handles.instructions = cell(0);
    return
end
% set execution message in GUI
message = get(handles.processing_message,'String');
if(ischar(message))
    message = {'';'';'';'';'';'';message};
end
if(length(handles.instructions)>1)
    message{7} = ['( ',num2str(length(handles.instructions)),' instructions )'];
end
set(handles.processing_message,'String',message);
set(handles.processing_message,'Visible','on');drawnow
% execute instructions
nb_images = length(handles.images.data);
nb_fields = length(handles.fields.data);
handles = Execute_reggui_instructions(handles);
nb_new_images = length(handles.images.data) - nb_images;
nb_new_fields = length(handles.fields.data) - nb_fields;
% update the display
try
    cmd = 'handles = Update_regguiC_GUI(handles';
    % if(nb_new_images>0)
    %     cmd = [cmd,',''show_last_image'''];
    % else
        i = 1;
        while(isfield(handles,['image',num2str(i)]))
            image_tag = ['image',num2str(i)];
            image_str = get(handles.(image_tag),'String');
            image_str = image_str(get(handles.(image_tag),'Value'));
            images_to_show{i} = image_str;
            i = i+1;
        end
        cmd = [cmd,',''images_to_show'',images_to_show'];
    % end
    if(nb_new_images<0)
        handles.contours_to_plot = [];
    end
    if(nb_new_fields>0)
        cmd = [cmd,',''show_last_field'''];
    else
        i = 1;
        while(isfield(handles,['field',num2str(i)]))
            field_tag = ['field',num2str(i)];
            field_str = get(handles.(field_tag),'String');
            field_str = field_str(get(handles.(field_tag),'Value'));
            fields_to_show{i} = field_str;
            i = i+1;
        end
        cmd = [cmd,',''fields_to_show'',fields_to_show'];
    end
    i = 1;
    while(isfield(handles,['image',num2str(i)]))
        fusion_tag = ['fusion',num2str(i)];
        fusion_str = get(handles.(fusion_tag),'String');
        fusion_str = fusion_str(get(handles.(fusion_tag),'Value'));
        fusions_to_show{i} = fusion_str;
        i = i+1;
    end
    cmd = [cmd,',''fusions_to_show'',fusions_to_show'];
    cmd = [cmd,');'];
    eval(cmd);
catch
    disp('Error in GUI update')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
guidata(handles.execute_all_button, handles);


% ---------------------------------------------------------------
% Navigation and Display
% ---------------------------------------------------------------

% ---------------------------------------------------------------
function Joint_slider_Callback(hObject, eventdata, handles)
if(get(handles.Joint_slider,'Value'))
    disp('Joint sliders mode ON');
    current = get(handles.xyz1,'Value');
    switch current
        case 1
            set(handles.slider1,'Value',floor(handles.view_point(1))/handles.size(1)*1.001-0.001);
            handles.slice1 = handles.view_point(1);
        case 2
            set(handles.slider1,'Value',floor(handles.view_point(2))/handles.size(2)*1.001-0.001);
            handles.slice1 = handles.view_point(2);
        case 3
            set(handles.slider1,'Value',floor(handles.view_point(3))/handles.size(3)*1.001-0.001);
            handles.slice1 = handles.view_point(3);
    end
    current = get(handles.xyz2,'Value');
    switch current
        case 1
            set(handles.slider2,'Value',floor(handles.view_point(1))/handles.size(1)*1.001-0.001);
            handles.slice2 = handles.view_point(1);
        case 2
            set(handles.slider2,'Value',floor(handles.view_point(2))/handles.size(2)*1.001-0.001);
            handles.slice2 = handles.view_point(2);
        case 3
            set(handles.slider2,'Value',floor(handles.view_point(3))/handles.size(3)*1.001-0.001);
            handles.slice2 = handles.view_point(3);
    end
    current = get(handles.xyz3,'Value');
    switch current
        case 1
            set(handles.slider3,'Value',floor(handles.view_point(1))/handles.size(1)*1.001-0.001);
            handles.slice3 = handles.view_point(1);
        case 2
            set(handles.slider3,'Value',floor(handles.view_point(2))/handles.size(2)*1.001-0.001);
            handles.slice3 = handles.view_point(2);
        case 3
            set(handles.slider3,'Value',floor(handles.view_point(3))/handles.size(3)*1.001-0.001);
            handles.slice3 = handles.view_point(3);
    end
    current = get(handles.xyz4,'Value');
    switch current
        case 1
            set(handles.slider4,'Value',floor(handles.view_point(1))/handles.size(1)*1.001-0.001);
            handles.slice4 = handles.view_point(1);
        case 2
            set(handles.slider4,'Value',floor(handles.view_point(2))/handles.size(2)*1.001-0.001);
            handles.slice4 = handles.view_point(2);
        case 3
            set(handles.slider4,'Value',floor(handles.view_point(3))/handles.size(3)*1.001-0.001);
            handles.slice4 = handles.view_point(3);
    end
else
    disp('Joint sliders mode OFF');
end
cla(handles.axes5);
handles = Update_regguiC_GUI(handles);

% ---------------------------------------------------------------
function center_on_isocenter_Callback(hObject, eventdata, handles)
if(length(handles.plans.name)>1)
    % select plan
    [plan_name,type1] = Image_list(handles,'Select plan',4);
    if(not(type1==4))
        disp('Error : wrong type of data ! Please select a treatment plan');
        return
    elseif(not(strcmp(plan_name,'none')))
        handles = Center_on_plan_isocenter(handles,plan_name);
        handles = Apply_view_point(handles);
        Update_regguiC_GUI(handles);
        return
    end
end
iso_voxel = round(handles.size/2);% in voxel space
if((iso_voxel(1)>0 && iso_voxel(1)<handles.size(1)) && (iso_voxel(2)>0 && iso_voxel(2)<handles.size(2)) && (iso_voxel(3)>0 && iso_voxel(3)<handles.size(3)))
    handles.view_point = iso_voxel;
    handles = Apply_view_point(handles);
    Update_regguiC_GUI(handles);
end

% ---------------------------------------------------------------
function play_button_Callback(hObject, eventdata, handles)
for i=2:length(handles.images.data)
    set(handles.image4,'Value',i);
    Update_regguiC_plot(handles,4)
    pause(0.2);
end

% ---------------------------------------------------------------
function zoom_Callback(hObject, eventdata, handles)
if(get(hObject,'Value')>1 && length(handles.images.data)>1)
    set(handles.pan_mode,'Value',1);
    pan on
else
    pan off
end
Update_regguiC_plot(handles,4)
guidata(hObject,handles);

% ---------------------------------------------------------------
function pan_mode_Callback(hObject, eventdata, handles)
if(get(hObject,'Value'))
    pan on
else
    pan off
end

% --------------------------------------------------------------------
function checkbox_difference_Callback(hObject, eventdata, handles)
handles.fusion_mode = get(hObject,'Value')+1;
guidata(hObject,handles);
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function edit_minscale_Callback(hObject, eventdata, handles)
value = str2double(get(hObject,'String'));
if(not(isnan(value)))
    handles.minscale = value;
else
    set(hObject,'String',num2str(handles.minscale));
end
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function edit_maxscale_Callback(hObject, eventdata, handles)
value = str2double(get(hObject,'String'));
if(not(isnan(value)))
    handles.maxscale = value;
else
    set(hObject,'String',num2str(handles.maxscale));
end
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function edit_minscaleF_Callback(hObject, eventdata, handles)
value = str2double(get(hObject,'String'));
if(not(isnan(value)))
    handles.minscaleF = value;
else
    set(hObject,'String',num2str(handles.minscaleF));
end
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function edit_maxscaleF_Callback(hObject, eventdata, handles)
value = str2double(get(hObject,'String'));
if(not(isnan(value)))
    handles.maxscaleF = value;
else
    set(hObject,'String',num2str(handles.maxscaleF));
end
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function button_less_brightness_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale+range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale+range/8,4,'round',2);
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function button_more_brightness_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale-range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale-range/8,4,'round',2);
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function button_less_contrast_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale-range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale+range/8,4,'round',2);
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function button_more_contrast_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale+range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale-range/8,4,'round',2);
handles = Update_regguiC_GUI(handles);
guidata(hObject,handles);

% ---------------------------------------------------------------
function Reset_scale_Callback(hObject, eventdata, handles)
% set scale for images
indices = unique([get(handles.image1,'Value'),get(handles.image2,'Value'),get(handles.image3,'Value'),get(handles.image4,'Value')]);
current_images = cell(0);
for i=1:length(indices)
    current_images{i} = handles.images.data{indices(i)};
end
[handles.minscale,handles.maxscale] = get_image_scale(current_images,handles.scale_prctile);
% set scale for fusion
if(handles.fusion_mode==1)
    indices = unique([get(handles.fusion1,'Value'),get(handles.fusion2,'Value'),get(handles.fusion3,'Value'),get(handles.fusion4,'Value')]);
    current_images = cell(0);
    for i=1:length(indices)
        current_images{i} = handles.images.data{indices(i)};
    end
    [handles.minscaleF,handles.maxscaleF] = get_image_scale(current_images,handles.scale_prctile);
end
handles = Update_regguiC_GUI(handles);
guidata(hObject, handles);

% ---------------------------------------------------------------
function Reset_scale_minmax_Callback(hObject, eventdata, handles)
% set scale for images
indices = unique([get(handles.image1,'Value'),get(handles.image2,'Value'),get(handles.image3,'Value'),get(handles.image4,'Value')]);
current_images = cell(0);
for i=1:length(indices)
    current_images{i} = handles.images.data{indices(i)};
end
[handles.minscale,handles.maxscale] = get_image_scale(current_images,0);
% set scale for fusion
if(handles.fusion_mode==1)
    indices = unique([get(handles.fusion1,'Value'),get(handles.fusion2,'Value'),get(handles.fusion3,'Value'),get(handles.fusion4,'Value')]);
    current_images = cell(0);
    for i=1:length(indices)
        current_images{i} = handles.images.data{indices(i)};
    end
    [handles.minscaleF,handles.maxscaleF] = get_image_scale(current_images,0);
end
handles = Update_regguiC_GUI(handles);
guidata(hObject, handles);

% ---------------------------------------------------------------
function slider_fusion_Callback(hObject, eventdata, handles)
if(handles.fusion_mode==1)
    handles = Update_regguiC_GUI(handles);
end

% ---------------------------------------------------------------
function multiple_contours_Callback(hObject, eventdata, handles)
if(get(hObject,'Value') && length(handles.images.name)>1)
    [selectedImages,OK] = listdlg('PromptString','Which contour do you want to view ?',...
        'SelectionMode','multiple',...
        'ListString',handles.images.name(2:end));
    if OK==0
        disp('Wrong selection')
        set(hObject,'Value',0);
    else
        handles.contours_to_plot = selectedImages+1;
        for i=1:min(length(handles.contours_to_plot),6)
            eval(['set(handles.multiple_contours_legend_',num2str(i),',''Visible'',''on'');']);
        end
        guidata(hObject, handles);
        Update_regguiC_all_plots(handles)
    end
else
    handles.contours_to_plot = [];
    for i=1:6
        eval(['set(handles.multiple_contours_legend_',num2str(i),',''Visible'',''off'');']);
    end
    guidata(hObject, handles);
    Update_regguiC_all_plots(handles);
end

% ---------------------------------------------------------------
function display_plan_Callback(hObject, eventdata, handles)
if(get(hObject,'Value') && length(handles.plans.name)>1)
    [selectedPlan,OK] = listdlg('PromptString','Which plan do you want to view ?',...
        'SelectionMode','single',...
        'ListString',handles.plans.name(2:end));
    if OK==0
        disp('Wrong selection')
        set(hObject,'Value',0);
    else
        handles.plan_to_plot = selectedPlan+1;
        set(handles.plan_legend_1,'Visible','on');
        guidata(hObject, handles);
        Update_regguiC_all_plots(handles)
    end
else
    handles.plan_to_plot = [];
    set(handles.plan_legend_1,'Visible','off');
    guidata(hObject, handles);
    Update_regguiC_all_plots(handles);
end

% ---------------------------------------------------------------
function DRR_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
Update_regguiC_plot(handles,4)


% --------
% Figure 1
% --------

% --- Executes on selection change in image1.
function image1_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,1);

% --- Executes on selection change in xyz1.
function xyz1_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        handles.slice1 = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(1)));
    case 2
        handles.slice1 = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(2)));
    case 3
        handles.slice1 = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(3)));
end
Update_regguiC_plot(handles,1);

% --- Executes on selection change in field1.
function field1_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,1);

% --- Executes on selection change in fusion1.
function fusion1_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,1);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
current = get(handles.xyz1,'Value');
switch current
    case 1
        handles.slice1 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(1)));
        handles.view_point(1) = handles.slice1;
    case 2
        handles.slice1 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(2)));
        handles.view_point(2) = handles.slice1;
    case 3
        handles.slice1 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(3)));
        handles.view_point(3) = handles.slice1;
end
Update_regguiC_plot(handles,1);
if(get(handles.Joint_slider,'Value'))
    if(current==get(handles.xyz2,'Value'))
        set(handles.slider2,'Value',get(hObject,'Value'));
        handles.slice2 = handles.slice1;
    end
    if(current==get(handles.xyz3,'Value'))
        set(handles.slider3,'Value',get(hObject,'Value'));
        handles.slice3 = handles.slice1;
    end
    if(current==get(handles.xyz4,'Value'))
        set(handles.slider4,'Value',get(hObject,'Value'));
        handles.slice4 = handles.slice1;
    end
    Update_regguiC_plot(handles,2);
    Update_regguiC_plot(handles,3);
    Update_regguiC_plot(handles,4)
end
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
if(get(handles.Joint_slider,'Value'))
    try
        new_point = round(get(gca,'CurrentPoint'));
        new_point = new_point(1,:);
        new_slider_pos = [0;0;0];
        switch get(handles.xyz1,'Value')
            case 1
                handles.view_point(2) = min(handles.size(2),max(1,new_point(1)));
                handles.view_point(3) = min(handles.size(3),max(1,new_point(2)));
                new_slider_pos(2) = handles.view_point(2)/handles.size(2);
                new_slider_pos(3) = handles.view_point(3)/handles.size(3);
            case 2
                handles.view_point(1) = min(handles.size(1),max(1,new_point(1)));
                handles.view_point(3) = min(handles.size(3),max(1,new_point(2)));
                new_slider_pos(1) = handles.view_point(1)/handles.size(1);
                new_slider_pos(3) = handles.view_point(3)/handles.size(3);
            case 3
                handles.view_point(1) = min(handles.size(1),max(1,new_point(1)));
                handles.view_point(2) = min(handles.size(2),max(1,handles.size(2)-new_point(2)));
                new_slider_pos(1) = handles.view_point(1)/handles.size(1);
                new_slider_pos(2) = handles.view_point(2)/handles.size(2);
        end
        switch get(handles.xyz2,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider2,'Value',new_slider_pos(1));
                    handles.slice2 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider2,'Value',new_slider_pos(2));
                    handles.slice2 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider2,'Value',new_slider_pos(3));
                    handles.slice2 = handles.view_point(3);
                end
        end
        switch get(handles.xyz3,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider3,'Value',new_slider_pos(1));
                    handles.slice3 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider3,'Value',new_slider_pos(2));
                    handles.slice3 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider3,'Value',new_slider_pos(3));
                    handles.slice3 = handles.view_point(3);
                end
        end
        switch get(handles.xyz4,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider4,'Value',new_slider_pos(1));
                    handles.slice4 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider4,'Value',new_slider_pos(2));
                    handles.slice4 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider4,'Value',new_slider_pos(3));
                    handles.slice4 = handles.view_point(3);
                end
        end
    catch
        disp('Invalid command')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    Update_regguiC_all_plots(handles);
    guidata(handles.axes1, handles);
end


% --------
% Figure 2
% --------

% --- Executes on selection change in image2.
function image2_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,2);

% --- Executes on selection change in xyz2.
function xyz2_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        handles.slice2 = max(1,ceil((get(handles.slider2,'Value')+0.001)/1.001*handles.size(1)));
    case 2
        handles.slice2 = max(1,ceil((get(handles.slider2,'Value')+0.001)/1.001*handles.size(2)));
    case 3
        handles.slice2 = max(1,ceil((get(handles.slider2,'Value')+0.001)/1.001*handles.size(3)));
end
Update_regguiC_plot(handles,2);

% --- Executes on selection change in field2.
function field2_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,2);

% --- Executes on selection change in fusion2.
function fusion2_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,2);

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
current = get(handles.xyz2,'Value');
switch current
    case 1
        handles.slice2 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(1)));
        handles.view_point(1) = handles.slice2;
    case 2
        handles.slice2 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(2)));
        handles.view_point(2) = handles.slice2;
    case 3
        handles.slice2 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(3)));
        handles.view_point(3) = handles.slice2;
end
Update_regguiC_plot(handles,2);
if(get(handles.Joint_slider,'Value'))
    if(current==get(handles.xyz1,'Value'))
        set(handles.slider1,'Value',get(hObject,'Value'));
        handles.slice1 = handles.slice2;
    end
    if(current==get(handles.xyz3,'Value'))
        set(handles.slider3,'Value',get(hObject,'Value'));
        handles.slice3 = handles.slice2;
    end
    if(current==get(handles.xyz4,'Value'))
        set(handles.slider4,'Value',get(hObject,'Value'));
        handles.slice4 = handles.slice2;
    end
    Update_regguiC_plot(handles,1);
    Update_regguiC_plot(handles,3);
    Update_regguiC_plot(handles,4)
end
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
if(get(handles.Joint_slider,'Value'))
    try
        new_point = round(get(gca,'CurrentPoint'));
        new_point = new_point(1,:);
        new_slider_pos = [0;0;0];
        switch get(handles.xyz2,'Value')
            case 1
                handles.view_point(2) = min(handles.size(2),max(1,new_point(1)));
                handles.view_point(3) = min(handles.size(3),max(1,new_point(2)));
                new_slider_pos(2) = handles.view_point(2)/handles.size(2);
                new_slider_pos(3) = handles.view_point(3)/handles.size(3);
            case 2
                handles.view_point(1) = min(handles.size(1),max(1,new_point(1)));
                handles.view_point(3) = min(handles.size(3),max(1,new_point(2)));
                new_slider_pos(1) = handles.view_point(1)/handles.size(1);
                new_slider_pos(3) = handles.view_point(3)/handles.size(3);
            case 3
                handles.view_point(1) = min(handles.size(1),max(1,new_point(1)));
                handles.view_point(2) = min(handles.size(2),max(1,handles.size(2)-new_point(2)));
                new_slider_pos(1) = handles.view_point(1)/handles.size(1);
                new_slider_pos(2) = handles.view_point(2)/handles.size(2);
        end
        switch get(handles.xyz1,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider1,'Value',new_slider_pos(1));
                    handles.slice1 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider1,'Value',new_slider_pos(2));
                    handles.slice1 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider1,'Value',new_slider_pos(3));
                    handles.slice1 = handles.view_point(3);
                end
        end
        switch get(handles.xyz3,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider3,'Value',new_slider_pos(1));
                    handles.slice3 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider3,'Value',new_slider_pos(2));
                    handles.slice3 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider3,'Value',new_slider_pos(3));
                    handles.slice3 = handles.view_point(3);
                end
        end
        switch get(handles.xyz4,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider4,'Value',new_slider_pos(1));
                    handles.slice4 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider4,'Value',new_slider_pos(2));
                    handles.slice4 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider4,'Value',new_slider_pos(3));
                    handles.slice4 = handles.view_point(3);
                end
        end
    catch
        disp('Invalid command')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    Update_regguiC_all_plots(handles);
    guidata(handles.axes2, handles);
end


% --------
% Figure 3
% --------

% --- Executes on selection change in image3.
function image3_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,3);

% --- Executes on selection change in xyz3.
function xyz3_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        handles.slice3 = max(1,ceil((get(handles.slider3,'Value')+0.001)/1.001*handles.size(1)));
    case 2
        handles.slice3 = max(1,ceil((get(handles.slider3,'Value')+0.001)/1.001*handles.size(2)));
    case 3
        handles.slice3 = max(1,ceil((get(handles.slider3,'Value')+0.001)/1.001*handles.size(3)));
end
Update_regguiC_plot(handles,3);

% --- Executes on selection change in field3.
function field3_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,3);

% --- Executes on selection change in fusion3.
function fusion3_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,3);

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
current = get(handles.xyz3,'Value');
switch current
    case 1
        handles.slice3 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(1)));
        handles.view_point(1) = handles.slice3;
    case 2
        handles.slice3 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(2)));
        handles.view_point(2) = handles.slice3;
    case 3
        handles.slice3 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(3)));
        handles.view_point(3) = handles.slice3;
end
Update_regguiC_plot(handles,3);
if(get(handles.Joint_slider,'Value'))
    if(current==get(handles.xyz1,'Value'))
        set(handles.slider1,'Value',get(hObject,'Value'));
        handles.slice1 = handles.slice3;
    end
    if(current==get(handles.xyz2,'Value'))
        set(handles.slider2,'Value',get(hObject,'Value'));
        handles.slice2 = handles.slice3;
    end
    if(current==get(handles.xyz4,'Value'))
        set(handles.slider4,'Value',get(hObject,'Value'));
        handles.slice4 = handles.slice3;
    end
    Update_regguiC_plot(handles,1);
    Update_regguiC_plot(handles,2);
    Update_regguiC_plot(handles,4)
end
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
if(get(handles.Joint_slider,'Value'))
    try
        new_point = round(get(gca,'CurrentPoint'));
        new_point = max(1,new_point(1,:));
        new_slider_pos = [0;0;0];
        switch get(handles.xyz3,'Value')
            case 1
                handles.view_point(2) = min(handles.size(2),max(1,new_point(1)));
                handles.view_point(3) = min(handles.size(3),max(1,new_point(2)));
                new_slider_pos(2) = handles.view_point(2)/handles.size(2);
                new_slider_pos(3) = handles.view_point(3)/handles.size(3);
            case 2
                handles.view_point(1) = min(handles.size(1),max(1,new_point(1)));
                handles.view_point(3) = min(handles.size(3),max(1,new_point(2)));
                new_slider_pos(1) = handles.view_point(1)/handles.size(1);
                new_slider_pos(3) = handles.view_point(3)/handles.size(3);
            case 3
                handles.view_point(1) = min(handles.size(1),max(1,new_point(1)));
                handles.view_point(2) = min(handles.size(2),max(1,handles.size(2)-new_point(2)));
                new_slider_pos(1) = handles.view_point(1)/handles.size(1);
                new_slider_pos(2) = handles.view_point(2)/handles.size(2);
        end
        switch get(handles.xyz1,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider1,'Value',new_slider_pos(1));
                    handles.slice1 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider1,'Value',new_slider_pos(2));
                    handles.slice1 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider1,'Value',new_slider_pos(3));
                    handles.slice1 = handles.view_point(3);
                end
        end
        switch get(handles.xyz2,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider2,'Value',new_slider_pos(1));
                    handles.slice2 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider2,'Value',new_slider_pos(2));
                    handles.slice2 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider2,'Value',new_slider_pos(3));
                    handles.slice2 = handles.view_point(3);
                end
        end
        switch get(handles.xyz4,'Value')
            case 1
                if(new_slider_pos(1)>0)
                    set(handles.slider4,'Value',new_slider_pos(1));
                    handles.slice4 = handles.view_point(1);
                end
            case 2
                if(new_slider_pos(2)>0)
                    set(handles.slider4,'Value',new_slider_pos(2));
                    handles.slice4 = handles.view_point(2);
                end
            case 3
                if(new_slider_pos(3)>0)
                    set(handles.slider4,'Value',new_slider_pos(3));
                    handles.slice4 = handles.view_point(3);
                end
        end
    catch
        disp('Invalid command')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    Update_regguiC_all_plots(handles);
    guidata(handles.axes3, handles);
end


% --------
% Figure 4
% --------

% --- Executes on selection change in image 4.
function image4_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,4)

% --- Executes on selection change in xyz4.
function xyz4_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        handles.slice4 = max(1,ceil((get(handles.slider4,'Value')+0.001)/1.001*handles.size(1)));
    case 2
        handles.slice4 = max(1,ceil((get(handles.slider4,'Value')+0.001)/1.001*handles.size(2)));
    case 3
        handles.slice4 = max(1,ceil((get(handles.slider4,'Value')+0.001)/1.001*handles.size(3)));
end
Update_regguiC_plot(handles,4)

% --- Executes on selection change in field4.
function field4_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,4)

% --- Executes on selection change in fusion4.
function fusion4_Callback(hObject, eventdata, handles)
Update_regguiC_plot(handles,4)

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
current = get(handles.xyz4,'Value');
switch current
    case 1
        handles.slice4 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(1)));
        handles.view_point(1) = handles.slice4;
    case 2
        handles.slice4 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(2)));
        handles.view_point(2) = handles.slice4;
    case 3
        handles.slice4 = max(1,ceil((get(hObject,'Value')+0.001)/1.001*handles.size(3)));
        handles.view_point(3) = handles.slice4;
end
Update_regguiC_plot(handles,4)
if(get(handles.Joint_slider,'Value') && not(handles.current_special_axes == 5))
    if(current==get(handles.xyz1,'Value'))
        set(handles.slider1,'Value',get(hObject,'Value'));
        handles.slice1 = handles.slice4;
    end
    if(current==get(handles.xyz2,'Value'))
        set(handles.slider2,'Value',get(hObject,'Value'));
        handles.slice2 = handles.slice4;
    end
    if(current==get(handles.xyz3,'Value'))
        set(handles.slider3,'Value',get(hObject,'Value'));
        handles.slice3 = handles.slice4;
    end
    Update_regguiC_plot(handles,1);
    Update_regguiC_plot(handles,2);
    Update_regguiC_plot(handles,3);
end
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function axes4_ButtonDownFcn(hObject, eventdata, handles)
if(strcmp(get(ancestor(gca,'figure'),'SelectionType'),'alt'))
    cla(handles.axes1);
    cla(handles.axes2);
    cla(handles.axes3);
    cla(handles.axes4);
    set(handles.uipanel2,'Visible','off');
    set(handles.uipanel3,'Visible','off');
    set(handles.uipanel4,'Visible','off');
    set(handles.slider1,'Visible','off');
    set(handles.slider2,'Visible','off');
    set(handles.slider3,'Visible','off');
    set(handles.Joint_slider,'Visible','off');
    set(handles.play_button,'Visible','on');
    handles.current_special_axes = 5;
    Update_regguiC_plot(handles,4)
end
guidata(handles.axes4, handles);

% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, eventdata, handles)
if(strcmp(get(ancestor(gca,'figure'),'SelectionType'),'alt'))
    cla
    set(handles.uipanel2,'Visible','on');
    set(handles.uipanel3,'Visible','on');
    set(handles.uipanel4,'Visible','on');
    set(handles.slider1,'Visible','on');
    set(handles.slider2,'Visible','on');
    set(handles.slider3,'Visible','on');
    set(handles.Joint_slider,'Visible','on');
    set(handles.play_button,'Visible','off');
    handles.current_special_axes = 4;
    set(handles.zoom,'Value',1);
    Update_regguiC_all_plots(handles);
else
    if(not(isfield(handles,'ginput')))
        handles.ginput = 0;
    end
    handles.ginput = not(handles.ginput);
    if(handles.ginput)
        Update_regguiC_plot(handles,4);
        try
            pt1 = round(get(gca,'CurrentPoint' ));
            pt1 = pt1(1,1:2);
            plot(pt1(1),pt1(2),'g.','MarkerSize',20);
            pt2 = round(ginput(1));
            plot(pt2(1),pt2(2),'gd','MarkerSize',10);
            plot([pt1(1) pt2(1)],[pt1(2) pt2(2)],'g');
            drawnow
            current_image = get(handles.image4,'Value');
            current_contour = get(handles.fusion4,'Value');
            current_view = get(handles.xyz4,'Value');
            P = [];
            P_fused = [];
            C = cell(0);
            labels = cell(0);
            % Check if CT modality (path length)
            pg_simulation = 0;
            if(isfield(handles.images.info{current_image},'OriginalHeader'))
                if(0)%strcmp(handles.images.info{current_image}.OriginalHeader.Modality,'CT'))
                    pg_simulation = 1;
                end
            end
            % For WEPL
            if(pg_simulation)
                myBeamData = [];
                [myBeamData.gantry_angle,myBeamData.table_angle,myBeamData.isocenter] = compute_beam_geometry_from_2D(pt1,pt2,current_view,handles.slice4,handles);
                energies = 200:-1:100;
                [x,y] = meshgrid(-10:2:10,-10:2:10);
                xy = [x(:),y(:)];
                for j=1:length(energies)
                    myBeamData.spots(j).energy = energies(j);
                    myBeamData.spots(j).xy = xy;
                    myBeamData.spots(j).weight = ones(size(x(:)));
                end
                if(handles.fusion_mode==0 && not(isempty(handles.images.data{current_contour})))
                    PG_simulation_GUI(handles,current_image,myBeamData,current_contour);
                else
                    PG_simulation_GUI(handles,current_image,myBeamData);
                end
            else
                switch current_view
                    case 1
                        distance = norm((pt2-pt1).*[handles.spacing(2) handles.spacing(3)]);
                        if(not(isempty(handles.images.data{current_image})))
                            P = improfile(squeeze(handles.images.data{current_image}(handles.slice4,1:handles.size(2),1:handles.size(3)))',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            labels{end+1} = strrep(handles.images.name{current_image},'_',' ');
                        end
                        if(handles.fusion_mode==1 && not(isempty(handles.images.data{current_contour})))
                            P_fused = improfile(squeeze(handles.images.data{current_contour}(handles.slice4,1:handles.size(2),1:handles.size(3)))',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            labels{end+1} = strrep(handles.images.name{current_contour},'_',' ');
                        end
                        if(get(handles.multiple_contours,'Value'))
                            for contour_index = 1:min(length(handles.contours_to_plot),6)
                                if(not(length(handles.images.data)<handles.contours_to_plot(contour_index)))
                                    P_cont = improfile((squeeze(handles.images.data{handles.contours_to_plot(contour_index)}(handles.slice4,1:handles.size(2),1:handles.size(3))) >= max(max(max(handles.images.data{handles.contours_to_plot(contour_index)})))/2)',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                                    P_cont = abs(diff(P_cont));
                                    C{contour_index} = (find(P_cont)+0.5)/length(P)*distance;
                                    if(not(isempty(C{contour_index})))
                                        labels{end+1} = strrep(handles.images.name{handles.contours_to_plot(contour_index)},'_',' ');
                                    end
                                end
                            end
                        elseif(handles.fusion_mode==0 && not(isempty(handles.images.data{current_contour})))
                            P_cont = improfile((squeeze(handles.images.data{current_contour}(handles.slice4,1:handles.size(2),1:handles.size(3))) >= max(handles.images.data{current_contour}(:))/2)',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            P_cont = abs(diff(P_cont));
                            C{1} = (find(P_cont)+0.5)/length(P)*distance;
                            labels{end+1} = strrep(handles.images.name{current_contour},'_',' ');
                        end
                    case 2
                        distance = norm((pt2-pt1).*[handles.spacing(1) handles.spacing(3)]);
                        if(not(isempty(handles.images.data{current_image})))
                            P = improfile(squeeze(handles.images.data{current_image}(1:handles.size(1),handles.slice4,1:handles.size(3)))',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            labels{end+1} = strrep(handles.images.name{current_image},'_',' ');
                        end
                        if(handles.fusion_mode==1 && not(isempty(handles.images.data{current_contour})))
                            P_fused = improfile(squeeze(handles.images.data{current_contour}(1:handles.size(1),handles.slice4,1:handles.size(3)))',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            labels{end+1} = strrep(handles.images.name{current_contour},'_',' ');
                        end
                        if(get(handles.multiple_contours,'Value'))
                            for contour_index = 1:min(length(handles.contours_to_plot),6)
                                if(not(length(handles.images.data)<handles.contours_to_plot(contour_index)))
                                    P_cont = improfile((squeeze(handles.images.data{handles.contours_to_plot(contour_index)}(1:handles.size(1),handles.slice4,1:handles.size(3))) >= max(max(max(handles.images.data{handles.contours_to_plot(contour_index)})))/2)',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                                    P_cont = abs(diff(P_cont));
                                    C{contour_index} = (find(P_cont)+0.5)/length(P)*distance;
                                    if(not(isempty(C{contour_index})))
                                        labels{end+1} = strrep(handles.images.name{handles.contours_to_plot(contour_index)},'_',' ');
                                    end
                                end
                            end
                        elseif(handles.fusion_mode==0 && not(isempty(handles.images.data{current_contour})))
                            P_cont = improfile((squeeze(handles.images.data{current_contour}(1:handles.size(1),handles.slice4,1:handles.size(3))) >= max(handles.images.data{current_contour}(:))/2)',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            P_cont = abs(diff(P_cont));
                            C{1} = (find(P_cont)+0.5)/length(P)*distance;
                            labels{end+1} = strrep(handles.images.name{current_contour},'_',' ');
                        end
                    case 3
                        distance = norm((pt2-pt1).*[handles.spacing(1) handles.spacing(2)]);
                        if(not(isempty(handles.images.data{current_image})))
                            P = improfile(squeeze(handles.images.data{current_image}(1:handles.size(1),handles.size(2):-1:1,handles.slice4))',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            labels{end+1} = strrep(handles.images.name{current_image},'_',' ');
                        end
                        if(handles.fusion_mode==1 && not(isempty(handles.images.data{current_contour})))
                            P_fused = improfile(squeeze(handles.images.data{current_contour}(1:handles.size(1),handles.size(2):-1:1,handles.slice4))',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            labels{end+1} = strrep(handles.images.name{current_contour},'_',' ');
                        end
                        if(get(handles.multiple_contours,'Value'))
                            for contour_index = 1:min(length(handles.contours_to_plot),6)
                                if(not(length(handles.images.data)<handles.contours_to_plot(contour_index)))
                                    P_cont = improfile((squeeze(handles.images.data{handles.contours_to_plot(contour_index)}(1:handles.size(1),handles.size(2):-1:1,handles.slice4)) >= max(max(max(handles.images.data{handles.contours_to_plot(contour_index)})))/2)',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                                    P_cont = abs(diff(P_cont));
                                    C{contour_index} = (find(P_cont)+0.5)/length(P)*distance;
                                    if(not(isempty(C{contour_index})))
                                        labels{end+1} = strrep(handles.images.name{handles.contours_to_plot(contour_index)},'_',' ');
                                    end
                                end
                            end
                        elseif(handles.fusion_mode==0 && not(isempty(handles.images.data{current_contour})))
                            P_cont = improfile((squeeze(handles.images.data{current_contour}(1:handles.size(1),handles.size(2):-1:1,handles.slice4)) >= max(handles.images.data{current_contour}(:))/2)',[pt1(1) pt2(1)],[pt1(2) pt2(2)]);
                            P_cont = abs(diff(P_cont));
                            C{1} = (find(P_cont)+0.5)/length(P)*distance;
                            labels{end+1} = strrep(handles.images.name{current_contour},'_',' ');
                        end
                end
                figure
                plot(linspace(0,distance,length(P)),P,'k')
                plot_scale = [min(P) max(P)];
                hold on
                if(not(isempty(P_fused)))
                    plot(linspace(0,distance,length(P)),P_fused,'Color',[0.7 0.7 0.7]);
                    plot_scale = [min(plot_scale(1),min(P_fused)) max(plot_scale(2),max(P_fused))];
                end
                contour_colors = {'y';'r';'b';'g';'c';'m'};
                if(not(isempty(C)))
                    for contour_index=1:length(C)
                        X = [];Y = [];
                        for i=1:length(C{contour_index})
                            X = [X,C{contour_index}(i),C{contour_index}(i)];
                            if(round(i/2)==i/2)
                                Y = [Y,plot_scale(2),plot_scale(1)];
                            else
                                Y = [Y,plot_scale(1),plot_scale(2)];
                            end
                        end
                        plot(X,Y,contour_colors{contour_index});
                    end
                end
                axis([0 distance plot_scale(1) plot_scale(2)])
                xlabel('distance [mm]');ylabel('intensity');
                legend(labels)
            end
        catch
            disp('Invalid command')
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
end
guidata(handles.axes5, handles);



%% File Menu ---------------------------------------------------------
% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Set_Path_To_Data_Callback(hObject, eventdata, handles)
try
    if(handles.dataPath)
        handles.dataPath = uigetdir(handles.dataPath,'Select data repository for reggui project');
    else
        handles.dataPath = uigetdir(pwd,'Select data repository for reggui project');
    end
    if(exist(handles.dataPath,'dir'))
        if(~handles.auto_mode)
            Choice = questdlg('Would you like to clear workspace (remove all images and fields)?', ...
                'Choose', ...
                'Yes','No','No');
            if(strcmp(Choice,'Yes'))
                handles = Remove_all_images(handles,1);
                if(handles.current_special_axes == 5)
                    cla
                    set(handles.uipanel2,'Visible','on');
                    set(handles.uipanel3,'Visible','on');
                    set(handles.uipanel4,'Visible','on');
                    set(handles.slider1,'Visible','on');
                    set(handles.slider2,'Visible','on');
                    set(handles.slider3,'Visible','on');
                    set(handles.Joint_slider,'Visible','on');
                    handles.current_special_axes = 4;
                end
                guidata(hObject, handles);
                handles = Update_regguiC_GUI(handles);
            end
        end
    end
catch
    disp('Set path to data aborted');
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(exist([handles.dataPath,'/patient_file.mat'],'file'))
    try
        handles = patient_file(handles);
    catch
        disp('Patient file closed erroneously.')
    end
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function New_Callback(hObject, eventdata, handles)
New(handles);
% --------------------------------------------------------------------
function New(handles)
if(handles.auto_mode)
    % Initialize the handles structure
    handles = Initialize_reggui_handles(handles);
    handles.slice1 = 1;
    handles.slice2 = 1;
    handles.slice3 = 1;
    handles.slice4 = 1;
    handles.current_special_axes = 4;
    handles.fusion_mode = 1;
    handles.contour_level = 2;
    handles.contours_to_plot = [];
    handles.plan_to_plot = [];
    set(handles.edit_instruction,'String','');
    % Update handles structure
    set(handles.edit_instruction,'String','');
    handles = executeall(handles);
    guidata(handles.New, handles);
else
    close all hidden
    eval('regguiC')
end

% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
[myProject_Name, myProject_Dir, filterindex] = uigetfile( ...
    {'*.mat','MATLAB Files (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', [handles.dataPath '/myProject']);
if isequal(myProject_Name,0) || isequal(myProject_Dir,0)
    return
end
myProject_Name = fullfile(myProject_Dir,myProject_Name);
if(not(isempty(myProject_Name)))
    try
        % set execution message in GUI
        set(handles.processing_message,'String','Opening reggui project...');
        set(handles.processing_message,'Visible','on');drawnow
        % Open project
        handles = Open_reggui_handles(handles,myProject_Name);
        handles.slice1 = 1;
        handles.slice2 = 1;
        handles.slice3 = 1;
    catch
        disp('Error occured while loading project !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    if(handles.beam_mode)
        set(handles.Import,'Visible','off');
    else
        set(handles.Import,'Visible','on');
    end
    handles = executeall(handles);
    Automatic_scale_Callback(handles.Automatic_scale, [], handles);
    set(handles.processing_message,'Visible','off');drawnow
    guidata(hObject, handles);
end
% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles, myProject_Name)
% display message
set(handles.processing_message,'String','Saving reggui project...');
set(handles.processing_message,'Visible','on');drawnow
% select ouput name
if(nargin>3 && handles.auto_mode)
else
    default_name = fullfile(handles.dataPath,'reggui_handles');
    [filename,pathname] = uiputfile({'*.mat', 'Mat file'},'Choose a name to save current handles',default_name);
    myProject_Name = fullfile(pathname,filename);
end
if(myProject_Name)
    Save_reggui_handles(handles,myProject_Name);
end
set(handles.processing_message,'Visible','off');
set(handles.processing_message,'String',cell(0));
drawnow

% --------------------------------------------------------------------
function Import_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Import_image_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
[myImageFilename, myImageDir, filterindex] = uigetfile( ...
    {'*;*.dcm;*.DCM','DICOM Serie'; ...
    '*.dcm;*.DCM','3D Dose files (*.dcm)'; ...
    '*.mat','MATLAB Files (*.mat)'; ...
    '*.hdr','ANALYZE Files (*.hdr)'; ...
    '*.mha;*.mhd','Meta Image Files (*.mha, *.mhd)'; ...
    '*.png;*.jpg;*.gif;*.tif;*.bmp;*.opg;*.dcm','2D Image Files (*.png, *.jpg, *.gif, *.tif, *.bmp, *.opg, *.dcm)'; ...
    '*.nii','NifTi Files (*.nii)'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);
Image_load = 1;
if(filterindex==8 || filterindex==1)
    [~,~,extension] = fileparts(myImageFilename);
    switch extension
        case {'.dcm','.DCM'}
            filterindex = 1;
        case '.mat'
            filterindex = 3;
        case '.hdr'
            filterindex = 4;
        case {'.mha','.mhd'}
            filterindex = 5;
        case {'.jpg','.png','.gif','.tif','.bmp','.opg'}
            filterindex = 6;
        case '.nii'
            filterindex = 7;
        case '.img'
            Image_load = 2;
            filterindex = 100;
        case '.nii'
            filterindex = 8;
    end
end
try
    default_name = cell(0);
    if(filterindex==1)
        [~,SerieName] = fileparts(myImageDir(1:end-1));
        default_name{1} = SerieName;
    else
        default_name{1} = myImageFilename(1:end-4);
    end
    myImageName = char(inputdlg({'Choose a name for this image'},' ',1,default_name));
    if(isempty(myImageName))
        Image_load = 0;
        return
    end
catch
    Image_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(Image_load==1)
    disp(['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '])
    try
        handles = Import_image(myImageDir, myImageFilename, filterindex, myImageName, handles);
        handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_image(''Select image'',''',myImageName,''',workflow_data); % handles = Import_image(''',myImageDir,''',''',myImageFilename,''',',num2str(filterindex),',''',myImageName,''',handles);'];
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
elseif(Image_load==2)
    % Select reference image
    [myRefImageFilename, myRefImageDir, filterindex] = uigetfile( ...
        {'*;*.dcm;*.DCM','DICOM Serie'; ...
        '*.dcm;*.DCM','3D Dose files (*.dcm)'; ...
        '*.mat','MATLAB Files (*.mat)'; ...
        '*.mha;*.mhd','Meta Image Files (*.mha, *.mhd)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select ''reference'' image', [handles.dataPath '/Untitled']);
    if(filterindex==5 || filterindex==1)
        [~,~,extension] = fileparts(myRefImageFilename);
        switch extension
            case {'.dcm','.DCM'}
                filterindex = 1;
            case '.mat'
                filterindex = 3;
            case '.hdr'
                filterindex = 4;
            case {'.mha','.mhd'}
                filterindex = 5;
            case {'.jpg','.png','.gif','.tif','.bmp'}
                filterindex = 6;
            case '.img'
                filterindex = 6;
        end
    end
    if(filterindex==6)
        disp('Invalid reference image. Abort.')
        return
    end
    endian = 'n';
    temp = char(inputdlg({'What is the endianness?'},' ',1,{endian}));
    if(not(isempty(temp)))
        endian = temp;
    end
    disp(['Importing binary image << ',fullfile(myImageDir,myImageFilename),' >> ... '])
    try
        handles = Import_binary_image(myImageDir,myImageFilename,endian,myImageName,handles,myRefImageDir,myRefImageFilename,filterindex);
        handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_image(''Select image'',''',myImageName,''',workflow_data); % handles = Import_binary_image(''',myImageDir,''',''',myImageFilename,''',''',endian,''',''',myImageName,''',handles,''',myRefImageDir,''',''',myRefImageFilename,''',',num2str(filterindex),');'];
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing binary image << ',fullfile(myImageDir,myImageFilename),' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
end
handles = Apply_view_point(handles);
update_str = 'show_last_image';
if(length(handles.images.info)>2)
    if(isfield(handles.images.info{end},'OriginalHeader'))
        if(isfield(handles.images.info{end}.OriginalHeader,'Modality'))
            if isDoseOrDoseRate(handles.images.info{end}.OriginalHeader.Modality)
              %(strcmp(handles.images.info{end}.OriginalHeader.Modality,'RTDOSE'))
                update_str = 'show_last_fusion';
            end
        end
    end
end
handles = Update_regguiC_GUI(handles,update_str);
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_field_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
Field_load = 1;
try
    [fieldFile,path,filterindex] = uigetfile({'*.dcm','Dicom File';...
        '*.mat','Matlab File';...
        '*.mha;*.mhd','Meta File';...
        '*.txt','Text File'}, ...
        eventdata, [handles.dataPath,'/Untitled']);
catch
    Field_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end

try
    default_name = cell(0);
    default_name{1} = fieldFile(1:end-4);
    myFieldName = char(inputdlg({'Choose a name for this field'},' ',1,default_name));
    if(isempty(myFieldName))
        Field_load = 0;
        return
    end
catch
    Field_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(Field_load)
    disp(['Importing field << ',fullfile(path,fieldFile),' >> ... '])
    try
        handles = Import_field(path,fieldFile,filterindex,myFieldName,handles);
        handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_field(''Select field'',''',myFieldName,''',workflow_data); % handles = Import_field(''',path,''',''',fieldFile,''',',num2str(filterindex),',''',myFieldName,''',handles);'];
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing field << ',fullfile(path,fieldFile),' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
    handles = Update_regguiC_GUI(handles,'show_last_field');
    Update_regguiC_all_plots(handles);
    guidata(hObject, handles);
end
% --------------------------------------------------------------------
function Import_data_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
[myDataFilename, myDataDir, filterindex] = uigetfile( ...
    {'*.mat','MATLAB Files (*.mat)'; ...
    '*.dcm;*.DCM','DICOM Serie (*.dcm)'; ...
    '*.dcm;*.DCM','3D Dose files (*.dcm)'; ...
    '*.mat','MATLAB Files (*.mat)'; ...
    '*.hdr','ANALYZE Files (*.hdr)'; ...
    '*.mha;*.mhd','Meta Image Files (*.mha, *.mhd)'; ...
    '*.tif;*.bmp;*.png;*.jpg;*.gif;*.dcm','2D Image Files (*.tif, *.bmp, *.png, *.jpg, *.gif, *.dcm)'; ...
    '*.txt','TEXT Files (*.txt)'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);
Data_load = 1;
filterindex = filterindex-1;
if(filterindex==0)
    filterindex = 3;
end
if(filterindex==9)
    [~,~,extension] = fileparts(myDataFilename);
    switch extension
        case {'.dcm','.DCM'}
            filterindex = 1;
        case '.mat'
            filterindex = 3;
        case '.hdr'
            filterindex = 4;
        case {'.mha','.mhd'}
            filterindex = 5;
        case {'.jpg','.png','.gif','.tif','.bmp'}
            filterindex = 6;
        case {'.txt'}
            filterindex = 7;
    end
end
try
    default_name = cell(0);
    default_name{1} = myDataFilename(1:end-4);
    myDataName = char(inputdlg({'Choose a name for this data'},' ',1,default_name));
    if(isempty(myDataName))
        Data_load = 0;
        return
    end
catch
    Data_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(Data_load)
    disp(['Importing data << ',fullfile(myDataDir,myDataFilename),' >> ... '])
    try
        handles = Import_data(myDataDir, myDataFilename, filterindex, myDataName, handles);
        handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_data(''Select image'',''',myDataName,''',workflow_data); % handles = Import_data(''',myDataDir,''',''',myDataFilename,''',',num2str(filterindex),',''',myDataName,''',handles);'];
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing data << ',fullfile(myDataDir,myDataFilename),' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
    guidata(hObject, handles);
end
% --------------------------------------------------------------------
function Import_contour_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
[myContourFilename, myContourDir] = uigetfile( ...
    {'*.*','RTSTRUCT Files (*)'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);
type = 1;
[image,type] = Image_list(handles,'On which image is this RTStruct Based',type);
try
    [~,info] = Get_reggui_data(handles,image);
    contours = read_dicomrtstruct(fullfile(myContourDir,myContourFilename),info);
    temp_instruction = ['[~,info] = Get_reggui_data(handles,''',image,''');contours = read_dicomrtstruct(fullfile(''',myContourDir,''',''',myContourFilename,'''),info);'];
catch
    disp('This is not a valid RTStruct file or not a valid reference image!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
contoursAvailable = {contours.Struct.Name};
[selectedContours,OK] = listdlg('PromptString','Select contour(s):',...
    'SelectionMode','multiple',...
    'ListString',contoursAvailable);
if OK==0
    disp('Wrong selection')
    return
end
disp(['Importing contours << ',fullfile(myContourDir,myContourFilename),' >> ... '])
try
    handles = Import_contour(contours,selectedContours,image,type,handles);
    handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_contour(''Select contour'',''',image,''',',num2str(type),',workflow_data); % ',temp_instruction,'handles = Import_contour(contours,[',num2str(selectedContours),'],''',image,''',',num2str(type),',handles);'];
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing contours << ',fullfile(myContourDir,myContourFilename),' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
handles = Update_regguiC_GUI(handles,'show_last_contour');
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_RT_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
[myContourFilename, myContourDir] = uigetfile( ...
    {'*.*','RTSTRUCT Files (*)'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);

type = 0;
images_nb = length(handles.images.data);
fields_nb = length(handles.fields.data);
data_nb = length(handles.mydata.data);

% Import image
myContourDir = myContourDir(1:end-1);
[myImageDir,myImageFilename] = fileparts(myContourDir);
try
    default_name = cell(0);
    default_name{1} = myImageFilename;
    myImageName = char(inputdlg({'Choose a name for this image'},' ',1,default_name));
    if(isempty(myImageName))
        return
    end
catch
    Image_load = 0;
    disp('Error : not a valid image file !')
end
disp(['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '])
try
    handles = Import_image(myImageDir, myImageFilename, 8, myImageName, handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
handles = Update_regguiC_GUI(handles,'show_last_image');
if(images_nb < length(handles.images.data))
    if(fields_nb < length(handles.fields.data))
        type = 2; % imported as image but with rigid alignment
    else
        type = 1; % imported as image
    end
elseif(data_nb < length(handles.mydata.data))
    type = 3; % imported as data
end

% Import contour
try
    if type==1
        cntrs = read_dicomrtstruct(fullfile(myContourDir,myContourFilename),handles.images.info{end});
    elseif(type==3)
        cntrs = read_dicomrtstruct(fullfile(myContourDir,myContourFilename),handles.mydata.info{end});
    end
catch
    disp('This is not a valid RTStruct file!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
contoursAvailable = {cntrs.Struct.Name};
[selectedContours,OK] = listdlg('PromptString','Select contour(s):',...
    'SelectionMode','multiple',...
    'ListString',contoursAvailable);
if OK==0
    disp('Wrong selection')
    return
end

myImageName = strrep(myImageName,' ','_');
disp(['Importing contours ... '])
try
    handles = Import_contour(cntrs,selectedContours,myImageName,type,handles);
    handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_RT(''Select contour'',''',myImageName,''',',num2str(type),',workflow_data); % handles = Import_contour(...);'];
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing contours ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
handles = Apply_view_point(handles);
handles = Update_regguiC_GUI(handles,'show_last_contour');
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_4D_image_Callback(hObject, eventdata, handles)
current_dir = pwd;
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Select reference DICOM image (directory)';
end
Images_load = 1;
try
    myDirFilename = uigetdir(handles.dataPath,eventdata);
    cd(myDirFilename)
    cd ..
    myImageDir = pwd;
    [~,myImageFilename] = fileparts(myDirFilename);
    otherfiles = struct2cell(dir_without_hidden(pwd,'folders'));
    otherfiles = otherfiles(1,:);
    [selectedDirs,OK] = listdlg('PromptString','Select all other phases',...
        'SelectionMode','multiple',...
        'ListString',otherfiles);
    cd(current_dir)
    if OK==0
        disp('Wrong selection')
        return
    end
catch
    cd(current_dir)
    Images_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(Images_load)
    disp(['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '])
    try
        handles = Import_image(myImageDir, myImageFilename, 8, myImageFilename, handles);
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
    temp_instruction = ' % ';
    for i=1:length(selectedDirs)
        if(not(strcmp(myImageFilename,otherfiles{selectedDirs(i)})))
            disp(['Importing image << ',fullfile(myImageDir, otherfiles{selectedDirs(i)}),' >> ... '])
            try
                handles = Import_image(myImageDir, otherfiles{selectedDirs(i)}, 8, otherfiles{selectedDirs(i)}, handles);
                temp_instruction = [temp_instruction,'handles = Import_image(''',myImageDir,''',''',otherfiles{selectedDirs(i)},''', 7,''',otherfiles{selectedDirs(i)},''', handles);'];
            catch
                % Display and log last error
                err = lasterror;
                msg{1} = ['Importing image << ',fullfile(myImageDir, otherfiles{selectedDirs(i)}),' >> ... '];
                msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
                reggui_logger.error(msg,handles.log_filename);
                disp(' ')
            end
        end
    end
    handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_4D(''Select image'',workflow_data);',temp_instruction];
    handles = Apply_view_point(handles);
    handles = Update_regguiC_GUI(handles,'show_last_image');
    Update_regguiC_all_plots(handles);
    guidata(hObject, handles);
end
% --------------------------------------------------------------------
function Import_4D_RT_Callback(hObject, eventdata, handles)
current_dir = pwd;
% Select rtstruct on the reference
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Select reference DICOM rt-struct';
end
[myContourFilename, myDirFilename] = uigetfile( ...
    {'*.*','RTSTRUCT Files (*)'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);
try
    contours = read_dicomrtstruct(fullfile(myDirFilename,myContourFilename));
catch
    disp('This is not a valid RTStruct file!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
contoursAvailable = {contours.Struct.Name};
[selectedContour,OK] = listdlg('PromptString','Select a contour:',...
    'SelectionMode','single',...
    'ListString',contoursAvailable);
if OK==0
    disp('Wrong selection')
    return
end
Images_load = 1;
% Select all 4D phases
cd(myDirFilename)
cd ..
myImageDir = pwd;
[~,myImageFilename] = fileparts(myDirFilename);
otherfiles = struct2cell(dir_without_hidden(pwd,'folders'));
otherfiles = otherfiles(1,:);
[selectedDirs,~] = listdlg('PromptString','Select all DICOM images',...
    'SelectionMode','multiple',...
    'ListString',otherfiles);
cd(current_dir)
% Check for rtstructs
selectedContour_index = zeros(1,length(selectedDirs));
other_contours = cell(0);
for i=1:length(selectedDirs)
    cd(myImageDir)
    cd(otherfiles{selectedDirs(i)})
    dicom_files = struct2cell(dir);
    dicom_files = dicom_files(1,3:end);
    isdcm = strfind(dicom_files,'.dcm');
    for j=1:length(dicom_files)
        if(isempty(isdcm{j}))
            isdcm{j} = 0;
        end
    end
    dicom_files = dicom_files(find(cell2mat(isdcm)));
    if(length(dicom_files)>1)
        disp('Too many dcm files in this repository... can''t find unique rtstruct')
    else
        try
            disp(fullfile(otherfiles{selectedDirs(i)},dicom_files{1}))
            current_struct = read_dicomrtstruct(fullfile(otherfiles{selectedDirs(i)},dicom_files{1}));
            contoursAvailable = {current_struct.Struct.Name};
            for j=1:length(contoursAvailable)
                if(strcmp(contoursAvailable{j}(1:end-(min(2,length(contoursAvailable{j})-3))),contours.Struct(selectedContour).Name(1:length(contoursAvailable{j})-(min(2,length(contoursAvailable{j})-3)))))
                    selectedContour_index(i) = 1;
                    other_contours{i} = current_struct;
                end
            end
        catch
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
end
cd(current_dir)
if(Images_load)
    current_auto_mode = handles.auto_mode;
    handles.auto_mode = 1;
    try
        images_nb = length(handles.images.data);
        data_nb = length(handles.mydata.data);
        disp(['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '])
        try
            handles = Import_image(myImageDir, myImageFilename, 8, myImageFilename, handles);
        catch
            % Display and log last error
            err = lasterror;
            msg{1} = ['Importing image << ',fullfile(myImageDir,myImageFilename),' >> ... '];
            msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
            reggui_logger.error(msg,handles.log_filename);
            disp(' ')
        end
        handles = Update_regguiC_GUI(handles,'show_last_image');
        if(images_nb < length(handles.images.data))
            type = 1;
        elseif(data_nb < length(handles.mydata.data))
            type = 3;
        end
        myImageFilename = strrep(myImageFilename,' ','_');
        disp(['Importing contours ... '])
        try
            handles = Import_contour(contours,selectedContour,myImageFilename,type,handles);
        catch
            % Display and log last error
            err = lasterror;
            msg{1} = ['Importing contours ... '];
            msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
            reggui_logger.error(msg,handles.log_filename);
            disp(' ')
        end
        for i=1:length(selectedDirs)
            try
                if(not(strcmp(myImageFilename,strrep(otherfiles{selectedDirs(i)},' ','_'))))
                    disp(['Importing image << ',fullfile(myImageDir,otherfiles{selectedDirs(i)}),' >> ... '])
                    try
                        handles = Import_image(myImageDir, otherfiles{selectedDirs(i)}, 8, otherfiles{selectedDirs(i)}, handles);
                    catch
                        % Display and log last error
                        err = lasterror;
                        msg{1} = ['Importing image << ',fullfile(myImageDir,otherfiles{selectedDirs(i)}),' >> ... '];
                        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
                        reggui_logger.error(msg,handles.log_filename);
                        disp(' ')
                    end
                    if(selectedContour_index(i))
                        disp(['Importing contours ... '])
                        try
                            handles = Import_contour(other_contours{i},selectedContour_index(i),strrep(otherfiles{selectedDirs(i)},' ','_'),type,handles);
                        catch
                            % Display and log last error
                            err = lasterror;
                            msg{1} = ['Importing contours ... '];
                            msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
                            reggui_logger.error(msg,handles.log_filename);
                            disp(' ')
                        end
                    end
                end
            catch
            end
        end
    catch
    end
    handles.auto_mode = current_auto_mode;
    handles = Apply_view_point(handles);
    handles = Update_regguiC_GUI(handles,'show_last_contour');
    Update_regguiC_all_plots(handles);
    guidata(hObject, handles);
end
% --------------------------------------------------------------------
function Import_plan_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
[myPlanFilename, myPlanDir, filterindex] = uigetfile( ...
    {'*;*.dcm;*.DCM','DICOM RT plan'; ...
    '*.pld;*.PLD','PLD file'; ...
    '*.txt','Gate input file'; ...
    '*.json;*.JSON','JSON file'; ...
    '*.zip','PLDs zip file'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);

if(filterindex==5)
    [~,~,extension] = fileparts(myPlanFilename);
    switch extension
        case {'.pld','.zip'}
            filterindex = 2;
        case '.txt'
            filterindex = 3;
        otherwise
            filterindex = 1;
    end
end
Plan_load = 1;
try
    default_name = cell(0);
    default_name{1} = remove_bad_chars(strrep(myPlanFilename,'.dcm',''));
    myPlanName = char(inputdlg({'Choose a name for this plan'},' ',1,default_name));
    if(isempty(myPlanName))
        Plan_load = 0;
        return
    end
catch
    Plan_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(Plan_load==1)
    disp(['Importing plan << ',fullfile(myPlanDir,myPlanFilename),' >> ... '])
    try
        handles = Import_plan(myPlanDir, myPlanFilename, filterindex, myPlanName, handles);
        handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_plan(''Select RT plan'',''',myPlanName,''',workflow_data); % handles = Import_plan(''',myPlanDir,''',''',myPlanFilename,''',',num2str(filterindex),',''',myPlanName,''',handles);'];
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing plan << ',fullfile(myPlanDir,myPlanFilename),' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
    guidata(hObject, handles);
end
handles = Update_regguiC_GUI(handles,'show_last_plan');
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_RT_archive_Callback(hObject, eventdata, handles)
type = 0;
images_nb = length(handles.images.data);
fields_nb = length(handles.fields.data);
data_nb = length(handles.mydata.data);
% Select RT directory and list RT data
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Select directory';
end
myDir = uigetdir(handles.dataPath, eventdata);
list_of_data = listing_dicom_data(myDir,1);
myImageFilename = cell(0);
myDoseFilename = cell(0);
myPlanFilename = cell(0);
myContourFilename = cell(0);
found_ct = 0;
found_dose = 0;
found_plan = 0;
found_structs = 0;
for i=1:size(list_of_data,1)
    switch list_of_data{i,8}
        case 'CT'
            if(found_ct)
                disp('Warning: multiple CT images found !! Importing only first image.')
            else
                myImageFilename = list_of_data{i,5};
                found_ct = 1;
            end
        case {'RTDOSE','RTDOSERATE'}
            if(found_dose)
                disp('Warning: multiple dose maps found !! Importing all of them.')
            else
                myDoseFilename{end+1} = list_of_data{i,5};
                found_dose = 1;
            end
        case 'RTPLAN'
            if(found_plan)
                disp('Warning: multiple plans found !! Importing all of them.')
            else
                myPlanFilename{end+1} = list_of_data{i,5};
                found_plan = 1;
            end
        case 'RTSTRUCT'
            if(found_structs)
                disp('Warning: multiple structures found !! Importing only first one.')
            else
                myContourFilename = list_of_data{i,5};
                found_structs = 1;
            end
    end
end

% Import image
if(isempty(myImageFilename))
    disp('No CT image found. Abort')
    return
end
try
    [~,dirName] = fileparts(myDir);
    default_name = cell(0);
    default_name{1} = dirName;
    myImageName = char(inputdlg({'Choose a name for this image'},' ',1,default_name));
    if(isempty(myImageName))
        return
    end
catch
    Image_load = 0;
    disp('Error : not a valid image file !')
end
disp(['Importing image << ',fullfile(myDir,myImageFilename),' >> ... '])
try
    handles = Import_image(myDir, myImageFilename, 8, myImageName, handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing image << ',fullfile(myDir,myImageFilename),' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
handles = Update_regguiC_GUI(handles,'show_last_image');
if(images_nb < length(handles.images.data))
    if(fields_nb < length(handles.fields.data))
        type = 2; % imported as image but with rigid alignment
    else
        type = 1; % imported as image
    end
    images_nb = images_nb+1;
elseif(data_nb < length(handles.mydata.data))
    type = 3; % imported as data
end

% Import contour
if(not(isempty(myContourFilename)))
    try
        if type==1
            cntrs = read_dicomrtstruct(fullfile(myDir,myContourFilename),handles.images.info{end});
        elseif(type==3)
            cntrs = read_dicomrtstruct(fullfile(myDir,myContourFilename),handles.mydata.info{end});
        end
    catch
        disp('This is not a valid RTStruct file!')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        return
    end
    contoursAvailable = {cntrs.Struct.Name};
    [selectedContours,OK] = listdlg('PromptString','Select contour(s):',...
        'SelectionMode','multiple',...
        'ListString',contoursAvailable);
    if OK==0
        disp('Wrong selection')
        return
    end
    myImageName = strrep(myImageName,' ','_');
    disp(['Importing contours ... '])
    try
        handles = Import_contour(cntrs,selectedContours,myImageName,type,handles);
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing contours ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
    handles = Update_regguiC_GUI(handles,'show_last_contour');
end
handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_RT_archive(''Select directory'',''',myImageName,''',',num2str(type),',workflow_data);'];

% Import dose
auto_mode = handles.auto_mode;
handles.auto_mode = 1;
if(not(isempty(myDoseFilename)))
    for j=1:length(myDoseFilename)
        disp(['Importing image << ',fullfile(myDir,myDoseFilename{j}),' >> ... '])
        try
            if(type==1)
                handles = Import_image(myDir, myDoseFilename{j}, 2, [myImageName,'_dose',num2str(j)], handles);
            elseif(type==3)
                handles = Import_data(myDir, myDoseFilename{j}, 2, [myImageName,'_dose',num2str(j)], handles);
            end
        catch
            % Display and log last error
            err = lasterror;
            msg{1} = ['Importing image << ',fullfile(myDir,myDoseFilename{j}),' >> ... '];
            msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
            reggui_logger.error(msg,handles.log_filename);
            disp(' ')
        end
    end
end
handles.auto_mode = auto_mode;

% Import plan
if(not(isempty(myPlanFilename)))
    for j=1:length(myPlanFilename)
        disp(['Importing plan << ',fullfile(myDir,myPlanFilename{j}),' >> ... '])
        try
            handles = Import_plan(myDir, myPlanFilename{j}, 1, [myImageName,'_plan',num2str(j)], handles);
        catch
            % Display and log last error
            err = lasterror;
            msg{1} = ['Importing plan << ',fullfile(myDir,myPlanFilename{j}),' >> ... '];
            msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
            reggui_logger.error(msg,handles.log_filename);
            disp(' ')
        end
    end
    handles = Center_on_plan_isocenter(handles,[myImageName,'_plan',num2str(j)]);
end

% Update viewed images
if(type==1)
    i = 1;
    while(isfield(handles,['image',num2str(i)]))
        image_tag = ['image',num2str(i)];
        fusion_tag = ['fusion',num2str(i)];
        set(handles.(image_tag),'Value',images_nb);
        if(not(isempty(myContourFilename))||not(isempty(myDoseFilename)))
            set(handles.(fusion_tag),'Value',length(handles.images.name));
        end
        i = i+1;
    end
    [handles.minscale,handles.maxscale] = get_image_scale({handles.images.data{images_nb}},handles.scale_prctile);
    if(not(isempty(myDoseFilename)))
        [handles.minscaleF,handles.maxscaleF] = get_image_scale({handles.images.data{end}},handles.scale_prctile);
        handles.fusion_mode = 1;
    end
end
handles = Apply_view_point(handles);
handles = Update_regguiC_GUI(handles);
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_PBS_logs_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
[myPlanFilenames, myPlanDir, filterindex] = uigetfile( ...
    {'*.dcm;*.DCM','DICOM RT record'; ...
    '*.zip','IBA log file(s)'; ...
    '*.txt','IBA scanalgo config'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, ...
    'MultiSelect', 'on', ...
    [handles.dataPath '/Untitled']);
if(not(iscell(myPlanFilenames)))
    myPlanFilenames = {myPlanFilenames};
end
if(filterindex==4)
    [~,~,extension] = fileparts(myPlanFilenames{1});
    switch extension
        case {'.zip'}
            filterindex = 2;
        case {'.txt'}
            filterindex = 3;
        otherwise
            filterindex = 1;
    end
end
% select reference plan
[plan,type1] = Image_list(handles,'Select plan',4);
if(not(type1==4))
    disp('Error : wrong type of data ! Please select a treatment plan');
    return
end
Plan_load = 1;
try
    default_name = cell(0);
    if(filterindex<=1) % dicom import
        default_name{1} = remove_bad_chars(strrep(myPlanFilenames{1},'.dcm',''));
    else
        default_name{1} = remove_bad_chars([plan,'_log']);
    end
    myPlanName = inputdlg('Choose a name for resulting plan','Choose name',1,default_name);
    if(isempty(myPlanName))
        Plan_load = 0;
        return
    else
        myPlanName = myPlanName{1};
    end
catch
    Plan_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(Plan_load==1)
    aggregate_paintings = 0;
    overwrite_geometry = 0;
    if(filterindex==1 || filterindex==2)
        answer = questdlg('Use planned geometry?', ...
            'Select geometry (plan or log)', ...
            'Yes', 'No', 'No');
        switch answer
            case 'Yes'
                overwrite_geometry = 1;
        end
    end
    disp(['Importing records from << ',fullfile(myPlanDir,cell2str(myPlanFilenames)),' >> ... '])
    try
        handles = Import_tx_records(myPlanDir, myPlanFilenames, filterindex, myPlanName, handles, plan, aggregate_paintings, overwrite_geometry);
        handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_record(''Select record/logs'',''',myPlanName,''',workflow_data,''',plan,'''); % handles = Import_tx_records(''',myPlanDir,''',',cell2str(myPlanFilenames),',',num2str(filterindex),',''',myPlanName,''',handles,''',plan,''',',num2str(aggregate_paintings),',',num2str(overwrite_geometry),');'];
    catch ME
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing records from << ',fullfile(myPlanDir,cell2str(myPlanFilenames)),' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
        rethrow(ME);
    end
    handles = Update_regguiC_GUI(handles,'show_last_plan');
    Update_regguiC_all_plots(handles);
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_indicators_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
indic_load = 1;
try
    [indicFile,path] = uigetfile('*.json', ...
        eventdata, [handles.dataPath '/Untitled']);
catch
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
[~,default_name,extension] = fileparts(indicFile);
try
    default_name = {default_name};
    myIndicName = char(inputdlg({'Choose a name for these indicators'},' ',1,default_name));
    if(isempty(myIndicName))
        return
    end
catch
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
disp(['Importing indicators << ',fullfile(path,indicFile),' >> ... '])
try
    handles = Import_indicators(path,indicFile,extension(2:end),myIndicName,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing indicators << ',fullfile(path,indicFile),' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_reg_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
try
    [regFile,path] = uigetfile('*.mat', ...
        eventdata, [handles.dataPath '/Untitled']);
catch
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end

try
    default_name = cell(0);
    default_name{1} = regFile(1:end-4);
    myRegName = char(inputdlg({'Choose a name for this registration'},' ',1,default_name));
    if(isempty(myRegName))
        return
    end
catch
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
disp(['Importing registration << ',fullfile(path,regFile),' >> ... '])
try
    handles = Import_reg(path,regFile,myRegName,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing registration << ',fullfile(path,regFile),' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_instructions_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
[myInFilename,myInDir,filterindex] = uigetfile( ...
    {'*.txt','Text Files (*.txt)'; ...
    '*.mat','Matlab Files (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);
disp(['Importing instructions << ',fullfile(myInDir,myInFilename),' >> ... '])
try
    handles = Import_instructions(myInDir,myInFilename,filterindex,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing instructions << ',fullfile(myInDir,myInFilename),' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_dvhs_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
try
    [dvhFile,path,filterindex] = uigetfile({'*.mat','Matlab Files (*.mat)';'*.json','Json Files (*.json)'}, eventdata, [handles.dataPath '/Untitled']);
catch
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
disp(['Importing dvhs << ',fullfile(path,dvhFile),' >> ... '])
try
    handles = Import_dvhs(path,dvhFile,handles,filterindex);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing dvhs << ',fullfile(path,dvhFile),' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_from_PACS_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Import_image_from_PACS_Callback(hObject, eventdata, handles)
[myImageId,mySeriesName] = pacs_list('image');
try
    myImageName = char(inputdlg({'Choose a name for this image'},' ',1,mySeriesName));
    if(isempty(myImageName))
        return
    end
catch
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
disp(['Importing image << ',mySeriesName{1},' >> from the PACS ... '])
try
    handles = Import_image(mySeriesName{1}, myImageId{1}, 'pacs', myImageName, handles);
    handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_image(''Select image'',''',myImageName,''',workflow_data); % handles = Import_image(''',mySeriesName{1},''',''',myImageId{1},''',''','pacs',''',''',myImageName,''',handles);'];
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing image << ',mySeriesName{1},' >> from the PACS ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
handles = Apply_view_point(handles);
handles = Update_regguiC_GUI(handles,'show_last_image');
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_contour_from_PACS_Callback(hObject, eventdata, handles)
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Pick a file';
end
myContourID = pacs_list('struct');
type = 1;
[image,type] = Image_list(handles,'On which image is this RTStruct Based',type);
temp = orthanc_get_info(['series/',myContourID{1}]);
contour_id = temp.Instances{1};
temp = orthanc_get_info(['instances/',contour_id,'/simplified-tags']);
contoursAvailable = {};
for i=1:length(temp.StructureSetROISequence)
    contoursAvailable{end+1} = temp.StructureSetROISequence{i}.ROIName;
end
[selectedContours,OK] = listdlg('PromptString','Select contour(s):',...
    'SelectionMode','multiple',...
    'ListString',contoursAvailable);
if OK==0
    disp('Wrong selection')
    return
end
disp(['Importing contours << ',contour_id,' >> from the PACS ... '])
try
    handles = Import_contour(contour_id,selectedContours,image,type,handles);
    handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_contour(''Select contour'',''',image,''',',num2str(type),',workflow_data); % handles = Import_contour(...);'];
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Importing contours << ',contour_id,' >> from the PACS ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
handles = Update_regguiC_GUI(handles,'show_last_contour');
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Import_plan_from_PACS_Callback(hObject, eventdata, handles)
[myPlanId,mySeriesName] = pacs_list('plan');
Plan_load = 1;
try
    default_name = cell(0);
    default_name{1} = remove_bad_chars(strrep(mySeriesName{1},'.dcm',''));
    myPlanName = char(inputdlg({'Choose a name for this plan'},' ',1,default_name));
    if(isempty(myPlanName))
        Plan_load = 0;
        return
    end
catch
    Plan_load = 0;
    disp('Error : not a valid file !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
if(Plan_load==1)
    temp = orthanc_get_info(['series/',myPlanId{1}]);
    plan_id = temp.Instances{1};
    disp(['Importing plan << ',mySeriesName{1},' >> ... '])
    try
        handles = Import_plan(mySeriesName{1}, plan_id, 'pacs', myPlanName, handles);
        handles.instruction_history{length(handles.instruction_history)+1} = ['Generate_import_plan(''Select RT plan'',''',myPlanName,''',workflow_data); % handles = Import_plan(''',mySeriesName{1},''',''',plan_id,''',''','pacs',''',''',myPlanName,''',handles);'];
    catch
        % Display and log last error
        err = lasterror;
        msg{1} = ['Importing plan << ',mySeriesName{1},' >> ... '];
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
    end
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function Export_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Export_image_Callback(hObject, eventdata, handles)
name = Image_list(handles,'What do you want to export ?',1,1);
outname = cell(size(name));
for n=1:length(name)
    default_name = [handles.dataPath,'/reggui_',name{n}];
    [filename,pathname] = uiputfile({'*', 'no file extension'},['Choose a name to export (without file extension) ',name{n}],default_name);
    outname{n} = fullfile(pathname,filename);
end
disp(['Exporting image ... '])
try
    handles = Export_image(name,outname,[],handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting image ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_field_Callback(hObject, eventdata, handles)
name = Image_list(handles,'What do you want to export ?',2,1);
outname = cell(size(name));
for n=1:length(name)
    default_name = [handles.dataPath,'/reggui_',name{n}];
    [filename,pathname] = uiputfile({'*', 'no file extension'},['Choose a name to export (without file extension) ',name{n}],default_name);
    outname{n} = fullfile(pathname,filename);
end
disp(['Exporting field ... '])
try
    handles = Export_field(name,outname,[],handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting field ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_transform_and_field_Callback(hObject, eventdata, handles)
default_name = cell(0);
name1 = Image_list(handles,'Select pre-def rigid transform',2);
name2 = Image_list(handles,'Select deformation field',2);
default_name{1} = [handles.dataPath,'/reggui_',name2];
[filename,pathname] = uiputfile({'*', 'no file extension '},'Choose a name to export (without file extension)',default_name{1});
outname = fullfile(pathname,filename);
disp(['Exporting transform and field to << ',outname,' >> ... '])
try
    Export_transform_and_field(name1,name2,outname,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting transform and field to << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_data_Callback(hObject, eventdata, handles)
name = Image_list(handles,'What do you want to export ?',3);
default_name = [handles.dataPath,'/reggui_',name];
[filename,pathname] = uiputfile({'*', 'no file extension '},'Choose a name to export (without file extension)',default_name);
outname = fullfile(pathname,filename);
disp(['Exporting data  to << ',outname,' >> ... '])
try
    Export_data(name,outname,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting data to << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_contour_Callback(hObject, eventdata, handles)
name = handles.images.name;
[selection, OK] = listdlg('PromptString','Which mask(s) do you want to export (multiple choice accepted)', 'SelectionMode', 'multiple', 'ListString',name);
if (~OK)
    return;
end
names_list = '';
for i=1:length(selection)-1
    names_list = [names_list '''' handles.images.name{selection(i)} ''','];
end
names_list = [names_list '''' handles.images.name{selection(end)} ''''];
eval(['contours_names = {',names_list,'};']);
[ref_image_name,type1] = Image_list(handles,'To which image do you want the contours header to correspond ?',1);
if (type1~=1&&type1~=3)
    disp('Wrong type of data!');
    return;
end
default_name = cell(0);
default_name{1} = [handles.dataPath,'/',ref_image_name,'_rtstruct'];
[filename,pathname] = uiputfile({'*', 'no file extension '},'Choose a name to export (without file extension)',default_name{1});
outname = fullfile(pathname,filename);
disp(['Exporting contour to << ',outname,' >> ... '])
try
    handles = Export_contour(contours_names,ref_image_name,outname,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting contour to << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_contour_to_existing_rtstruct_Callback(hObject, eventdata, handles)
name = handles.images.name;
[selection, OK] = listdlg('PromptString','Which mask(s) do you want to export (multiple choice accepted)', 'SelectionMode', 'multiple', 'ListString',name);
if (~OK)
    return;
end
names_list = '';
for i=1:length(selection)-1
    names_list = [names_list '''' handles.images.name{selection(i)} ''','];
end
names_list = [names_list '''' handles.images.name{selection(end)} ''''];
eval(['contours_names = {' names_list '};']);
[ref_image_name type1] = Image_list(handles,'To which image do these contours correspond ?',1);
if (type1~=1&&type1~=3)
    disp('Wrong type of data!');
    return;
end
if(isempty(eventdata) || not(ischar(eventdata)))
    eventdata = 'Select RTstruct to be updated with exported contours.';
end
[myContourFilename, myContourDir] = uigetfile( ...
    {'*.*','RTSTRUCT Files (*)'; ...
    '*.*',  'All Files (*.*)'}, ...
    eventdata, [handles.dataPath '/Untitled']);
default_name = cell(0);
default_name{1} = [myContourDir,strrep(myContourFilename,'.dcm',''),'_ext'];
[filename,pathname] = uiputfile({'*', 'no file extension '},'Choose a name to export (without file extension)',default_name{1});
outname = fullfile(pathname,filename);
disp(['Exporting contour to << ',outname,' >> ... '])
try
    handles = Export_contour(contours_names,ref_image_name,outname,handles,[],{},fullfile(myContourDir,myContourFilename));
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting contour to << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_contour_to_mesh_Callback(hObject, eventdata, handles)
name = handles.images.name;
[selection, OK] = listdlg('PromptString','Which mask do you want to export', 'SelectionMode', 'single', 'ListString',name);
if (~OK)
    return;
end
binary_mask = handles.images.name{selection};
[ref_image type1] = Image_list(handles,'To which image do the contour corresponds ?',1);
if (type1~=1&&type1~=3)
    disp('Wrong type of data!');
    return;
end
default_name = cell(0);
default_name{1} = [handles.dataPath,'/rtstruct_' ref_image '_' binary_mask];
[filename,pathname] = uiputfile({'*', 'no file extension '},'Choose a name to export (without file extension)',default_name{1});
outname = fullfile(pathname,filename);
disp(['Exporting contour to << ',outname,' >> ... '])
try
    handles = Export_contour_to_mesh(binary_mask,ref_image,outname,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting contour to << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_plan_Callback(hObject, eventdata, handles)
name = Image_list(handles,'What plan do you want to export ?',4,1);
outname = cell(size(name));
for n=1:length(name)
    default_name = [handles.dataPath,'/reggui_',name{n}];
    [filename,pathname] = uiputfile({'*', 'no file extension'},['Choose a name to export (without file extension) ',name{n}],default_name);
    outname{n} = fullfile(pathname,filename);
end
disp(['Exporting plan ... '])
try
    Export_plan(name,outname,[],handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting plan ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_indicators_Callback(hObject, eventdata, handles)
name = Image_list(handles,'What indicators do you want to export ?',7,1);
outname = cell(size(name));
for n=1:length(name)
    default_name = [handles.dataPath,'/reggui_',name{n}];
    [filename,pathname] = uiputfile({'*', 'no file extension'},['Choose a name to export (without file extension) ',name{n}],default_name);
    outname{n} = fullfile(pathname,filename);
end
disp(['Exporting indicators ... '])
try
    Export_indicators(name,outname,[],handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting indicators ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_dvhs_Callback(hObject, eventdata, handles)
[filename,pathname] = uiputfile({'*', 'no file extension '},'Choose a name to export (without file extension)',fullfile(handles.dataPath,'dvhs'));
outname = fullfile(pathname,filename);
disp(['Exporting DVHs to << ',outname,' >> ... '])
try
    Export_DVH(outname,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_reg_Callback(hObject, eventdata, handles)
name = Image_list(handles,'What registration do you want to export ?',5,1);
outname = cell(size(name));
for n=1:length(name)
    default_name = [handles.dataPath,'/reggui_',name{n}];
    [filename,pathname] = uiputfile({'*', 'no file extension'},['Choose a name to export (without file extension) ',name{n}],default_name);
    outname{n} = fullfile(pathname,filename);
end
disp(['Exporting << ',outname,' >> ... '])
try
    Export_reg(name,outname,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting registration to << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_instructions_Callback(hObject, eventdata, handles)
try
    instruction_list = get(handles.instructions_handles.listbox1,'String');
catch
    disp('Instruction list was closed. Exiting instruction list mode.');
    set(handles.instruction_list_check,'Value',0);
    set(handles.edit_instruction,'Visible','off');
    set(handles.add_button,'Visible','off');
    set(handles.replace_button,'Visible','off');
    set(handles.remove_button,'Visible','off');
    set(handles.insert_button,'Visible','off');
    set(handles.execute_button,'Visible','off');
    set(handles.execute_all_button,'Visible','off');
    set(handles.execute_manual_button,'Visible','off');
    handles = rmfield(handles,'instructions_handles');
    handles.reggui_mode = 0;
    return
end
[filename,pathname] = uiputfile({'*', 'no file extension '},'Choose a name to export (without file extension)',[handles.dataPath '/instructions']);
outname = fullfile(pathname,filename);
disp(['Exporting instructions to << ',outname,' >> ... '])
try
    Export_instructions(instruction_list,outname);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting insructions to << ',outname,' >> ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_to_PACS_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Export_image_to_PACS_Callback(hObject, eventdata, handles)
name = Image_list(handles,'What do you want to export ?',1,1);
for n=1:length(name)
    outname(n) = inputdlg('Choose a name for this image','Choose image name',1,name(n));
end
disp(['Exporting image ... '])
try
    handles = Export_image(name,outname,0,handles);
catch
    % Display and log last error
    err = lasterror;
    msg{1} = ['Exporting image ... '];
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Export_contour_to_PACS_Callback(hObject, eventdata, handles)
name = handles.images.name;
[selection, OK] = listdlg('PromptString','Which mask(s) do you want to export (multiple choice accepted)', 'SelectionMode', 'multiple', 'ListString',name);
if (~OK)
    return;
end
names_list = '';
for i=1:length(selection)-1
    names_list = [names_list '''' handles.images.name{selection(i)} ''','];
end
names_list = [names_list '''' handles.images.name{selection(end)} ''''];
eval(['contours_names = {',names_list,'};']);
[ref_image_name,type1] = Image_list(handles,'To which image do you want the contours header to correspond ?',1);
if (type1~=1&&type1~=3)
    disp('Wrong type of data!');
    return;
end
outname = 'rtstruct';
disp('Exporting contour(s) to pacs ... ')
try
    handles = Export_contour(contours_names,ref_image_name,outname,handles,[],{},'',{},'pacs');
catch
    % Display and log last error
    err = lasterror;
    msg{1} = 'Exporting contour(s) to pacs ... ';
    msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
    reggui_logger.error(msg,handles.log_filename);
    disp(' ')
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Remove_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Remove_image_Callback(hObject, eventdata, handles)
[selectedImages,OK] = listdlg('PromptString','Which image do you want to remove ?',...
    'SelectionMode','multiple',...
    'ListString',handles.images.name);
if OK==0
    disp('Wrong selection')
    return
end
for i=1:length(selectedImages)
    a = handles.images.name{selectedImages(i)};
    if(~strcmp(a,'none'))
        handles.instructions{length(handles.instructions)+1} = ['handles = Remove_image(''',a,''', handles);'];
    end
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_field_Callback(hObject, eventdata, handles)
[selectedFields,OK] = listdlg('PromptString','Which field do you want to remove ?',...
    'SelectionMode','multiple',...
    'ListString',handles.fields.name);
if OK==0
    disp('Wrong selection')
    return
end
for i=1:length(selectedFields)
    a = handles.fields.name{selectedFields(i)};
    if(~strcmp(a,'none'))
        handles.instructions{length(handles.instructions)+1} = ['handles = Remove_field(''',a,''', handles);'];
    end
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_data_Callback(hObject, eventdata, handles)
[selectedData,OK] = listdlg('PromptString','Which data do you want to remove ?',...
    'SelectionMode','multiple',...
    'ListString',handles.mydata.name);
if OK==0
    disp('Wrong selection')
    return
end
for i=1:length(selectedData)
    a = handles.mydata.name{selectedData(i)};
    if(~strcmp(a,'none'))
        handles.instructions{length(handles.instructions)+1} = ['handles = Remove_data(''',a,''', handles);'];
    end
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_plan_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Which plan do you want to remove ?',4);
if(type1==4)
    if(~strcmp(a,'none'))
        handles.instructions{length(handles.instructions)+1} = ['handles = Remove_plan(''',a,''', handles);'];
    end
    guidata(hObject, handles);
else
    disp('Removal aborted. You have to select a plan')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_indicators_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Which indicators do you want to remove ?',7);
if(type1==7)
    if(~strcmp(a,'none'))
        handles.instructions{length(handles.instructions)+1} = ['handles = Remove_indicators(''',a,''', handles);'];
    end
    guidata(hObject, handles);
else
    disp('Removal aborted. You have to select indicators')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_mesh_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Which mesh do you want to remove ?',5);
if(type1==5)
    if(~strcmp(a,'none'))
        handles.instructions{length(handles.instructions)+1} = ['handles = Remove_mesh(''',a,''', handles);'];
    end
    guidata(hObject, handles);
else
    disp('Removal aborted. You have to select a mesh')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_reg_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Which registration do you want to remove ?',6);
if(type1==6)
    if(~strcmp(a,'none'))
        handles.instructions{length(handles.instructions)+1} = ['handles = Remove_reg(''',a,''', handles);'];
    end
    guidata(hObject, handles);
else
    disp('Removal aborted. You have to select a registration')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Remove_all_images_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_images(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_fields_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_fields(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_data_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_data(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_plans_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_plans(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_meshes_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_meshes(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_indicators_Callback(hObject, eventdata, handles)
handles.indicators = struct('name',[],'data',[]);
handles.indicators.name{1} = 'none';
handles.indicators.data{1} = [];
handles.indicators.info{1} = [];
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_registrations_Callback(hObject, eventdata, handles)
handles.registrations = struct('name',[],'data',[]);
handles.registrations.name{1} = 'none';
handles.registrations.data{1} = [];
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_frames_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_frames(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function remove_all_dvhs_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_dvhs(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Remove_all_empty_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_empty(handles);';
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Clear_Callback(hObject, eventdata, handles)
handles.instructions{length(handles.instructions)+1} = 'handles = Remove_all_images(handles,1);';
guidata(hObject, handles);
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Render_Callback(hObject, eventdata, handles)
try
    use_renderer = 1;
    if(not(isempty(handles.rendering_frames)))
        Choice = questdlg([num2str(length(handles.rendering_frames)) ' sequences are available. What sequence would you like to render?'], ...
            '', ...
            'New sequence','Available sequence','Available sequence');
        if(strcmp(Choice,'Available sequence'))
            use_renderer = 0;
        end
    end
    if(use_renderer)
        [myInstruction,handles] = renderer(handles);
    else
        myInstruction = rendering_list(handles);
    end
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);



%% View Menu----------------------------------------------------------
% --------------------------------------------------------------------
function View_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Display_settings_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Set_scale_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Automatic_scale_Callback(hObject, eventdata, handles)
indices = unique([get(handles.image1,'Value'),get(handles.image2,'Value'),get(handles.image3,'Value'),get(handles.image4,'Value')]);
current_images = cell(0);
for i=1:length(indices)
    current_images{i} = handles.images.data{indices(i)};
end
[handles.minscale,handles.maxscale] = get_image_scale(current_images,handles.scale_prctile);
set(handles.edit_minscale,'String',num2str(handles.minscale));
set(handles.edit_maxscale,'String',num2str(handles.maxscale));
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function Manual_scale_Callback(hObject, eventdata, handles, values)
if(nargin>3 && handles.auto_mode)
    handles.minscale = values(1);
    handles.maxscale = values(2);
else
    handles.minscale = str2double(char(inputdlg('Set minimum scale intensity value')));
    handles.maxscale = str2double(char(inputdlg('Set maximum scale intensity value')));
end
set(handles.edit_minscale,'String',num2str(handles.minscale));
set(handles.edit_maxscale,'String',num2str(handles.maxscale));
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function Set_scale_F_Callback(hObject, eventdata, handles, values)
if(nargin>3 && handles.auto_mode)
    handles.minscaleF = values(1);
    handles.maxscaleF = values(2);
else
    handles.minscaleF = str2double(char(inputdlg('Set minimum scale intensity value for fusion')));
    handles.maxscaleF = str2double(char(inputdlg('Set maximum scale intensity value for fusion')));
end
set(handles.edit_minscaleF,'String',num2str(handles.minscaleF));
set(handles.edit_maxscaleF,'String',num2str(handles.maxscaleF));
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function Set_colormap_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Set_first_colormap_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function colormap_gray_Callback(hObject, eventdata, handles)
handles.colormap = gray(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_bone_Callback(hObject, eventdata, handles)
handles.colormap = bone(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_jet_Callback(hObject, eventdata, handles)
temp = jet(64);
temp(1,:) = [0,0,0];
handles.colormap = temp;
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_hot_Callback(hObject, eventdata, handles)
handles.colormap = hot(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_cool_Callback(hObject, eventdata, handles)
handles.colormap = cool(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_copper_Callback(hObject, eventdata, handles)
handles.colormap = copper(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_hsv_Callback(hObject, eventdata, handles)
handles.colormap = hsv(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_pink_Callback(hObject, eventdata, handles)
handles.colormap = pink(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function colormap_inverse_Callback(hObject, eventdata, handles)
handles.colormap = gray(64);
handles.colormap = handles.colormap(end:-1:1,:);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function Set_field_color_Callback(hObject, eventdata, handles)
try
    handles.field_color = uisetcolor(handles.field_color);
    guidata(hObject, handles);
    Update_regguiC_all_plots(handles);
catch
    handles.field_color = [1 0 0];
    guidata(hObject, handles);
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
% --------------------------------------------------------------------
function Set_second_colormap_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function second_colormap_gray_Callback(hObject, eventdata, handles)
handles.second_colormap = gray(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function second_colormap_hot_Callback(hObject, eventdata, handles)
handles.second_colormap = hot(64);
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function second_colormap_jet_Callback(hObject, eventdata, handles)
temp = jet(64);
temp(1,:) = 0;
handles.second_colormap = temp;
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function second_colormap_diff_Callback(hObject, eventdata, handles)
temp = jet(64);
temp(32:33,:) = 0;
handles.second_colormap = temp;
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function second_colormap_blue_Callback(hObject, eventdata, handles)
handles.second_colormap = [linspace(0,0.25,64)',linspace(0,0.15,64)',linspace(0,1,64)'];
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function Set_field_density_Callback(hObject, eventdata, handles)
factor = str2double(char(inputdlg('Set field density factor (>1)','Field density',1,{num2str(handles.fielddensity)})));
if(factor>=1)
    handles.fielddensity = round(factor);
else
    disp('Error : invalid field density factor. Please choose a number between [1 size(Field)]')
end
guidata(hObject, handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function Set_fusion_mode_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Fusion_mode_fusion_Callback(hObject, eventdata, handles)
handles.fusion_mode = 1;
set(handles.checkbox_difference,'Value',0);
guidata(hObject,handles);
Update_regguiC_all_plots(handles);
% --------------------------------------------------------------------
function Fusion_mode_difference_Callback(hObject, eventdata, handles)
handles.fusion_mode = 2;
set(handles.checkbox_difference,'Value',1);
guidata(hObject,handles);
Update_regguiC_all_plots(handles);

% --------------------------------------------------------------------
function Display_dvhs_Callback(hObject, eventdata, handles)
if(isempty(handles.dvhs) && not(handles.spatialpropsettled))

    Choice = questdlg(['There is no DVH to display.'], ...
        'Choose', ...
        'Import from file', 'Import data and compute','Cancel','Cancel');
    if(strcmp(Choice,'Cancel'))
        return
    elseif(strcmp(Choice,'Import from file'))
        [DVHs_Name, DVHs_Dir, filterindex] = uigetfile( ...
            {'*.mat','MATLAB Files (*.mat)'; ...
            '*.*',  'All Files (*.*)'}, ...
            'Pick a file', fullfile(handles.dataPath,'dvhs.mat'));
        DVHs_Name = fullfile(DVHs_Dir,DVHs_Name);
        if(not(isempty(DVHs_Name)))
            temp = load(DVHs_Name);
            handles.dvhs = temp.dvhs;
        end
    else
        handles.auto_mode = 1;
        [myContourFilename, myContourDir] = uigetfile( ...
            {'*.*','RTSTRUCT Files (*)'; ...
            '*.*',  'All Files (*.*)'}, ...
            'Select a RT-Struct file', [handles.dataPath '/Untitled']);

        % Import image
        myContourDir = myContourDir(1:end-1);
        [myImageDir,myImageFilename] = fileparts(myContourDir);
        try
            myImageName = myImageFilename;
            if(isempty(myImageName))
                return
            end
        catch
            Image_load = 0;
            disp('Error : not a valid image file !')
        end
        handles = Import_image(myImageDir, myImageFilename, 8, myImageName, handles);

        % Import contour
        try
            contours = read_dicomrtstruct(fullfile(myContourDir,myContourFilename),handles.images.info{end});
        catch
            disp('This is not a valid RTStruct file!')
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
            return
        end
        contoursAvailable = {contours.Struct.Name};
        [selectedContours,OK] = listdlg('PromptString','Select contour(s):',...
            'SelectionMode','multiple',...
            'ListString',contoursAvailable);
        if OK==0
            disp('Wrong selection')
            return
        end
        myImageName = strrep(myImageName,' ','_');
        handles = Import_contour(contours,selectedContours,myImageName,1,handles);
        list_of_selectedContours = cell(0);
        for c=1:length(selectedContours)
            list_of_selectedContours{c} = contoursAvailable{selectedContours(c)};
        end

        % Import dose map
        [myDoseFilename, myDoseDir, filterindex] = uigetfile( ...
            {'*.dcm;*.DCM;*.*','3D Dose files (*.dcm)'; ...
            '*.mat','MATLAB Files (*.mat)'; ...
            '*.img','Binary Files (*.img*)'}, ...
            'Select dose file', [handles.dataPath '/Untitled']);
        Dose_load = 1;
        if(filterindex==1)
            [~,~,extension] = fileparts(myDoseFilename);
            switch extension
                case {'.img'}
                    filterindex = 0;
                case {'.mat'}
                    filterindex = 3;
                otherwise
                    filterindex = 2;
            end
        elseif(filterindex==2)
            filterindex = 3;
        elseif(filterindex==3)
            filterindex = 0;
        end
        try
            default_name = cell(0);
            if(filterindex==1)
                [~,SerieName] = fileparts(myDoseDir(1:end-1));
                default_name{1} = SerieName;
            else
                default_name{1} = myDoseFilename(1:end-4);
            end
            myDoseName = char(inputdlg({'Choose a name for this dose map'},' ',1,default_name));
            if(isempty(myDoseName))
                Dose_load = 0;
                return
            end
        catch
            Dose_load = 0;
            disp('Error : not a valid file !')
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
            return
        end
        if(Dose_load)
            if(filterindex)
                handles = Import_image(myDoseDir, myDoseFilename, filterindex, myDoseName, handles);
            else
                handles = Resample_all(handles,[3/2;3/2;1],[256;256;0],[handles.spacing(1)*2;handles.spacing(2)*2;handles.spacing(3)]);
                handles = Empty_image(myDoseName,handles);
                fid=fopen(fullfile(myDoseDir,myDoseFilename));data=fread(fid,inf,'single');data=single(reshape(data,256,256,[]));handles.images.data{end}=data(:,:,end:-1:1);fclose(fid);
            end
            guidata(hObject, handles);
        end
        for c=1:length(list_of_selectedContours)
            disp([remove_bad_chars(myImageName),'_',remove_bad_chars(list_of_selectedContours{c})])
            handles = DVH_computation(handles,1,{myDoseName},{[remove_bad_chars(myImageName),'_',remove_bad_chars(list_of_selectedContours{c})]});
        end
        handles.auto_mode = 0;
        guidata(hObject, handles);
        Update_regguiC_all_plots(handles);
    end
end
if(isempty(handles.dvhs)) % no dvhs available
    [a,~] = Image_list(handles,'Select dose map',1,1);
    a_string = ['{''',a{1}];
    for i=2:length(a)
        a_string = [a_string,''',''',a{i}];
    end
    a_string = [a_string,'''}'];
    [b,~] = Image_list(handles,'Select volumes (binary images)',1,1);
    b_string = ['{''',b{1}];
    for i=2:length(b)
        b_string = [b_string,''',''',b{i}];
    end
    b_string = [b_string,'''}'];
    try
        myInstruction = ['handles = DVH_computation(handles,1,',a_string,',',b_string,');'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
    handles = executeall(handles);
    guidata(hObject, handles);
end
if(not(handles.reggui_mode))
    dose_volume_histograms(handles);
end

% --------------------------------------------------------------------
function History_Callback(hObject, eventdata, handles)
reggui_instruction_history(handles.instruction_history);

% --------------------------------------------------------------------
function Patient_file_Callback(hObject, eventdata, handles)
try
    handles = patient_file(handles);
catch
    disp('Patient file closed erroneously.')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    cd(handles.path)
end
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Properties_Callback(hObject, eventdata, handles)
try
    [m,handles] = reggui_properties(handles);
    handles.registrations = m.registrations;
    handles.indicators = m.indicators;
catch
    disp('Error occured while viewing/setting properties !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles = Update_regguiC_GUI(handles);
guidata(hObject, handles);


%% Data manipulation -------------------------------------------------
% --------------------------------------------------------------------
function Data_manip_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function List_of_Data_Callback(hObject, eventdata, handles)
try
    [~,~,~,instructions] = Image_list(handles,'List of data',1,1,1);
    for i=1:length(instructions)
        handles.instructions{length(handles.instructions)+1} = instructions{i};
    end
catch
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Create_empty_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Empty_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Empty_image_Callback(hObject, eventdata, handles)
name = inputdlg('Choose a name for empty image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Empty_image(''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Replicata_Callback(hObject, eventdata, handles)
[a,type] = Image_list(handles,'Select data to replicate',1);
name = inputdlg('Choose a name for Replicata');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Replicata(''' a ''',''' name{1} ''',',num2str(type),',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Empty_field_Callback(hObject, eventdata, handles)
name = inputdlg('Choose a name for empty field');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Empty_field(''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Empty_transform_Callback(hObject, eventdata, handles)
name = inputdlg('Choose a name for empty transform');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Empty_transform(''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Empty_data_Callback(hObject, eventdata, handles)
name = inputdlg('Choose a name for empty data');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Empty_data(''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Random_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Random_image_Callback(hObject, eventdata, handles)
scale = inputdlg('Set scale for smoothness');
name = inputdlg('Choose a name for random image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Random_image(''' name{1} ''',handles,' scale{1} ');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Random_field_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Fully_random_Callback(hObject, eventdata, handles)
scale = inputdlg('Set scale for smoothness');
name = inputdlg('Choose a name for random field');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Empty_field(''' name{1} ''',handles,' scale{1} ');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Radially_random_Callback(hObject, eventdata, handles)
scale = inputdlg('Set scale for smoothness');
sm = inputdlg('Set regularity for random function');
name = inputdlg('Choose a name for random field');
if(isempty(name))
    return
end
Org = inputdlg('Origin of the radial field','Origin',[1],{'[0 0 0]'});
try
    myInstruction = ['handles = Empty_field(''' name{1} ''',handles,' scale{1} ',1,',sm{1},',',Org{1},');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Fully_random_inside_Callback(hObject, eventdata, handles)
scale = inputdlg('Set scale for smoothness');
[image type] = Image_list(handles,'Inside which mask do you like to create this field?',1);
name = inputdlg('Choose a name for random field');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Empty_field(''' name{1} ''',handles,' scale{1} ',''' image ''');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Test_image_Callback(hObject, eventdata, handles)
scale = inputdlg('Set scales for frequencies','Frequencies in image',1,{'[1 0 1 0 1 0 1]'});
name = inputdlg('Choose a name for test image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Test_image(''' name{1} ''',handles,' scale{1} ');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Test_field_Callback(hObject, eventdata, handles)
scaleX = inputdlg('Set scales for X-frequencies','X-Frequencies in field',1,{'[1 0 1 0 1]'});
scaleY = inputdlg('Set scales for Y-frequencies','Y-Frequencies in field',1,{scaleX{1}});
scaleZ = inputdlg('Set scales for Z-frequencies','Z-Frequencies in field',1,{scaleY{1}});
name = inputdlg('Choose a name for test field');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Test_field(''' name{1} ''',handles,' scaleX{1} ',' scaleY{1} ',' scaleZ{1} ');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Create_plan_Callback(hObject, eventdata, handles)
try
    default_name = cell(0);
    default_name{1} = check_existing_names('plan',handles.plans.name);
    myPlanName = char(inputdlg({'Choose a name for this plan'},' ',1,default_name));
    if(isempty(myPlanName))
        return
    end
catch
    disp('Error : not a valid name !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
myBeamData = Create_PBS_plan([handles.view_point(1)*handles.spacing(1)+handles.origin(1),handles.view_point(2)*handles.spacing(2)+handles.origin(2),handles.view_point(3)*handles.spacing(3)+handles.origin(3)]);
myInfo.Type = 'pbs_plan';
disp('Adding plan to the list...')
myPlanName = check_existing_names(myPlanName,handles.plans.name);
handles.plans.name{length(handles.plans.name)+1} = myPlanName;
handles.plans.data{length(handles.plans.data)+1} = myBeamData;
handles.plans.info{length(handles.plans.info)+1} = myInfo;
guidata(handles.Import_plan, handles);
% --------------------------------------------------------------------
function Create_indicators_Callback(hObject, eventdata, handles)
try
    default_name = cell(0);
    default_name{1} = check_existing_names('indicators',handles.indicators.name);
    myIndicName = char(inputdlg({'Choose a name for these indicators'},' ',1,default_name));
    if(isempty(myIndicName))
        return
    end
catch
    disp('Error : not a valid name !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end
Indicators = Create_indicators(handles);
myInfo.Type = 'indicators';
disp('Adding indicators to the list...')
myIndicName = check_existing_names(myIndicName,handles.indicators.name);
handles.indicators.name{length(handles.indicators.name)+1} = myIndicName;
handles.indicators.data{length(handles.indicators.data)+1} = Indicators;
handles.indicators.info{length(handles.indicators.info)+1} = myInfo;
guidata(handles.Import_indicators, handles);
% --------------------------------------------------------------------
function Reference_point_Callback(hObject, eventdata, handles)
name = inputdlg('Choose a name for reference point');
if(isempty(name))
    return
end
[image type] = Image_list(handles,'On which image do you want to set this point?',1);
try
    myInstruction = ['handles = Reference_point(''' name{1} ''',''',image,''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function New_reg_Callback(hObject, eventdata, handles)
try
    [m handles] = registration_modules_params(handles);
    name = inputdlg('Choose a name for custom registration set of parameters');
    name = name{1};
    name = check_existing_names(name,handles.registrations.name);
    handles.registrations.name{length(handles.registrations.name)+1} = name;
    handles.registrations.data{length(handles.registrations.data)+1} = m;
    guidata(hObject, handles);
catch
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
% --------------------------------------------------------------------
function Transfer_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Data_to_image_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select data',3);
default_name = cell(0);
default_name{1} = [a '_wksp'];
myImageName = inputdlg({'Choose a name to store rescaled and croped data'},' ',1,default_name);
if(type1==3)
    try
        myInstruction = ['handles = Data2image(''' a ''',''' myImageName{1} ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error : you have to select 1 data !');
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Data_to_field_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select data',3);
default_name = cell(0);
default_name{1} = [a '_wksp'];
myFieldName = inputdlg({'Choose a name to store rescaled and croped data'},' ',1,default_name);
if(type1==3)
    try
        myInstruction = ['handles = Data2field(''' a ''',''' myFieldName{1} ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error : you have to select 1 data !');
end
handles = executeall(handles);
guidata(hObject, handles);
% -------------------------------------------------------------------
function Transform_to_field_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select transformation data (matrix)',2);
if(type1==2)
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},a))
            myInfo = handles.fields.info{i};
        end
    end
elseif(type1==3)
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},a))
            myInfo = handles.mydata.info{i};
        end
    end
else
    disp('Error : wrong type of data !');
    return
end
if(not(strcmp(myInfo.Type,'rigid_transform')))
    disp('Error : you have to select a transformation matrix !');
    return
end
default_name = cell(0);
default_name{1} = [a '_field'];
myFieldName = inputdlg({'Choose a name to store field'},' ',1,default_name);
if(type1==2 || type1==3)
    try
        myInstruction = ['handles = Transform2field(''' a ''',''' myFieldName{1} ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Copy_image_to_data_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select image',1);
if(not(type1==1))
    disp('Error : wrong type of data !');
    return
end
default_name = cell(0);
default_name{1} = [a '_data'];
myDataName = inputdlg({'Choose a name to store data'},' ',1,default_name);
try
    myInstruction = ['handles = Image2data(''' a ''',[],[],[],''' myDataName{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Copy_field_to_data_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select field',2);
if(not(type1==2))
    disp('Error : wrong type of data !');
    return
end
default_name = cell(0);
default_name{1} = [a '_data'];
myDataName = inputdlg({'Choose a name to store data'},' ',1,default_name);
try
    myInstruction = ['handles = Field2data(''' a ''',[],[],[],''' myDataName{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Image_to_data_Callback(hObject, eventdata, handles)
dataType = 'image';
try
    [myInstruction,handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Data_to_Data_Callback(hObject, eventdata, handles)
dataType = 'data';
try
    [myInstruction handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Field_to_data_Callback(hObject, eventdata, handles)
dataType = 'field';
try
    [myInstruction handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Fieldset_to_data_Callback(hObject, eventdata, handles)
dataType = 'fieldset';
try
    [myInstruction handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Mesh_to_mask_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select mesh',5);
if(not(type1==5))
    disp('Error : wrong type of data !');
    return
end
default_name = cell(0);
default_name{1} = [a '_mask'];
myDataName = inputdlg({'Choose a name to store mask'},' ',1,default_name);
try
    myInstruction = ['handles = Mesh2mask(''' a ''',''' myDataName{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Mask_to_mesh_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select image',1);
if(not(type1==1))
    disp('Error : wrong type of data !');
    return
end
default_name = cell(0);
default_name{1} = [a '_mask'];
myDataName = inputdlg({'Choose a name to store mesh'},' ',1,default_name);
try
    myInstruction = ['handles = Mask2mesh(''' a ''',''' myDataName{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Resample_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Resample_all_Callback(hObject, eventdata, handles)
dataType = 'all';
try
    [myInstruction,handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
handles = Apply_view_point(handles);
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Resample_all_button_Callback(hObject, eventdata, handles)
dataType = 'all';
try
    [myInstruction,handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
handles = Apply_view_point(handles);
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Resample_crop_Callback(hObject, eventdata, handles)
dataType = 'crop';
try
    [myInstruction,handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
handles = Apply_view_point(handles);
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Resample_grid_Callback(hObject, eventdata, handles)
dataType = 'grid';
try
    [myInstruction,handles] = resample_resize(handles,dataType);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
handles = Apply_view_point(handles);
Update_regguiC_all_plots(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Resample_beam_Callback(hObject, eventdata, handles)
% select plan
[a,type1] = Image_list(handles,'Select plan',4);
if(not(type1==4))
    disp('Error : wrong type of data ! Please select a treatment plan');
    return
end
% get plan
for i=1:length(handles.plans.name)
    if(strcmp(handles.plans.name{i},a))
        myBeamData = handles.plans.data{i};
    end
end
% select beam
beam_index = round(str2double(char(inputdlg(['Select beam (from 1 to ',num2str(length(myBeamData)),')'],'Beam index',1,{'1'}))));
if(beam_index<1 || beam_index>length(myBeamData))
    beam_index = 1;
end
% create instructions
myInstructions = cell(0);
try
    myInstruction = ['handles = Resample_beam(''',a,''',',num2str(beam_index),',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
% not reversible
selection = questdlg('This operation is not reversible. Only images in the workspace will be kept. Proceed?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        % apply instructions
        handles = executeall(handles);
        % set beam_mode and make import image invisible
        handles.beam_mode = 1;
        set(handles.Import,'Visible','off');
        set(handles.Resample_beam,'Visible','off');
    case 'No'
        return
end
handles = Apply_view_point(handles);
Update_regguiC_all_plots(handles);
guidata(hObject, handles);


%% Algorithms --------------------------------------------------------
% --------------------------------------------------------------------
function Algorithms_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Registrations_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Rigid_reg_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Registration_monomodal_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Registration_rigid_itkprog_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select fixed image',1);
[b,type2] = Image_list(handles,'Select moving image/data',1);
default_name = cell(0);
default_name{1} = [b,'_rigid_def'];
myImageName = inputdlg({'Choose a name to store deformed image'},' ',1,default_name);
default_name = cell(0);
default_name{1} = [b,'_rigid_trans'];
myFieldName = inputdlg({'Choose a name to store transformation'},' ',1,default_name);
if(type1==1 && (type2==1||type2==3))
    try
        myInstruction = ['handles = Registration_ITK_rigid(''' a ''',''' b ''',''' myImageName{1} ''',''' myFieldName{1} ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error ! Wrong type of data! (first has to be an image, and second either a data or an image)');
end
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Registration_affine_itkprog_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select fixed image',1);
[b,type2] = Image_list(handles,'Select moving image/data',1);
default_name = cell(0);
default_name{1} = [b,'_affine_def'];
myImageName = inputdlg({'Choose a name to store deformed image'},' ',1,default_name);
default_name = cell(0);
default_name{1} = [b,'_affine_trans'];
myFieldName = inputdlg({'Choose a name to store transformation'},' ',1,default_name);
if(type1==1 && (type2==1||type2==3))
    try
        myInstruction = ['handles = Registration_ITK_affine(''' a ''',''' b ''',''' myImageName{1} ''',''' myFieldName{1} ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error ! Wrong type of data! (first has to be an image, and second either a data or an image)');
end
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Registration_rigid_translation_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select fixed image',1);
[b,type2] = Image_list(handles,'Select moving image/data',1);
default_name = cell(0);
default_name{1} = [b,'_rigid_def'];
myImageName = inputdlg({'Choose a name to store deformed image'},' ',1,default_name);
default_name = cell(0);
default_name{1} = [b,'_rigid_trans'];
myFieldName = inputdlg({'Choose a name to store transformation'},' ',1,default_name);
if(type1==1 && (type2==1||type2==3))
    try
        myInstruction = ['handles = Registration_rigid(''' a ''',''' b ''',''' myImageName{1} ''',''' myFieldName{1} ''',',num2str(type2),',''ssd'',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error ! Wrong type of data! (first has to be an image, and second either a data or an image)');
end
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Registration_multimodal_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Registration_rigid_mm_itkprog_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select fixed image',1);
[b,type2] = Image_list(handles,'Select moving image/data',1);
default_name = cell(0);
default_name{1} = [b,'_rigid_def'];
myImageName = inputdlg({'Choose a name to store deformed image'},' ',1,default_name);
default_name = cell(0);
default_name{1} = [b,'_rigid_trans'];
myFieldName = inputdlg({'Choose a name to store transformation'},' ',1,default_name);
if(type1==1 && (type2==1||type2==3))
    try
        myInstruction = ['handles = Registration_ITK_rigid_multimodal(''' a ''',''' b ''',''' myImageName{1} ''',''' myFieldName{1} ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error ! Wrong type of data! (first has to be an image, and second either a data or an image)');
end
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Manual_rigid_translation_Callback(hObject, eventdata, handles)
try
    [image1 type1] = Image_list(handles,'Select fixed image/data',1);
    [image2 type2] = Image_list(handles,'Select moving image/data',1);
    default_name = cell(0);
    default_name{1} = [image2,'_rigid_def'];
    myImageName = inputdlg({'Choose a name to store deformed image'},' ',1,default_name);
    default_name = cell(0);
    default_name{1} = [image2,'_to_',image2,'_rigid_trans'];
    myFieldName = inputdlg({'Choose a name to store transformation'},' ',1,default_name);
    if(type1==1)
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},image1))
                myImage = handles.images.data{i};
                myInfo = handles.images.info{i};
            end
        end
    else
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},image1))
                myImage = handles.mydata.data{i};
                myInfo = handles.mydata.info{i};
            end
        end
    end
    pt1 = image_viewer(myImage,myInfo);
    eval(['pt1 = ',pt1,' .* myInfo.Spacing'' + myInfo.ImagePositionPatient'' ;']);
    pt1 = ['[',num2str(pt1),']'];
    if(type2==1)
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},image2))
                myImage = handles.images.data{i};
                myInfo = handles.images.info{i};
            end
        end
    else
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},image2))
                myImage = handles.mydata.data{i};
                myInfo = handles.mydata.info{i};
            end
        end
    end
    pt2 = image_viewer(myImage,myInfo);
    eval(['pt2 = ',pt2,' .* myInfo.Spacing'' + myInfo.ImagePositionPatient'' ;']);
    pt2 = ['[',num2str(pt2),']'];
catch
    disp('Aborted.')
    return
end
if(type2==1||type2==3)
    try
        myInstruction = ['handles = Manual_translation(''' image2 ''',' pt1 ',' pt2 ',''' myImageName{1} ''',''' myFieldName{1} ''',' num2str(type2) ',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
        return
    end
else
    disp('Error !');
    return
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Non_rigid_reg_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Registration_Callback(hObject, eventdata, handles)
try
    [myInstruction handles] = registration_params(handles.images.name,handles);
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Registration_modules_Callback(hObject, eventdata, handles)
Create_new_registration = 1;
if(length(handles.registrations.data)>1)
    Choice = questdlg('Would you like to create a new registration? (if ''No'', you will select a registration in the list)', ...
        'Choose', ...
        'Yes', 'No','No');
    if(strcmp(Choice,'No'))
        Create_new_registration = 0;
    end
end
try
    if(Create_new_registration)
        [myRegistration handles] = registration_modules_params(handles);
        if(not(isempty(myRegistration)))
            Choice = questdlg('Would you like to save this registration in the list (for further modifications)?', ...
                'Choose', ...
                'Yes', 'No','No');
            if(strcmp(Choice,'Yes'))
                name = cell(0);
                name{1} = 'custom_registration';
                name = inputdlg({'Choose a name to store registration'},' ',1,name);
                name = check_existing_names(name{1},handles.registrations.name);
                handles.registrations.name{length(handles.registrations.name)+1} = name;
                handles.registrations.data{length(handles.registrations.data)+1} = myRegistration;
            end
        end
    else
        [a,type1] = Image_list(handles,'Which registration do you want to use ?',6);
        index = 0;
        if(type1==6 && ~strcmp(a,'none'))
            for i=1:length(handles.registrations.name)
                if(strcmp(handles.registrations.name{i},a))
                    if(index~=0)
                        disp('Warning : multiple registrations with the same name. Using the last of them !');
                    end
                    index = i;
                end
            end
            myRegistration = handles.registrations.data{index};
        else
            disp('Aborted. You have to select a valid registration');
            return
        end
    end
    if(isempty(myRegistration))
        myInstruction = 'no_instruction()';
    else
        def_image_name = [myRegistration.moving{1},'_def'];
        if(isfield(myRegistration,'logdomain'))
            switch myRegistration.num_of_processes
                case 1
                    myInstruction = ['handles = Registration_modules(',num2str(myRegistration.num_of_processes),',{''',myRegistration.fixed{1},'''},{''',myRegistration.moving{1},'''},''',myRegistration.discontinuity_mask,''',',num2str(myRegistration.num_of_scales),',[',num2str(myRegistration.iterations),'],{',num2str(myRegistration.reg{1}),'},{',num2str(myRegistration.preregul{1}),'},{[',num2str(myRegistration.pre_var{1}),']},{',num2str(2*myRegistration.merging{1}),'},',num2str(myRegistration.fluidregul),',[',num2str(myRegistration.fluid_var),'],',num2str(myRegistration.accumulation),',',num2str(myRegistration.solidregul),',[',num2str(myRegistration.solid_var),'],''',def_image_name,''',''',myRegistration.def_field_name,''',''',myRegistration.report_name,''',',num2str(myRegistration.visual),',handles,',num2str(myRegistration.logdomain),');'];
                case 2
                    myInstruction = ['handles = Registration_modules(',num2str(myRegistration.num_of_processes),',{''',myRegistration.fixed{1},''',''',myRegistration.fixed{2},'''},{''',myRegistration.moving{1},''',''',myRegistration.moving{2},'''},''',myRegistration.discontinuity_mask,''',',num2str(myRegistration.num_of_scales),',[',num2str(myRegistration.iterations),'],{',num2str(myRegistration.reg{1}),',',num2str(myRegistration.reg{2}),'},{',num2str(myRegistration.preregul{1}),',',num2str(myRegistration.preregul{2}),'},{[',num2str(myRegistration.pre_var{1}),'],[',num2str(myRegistration.pre_var{2}),']},{',num2str(2*myRegistration.merging{1}),',',num2str(2*myRegistration.merging{2}),'},',num2str(myRegistration.fluidregul),',[',num2str(myRegistration.fluid_var),'],',num2str(myRegistration.accumulation),',',num2str(myRegistration.solidregul),',[',num2str(myRegistration.solid_var),'],''',def_image_name,''',''',myRegistration.def_field_name,''',''',myRegistration.report_name,''',',num2str(myRegistration.visual),',handles,',num2str(myRegistration.logdomain),');'];
                case 3
                    myInstruction = ['handles = Registration_modules(',num2str(myRegistration.num_of_processes),',{''',myRegistration.fixed{1},''',''',myRegistration.fixed{2},''',''',myRegistration.fixed{3},'''},{''',myRegistration.moving{1},''',''',myRegistration.moving{2},''',''',myRegistration.moving{3},'''},''',myRegistration.discontinuity_mask,''',',num2str(myRegistration.num_of_scales),',[',num2str(myRegistration.iterations),'],{',num2str(myRegistration.reg{1}),',',num2str(myRegistration.reg{2}),',',num2str(myRegistration.reg{3}),'},{',num2str(myRegistration.preregul{1}),',',num2str(myRegistration.preregul{2}),',',num2str(myRegistration.preregul{3}),'},{[',num2str(myRegistration.pre_var{1}),'],[',num2str(myRegistration.pre_var{2}),'],[',num2str(myRegistration.pre_var{3}),']},{',num2str(2*myRegistration.merging{1}),',',num2str(2*myRegistration.merging{2}),',',num2str(2*myRegistration.merging{3}),'},',num2str(myRegistration.fluidregul),',[',num2str(myRegistration.fluid_var),'],',num2str(myRegistration.accumulation),',',num2str(myRegistration.solidregul),',[',num2str(myRegistration.solid_var),'],''',def_image_name,''',''',myRegistration.def_field_name,''',''',myRegistration.report_name,''',',num2str(myRegistration.visual),',handles,',num2str(myRegistration.logdomain),');'];
            end
        else
            switch myRegistration.num_of_processes
                case 1
                    myInstruction = ['handles = Registration_modules(',num2str(myRegistration.num_of_processes),',{''',myRegistration.fixed{1},'''},{''',myRegistration.moving{1},'''},''',myRegistration.discontinuity_mask,''',',num2str(myRegistration.num_of_scales),',[',num2str(myRegistration.iterations),'],{',num2str(myRegistration.reg{1}),'},{',num2str(myRegistration.preregul{1}),'},{[',num2str(myRegistration.pre_var{1}),']},{',num2str(2*myRegistration.merging{1}),'},',num2str(myRegistration.fluidregul),',[',num2str(myRegistration.fluid_var),'],',num2str(myRegistration.accumulation),',',num2str(myRegistration.solidregul),',[',num2str(myRegistration.solid_var),'],''',def_image_name,''',''',myRegistration.def_field_name,''',''',myRegistration.report_name,''',',num2str(myRegistration.visual),',handles);'];
                case 2
                    myInstruction = ['handles = Registration_modules(',num2str(myRegistration.num_of_processes),',{''',myRegistration.fixed{1},''',''',myRegistration.fixed{2},'''},{''',myRegistration.moving{1},''',''',myRegistration.moving{2},'''},''',myRegistration.discontinuity_mask,''',',num2str(myRegistration.num_of_scales),',[',num2str(myRegistration.iterations),'],{',num2str(myRegistration.reg{1}),',',num2str(myRegistration.reg{2}),'},{',num2str(myRegistration.preregul{1}),',',num2str(myRegistration.preregul{2}),'},{[',num2str(myRegistration.pre_var{1}),'],[',num2str(myRegistration.pre_var{2}),']},{',num2str(2*myRegistration.merging{1}),',',num2str(2*myRegistration.merging{2}),'},',num2str(myRegistration.fluidregul),',[',num2str(myRegistration.fluid_var),'],',num2str(myRegistration.accumulation),',',num2str(myRegistration.solidregul),',[',num2str(myRegistration.solid_var),'],''',def_image_name,''',''',myRegistration.def_field_name,''',''',myRegistration.report_name,''',',num2str(myRegistration.visual),',handles);'];
                case 3
                    myInstruction = ['handles = Registration_modules(',num2str(myRegistration.num_of_processes),',{''',myRegistration.fixed{1},''',''',myRegistration.fixed{2},''',''',myRegistration.fixed{3},'''},{''',myRegistration.moving{1},''',''',myRegistration.moving{2},''',''',myRegistration.moving{3},'''},''',myRegistration.discontinuity_mask,''',',num2str(myRegistration.num_of_scales),',[',num2str(myRegistration.iterations),'],{',num2str(myRegistration.reg{1}),',',num2str(myRegistration.reg{2}),',',num2str(myRegistration.reg{3}),'},{',num2str(myRegistration.preregul{1}),',',num2str(myRegistration.preregul{2}),',',num2str(myRegistration.preregul{3}),'},{[',num2str(myRegistration.pre_var{1}),'],[',num2str(myRegistration.pre_var{2}),'],[',num2str(myRegistration.pre_var{3}),']},{',num2str(2*myRegistration.merging{1}),',',num2str(2*myRegistration.merging{2}),',',num2str(2*myRegistration.merging{3}),'},',num2str(myRegistration.fluidregul),',[',num2str(myRegistration.fluid_var),'],',num2str(myRegistration.accumulation),',',num2str(myRegistration.solidregul),',[',num2str(myRegistration.solid_var),'],''',def_image_name,''',''',myRegistration.def_field_name,''',''',myRegistration.report_name,''',',num2str(myRegistration.visual),',handles);'];
            end
        end
    end
catch
    myInstruction = 'no_instruction()';
    %     err = lasterror;
    %     disp(['    ',err.message]);
    %     disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Registration_bspline_itkprog_Callback(hObject, eventdata, handles)
try
    [myInstruction handles] = registration_params(handles.images.name,handles,'parametric');
catch
    myInstruction = 'no_instruction()';
    disp('Unexpected closure')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
handles.instructions{length(handles.instructions)+1} = myInstruction;
handles = executeall(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Deformation_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select image to deform',1);
[b,type2] = Image_list(handles,'Select deformation field',2);
default_name = cell(0);
default_name{1} = [a '_def'];
myImageName = inputdlg({'Choose a name to store deformed image'},' ',1,default_name);
try
    myImageName = check_existing_names(myImageName{1},handles.images.name);
catch
    disp('Error. Aborted.')
    return
end
if(type1==1 && type2==2)
    try
        myInstruction = ['handles = Deformation(''' a ''',''' b ''',''' myImageName ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
elseif(type1==3)
    try
        myInstruction = ['handles = Data_deformation(''' a ''',''' b ''',''' myImageName ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error : you have to select 1 image and 1 field !');
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Composition_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first field (field to be deformed)',2);
[b,type2] = Image_list(handles,'Select second field (update)',2);
default_name = cell(0);
default_name{1} = [a '_def'];
myImageName = inputdlg({'Choose a name to store deformed image'},' ',1,default_name);
try
    myImageName = check_existing_names(myImageName{1},handles.images.name);
catch
    disp('Error. Aborted.')
    return
end
if(type1==2 && type2==2)
    try
        myInstruction = ['handles = Composition(''' a ''',''' b ''',''' myImageName ''',handles);'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    catch
        disp('Invalid command')
    end
else
    disp('Error : you have to select 2 fields !');
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Segmentation_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function ManualSegmentation_Callback(hObject, eventdata, handles)
[image,b] = filters_list(handles.images.name,'Manual segmentation','','');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
handles = ManualSegmentation(handles,image,name{1},b);
Update_regguiC_all_plots(handles);
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function ManualThreshold_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Threshold segmentation','[ min max ]','[0 1]');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = ManualThreshold(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function AutoThreshold_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Threshold segmentation','[ number of histograms ]','[128]');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = AutoThreshold(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Watershed_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Watershed segmentation','[ level , threshold , seed ]','[0.4  0.2  0]');
eval(['params = ',b,';']);
if(length(params)<3)
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},a))
            myImage = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},a))
            myImage = handles.images.data{i};
            myInfo = handles.images.info{i};
        end
    end
    eval(['pt = ',image_viewer(myImage,myInfo),';']);
    b = [params(1),params(2),pt(1),pt(2),pt(3)];
    b = ['[',num2str(b),']'];
end
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Watersheds(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function FastMarching_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Fast marching segmentation','[ seed, stopping time ]',['[',num2str(handles.view_point(1)),' ',num2str(handles.view_point(2)),' ',num2str(handles.view_point(3)),' 10]']);
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = FastMarching(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function RegionGrowing_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Region Growing segmentation','[ seed, tolerance ]',['[',num2str(handles.view_point(1)),' ',num2str(handles.view_point(2)),' ',num2str(handles.view_point(3)),' 0]']);
if(length(b)<4)
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},a))
            myImage = handles.mydata.data{i};
            myInfo = handles.mydata.info{i};
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},a))
            myImage = handles.images.data{i};
            myInfo = handles.images.info{i};
        end
    end
    eval(['pt = ',image_viewer(myImage,myInfo),';']);
    eval(['b = ',b,';']);
    b = [pt(1),pt(2),pt(3),b(1)];
    b = ['[',num2str(b),']'];
end
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = RegionGrowing(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function CT_specific_seg_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function BodySegmentation_Callback(hObject, eventdata, handles)
[a,~] = filters_list(handles.images.name,'Body segmentation','','');
name = inputdlg('Choose a name for body segmentation mask','Choose name',1,{'body'});
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Body_segmentation(''' a ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function LungSegmentation_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select CT image',1);
[b] = Image_list(handles,'Select body mask',type1);
name = inputdlg('Choose a name for lung segmentation mask','Choose name',1,{'lungs'});
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Lung_segmentation(''',a,''',''',b,''',{},''',name{1},''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function ROI_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function ROI_box_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Region of Interest definition','[ shape, size ]','{''box''}');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = ROI(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function ROI_shapes_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Region of Interest definition','[ shape, size ]','{''sphere'',''2''}');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = ROI(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Filters_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Gaussian_Smoothing_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Gaussian smoothing filter','std [in mm]','2');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Gaussian_Smoothing(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Curvature_Smoothing_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Curvature smoothing filter','[ number of iterations , timestep , conductance ]','[10 0.0625 3.0]');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Curvature_Smoothing(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Median_smoothing_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Median smoothing filter','[ sizeX sizeY sizeZ ] in voxels','[3 3 3]');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Median_Smoothing(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Gradient_Magnitude_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Gradient magnitude filter','- no params -','[ ]');
name = inputdlg('Choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Gradient_Magnitude(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Deblurring_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Deconvolution','[ PSF size ] in voxels','[3 3 3]');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Deblurring(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Derivative_first_order_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'First order derivative','[]','[]');
name = inputdlg('choose a name for resulting vector field');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Derivative_first_order(''' a ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Derivative_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Partial derivative','[ order , direction ]','[1 1]');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Derivative(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Image_histeq_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Image_histeq_ct_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'CT histogram equalization','Contrast enhancement (choose between 0 and 100)','25');
name = inputdlg('Choose a name for equalized image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Image_histeq(''' a ''',''' name{1} ''',''ct'',' b ',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Field_filters_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Jacobian_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.fields.name,'Jacobian','','');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Jacobian(''' a ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Harmonic_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.fields.name,'Jacobian','','');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Harmonic(''' a ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Field_norm_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.fields.name,'Norm computation','','');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Field_norm(''' a ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Field_gaussian_smoothing_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.fields.name,'Gaussian smoothing filter','std','2');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Field_gaussian_smoothing(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function diffeomorphism_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.fields.name,'Exponentiation filter','','');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Field_exponential(''' a ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Morphology_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Erosion_Callback(hObject, eventdata, handles)

[a,b] = filters_list(handles.images.name,'Erosion','kernel size (mm)','[2 2 2]');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Erosion(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Dilation_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Dilation','kernel size (mm)','[2 2 2]');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Dilation(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Opening_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Opening','kernel size (mm)','[2 2 2]');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Opening(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Closure_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Closure','kernel size (mm)','[2 2 2]');
name = inputdlg('choose a name for resulting image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Closure(''' a ''',' b ',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Mask2DistMap_Callback(hObject, eventdata, handles)
[a] = Image_list(handles,'Select mask image',1);
name = inputdlg('choose a name for resulting distance map');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Mask2DistMap(''' a ''',''' name{1} ''',0,handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Basic_operations_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Im_Addition_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first image',1);
[b] = Image_list(handles,'Select second image',type1);
name = inputdlg('Choose a name for sum image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Addition({''' a ''',''' b '''},''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Im_Difference_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first image',1);
[b] = Image_list(handles,'Select second image',type1);
name = inputdlg('Choose a name for difference image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Difference(''' a ''',''' b ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Im_Multiplication_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first image',1);
[b] = Image_list(handles,'Select second image',type1);
name = inputdlg('Choose a name for difference image');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Multiplication(''' a ''',''' b ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Im_Averaging_Callback(hObject, eventdata, handles)
[names,type] = Image_list(handles,'Select images to be averaged',1,1);
name = inputdlg('Choose a name for the resulting image');
if(isempty(name))
    return
end
names_string = names{1};
for i=2:length(names)
    names_string = [names_string,''',''',names{i}];
end
try
    myInstruction = ['handles = Average_image({''',names_string,'''},''',name{1}, ''',handles,',num2str(type),');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Im_Median_Callback(hObject, eventdata, handles)
[names,type] = Image_list(handles,'Select images for median computation',1,1);
name = inputdlg('Choose a name for the resulting image');
if(isempty(name))
    return
end
names_string = names{1};
for i=2:length(names)
    names_string = [names_string,''',''',names{i}];
end
try
    myInstruction = ['handles = Median_image({''',names_string,'''},''',name{1}, ''',handles,',num2str(type),');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Im_MidP_Callback(hObject, eventdata, handles)
[names,type] = Image_list(handles,'Select images for MidP computation',1,1);
[body,type] = Image_list(handles,'Select body contour',1,1);
name = inputdlg('Choose a name for the resulting image');
if(isempty(name))
    return
end
names_string = names{1};
for i=2:length(names)
    names_string = [names_string,''',''',names{i}];
end
try
    myInstruction = ['handles = MidP_image({''',names_string,'''},''',name{1}, ''',handles,''',body{1},''');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Im_Overwrite_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select image',1);
[b,~] = Image_list(handles,'Select mask',type1);
new_intensity = inputdlg('New intensity','Set new intensity',1,{'0'});
name = inputdlg('Choose a name for overwritten image','Set output name',1,{[a,'_overwrite']});
if(isempty(name))
    return
else
    name = check_existing_names(name{1},handles.images.name);
end
try
    myInstruction = ['handles = Replicata(''',a,''',''',name,''',',num2str(type1),',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
    myInstruction = ['',name,' ( ',b,' >=max( ',b,' (:)/2)) = ',new_intensity{1},';'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Metrics_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Metrics_image_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function SSD_metric_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first image',1);
[b,type2] = Image_list(handles,'Select second image',type1);
try
    myInstruction = ['SSD(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function CC_metric_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first image',1);
[b,type2] = Image_list(handles,'Select second image',type1);
try
    myInstruction = ['Cross_correlation(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Mutual_info_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first image',1);
[b,type2] = Image_list(handles,'Select second image',type1);
try
    myInstruction = ['Mutual_info(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Metrics_field_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Mean_norm_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first field',2);
[b,type2] = Image_list(handles,'Select second field',type1);
try
    myInstruction = ['Mean_norm_metric(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function RMS_metric_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first field',2);
[b,type2] = Image_list(handles,'Select second field',type1);
try
    myInstruction = ['RMS_metric(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Median_deviation_metric_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first field',2);
[b,type2] = Image_list(handles,'Select second field',type1);
try
    myInstruction = ['Median_deviation_metric(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Maximum_deviation_metric_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first field',2);
[b,type2] = Image_list(handles,'Select second field',type1);
try
    myInstruction = ['Maximum_deviation_metric(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Volume_computation_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select volume image',1);
try
    myInstruction = ['Volume_computation(''' a ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function DICE_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select first image',1);
[b,type2] = Image_list(handles,'Select second image',type1);
try
    myInstruction = ['DICE(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function staple_Callback(hObject, eventdata, handles)
[names,type] = Image_list(handles,'Select segmentations for staple analysis',1,1);
name = inputdlg('Choose a name for the resulting segmentation');
if(isempty(name))
    return
end
name_list = '{';
for i=1:length(names)
    name_list = [name_list,'''',names{i},''','];
end
name_list = [name_list(1:end-1),'}'];
try
    myInstruction = ['handles = Staple(',name_list,',''',name{1}, ''',handles,',num2str(type),');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Contour_distance_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select ''gold'' mask',1);
[b,type2] = Image_list(handles,'Select second mask',type1);
try
    myInstruction = ['Contour_distance(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function WE_contour_distance_Callback(hObject, eventdata, handles)
isocenter = (handles.view_point-1).*handles.spacing+handles.origin;
[a,b] = filters_list(handles.images.name,'WE distance between contours. Select CT image.','{model,sad,[isocenter],gantry angle,table angle}',['{''reggui_material_default.txt'',2270,[',num2str(isocenter(1)),';',num2str(isocenter(2)),';',num2str(isocenter(3)),']}']);
[mask1,type1] = Image_list(handles,'Select first mask',1);
[mask2,~] = Image_list(handles,'Select second mask',type1);
if(not(handles.beam_mode))
    eval(['params = ',b,';']);
    if(length(params)<5)
        % select plan
        [p,type1] = Image_list(handles,'Select plan',4);
        if(not(type1==4))
            disp('Error : wrong type of data ! Please select a treatment plan');
            return
        end
        % select beam
        for i=1:length(handles.plans.name)
            if(strcmp(handles.plans.name{i},p))
                myBeamData = handles.plans.data{i};
            end
        end
        beam_index = round(str2double(char(inputdlg(['Select beam (from 1 to ',num2str(length(myBeamData)),')'],'Beam index',1,{'1'}))));
        if(beam_index<1 || beam_index>length(myBeamData))
            beam_index = 1;
        end
        if(isnumeric(params{1}) && size(params{1})>1)
            m = '[';
            for i=1:size(params{1},1)
                for j=1:size(params{1},2)
                    m = [m,num2str(params{1}(i,j)),','];
                end
                m = [m(1:end-1),';'];
            end
            m = [m(1:end-1),']'];
        elseif(isnumeric(params{1}))
            m = num2str(params{1});
        else
            m = ['''',params{1},''''];
        end
        b = ['{',m,',',num2str(params{2}),',''',p,''',',num2str(beam_index),'}'];
    end
end
% select body
body = Image_list(handles,'Select body contour',1,1);
% compute WE distances
myInstruction = ['WE_contour_distance(''',a,''',''',mask1,''',''',mask2,''',',b,',handles,''',body{1},''');'];
try
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function CenterOfMass_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select volume',1);
try
    myInstruction = ['[CoM CoM_rs handles] = CenterOfMass(''' a ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
set(handles.Joint_slider,'Value',1);
guidata(hObject, handles);
Joint_slider_Callback(handles.Joint_slider, [], handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function WeightedCenterOfMass_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select volume',1);
try
    myInstruction = ['[CoM CoM_rs handles] = WeightedCenterOfMass(''' a ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
set(handles.Joint_slider,'Value',1);
guidata(hObject, handles);
Joint_slider_Callback(handles.Joint_slider, [], handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function volume_histogram_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select image for distribution computation',1);
[b,type2] = Image_list(handles,'Select volume (segmentation) image',1);
try
    myInstruction = ['Volume_histogram(''' a ''',''' b ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function dose_volume_histogram_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select dose map',1,1);
a_string = ['{''',a{1}];
for i=2:length(a)
    a_string = [a_string,''',''',a{i}];
end
a_string = [a_string,'''}'];
[b,type2] = Image_list(handles,'Select volumes (binary images)',1,1);
b_string = ['{''',b{1}];
for i=2:length(b)
    b_string = [b_string,''',''',b{i}];
end
b_string = [b_string,'''}'];
try
    myInstruction = ['handles = DVH_computation(handles,1,',a_string,',',b_string,');'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Gamma_index_Callback(hObject, eventdata, handles)
[a,type1] = Image_list(handles,'Select reference dose map',1);
[b,type2] = Image_list(handles,'Select dose map for comparison',1);
[c,type3] = Image_list(handles,'Select volume (segmentation) image(s)',1,1);
params = inputdlg('Enter dd[mm], DD[Gy], FI[0-10], global[0/1], threshold[%]','Gamma index parameters',1,{'[3,3,5,1,10]'});
name = inputdlg('Choose a name for output Gamma index image');
if(isempty(name))
    return
end
try
    if(type1==type3)
        myInstruction = ['handles = Gamma_index(''' a ''',''' b ''',' cell2str(c) ',''' name{1} ''',handles,',params{1},');'];
        handles.instructions{length(handles.instructions)+1} = myInstruction;
    else
        disp('Reference dose map and volume must be of the same type (image or data)');
    end
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Dicom_rescaling_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Rescaling based on dicom','','[]');
try
    if(isempty(b))
        myInstruction = ['handles = Intensity_rescaling(''' a ''',handles);'];
    else
        myInstruction = ['handles = Intensity_rescaling(''' a ''',handles,' b ');'];
    end
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Compare_plans_Callback(hObject, eventdata, handles)
a = Image_list(handles,'Select reference plan',4);
b = Image_list(handles,'Select new plan',4);
try
    myInstruction = ['Compare_plans(''',b,''',''',a,''',handles,1);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function margins_Callback(hObject, eventdata, handles)
margin_recipe(handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Inverse_transform_Callback(hObject, eventdata, handles)
a = filters_list(handles.fields.name,'Inverse rigid transform','','');
name = inputdlg('choose a name for resulting transform');
if(isempty(name))
    return
end
try
    myInstruction = ['handles = Inverse_transform(''' a ''',''' name{1} ''',handles);'];
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Stopping_power_conversion_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'Stopping power filter','{model}',['{''reggui_material_default.txt''}']);
name = inputdlg('Choose a name for resulting image','Choose name',1,{[a,'_sp']});
if(isempty(name))
    return
end
myInstruction = ['handles = StoppingPower_computation(''',a,''',',b,',''',name{1},''',handles);'];
try
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function WEPL_Callback(hObject, eventdata, handles)
isocenter = (handles.view_point-1).*handles.spacing+handles.origin;
[a,b] = filters_list(handles.images.name,'WEPL filter','{model,sad,[isocenter],gantry angle,table angle}',['{''reggui_material_default.txt'',2270,[',num2str(isocenter(1)),';',num2str(isocenter(2)),';',num2str(isocenter(3)),']}']);
name = inputdlg('Choose a name for resulting image','Choose name',1,{[a,'_wepl']});
if(isempty(name))
    return
end
if(handles.beam_mode)
    myInstruction = ['handles = WEPL_computation(''',a,''',',b,',''',name{1},''',handles);'];
else
    eval(['params = ',b,';']);
    if(length(params)<5)
        % select plan
        [p,type1] = Image_list(handles,'Select plan',4);
        if(not(type1==4))
            disp('Error : wrong type of data ! Please select a treatment plan');
            return
        end
        % select beam
        for i=1:length(handles.plans.name)
            if(strcmp(handles.plans.name{i},p))
                myBeamData = handles.plans.data{i};
            end
        end
        beam_index = round(str2double(char(inputdlg(['Select beam (from 1 to ',num2str(length(myBeamData)),')'],'Beam index',1,{'1'}))));
        if(beam_index<1 || beam_index>length(myBeamData))
            beam_index = 1;
        end
        if(isnumeric(params{1}) && size(params{1},1)>1)
            m = '[';
            for i=1:size(params{1},1)
                for j=1:size(params{1},2)
                    m = [m,num2str(params{1}(i,j)),','];
                end
                m = [m(1:end-1),';'];
            end
            m = [m(1:end-1),']'];
        elseif(isnumeric(params{1}))
            m = num2str(params{1});
        else
            m = ['''',params{1},''''];
        end
        b = ['{',m,',',num2str(params{2}),',''',p,''',',num2str(beam_index),'}'];
    end
    % compute WEPL
    if(length(params)<2 && (table_angle==0 || table_angle==90 || table_angle==180 || table_angle==270) && (gantry_angle==0 || gantry_angle==90 || gantry_angle==180 || gantry_angle==270))
        myInstruction = ['handles = WEPL_computation(''',a,''',',b,',''',name{1},''',handles);'];
    else
        roi = Image_list(handles,'Select region of interest',1,1);
        myInstruction = ['handles = WEPL_computation(''',a,''',',b,',''',name{1},''',handles,''',roi{1},''');'];
    end
end
try
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function WEPL_based_warping_Callback(hObject, eventdata, handles)
[a,b] = filters_list(handles.images.name,'WEPL-based dose warping - select dose map','{model,sad,plan_name,beam_index}',['{''reggui_material_default.txt'',2270}']);
c = Image_list(handles,'Select reference CT image',1);
d = Image_list(handles,'Select new CT image',1);
name = inputdlg('Choose a name for resulting dose map','Choose name',1,{[a,'_warped']});
if(isempty(name))
    return
end
if(not(handles.beam_mode))
    eval(['params = ',b,';']);
    if(length(params)<4)
        % select plan
        [p,type1] = Image_list(handles,'Select plan',4);
        if(not(type1==4))
            disp('Error : wrong type of data ! Please select a treatment plan');
            return
        end
        % select beam
        for i=1:length(handles.plans.name)
            if(strcmp(handles.plans.name{i},p))
                myBeamData = handles.plans.data{i};
            end
        end
        beam_index = round(str2double(char(inputdlg(['Select beam (from 1 to ',num2str(length(myBeamData)),')'],'Beam index',1,{'1'}))));
        if(beam_index<1 || beam_index>length(myBeamData))
            beam_index = 1;
        end
        if(isnumeric(params{1}) && size(params{1})>1)
            m = '[';
            for i=1:size(params{1},1)
                for j=1:size(params{1},2)
                    m = [m,num2str(params{1}(i,j)),','];
                end
                m = [m(1:end-1),';'];
            end
            m = [m(1:end-1),']'];
        elseif(isnumeric(params{1}))
            m = num2str(params{1});
        else
            m = ['''',params{1},''''];
        end
        b = ['{',m,',',num2str(params{2}),',''',p,''',',num2str(beam_index),'}'];
    end
end
myInstruction = ['handles = WEPL_based_warping(''',a,''',''',c,''',''',d,''',',b,',''',name{1},''',handles);'];
try
    handles.instructions{length(handles.instructions)+1} = myInstruction;
catch
    disp('Invalid command')
end
handles = executeall(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Applications_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Tools_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Workflows_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Load_workflow_Callback(hObject, eventdata, handles)
[filename,pathname] = uigetfile({'*.m'},'Pick a file');
filename = fullfile(pathname,filename);
Generate_instructions_Callback(hObject, eventdata, handles, filename);
% --------------------------------------------------------------------
function Generate_instructions_Callback(hObject, eventdata, handles, filename)
current_dir = pwd;
if(exist(filename,'file'))
    [pathname,filename] = fileparts(filename);
else
    disp([filename,' script not found']);
    return
end
try
    if(exist(pathname,'dir'))
        cd(pathname);
    end
    eval(['myInstructions = ',filename,'(handles);']);
catch
    myInstructions = cell(0);
    myInstructions{1} = 'no_instruction()';
    disp('Error in workflow generation. Abort.')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    cd(current_dir);
end
cd(current_dir);
for i=1:length(myInstructions)
    handles.instructions{end+1} = myInstructions{i};
end
handles = executeall(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function Help_fct_Callback(hObject, eventdata, handles)
handles.instructions = cell(0);
handles = Update_regguiC_GUI(handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function Help_manual_Callback(hObject, eventdata, handles)
if(ispc)
    winopen(fullfile(get_reggui_path,'doc','help','REGGUI_readme.pdf'))
elseif(isunix)
    system(strcat('xpdf ''',fullfile(get_reggui_path,'doc','help','REGGUI_readme.pdf'),''''))
end
% --------------------------------------------------------------------
function Help_tutorials_Callback(hObject, eventdata, handles)
if(ispc)
    winopen(fullfile(get_reggui_path,'doc','help','REGGUI_readme.pdf'))
elseif(isunix)
    system(strcat('xpdf ''',fullfile(get_reggui_path,'doc','help','REGGUI_readme.pdf'),''''))
end
% --------------------------------------------------------------------
function Help_intro_registration_Callback(hObject, eventdata, handles)
if(ispc)
    winopen(fullfile(get_reggui_path,'doc','help','REGGUI_intro_to_registration.pdf'))
elseif(isunix)
    system(strcat('xpdf ''',fullfile(get_reggui_path,'doc','help','REGGUI_intro_to_registration.pdf'),''''))
end
% --------------------------------------------------------------------
function Help_publi_Callback(hObject, eventdata, handles)
if(ispc)
    winopen(fullfile(get_reggui_path,'doc','help','diffeomorphic_morphons_Janssens2011.pdf'))
elseif(isunix)
    system(strcat('xpdf ''',fullfile(get_reggui_path,'doc','help','diffeomorphic_morphons_Janssens2011.pdf'),''''))
end
% --------------------------------------------------------------------
function test_executable_Callback(hObject, eventdata, handles)
test_executables(handles);
% --------------------------------------------------------------------
function Help_about_Callback(hObject, eventdata, handles)
msgbox({'REGGUI';...
    handles.reggui_version;...
    '------';...
    '';...
    'Author: Guillaume Janssens';...
    'Contact : open.reggui@gmail.com';...
    '';...
    'OpenREGGUI is copyrighted by the OpenREGGUI Consortium. ';...
    'The software is distributed as open source under the Apache 2.0 ';...
    'license aproved by the Open Source Initiative (OSI). The complete ';...
    'license is shown in "License.txt".';...
    ''});

% ---------------------------- END OF REGGUIC
