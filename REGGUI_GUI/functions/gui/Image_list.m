function [myString,myDataType,myDataIndex,myInstructions] = Image_list(handles,myTitle,defaultDataType,multi_selection,data_convert)

% Authors : G.Janssens

%% Use system background color for GUI components
panelColor = get(0,'DefaultUicontrolBackgroundColor');
myString = [];
myDataType = 1;
myDataIndex = 1;
myInstructions = cell(0);

Image_list = handles.images.name;
Field_list = handles.fields.name;
Data_list = handles.mydata.name;
Plan_list = handles.plans.name;
Mesh_list = handles.meshes.name;
Reg_list = handles.registrations.name;
Indic_list = handles.indicators.name;

if(nargin<3)
    defaultDataType = 1;
end
if(nargin<4)
    multi_selection = 0;
end
if(nargin<5)
    data_convert = 0;
end

%% ------------ Callback Functions ---------------

% Figure resize function
    function figResize(src,evt)
        fpos = get(f,'Position');
        set(botPanel,'Position',...
            [1 1/20 fpos(3) fpos(4)*8/35])
        set(rightPanel,'Position',...
            [1 fpos(4)*8/35 fpos(3) fpos(4)*27/35])
    end

% Bottom panel resize function
    function botPanelResize(src, evt)
        bpos = get(botPanel,'Position');
        set(selectButton,'Position',...
            [bpos(3)*10/120 bpos(4)*2/8 bpos(3)*15/120 2])
        if(data_convert)
            set(convertButton,'Position',...
                [bpos(3)*50/120 bpos(4)*2/8 bpos(3)*25/120 2])
            set(deleteButton,'Position',...
                [bpos(3)*30/120 bpos(4)*2/8 bpos(3)*15/120 2])
        end
        set(popUp,'Position',...
            [bpos(3)*80/120 bpos(4)*2/8 bpos(3)*24/120 2])
        set(popUpLabel,'Position',...
            [bpos(3)*80/120 bpos(4)*4/8 bpos(3)*24/120 2])
    end

% Right panel resize function
    function rightPanelResize(src,evt)
        rpos = get(rightPanel,'Position');
        set(listBox,'Position',...
            [rpos(3)*4/32 rpos(4)*2/27 rpos(3)*24/32 rpos(4)*20/27]);
        set(listBoxLabel,'Position',...
            [rpos(3)*4/32 rpos(4)*24/27 rpos(3)*24/32 rpos(4)*2/27]);
    end

%% Callback for list box
    function listBoxCallback(src,evt)
        selected_cmd = get(popUp,'Value');
        switch selected_cmd
            case 1
                set(src,'String',Image_list);
            case 2
                set(src,'String',Field_list);
            case 3
                set(src,'String',Data_list);
            case 4
                set(src,'String',Plan_list);
            case 5
                set(src,'String',Mesh_list);
            case 6
                set(src,'String',Reg_list);
            case 7
                set(src,'String',Indic_list);
        end
    end % listBoxCallback

%% Callback for popup

    function popupCallback(src,evt)
        selected_cmd = get(popUp,'Value');
        switch selected_cmd
            case 1
                set(listBox,'Value',1);
                set(listBox,'String',Image_list);
                if(data_convert)
                    set(convertButton,'String','Copy in Data-store');
                    set(convertButton,'Visible','on');
                end
            case 2
                set(listBox,'Value',1);
                set(listBox,'String',Field_list);
                if(data_convert)
                    set(convertButton,'String','Copy in Data-store');
                    set(convertButton,'Visible','on');
                end
            case 3
                set(listBox,'Value',1);
                set(listBox,'String',Data_list);
                if(data_convert)
                    set(convertButton,'String','Convert to workspace');
                    set(convertButton,'Visible','on');
                end
            case 4
                set(listBox,'Value',1);
                set(listBox,'String',Plan_list);
                if(data_convert)
                    set(convertButton,'Visible','off');
                end
            case 5
                set(listBox,'Value',1);
                set(listBox,'String',Mesh_list);
                if(data_convert)
                    set(convertButton,'String','Convert to binary mask');
                    set(convertButton,'Visible','on');
                end
            case 6
                set(listBox,'Value',1);
                set(listBox,'String',Reg_list);
                if(data_convert)
                    set(convertButton,'Visible','off');
                end
            case 7
                set(listBox,'Value',1);
                set(listBox,'String',Indic_list);
                if(data_convert)
                    set(convertButton,'Visible','off');
                end
        end
    end

%% Callback for select button
    function selectButtonCallback(src,evt)
        myString_full = get(listBox,'String');
        myDataIndex = get(listBox,'Value');
        if(multi_selection)
            myString = cell(0);
            for i=1:length(myDataIndex)
                myString{i} = myString_full{myDataIndex(i)};
            end
        else
            myString = myString_full{myDataIndex};
        end
        myDataType = get(popUp,'Value');
        delete(f);
        return
    end % selectButtonCallback

%% Callback for convert button
    function convertButtonCallback(src,evt)
        myString_full = get(listBox,'String');
        myDataIndex = get(listBox,'Value');
        myDataType = get(popUp,'Value');
        switch(myDataType)
            case 1
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Image2data(''' myString_full{myDataIndex(i)} ''',[],[],[],''' myString_full{myDataIndex(i)} '_data'',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Image2data(''' myString_full{myDataIndex} ''',[],[],[],''' myString_full{myDataIndex} '_data'',handles);'];
                end
            case 2
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Field2data(''' myString_full{myDataIndex(i)} ''',[],[],[],''' myString_full{myDataIndex(i)} '_data'',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Field2data(''' myString_full{myDataIndex} ''',[],[],[],''' myString_full{myDataIndex} '_data'',handles);'];
                end
            case 3
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            if(strcmp(handles.mydata.info{myDataIndex(i)}.Type,'deformation_field') || strcmp(handles.mydata.info{myDataIndex(i)}.Type,'rigid_transform'))
                                myInstructions{i} = ['handles = Data2field(''' myString_full{myDataIndex(i)} ''',''' myString_full{myDataIndex(i)} '_wksp'',handles);'];
                            else
                                myInstructions{i} = ['handles = Data2image(''' myString_full{myDataIndex(i)} ''',''' myString_full{myDataIndex(i)} '_wksp'',handles);'];
                            end
                        end
                    end
                else
                    if(strcmp(handles.mydata.info{myDataIndex}.Type,'deformation_field') || strcmp(handles.mydata.info{myDataIndex}.Type,'rigid_transform'))
                        myInstructions{1} = ['handles = Data2field(''' myString_full{myDataIndex} ''',''' myString_full{myDataIndex} '_wksp'',handles);'];
                    else
                        myInstructions{1} = ['handles = Data2image(''' myString_full{myDataIndex} ''',''' myString_full{myDataIndex} '_wksp'',handles);'];
                    end
                end
        end
        delete(f);
        return
    end % selectButtonCallback

%% Callback for delete button
    function deleteButtonCallback(src,evt)
        myString_full = get(listBox,'String');
        myDataIndex = get(listBox,'Value');
        myDataType = get(popUp,'Value');
        switch(myDataType)
            case 1
                if(multi_selection)
                    if(length(myDataIndex)>=length(myString_full)-1)
                        myInstructions{1} = ['handles = Remove_all_images(handles,1);'];
                    else
                        for i=1:length(myDataIndex)
                            if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                                myInstructions{i} = ['handles = Remove_image(''' myString_full{myDataIndex(i)} ''',handles);'];
                            end
                        end
                    end
                else
                    myInstructions{1} = ['handles = Remove_image(''' myString_full{myDataIndex} ''',handles);'];
                end
            case 2
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Remove_field(''' myString_full{myDataIndex(i)} ''',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Remove_field(''' myString_full{myDataIndex} ''',handles);'];
                end
            case 3
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Remove_data(''' myString_full{myDataIndex(i)} ''',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Remove_data(''' myString_full{myDataIndex} ''',handles);'];
                end
            case 4
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Remove_plan(''' myString_full{myDataIndex(i)} ''',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Remove_plan(''' myString_full{myDataIndex} ''',handles);'];
                end
            case 5
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Remove_mesh(''' myString_full{myDataIndex(i)} ''',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Remove_mesh(''' myString_full{myDataIndex} ''',handles);'];
                end
            case 6
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Remove_reg(''' myString_full{myDataIndex(i)} ''',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Remove_reg(''' myString_full{myDataIndex} ''',handles);'];
                end
            case 7
                if(multi_selection)
                    for i=1:length(myDataIndex)
                        if(not(strcmp(myString_full{myDataIndex(i)},'none')))
                            myInstructions{i} = ['handles = Remove_indicators(''' myString_full{myDataIndex(i)} ''',handles);'];
                        end
                    end
                else
                    myInstructions{1} = ['handles = Remove_indicators(''' myString_full{myDataIndex} ''',handles);'];
                end
        end
        delete(f);
        return
    end % selectDeleteCallback


%% ------------ GUI layout ---------------

%% Set up the figure and defaults
f = figure('Units','characters',...
    'Position',[30 30 120 35],...
    'Color',panelColor,...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name','Image_list',...
    'Visible','off',...
    'ResizeFcn',@figResize);

%% Create the bottom uipanel
botPanel = uipanel('BorderType','etchedin',...
    'BackgroundColor',panelColor,...
    'Units','characters',...
    'Position',[1 1.5 120 8],...
    'Parent',f,...
    'ResizeFcn',@botPanelResize);

%% Create the right side panel
rightPanel = uipanel('bordertype','etchedin',...
    'BackgroundColor',panelColor,...
    'Units','characters',...
    'Position',[1 1 32 27],...
    'Parent',f,...
    'ResizeFcn',@rightPanelResize);

%% Add listbox and label
listBoxLabel = uicontrol(f,'Style','text','Units','characters',...
    'Position',[4 24 24 2],...
    'String',myTitle,...
    'FontSize',14,...
    'BackgroundColor',panelColor,...
    'Parent',rightPanel);
listBox = uicontrol(f,'Style','listbox','Units','characters',...
    'Position',[4 2 24 20],...
    'BackgroundColor','white',...
    'Max',100,'Min',1,...
    'Parent',rightPanel,...
    'Callback',@listBoxCallback);

%% Add popup and label
popUpLabel = uicontrol(f,'Style','text','Units','characters',...
    'Position',[80 4 24 2],...
    'String','Data type',...
    'BackgroundColor',panelColor,...
    'Parent',botPanel);
popUp = uicontrol(f,'Style','popupmenu','Units','characters',...
    'Position',[80 2 24 2],...
    'BackgroundColor','white',...
    'String',{'Image','Field','Data','Plan','Mesh','Registration','Indicators'},...
    'Value',defaultDataType,...
    'Parent',botPanel,...
    'Callback',@popupCallback);

%% Add buttons
selectButton = uicontrol(f,'Style','pushbutton','Units','characters',...
    'Position',[5 2 15 2],...
    'String','Select',...
    'BackgroundColor',[1.0,1.0,1.0],...
    'Parent',botPanel,...
    'Callback',@selectButtonCallback);

if(data_convert)
    convertButton = uicontrol(f,'Style','pushbutton','Units','characters',...
        'Position',[25 2 25 2],...
        'String','Copy in Data-store',...
        'BackgroundColor',[0.9,0.8,0.9],...
        'Parent',botPanel,...
        'Callback',@convertButtonCallback);
    if(myDataType<=3)
        set(convertButton,'Visible','on');
    else
        set(convertButton,'Visible','off');
    end
    deleteButton = uicontrol(f,'Style','pushbutton','Units','characters',...
        'Position',[55 2 15 2],...
        'String','Remove',...
        'BackgroundColor',[0.9,0.8,0.9],...
        'Parent',botPanel,...
        'Callback',@deleteButtonCallback);
    if(myDataType<=3)
        set(deleteButton,'Visible','on');
    else
        set(deleteButton,'Visible','off');
    end
end

%% Initialize list box and make sure
% the hold toggle is set correctly
listBoxCallback(listBox,[])
uiwait(f);

end % uipanel1




