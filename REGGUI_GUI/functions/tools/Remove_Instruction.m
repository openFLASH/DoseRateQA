%% Remove_Instruction
% Remove one line from the list of instructions.
% The list of instructions defines a script to automatically execute the REGGUI instruction in the deifned order.
%
%% Syntax
% |new_instructions = Remove_Instruction(index,instructions)|
%
%
%% Description
% |new_instructions = Remove_Instruction(index,instructions)| Remove one line from the list of instructions
%
%
%% Input arguments
% |index| - _INTEGER_ - Index of the instruction to be removed from the list of instruction
%
% |instructions| - _CELL VECTOR of STRING_ - |instructions{i}| REGGUI command representing the i-th instruction in the list of instruction
%
%
%% Output arguments
%
% |new_instructions| - _CELL VECTOR of STRING_ List of instruction ofter removeal o the instruction at |index|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function new_instructions = Remove_Instruction(index,instructions)
if(index<=length(instructions))
    new_instructions = instructions([1:index-1,index+1:length(instructions)]);
else
    disp('Cannot remove instruction because index is out of range')
    new_instructions = instructions;
end
