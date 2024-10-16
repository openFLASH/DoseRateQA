%% Remove_all_empty
% Deletes all empty data from the |handles.*| structures.
%
%% Syntax
% |handles = Remove_all_empty(handles)|
%
% |handles = Remove_all_empty(handles,clear_workspace)|

%% Description
% |handles = Remove_all_empty (handles)| clears all empty data contained inside |handles.*|

%% Input arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal data structure containing the update after deleting all images.

%% Contributors
% Author(s): Guillaume Janssens (open.reggui@gmail.com).

function handles = Remove_all_empty(handles)

types = {'images','fields','mydata','plans'};

for t=1:length(types)
    index = 2;
    while index<=length(handles.(types{t}).name)        
        if(not(sum(handles.(types{t}).data{index}(:))))            
            switch types{t}
                case 'images'
                    handles = Remove_image(handles.(types{t}).name{index},handles);
                case 'fields'
                    handles = Remove_field(handles.(types{t}).name{index},handles);
                case 'mydata'
                    handles = Remove_data(handles.(types{t}).name{index},handles);
                case 'plans'
                    handles = Remove_plan(handles.(types{t}).name{index},handles);
            end
        else
            index = index+1;
        end
    end
end
