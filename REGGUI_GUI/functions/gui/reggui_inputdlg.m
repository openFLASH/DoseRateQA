function output = reggui_inputdlg(varargin)

% Authors : G.Janssens

%% Use system background color for GUI components
panelColor = get(0,'DefaultUicontrolBackgroundColor');

%% Get input tags and initial values
tag_list = cell(0);
values = cell(0);
if(length(varargin)==1)
    if(isstruct(varargin{1}))
        input = fieldnames(varargin{1});
        for i=1:length(input)
            tag_list{end+1} = input{i};
            value = varargin{1}.(input{i});
            if(isempty(value))
                values{end+1} = '';
            else
                if(iscell(value))
                    temp = '{';
                    for j=1:length(value)
                        if(isnumeric(value{j}))
                            temp = [temp,mat2str(value{j}),','];
                        else
                            temp = [temp,'''',value{j},''','];
                        end
                    end
                    temp = [temp(1:end-1),'}'];
                    values{end+1} = temp;
                else
                    if(isnumeric(value))
                        values{end+1} = mat2str(value);
                    else
                        values{end+1} = ['''',value,''''];
                    end
                end
            end
        end
    else
        disp('Wrong input')
        output = cell(0);
        return
    end
else
    for i=1:2:length(varargin)-1
        if(ischar(varargin{i}) && ischar(varargin{i+1}))
            tag_list{end+1} = varargin{i};
            values{end+1} = varargin{i+1};
        end
    end
end

%% ------------ Callback Functions ---------------

% Figure resize function
    function figResize(src,evt)
        fpos = get(f,'Position');
        set(rightPanel,'Position',...
            [fpos(3)*1/150 fpos(4)*4/30 fpos(3)*148/150 fpos(4)*25/30])
        set(selectButton,'Position',...
            [fpos(3)*115/150 fpos(4)*1/30 fpos(3)*30/150 fpos(4)*2/30])
    end

% Right panel resize function
    function rightPanelResize(src,evt)
        rpos = get(rightPanel,'Position');
        for t=1:length(Tags)
            set(Tags{t},'Position',...
                [rpos(3)*2/140 rpos(4)*(2+27/length(Tags)*(length(Tags)-t))/30 rpos(3)*46/140 1.75]);
            set(listEdit{t},'Position',...
                [rpos(3)*50/140 rpos(4)*(2+27/length(Tags)*(length(Tags)-t))/30 rpos(3)*88/140 1.75]);
        end
    end

%% Callback for list box
    function listEditCallback(src,evt)
        guidata(src,gcf);
    end % listEditCallback


%% Callback for select button
    function selectButtonCallback(src,evt)
        for t=1:length(tag_list)
            try
                eval(['output.(tag_list{t}) = ',get(listEdit{t},'String'),';']);
            catch
                output.(tag_list{t}) = get(listEdit{t},'String');
            end
        end
        delete(f);
        return
    end % selectButtonCallback


%% ------------ GUI layout ---------------

%% Set up the figure and defaults
f = figure('Units','characters',...
    'Position',[20 20 150 30],...
    'Color',panelColor,...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name','Input dialog',...
    'Visible','off',...
    'ResizeFcn',@figResize);

%% Create the right side panel
rightPanel = uipanel('bordertype','etchedin',...
    'BackgroundColor',panelColor,...
    'Units','characters',...
    'Position',[5 1 140 25],...
    'Parent',f,...
    'ResizeFcn',@rightPanelResize);

%% Add listbox and label
for i=1:length(tag_list)
    Tags{i} = uicontrol(f,'Style','text','Units','characters',...
        'Position',[1 1 1 1],...
        'HorizontalAlignment','right',...
        'String',tag_list{i},...
        'FontSize',10,...
        'BackgroundColor',panelColor,...
        'Parent',rightPanel);
    listEdit{i} = uicontrol(f,'Style','edit','Units','characters',...
        'Position',[1 1 1 1],...
        'HorizontalAlignment','left',...
        'String',values{i},...
        'FontSize',10,...
        'BackgroundColor','white',...
        'Max',20,'Min',1,...
        'Parent',rightPanel,...
        'Callback',@listEditCallback);
end

%% Add buttons
selectButton = uicontrol(f,'Style','pushbutton','Units','characters',...
    'Position',[1 1 1 1],...
    'String','OK',...
    'Parent',f,...
    'Callback',@selectButtonCallback);

uiwait(f);

end % uipanel1




