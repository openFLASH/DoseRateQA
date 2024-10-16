%% strpad
% Add space character at the end of a string to reach the length specified by |nb_chars|.
% In addition, the '<' are replaced by '&lt;' and the '%' character is replaced by '%%'
%
%% Syntax
% |str = strpad(str,nb_chars)|
%
%
%% Description
% |str = strpad(str,nb_chars)| Description
%
%
%% Input arguments
% |str| - _STRING_ - String to be padded 
%
% |nb_chars| - _INTEGER_ - Final length of the string
%
%
%% Output arguments
%
% |str| - _STRING_ - The padded string
%
%
%% Contributors
% Authors : 

function str = strpad(str,nb_chars)
while(length(str)<nb_chars)
    str = [str,' '];
end
str = strrep(str,'<','&lt;');
str = strrep(str,'%','%%');
