%% remove_html_from_str
% Remove all the text contained between <> brackets in a string
%
%% Syntax
% |new_str = remove_html_from_str(str)|
%
%
%% Description
% |new_str = remove_html_from_str(str)| Remove illegal characters from string
%
%
%% Input arguments
% |str| - _STRING_ - String to be cleaned
%
%
%% Output arguments
%
% |new_str| - _STRING_ - String without the lement contained in between the <> brackets
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function new_str = remove_html_from_str(str)

new_str = str;
try
    i1 = strfind(str,'<');
    i2 = strfind(str,'>');
    if(not(isempty(i1)))
        if(length(i1)==length(i2))
            new_str = str(1:i1(1)-1);
            for i=1:length(i1)-1
                new_str = [new_str,str(i2(i)+1:i1(i+1)-1)];
            end
            new_str = [new_str,str(i2(end)+1:end)];
        end
    end
catch
    new_str = str;
end

