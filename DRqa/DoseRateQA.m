function varargout = DoseRateQA(varargin)

% DOSERATEQA MATLAB code for DoseRateQA.fig
%      DOSERATEQA, by itself, creates a new DOSERATEQA or raises the existing
%      singleton*.
%
%      H = DOSERATEQA returns the handle to a new DOSERATEQA or the handle to
%      the existing singleton*.
%
%      DOSERATEQA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOSERATEQA.M with the given input arguments.
%
%      DOSERATEQA('Property','Value',...) creates a new DOSERATEQA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DoseRateQA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DoseRateQA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DoseRateQA

% Last Modified by GUIDE v2.5 15-Oct-2024 13:30:37

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DoseRateQA_OpeningFcn, ...
    'gui_OutputFcn',  @DoseRateQA_OutputFcn, ...
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


% --- Executes just before DoseRateQA is made visible.
function DoseRateQA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DoseRateQA (see VARARGIN)

% Choose default command line output for DoseRateQA
handles.output = hObject;

%If there are stored preference, load then and update GUI

if ispref('DoseRateQA','planFileName')
    handles.config.files.planFileName = getpref('DoseRateQA','planFileName');
    set(handles.EditPlan,'String',handles.config.files.planFileName)
end

if ispref('DoseRateQA','rtstructFileName')
    handles.config.files.rtstructFileName = getpref('DoseRateQA','rtstructFileName');
    set(handles.editRTstruct,'String',handles.config.files.rtstructFileName)

    if exist(handles.config.files.rtstructFileName)
        RTstrucOUT = read_dicomrtstruct(handles.config.files.rtstructFileName);
        StructList = convertCharsToStrings({RTstrucOUT.Struct.Name});

        set(handles.popupmenuBody,'String',StructList)
        [~ , index  ] = findClosestString( StructList , 'BODY' );
        set(handles.popupmenuBody,'Value',index(1))

        set(handles.popupmenuTarget,'String',StructList)
        [~ , index ] = findClosestString( StructList , 'CTV' );
        set(handles.popupmenuTarget,'Value',index(1))

        if ispref('DoseRateQA','popupmenuBody')
            set(handles.popupmenuBody,'Value',getpref('DoseRateQA','popupmenuBody'))
        end
        if ispref('DoseRateQA','popupmenuTarget')
            set(handles.popupmenuTarget,'Value',getpref('DoseRateQA','popupmenuTarget'))
        end
    else
        fprintf("CRITICAL WARNING: the provided RT-Struct file doens't exist. Please provide an existing file path.\n");
    end
end

if ispref('DoseRateQA','CTname')
    handles.config.files.CTname = getpref('DoseRateQA','CTname');
    set(handles.editCT,'String',handles.config.files.CTname)
end

if ispref('DoseRateQA','RecordName')
    handles.config.files.RecordName = getpref('DoseRateQA','RecordName');
    set(handles.editLogFile,'String',handles.config.files.RecordName)
end

if ispref('DoseRateQA','BDL')
    handles.config.BeamProp.BDL = getpref('DoseRateQA','BDL');
    set(handles.editBDL,'String',handles.config.BeamProp.BDL)
end

if ispref('DoseRateQA','ScannerDirectory')
    handles.config.BeamProp.ScannerDirectory = getpref('DoseRateQA','ScannerDirectory');
    set(handles.editScanner,'String',handles.config.BeamProp.ScannerDirectory)
end

if ispref('DoseRateQA','MCsqExecPath')
    handles.config.BeamProp.MCsqExecPath = getpref('DoseRateQA','MCsqExecPath');
    set(handles.editMC2,'String',handles.config.BeamProp.MCsqExecPath)
end

if ispref('DoseRateQA','output_path')
    handles.config.files.output_path = getpref('DoseRateQA','output_path');
    set(handles.editoutput,'String',handles.config.files.output_path)
end

if ispref('DoseRateQA','editNbProtons')
    set(handles.editNbProtons,'String',getpref('DoseRateQA','editNbProtons'))
end

if ispref('DoseRateQA','editDoseGrid')
    set(handles.editDoseGrid,'String',getpref('DoseRateQA','editDoseGrid'))
end

if ispref('DoseRateQA','editDose')
    set(handles.editDose,'String',getpref('DoseRateQA','editDose'))
end

if ispref('DoseRateQA','uitablePointList')
  set(handles.uitablePointList,'Data' , getpref('DoseRateQA','uitablePointList'))
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DoseRateQA wait for user response (see UIRESUME)
% uiwait(handles.DoseRateQAFig);


% --- Outputs from this function are returned to the command line.
function varargout = DoseRateQA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function EditPlan_Callback(hObject, eventdata, handles)
% hObject    handle to EditPlan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPlan as text
%        str2double(get(hObject,'String')) returns contents of EditPlan as a double


% --- Executes during object creation, after setting all properties.
function EditPlan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPlan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ButtonPlan.
function ButtonPlan_Callback(hObject, eventdata, handles)
[file,location] = uigetfile('*.dcm','Select treatment plan',getpref('DoseRateQA','planFileName',pwd));
if location ~= 0
    %This is a valid file
    handles.config.files.planFileName = fullfile(location , file);
    set(handles.EditPlan,'String',handles.config.files.planFileName)
    setpref('DoseRateQA','planFileName',handles.config.files.planFileName); %SAve current value in preferences
end
guidata(hObject, handles);


function editRTstruct_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editRTstruct_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ButtonRSstru.
function ButtonRSstru_Callback(hObject, eventdata, handles)

[file,location] = uigetfile('*.dcm','Select RT structure',getpref('DoseRateQA','rtstructFileName',pwd));
if location ~= 0
    %This is a valid file
    handles.config.files.rtstructFileName = fullfile(location , file);
    set(handles.editRTstruct,'String',handles.config.files.rtstructFileName)
    setpref('DoseRateQA','rtstructFileName',handles.config.files.rtstructFileName); %SAve current value in preferences
else
    guidata(hObject, handles);
    return;
end

RTstrucOUT = read_dicomrtstruct(handles.config.files.rtstructFileName);
StructList = convertCharsToStrings({RTstrucOUT.Struct.Name});

set(handles.popupmenuBody,'String',StructList)
[~ , index  ] = findClosestString( StructList , 'BODY' );
set(handles.popupmenuBody,'Value',index(1))
setpref('DoseRateQA','popupmenuBody',index(1)); %SAve current value in preferences

set(handles.popupmenuTarget,'String',StructList)
[~ , index ] = findClosestString( StructList , 'CTV' );
set(handles.popupmenuTarget,'Value',index(1))
setpref('DoseRateQA','popupmenuTarget',index(1)); %SAve current value in preferences

guidata(hObject, handles);


function editCT_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editCT_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ButtonCT.
function ButtonCT_Callback(hObject, eventdata, handles)

[file,location] = uigetfile('*.dcm','Select CT scan',getpref('DoseRateQA','CTname',pwd));
if location ~= 0
    %This is a valid file
    handles.config.files.CTfolder = location;
    handles.config.files.CTname = fullfile(location , file);
    set(handles.editCT,'String',handles.config.files.CTname)
    setpref('DoseRateQA','CTname',handles.config.files.CTname); %SAve current value in preferences
end
guidata(hObject, handles);

% --- Executes on selection change in popupmenuBody.
function popupmenuBody_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function popupmenuBody_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTarget.
function popupmenuTarget_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function popupmenuTarget_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editoutput_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editoutput_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonOutput.
function pushbuttonOutput_Callback(hObject, eventdata, handles)

location = uigetdir(getpref('DoseRateQA','output_path',pwd),'Select output folder');
if location ~= 0
    %This is a valid file
    handles.config.files.output_path = location;
    set(handles.editoutput,'String',handles.config.files.output_path)
    setpref('DoseRateQA','output_path',handles.config.files.output_path); %SAve current value in preferences
else
    guidata(hObject, handles);
    return
end

%check whether folder is empty
listing = dir(handles.config.files.output_path);
listing = listing((~ismember({listing.name}, {'.', '..'})));
if ~isempty(listing)
    msgbox(['Output folder not empty. Existing data will be reused.' newline 'You should provide an empty folder to refresh all computations.'],...
        'Warning' , "warn");
end

guidata(hObject, handles);


function editBDL_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editBDL_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonBDL.
function pushbuttonBDL_Callback(hObject, eventdata, handles)

[file,location] = uigetfile('*.txt','Select beam data library file', getpref('DoseRateQA','BDL',pwd));
if location ~= 0
    %This is a valid file
    handles.config.BeamProp.BDL = fullfile(location , file);
    set(handles.editBDL,'String',handles.config.BeamProp.BDL)
    setpref('DoseRateQA','BDL',handles.config.BeamProp.BDL); %SAve current value in preferences
end
guidata(hObject, handles);


function editScanner_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editScanner_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonScanner.
function pushbuttonScanner_Callback(hObject, eventdata, handles)

location = uigetdir(getpref('DoseRateQA','ScannerDirectory',pwd),'Select scanner folder');
if location ~= 0
    %This is a valid file
    handles.config.BeamProp.ScannerDirectory = location;
    set(handles.editScanner,'String',handles.config.BeamProp.ScannerDirectory)
    setpref('DoseRateQA','ScannerDirectory',handles.config.BeamProp.ScannerDirectory); %SAve current value in preferences
end
guidata(hObject, handles);


function editMC2_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editMC2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonMC2.
function pushbuttonMC2_Callback(hObject, eventdata, handles)

location = uigetdir(pwd,'Select MC square folder');
if location ~= 0
    %This is a valid file
    handles.config.BeamProp.MCsqExecPath = location;
    set(handles.editMC2,'String',handles.config.BeamProp.MCsqExecPath)
    setpref('DoseRateQA','MCsqExecPath',handles.config.BeamProp.MCsqExecPath); %SAve current value in preferences
end
guidata(hObject, handles);


function editDose_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editDose_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCompute.
function pushbuttonCompute_Callback(hObject, eventdata, handles)

%check whether folder is empty
listing = dir(handles.config.files.output_path);
listing = listing((~ismember({listing.name}, {'.', '..'})));
if ~isempty(listing)
    waitfor(msgbox(['Output folder not empty. Existing data will be reused.' newline 'You should provide an empty folder to refresh all computations.'],...
        'Warning' , "warn"));
end

guidata(hObject, handles);

%Read data and chech consistency
tmp = str2num(get(handles.editDose,'String'));
if ~isempty(tmp)
    handles.config.Analysis.DoseMin = tmp;
    setpref('DoseRateQA','editDose',get(handles.editDose,'String')); %SAve current value in preferences
else
    warning('Incorrect minimum dose')
    set(handles.editStatus,'String','Error : Incorrect minimum dose')
    guidata(hObject, handles);
    return
end

List = get(handles.popupmenuBody,'String');
Selected = get(handles.popupmenuBody,'Value');
setpref('DoseRateQA','popupmenuBody',Selected); %SAve current value in preferences
handles.config.RTstruct.ExternalROI = remove_bad_chars(List{Selected});

Selected = get(handles.popupmenuTarget,'Value');
setpref('DoseRateQA','popupmenuTarget',Selected); %SAve current value in preferences
handles.config.Analysis.Target = remove_bad_chars(List{Selected});

tmp = str2num(get(handles.editNbProtons,'String'));
if ~isempty(tmp)
    handles.config.BeamProp.protonsHighResDose = tmp;
    setpref('DoseRateQA','editNbProtons',get(handles.editNbProtons,'String')); %SAve current value in preferences
else
    warning('Incorrect number of protons')
    set(handles.editStatus,'String','Error : Incorrect number of protons')
    guidata(hObject, handles);
    return
end
tmp = str2num(get(handles.editDoseGrid,'String'));
if ~isempty(tmp) & numel(tmp) == 3
    handles.config.BeamProp.CEFDoseGrid =  tmp;
    setpref('DoseRateQA','editDoseGrid',get(handles.editDoseGrid,'String')); %SAve current value in preferences
else
    warning('Incorrect dose grid size')
    set(handles.editStatus,'String','Error : Incorrect dose grid size')
    guidata(hObject, handles);
    return
end

handles.config.BeamProp.DICOMdict = fullfile(handles.config.BeamProp.MCsqExecPath , 'dicom-dict.txt');

handles.config.RTstruct.DRPercentile = 0.95; %Not used anyway
handles.config.files.AggregatePaintings = 0;

%Delete all open figures
h = findall(groot,'Type','figure'); %Find all open figures
for Hidx = 1:numel(h)
    if ~strcmp('DoseRateQA', h(Hidx).Name )
        %Do not close the GUI of this program
        if ~isempty(h(Hidx).Number)
            close(h(Hidx).Number)
        else
            close(h(Hidx).Name)
        end
    end
end

set(handles.editStatus,'String','Computing...')
runDRqa(handles.config); %Run the computation. This may take some time
set(handles.editStatus,'String','Computation finished')


guidata(hObject, handles);

% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
selection = questdlg('Do you really want to close the program ?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection
    case 'Yes'
        closereq(); %Close the GUI
    case 'No'
        return
end



function editStatus_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editStatus_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDoseGrid_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editDoseGrid_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editNbProtons_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editNbProtons_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editLogFile_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editLogFile_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLogFile.
function pushbuttonLogFile_Callback(hObject, eventdata, handles)

[file,location] = uigetfile('*.zip','Select log file',getpref('DoseRateQA','RecordName',pwd));
if location ~= 0
    %This is a valid file
    handles.config.files.RecordName = fullfile(location , file);
    set(handles.editLogFile,'String',handles.config.files.RecordName)
    setpref('DoseRateQA','RecordName',handles.config.files.RecordName); %SAve current value in preferences
end
guidata(hObject, handles);


% --- Executes on button press in pushbuttonTimeTRace.
function pushbuttonTimeTRace_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTimeTRace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitablePointList,'Data');
setpref('DoseRateQA','uitablePointList',data); %SAve current value in preferences

%REmove empty lines from input
flag = cellfun(@isempty, data(:,2:4));
flag = sum(flag,2);
i = find(~flag);
GoodLines = unique(i);
Pg = cellfun(@str2num, data(GoodLines,2:4)); %Convert cell array into numerical matrix

config.files.output_path = handles.config.files.output_path;
config.files.planFileName = handles.config.files.planFileName;
List = get(handles.popupmenuBody,'String');
Selected = get(handles.popupmenuBody,'Value');
setpref('DoseRateQA','popupmenuBody',Selected); %SAve current value in preferences
config.RTstruct.ExternalROI = remove_bad_chars(List{Selected});


titleSTR = data(:,1);

set(handles.editStatus,'String','Computing...')
runGetDoseTiming(config , Pg, titleSTR);
set(handles.editStatus,'String','Computation finished')

guidata(hObject, handles);


% --- Executes on button press in pushButtonViewReggui.
function pushButtonViewReggui_Callback(hObject, eventdata, handles)

[CTfolder,CTname,CText] = fileparts(getpref('DoseRateQA','CTname',pwd));
CTname = [CTname, CText];
inst1 = "handles=Import_image('" + CTfolder + "','";
inst1 = inst1.append(CTname + "',");
inst1 = inst1.append("1,'CT',handles);");

inst2 = "handles=Import_contour('" + handles.config.files.rtstructFileName + "',";
inst2 = inst2.append("'all','CT',1,handles);");

inst10 = "handles.image1.Value=2;";

inst98 = "Update_regguiC_GUI(handles);";
inst99 = "handles=Apply_view_point(handles);";
inst100 = "Update_regguiC_all_plots(handles);";

instructions = {inst1, inst2, inst98, inst99, inst100, inst10};

reggui('GUI',1,'dataPath',handles.config.files.output_path,'workflow',instructions);


