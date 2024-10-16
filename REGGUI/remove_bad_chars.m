%% remove_bad_chars
% Remove character that are not allowed in image names in |handles|. The illegal characters are either replaced by '_' or simply removed.
%
%% Syntax
% |name = remove_bad_chars(name)|
%
%
%% Description
% |name = remove_bad_chars(name)| Return a name that no longer contains illegal characters
%
%
%% Input arguments
% |name| - _STRING_ - Proposed image name
%
%
%% Output arguments
%
% |name| - _STRING_ - Image name without illegal characters
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function name = remove_bad_chars(name)

if(iscell(name))
    for i=1:length(name)
        name{i} = remove_bad_chars(name{i});
    end   
elseif(ischar(name) || isstring(name))
    
    % Remove some characters
    name = strrep(name,'%','');
    name = strrep(name,'~','');
    name = strrep(name,'^','');
    name = strrep(name,'&','');
    name = strrep(name,'\','');
    name = strrep(name,'+','');
    name = strrep(name,'*','');
    name = strrep(name,'/','');
    
    % Replace all special characters by underscores
    name(uint8(name)<48 | (uint8(name)>57 & uint8(name)<65) | (uint8(name)>90 & uint8(name)<97) | uint8(name)>122) = '_';
    
    if(not(isnan(str2double(name))))
        name = ['x_',name];
    end
    
    while(length(name)>1 && name(1)=='_')
        name = name(2:end);
    end
    
end
