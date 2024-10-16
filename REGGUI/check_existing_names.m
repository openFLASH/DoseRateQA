%% check_existing_names
% Check wether the proposed name for a new image is already present in the list of name. If it is present, the new name is modified by adding '_X' extension at the end of the name (where 'X' is an incremental number).  
%
%% Syntax
% |new_name = check_existing_names(name,name_list)|
%
%
%% Description
% |new_name = check_existing_names(name,name_list)| Modify the proposed name to make it unique in the list of names
%
%
%% Input arguments
% |name| - _STRING_ -  Proposed name of a new image to add to the list
%
% |name_list| - _CELL VECTOR_ -  |name_list{i}| The name of the ith image in the list
%
%
%% Output arguments
%
% |new_name| - _STRING_ - Name for the new image. This name is not already present in |name_list|
%
% |index| - _INTEGER_ - If the name already exist, return the index of the image in handles.images{index}. If the name does not exists, return 0.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [new_name,index] = check_existing_names(name,name_list)

% remove ambiguous characters
name = remove_bad_chars(name);

% search existing names
comparison = strcmp(name_list,name);
[~,index] = find(comparison);

if(sum(comparison))
    new_name = [name '_1'];
    checking = 2;
    while checking
        if(sum(strcmp(name_list,new_name)))
            underscores = strfind(new_name,'_');
            new_name = [new_name(1:underscores(end)) num2str(checking)];
            checking = checking + 1;
        else
            checking = 0;
        end
    end
else
    new_name = name;
    index = 0;
end
