%% Import_instructions
% Load from a text file on disk a list of instructions. The function then *executes* the instructions.
% The text file can be considered as a script containing REGGUI/ Matlab instructions that Import_instructions is executing.
%
%% Syntax
% |handles = Import_instructions(myInDir,myInFilename,format,handles)|
%
%
%% Description
% |handles = Import_instructions(myInDir,myInFilename,format,handles)| Load list of instructions
%
%
%% Input arguments
% |myInDir| - _STRING_ - Name of the file containing the instructions
%
% |myInFilename| - _STRING_ - Name of the file containing the instructions
%
% |format| - _STRING_ - Format of the file containing the instructions:
%
% * 'txt' : text file
% * 'mat' : Binary Matlab file
%
% |handles| - _STRUCTURE_ - REGGUI data structure.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated:
%
% * |handles.instructions| - _CELL VECTOR of STRING_ - |handles.instructions{i}| String describing the i-th REGGUI instruction. The string must describe a valid Matlab / REGGUI command.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO "executeall.m" does not exist. Use "Execute_reggui_instructions.m" instead

function handles = Import_instructions(myInDir,myInFilename,format,handles)
In_load = 1;
Instructions = cell(0);
switch format
    case 'txt'
        try
            i = 1;
            fid = fopen(fullfile(myInDir,myInFilename), 'r');
            current = fgetl(fid);
            while (~(current==-1) && i<10000)
                Instructions{i} = current;
                current = fgetl(fid);
                i = i+1;
            end
            fclose(fid);
        catch ME
            reggui_logger.info(['Error while importing instruction list : ',fullfile(myInDir,myInFilename),' is not a valid file. ',ME.message],handles.log_filename);
            rethrow(ME);
        end
    case 'mat'
        Instructions = load(fullfile(myInDir,myInFilename));
    otherwise
        In_load = 0;
        disp(['Error while importing instruction list : ',fullfile(myInDir,myInFilename),' has not a valid format.'])
end
if(In_load)
    handles.instructions = Instructions;
end
