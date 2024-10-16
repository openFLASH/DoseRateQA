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
    %---- WSL2 under Windows
    wsl = check4WSL(MC2_lib_path);
    if wsl
        disp(' ')
        disp(['***** Important information below *****'])
        disp(['Detected OS: Windows'])
        disp(['WSL option activated: will run MC2 in WSL'])
        disp(['WSL1 is not supported'])
        disp(['WSL2 has to be installed (with a recent Ubuntu)'])
        disp(['For more information, see https://openreggui.org/git/open/CAPTAIN/wikis/WSL#wsl-2-ubuntu-and-windows-terminal'])
        disp(['If do NOT want to run the linux version of MC2 in WSL, edit wsl.conf to contain just ''no'''])
        disp(' ')

        %MCsquare finds the material file
        % 1) either in a /Materials folder in the current diurectory. The following file copies the Mateiral folder in the current diurectory
        % copyfile(fullfile(MC2_lib_path, 'Materials'), fullfile(Simu_dir, 'Materials'));
        % 2) Or in the system variable 'MCsquare_Materials_Dir' declared in openMCsquare\lib\MCsquare.
        % This system variable is defined as the folder /Materials which is a subfolder of the folder where the script openMCsquare\lib\MCsquare is located
        cd(MC2_lib_path);
        [~,linux_MC2_lib_path] = system('wsl realpath .'); %wsl path to the MCsquare executable

        %replace path to scanner config by the wsl path
        cd(MC2_Config.ScannerDirectory);
        [~,linux_path] = system('wsl realpath .');
        MC2_Config.ScannerDirectory = linux_path(1,1:end-1);

        %replace path to BDL by the wsl path
        [BDL_path , BDL_filename , BDL_ext] = fileparts(MC2_Config.BDL_File); %Extract the folder name where BDL is store. This function works with / and \ as folder separator
        BDL_filename  = [BDL_filename , BDL_ext];
        cd(BDL_path); %Move to the folder where BDL is store
        [~,linux_path] = system('wsl realpath .'); %Get the Linux path to BDL
        MC2_Config.BDL_File = [char(linux_path(1,1:end-1)),'/',char(BDL_filename)]; %Replace Windows path by Linux path in config file

        Export_MC2_Config(MC2_Config, linux_MC2_lib_path);

        cd(Simu_dir);
        [~,linux_MC2_simu_path] = system('wsl realpath .');

        cmdStr = cmdToGetAllCores();
        command = ['wsl ' , cmdStr , ' "',linux_MC2_lib_path(1,1:end-1),'/MCsquare" "',linux_MC2_simu_path(1,1:end-1), '"'];
        disp(['Command: ',command]);
        system(command);
    else
        %---- Native Windows
        disp(' ')
        disp(['***** Important information below *****'])
        disp(['Detected OS: Windows'])
        disp(['WSL option NOT activated: will launch the Windows executable'])
        disp(['If you are willing to run the linux version of MC2 in WSL, edit wsl.conf to contain just ''yes'''])
        disp(' ')
        copyfile(fullfile(MC2_lib_path, 'Materials'), fullfile(Simu_dir, 'Materials'));
        cd(Simu_dir)
        %eval(['!',fullfile(MC2_lib_path, 'MCsquare.bat >> log.txt 2>>&1')]);
        system([fullfile(MC2_lib_path, 'MCsquare.bat')], '-echo'); %Eval is not well supported by compiler

    end
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
