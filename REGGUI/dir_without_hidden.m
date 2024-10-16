%% dir_without_hidden
% Return the list of non hidden file contained in a directory. All the file with a name starting with '.' are removed from the list (this includeds '.' and '..')
%
%% Syntax
% |d = dir_without_hidden()|
%
% |d = dir_without_hidden(folder)|
%
%
%% Description
% |d = dir_without_hidden()| Find the list of non hidden files and repositories in current working directory
%
% |d = dir_without_hidden(folder)| Find the list of non hidden files and repositories in the specified directory
%
% |d = dir_without_hidden(folder,filter)| Find the list of non hidden file and/or repositories in the specified directory
%
%% Input arguments
% |folder| - _STRING_ -  [OPTIONAL. Default: present working directory] Name of the directory where the files are located
%
% |filter| - _STRING_ -  [OPTIONAL.] 'folders': return only repositories. 'files': return only files.
%
%% Output arguments
%
% |d| - _STRUCTURE VECTOR_ -  Return the same structure as the function |dir| with the hidden files removed from the list
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function d = dir_without_hidden(folder,filter)

if(nargin<1)
    folder = pwd;
end
if(nargin<2)
    filter = '';
end

d = dir(folder);

for i=1:length(d)
    is_hidden(i) = strcmp(d(i).name(1),'.');
end

if(exist('is_hidden'))
    d(is_hidden)=[];
end

switch filter
    case 'folders'
        for i=1:length(d)
            is_folder(i) = d(i).isdir;
        end
        if(exist('is_folder'))
            d = d(is_folder);
        end
    case 'files'
        for i=1:length(d)
            is_file(i) = not(d(i).isdir);
        end
        if(exist('is_file'))
            d = d(is_file);
        end
end
