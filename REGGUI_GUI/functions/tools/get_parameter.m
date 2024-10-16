%% get_parameter
% Return the value associated with a given parameter in a cell array. The first column of cell array define the name of the parameter. the second column defines the values of the parameters.
%
%% Syntax
% |value = get_parameter(paramsCellArray, arg)|
%
%
%% Description
% |value = get_parameter(paramsCellArray, arg)| Return the value of the parameter form thz cell array
%
%
%% Input arguments
% |paramsCellArray{i,1:2}| - _CELL ARRAY of STRING_ - List of parameters with their correspondin value. |paramsCellArray{i,1}| is the name of the parameter. |paramsCellArray{i,2}| is the value of the parameter.
%
% |arg| - _STRING_ - Name of the parameter to look for in the cell array |paramsCellArray{i,1}| 
%
%
%% Output arguments
%
% |value| - _STRING_ - ith value |paramsCellArray{i,2}| of the cell array with a name |paramsCellArray{i,1}| equal to |arg|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function value = get_parameter(paramsCellArray, arg)
index = find(strcmp(paramsCellArray,arg));
if(not(isempty(index)))
    value = paramsCellArray{index + size(paramsCellArray, 1)};
    value = strrep(value, '"', '');
else
    disp(['Warning: parameter ''',arg,''' not found.']);
    value = [];
end
