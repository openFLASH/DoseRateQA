%% Export_instructions
% Save on disk a list of instructions in a text file
%
%% Syntax
% |Export_instructions(myIn,outname)|
%
%
%% Description
% |Export_instructions(myIn,outname)| Save the instructions to file
%
%
%% Input arguments
% |myIn| - _CELL VECTOR of STRING_ - |myIn{i}| String describing the i-th REGGUI instruction. The string must describe a valid Matlab / REGGUI command. 
%
% |outname| - _STRING_ - Name of the file in which the instructions should be saved
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Export_instructions(myIn,outname)

fid = fopen(strcat(outname,'.txt'),'w');
for i=1:length(myIn)
    myIn{i} = strrep(myIn{i},'\','\\');
    fprintf(fid,strrep(myIn{i},'%','%%'));
    fprintf(fid,'\n');
end
fclose(fid);
