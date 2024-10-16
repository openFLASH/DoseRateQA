function varargout = patient_file(varargin)
% PATIENT_FILE M-file for patient_file.fig
%      PATIENT_FILE, by itself, creates a new PATIENT_FILE or raises the existing
%      singleton*.
%
%      H = PATIENT_FILE returns the handle to a new PATIENT_FILE or the handle to
%      the existing singleton*.
%
%      PATIENT_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PATIENT_FILE.M with the given input arguments.
%
%      PATIENT_FILE('Property','Value',...) creates a new PATIENT_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before patient_file_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to patient_file_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help patient_file

% Last Modified by GUIDE v2.5 05-Jun-2015 11:07:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @patient_file_OpeningFcn, ...
    'gui_OutputFcn',  @patient_file_OutputFcn, ...
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


% --- Executes just before patient_file is made visible.
function patient_file_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to patient_file (see VARARGIN)

handles.ancest = varargin{1};
handles.currentDir = pwd;
handles.patientDir = handles.ancest.dataPath;
handles.list_of_data = cell(0);
handles.timeline_string = cell(0);
handles.timeline_indices = [];
try
    timeline_logo = imread('timeline_logo.png');
    axes(handles.timeline_logo);
    imshow(timeline_logo);
catch
end
if(exist(fullfile(handles.patientDir,'reggui_patient_file.mat'),'file'))
    try
        input = load(fullfile(handles.patientDir,'reggui_patient_file.mat'));
        handles.list_of_data = input.output;
    catch
    end
else
    handles.list_of_data = listing_dicom_data(handles.patientDir,get(handles.set_unique_patientID,'Value'),handles.list_of_data);
    cd(handles.currentDir)
end
N = 16; % number of elements in the data list
if(size(handles.list_of_data,2)<N)
    handles.list_of_data(:,end+1:N) = cell(size(handles.list_of_data,1),N-size(handles.list_of_data,2));
end
[handles,legend_txt] = patient_file_update_txt(handles);
try
    set(handles.legend_txt,'String',legend_txt);
    set(handles.legend_txt,'Value',1);
    set(handles.legend_txt,'ListboxTop',2);
catch
end
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = patient_file_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.ancest;
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function timeline_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function legend_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Quit_button.
function Quit_button_Callback(hObject, eventdata, handles)
cd(handles.patientDir)
output = handles.list_of_data;
save reggui_patient_file.mat output
cd(handles.currentDir)
uiresume(handles.figure1);


% --- Executes on selection change in legend_txt.
function legend_txt_Callback(hObject, eventdata, handles)
try
    set(handles.legend_txt,'Value',1);
    set(handles.legend_txt,'ListboxTop',2);
catch
end
guidata(hObject, handles);


% --- Executes on selection change in timeline.
function timeline_Callback(hObject, eventdata, handles)
handles = patient_file_update_txt(handles,0);
guidata(hObject, handles);


% --- Executes on button press in Update_button.
function Update_button_Callback(hObject, eventdata, handles)
handles.list_of_data = listing_dicom_data(handles.patientDir,get(handles.set_unique_patientID,'Value'),handles.list_of_data);
cd(handles.currentDir)
handles = patient_file_update_txt(handles);
guidata(hObject, handles);



% --- Executes on button press in Add_label_button.
function Add_label_button_Callback(hObject, eventdata, handles)
selected_line = get(handles.timeline,'Value')+1;
default_label{1} = '';
if(handles.timeline_indices(selected_line(1)) && length(selected_line)<2)
    if(isempty(handles.list_of_data{handles.timeline_indices(selected_line(1)),1}))
        default_label{1} = '';
    else
        default_label{1} = handles.list_of_data{handles.timeline_indices(selected_line(1)),1};
    end
    label = char(inputdlg({['Choose a label for ',handles.list_of_data{handles.timeline_indices(selected_line(1)),4}]},' ',1,default_label));
    handles.list_of_data{handles.timeline_indices(selected_line(1)),1} = label;
else
    disp('Wrong selection.');
    return
end
handles = patient_file_update_txt(handles);
guidata(hObject, handles);



% --- Executes on button press in Dicom_button.
function Dicom_button_Callback(hObject, eventdata, handles)
selected_line = get(handles.timeline,'Value')+1;
if(handles.timeline_indices(selected_line(1)) && length(selected_line)<2)
    evalin('base',['header = dicominfo(''',handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4},'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),5},''')']);
else
    disp('Wrong selection.');
    return
end
cd(handles.patientDir)
output = handles.list_of_data;
save reggui_patient_file.mat output
cd(handles.currentDir)
uiresume(handles.figure1);



% --- Executes on button press in Edit_dicom_button.
function Edit_dicom_button_Callback(hObject, eventdata, handles)
selected_line = get(handles.timeline,'Value')+1;
if(handles.timeline_indices(selected_line(1)) && length(selected_line)<2)
    filename = [handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4},'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),5}];
    sel_info = dicominfo(filename);
    fn = fieldnames(sel_info);
    f = cell(0);
    t = [];
    for i=1:length(fn)
        if(ischar(sel_info.(fn{i})))
            f{length(f)+1} = fn{i};
            t(length(f)) = 0;
        elseif(isnumeric(sel_info.(fn{i})) && length(sel_info.(fn{i}))==1)
            f{length(f)+1} = fn{i};
            t(length(f)) = 1;
        end
    end
    if(strcmp(sel_info.Modality,'RTSTRUCT'))
        newUID = inputdlg('Set SeriesInstanceUID of reference image','Reference image',1,{sel_info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID});
        Reference_SeriesInstanceUID = newUID{1};
    end
    [selection,Ok] = listdlg('ListString',f,'SelectionMode','single');
    if(Ok)
        tag_names{1} = f{selection};
        tag_type(1) = t(selection);
        if(strcmp(tag_names{1},'PatientID'))
            selection = questdlg('Do you want to anonymize the whole patient file?',...
                'Close Request Function',...
                'Yes','No','No');
            if(strcmp(selection,'Yes'))
                ID = inputdlg('New ID','Anonymize',1);
                first_name = inputdlg('New first name','Anonymize',1);
                last_name = inputdlg('New last name','Anonymize',1);
                handles = anonymize(handles,ID{1},first_name{1},last_name{1});
                guidata(hObject, handles);
                return
            end
        end
        if(tag_type(1)==1) % if numeric tag value
            new_tag_values = cell(0);
            new_tag_string = inputdlg(tag_names{1},'New tag value',1,{num2str(sel_info.(tag_names{1}))});
            if(isempty(new_tag_string{1}))
                new_tag_values{1} = [];
            else
                new_tag_values{1} = str2double(new_tag_string{1});
            end
        else % if string tag value
            new_tag_values = inputdlg(tag_names{1},'New tag value',1,{sel_info.(tag_names{1})});
        end
        if(length(new_tag_values)>0)
            if(strcmp(sel_info.Modality,'RTSTRUCT'))
                modify_dicom_tags([handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4}],tag_names,new_tag_values,sel_info,Reference_SeriesInstanceUID);
            else
                modify_dicom_tags([handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4}],tag_names,new_tag_values,sel_info);
            end
        end
    end
else
    disp('Wrong selection.');
    cd(handles.patientDir)
    return
end
cd(handles.patientDir)

% -----------------------
function h = modify_dicom_tags(dicom_dir,tag_names,new_tag_values,sel_info,Reference_SeriesInstanceUID)
current_dir = pwd;
cd(dicom_dir)
d = dir();
if(nargin<4)
    sel_info = [];
end
for i=3:length(d)
    try
        h = dicominfo(d(i).name);
    catch
        h = [];
    end
    check_uids = not(isempty(sel_info));
    if(check_uids)
        check_uids = ~strcmp(h.SeriesInstanceUID,sel_info.SeriesInstanceUID) || ...
            ~strcmp(h.StudyInstanceUID,sel_info.StudyInstanceUID) || ...
            ~strcmp(h.SOPClassUID,sel_info.SOPClassUID);
    end
    if(isempty(h))
        disp(['File ',d(i).name,' is not in Dicom format! Skip...']);
    elseif(check_uids)
        disp(['File ',d(i).name,' has not the same UIDs! Skip...']);
    else
        g = dicomread(d(i).name);
        for j=1:length(tag_names)
            if(isempty(new_tag_values{j}) && isfield(h,tag_names{j}))
                h = rmfield(h,tag_names{j});
            else
                h.(tag_names{j}) = new_tag_values{j};
            end
        end
        if(not(isempty(sel_info)))
            if(nargin>5 && strcmp(sel_info.Modality,'RTSTRUCT'))
                h.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = Reference_SeriesInstanceUID;
            elseif isDoseOrDoseRate(sel_info.Modality)
              %(strcmp(sel_info.Modality,'RTDOSE'))
                break;
            end
        end
        try
            dicomwrite(g,d(i).name,h,'CreateMode','copy');
        catch
            disp(['Impossible to export dicom data (',d(i).name,')'])
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
end
cd(current_dir)

% -----------------------
function handles = anonymize(handles,ID,first_name,last_name)
handles.list_of_data = listing_dicom_data(handles.patientDir,get(handles.set_unique_patientID,'Value'),handles.list_of_data);
tag_names = cell(0);
new_tag_values = cell(0);
patient_name = struct;
patient_name.FamilyName = last_name;
patient_name.GivenName = first_name;
tag_names{length(tag_names)+1} = 'PatientID';new_tag_values{length(tag_names)} = ID;
tag_names{length(tag_names)+1} = 'PatientName';new_tag_values{length(tag_names)} = patient_name;
current_date = datevec(date);
current_date = [num2str(current_date(1)),num2str(current_date(2)),num2str(current_date(3))];
tag_names{length(tag_names)+1} = 'PatientBirthDate';new_tag_values{length(tag_names)} = current_date;
list_of_dir = cell(0);
for i=1:size(handles.list_of_data,1)
list_of_dir{i} = handles.list_of_data{i,4};
end
list_of_dir = unique(list_of_dir);
w = waitbar(0,'Anonymizing...');
for i=1:length(list_of_dir)
    dicom_dir = fullfile(handles.patientDir,list_of_dir{i});
    disp(dicom_dir)
    modify_dicom_tags(dicom_dir,tag_names,new_tag_values);
    waitbar(i/size(handles.list_of_data,1),w);
end
close(w);
handles.list_of_data = listing_dicom_data(handles.patientDir,get(handles.set_unique_patientID,'Value'));
cd(handles.currentDir)
handles = patient_file_update_txt(handles);


% --- Executes on button press in Import_to_reggui_button.
function Import_to_reggui_button_Callback(hObject, eventdata, handles)
% list of already imported data (uids)
available_uids = cell(0);
for i=1:length(handles.ancest.images.name)
    if(isfield(handles.ancest.images.info{i},'SeriesInstanceUID'))
        available_uids{i} = handles.ancest.images.info{i}.SeriesInstanceUID;
    end
end
% import instructions
selected_lines = get(handles.timeline,'Value')+1;
imported_data=0;
for i=1:length(selected_lines)
    selected_line = selected_lines(i);
    if(handles.timeline_indices(selected_line))
        switch handles.list_of_data{handles.timeline_indices(selected_line),8}
            case 'RTSTRUCT'
                import_contour = 0;
                refImageName = '';
                reference_index = find(strcmp(handles.list_of_data{handles.timeline_indices(selected_line),12},available_uids));
                if(not(isempty(reference_index)))
                    refImageName = handles.ancest.images.name{reference_index(end)};
                    import_contour = 1;
                else
                    for j=1:size(handles.list_of_data,1)
                        if(sum(strcmp(handles.list_of_data{j,8},{'CT','PT'})) && strcmp(handles.list_of_data{handles.timeline_indices(selected_line),12},handles.list_of_data{j,12}))
                            myImageDir = [handles.patientDir,'/',handles.list_of_data{j,4},'/'];
                            myImageFilename = handles.list_of_data{j,5};
                            refImageName = handles.list_of_data{j,4};
                            rep_index = strfind(refImageName,'/');
                            if(not(isempty(rep_index)))
                                refImageName = refImageName(rep_index(end)+1:end);
                            end
                            refImageName = remove_bad_chars(refImageName);
                            if(not(sum(strcmp(handles.ancest.instructions,['handles = Import_image(''',myImageDir,''',''',myImageFilename,''',1, ''',refImageName,''',handles);']))))
                                handles.ancest.instructions{length(handles.ancest.instructions)+1} = ['handles = Import_image(''',myImageDir,''',''',myImageFilename,''',1, ''',refImageName,''',handles);'];
                            end
                            import_contour = 1;
                            break
                        end
                    end
                end
                if(import_contour)
                    myContourDir = [handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4},'/'];
                    myContourFilename = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                    eval(['contoursAvailable = ',strrep(strrep(strrep(handles.list_of_data{handles.timeline_indices(selected_line),15},' , ',''';'''),'{','{'''),'}','''}'),';']);
                    [selectedContours,OK] = listdlg('PromptString','Select contour(s):',...
                        'SelectionMode','multiple',...
                        'ListString',contoursAvailable);
                    if OK==0
                        disp('Wrong selection')
                        return
                    end
                    handles.ancest.instructions{length(handles.ancest.instructions)+1} = ['handles = Import_contour(''',fullfile(myContourDir,myContourFilename),''',[',num2str(selectedContours),'],''',refImageName,''',1,handles);'];
                else
                    disp('The image referred by this rt-struct cannot be found. Abort contour import.');
                end
            case 'REG'
                myFieldDir = [handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4},'/'];
                myFieldFilename = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                myFieldName = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                myFieldName = remove_bad_chars(myFieldName);
                handles.ancest.instructions{length(handles.ancest.instructions)+1} = ['handles = Import_field(''',myFieldDir,''',''',myFieldFilename,''',1, ''',myFieldName,''',handles);'];
            case {'RTDOSE','RTDOSERATE'}
                myImageDir = [handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4},'/'];
                myImageFilename = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                myImageName = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                myImageName = remove_bad_chars(myImageName);
                handles.ancest.instructions{length(handles.ancest.instructions)+1} = ['handles = Import_image(''',myImageDir,''',''',myImageFilename,''',1, ''',myImageName,''',handles);'];
            case 'RTPLAN'
                myPlanDir = [handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4},'/'];
                myPlanFilename = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                myPlanName = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                myPlanName = remove_bad_chars(myPlanName);
                handles.ancest.instructions{length(handles.ancest.instructions)+1} = ['handles = Import_plan(''',myPlanDir,''',''',myPlanFilename,''',1, ''',myPlanName,''',handles);'];
            otherwise
                myImageDir = [handles.patientDir,'/',handles.list_of_data{handles.timeline_indices(selected_line(1)),4},'/'];
                myImageFilename = handles.list_of_data{handles.timeline_indices(selected_line(1)),5};
                myImageName = handles.list_of_data{handles.timeline_indices(selected_line(1)),4};
                rep_index = strfind(myImageName,'/');
                if(not(isempty(rep_index)))
                    myImageName = myImageName(rep_index(end)+1:end);
                end
                myImageName = remove_bad_chars(myImageName);
                handles.ancest.instructions{length(handles.ancest.instructions)+1} = ['handles = Import_image(''',myImageDir,''',''',myImageFilename,''',1, ''',myImageName,''',handles);'];
        end
        imported_data = imported_data +1;
    end
end
if(imported_data)
    guidata(hObject, handles);
    cd(handles.patientDir)
    output = handles.list_of_data;
    save reggui_patient_file.mat output
    cd(handles.currentDir)
    uiresume(handles.figure1);
else
    disp('Wrong selection')
    return
end


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
input = load(fullfile(handles.patientDir,'reggui_patient_file.mat'));
handles.list_of_data = input.output;
guidata(hObject, handles);
% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
cd(handles.patientDir)
output = handles.list_of_data;
save reggui_patient_file.mat output
cd(handles.currentDir)


% --------------------------------------------------------------------
function sort_by_time_Callback(hObject, eventdata, handles)
handles = patient_file_update_txt(handles);
set(handles.timeline,'Value',1);
guidata(hObject, handles);


% --------------------------------------------------------------------
function set_unique_patientID_Callback(hObject, eventdata, handles)
if(get(handles.set_unique_patientID,'Value'))
    set(handles.patient_name_id,'Visible','on');
    set(handles.text1,'String','Patient :');
else
    set(handles.patient_name_id,'Visible','off');
    set(handles.text1,'String','(any uid)');
end
handles.list_of_data = listing_dicom_data(handles.patientDir,get(handles.set_unique_patientID,'Value'),handles.list_of_data);
cd(handles.currentDir)
handles = patient_file_update_txt(handles);
guidata(hObject, handles);
