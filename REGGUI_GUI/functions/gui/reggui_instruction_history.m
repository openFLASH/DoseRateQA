function reggui_instruction_history(instructions)

% Authors : G.Janssens

%% Use system background color for GUI components
panelColor = get(0,'DefaultUicontrolBackgroundColor');

%% ------------ Callback Functions ---------------

% Figure resize function
    function figResize(src,evt)
        fpos = get(f,'Position');
    end

%% Callback for list box
    function listBoxCallback(src,evt)
        
    end % listBoxCallback


%% Callback for exit button
    function exitButtonCallback(src,evt)
        delete(f);
        return
    end % exitButtonCallback

%% Callback for remove button
    function removeButtonCallback(src,evt)
        instructions = get(listBox,'String');
        var_index = get(listBox,'Value');
        for i=1:length(var_index)
            index = var_index(i)-i+1;
            instructions = instructions([1:index-1,index+1:length(instructions)]);
        end
        set(listBox,'String',instructions);
        set(listBox,'Value',[]);
    end % exitButtonCallback

%% Callback for export button
    function exportButtonCallback(src,evt)
        [filename,pathname] = uiputfile({'*.m'},'Save workflow as');
        output_file = fullfile(pathname,filename);
        fid = fopen(output_file,'wt');
        fprintf(fid,char(['function instructions = ' filename(1:end-2) '(workflow_data)']));fprintf(fid,'\n');
        fprintf(fid,'instructions = cell(0);');fprintf(fid,'\n');
        fprintf(fid,'instructions{end+1} = ''handles = Initialize_reggui_workflow(handles);'';');fprintf(fid,'\n');
        for i=1:length(instructions)
            is_write_import = 0;
            try
                is_write_import = strcmp(instructions{i}(1:15),'Generate_import');
            catch
            end
            if(is_write_import)
                fprintf(fid,['instructions{end+1} = ' instructions{i}]);
            else
                instructions{i} = strrep(strrep(instructions{i},'''',''''''),'\','\\');
                fprintf(fid,['    instructions{end+1} = ''' instructions{i} ''';']);
            end
            fprintf(fid,'\n');
        end
        fprintf(fid,'end');
        fprintf(fid,'\n');
        fclose(fid);
        % Append workflow script to config file
        temp = mfilename('fullpath');
        [reggui_path,~] = fileparts(temp);
        fid = fopen(fullfile(fullfile(reggui_path,'reggui_config'),'plugins_config.txt'),'a');
        fprintf(fid,'\n%s',output_file);
        fclose(fid);
        delete(f);
        return
    end


%% Callback for export button
    function scriptButtonCallback(src,evt)
        [filename,pathname] = uiputfile({'*.m'},'Save script as');
        output_file = fullfile(pathname,filename);
        fid = fopen(output_file,'wt');
        fprintf(fid,'handles = reggui();');fprintf(fid,'\n');
        for i=1:length(instructions)
            is_write_import = 0;
            try
                is_write_import = strcmp(instructions{i}(1:15),'Generate_import');
            catch
            end
            if(is_write_import)
                temp = strsplit(instructions{i},'%');
                fprintf(fid,strrep(temp{end},'\','\\'));
            else
                fprintf(fid,strrep(instructions{i},'\','\\'));
            end
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        fclose(fid);
        % Append workflow script to config file
        temp = mfilename('fullpath');
        [reggui_path,~] = fileparts(temp);
        fid = fopen(fullfile(fullfile(reggui_path,'reggui_config'),'plugins_config.txt'),'a');
        fprintf(fid,'\n%s',output_file);
        fclose(fid);
        delete(f);
        return
    end


%% ------------ GUI layout ---------------

%% Set up the figure and defaults
f = figure('Units','characters',...
    'Position',[30 32 220 37],...
    'Color',panelColor,...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Name','History');
%'ResizeFcn',@figResize);

%% Add listbox and label
listBoxLabel = uicontrol(f,'Style','text','Units','characters',...
    'Position',[1 2 195 33],...
    'String','Executed instructions',...
    'FontSize',14,...
    'BackgroundColor',panelColor,...
    'Parent',f);
listBox = uicontrol(f,'Style','listbox','Units','characters',...
    'Position',[1 1 195 30],...
    'BackgroundColor','white',...
    'Max',10,'Min',1,...
    'String',instructions,...
    'Parent',f,...
    'Callback',@listBoxCallback);

%% Add buttons
exitButton = uicontrol(f,'Style','pushbutton','Units','characters',...
    'Position',[198 1 20 2],...
    'String','OK',...
    'BackgroundColor',[0.71 0 0],...
    'Parent',f,...
    'Callback',@exitButtonCallback);

exportButton = uicontrol(f,'Style','pushbutton','Units','characters',...
    'Position',[198 4 20 2],...
    'String','Create Workflow',...
    'BackgroundColor','white',...
    'Parent',f,...
    'Callback',@exportButtonCallback);

exportButton = uicontrol(f,'Style','pushbutton','Units','characters',...
    'Position',[198 7 20 2],...
    'String','Create script',...
    'BackgroundColor','white',...
    'Parent',f,...
    'Callback',@scriptButtonCallback);

removeButton = uicontrol(f,'Style','pushbutton','Units','characters',...
    'Position',[198 10 20 2],...
    'String','Remove',...
    'BackgroundColor','white',...
    'Parent',f,...
    'Callback',@removeButtonCallback);

%% Initialize list box and make sure
% the hold toggle is set correctly
listBoxCallback(listBox,[])
uiwait(f);

end % uipanel1




