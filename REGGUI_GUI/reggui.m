%% reggui
% Create a reggui structure - with or without graphical items (GUI) - and execute the input instructions (if any).
%
%% Syntax
% |reggui(Name1,Value1,...)|
%
% |handles = reggui(_)|
%
%% Description
% |reggui(Name1,Value1,...)| specifies inputs using one or more Name,Value pair arguments. For a list of recognized input names, see Input arguments.
%
% |handles = reggui(_)| returns the reggui structure.
%
%% Input arguments
% |('GUI',Value)| : |Value| - _SCALAR_ - specifies whether the GUI must be used or not. The default value is 0.
%
% * |Value=0| : No GUI
%
% * |Value=1| : The GUI (|regguiC|) is started
%
% * |Value=2| : The GUI (|regguiC|) is started, as well as the external instruction list GUI
%
% |('dataPath',Value)| : |Value| - _STRING_ - specifies the default path to the data (i.e. the working repository).
%
% |('log',Value)| : |Value| - _STRING_ - specifies the text file that will be used for logging.
%
% |('input',Value)| : |Value| - _STRING_ - specifies the (full) name of a previously saved reggui structure (.mat file) that will be opened when starting reggui.
%
% |('output',Value)| : |Value| - _STRING_ - specifies a (full) file name for saving the reggui structure after processing all instructions.
%
% |('workflow',Value)| : |Value| - _CELL of STRING_ or _STRING_ - specifies the instructions to be executed by reggui. There are 3 possible input types:
%
% * Instruction list : Nx1 or 1xN cell containing the N instructions (_STRING_) to be executed in reggui
%
% * Instruction list filename (*.txt) : the list of instructions is loaded from a text file (prior to the execution of the instructions in reggui)
%
% * Workflow filename (*.m) : the given workflow script that generates a list of instructions will be called (prior to the execution of the instructions in reggui) 
%
% |('workflow_data',Value)| : |Value| - _STRUCT_ - (optional) specifies the input parameters for calling a workflow script. This is used only when the Value corresponding to the 'workflow' parameter is a workflow script (*.m)
%
% |('process',Value)| : |Value| - _STRUCT_ - (optional) specifies the required actions/process to be executed in a workflow. This is used only when the Value corresponding to the 'workflow' parameter is a workflow script (*.m)
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function varargout = reggui(varargin)

% get reggui folder
temp = mfilename('fullpath');
[reggui_dir,~] = fileparts(temp);

% add reggui folder and sub-folders to matlab path
if ~isdeployed  % Can't add folders to path when compiled
    addpath_reggui(reggui_dir)
end
%addpath(reggui_dir);
%d = dir(reggui_dir);
%for i=1:length(d)
%    if(d(i).isdir && (not(strcmp(d(i).name(1),'.')))) % do not include hidden folder (e.g. ".git")
%        addpath(genpath(fullfile(reggui_dir,d(i).name)));
%    end
%end

cd(reggui_dir)

% create reggui user data folder if not existing
[~,reggui_config_dir] = get_reggui_path;
if(not(isdir(reggui_config_dir)))
    try
        mkdir(reggui_config_dir)
        disp('Creating reggui user data directory...')
    catch
        disp(['Cannot create reggui user data directory (',reggui_config_dir,')']);
    end
    try
        copyfile(fullfile(fullfile(fullfile(fullfile(reggui_dir,'functions'),'gui'),'reggui_config'),'plugins_config_default.txt'),fullfile(reggui_config_dir,'plugins_config.txt'))
        disp('Creating plugins configuration file...')
    catch
        disp('Cannot copy plugins configuration file')
    end
end

% display starting message
disp('--------------------')

% default inputs
instructions = cell(0);
workflow_data = [];
process = [];
visu = 0;
handles_fields = {};
input_project_filename = '';
output_project_filename = '';
dataPath = pwd;
dataPath_filename = fullfile(reggui_config_dir,'default_data_path.txt');
log_filename = fullfile(reggui_config_dir,'reggui_logs.txt');

% read optional inputs
for i=1:2:length(varargin)-1
    if(ischar(varargin{i}))
        switch varargin{i}
            case 'GUI'
                visu = varargin{i+1};
            case 'dataPath'
                if(exist(varargin{i+1},'dir'))
                    dataPath = varargin{i+1};
                    if(visu && exist(dataPath_filename,'file'))
                        % write new dataPath to the default dataPath file
                        f = fopen(dataPath_filename,'w');
                        fprintf(f,[char(strrep(dataPath,'\','/')),'\n']);
                        fprintf(f,[' \n']);
                        fclose(f);
                    end
                else
                    disp([varargin{i+1},' directory could not be found. Use default dataPath.'])
                end
                dataPath_filename = '';
            case 'log'
                log_dir = fileparts(varargin{i+1});
                if(exist(log_dir,'dir'))
                    log_filename = varargin{i+1};
                else
                    disp([log_dir,' folder could not be found. log file set to ',log_filename])
                end
            case 'input'
                if(exist(varargin{i+1},'file'))
                    input_project_filename = varargin{i+1};
                else
                    disp([varargin{i+1},' file could not be found. No input project will be loaded.'])
                end
            case 'output'
                output_project_filename = varargin{i+1};
            case 'workflow'
                instructions = varargin{i+1};
            case 'workflow_data'
                workflow_data = varargin{i+1};
            case 'process'
                process = varargin{i+1};
            case 'handles_fields'
                handles_fields = varargin{i+1};
            otherwise
                disp(['Unknown input parameter : ',varargin{i}])
        end
    end
end

% check input fields
if(not(isempty(handles_fields)))
    if(not(round(length(handles_fields)/2) == length(handles_fields)/2))
        handles_fields = handles_fields(1:end-1);
    end
    temp = {};
    for i=1:2:length(handles_fields)-1
        if(ischar(handles_fields{i}))
            temp{end+1} = handles_fields{i};
            temp{end+1} = handles_fields{i+1};
        end
    end
    handles_fields = temp;
end

% if instructions is an existing txt file, import the instructions from the
% file, else if instructions is an existing workflow script, run it.
if(not(iscell(instructions)))
    if(exist(instructions,'file'))
        if(strcmp(instructions(end-1:end),'.m'))    
            % move to workflow folder
            [pathname,instructions] = fileparts(instructions);
            if(exist(pathname,'dir'))
                cd(pathname);
            end
            % run workflow script
            if(not(isempty(workflow_data)) && not(isempty(process)))
                eval(['instructions = ',instructions,'(workflow_data,process);']);
            elseif(not(isempty(workflow_data)))
                eval(['instructions = ',instructions,'(workflow_data);']);
            else
                try % try without input data, then with only the path to data as input.
                    eval(['instructions = ',instructions,'();']);
                catch
                    workflow_data.dataPath = dataPath;
                    eval(['instructions = ',instructions,'(workflow_data);']);
                end
            end
            cd(reggui_dir)
        else
            % text file
            try
                fid = fopen(instructions);
                instructions = cell(0);
                tline = fgetl(fid);
                while ischar(tline)
                    instructions{end+1} = tline;
                    tline = fgetl(fid);
                end
                fclose(fid);
            catch
                fclose(fid);
            end
        end
    else
        instructions = {instructions};
    end
end

% try reading the default data path from file
if(visu && not(isempty(dataPath_filename)))
    if(exist(dataPath_filename,'file'))
        f = fopen(dataPath_filename,'r');
        current_default_path = char(fgetl(f));
        fclose(f);
    else
        current_default_path = pwd;
    end
    if(isdir(fileparts(dataPath_filename)))
        if(exist(current_default_path,'dir'))
            dataPath = uigetdir(current_default_path,'Select data repository');
        else
            dataPath = uigetdir(dataPath,'Select data repository');
        end
        f = fopen(dataPath_filename,'w');
        fprintf(f,[char(strrep(dataPath,'\','/')),'\n']);
        fclose(f);
    end
end

% add opening and/or saving of input/output project files
if(not(isempty(input_project_filename)))
    if(exist(input_project_filename,'file'))
        instructions(2:end+1) = instructions;
        instructions{1} = ['handles = Open_reggui_handles(handles,''',input_project_filename,''');'];
    end
end
if(not(isempty(output_project_filename)))
    instructions{end+1} = ['Save_reggui_handles(handles,''',output_project_filename,''');'];
end

if(visu) % execution from regguiC
    
    if(visu == 2)
        regguiC(1,dataPath,instructions,log_filename,handles_fields);
    else
        regguiC([],dataPath,instructions,log_filename,handles_fields);
    end
    
else % standalone execution
    
    handles = struct;
    
    % get path
    temp = mfilename('fullpath');
    [handles.path,~] = fileparts(temp);
    handles.dataPath = dataPath;
    
    % initialize the handles structure
    handles = Initialize_reggui_handles(handles);
    
    % modify fields
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
    
    % pass the instructions
    handles.instructions = instructions;
    
    % pass the log filename and print the start
    handles.log_filename = log_filename;    
    reggui_logger.info(['Starting reggui with path to data: ',handles.dataPath],handles.log_filename)
    
    % execute instructions
    handles = Execute_reggui_instructions(handles);
    
end

% if required, output the reggui handles
if(nargout>0)
    if(visu)
        varargout{1} = [];
    else
        varargout{1} = handles;
    end
end
