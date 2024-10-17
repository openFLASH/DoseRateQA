%% MC2_compute
% Call the external MCsquare executable to run the MCsquare simulation. the function expects that the simulation parameters and the input data are saved in the proerly formated files in the |Simu_dir| directory. For example, the function |MC2_simulation| can carry out this preparation work.
%
% The function determines the current operating system and call the appropriate MCsquare executable. Windows, Mac and Linux are supported.
%
%% Syntax
% |MC2_compute(Simu_dir, MC2_lib_path, MC2_Config)|
%
% |MC2_compute(Simu_dir, MC2_lib_path)|
%
%
%% Description
% |MC2_compute(Simu_dir, MC2_lib_path, MC2_Config)| Excute the MCsquare simulation
%
%
%% Input arguments
% |Simu_dir| - _STRING_ - Directory where the data and configuration files are stored.
%
% |MCsquare_path| - _STRING_ - Directory where the MCsquare executable are stored.
%
% |MC2_Config| -_STRUCT_- [OPTIONAL. Only needed to run MCsqaure on wsl]. If the file 'wsl.conf' activates the option to run MCsqaure under WSL of the host windows computer, then additional folder information are provided in this structure.
%   * |MC2_Config.ScannerDirectory|
%   * |MC2_Config.BDL_File|
%
%
%% Output arguments
%
% None.
%
%
%% REFERENCE
% [1] https://www.xmodulo.com/run-program-process-specific-cpu-cores-linux.html
% [2] https://www.cyberciti.biz/tips/setting-processor-affinity-certain-task-or-process.html
%
%% Contributors
% Authors : K. Souris (open.reggui@gmail.com)

function MC2_compute(Simu_dir, MC2_lib_path, MC2_Config)
disp('Start MCsquare simulation...');
tic

if (ismac)
    %---- Native McOS
    cd(Simu_dir)
    %eval(['!',fullfile(MC2_lib_path, 'MCsquare')]);
    system([fullfile(MC2_lib_path, 'MCsquare')]);

elseif (isunix)

    %---- Native LINUX
    cmdStr = cmdToGetAllCores();

    disp(['Detected OS: UNIX-like'])
    cd(Simu_dir)

    command = ['!' cmdStr ' "',fullfile(MC2_lib_path, 'MCsquare"')];
    disp(['Command: ',command]);
    %eval(['!' cmdStr ' "',fullfile(MC2_lib_path, 'MCsquare"')])
    system([cmdStr ' "',fullfile(MC2_lib_path, 'MCsquare"')])

elseif (ispc)
    %---- Native Windows
    disp(' ')
    disp(['***** MCsquare information below *****'])
    disp(['Detected OS: Windows'])
    disp(' ')
    copyfile(fullfile(MC2_lib_path, 'Materials'), fullfile(Simu_dir, 'Materials'));
    cd(Simu_dir)
    %eval(['!',fullfile(MC2_lib_path, 'MCsquare.bat >> log.txt 2>>&1')]);
    system([fullfile(MC2_lib_path, 'MCsquare.bat')], '-echo'); %Eval is not well supported by compiler
else
    error('This Operating System is not suported')
end

disp(['MCsquare simulation has finished in ' num2str(toc) ' seconds...']);

end

%-----------------------------------------------
%Force the operating system to allocate the maximum number of cores to MCsqaure
%-----------------------------------------------
function cmdStr = cmdToGetAllCores()
[CoreTotal , CoreMatlab] = getNumberLogicalCores();
fprintf('Total number of logical cores available on machine : %d \n', CoreTotal);
fprintf('Total number of logical cores allocated to Matlab  : %d \n', CoreMatlab);

%Create an hexadecimal mask with a binary size equal to CoreTotal
NbF = ceil(CoreTotal ./4);
Resid = mod(CoreTotal,4);
cmdStr = repelem('F' , NbF);
if Resid
    cmdStr = [dec2hex(Resid) cmdStr ];
end

cmdStr = ['taskset ' cmdStr ' '];  %Explicitly ask Linux to allocate all CPU to MCsqaure [2]

end


%------------------------------------------------------
% check whether user wants to use MCsquare under WSL2
% The file 'wsl.conf' must be saved in the root of the folder 'reggui_config_dir'
%-----------------------------------------------------
function wsl = check4WSL(MC2_lib_path)

wsl = false;
%[~,reggui_config_dir] = get_reggui_path();
fileName = fullfile(MC2_lib_path , 'wsl.conf');
if isfile(fileName)
    wslFile = fileread(fileName);
    wsl = strcmp(strip(wslFile),'yes'); %remove white space and formating characters
end
end
