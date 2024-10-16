%% Execute_reggui_instructions
% Execute the script of instruction contained in |handles.instructions|. The instructions are executed untill the instruction list is empty
%
%% Syntax
% |handles = Execute_reggui_instructions(handles)|
%
%
%% Description
% |handles = Execute_reggui_instructions(handles)| Execute all the instruction in the list
%
%
%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.instructions| - _CELL VECTOR of STRING_ - |handles.instructions{i}| String describing the i-th REGGUI instruction. The string must describe a valid Matlab / REGGUI command.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated:
%
% * |handles.instructions| - _CELL VECTOR of STRING_ - Empty cell when the instruction list is empty
% * |handles.instruction_history| - _CELL VECTOR of STRING_ - Historical sequence of all instructions executed in REGGUI. Same format as |handles.instructions|
% * |handles.error_count| - _INTEGER_ - Number of error encountered during the processing of instructions
% * |handles.auto_mode| - _INTEGER_ - 0 = auto mode is not active. 1 = auto mode is active (see function |Automatic|)
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


% TODO Use function compute_processing_time instead of reimplementing it

function handles = Execute_reggui_instructions(handles)

current_dir = pwd;
current = cell(0);
current.instructions = handles.instructions;

while(not(isempty(current.instructions)))
    myIn = current.instructions{1};
    disp(['Executing << ' myIn ' >> ... '])
    try
        % replace variables by corrsponding data in the handles structure
        % myIn = Check_var(myIn,handles);
        % get the initial time
        starting_time = clock;
        % execute the instruction
        eval(myIn);
        % compute processing time
        execution_time = clock - starting_time;
        if(execution_time(6)<0)
            execution_time(5) = execution_time(5)-1;
            execution_time(6) = 60 + execution_time(6);
        end
        if(execution_time(5)<0)
            execution_time(4) = execution_time(4)-1;
            execution_time(5) = 60 + execution_time(5);
        end
        % display memory usage and computation time
        if(ispc)
            userview = memory;
            disp(['Done. (Memory usage: ',num2str(round(userview.MemUsedMATLAB/1e6)),' MB & time: ',num2str(execution_time(4)),'h ',num2str(execution_time(5)),''' and ',num2str(execution_time(6)),''''')'])
        else
            disp(['Done. (time: ',num2str(execution_time(4)),'h ',num2str(execution_time(5)),''' and ',num2str(execution_time(6)),''''')']);
        end
        disp(' ')
        % update the instruction history
        handles.instruction_history{length(handles.instruction_history)+1} = myIn;
    catch
        handles.error_count = handles.error_count+1;
        handles.instructions = current.instructions;
        % Display and log last error
        err = lasterror;
        msg = {['Executing << ',strrep(myIn,'\','/'),' >> ...']};
        msg{end+1} = remove_html_from_str(strrep(err.message,'\','/'));
        i=1;
        while isempty(strfind(err.stack(i).file,'Execute_reggui_instructions.m')) && i<10
            msg{end+1} = ['>Error in ',err.stack(i).file,' (line ',num2str(err.stack(i).line),') : ',err.stack(i).name];
            i = i+1;
        end
        reggui_logger.error(msg,handles.log_filename);
        disp(' ')
        if(not(handles.auto_mode) && strcmp(err.identifier,'MATLAB:nomem'))
            errordlg('Not enough memory available for this operation.','Out of Memory Error');
        end
        if(isfield(handles,'error_mode'))
            if(handles.error_mode)
                rethrow(lasterror);
            end
        end
    end
    current.instructions = Remove_Instruction(1,current.instructions);
end

handles.instructions = cell(0);

cd(current_dir)
