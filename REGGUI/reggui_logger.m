classdef reggui_logger
    % reggui_logger is a static class that provides a system to display info, 
    % warning, error messages to screen and log file.
    
    % Authors : L. Hotoiu, G.Janssens
    
    ...
        
methods(Static)
    %% Basic functions
    function info(msg,filename)
        try
            if ispc
                userview = memory;
            elseif isunix
                [tmp pid] = system('pgrep MATLAB');
                [tmp mem_usage] = system(['cat /proc/' strtrim(pid) '/status | grep VmSize']);
                mem_in_kB = round(str2num(strtrim(extractAfter(extractBefore(mem_usage, ' kB'), ':'))));
                userview = struct('MemUsedMATLAB', mem_in_kB);
            else
                userview = struct('MemUsedMATLAB', nan);
            end
            
            if(nargin<2)
                filename = get_default_log_filename;
            end
            if(ischar(msg))
                msg = {msg};
            end
            time = datestr(now, 'HH:MM:SS');
            fid = fopen(filename, 'a');
            for i=1:length(msg)
                logEntry = strrep(msg{i},'\','/');
                if(i==1)
                    logEntry = horzcat('[INFO: ', time, ' - ',num2str(round(userview.MemUsedMATLAB/1e6)),' MB] ',logEntry);
                else
                    logEntry = horzcat(logEntry);
                end
                disp(logEntry);
                logEntry = strrep(logEntry,'%','%%');
                fprintf(fid, horzcat(logEntry, '\n'));
            end
            disp(' ')
            fprintf(fid,'\n');
            fclose(fid);
        catch err
            reggui_logger.error(err.message);
            return
        end
    end
    
    %--------------------------------------------------------------------------
    
    function warning(msg,filename)
        try
            if ispc
                userview = memory;
            elseif isunix
                [tmp pid] = system('pgrep MATLAB');
                [tmp mem_usage] = system(['cat /proc/' strtrim(pid) '/status | grep VmSize']);
                mem_in_kB = round(str2num(strtrim(extractAfter(extractBefore(mem_usage, ' kB'), ':'))));
                userview = struct('MemUsedMATLAB', mem_in_kB);
            else
                userview = struct('MemUsedMATLAB', nan);
            end
            
            if(nargin<2)
                filename = get_default_log_filename;
            end
            if(ischar(msg))
                msg = {msg};
            end
            time = datestr(now, 'HH:MM:SS');
            fid = fopen(filename, 'a');
            for i=1:length(msg)
                logEntry = strrep(msg{i},'\','/');
                if(i==1)
                    logEntry = horzcat('[WARN: ', time, ' - ',num2str(round(userview.MemUsedMATLAB/1e6)),' MB] ',logEntry);
                else
                    logEntry = horzcat(logEntry);
                end
                disp(logEntry);
                logEntry = strrep(logEntry,'%','%%');
                fprintf(fid, horzcat(logEntry, '\n'));
            end
            disp(' ')
            fprintf(fid,'\n');
            fclose(fid);
        catch err
            reggui_logger.error(err.message);
            return
        end
    end
    
    %--------------------------------------------------------------------------
    
    function error(msg,filename)
        try
            if ispc
                userview = memory;
            elseif isunix
                [tmp pid] = system('pgrep MATLAB');
                [tmp mem_usage] = system(['cat /proc/' strtrim(pid) '/status | grep VmSize']);
                mem_in_kB = round(str2num(strtrim(extractAfter(extractBefore(mem_usage, ' kB'), ':'))));
                userview = struct('MemUsedMATLAB', mem_in_kB);
            else
                userview = struct('MemUsedMATLAB', nan);
            end
            
            if(nargin<2)
                filename = get_default_log_filename;
            end
            if(ischar(msg))
                msg = {msg};
            end
            time = datestr(now, 'HH:MM:SS');
            fid = fopen(filename, 'a');
            for i=1:length(msg)
                logEntry = strrep(msg{i},'\','/');
                if(i==1)
                    logEntry = horzcat('[ERROR: ', time, ' - ',num2str(round(userview.MemUsedMATLAB/1e6)),' MB] ',logEntry);
                else
                    logEntry = horzcat(logEntry);
                end
                disp(logEntry);
                logEntry = strrep(logEntry,'%','%%');
                fprintf(fid, horzcat(logEntry, '\n'));
            end
            disp(' ')
            fprintf(fid,'\n');
            fclose(fid);
        catch err
            %reggui_logger.error(err.message);  % infinite loop when there is an issue in the error function !!!
            disp('Error in reggui_logger.error function !')
            return
        end
    end
end
end % End of classdef
%--------------------------------------------------------------------------


%% Local functions
function log_filename = get_default_log_filename
try
    [~,reggui_config_dir] = get_reggui_path;
    log_filename = fullfile(reggui_config_dir,'reggui_logs.txt');
catch err
    reggui_logger.error(err.message);
    return
end
end
%End local functions
