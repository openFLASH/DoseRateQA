function varargout = image_viewer(varargin)
% IMAGE_VIEWER M-file for image_viewer.fig
%      IMAGE_VIEWER, by itself, creates a new IMAGE_VIEWER or raises the existing
%      singleton*.
%
%      H = IMAGE_VIEWER returns the handle to a new IMAGE_VIEWER or the handle to
%      the existing singleton*.
%
%      IMAGE_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_VIEWER.M with the given input arguments.
%
%      IMAGE_VIEWER('Property','Value',...) creates a new IMAGE_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_viewer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Authors : G.Janssens

% Edit the above text to modify the response to help image_viewer

% Last Modified by GUIDE v2.5 04-Apr-2012 18:03:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @image_viewer_OpeningFcn, ...
    'gui_OutputFcn',  @image_viewer_OutputFcn, ...
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


% --- Executes just before image_viewer is made visible.
function image_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_viewer (see VARARGIN)

handles.image = single(varargin{1});
handles.info = varargin{2};
if(nargin>5)
    handles.output_type = varargin{3};
else
    handles.output_type = 'point';
end
handles.output = '[]';
try
    handles.size(1) = size(handles.image,1);
    handles.size(2) = size(handles.image,2);
    handles.size(3) = size(handles.image,3);
    if(nargin>6)
        handles.point = varargin{4};
    else
        handles.point = [round(handles.size(1)/2) round(handles.size(2)/2) round(handles.size(3)/2)];
    end
    handles.minscale = min(min(min(handles.image)));
    handles.maxscale = max(max(max(handles.image)));
    handles.max = handles.maxscale;
    handles.spacing = handles.info.Spacing;
    handles.origin = handles.info.ImagePositionPatient;
    if(strcmp(handles.output_type,'mask'))
        set(handles.create_mask_button,'Visible','on');
        set(handles.undo_button,'Visible','on');
        set(handles.fill_button,'Visible','on');
        set(handles.reset_button,'Visible','on');
        set(handles.slider3,'Visible','on');
        set(handles.slider4,'Visible','on');
        set(handles.threshold,'Visible','on');
        handles.mask = zeros(size(handles.image));
        handles.mask_temp = zeros(size(handles.image));
        handles.contour = cell(3,1);
        handles.contour_temp = [];
        handles.image_temp = handles.image;
        handles.image_init = handles.image;
        if(nargin>7)
            if(~sum(size(varargin{5})~=size(handles.image)))
                handles.mask = varargin{5};
                handles.image(find(handles.mask)) = handles.max;
            end
        end
    elseif(strcmp(handles.output_type,'box'))
        set(handles.exit_button,'String','Create box');
        set(handles.create_mask_button,'String','Select corners');
        set(handles.create_mask_button,'Visible','on');
        handles.box = zeros(size(handles.image));
        handles.minimum = [1;1;1];
        handles.maximum = size(handles.image)';
        handles.minscale = handles.minscale - abs(handles.maxscale-handles.minscale)/5;
        if(nargin>7)
            if(~sum(size(varargin{5})~=size(handles.image)))
                [i,j] = find(varargin{5});
                [j,k] = ind2sub([handles.size(2) handles.size(3)],j);
                handles.minimum = [max(1,min(i));max(1,min(j));max(1,min(k))];
                handles.maximum = [min(handles.size(1),max(i));min(handles.size(2),max(j));min(handles.size(3),max(k))];
                %handles.box(handles.minimum(1):handles.maximum(1),handles.minimum(2):handles.maximum(2),handles.minimum(3):handles.maximum(3)) = 1;
                handles.box = varargin{5};
            end
        end
    elseif(strcmp(handles.output_type,'contour_validation'))
        set(handles.exit_button,'String','True detection');
        set(handles.reset_button,'String','False detection');
        set(handles.reset_button,'Visible','on');
        handles.mask = zeros(size(handles.image));
        handles.mask_temp = zeros(size(handles.image));
        handles.contour = cell(3,1);
        handles.contour_temp = [];
        handles.image_temp = handles.image;
        handles.image_init = handles.image;
        if(nargin>7)
            if(~sum(size(varargin{5})~=size(handles.image)))
                handles.mask = varargin{5};
                handles.image(handles.mask>=0.5) = handles.max;
            end
        end
    end
    set(handles.text1,'String',['[' num2str(handles.point(1)) ' ' num2str(handles.point(2)) ' ' num2str(handles.point(3)) ']']);
    set(handles.text2,'String',['[' num2str(handles.origin(1)+(handles.point(1)-1)*handles.spacing(1)) ' ' num2str(handles.origin(2)+(handles.point(2)-1)*handles.spacing(2)) ' ' num2str(handles.origin(3)+(handles.point(3)-1)*handles.spacing(3)) ']']);
    set(handles.edit1,'String',['[' num2str(handles.minscale) ' ' num2str(handles.maxscale) ']']);
    set(handles.popupmenu1,'Value',3);
    set(handles.slider1,'Value',max(0,(handles.point(3)-0.9)/handles.size(3)));
    Plot_image(handles);
    guidata(hObject, handles);
    uiwait(handles.figure1);
catch
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    guidata(hObject, handles);
    uiresume(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = image_viewer_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
if(strcmp(handles.output_type,'box'))
    varargout{2} = handles.minimum;
    varargout{3} = handles.maximum;
end
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function colormap_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function viewer_zoom_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% ---------------------------------------------------------------------


% ---------------------------------------------------------------------
function exit_button_Callback(hObject, eventdata, handles)
if(strcmp(handles.output_type,'mask'))
    if( (sum(sum(sum(handles.mask)))==0) && (not(get(handles.slider3,'Value')==0) || not(get(handles.slider4,'Value')==1)) )
        handles.mask = handles.mask + 1;
    end
    handles.output = handles.mask & (handles.image_init>=(get(handles.slider3,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init))))) & (handles.image_init<=(get(handles.slider4,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init)))));
elseif(strcmp(handles.output_type,'box'))
    handles.output = handles.box;
elseif(strcmp(handles.output_type,'contour_validation'))
    handles.output = 1;
else
    handles.output = get(handles.text1,'String');
end
guidata(hObject, handles);
uiresume(handles.figure1);
disp('Viewer closed');


% ---------------------------------------------------------------------
function handles = Plot_image(handles)
axes(handles.axes1);
cla(handles.axes1,'reset')
eval(['handles.point = ' get(handles.text1,'String') ';']);
current_view = get(handles.popupmenu1,'Value');
axe_BDF = get(gca,'ButtonDownFcn');
hold off;

switch current_view
    case 1
        current_slice = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(1)));
        myIm = ones(handles.size(3),handles.size(2));
        imshow(myIm,[0 1]);
        hold on
        if(not(isempty(handles.image)))
            myIm = squeeze(handles.image(current_slice,1:handles.size(2),1:handles.size(3)))';
        end
        imshow(myIm,[handles.minscale handles.maxscale]);
        s = get(handles.colormap,'String');
        s = s{get(handles.colormap,'Value')};
        if(strcmp(s,'inverse'))
            c = gray(64);
            c = c(end:-1:1,:);
            colormap(c);
        else
            colormap(s);
        end
        if(strcmp(handles.output_type,'mask'))
            %             image_init = squeeze(handles.image_init(current_slice,1:handles.size(2),1:handles.size(3)))';
            %             image_init = (image_init-handles.minscale)/handles.maxscale;
            %             image_init(find(image_init>1)) = 1;
            %             blue = cat(3,ones(size(image_init))*0.8,ones(size(image_init))*0.8,ones(size(image_init)));
            %             h = imshow(blue);
            %             set(h, 'AlphaData', image_init);
        elseif(strcmp(handles.output_type,'box'))
            %             box = 1-squeeze(handles.box(current_slice,1:handles.size(2),1:handles.size(3)))';
            %             green = cat(3,ones(size(myIm))*0.1,ones(size(myIm))*0.8,ones(size(myIm))*0.3);
            %             h = imshow(green);
            %             set(h, 'AlphaData', box/5);
            plot([1 handles.size(2)],[handles.minimum(3) handles.minimum(3)],'Color','b');
            plot([handles.minimum(2) handles.minimum(2)],[1 handles.size(3)],'Color','b');
            plot([1 handles.size(2)],[handles.maximum(3) handles.maximum(3)],'Color','b');
            plot([handles.maximum(2) handles.maximum(2)],[1 handles.size(3)],'Color','b');
        end
        plot(handles.point(2),handles.point(3),'yx','MarkerSize',8);
        if(not(get(handles.slider3,'Value')==0) || not(get(handles.slider4,'Value')==1))
            F = (myIm>=get(handles.slider3,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init)))) & (myIm<=get(handles.slider4,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init))));
            F_eroded = imerode(F,ones(3,3));
            F = F - F_eroded;
            [i,j] = find(F);
            eval(['plot(j,i,''g.'',''MarkerSize'',4);']);
        end
        if(get(handles.show_axis,'Value'))
            hold on
            plot([1 handles.size(2)],[handles.point(3) handles.point(3)],'Color','b');
            plot([handles.point(2) handles.point(2)],[1 handles.size(3)],'Color','b');
            hold off
        end
        daspect([handles.spacing(3) handles.spacing(2) 1]);
    case 2
        current_slice = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(2)));
        myIm = ones(handles.size(3),handles.size(1));
        imshow(myIm,[0 1]);
        hold on
        if(not(isempty(handles.image)))
            myIm = squeeze(handles.image(1:handles.size(1),current_slice,1:handles.size(3)))';
        end
        imshow(myIm,[handles.minscale handles.maxscale]);
        s = get(handles.colormap,'String');
        s = s{get(handles.colormap,'Value')};
        if(strcmp(s,'inverse'))
            c = gray(64);
            c = c(end:-1:1,:);
            colormap(c);
        else
            colormap(s);
        end
        if(strcmp(handles.output_type,'mask'))
            %             image_init = squeeze(handles.image_init(1:handles.size(1),current_slice,1:handles.size(3)))';
            %             image_init = (image_init-handles.minscale)/handles.maxscale;
            %             image_init(find(image_init>1)) = 1;
            %             blue = cat(3,ones(size(image_init))*0.8,ones(size(image_init))*0.8,ones(size(image_init)));
            %             h = imshow(blue);
            %             set(h, 'AlphaData', image_init);
        elseif(strcmp(handles.output_type,'box'))
            %             box = 1-squeeze(handles.box(1:handles.size(1),current_slice,1:handles.size(3)))';
            %             green = cat(3,ones(size(myIm))*0.1,ones(size(myIm))*0.8,ones(size(myIm))*0.3);
            %             h = imshow(green);
            %             set(h, 'AlphaData', box/5);
            plot([1 handles.size(1)],[handles.minimum(3) handles.minimum(3)],'Color','b');
            plot([handles.minimum(1) handles.minimum(1)],[1 handles.size(3)],'Color','b');
            plot([1 handles.size(1)],[handles.maximum(3) handles.maximum(3)],'Color','b');
            plot([handles.maximum(1) handles.maximum(1)],[1 handles.size(3)],'Color','b');
        end
        plot(handles.point(1),handles.point(3),'yx','MarkerSize',8);
        if(not(get(handles.slider3,'Value')==0) || not(get(handles.slider4,'Value')==1))
            F = (myIm>=get(handles.slider3,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init)))) & (myIm<=get(handles.slider4,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init))));
            F_eroded = imerode(F,ones(3,3));
            F = F - F_eroded;
            [i,j] = find(F);
            eval(['plot(j,i,''g.'',''MarkerSize'',4);']);
        end
        if(get(handles.show_axis,'Value'))
            hold on
            plot([1 handles.size(1)],[handles.point(3) handles.point(3)],'Color','b');
            plot([handles.point(1) handles.point(1)],[1 handles.size(3)],'Color','b');
            hold off
        end
        daspect([handles.spacing(3) handles.spacing(1) 1]);
    case 3
        current_slice = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(3)));
        myIm = ones(handles.size(2),handles.size(1));
        imshow(myIm,[0 1]);
        hold on
        if(not(isempty(handles.image)))
            myIm = squeeze(handles.image(1:handles.size(1),handles.size(2):-1:1,current_slice))';
        end
        imshow(myIm,[handles.minscale handles.maxscale]);
        s = get(handles.colormap,'String');
        s = s{get(handles.colormap,'Value')};
        if(strcmp(s,'inverse'))
            c = gray(64);
            c = c(end:-1:1,:);
            colormap(c);
        else
            colormap(s);
        end
        if(strcmp(handles.output_type,'mask'))
            %             image_init = squeeze(handles.image_init(1:handles.size(1),handles.size(2):-1:1,current_slice))';
            %             image_init = (image_init-handles.minscale)/handles.maxscale;
            %             image_init(find(image_init>1)) = 1;
            %             blue = cat(3,ones(size(image_init))*0.8,ones(size(image_init))*0.8,ones(size(image_init)));
            %             h = imshow(blue);
            %             set(h, 'AlphaData', image_init);
        elseif(strcmp(handles.output_type,'box'))
            %             box = 1-squeeze(handles.box(1:handles.size(1),handles.size(2):-1:1,current_slice))';
            %             green = cat(3,ones(size(myIm))*0.1,ones(size(myIm))*0.8,ones(size(myIm))*0.3);
            %             h = imagesc(green);
            %             set(h, 'AlphaData', box/5);
            plot([1 handles.size(1)],handles.size(2)-[handles.minimum(2) handles.minimum(2)]+1,'Color','b');
            plot([handles.minimum(1) handles.minimum(1)],[1 handles.size(2)],'Color','b');
            plot([1 handles.size(1)],handles.size(2)-[handles.maximum(2) handles.maximum(2)]+1,'Color','b');
            plot([handles.maximum(1) handles.maximum(1)],[1 handles.size(2)],'Color','b');
        end
        plot(handles.point(1),handles.size(2) - handles.point(2),'yx','MarkerSize',8);
        if(not(get(handles.slider3,'Value')==0) || not(get(handles.slider4,'Value')==1))
            F = (myIm>=get(handles.slider3,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init)))) & (myIm<=get(handles.slider4,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init))));
            F_eroded = imerode(F,ones(3,3));
            F = F - F_eroded;
            [i,j] = find(F);
            eval(['plot(j,i,''g.'',''MarkerSize'',4);']);
        end
        if(get(handles.show_axis,'Value'))
            hold on
            plot([1 handles.size(1)],handles.size(2)-[handles.point(2) handles.point(2)],'Color','b');
            plot([handles.point(1) handles.point(1)],[1 handles.size(2)],'Color','b');
            hold off
        end
        daspect([handles.spacing(2) handles.spacing(1) 1]);
end
axis xy;
handles.point(current_view) = current_slice;
set(handles.text1,'String',['[' num2str(handles.point(1)) ' ' num2str(handles.point(2)) ' ' num2str(handles.point(3)) ']']);
set(handles.text2,'String',['[' num2str(handles.origin(1)+(handles.point(1)-1)*handles.spacing(1)) ' ' num2str(handles.origin(2)+(handles.point(2)-1)*handles.spacing(2)) ' ' num2str(handles.origin(3)+(handles.point(3)-1)*handles.spacing(3)) ']']);
guidata(handles.axes1,handles);


% ---------------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)
bounds = [handles.minscale handles.maxscale];
try
    eval(['bounds = ' get(hObject,'String') ';']);
catch
end
handles.minscale = bounds(1);
handles.maxscale = bounds(2);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
if(strcmp(handles.output_type,'contour_validation'))
    handles.output = 0;
    guidata(hObject, handles);
    uiresume(handles.figure1);
    disp('Viewer closed');
else
    eval(['handles.point = ' get(handles.text1,'String') ';']);
    set(handles.edit1,'String',['[' num2str(min(min(min(handles.image)))) ' ' num2str(max(max(max(handles.image)))) ']']);
    handles.minscale = min(min(min(handles.image)));
    handles.maxscale = max(max(max(handles.image)));
    if(strcmp(handles.output_type,'mask'))
        handles.image = handles.image_init;
        handles.mask = zeros(size(handles.image));
        handles.contour = cell(3,1);
    end
    handles = Plot_image(handles);
    guidata(hObject, handles);
end

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
set(handles.threshold,'String',[num2str(get(handles.slider3,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init)))) ' - ' num2str(get(handles.slider4,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init))))]);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
set(handles.threshold,'String',[num2str(get(handles.slider3,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init)))) ' - ' num2str(get(handles.slider4,'Value')*(max(max(max(handles.image_init)))-min(min(min(handles.image_init))))+min(min(min(handles.image_init))))]);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
eval(['handles.point = ' get(handles.text1,'String') ';']);
Plot_image(handles);
guidata(hObject, handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
eval(['handles.point = ' get(handles.text1,'String') ';']);
current_view = get(hObject,'Value');
switch current_view
    case 1
        set(handles.slider1,'Value',min(1,max(0,(handles.point(current_view)-0.9)/handles.size(1))));
    case 2
        set(handles.slider1,'Value',min(1,max(0,(handles.point(current_view)-0.9)/handles.size(2))));
    case 3
        set(handles.slider1,'Value',min(1,max(0,(handles.point(current_view)-0.9)/handles.size(3))));
end
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in create_mask_button.
function create_mask_button_Callback(hObject, eventdata, handles)
if(strcmp(handles.output_type,'mask'))
    handles.mask_temp = handles.mask;
    handles.image_temp = handles.image;
    handles.contour_temp = handles.contour;
    current_view = get(handles.popupmenu1,'Value');
    switch current_view
        case 1
            pt = ginput(1);
            plot(pt(:,1),pt(:,2),'g');
            pt = [pt;ginput(1)];
            plot(pt(:,1),pt(:,2),'g');
            while (round(pt(end,1)/handles.size(2)*30)~=round(pt(1,1)/handles.size(2)*30) || round(pt(end,2)/handles.size(3)*30)~=round(pt(1,2)/handles.size(3)*30))
                pt = [pt;ginput(1)];
                plot(pt(:,1),pt(:,2),'g');
            end
            current_slice = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(1)));
            handles.mask(current_slice,1:handles.size(2),1:handles.size(3)) = squeeze(handles.mask(current_slice,1:handles.size(2),1:handles.size(3))) | poly2mask(pt(:,2),pt(:,1),handles.size(2),handles.size(3));
            %         handles.contour(current_slice,1:handles.size(2),1:handles.size(3)) = squeeze(handles.mask(current_slice,1:handles.size(2),1:handles.size(3))) - imerode(squeeze(handles.mask(current_slice,1:handles.size(2),1:handles.size(3))),ones(3));
            handles.image(current_slice,1:handles.size(2),1:handles.size(3)) = handles.mask(current_slice,1:handles.size(2),1:handles.size(3))*handles.max;
            handles.contour{1} = [handles.contour{1} current_slice];
        case 2
            pt = ginput(1);
            plot(pt(:,1),pt(:,2),'g');
            pt = [pt;ginput(1)];
            plot(pt(:,1),pt(:,2),'g');
            while (round(pt(end,1)/handles.size(1)*30)~=round(pt(1,1)/handles.size(1)*30) || round(pt(end,2)/handles.size(3)*30)~=round(pt(1,2)/handles.size(3)*30))
                pt = [pt;ginput(1)];
                plot(pt(:,1),pt(:,2),'g');
            end
            current_slice = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(2)));
            handles.mask(1:handles.size(1),current_slice,1:handles.size(3)) = squeeze(handles.mask(1:handles.size(1),current_slice,1:handles.size(3))) | poly2mask(pt(:,2),pt(:,1),handles.size(1),handles.size(3));
            %         handles.contour(1:handles.size(1),current_slice,1:handles.size(3)) = squeeze(handles.mask(1:handles.size(1),current_slice,1:handles.size(3))) - imerode(squeeze(handles.mask(1:handles.size(1),current_slice,1:handles.size(3))),ones(3));
            handles.image(1:handles.size(1),current_slice,1:handles.size(3)) = handles.mask(1:handles.size(1),current_slice,1:handles.size(3))*handles.max;
            handles.contour{2} = [handles.contour{2} current_slice];
        case 3
            pt = ginput(1);
            plot(pt(:,1),pt(:,2),'g');
            pt = [pt;ginput(1)];
            plot(pt(:,1),pt(:,2),'g');
            while (round(pt(end,1)/handles.size(1)*30)~=round(pt(1,1)/handles.size(1)*30) || round(pt(end,2)/handles.size(2)*30)~=round(pt(1,2)/handles.size(2)*30))
                pt = [pt;ginput(1)];
                plot(pt(:,1),pt(:,2),'g');
            end
            current_slice = max(1,ceil((get(handles.slider1,'Value')+0.001)/1.001*handles.size(3)));
            handles.mask(1:handles.size(1),handles.size(2):-1:1,current_slice) = handles.mask(1:handles.size(1),handles.size(2):-1:1,current_slice) | poly2mask(pt(:,2),pt(:,1),handles.size(1),handles.size(2));
            %         handles.contour(1:handles.size(1),handles.size(2):-1:1,current_slice) = handles.mask(1:handles.size(1),handles.size(2):-1:1,current_slice) - imerode(handles.mask(1:handles.size(1),handles.size(2):-1:1,current_slice),ones(3));
            handles.image(1:handles.size(1),handles.size(2):-1:1,current_slice) = handles.mask(1:handles.size(1),handles.size(2):-1:1,current_slice)*handles.max;
            handles.contour{3} = [handles.contour{3} current_slice];
    end
elseif(strcmp(handles.output_type,'box'))
    current_view = get(handles.popupmenu1,'Value');
    handles.box = zeros(size(handles.box),'single');
    switch current_view
        case 1
            pts = ginput(2);
            handles.minimum(2) = max(1,round(min(pts(:,1))));
            handles.minimum(3) = max(1,round(min(pts(:,2))));
            handles.maximum(2) = min(handles.size(2),round(max(pts(:,1))));
            handles.maximum(3) = min(handles.size(3),round(max(pts(:,2))));
        case 2
            pts = ginput(2);
            handles.minimum(1) = max(1,round(min(pts(:,1))));
            handles.minimum(3) = max(1,round(min(pts(:,2))));
            handles.maximum(1) = min(handles.size(1),round(max(pts(:,1))));
            handles.maximum(3) = min(handles.size(3),round(max(pts(:,2))));
        case 3
            pts = ginput(2);
            handles.minimum(1) = max(1,round(min(pts(:,1))));
            handles.minimum(2) = max(1,round(min(handles.size(2)-pts(:,2))));
            handles.maximum(1) = min(handles.size(1),round(max(pts(:,1))));
            handles.maximum(2) = min(handles.size(2),round(max(handles.size(2)-pts(:,2))));
    end
    handles.box(handles.minimum(1):handles.maximum(1),handles.minimum(2):handles.maximum(2),handles.minimum(3):handles.maximum(3)) = 1;
end
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in undo_button.
function undo_button_Callback(hObject, eventdata, handles)
if(strcmp(handles.output_type,'mask'))
    handles.image = handles.image_temp;
    handles.mask = handles.mask_temp;
    handles.contour = handles.contour_temp;
end
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in fill_button.
function fill_button_Callback(hObject, eventdata, handles)
if(strcmp(handles.output_type,'mask'))
    handles.mask_temp = handles.mask;
    handles.image_temp = handles.image;
    handles.contour_temp = handles.contour;
    current_view = get(handles.popupmenu1,'Value');
    switch current_view
        case 1
            slices1 = sort(handles.contour{2});
            slices2 = sort(handles.contour{3});
            for current_slice=1:handles.size(1)
                pt = [];
                for i=slices1
                    j = min(find(handles.mask(current_slice,i,:)));
                    if(~isempty(j))
                        pt = [pt;i j];
                    end
                end
                for j=slices2
                    i = max(find(handles.mask(current_slice,:,j)));
                    if(~isempty(i))
                        pt = [pt;i j];
                    end
                end
                for i=slices1(end:-1:1)
                    j = max(find(handles.mask(current_slice,i,:)));
                    if(~isempty(j))
                        pt = [pt;i j];
                    end
                end
                for j=slices2(end:-1:1)
                    i = min(find(handles.mask(current_slice,:,j)));
                    if(~isempty(i))
                        pt = [pt;i j];
                    end
                end
                if(size(pt,1)>2)
                    handles.mask(current_slice,1:handles.size(2),1:handles.size(3)) = squeeze(handles.mask(current_slice,1:handles.size(2),1:handles.size(3))) | poly2mask(pt(:,2),pt(:,1),handles.size(2),handles.size(3));
                    handles.mask(current_slice,1:handles.size(2),1:handles.size(3)) = imclose(squeeze(handles.mask(current_slice,1:handles.size(2),1:handles.size(3))),ones(3));
                end
            end
        case 2
            slices1 = sort(handles.contour{1});
            slices2 = sort(handles.contour{3});
            for current_slice=1:handles.size(2)
                pt = [];
                for i=slices1
                    j = min(find(handles.mask(i,current_slice,:)));
                    if(~isempty(j))
                        pt = [pt;i j];
                    end
                end
                for j=slices2
                    i = max(find(handles.mask(:,current_slice,j)));
                    if(~isempty(i))
                        pt = [pt;i j];
                    end
                end
                for i=slices1(end:-1:1)
                    j = max(find(handles.mask(i,current_slice,:)));
                    if(~isempty(j))
                        pt = [pt;i j];
                    end
                end
                for j=slices2(end:-1:1)
                    i = min(find(handles.mask(:,current_slice,j)));
                    if(~isempty(i))
                        pt = [pt;i j];
                    end
                end
                if(size(pt,1)>2)
                    handles.mask(1:handles.size(1),current_slice,1:handles.size(3)) = squeeze(handles.mask(1:handles.size(1),current_slice,1:handles.size(3))) | poly2mask(pt(:,2),pt(:,1),handles.size(1),handles.size(3));
                    handles.mask(1:handles.size(1),current_slice,1:handles.size(3)) = imclose(squeeze(handles.mask(1:handles.size(1),current_slice,1:handles.size(3))),ones(3));
                end
            end
        case 3
            slices1 = sort(handles.contour{1});
            slices2 = sort(handles.contour{2});
            for current_slice=1:handles.size(3)
                pt = [];
                for i=slices1
                    j = min(find(handles.mask(i,:,current_slice)));
                    if(~isempty(j))
                        pt = [pt;i j];
                    end
                end
                for j=slices2
                    i = max(find(handles.mask(:,j,current_slice)));
                    if(~isempty(i))
                        pt = [pt;i j];
                    end
                end
                for i=slices1(end:-1:1)
                    j = max(find(handles.mask(i,:,current_slice)));
                    if(~isempty(j))
                        pt = [pt;i j];
                    end
                end
                for j=slices2(end:-1:1)
                    i = min(find(handles.mask(:,j,current_slice)));
                    if(~isempty(i))
                        pt = [pt;i j];
                    end
                end
                if(size(pt,1)>2)
                    handles.mask(1:handles.size(1),1:handles.size(2),current_slice) = squeeze(handles.mask(1:handles.size(1),1:handles.size(2),current_slice)) | poly2mask(pt(:,2),pt(:,1),handles.size(1),handles.size(2));
                    handles.mask(1:handles.size(1),1:handles.size(2),current_slice) = imclose(squeeze(handles.mask(1:handles.size(1),1:handles.size(2),current_slice)),ones(3));
                end
            end
    end
    handles.image(find(handles.mask)) = handles.max;
end
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in choose_point_button.
function choose_point_button_Callback(hObject, eventdata, handles)
eval(['handles.point = ' get(handles.text1,'String') ';']);
pt = round(ginput(1));
current_view = get(handles.popupmenu1,'Value');
switch current_view
    case 1
        handles.point(2) = pt(1);
        handles.point(3) = pt(2);
    case 2
        handles.point(1) = pt(1);
        handles.point(3) = pt(2);
    case 3
        handles.point(1) = pt(1);
        handles.point(2) = handles.size(2) - pt(2);
end
set(handles.text1,'String',['[' num2str(handles.point(1)) ' ' num2str(handles.point(2)) ' ' num2str(handles.point(3)) ']']);
set(handles.text2,'String',['[' num2str(handles.origin(1)+(handles.point(1)-1)*handles.spacing(1)) ' ' num2str(handles.origin(2)+(handles.point(2)-1)*handles.spacing(2)) ' ' num2str(handles.origin(3)+(handles.point(3)-1)*handles.spacing(3)) ']']);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in button_less_brightness.
function button_less_brightness_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale+range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale+range/8,4,'round',2);
set(handles.edit1,'String',['[',num2str(handles.minscale),' ',num2str(handles.maxscale),']']);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in button_more_brightness.
function button_more_brightness_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale-range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale-range/8,4,'round',2);
set(handles.edit1,'String',['[',num2str(handles.minscale),' ',num2str(handles.maxscale),']']);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in button_less_contrast.
function button_less_contrast_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale-range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale+range/8,4,'round',2);
set(handles.edit1,'String',['[',num2str(handles.minscale),' ',num2str(handles.maxscale),']']);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in button_more_contrast.
function button_more_contrast_Callback(hObject, eventdata, handles)
range = abs(handles.maxscale-handles.minscale);
handles.minscale = roundsd(handles.minscale+range/8,4,'round',2);
handles.maxscale = roundsd(handles.maxscale-range/8,4,'round',2);
set(handles.edit1,'String',['[',num2str(handles.minscale),' ',num2str(handles.maxscale),']']);
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on button press in show_axis.
function show_axis_Callback(hObject, eventdata, handles)
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on selection change in colormap.
function colormap_Callback(hObject, eventdata, handles)
handles = Plot_image(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function viewer_zoom_Callback(hObject, eventdata, handles)
handles = Plot_image(handles);
guidata(hObject, handles);

