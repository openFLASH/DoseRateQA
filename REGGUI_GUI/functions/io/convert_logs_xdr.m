function [version,outputDir] = convert_logs_xdr(logFilename,outputDir,xdr_converter)

if(nargin<2)
    outputDir = '';
end
if(nargin<3)
    xdr_converter = '';
end

if(isempty(outputDir))
    [path,filename,~] = fileparts(logFilename);
    outputDir = fullfile(path,filename);
    if(not(exist(outputDir,'dir')))
        try
            mkdir(outputDir)
        catch
        end
    end
end

version = '';
if strcmp(logFilename(end-6:end-4), '2.6')
    if(nargin<3 || isempty(xdr_converter))
        xdr_converter = which(fullfile('externals','data-recorder-proc-8.3.2.1-deploy.jar'));
    end
    version = '2.6';
elseif strcmp(logFilename(end-6:end-4),'2.7')
    if(nargin<3 || isempty(xdr_converter))
        xdr_converter = which(fullfile('externals','data-recorder-proc-8.5.1.2-deploy.jar'));
    end
    version = '2.7';
elseif strcmp(logFilename(end-6:end-4),'2.8')
    if(nargin<3 || isempty(xdr_converter))
        xdr_converter = which(fullfile('externals','data-recorder-proc-11.0.3.1-deploy.jar'));
    end
    version = '2.8';
end


% ------------------------------------
% Convert XDR files (only if output directory is still empty)
% ------------------------------------

currentPath = pwd;

if ~isempty(xdr_converter)    
    cd(outputDir);
    listDir = dir_without_hidden(outputDir);
    if(length(listDir)<=2)
        % cd(fileparts(mfilename('fullpath')));
        convertXDR(logFilename, outputDir, xdr_converter);
        listDir_new = dir;
        if(length(listDir_new)<=2) % if XDR conversion failed, try without conversion (i.e. zip file with already converted CSV files)
            disp('Unzipping archive to search for CSV files...')
            unzip(logFilename,outputDir);
            f = dir(outputDir);
            % remove xdr files
            for i=1:1:size(f,1)
                if(not(isempty(strfind(f(i).name,'.xdr'))))
                    delete(fullfile(outputDir,f(i).name));
                end
            end
            %         % remove duplicates (FIX beacuse of BUG in unzip function: inversion of the filename with dots)
            %         for i=1:1:size(f,1)
            %             if(not(isnan(str2double(f(i).name(1)))))
            %                 delete(fullfile(outputDir,f(i).name));
            %             end
            %         end
        end
    end
else
    cd(outputDir);
    listDir_new = dir;
    if(length(listDir_new)<=2) % if XDR conversion failed, try without conversion (i.e. zip file with already converted CSV files)
        disp('Warning: no converted file found. Unzipping archive to search for CSV files...')
        unzip(logFilename,outputDir);
        if(isempty(dir(fullfile(outputDir,'*.csv')))) % zip of folder instead of zip of files
            d = dir(outputDir);
            d = d([d(:).isdir]==1);
            d = d(~ismember({d(:).name},{'.','..'}));
            if(length(d)==1)
                dir_to_remove = fullfile(d(1).folder,d(1).name);
                d = dir(dir_to_remove);
                d = d([d(:).isdir]==0);
                for i=1:length(d)
                    movefile(fullfile(d(i).folder,d(i).name),fullfile(outputDir,d(i).name));
                end
                rmdir(dir_to_remove);
            end
        end
    end
end

cd(currentPath);

end


% ----------------------------------------------------------------------
function convertXDR(logFilename, outputPath, xdrConvFile)

if(iscell(xdrConvFile))
    java = ['!"',xdrConvFile{1},'" -classpath'];
    xdrConvFile = xdrConvFile{2};    
else
    java = '!java -classpath';
end
disp(['XDR converter: ',xdrConvFile])

try    
    if ismac || isunix
        xdrConvPref = ' sites.configs.LLN.LAB-continuous-SNAPSHOT-deploy.jar:';
    elseif ispc
        xdrConvPref = ' sites.configs.LLN.LAB-continuous-SNAPSHOT-deploy.jar;';
    end
    
    xdrConv = [xdrConvPref, '"', xdrConvFile, '"'];
    
    argsXdrConv1 = ' com.iba.icomp.core.launch.Launcher';
    argsXdrConv2 = ' config/bms/dataRecorder/container.xml';
    argsXdrConv3 = ' -Dconfig.recorder.mode=converter';
    argsXdrConv4 = ' -Dbms.datarecorder.converter.file=';
    argsXdrConv5 = ['"',logFilename,'"'];
    argsXdrConv6 = ' -Dbms.datarecorder.converter.outputdir=';
    argsXdrConv7 = ['"',outputPath,'"'];
    
    cmd = [java, xdrConv, argsXdrConv1, argsXdrConv2, argsXdrConv3,...
        argsXdrConv4, argsXdrConv5, argsXdrConv6, argsXdrConv7];
    
    cmd = strrep(cmd,'\','/');
    disp(cmd);
    eval(cmd);
    
catch err
    disp(err.message);
end
end
