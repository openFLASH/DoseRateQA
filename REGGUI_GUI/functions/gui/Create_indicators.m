function varargout = Create_indicators(varargin)
% CREATE_INDICATORS MATLAB code for Create_indicators.fig
%      CREATE_INDICATORS, by itself, creates a new CREATE_INDICATORS or raises the existing
%      singleton*.
%
%      H = CREATE_INDICATORS returns the handle to a new CREATE_INDICATORS or the handle to
%      the existing singleton*.
%
%      CREATE_INDICATORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_INDICATORS.M with the given input arguments.
%
%      CREATE_INDICATORS('Property','Value',...) creates a new CREATE_INDICATORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Create_indicators_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Create_indicators_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Create_indicators

% Last Modified by GUIDE v2.5 14-Jun-2017 16:54:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Create_indicators_OpeningFcn, ...
    'gui_OutputFcn',  @Create_indicators_OutputFcn, ...
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


% ------------------------------------------------------------------------
function Create_indicators_OpeningFcn(hObject, eventdata, handles, varargin)
handles.contours = {};
if(nargin>2)
    ancest = varargin{1};
    if(isstruct(ancest)) % ancest is the reggui handles
        for i=1:length(ancest.images.name)
            try
                [~,info] = Get_reggui_data(ancest,ancest.images.name{i});
                if(isfield(info,'Contour_name'))
                    handles.contours{end+1} = info.Contour_name;
                end
            catch
            end
        end
    elseif(iscell(ancest)) % ancest is a list of available contours
        handles.contours = ancest;
    end
else
    set(handles.list_structs,'Visible','off');
end
if(length(varargin)>1)
    handles.indicators = varargin{2};    
else
    handles.indicators = [];
end
handles = update_txt(handles);
handles = update_menus(handles);
handles.output = [];
guidata(hObject, handles);
uiwait(handles.figure1);


% ------------------------------------------------------------------------
function varargout = Create_indicators_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
delete(handles.figure1);


% ------------------------------------------------------------------------
function Quit_button_Callback(hObject, eventdata, handles)
indicators = {};
i = 0;
for index=1:9
    contour = get(handles.(['edit_struct_',num2str(index)]),'String');    
    if(not(isempty(contour)))
        i = i+1;
        indicators{i}.struct = contour;
        beam = str2double(get(handles.(['edit_beam_',num2str(i)]),'String'));
        if(isnan(beam))
            indicators{i}.beam = 0;% use '0' for sum dose
        else
            indicators{i}.beam = beam;
        end
        types = get(handles.(['menu_type_',num2str(i)]),'String');
        if(ischar(types))
            types = {types};
        end
        indicators{i}.type = types{get(handles.(['menu_type_',num2str(i)]),'Value')};
        values = get(handles.(['menu_value_',num2str(i)]),'String');
        if(ischar(values))
            values = {values};
        end
        indicators{i}.value = values{get(handles.(['menu_value_',num2str(i)]),'Value')};
        units = get(handles.(['menu_unit_',num2str(i)]),'String');
        if(ischar(units))
            units = {units};
        end
        indicators{i}.unit = units{get(handles.(['menu_unit_',num2str(i)]),'Value')};
        if(strcmp(indicators{i}.type,'Distance')||strcmp(indicators{i}.type,'Distance_WET'))
            indicators{i}.param = get(handles.(['edit_param_',num2str(i)]),'String');
        else
            indicators{i}.param = str2num(get(handles.(['edit_param_',num2str(i)]),'String'));
        end
        units = get(handles.(['menu_param_unit_',num2str(i)]),'String');
        if(ischar(units))
            units = {units};
        end
        indicators{i}.param_unit = units{get(handles.(['menu_param_unit_',num2str(i)]),'Value')};
        tests = get(handles.(['menu_acceptance_test_',num2str(i)]),'String');
        if(ischar(tests))
            tests = {tests};
        end
        indicators{i}.acceptance_test = tests{get(handles.(['menu_acceptance_test_',num2str(i)]),'Value')};
        level = str2double(get(handles.(['edit_acceptance_level_',num2str(i)]),'String'));
        if(isnan(level))
            indicators{i}.acceptance_level = [];
        else
            indicators{i}.acceptance_level = level;
        end
        tolerance = str2double(get(handles.(['edit_acceptance_tolerance_',num2str(i)]),'String'));
        if(isnan(tolerance))
            indicators{i}.acceptance_tolerance = [];
        else
            indicators{i}.acceptance_tolerance = tolerance;
        end
        units = get(handles.(['menu_acceptance_unit_',num2str(i)]),'String');
        if(ischar(units))
            units = {units};
        end
        indicators{i}.acceptance_unit = units{get(handles.(['menu_acceptance_unit_',num2str(i)]),'Value')};        
        prescription = str2double(get(handles.(['edit_prescription_',num2str(i)]),'String'));
        if(isnan(prescription))
            indicators{i}.prescription = [];
        else
            indicators{i}.prescription = prescription;
        end
        
        
        disp(indicators{i})
        
        
    end    
end
handles.output = indicators;
guidata(hObject, handles);
uiresume(handles.figure1);


% ------------------------------------------------------------------------
function add_Callback(hObject, eventdata, handles)
handles.indicators{end+1} = [];
i = length(handles.indicators);
if(i<10)
    % Un-hide
    set(handles.(['edit_struct_',num2str(i)]),'Visible','on');
    set(handles.(['edit_beam_',num2str(i)]),'Visible','on');
    set(handles.(['menu_type_',num2str(i)]),'Visible','on');
    set(handles.(['menu_value_',num2str(i)]),'Visible','on');
    set(handles.(['menu_unit_',num2str(i)]),'Visible','on');
    set(handles.(['edit_param_',num2str(i)]),'Visible','on');
    set(handles.(['menu_param_unit_',num2str(i)]),'Visible','on');
    set(handles.(['menu_acceptance_test_',num2str(i)]),'Visible','on');
    set(handles.(['edit_acceptance_level_',num2str(i)]),'Visible','on');
    set(handles.(['edit_acceptance_tolerance_',num2str(i)]),'Visible','on');
    set(handles.(['menu_acceptance_unit_',num2str(i)]),'Visible','on');
    set(handles.(['edit_prescription_',num2str(i)]),'Visible','on');
    handles = update_menus(handles,i);
end
if(length(handles.contours)>1)
    c = get(handles.list_structs,'Value');
    set(handles.(['edit_struct_',num2str(i)]),'String',handles.contours{c});
end
guidata(hObject, handles);


% ------------------------------------------------------------------------
function handles = update_txt(handles)
set(handles.list_structs,'String',handles.contours);
for i=1:9
    if(length(handles.indicators)>=i)
        set(handles.(['edit_struct_',num2str(i)]),'String',handles.indicators{i}.struct);
        set(handles.(['edit_beam_',num2str(i)]),'String',num2str(handles.indicators{i}.beam));
        set(handles.(['edit_param_',num2str(i)]),'String',num2str(handles.indicators{i}.param));
        set(handles.(['edit_acceptance_level_',num2str(i)]),'String',num2str(handles.indicators{i}.acceptance_level));
        set(handles.(['edit_acceptance_tolerance_',num2str(i)]),'String',num2str(handles.indicators{i}.acceptance_tolerance));
        set(handles.(['edit_prescription_',num2str(i)]),'String',num2str(handles.indicators{i}.prescription));
        temp = find(strcmp(get(handles.(['menu_type_',num2str(i)]),'String'),handles.indicators{i}.type));
        if(not(isempty(temp)))
            set(handles.(['menu_type_',num2str(i)]),'Value',temp);
        end
        handles = update_menus(handles,i);
        temp = find(strcmp(get(handles.(['menu_value_',num2str(i)]),'String'),handles.indicators{i}.value));
        if(not(isempty(temp)))
            set(handles.(['menu_value_',num2str(i)]),'Value',temp);
        end
        temp = find(strcmp(get(handles.(['menu_unit_',num2str(i)]),'String'),handles.indicators{i}.unit));
        if(not(isempty(temp)))
            set(handles.(['menu_unit_',num2str(i)]),'Value',temp);
        end
        temp = find(strcmp(get(handles.(['menu_param_unit_',num2str(i)]),'String'),handles.indicators{i}.param_unit));
        if(not(isempty(temp)))
            set(handles.(['menu_param_unit_',num2str(i)]),'Value',find(strcmp(get(handles.(['menu_param_unit_',num2str(i)]),'String'),handles.indicators{i}.param_unit)));
        end
        temp = find(strcmp(get(handles.(['menu_acceptance_test_',num2str(i)]),'String'),handles.indicators{i}.acceptance_test));
        if(not(isempty(temp)))
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',temp);
        end
        temp = find(strcmp(get(handles.(['menu_acceptance_unit_',num2str(i)]),'String'),handles.indicators{i}.acceptance_unit));
        if(not(isempty(temp)))
            set(handles.(['menu_acceptance_unit_',num2str(i)]),'Value',temp);
        end
    else
        % Hide
        set(handles.(['edit_struct_',num2str(i)]),'Visible','off');
        set(handles.(['edit_beam_',num2str(i)]),'Visible','off');
        set(handles.(['edit_param_',num2str(i)]),'Visible','off');
        set(handles.(['edit_acceptance_level_',num2str(i)]),'Visible','off');
        set(handles.(['edit_acceptance_tolerance_',num2str(i)]),'Visible','off');
        set(handles.(['edit_prescription_',num2str(i)]),'Visible','off');
        set(handles.(['menu_type_',num2str(i)]),'Visible','off');
        set(handles.(['menu_value_',num2str(i)]),'Visible','off');
        set(handles.(['menu_unit_',num2str(i)]),'Visible','off');        
        set(handles.(['menu_param_unit_',num2str(i)]),'Visible','off');
        set(handles.(['menu_acceptance_test_',num2str(i)]),'Visible','off');        
        set(handles.(['menu_acceptance_unit_',num2str(i)]),'Visible','off');        
    end
end
guidata(handles.Quit_button,handles);


% ------------------------------------------------------------------------
function handles = update_menus(handles,indices)
if(nargin<2)
    indices = 1:min(length(handles.indicators),9);
end
for i=indices
    type_list = get(handles.(['menu_type_',num2str(i)]),'String');
    units = {''};
    param_units = {''};
    acceptance_units = {''};
    switch type_list{get(handles.(['menu_type_',num2str(i)]),'Value')}
        case 'D'
            values = {'';'min';'max';'mean';'geud'};
            units = {'[Gy]';'[%p]'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')==1)
                param_units = {'[%]';'[cc]'};
            end    
            acceptance_units = units;
        case 'V'
            values = {''};
            units = {'[%]';'[cc]'};
            param_units = {'[Gy]';'[%p]'};
            acceptance_units = units;
        case 'D_index'
            values = {'conformity';'homogeneity'};
            units = {''};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')==1)
                param_units = {'[Gy]';'[%p]'};
            else
                param_units = {'[%]'};
            end
            acceptance_units = units;
        case 'D_diff'
            values = {'min';'max';'mean';'max_abs';'mean_abs';'percentile';'percentile_abs'};
            units = {'[Gy]';'[%p]';'relative'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>5)
                param_units = {'[%]'};
            else
                param_units = {''};
            end    
            acceptance_units = units;
        case 'D_gamma'
            values = {'min';'max';'mean';'passing_rate'};
            units = {''}; 
            param_units = {'[%,mm]'};
            acceptance_units = units;
        case 'WET_3D'
            values = {'min';'max';'mean';'percentile'};
            units = {'[mm]'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>3)
                param_units = {'[%]'};
            else
                param_units = {''};
            end   
            acceptance_units = units;
        case 'WET_3D_diff'
            values = {'min';'max';'mean';'max_abs';'mean_abs';'percentile';'percentile_abs'};
            units = {'[mm]';'[%]','relative'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>5)
                param_units = {'[%]'};
            else
                param_units = {''};
            end   
            acceptance_units = units;
        case 'WET_3D_gamma'
            values = {'min';'max';'mean';'passing_rate'};
            units = {''};
            param_units = {'[%,mm]'};
            acceptance_units = units;
        case 'WET_distal'
            values = {'min';'max';'mean';'percentile'};
            units = {'[mm]'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>3)
                param_units = {'[%]'};
            else
                param_units = {''};
            end   
            acceptance_units = units;
        case 'WET_distal_diff'
            values = {'min';'max';'mean';'max_abs';'mean_abs';'percentile';'percentile_abs';'overrange_mean';'overrange_max';'overrange_rate';'underrange_mean';'underrange_max';'underrange_rate'};
            units = {'[mm]';'[%]','[]'};
            switch get(handles.(['menu_value_',num2str(i)]),'Value')
                case {10,13}
                    param_units = {'[mm]'};
                case {6,7}
                    param_units = {'[%]'};
                otherwise
                    param_units = {''};
            end 
            acceptance_units = units;
        case 'WET_proximal'
            values = {'min';'max';'mean';'percentile'};
            units = {'[mm]'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>3)
                param_units = {'[%]'};
            else
                param_units = {''};
            end   
            acceptance_units = units;
        case 'WET_proximal_diff'
            values = {'min';'max';'mean';'max_abs';'mean_abs';'percentile';'percentile_abs';'overrange_mean';'overrange_max';'overrange_rate';'underrange_mean';'underrange_max';'underrange_rate'};
            units = {'[mm]';'[%]','[]'};
            switch get(handles.(['menu_value_',num2str(i)]),'Value')
                case {10,13}
                    param_units = {'[mm]'};
                case {6,7}
                    param_units = {'[%]'};
                otherwise
                    param_units = {''};
            end
            acceptance_units = units;
        case 'Intensity'
            values = {'mean';'std';'percentile'};
            units = {'[HU]','[SP]'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>2)
                param_units = {'[%]'};
            else
                param_units = {''};
            end   
            acceptance_units = units;
        case 'Intensity_diff'
            values = {'min';'max';'mean';'max_abs';'mean_abs';'percentile';'percentile_abs'};
            units = {'[HU]','[SP]','relative'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>5)
                param_units = {'[%]'};
            else
                param_units = {''};
            end   
            acceptance_units = units;
        case 'Distance'
            values = {'min';'max';'mean'};
            units = {'[mm]'};
            acceptance_units = units;
        case 'Distance_WET'
            values = {'min';'max';'mean'};
            units = {'[mm]'};
            acceptance_units = units;
        case 'Motion'
            values = {'min';'max';'mean';'percentile'};
            units = {'[mm]'};
            if(get(handles.(['menu_value_',num2str(i)]),'Value')>3)
                param_units = {'[%]'};
            else
                param_units = {''};
            end   
            acceptance_units = units;
    end
    % set value menu index
    if(get(handles.(['menu_value_',num2str(i)]),'Value')>length(values))
        set(handles.(['menu_value_',num2str(i)]),'Value',1);
    end
    set(handles.(['menu_value_',num2str(i)]),'String',values);
    % set unit menu index
    if(get(handles.(['menu_unit_',num2str(i)]),'Value')>length(units))
        set(handles.(['menu_unit_',num2str(i)]),'Value',1);
    end
    set(handles.(['menu_unit_',num2str(i)]),'String',units);
    % set param_unit menu index
    if(get(handles.(['menu_param_unit_',num2str(i)]),'Value')>length(param_units))
        set(handles.(['menu_param_unit_',num2str(i)]),'Value',1);
    end    
    set(handles.(['menu_param_unit_',num2str(i)]),'String',param_units);
    % set acceptance_unit menu index
    if(get(handles.(['menu_acceptance_unit_',num2str(i)]),'Value')>length(acceptance_units))
        set(handles.(['menu_acceptance_unit_',num2str(i)]),'Value',1);
    end    
    set(handles.(['menu_acceptance_unit_',num2str(i)]),'String',acceptance_units);
end
guidata(handles.Quit_button,handles);


% ------------------------------------------------------------------------
function handles = set_default_values(handles,type,indices)
if(nargin<2)
    indices = 1:min(length(handles.indicators),9);
end
for i=indices
    switch type
        case 'D'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',1);
        case 'V'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'D_index'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',1);
        case 'D_diff'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'D_gamma'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
            set(handles.(['edit_param_',num2str(i)]),'String','3,3');
        case 'WET_3D'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',1);
        case 'WET_3D_diff'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'WET_gamma'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'WET_distal'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',1);
        case 'WET_distal_diff'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'WET_proximal'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',1);
        case 'WET_proximal_diff'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'Intensity'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',1);
        case 'Intensity_diff'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'Distance'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',1);
        case 'Distance_WET'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
        case 'Motion'
            set(handles.(['menu_acceptance_test_',num2str(i)]),'Value',2);
    end
end


% ------------------------------------------------------------------------
function edit_struct_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_1_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,1);
handles = update_menus(handles,1);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_1_Callback(hObject, eventdata, handles)
handles = update_menus(handles,1);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_1_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_2_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,2);
handles = update_menus(handles,2);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_2_Callback(hObject, eventdata, handles)
handles = update_menus(handles,2);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_2_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_3_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,3);
handles = update_menus(handles,3);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_3_Callback(hObject, eventdata, handles)
handles = update_menus(handles,3);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_3_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_4_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,4);
handles = update_menus(handles,4);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_4_Callback(hObject, eventdata, handles)
handles = update_menus(handles,4);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_4_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_5_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,5);
handles = update_menus(handles,5);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_5_Callback(hObject, eventdata, handles)
handles = update_menus(handles,5);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_5_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_6_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,6);
handles = update_menus(handles,6);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_6_Callback(hObject, eventdata, handles)
handles = update_menus(handles,6);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_6_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_7_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,7);
handles = update_menus(handles,7);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_7_Callback(hObject, eventdata, handles)
handles = update_menus(handles,7);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_7_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_8_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,8);
handles = update_menus(handles,8);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_8_Callback(hObject, eventdata, handles)
handles = update_menus(handles,8);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_unit_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_prescription_8_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_prescription_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_struct_9_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_struct_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_beam_9_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_beam_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_type_9_Callback(hObject, eventdata, handles)
types = get(hObject,'String');
type = types{get(hObject,'Value')};
handles = set_default_values(handles,type,9);
handles = update_menus(handles,9);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_type_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_param_9_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_param_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_value_9_Callback(hObject, eventdata, handles)
handles = update_menus(handles,9);guidata(hObject, handles);

% ------------------------------------------------------------------------
function menu_value_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_unit_9_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_unit_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_param_unit_9_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_param_unit_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_test_9_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function menu_acceptance_test_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function edit_acceptance_level_9_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function edit_acceptance_level_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------------
function edit_acceptance_tolerance_9_Callback(hObject, eventdata, handles)


% ------------------------------------------------------------------------
function edit_acceptance_tolerance_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function menu_acceptance_unit_9_Callback(hObject, eventdata, handles)


% ------------------------------------------------------------------------
function menu_acceptance_unit_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------------
function edit_prescription_9_Callback(hObject, eventdata, handles)


% ------------------------------------------------------------------------
function edit_prescription_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ------------------------------------------------------------------------
function list_structs_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function list_structs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
