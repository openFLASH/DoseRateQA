function varargout = pacs_list(varargin)
% PACS_LIST MATLAB code for pacs_list.fig
%      PACS_LIST, by itself, creates a new PACS_LIST or raises the existing
%      singleton*.
%
%      H = PACS_LIST returns the handle to a new PACS_LIST or the handle to
%      the existing singleton*.
%
%      PACS_LIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PACS_LIST.M with the given input arguments.
%
%      PACS_LIST('Property','Value',...) creates a new PACS_LIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pacs_list_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pacs_list_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pacs_list

% Last Modified by GUIDE v2.5 02-Oct-2017 16:35:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pacs_list_OpeningFcn, ...
    'gui_OutputFcn',  @pacs_list_OutputFcn, ...
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


% ----------------------------------------------------------------------
function pacs_list_OpeningFcn(hObject, eventdata, handles, varargin)

if(not(isempty(varargin)))
    handles.filter = varargin{1};
    set(handles.data_list,'Max',1);
else
    handles.filter = '';
end

handles.patient_ids = orthanc_get_info('patients');
for i=1:length(handles.patient_ids)
    temp = orthanc_get_info(['patients/',handles.patient_ids{i}]);
    handles.patient_names{i} = temp.MainDicomTags.PatientName;
    handles.studies_ids{i} = temp.Studies;
end
set(handles.patient_list,'String',handles.patient_names);

handles.output_ids = {};
handles.output_names = {};
handles = update_list(handles,handles.filter);
guidata(hObject, handles);
uiwait(handles.figure1);

% ----------------------------------------------------------------------
function varargout = pacs_list_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output_ids;
varargout{2} = handles.output_names;
delete(handles.figure1);

% ----------------------------------------------------------------------
function Ok_button_Callback(hObject, eventdata, handles)
selection = get(handles.data_list,'Value');
names = get(handles.data_list,'String');
handles.output_ids = handles.ids(selection);
handles.output_names = names(selection);
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes during object creation, after setting all properties.
function patient_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function data_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ----------------------------------------------------------------------
function patient_list_Callback(hObject, eventdata, handles)
handles = update_list(handles,handles.filter);
guidata(hObject, handles);

% ----------------------------------------------------------------------
function data_list_Callback(hObject, eventdata, handles)

% ----------------------------------------------------------------------
function handles = update_list(handles,filter)
handles.ids = {};
if(nargin<2)
    filter = '';
end
p=get(handles.patient_list,'Value');
series_names = {};
for i=1:length(handles.studies_ids{p})
    temp_s = orthanc_get_info(['studies/',handles.studies_ids{p}{i}]);
    serie_id = temp_s.Series;
    for j=1:length(serie_id)
        temp = orthanc_get_info(['series/',serie_id{j}]);
        add_to_list = 1;
        switch filter
            case 'image'
                if(strcmp(temp.MainDicomTags.Modality,'RTSTRUCT')||strcmp(temp.MainDicomTags.Modality,'RTPLAN')||strcmp(temp.MainDicomTags.Modality,'REG'))
                    add_to_list = 0;
                end
            case 'struct'
                if(not(strcmp(temp.MainDicomTags.Modality,'RTSTRUCT')))
                    add_to_list = 0;
                end
            case 'plan'
                if(not(strcmp(temp.MainDicomTags.Modality,'RTPLAN')))
                    add_to_list = 0;
                end
            case 'field'
                if(not(strcmp(temp.MainDicomTags.Modality,'REG')))
                    add_to_list = 0;
                end                
        end
        if(strcmp(temp.MainDicomTags.Modality,'RTDOSE'))
            add_to_list = 2;
        end        
        if(add_to_list==1)
            handles.ids{end+1} = serie_id{j};
            if(isfield(temp.MainDicomTags,'SeriesDescription'))
                if(not(isempty(temp.MainDicomTags.SeriesDescription)))
                    series_names{end+1} = temp.MainDicomTags.SeriesDescription;
                else
                    series_names{end+1} = temp.MainDicomTags.SeriesInstanceUID;
                end
            else
                series_names{end+1} = temp.MainDicomTags.SeriesInstanceUID;
            end
        elseif(add_to_list==2)
            for k=1:length(temp.Instances)
                handles.ids{end+1} = temp.Instances{k};
                if(isfield(temp.MainDicomTags,'SeriesDescription'))
                    series_names{end+1} = [temp.MainDicomTags.SeriesDescription,'_',num2str(k)];
                else
                    series_names{end+1} = [temp.MainDicomTags.SeriesInstanceUID,'_',num2str(k)];
                end
            end
        end
    end
end

set(handles.data_list,'String',series_names);
if(get(handles.data_list,'Value')>length(series_names))
    set(handles.data_list,'Value',1);
end

