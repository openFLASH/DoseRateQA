function varargout = reggui_instructions(varargin)
% REGGUI_INSTRUCTIONS MATLAB code for reggui_instructions.fig
%      REGGUI_INSTRUCTIONS, by itself, creates a new REGGUI_INSTRUCTIONS or raises the existing
%      singleton*.
%
%      H = REGGUI_INSTRUCTIONS returns the handle to a new REGGUI_INSTRUCTIONS or the handle to
%      the existing singleton*.
%
%      REGGUI_INSTRUCTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGGUI_INSTRUCTIONS.M with the given input arguments.
%
%      REGGUI_INSTRUCTIONS('Property','Value',...) creates a new REGGUI_INSTRUCTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before reggui_instructions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to reggui_instructions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help reggui_instructions

% Last Modified by GUIDE v2.5 01-Oct-2015 12:27:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reggui_instructions_OpeningFcn, ...
                   'gui_OutputFcn',  @reggui_instructions_OutputFcn, ...
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


% --- Executes just before reggui_instructions is made visible.
function reggui_instructions_OpeningFcn(hObject, eventdata, handles, varargin)
if(nargin>4)
    if(not(isempty(varargin{2})))
        handles.ancest = varargin{2};
    end
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes reggui_instructions wait for user response (see UIRESUME)
% uiwait(handles.reggui_instructions_gui);

% --- Outputs from this function are returned to the command line.
function varargout = reggui_instructions_OutputFcn(hObject, eventdata, handles) 
varargout{1} = [];

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% ----------------------------------------------------------
function listbox1_Callback(hObject, eventdata, handles)
